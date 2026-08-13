#!/usr/bin/env python3
"""Dibuja los trozos de pista, pasandolos por el mismo interprete que el juego.

Entre 0x6BE9 y 0x7241 hay 92 trozos escritos en el formato de bloques de
0x4533, el mismo que los decorados. Pero no son pantallas: cada uno pone entre
una y seis casillas, o sea que son INCREMENTOS. El juego los consume en cadena,
uno por paso, y de ahi sale la sensacion de que el obstaculo se acerca.

Quien los arranca es la tabla de obstaculos de 0x52CB: sus siete punteros de
dibujo caen todos aqui dentro, y a partir de cada uno la ficha del obstaculo va
avanzando sola por la cadena (0x5201).

Esta herramienta hace las dos cosas:
  - acumula los trozos de un obstaculo, que es como se ve montado entero
  - y los cuenta, para comprobar que la cadena de cada uno acaba donde debe

Uso: render_pista.py <rom> <work/vram.bin> <directorio_salida>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from render_decorados import dibuja, ejecuta         # noqa: E402
from render_maps import png                          # noqa: E402

ORG = 0x4000
OBSTACULOS = 0x52CB      # siete filas de seis bytes
FILA = 6
PASOS = 15               # los que da una ficha antes de quedar libre (0x51FB)


def w(rom, a):
    return rom[a - ORG] | (rom[a + 1 - ORG] << 8)


def cadena(rom, p, nombres, pasos=PASOS):
    """Ejecuta y encadena los trozos, como hace la ficha del obstaculo.

    El interprete devuelve donde se quedo, y ahi empieza el trozo siguiente:
    es exactamente lo que hace 0x5201 guardando el puntero de vuelta en la
    ficha.

    OJO: los siete punteros de 0x52CB apuntan a un 0x00, o sea a un bloque
    VACIO. No es un error de lectura: el primer paso de un obstaculo no dibuja
    nada porque todavia esta detras del horizonte, y dos de los siete llevan
    dos pasos vacios. Por eso aqui no se corta al primer bloque que no pone
    casillas.
    """
    puestas = 0
    for _ in range(pasos):
        n, p = ejecuta_y_avanza(rom, p, nombres)
        puestas += n
    return puestas, p


def ejecuta_y_avanza(rom, p, nombres):
    """Como ejecuta(), pero devuelve tambien por donde se quedo el puntero."""
    ini = p
    n = ejecuta(rom, p, nombres)
    # El interprete se para en el 0x00 que cierra el bloque; para encadenar hay
    # que recorrerlo otra vez contando bytes, que es lo que hace el juego con el
    # puntero que lleva la ficha.
    a = rom[p - ORG]
    if a == 0:
        return 0, p + 1
    p += 1
    while True:
        b = rom[p - ORG]
        p += 1
        while True:
            c = rom[p - ORG]
            if c == 0:
                return n, p + 1
            if c >= 0xE0:
                break
            p += 1
    return n, p


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
    for tipo in range(7):
        p = w(rom, OBSTACULOS + tipo * FILA)
        nombres = bytearray(0x300)
        n, fin = cadena(rom, p, nombres)
        cadena(rom, p, todos)
        w_, h_, img = dibuja(vram, nombres)
        nombre = "obstaculo-%d.png" % tipo
        png(os.path.join(salida, nombre), w_, h_, img)
        print("  %-22s tipo %d, de 0x%04X a 0x%04X, %3d casillas"
              % (nombre, tipo, p, fin, n))

    w_, h_, img = dibuja(vram, todos)
    png(os.path.join(salida, "pista.png"), w_, h_, img)
    print("  %-22s los siete montados encima del mismo hielo" % "pista.png")


if __name__ == "__main__":
    main()
