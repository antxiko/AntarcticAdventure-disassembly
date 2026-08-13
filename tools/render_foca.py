#!/usr/bin/env python3
"""Dibuja la foca que sale de los agujeros, fotograma a fotograma.

Quien la mueve es 0x7842, y su tabla de fotogramas esta en 0x78C1. El indice
es facil de leer mal, y conviene explicarlo porque el error es convincente:

    ld hl,(0e181h)     ; 0xE181 apunta al byte de ESTADO de la ficha
    ld a,(hl)          ; ...asi que A es EL PASO, no el tipo de obstaculo
    sub 00fh           ; paso 15 -> 0, que es el fotograma de esconderla
    jr nz,L_785B
L_785B:
    ld hl,078c1h
    add a,008h         ; A = paso - 15 + 8 = paso - 7
    add a,a
    call SUMA_A_HL     ; ocho entradas, para los pasos 7 a 14

Leido como si el indice fuera el tipo de obstaculo salen punteros imposibles
-0xE878, 0x9067- que se van fuera del cartucho. Con el paso salen ocho
punteros seguidos, y CIERRAN CLAVADOS: el ultimo fotograma acaba en 0x79BD,
que es justo el de esconderla, y ese acaba en 0x79C9, donde vuelve a haber
codigo.

CADA FOTOGRAMA LLEVA TRES VARIANTES, una por tipo de agujero, y las elige el
bit que 0x7657 encendio en 0xE183 segun el tipo (0x40, 0x20 o 0x80). Los tres
primeros pasos son de DOS sprites -18 bytes: 3 variantes x 2 x 3- y los cinco
restantes de CUATRO -36 bytes-.

LAS TRES VARIANTES LLEVAN EL MISMO DIBUJO Y SOLO CAMBIAN LA X: una sale por el
centro (X=0x78), otra se va hacia la derecha y otra hacia la izquierda, y cada
paso las separa un poco mas del centro. Del paso 10 al 14 pasa lo mismo con la
otra coordenada: los cuatro patrones son siempre C0, C4, C8 y CC, y lo que
cambia es la Y, que va bajando de 0x7B a 0xA1. O sea que la foca no se
deforma: se acerca.

Por eso este dibujo NO recoloca los fotogramas en una rejilla. Si se
normalizan las posiciones -que fue el primer intento- salen quince focas
identicas y no se ve nada, porque justo se ha tirado lo unico que cambia. Van
a su Y y su X de pantalla, los ocho pasos superpuestos, que es como se ve el
acercamiento de un vistazo.

DE CADA ENTRADA SE LEEN TRES BYTES -Y, X y patron- Y EL CUARTO SE SALTA, que
es justo el del color: 0x789D copia tres y hace un `inc de` para pasar por
encima del que hay. O sea que el color de la foca NO esta en el fotograma,
viene de antes: lo dejo puesto la lista de atributos de la partida (0x66EF), y
por eso hay que ir a buscarlo alli.

Y no es uno solo: el primero de sus cuatro sprites va en NEGRO y los otros
tres en ROJO OSCURO, que es como se le hace la cara oscura al bicho sin gastar
mas sprites.

Uso: render_foca.py <rom> <work/vram.bin> <directorio_salida>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from render_maps import PALETA, png                  # noqa: E402

ORG = 0x4000
TABLA = 0x78C1         # ocho punteros, uno por paso, del 7 al 14
ESCONDE = 0x79BD       # el fotograma que la saca de la pantalla
FIN = 0x79C9           # donde vuelve a haber codigo
PASOS = 8
VARIANTES = 3          # una por tipo de agujero
SPRITES = 0x1800       # los patrones de sprite en la VRAM
ATRIBUTOS = 0x66EF     # la lista con la que se monta la tabla de atributos
PRIMER_SPRITE = 16     # la foca ocupa los atributos 16 a 19
FUERA = 0xE0           # una Y de 0xE0 es "este sprite no se ve"
ESCALA = 2
PANTALLA = 256         # el ancho de la pantalla del MSX
Y_DESDE, Y_HASTA = 0x60, 0xC8   # la banda por la que se mueve


def w(rom, a):
    return rom[a - ORG] | (rom[a + 1 - ORG] << 8)


def colores_de_los_atributos(rom, lista, cuantos, desde):
    """Los colores que la lista de atributos deja puestos, empezando en `desde`.

    El formato de la lista es (cuantos, y, x, patron, color) repetido, y un
    cero al final; 0x66CA la ejecuta para componer los 128 bytes de la tabla.
    """
    out, i = [], 0
    p = lista
    while True:
        n = rom[p - ORG]
        if n == 0:
            break
        p += 1
        entrada = rom[p - ORG:p - ORG + 4]
        p += 4
        for _ in range(n):
            if desde <= i < desde + cuantos:
                out.append(entrada[3] & 15)
            i += 1
    return out


def sprite16(vram, patron):
    """Las 16 filas de un sprite de 16x16: dos mitades de 16 bytes."""
    base = SPRITES + (patron & 0xFC) * 8
    filas = []
    for y in range(16):
        izq, der = vram[base + y], vram[base + 16 + y]
        filas.append([(izq >> (7 - i)) & 1 for i in range(8)]
                     + [(der >> (7 - i)) & 1 for i in range(8)])
    return filas


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    with open(sys.argv[1], "rb") as f:
        rom = f.read()
    with open(sys.argv[2], "rb") as f:
        vram = f.read()
    salida = sys.argv[3]
    os.makedirs(salida, exist_ok=True)

    colores = colores_de_los_atributos(rom, ATRIBUTOS, 4, PRIMER_SPRITE)
    punteros = [w(rom, TABLA + 2 * i) for i in range(PASOS)] + [ESCONDE]
    for i in range(PASOS):
        largo = punteros[i + 1] - punteros[i]
        if largo not in (18, 36):
            sys.exit("  el fotograma del paso %d mide %d bytes, y tenia que "
                     "medir 18 o 36" % (i + 7, largo))
    if ESCONDE + 12 != FIN:
        sys.exit("  el fotograma de esconder no acaba donde empieza el codigo")

    banda = Y_HASTA - Y_DESDE
    ancho, alto = PANTALLA, VARIANTES * banda
    img = [[PALETA[15]] * ancho * ESCALA for _ in range(alto * ESCALA)]

    for var in range(VARIANTES):
        for i in range(PASOS):
            p, fin = punteros[i], punteros[i + 1]
            cuantos = 2 if fin - p == 18 else 4
            q = p + var * (fin - p) // VARIANTES
            entradas = [(rom[q + s * 3 - ORG], rom[q + s * 3 + 1 - ORG],
                         rom[q + s * 3 + 2 - ORG]) for s in range(cuantos)]
            # De atras hacia adelante: el atributo de numero MAS BAJO va
            # DELANTE, y aqui el primero es el negro. Pintados en orden, los
            # rojos lo taparian y el bicho saldria de un solo color.
            for s_, (y, x, patron) in reversed(list(enumerate(entradas))):
                if y == FUERA:
                    continue
                color = colores[s_]
                for fy, fila in enumerate(sprite16(vram, patron)):
                    for fx, bit in enumerate(fila):
                        if not bit:
                            continue
                        yy0 = var * banda + (y - Y_DESDE) + fy
                        xx0 = x + fx
                        if not (0 <= yy0 < alto and 0 <= xx0 < ancho):
                            continue
                        for sy in range(ESCALA):
                            for sx in range(ESCALA):
                                img[yy0 * ESCALA + sy][xx0 * ESCALA + sx] = PALETA[color]
            if var == 0:
                xs = " ".join("%02X" % e[1] for e in entradas)
                print("  paso %2d  fotograma 0x%04X  %d sprites  Y=%02X  X=%s"
                      % (i + 7, p, cuantos, entradas[0][0], xs))

    png(os.path.join(salida, "foca.png"), ancho * ESCALA, alto * ESCALA, img)
    print("  foca.png                los ocho pasos, en su sitio de pantalla,")
    print("                          y las tres salidas: centro, derecha e izquierda")
    print("  la cadena acaba en 0x%04X y el codigo empieza en 0x%04X: clavada"
          % (ESCONDE + 12, FIN))


if __name__ == "__main__":
    main()
