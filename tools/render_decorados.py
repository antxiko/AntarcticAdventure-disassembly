#!/usr/bin/env python3
"""Dibuja los decorados, ejecutando el mismo interprete que ejecuta el juego.

En 0x7241 hay un arbol de punteros de dos niveles: cuatro grupos, y cada grupo
con cuatro bloques, dieciseis en total, que embaldosan 0x732D-0x7518 sin dejar
hueco. Cada bloque es una lista de casillas que se escriben directamente en la
tabla de nombres, o sea un trozo de pantalla ya montado.

El formato sale de leer la rutina de 0x4533, que es a quien se los pasa el
interprete de 0x51C0:

    primer byte   el nibble alto es la columna, y los dos bits bajos eligen
                  pagina de la tabla de nombres: 0x78..0x7B -> 0x3800..0x3B00
    luego         un byte de desplazamiento por fila, y detras los numeros de
                  casilla, uno por columna
    0x00          fin del bloque
    >= 0xE0       no es una casilla: es el desplazamiento de la fila siguiente
                  (la rutina salta a 0x4541 SIN avanzar el puntero)

Cada fila avanza 0x20 posiciones, que son las 32 columnas de la pantalla.

Uso: render_decorados.py <rom> <work/vram.bin> <directorio_salida>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from render_maps import png                          # noqa: E402
from render_tiles import COLORES, PATRONES, FONDO, PALETA, pinta_tile   # noqa: E402

ORG = 0x4000
RAIZ = 0x7241          # la tabla de cuatro punteros del primer nivel
NOMBRES = 0x3800


def w(rom, a):
    return rom[a - ORG] | (rom[a + 1 - ORG] << 8)


def bloques(rom):
    """Los dieciseis, en el orden en que los tiene el juego."""
    out = []
    for g in range(4):
        grupo = w(rom, RAIZ + 2 * g)
        for b in range(4):
            out.append((g, b, w(rom, grupo + 2 * b)))
    return out


def ejecuta(rom, p, nombres):
    """El interprete de 0x4533, paso por paso. Devuelve cuantas casillas pone."""
    a = rom[p - ORG]
    if a == 0:
        return 0
    c = a & 0xF0
    d = (a & 0x03) + 0x78
    p += 1
    puestas = 0
    while True:
        b = rom[p - ORG]
        p += 1
        t = c + 0x20                        # una fila mas abajo
        c = t & 0xFF
        if t > 0xFF:
            d = (d + 1) & 0xFF
        e = (c + b - 0xE0) & 0xFF
        de = ((d << 8) | e) & 0x3FFF
        while True:
            a = rom[p - ORG]
            if a == 0:
                return puestas
            if a >= 0xE0:                   # salto de fila, sin avanzar
                break
            p += 1
            if NOMBRES <= de < NOMBRES + 0x300:
                nombres[de - NOMBRES] = a
                puestas += 1
            de += 1


def dibuja(vram, nombres, escala=2):
    """La pantalla de 32x24 con los tres bancos de tiles."""
    w_, h_ = 32 * 8 * escala, 24 * 8 * escala
    img = [[PALETA[FONDO]] * w_ for _ in range(h_)]
    for fy in range(24):
        banco = fy // 8
        for fx in range(32):
            t = nombres[fy * 32 + fx]
            pb = PATRONES + banco * 0x800 + t * 8
            cb = COLORES + banco * 0x800 + t * 8
            pinta_tile(img, fx * 8, fy * 8, vram[pb:pb + 8], vram[cb:cb + 8], escala)
    return w_, h_, img


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    with open(sys.argv[1], "rb") as f:
        rom = f.read()
    with open(sys.argv[2], "rb") as f:
        vram = f.read()
    salida = sys.argv[3]
    os.makedirs(salida, exist_ok=True)

    todos = bytearray(0x300)
    for g, b, p in bloques(rom):
        nombres = bytearray(0x300)
        n = ejecuta(rom, p, nombres)
        ejecuta(rom, p, todos)
        w_, h_, img = dibuja(vram, nombres)
        nombre = "decorado-%d-%d.png" % (g + 1, b + 1)
        png(os.path.join(salida, nombre), w_, h_, img)
        print("  %-22s grupo %d bloque %d, de 0x%04X, %3d casillas"
              % (nombre, g + 1, b + 1, p, n))

    w_, h_, img = dibuja(vram, todos)
    png(os.path.join(salida, "decorados-todos.png"), w_, h_, img)
    print("  %-22s los dieciseis a la vez" % "decorados-todos.png")


if __name__ == "__main__":
    main()
