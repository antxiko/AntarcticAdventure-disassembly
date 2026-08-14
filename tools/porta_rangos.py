#!/usr/bin/env python3
"""Busca en otra compilacion los rangos de datos ya identificados en esta.

    python3 tools/porta_rangos.py <rom_origen> <src_origen> <rom_destino>

Las tres compilaciones de este cartucho son el mismo programa ensamblado en
otro sitio: el codigo esta movido, pero los DATOS son en su mayoria los mismos
bytes. Asi que un bloque de graficos comprimidos, un flujo de sonido o una
tabla de nibbles se puede encontrar en la otra ROM buscando su contenido, y eso
ahorra volver a deducir de cero donde empieza y donde acaba cada cosa.

Lo que NO va a encontrar, y esta bien que no lo encuentre: todo lo que lleve
direcciones absolutas dentro. Las tablas de punteros cambian byte a byte
porque apuntan a sitios distintos, y esas hay que rehacerlas mirando quien las
lee. Aqui salen como NO ENCONTRADO, que es informacion util y no un fallo.

Y OJO con los que aparecen mas de una vez: un rango corto y repetitivo -relleno
o ceros- puede casar en varios sitios. Salen marcados como AMBIGUO y no se
deben usar sin mirarlos.
"""
import os
import re
import sys

ORG = 0x4000


def rangos_de_notas(path):
    """Los rangos D del fichero de notas: inicio, fin y nombre."""
    out = []
    with open(path, encoding="utf-8") as f:
        for ln in f:
            m = re.match(r"^D\s+(0x[0-9A-Fa-f]+)\s+(0x[0-9A-Fa-f]+)\s+(\S+)", ln)
            if m:
                out.append((int(m.group(1), 16), int(m.group(2), 16), m.group(3)))
    return sorted(out)


def main():
    if len(sys.argv) != 4:
        print(__doc__)
        return 1
    rom_o, src_o, rom_d = sys.argv[1], sys.argv[2], sys.argv[3]
    with open(rom_o, "rb") as f:
        origen = f.read()
    with open(rom_d, "rb") as f:
        destino = f.read()
    rangos = rangos_de_notas(os.path.join(src_o, "antarctic.notes"))

    hallados, ambiguos, perdidos = [], [], []
    for a, b, nombre in rangos:
        trozo = origen[a - ORG:b - ORG]
        if len(trozo) < 4:
            perdidos.append((a, b, nombre, "demasiado corto para buscarlo"))
            continue
        sitios = [m.start() for m in re.finditer(re.escape(trozo), destino)]
        if len(sitios) == 1:
            hallados.append((a, b, nombre, ORG + sitios[0]))
        elif len(sitios) > 1:
            ambiguos.append((a, b, nombre, [ORG + s for s in sitios]))
        else:
            perdidos.append((a, b, nombre, "no esta: lleva direcciones dentro"))

    print("=" * 72)
    print(" ENCONTRADOS DE UNA PIEZA: %d de %d" % (len(hallados), len(rangos)))
    print("=" * 72)
    for a, b, nombre, nuevo in hallados:
        print("  0x%04X..0x%04X  ->  0x%04X..0x%04X  %s"
              % (a, b, nuevo, nuevo + (b - a), nombre))
    if ambiguos:
        print()
        print("=" * 72)
        print(" AMBIGUOS, aparecen mas de una vez: %d" % len(ambiguos))
        print("=" * 72)
        for a, b, nombre, sitios in ambiguos:
            print("  0x%04X..0x%04X  %s  en %s"
                  % (a, b, nombre, ", ".join("0x%04X" % s for s in sitios[:6])))
    if perdidos:
        print()
        print("=" * 72)
        print(" HAY QUE REHACERLOS A MANO: %d" % len(perdidos))
        print("=" * 72)
        for a, b, nombre, por_que in perdidos:
            print("  0x%04X..0x%04X  %-28s %s" % (a, b, nombre, por_que))

    n = len(hallados)
    print()
    print("  %d de %d rangos localizados solos (%.0f %%), %d ambiguos, %d a mano"
          % (n, len(rangos), 100.0 * n / len(rangos), len(ambiguos), len(perdidos)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
