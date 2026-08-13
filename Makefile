# Antarctic Adventure (Konami, 1984, MSX1) - desensamblado
#
# El cartucho no se distribuye. Hace falta ponerlo en la raiz con el nombre
# antarctic.rom; su sha256 esta abajo y `make comprueba` lo verifica.
#
# El orden de las cosas: trazar el flujo -> generar el listado -> comprobar que
# vuelve a dar la ROM byte a byte -> las comprobaciones que el reensamblado NO
# cubre -> la web.

ROM      = antarctic.rom
ORG      = 0x4000
SHA      = 17f4dd654c937134c44c1faf68a9f67141d69ccf251853228aa5211dc8065126
TITULO   = ANTARCTIC ADVENTURE - Konami (1984) - MSX1 - cartucho de 16 KB

all: listado verify sanity test

$(ROM):
	@echo "=================================================================="
	@echo " Falta $(ROM), y este repositorio NO lo distribuye."
	@echo ""
	@echo " Es el cartucho europeo de Antarctic Adventure (Konami, 1984),"
	@echo " 16384 bytes exactos. Ponlo aqui con ese nombre. Para comprobar"
	@echo " que es el mismo:"
	@echo "     shasum -a 256 $(ROM)"
	@echo "     $(SHA)"
	@echo ""
	@echo " Sin el se puede leer el listado ya generado en src/, y los tests"
	@echo " que no dependen del binario siguen pasando."
	@echo "=================================================================="
	@false

comprueba: $(ROM)
	@echo "$(SHA)  $(ROM)" | shasum -a 256 -c -

# El trazado sigue el flujo desde los puntos de entrada. Los que no se pueden
# deducir estaticamente -la rutina de interrupcion, que se engancha a H.TIMI, y
# los destinos de las seis tablas de salto- estan declarados en el .entries.
work/antarctic.trace.json: $(ROM) src/antarctic.entries src/antarctic.nocode
	@mkdir -p work
	python3 tools/z80trace.py $(ROM) $(ORG) src/antarctic.entries \
	        work/antarctic src/antarctic.nocode

trace: work/antarctic.trace.json

listado: work/antarctic.trace.json src/antarctic.notes
	python3 tools/mkasm.py $(ROM) $(ORG) work/antarctic.trace.json \
	        src/antarctic.notes work/msx.sym src/antarctic.asm "$(TITULO)"

# La prueba que decide si el desensamblado es fiable.
verify: src/antarctic.asm $(ROM)
	@sh tools/verify_build.sh src/antarctic.asm $(ROM) $(ORG)

# Los graficos van comprimidos: la unica forma de verlos es hacer lo mismo que
# hace el juego. Esto reconstruye la VRAM y dibuja los tiles y los sprites.
graficos: $(ROM)
	@mkdir -p work/png
	python3 tools/descomprime.py $(ROM) work
	python3 tools/render_tiles.py work/vram.bin work/png

# Lo que el reensamblado NO puede cazar: que unos datos se esten leyendo como
# codigo. El binario sale identico igual, porque los bytes no cambian; lo unico
# que cambia es lo que decimos de ellos.
sanity: work/antarctic.trace.json
	@echo "=================================================================="
	@echo " Ningun byte declarado como datos puede salir como codigo"
	@echo "=================================================================="
	@python3 tools/check_trace.py work/antarctic.trace.json src/antarctic.nocode
	@echo "=================================================================="
	@echo " Ningun punto de entrada puede caer dentro de una zona de datos"
	@echo "=================================================================="
	@python3 tools/check_entradas.py src/antarctic.entries src/antarctic.notes \
	        src/antarctic.nocode

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@python3 -m unittest discover -s tests -v

clean:
	rm -rf work/png work/vram.bin work/vram.escrito
	rm -f work/antarctic.trace.json work/antarctic.blocks

.PHONY: all comprueba trace listado verify graficos sanity test clean imagenes web

# Las imagenes de la web salen del propio cartucho: se descomprime lo que el
# juego descomprime, se dibuja con las bases del VDP que el juego escribe, y se
# ejecutan sus mismos interpretes de bloques. Ninguna es una captura.
imagenes: $(ROM)
	@mkdir -p docs/imagenes
	python3 tools/descomprime.py $(ROM) work >/dev/null
	python3 tools/render_tiles.py work/vram.bin docs/imagenes
	python3 tools/render_decorados.py $(ROM) work/vram.bin docs/imagenes | tail -1
	python3 tools/render_banderas.py $(ROM) work/vram.bin docs/imagenes | tail -3
	python3 tools/render_pista.py $(ROM) work/vram.bin docs/imagenes | tail -1
	python3 tools/render_foca.py $(ROM) work/vram.bin docs/imagenes | tail -2

web: imagenes
	python3 tools/md2html.py docs en
	python3 tools/md2html.py docs/es es
	python3 tools/make_web.py work/vram.bin docs/imagenes docs/index.html en
	python3 tools/make_web.py work/vram.bin docs/imagenes docs/es/index.html es
	@touch docs/.nojekyll
	@python3 tools/check_enlaces.py docs
