# Antarctic Adventure (Konami, 1984, MSX1) - desensamblado de las TRES versiones
#
# De este cartucho hay tres compilaciones distintas, y aqui se desensamblan las
# tres. Cada una tiene su carpeta en src/ con sus puntos de entrada, sus zonas
# de datos, sus notas y su listado.
#
#     make            la version por defecto, la segunda japonesa
#     make V=jap1     la primera japonesa
#     make V=eu       la europea
#     make todas      las tres, una detras de otra
#
# Ninguna ROM se distribuye. Hacen falta en la raiz con estos nombres, y
# `make comprueba` verifica el sha256 de la que toque.
#
# El orden de las cosas: trazar el flujo -> generar el listado -> comprobar que
# vuelve a dar la ROM byte a byte -> las comprobaciones que el reensamblado NO
# cubre -> la web.

V ?= jap2

VERSIONES = jap1 jap2 eu

SHA_jap1 = 087378ddad1379a6e378f0810e9cf1dbb64ee03c36e630bb78020b754b7dfebd
SHA_jap2 = a33f9298bf6f740ebe8d88bdc8ed75c855404d804e07679d6c2f2ad00dc3c452
SHA_eu   = 9b13aaa66661b69a8a9a19656d2d9fd052ddae11aba752e84ebb38b03137739a

NOMBRE_jap1 = primera version japonesa
NOMBRE_jap2 = segunda version japonesa
NOMBRE_eu   = version europea

ROM      = antarctic-$(V).rom
SHA      = $(SHA_$(V))
NOMBRE   = $(NOMBRE_$(V))
SRC      = src/$(V)
WORK     = work/$(V)
ORG      = 0x4000
TITULO   = ANTARCTIC ADVENTURE - Konami (1984) - MSX1 - cartucho de 16 KB - $(NOMBRE)

# La web y las imagenes salen de la version que esta documentada, que es la
# segunda japonesa. No dependen de V.
ROMWEB   = antarctic-jap2.rom

all: listado verify sanity test

# Las tres seguidas. Los tests van una sola vez al final, que son los mismos.
todas:
	@for v in $(VERSIONES); do \
	    echo "##################################################### $$v"; \
	    $(MAKE) --no-print-directory V=$$v listado verify sanity || exit 1; \
	done
	@$(MAKE) --no-print-directory test

$(ROM):
	@echo "=================================================================="
	@echo " Falta $(ROM), y este repositorio NO lo distribuye."
	@echo ""
	@echo " Es Antarctic Adventure (Konami, 1984), $(NOMBRE),"
	@echo " 16384 bytes exactos. Ponlo aqui con ese nombre. Para comprobar"
	@echo " que es el mismo:"
	@echo "     shasum -a 256 $(ROM)"
	@echo "     $(SHA)"
	@echo ""
	@echo " Sin el se puede leer el listado ya generado en $(SRC)/, y los"
	@echo " tests que no dependen del binario siguen pasando."
	@echo "=================================================================="
	@false

comprueba: $(ROM)
	@echo "$(SHA)  $(ROM)" | shasum -a 256 -c -

# El trazado sigue el flujo desde los puntos de entrada. Los que no se pueden
# deducir estaticamente -la rutina de interrupcion, que se engancha a H.TIMI, y
# los destinos de las tablas de salto- estan declarados en el .entries.
$(WORK)/antarctic.trace.json: $(ROM) $(SRC)/antarctic.entries $(SRC)/antarctic.nocode
	@mkdir -p $(WORK)
	python3 tools/z80trace.py $(ROM) $(ORG) $(SRC)/antarctic.entries \
	        $(WORK)/antarctic $(SRC)/antarctic.nocode

trace: $(WORK)/antarctic.trace.json

listado: $(WORK)/antarctic.trace.json $(SRC)/antarctic.notes
	python3 tools/mkasm.py $(ROM) $(ORG) $(WORK)/antarctic.trace.json \
	        $(SRC)/antarctic.notes work/msx.sym $(SRC)/antarctic.asm "$(TITULO)"

# La prueba que decide si el desensamblado es fiable.
verify: $(SRC)/antarctic.asm $(ROM)
	@sh tools/verify_build.sh $(SRC)/antarctic.asm $(ROM) $(ORG)

# Los graficos van comprimidos: la unica forma de verlos es hacer lo mismo que
# hace el juego. Esto reconstruye la VRAM y dibuja los tiles y los sprites.
graficos: $(ROM)
	@mkdir -p $(WORK)/png
	python3 tools/descomprime.py $(ROM) $(WORK)
	python3 tools/render_tiles.py $(WORK)/vram.bin $(WORK)/png

# Lo que el reensamblado NO puede cazar: que unos datos se esten leyendo como
# codigo. El binario sale identico igual, porque los bytes no cambian; lo unico
# que cambia es lo que decimos de ellos.
sanity: $(WORK)/antarctic.trace.json
	@echo "=================================================================="
	@echo " $(V): ningun byte declarado como datos puede salir como codigo"
	@echo "=================================================================="
	@python3 tools/check_trace.py $(WORK)/antarctic.trace.json $(SRC)/antarctic.nocode
	@echo "=================================================================="
	@echo " $(V): ningun punto de entrada puede caer dentro de una zona de datos"
	@echo "=================================================================="
	@python3 tools/check_entradas.py $(SRC)/antarctic.entries $(SRC)/antarctic.notes \
	        $(SRC)/antarctic.nocode
	@echo "=================================================================="
	@echo " $(V): ni un byte del cartucho sin asignar"
	@echo "=================================================================="
	@python3 tools/presupuesto.py $(WORK) $(SRC)

# Las tres comparadas, que es lo que sostiene la pagina de las versiones.
compara: antarctic-jap1.rom antarctic-jap2.rom antarctic-eu.rom
	@python3 tools/compara_versiones.py antarctic-jap1.rom \
	        antarctic-jap2.rom antarctic-eu.rom

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@python3 -m unittest discover -s tests -v

clean:
	rm -rf work/png work/vram.bin work/vram.escrito
	rm -rf $(foreach v,$(VERSIONES),work/$(v))

.PHONY: all todas comprueba trace listado verify graficos sanity compara test \
        clean imagenes web

# Las imagenes de la web salen del propio cartucho: se descomprime lo que el
# juego descomprime, se dibuja con las bases del VDP que el juego escribe, y se
# ejecutan sus mismos interpretes de bloques. Ninguna es una captura.
imagenes: $(ROMWEB)
	@mkdir -p docs/imagenes work
	python3 tools/descomprime.py $(ROMWEB) work >/dev/null
	python3 tools/render_tiles.py work/vram.bin docs/imagenes $(ROMWEB)
	python3 tools/render_decorados.py $(ROMWEB) work/vram.bin docs/imagenes | tail -1
	python3 tools/render_banderas.py $(ROMWEB) work/vram.bin docs/imagenes | tail -3
	python3 tools/render_pista.py $(ROMWEB) work/vram.bin docs/imagenes | tail -1
	python3 tools/render_foca.py $(ROMWEB) work/vram.bin docs/imagenes | tail -3
	python3 tools/render_pinguino.py $(ROMWEB) work/vram.bin docs/imagenes | tail -1

web: imagenes
	python3 tools/md2html.py docs en
	python3 tools/md2html.py docs/es es
	python3 tools/make_web.py work/vram.bin docs/imagenes docs/index.html en
	python3 tools/make_web.py work/vram.bin docs/imagenes docs/es/index.html es
	@touch docs/.nojekyll
	@python3 tools/check_enlaces.py docs
