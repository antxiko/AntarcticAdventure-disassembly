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

Uso: render_tiles.py <work/vram.bin> <directorio_salida>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

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


def hoja_de_tiles(v, banco, escala=3, ancho=16):
    """Los 256 dibujos de un banco, puestos en rejilla."""
    alto = 256 // ancho
    w, h = ancho * 8 * escala, alto * 8 * escala
    img = [[PALETA[FONDO]] * w for _ in range(h)]
    for t in range(256):
        pb = PATRONES + banco * 0x800 + t * 8
        cb = COLORES + banco * 0x800 + t * 8
        pinta_tile(img, (t % ancho) * 8, (t // ancho) * 8,
                   v[pb:pb + 8], v[cb:cb + 8], escala)
    return w, h, img


def hoja_de_sprites(v, escala=3, ancho=8):
    """Los sprites son de 16x16 (R1 bit 1), o sea CUATRO cuartos de 8x8 cada uno.

    El VDP los guarda por columnas: el cuarto de arriba-izquierda, el de
    abajo-izquierda, el de arriba-derecha y el de abajo-derecha. Ponerlos en
    orden de lectura los parte por la mitad, y se nota a simple vista.
    """
    n = 0x800 // 32                       # 64 sprites de 16x16
    alto = (n + ancho - 1) // ancho
    w, h = ancho * 16 * escala, alto * 16 * escala
    img = [[PALETA[FONDO]] * w for _ in range(h)]
    blanco = bytes([0xF0]) * 8            # sin tabla de color: tinta 15
    for s in range(n):
        base = SPR_PAT + s * 32
        x0, y0 = (s % ancho) * 16, (s // ancho) * 16
        for cuarto in range(4):
            dx, dy = (cuarto // 2) * 8, (cuarto % 2) * 8
            pinta_tile(img, x0 + dx, y0 + dy,
                       v[base + cuarto * 8:base + cuarto * 8 + 8], blanco, escala)
    return w, h, img


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    with open(sys.argv[1], "rb") as f:
        v = f.read()
    salida = sys.argv[2]
    os.makedirs(salida, exist_ok=True)

    for banco in range(3):
        w, h, img = hoja_de_tiles(v, banco)
        nombre = "tiles-banco%d.png" % banco
        png(os.path.join(salida, nombre), w, h, img)
        print("  %-22s %dx%d   los 256 dibujos del banco %d" % (nombre, w, h, banco))

    w, h, img = hoja_de_sprites(v)
    png(os.path.join(salida, "sprites.png"), w, h, img)
    print("  %-22s %dx%d   los 64 sprites de 16x16" % ("sprites.png", w, h))


if __name__ == "__main__":
    main()
