#!/usr/bin/env python3
"""Lleva las etiquetas y los comentarios de una version a otra.

    python3 tools/porta_comentarios.py <origen> <destino> [--escribe]

Los rangos de datos ya se portan por contenido y por orden; lo que falta para
que una version este comentada de verdad son las directivas L -el nombre de
cada rutina- y C -el comentario pegado a una instruccion-, que van ancladas a
una direccion concreta.

Se traducen con el mapa de tools/mapa_direcciones.py, que empareja las dos
compilaciones caminandolas a la vez y solo apunta parejas cuyas instrucciones
coinciden. O sea que una etiqueta solo se mueve si en el destino hay
EXACTAMENTE la misma instruccion en el sitio al que va.

Las que no se puedan traducir se quedan fuera y se cuentan. No se colocan a
ojo: una etiqueta puesta media instruccion mas alla no la caza el reensamblado
-los bytes no cambian- y convierte el listado en algo que parece comprobado y
no lo esta.

Tambien se traducen las direcciones que aparezcan DENTRO del texto, con el
mismo mapa, y las del cartucho que no se puedan comprobar se dejan como estan.
"""
import os
import re
import subprocess
import sys

ORG = 0x4000
HEX = re.compile(r"0x([0-9A-Fa-f]{4})\b")


def mapa(vo, vd):
    aqui = os.path.dirname(os.path.abspath(__file__))
    sal = subprocess.run(
        [sys.executable, os.path.join(aqui, "mapa_direcciones.py"), vo, vd],
        capture_output=True, text=True, check=True).stdout
    m = {}
    for ln in sal.splitlines():
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
    cod = mapa(vo, vd)
    ro, rd = rangos(vo), rangos(vd)
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

    def texto(s):
        def cambia(m):
            v = int(m.group(1), 16)
            if not (ORG <= v < ORG + 0x4000):
                return m.group(0)
            w = traduce(v)
            return m.group(0) if w is None else "0x%04X" % w
        return HEX.sub(cambia, s)

    salida, n_ok, perdidas = [], {"L": 0, "C": 0, "B": 0}, {"L": [], "C": [], "B": []}
    bloque_actual = None
    with open("src/%s/antarctic.notes" % vo, encoding="utf-8") as f:
        for ln in f.read().splitlines():
            m = re.match(r"^([LCB])\s+(0x[0-9A-Fa-f]+)\s*(.*)$", ln)
            if not m:
                continue
            tipo, dir_o, resto = m.group(1), int(m.group(2), 16), m.group(3)
            dir_d = traduce(dir_o)
            if dir_d is None:
                perdidas[tipo].append(dir_o)
                continue
            n_ok[tipo] += 1
            # Los bloques B van en varias lineas con la misma direccion: se
            # traducen igual, linea a linea.
            salida.append("%s 0x%04X %s" % (tipo, dir_d, texto(resto)))

    print("%s -> %s:  L %d portadas (%d sin sitio)   C %d (%d)   B %d lineas (%d)"
          % (vo, vd, n_ok["L"], len(perdidas["L"]), n_ok["C"], len(perdidas["C"]),
             n_ok["B"], len(perdidas["B"])))
    for t in ("L", "C", "B"):
        if perdidas[t]:
            print("  %s sin traducir: %s" % (
                t, ", ".join("0x%04X" % x for x in sorted(set(perdidas[t]))[:12])))

    if "--escribe" in sys.argv:
        path = "src/%s/antarctic.notes" % vd
        with open(path, encoding="utf-8") as f:
            viejo = f.read()
        # Se quitan las L, C y B que hubiera, y se ponen las portadas.
        base = [ln for ln in viejo.splitlines()
                if not re.match(r"^[LCB]\s+0x", ln)]
        with open(path, "w", encoding="utf-8") as f:
            f.write("\n".join(base) + "\n\n"
                    "# --- Etiquetas y comentarios portados de src/%s con\n"
                    "# tools/porta_comentarios.py: cada uno va donde el mapa de\n"
                    "# direcciones dice que esta LA MISMA INSTRUCCION, y las\n"
                    "# direcciones del texto estan traducidas con ese mismo mapa.\n\n"
                    % vo)
            f.write("\n".join(salida) + "\n")
        print("  escrito en %s" % path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
