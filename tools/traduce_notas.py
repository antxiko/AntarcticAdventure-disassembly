#!/usr/bin/env python3
"""Traduce a otra version las direcciones que aparecen dentro de las notas.

    python3 tools/traduce_notas.py <version_origen> <version_destino> [--escribe]

Cuando se arranca una version copiando los nombres y las explicaciones de otra,
el sitio de cada bloque es correcto -se ha localizado en esta ROM- pero las
direcciones que aparecen DENTRO del texto siguen siendo las de la version de
origen. Un comentario que diga "0x5308 la indexa" es falso aqui aunque el rango
este bien puesto, y eso es peor que no decir nada.

Esta herramienta las cambia usando dos mapas:

  - el del CODIGO, que sale de caminar las dos versiones a la vez
    (mapa_direcciones.py) y solo empareja instrucciones que coinciden;
  - el de los DATOS, que sale de los propios rangos D: los que se llaman igual
    en las dos se emparejan, y dentro de cada uno se traduce por
    desplazamiento.

Lo que no cae en ninguno de los dos NO SE TOCA y se marca, porque traducir a
ojo una direccion que no se ha podido comprobar es exactamente la forma de
colar un dato falso en un sitio que parece verificado.

Sin --escribe solo enseña el resumen y las que no se pueden traducir.
"""
import os
import re
import subprocess
import sys

ORG = 0x4000
HEX = re.compile(r"0x([0-9A-Fa-f]{4})\b")


def mapa_de_codigo(vo, vd):
    aqui = os.path.dirname(os.path.abspath(__file__))
    salida = subprocess.run(
        [sys.executable, os.path.join(aqui, "mapa_direcciones.py"), vo, vd],
        capture_output=True, text=True, check=True).stdout
    m = {}
    for ln in salida.splitlines():
        if ln.startswith("0x"):
            a, b = ln.split()
            m[int(a, 16)] = int(b, 16)
    return m


def rangos(v):
    out = {}
    with open("src/%s/antarctic.notes" % v, encoding="utf-8") as f:
        for ln in f:
            m = re.match(r"^D\s+(0x[0-9A-Fa-f]+)\s+(0x[0-9A-Fa-f]+)\s+(\S+)", ln)
            if m:
                out[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
    return out


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 1
    vo, vd = sys.argv[1], sys.argv[2]
    cod = mapa_de_codigo(vo, vd)
    ro, rd = rangos(vo), rangos(vd)
    # Los rangos que se llaman igual en las dos: dentro se traduce por
    # desplazamiento, y solo si el que sale cae dentro del rango de destino.
    datos = [(ro[n], rd[n]) for n in ro if n in rd]

    def traduce(v):
        if v in cod:
            return cod[v]
        for (a, b), (c, d) in datos:
            if a <= v < b:
                w = c + (v - a)
                if c <= w < d:
                    return w
        return None

    path = "src/%s/antarctic.notes" % vd
    with open(path, encoding="utf-8") as f:
        lineas = f.read().splitlines()

    n_ok = n_no = 0
    sin_traducir = {}
    fuera = []
    for ln in lineas:
        if not ln.startswith(("D ", "C ", "L ", "B ")):
            fuera.append(ln)
            continue
        # En las directivas, las direcciones de las DOS primeras columnas son ya
        # de esta version: solo se traduce lo que va en el texto.
        partes = ln.split(None, 3 if ln.startswith("D ") else 2)
        cabeza = " ".join(partes[:-1])
        cola = partes[-1] if len(partes) > 1 else ""

        def cambia(m):
            nonlocal n_ok, n_no
            v = int(m.group(1), 16)
            # Solo se traducen direcciones del cartucho. Las de la RAM del MSX
            # (0xE0xx), las de la VRAM y los numeros que casualmente parecen una
            # direccion son iguales en las tres versiones y no se tocan.
            if not (ORG <= v < ORG + 0x4000):
                return m.group(0)
            w = traduce(v)
            if w is None:
                n_no += 1
                sin_traducir[v] = sin_traducir.get(v, 0) + 1
                return m.group(0)
            n_ok += 1
            return "0x%04X" % w

        fuera.append((cabeza + " " + HEX.sub(cambia, cola)).rstrip())

    print("%s -> %s: %d direcciones traducidas, %d sin traducir (%d distintas)"
          % (vo, vd, n_ok, n_no, len(sin_traducir)))
    if sin_traducir:
        print("  sin traducir, por veces que salen:")
        for v, n in sorted(sin_traducir.items(), key=lambda x: -x[1])[:20]:
            print("    0x%04X  x%d" % (v, n))
    if "--escribe" in sys.argv:
        with open(path, "w", encoding="utf-8") as f:
            f.write("\n".join(fuera) + "\n")
        print("  escrito en %s" % path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
