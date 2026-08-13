#!/usr/bin/env python3
"""Dibuja las diez posturas del pinguino, tal y como se ven en la pista.

El pinguino son CUATRO sprites de 16x16 puestos en cuadro, o sea 32x32
pixeles. La tabla de 0x4B84 lleva diez posturas de cuatro bytes, que son los
cuatro dibujos que le tocan a cada uno, y 0x4BD5 los reparte de cuatro en
cuatro por los atributos:

    byte 0 -> 0xE078   arriba a la izquierda
    byte 1 -> 0xE07C   arriba a la derecha
    byte 2 -> 0xE080   abajo a la izquierda
    byte 3 -> 0xE084   abajo a la derecha

Y LOS CUATRO VAN EN NEGRO. El color no esta en la tabla de posturas ni lo
toca 0x4BD5: viene de la lista de atributos de la partida (0x66EF), que deja
los atributos 10 a 13 con el color 1. O sea que el pinguino es una silueta
negra, y lo que se ve blanco -la barriga, la cara- **no esta dibujado**: es el
hielo que se ve por los huecos del dibujo.

Por eso aqui el fondo es blanco y no el azul de los demas dibujos: sobre azul
saldria un pinguino con la barriga azul, que no es lo que se ve jugando. El
hielo es blanco porque la pista se rellena con la casilla 0x0F, y las dieciseis
primeras casillas de cada banco son cuadrados de color liso: la 0x0F es la del
color 15.

Uso: render_pinguino.py <rom> <work/vram.bin> <directorio_salida>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from render_maps import PALETA, png                  # noqa: E402

ORG = 0x4000
POSTURAS = 0x4B84      # diez posturas de cuatro patrones
CUANTAS = 10
ATRIBUTOS = 0x66EF     # la lista de atributos de la partida
PRIMER_SPRITE = 10     # el pinguino ocupa los atributos 10 a 13
SPRITES = 0x1800
HIELO = 15             # la casilla 0x0F de la pista, que es color liso 15
ESCALA = 3
CELDA = 40


def colores_de_los_atributos(rom, lista, cuantos, desde):
    """Los colores que deja puestos la lista de atributos, desde el numero N."""
    out, i, p = [], 0, lista
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
    if len(set(colores)) != 1:
        print("  aviso: los cuatro sprites no comparten color: %s" % colores)

    ancho, alto = CUANTAS * CELDA, CELDA
    img = [[PALETA[HIELO]] * ancho * ESCALA for _ in range(alto * ESCALA)]

    for pose in range(CUANTAS):
        patrones = rom[POSTURAS + pose * 4 - ORG:POSTURAS + pose * 4 + 4 - ORG]
        # De atras hacia adelante no hace falta aqui -los cuatro no se pisan,
        # van en cuadro- pero el orden es el mismo que en los atributos.
        for s, patron in enumerate(patrones):
            dx, dy = (s % 2) * 16, (s // 2) * 16
            for fy, fila in enumerate(sprite16(vram, patron)):
                for fx, bit in enumerate(fila):
                    if not bit:
                        continue
                    for sy in range(ESCALA):
                        for sx in range(ESCALA):
                            yy = (4 + dy + fy) * ESCALA + sy
                            xx = (pose * CELDA + 4 + dx + fx) * ESCALA + sx
                            if 0 <= yy < alto * ESCALA and 0 <= xx < ancho * ESCALA:
                                img[yy][xx] = PALETA[colores[s]]
        print("  postura %2d  patrones %s" % (pose, " ".join("%02X" % p for p in patrones)))

    png(os.path.join(salida, "pinguino.png"), ancho * ESCALA, alto * ESCALA, img)
    print("  pinguino.png            diez posturas, en el color %d sobre el hielo"
          % colores[0])


if __name__ == "__main__":
    main()
