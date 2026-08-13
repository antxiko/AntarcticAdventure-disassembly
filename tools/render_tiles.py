#!/usr/bin/env python3
"""Dibuja los dibujos del juego desde la VRAM que reconstruye descomprime.py.

No sirve el renderizador general del toolkit, y conviene saber por que: aquel
da por hecha la disposicion que deja la BIOS del MSX -patrones en 0x0000,
nombres en 0x1800, colores en 0x2000- y este cartucho pone otra. Konami escribe
sus propios registros del VDP en 0x44C3, con la tabla de ocho bytes que hay en
0x44DF, y le salen los COLORES abajo y los PATRONES arriba, al reves de lo
corriente:

    R2 = 0x0E   nombres              0x3800
    R3 = 0x7F   colores              0x0000   (R3 & 0x80) * 0x40
    R4 = 0x07   patrones             0x2000   (R4 & 0x04) * 0x800
    R5 = 0x76   atributos de sprite  0x3B00
    R6 = 0x03   patrones de sprite   0x1800
    R7 = 0xE4   tinta 14 sobre fondo 4

Dibujar con las bases cambiadas no da error: da una imagen, y encima
convincente, porque los colores se leen como dibujo y al reves. Por eso las
bases salen de aqui de los registros y no de una constante escrita a mano.

Uso: render_tiles.py <work/vram.bin> <directorio_salida> [rom]

Con la ROM detras, los sprites salen cada uno del color que de verdad les
da su entrada en la tabla de atributos.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from descomprime import descomprime                 # noqa: E402
from render_maps import PALETA, png                 # noqa: E402

# Los ocho registros, tal como estan en la ROM en 0x44DF.
VDP = [0x02, 0xE2, 0x0E, 0x7F, 0x07, 0x76, 0x03, 0xE4]
COLORES = (VDP[3] & 0x80) * 0x40
PATRONES = (VDP[4] & 0x04) * 0x800
NOMBRES = VDP[2] * 0x400
SPR_PAT = VDP[6] * 0x800
SPR_ATR = VDP[5] * 0x80
FONDO = VDP[7] & 0x0F


def pinta_tile(img, x0, y0, patron, color, escala):
    """Una casilla de 8x8: ocho filas, cada una con su pareja dibujo/color."""
    for l in range(8):
        p, c = patron[l], color[l]
        tinta = PALETA[c >> 4] if (c >> 4) else PALETA[FONDO]
        fondo = PALETA[c & 15] if (c & 15) else PALETA[FONDO]
        for b in range(8):
            col = tinta if (p >> (7 - b)) & 1 else fondo
            for ey in range(escala):
                fila = img[(y0 + l) * escala + ey]
                for ex in range(escala):
                    fila[(x0 + b) * escala + ex] = col


def hoja_de_tiles(v, banco, escala=3, ancho=32):
    """Los 256 dibujos de un banco, en una rejilla de 32 x 8.

    Treinta y dos de ancho y no dieciseis porque asi la hoja mide 256 pixeles,
    que es justo el ancho de la pantalla del MSX: los dibujos que el juego usa
    en tiras horizontales -el panel, el horizonte, las bandas de hielo- salen
    en la hoja tal y como se ven en pantalla.

    Y HAY QUE SACAR UNA POR BANCO, no una para todo. En este modo la pantalla
    se parte en tres tercios y cada uno tiene su propio juego de 256 casillas.
    Es tentador suponer que el juego carga las mismas en los tres -la fuente si
    la escribe tres veces, en 0x589C-, pero luego cada escena descomprime sus
    dibujos ENCIMA, banco por banco. Comparando los tres en una VRAM de verdad
    solo quedan iguales DIECINUEVE casillas: la 0x00-0x0F, que son los cuadrados
    de color liso, y la 0xFD-0xFF, que estan vacias.
    """
    alto = 256 // ancho
    w, h = ancho * 8 * escala, alto * 8 * escala
    img = [[PALETA[FONDO]] * w for _ in range(h)]
    for t in range(256):
        pb = PATRONES + banco * 0x800 + t * 8
        cb = COLORES + banco * 0x800 + t * 8
        pinta_tile(img, (t % ancho) * 8, (t // ancho) * 8,
                   v[pb:pb + 8], v[cb:cb + 8], escala)
    return w, h, img


ORG = 0x4000
LISTA_ATRIBUTOS = 0x66EF      # con la que se monta la tabla durante la partida
LISTA_DE_LA_BASE = 0x672C     # y la que la rehace en la escena de la base
ATRIBUTOS_DEL_POLO = 0x6746   # los cuatro que 0x5537 copia encima, en el polo
BANDERAS = 0x565C             # diez punteros a los flujos de bandera
POSTURAS = 0x4B84             # diez posturas del pinguino, cuatro patrones cada una
FOTOGRAMAS_FOCA = 0x78C1      # ocho punteros, uno por paso
ESCONDE_FOCA = 0x79BD
SIN_DUENO = 15                # los que no reclama nadie, en blanco


def colores_de_atributos(rom, desde, cuantos, lista=LISTA_ATRIBUTOS):
    """Los colores que la lista de atributos deja puestos, desde el numero N.

    Formato de la lista: (cuantos, y, x, patron, color) repetido y un cero al
    final, que es lo que ejecuta 0x66CA para componer los 128 bytes.
    """
    out, i, p = [], 0, lista
    while True:
        n = rom[p - ORG]
        if n == 0:
            return out
        p += 1
        entrada = rom[p - ORG:p - ORG + 4]
        p += 4
        for _ in range(n):
            if desde <= i < desde + cuantos:
                out.append(entrada[3] & 15)
            i += 1


def duenos(rom):
    """De que color sale cada sprite, y por culpa de quien. Los sesenta y cuatro.

    EL COLOR DE UN SPRITE NO ESTA EN SU DIBUJO: va en el cuarto byte de su
    entrada de atributo, asi que el mismo dibujo puede salir de un color o de
    otro segun quien lo use. Y HAY DOS REPARTOS, no uno, porque el juego monta
    la tabla dos veces: con la lista de 0x66EF durante la partida y con la de
    0x672C al llegar a la base. El mismo numero de sprite es una cosa en la
    pista y otra en la base, y ademas los PATRONES se recargan: la carga
    general (0x6759) llena los sprites 0 a 58, la bandera de la fase (0x55AD)
    reescribe el 58 y el 59, y el remate del polo (0x5534) el 60 al 63.

    Todo lo de aqui abajo esta contrastado contra la partida grabada del
    usuario: tools/omsx_sprites.tcl muestrea la tabla de atributos DE VERDAD
    cada 0,2 s de los diez minutos y deja en work/sprites_medidos.txt cada
    combinacion de (estado, patron, color) que sale en pantalla.
    """
    def w(a):
        return rom[a - ORG] | (rom[a + 1 - ORG] << 8)

    mapa = {}

    def pon(patron, color, quien):
        mapa.setdefault(patron & 0xFC, (color, quien))

    # El pinguino: los cuatro sprites de cada postura, atributos 10-13. Las
    # diez posturas gastan 32 sprites, del 0 al 27 y del 42 al 45.
    for color, base in zip(colores_de_atributos(rom, 10, 4), range(4)):
        for pose in range(10):
            pon(rom[POSTURAS + pose * 4 + base - ORG], color, "pinguino")
    # La foca: los fotogramas, con sus tres variantes, atributos 16-19. Los
    # tres primeros pasos son de dos sprites, y el mas lejano gasta el 0x7C
    # -que esta en blanco: de lejos no se le dibuja la cara- y el 0xE8.
    col_foca = colores_de_atributos(rom, 16, 4)
    ptr = [w(FOTOGRAMAS_FOCA + 2 * i) for i in range(8)] + [ESCONDE_FOCA]
    for i in range(8):
        p, fin = ptr[i], ptr[i + 1]
        cuantos = 2 if fin - p == 18 else 4
        for var in range(3):
            q = p + var * (fin - p) // 3
            for s in range(cuantos):
                pon(rom[q + s * 3 + 2 - ORG], col_foca[s], "foca")
    # EL PEZ SON OCHO DIBUJOS, no tres. Es facil leer mal el `ld bc,07a66h` de
    # 0x7644: 0x66, 0x64 y 0x92 son las X de los tres saltos, no patrones. El
    # patron sale de 0x7632 -0x90 mirando a un lado, 0x80 al otro- y de ahi
    # crece con el salto; 0x76CD le da la vuelta al bit 2 cada 16 fotogramas.
    # Medidos los ocho en la partida: 0x80-0x8C y 0x90-0x9C, todos en el color
    # del atributo 15.
    for patron in range(0x80, 0xA0, 4):
        pon(patron, colores_de_atributos(rom, 15, 1)[0], "pez")
    # La sombra: atributos 20-21.
    for patron in (0xA0, 0xA4, 0xAE):
        pon(patron, colores_de_atributos(rom, 20, 1)[0], "sombra")
    # LAS NUBES son tres dibujos, no cuatro. 0x77CA monta la nube con el patron
    # 0xE0 y el color 15 a mano, y por el camino 0x7810 y 0x7817 se lo cambian
    # a 0xDC y a 0xD8, que son mas grandes: es la perspectiva de acercarse. El
    # 0xD1 de 0x77F4 NO es un patron: se escribe en el byte de la Y para sacar
    # la nube por abajo cuando ha llegado arriba del todo.
    for patron in (0xE0, 0xDC, 0xD8):
        pon(patron, 0x0F, "nubes")
    # LAS PATAS AMARILLAS. Mientras el pinguino chapotea en el agujero se le
    # ven dos patas amarillas, y no hay un sprite nuevo para eso: 0x4F7F le
    # cambia el COLOR al atributo de la sombra, de azul oscuro a 0x0A, y
    # 0x4FC6 le va poniendo estos tres patrones. Al salir, 0x5012 le devuelve
    # el patron y el color de sombra.
    for patron in (0x70, 0x74, 0x78):
        pon(patron, 0x0A, "patas")
    # LA BANDERA DE LA BASE son tres sprites, atributos 4, 5 y 6. El 0xE4 es un
    # rectangulo blanco macizo que hace de fondo y sale de la carga general; el
    # 0xE8 y el 0xEC los descomprime 0x55AD encima, uno por fase, y sus dos
    # colores van detras del propio flujo comprimido. Aqui se pone la de la
    # primera fase, que es la que reconstruye descomprime.py; las diez se ven
    # con render_banderas.py.
    _, fin = descomprime(rom, w(BANDERAS), False, 0x5F40)   # la de la fase 1
    pon(0xE4, 0x0F, "bandera")
    pon(0xE8, col_foca[1], "foca lejos")      # en la pista es la foca de lejos
    pon(0xEC, rom[fin + 1 - ORG] & 15, "bandera")
    # LA ESCENA DE LA BASE tiene su propia lista de atributos (0x672C), y de
    # ella sale el UNICO sprite del pinguino que se gira y sonrie: el atributo
    # 7, con el patron 0xD0 en amarillo. Todo lo demas de ese pinguino -la
    # cara, los ojos, la boca roja y hasta la sombra azul de debajo- son
    # CASILLAS, no sprites: se ve volcando la tabla de nombres a t=126,6 de la
    # partida grabada, donde salen los ocho unicos atributos puestos.
    pon(0xD0, colores_de_atributos(rom, 7, 1, LISTA_DE_LA_BASE)[0], "pico")
    # EL REMATE DEL POLO SUR. 0x5531 descomprime cuatro sprites mas encima
    # (0x6B81 -> VRAM 0x1F80) y copia los dieciseis bytes de 0x6746 a los
    # atributos 7 a 10: dos en amarillo -el pico y la mancha de la barriga- y
    # dos en negro -el ala y el lomo-, que completan al pinguino inclinado que
    # dibujan las casillas.
    for i in range(4):
        entrada = rom[ATRIBUTOS_DEL_POLO + i * 4 - ORG:
                      ATRIBUTOS_DEL_POLO + i * 4 + 4 - ORG]
        pon(entrada[2], entrada[3] & 15, "polo")
    # EL ATRIBUTO 14 NO SE VE NUNCA. La lista se lo monta entero -patron 0xD4 y
    # color amarillo- pero con Y=0xE0, que es fuera de la pantalla, y NADIE se
    # la cambia: ni una instruccion escribe en 0xE088, la cadena de 0x4FE2 se
    # para en el atributo 13, y las demas copias empiezan mas arriba o mas
    # abajo. En los diez minutos de partida grabada no sale ni una vez.
    pon(0xD4, colores_de_atributos(rom, 14, 1)[0], "sin estrenar")
    return mapa


def hoja_de_sprites(v, rom=None, escala=3, ancho=8):
    """Los sprites son de 16x16 (R1 bit 1), o sea CUATRO cuartos de 8x8 cada uno.

    El VDP los guarda por columnas: el cuarto de arriba-izquierda, el de
    abajo-izquierda, el de arriba-derecha y el de abajo-derecha. Ponerlos en
    orden de lectura los parte por la mitad, y se nota a simple vista.

    Con la ROM delante, cada uno sale del color que le da su entrada de
    atributo; sin ella, todos en blanco. El fondo es gris a proposito: sobre
    el hielo blanco del juego no se verian los de fondo, que son blancos, y
    sobre el azul del borde no se veria la sombra, que es azul.
    """
    n = 0x800 // 32                       # 64 sprites de 16x16
    mapa = duenos(rom) if rom else {}
    alto = (n + ancho - 1) // ancho
    w, h = ancho * 16 * escala, alto * 16 * escala
    img = [[PALETA[14]] * w for _ in range(h)]
    # Aqui NO vale pinta_tile: esa rutina es para casillas, que llevan tinta y
    # fondo, y pintaria tambien los pixeles apagados. Un sprite no tiene fondo:
    # lo que no esta encendido es transparente y deja ver lo que hay detras.
    for s in range(n):
        base = SPR_PAT + s * 32
        color, _ = mapa.get(s * 4, (SIN_DUENO, None))
        rgb = PALETA[color]
        x0, y0 = (s % ancho) * 16, (s // ancho) * 16
        for y in range(16):
            izq, der = v[base + y], v[base + 16 + y]
            fila = ([(izq >> (7 - i)) & 1 for i in range(8)]
                    + [(der >> (7 - i)) & 1 for i in range(8)])
            for x, bit in enumerate(fila):
                if not bit:
                    continue
                for sy in range(escala):
                    for sx in range(escala):
                        img[(y0 + y) * escala + sy][(x0 + x) * escala + sx] = rgb
    return w, h, img


def main():
    if len(sys.argv) not in (3, 4):
        sys.exit(__doc__)
    with open(sys.argv[1], "rb") as f:
        v = f.read()
    salida = sys.argv[2]
    rom = None
    if len(sys.argv) == 4:
        with open(sys.argv[3], "rb") as f:
            rom = f.read()
    os.makedirs(salida, exist_ok=True)

    for banco in range(3):
        w, h, img = hoja_de_tiles(v, banco)
        nombre = "tiles-banco%d.png" % banco
        png(os.path.join(salida, nombre), w, h, img)
        print("  %-22s %dx%d   los 256 dibujos del banco %d" % (nombre, w, h, banco))

    w, h, img = hoja_de_sprites(v, rom)
    png(os.path.join(salida, "sprites.png"), w, h, img)
    if rom:
        from collections import Counter
        mapa = duenos(rom)
        cuenta = Counter(q for _, q in mapa.values())
        print("  %-22s %dx%d   los 64 sprites, cada uno de su color: %s"
              % ("sprites.png", w, h,
                 ", ".join("%s %d" % (q, n) for q, n in sorted(cuenta.items()))))
        # Ni uno en blanco por descarte: si alguno se queda sin dueno, se dice.
        # El blanco es un color de verdad en este juego -las nubes y el fondo
        # de la bandera son blancos-, asi que un sprite sin reclamar no se
        # distingue a simple vista de uno bien pintado.
        huerfanos = [s for s in range(64) if s * 4 not in mapa]
        if huerfanos:
            print("  AVISO: %d sprites sin dueno, pintados en blanco por "
                  "descarte: %s" % (len(huerfanos), huerfanos))
    else:
        print("  %-22s %dx%d   los 64 sprites de 16x16" % ("sprites.png", w, h))


if __name__ == "__main__":
    main()
