#!/usr/bin/env python3
"""Empareja los huecos sin explicar de una version con los rangos de otra.

    python3 tools/alinea_huecos.py <src_origen> <work_destino> <src_destino> \\
                                   [nombre_a_saltar ...]

Lo que queda sin explicar despues de portar los datos por contenido son las
tablas de punteros: como llevan direcciones absolutas dentro, sus bytes no
coinciden entre compilaciones y hay que localizarlas de otra manera.

La otra manera es el ORDEN. El ensamblador respeta la secuencia de los datos,
asi que el n-esimo bloque sin explicar de esta version es el n-esimo bloque sin
portar de la otra. La alineacion se hace agrupando primero los rangos de origen
que van pegados -porque en el destino aparecen como un solo hueco- y despues
emparejando grupo con hueco, en orden.

Y NO SE FIA DE ESO A CIEGAS. Cada pareja se comprueba por tamano: si el grupo
de origen y el hueco de destino no miden lo mismo, sale marcado, porque
entonces o el bloque cambia de verdad entre versiones -que pasa, por ejemplo,
con la fuente- o la alineacion se ha descolocado y todo lo que venga detras
esta mal. Sin esa comprobacion, esto seria una forma elegante de inventarse un
listado que ademas reensambla.

Los limites que se escriben son SIEMPRE los del hueco de destino, que estan
acotados por codigo trazado a los dos lados. Los nombres y las explicaciones
vienen de la version de origen, y sus direcciones interiores siguen siendo las
de alli hasta que se repasen a mano.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import porta_rangos as por
import quien_apunta as qa

ORG = 0x4000


def tablas_de_salto(d):
    """Las tablas incrustadas detras de los CALL al despachador. Se excluyen
    porque el destino ya las tiene puestas: se localizan solas con su regla de
    cierre, sin necesidad de alinear nada."""
    import re
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import localiza_entradas as loc
    fuera = set()
    for dp in loc.busca_despachador(d, ORG, loc.busca_suma_a_hl(d, ORG)):
        pat = bytes([0xCD, dp & 0xFF, dp >> 8])
        for m in re.finditer(re.escape(pat), d):
            tab, ds = loc.tabla_detras_del_call(d, ORG, ORG + m.start())
            if ds:
                fuera.add((tab, tab + 2 * len(ds)))
    return fuera


def sin_portar(rom_o, src_o, rom_d, saltar=()):
    """Los rangos de origen que NO se encuentran por contenido en el destino."""
    import re
    with open(rom_o, "rb") as f:
        origen = f.read()
    with open(rom_d, "rb") as f:
        destino = f.read()
    fuera = tablas_de_salto(origen)
    out = []
    for a, b, nombre, desc in por.rangos_de_notas(
            os.path.join(src_o, "antarctic.notes")):
        if (a, b) in fuera or nombre in saltar:
            continue
        trozo = origen[a - ORG:b - ORG]
        if len(trozo) >= 4 and len(list(re.finditer(re.escape(trozo), destino))) == 1:
            continue
        out.append((a, b, nombre, desc))
    return sorted(out)


def agrupa(rangos):
    """Los que van pegados salen como un solo hueco en la otra version."""
    grupos = []
    for r in rangos:
        if grupos and grupos[-1][-1][1] == r[0]:
            grupos[-1].append(r)
        else:
            grupos.append([r])
    return grupos


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        return 1
    src_o, work_d, src_d = sys.argv[1], sys.argv[2], sys.argv[3]
    saltar = set(sys.argv[4:])
    v_o = os.path.basename(src_o.rstrip("/"))
    v_d = os.path.basename(src_d.rstrip("/"))
    rom_o, rom_d = "antarctic-%s.rom" % v_o, "antarctic-%s.rom" % v_d

    traza = json.load(open(os.path.join(work_d, "antarctic.trace.json")))
    huecos = qa.huecos(traza["blocks"],
                       qa.rangos_d(os.path.join(src_d, "antarctic.notes")))
    grupos = agrupa(sin_portar(rom_o, src_o, rom_d, saltar))

    print("%s: %d grupos sin portar    %s: %d huecos"
          % (v_o, len(grupos), v_d, len(huecos)))
    if len(grupos) != len(huecos):
        print("NO CUADRAN, no se puede alinear en orden. Hay que mirarlo a mano.")
        for g in grupos:
            print("   grupo 0x%04X..0x%04X (%d B): %s"
                  % (g[0][0], g[-1][1], g[-1][1] - g[0][0],
                     ", ".join(x[2] for x in g)))
        for a, b in huecos:
            print("   hueco 0x%04X..0x%04X (%d B)" % (a, b, b - a))
        return 2

    lineas, avisos = [], []
    for g, (ha, hb) in zip(grupos, huecos):
        tam_o = g[-1][1] - g[0][0]
        tam_d = hb - ha
        if tam_o != tam_d:
            avisos.append((g, ha, hb, tam_o, tam_d))
        # Se reparte el hueco con las proporciones del origen; si el tamano
        # coincide es exacto, y si no, el ultimo se come la diferencia.
        pos = ha
        for i, (a, b, nombre, desc) in enumerate(g):
            fin = hb if i == len(g) - 1 else pos + (b - a)
            lineas.append((pos, fin, nombre, desc))
            pos = fin

    for a, b, nombre, desc in lineas:
        print("D 0x%04X 0x%04X %s %s" % (a, b, nombre, desc))

    if avisos:
        print()
        print("# AVISO: %d grupos no miden lo mismo en las dos versiones."
              % len(avisos))
        print("# O el bloque cambia de verdad, o la alineacion se ha descolocado.")
        for g, ha, hb, to, td in avisos:
            print("#   %s: %d bytes en %s y %d en %s (0x%04X..0x%04X)"
                  % (", ".join(x[2] for x in g), to, v_o, td, v_d, ha, hb))
    return 0


if __name__ == "__main__":
    sys.exit(main())
