#!/usr/bin/env python3
"""Prepara el .entries y el .nocode de una version a partir de otra ya hecha.

    python3 tools/arranca_version.py <rom_origen> <src_origen> \\
                                     <rom_destino> <src_destino>

Junta las dos herramientas de al lado:

  - localiza_entradas.py, que encuentra el gancho de H.TIMI y los destinos de
    las tablas de salto de la ROM destino, y de paso donde empieza y acaba cada
    tabla, que son zonas de NO codigo;
  - porta_rangos.py, que localiza en la ROM destino los rangos de datos ya
    identificados en la de origen, buscandolos por contenido.

Lo que sale NO es un desensamblado terminado, es el punto de partida: falta
todo lo que lleva direcciones absolutas dentro -las tablas de punteros- y todo
el codigo al que no llega nadie. Esos dos se anaden a mano, y el presupuesto de
bytes dice cuanto queda.

Se puede volver a ejecutar cuando la version de origen mejore, pero OJO: pisa
los ficheros. Solo se lanza sobre una carpeta vacia o con copia de seguridad.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import localiza_entradas as loc
import porta_rangos as por

ORG = 0x4000


def tablas_y_destinos(d):
    """Las tablas de salto de la ROM: (direccion, fin, n_entradas, call) y el
    conjunto de destinos."""
    import re
    sumas = loc.busca_suma_a_hl(d, ORG)
    desps = loc.busca_despachador(d, ORG, sumas)
    tablas, destinos = [], set()
    for dp in desps:
        pat = bytes([0xCD, dp & 0xFF, dp >> 8])
        for m in re.finditer(re.escape(pat), d):
            call_a = ORG + m.start()
            tab, ds = loc.tabla_detras_del_call(d, ORG, call_a)
            if ds and all(ORG <= x < ORG + len(d) for x in ds):
                tablas.append((tab, tab + 2 * len(ds), len(ds), call_a))
                destinos.update(ds)
    return sorted(tablas), sorted(destinos), sumas, desps


def main():
    if len(sys.argv) != 5:
        print(__doc__)
        return 1
    rom_o, src_o, rom_d, src_d = sys.argv[1:5]
    with open(rom_d, "rb") as f:
        d = f.read()
    os.makedirs(src_d, exist_ok=True)

    tablas, destinos, sumas, desps = tablas_y_destinos(d)
    init = loc.palabra(d, ORG, ORG + 2)
    htimi = loc.busca_htimi(d, ORG)

    # ---------------------------------------------------------------- entries
    ent = os.path.join(src_d, "antarctic.entries")
    with open(ent, "w", encoding="utf-8") as f:
        f.write("# Puntos de entrada. Arrancado con tools/arranca_version.py y\n"
                "# COMPLETADO A MANO: lo de aqui es lo que se deduce solo.\n#\n"
                "# El unico que declara el cartucho es INIT: la BIOS lee la\n"
                "# cabecera \"AB\" y lo llama tras inicializar la maquina.\n")
        f.write("0x%04X   # INIT, de la cabecera del cartucho\n" % init)
        for h in htimi:
            f.write("0x%04X   # H.TIMI: la rutina de interrupcion. La engancha INIT\n"
                    "         # y la llama la BIOS 50 o 60 veces por segundo, asi que\n"
                    "         # ningun trazador estatico llega sin esto.\n" % h)
        f.write("\n# --- Destinos de las tablas de salto del despachador de 0x%04X.\n"
                "# La tabla va INCRUSTADA detras del CALL, asi que el trazador no\n"
                "# puede seguirla. Cada una cierra clavada contra su primer destino,\n"
                "# y eso valida el tamano sin suponer nada:\n"
                % (desps[0] if desps else 0))
        for tab, fin, n, call_a in tablas:
            f.write("#   CALL 0x%04X -> tabla 0x%04X, %2d entradas\n"
                    % (call_a, tab, n))
        for a in destinos:
            f.write("0x%04X   # destino de tabla de saltos\n" % a)

    # ----------------------------------------------------------------- nocode
    rangos = []
    rangos.append((ORG, ORG + 0x10, "cabecera_del_cartucho",
                   'La cabecera: "AB", INIT y los tres vectores a cero'))
    for tab, fin, n, call_a in tablas:
        rangos.append((tab, fin, "tabla_de_saltos_%04X" % tab,
                       "Los %d destinos del CALL de 0x%04X. Cierra clavada "
                       "contra su primer destino" % (n, call_a)))

    with open(os.path.join(src_o, "antarctic.notes"), encoding="utf-8") as f:
        pass
    portados, perdidos = [], []
    with open(rom_o, "rb") as f:
        origen = f.read()
    import re
    for a, b, nombre, desc in por.rangos_de_notas(
            os.path.join(src_o, "antarctic.notes")):
        trozo = origen[a - ORG:b - ORG]
        if len(trozo) < 4:
            perdidos.append((a, b, nombre, desc))
            continue
        sitios = [m.start() for m in re.finditer(re.escape(trozo), d)]
        if len(sitios) == 1:
            nuevo = ORG + sitios[0]
            portados.append((nuevo, nuevo + (b - a), nombre, desc))
        else:
            perdidos.append((a, b, nombre, desc))

    rangos.extend(portados)
    # La cabecera se anade a mano y ademas se porta: un rango repetido no es un
    # solape de verdad, asi que se queda con el primero.
    vistos, unicos = set(), []
    for r in sorted(rangos):
        if (r[0], r[1]) not in vistos:
            vistos.add((r[0], r[1]))
            unicos.append(r)
    rangos = unicos

    # Los solapes son un error de partida y hay que verlos, no taparlos.
    solapes = [(rangos[i], rangos[i + 1]) for i in range(len(rangos) - 1)
               if rangos[i][1] > rangos[i + 1][0]]

    noc = os.path.join(src_d, "antarctic.nocode")
    with open(noc, "w", encoding="utf-8") as f:
        f.write("# Zonas que NO son codigo, para que el trazador no se meta en\n"
                "# ellas. Arrancado con tools/arranca_version.py: las tablas de\n"
                "# salto salen de su propia regla de cierre, y los rangos de datos\n"
                "# de buscar en esta ROM el contenido de los ya identificados en\n"
                "# %s.\n#\n"
                "# FALTA todo lo que lleva direcciones absolutas dentro, que no se\n"
                "# puede portar por contenido. El presupuesto de bytes dice cuanto.\n#\n"
                "# Convenio: [inicio, fin), el extremo derecho NO entra.\n\n"
                % src_o)
        for a, b, nombre, desc in rangos:
            f.write("0x%04X 0x%04X   # %s\n" % (a, b, nombre))

    # ------------------------------------------------------------------ notes
    # Las directivas D son las que cuentan para el presupuesto de bytes: un
    # rango sin nombre y sin explicacion no explica nada.
    nts = os.path.join(src_d, "antarctic.notes")
    with open(nts, "w", encoding="utf-8") as f:
        f.write("# Anotaciones de Antarctic Adventure (Konami, 1984, MSX1, RC-701).\n"
                "#\n"
                "# Arrancadas con tools/arranca_version.py desde %s. Los rangos de\n"
                "# datos se han localizado buscando su contenido en esta ROM, asi\n"
                "# que el sitio es de aqui y esta comprobado; pero LAS\n"
                "# DIRECCIONES QUE APARECEN DENTRO DE LAS EXPLICACIONES SON\n"
                "# TODAVIA LAS DE %s y hay que traducirlas al repasar cada una.\n"
                "#\n"
                "# Falta ademas todo lo que lleva direcciones absolutas dentro -las\n"
                "# tablas de punteros-, que no se puede portar por contenido.\n\n"
                % (src_o, src_o))
        for a, b, nombre, desc in rangos:
            f.write("D 0x%04X 0x%04X %s %s\n" % (a, b, nombre, desc))

    print("%s: %d puntos de entrada (%d destinos de tabla)"
          % (ent, 1 + len(htimi) + len(destinos), len(destinos)))
    print("%s: %d rangos (%d tablas de salto + %d datos portados)"
          % (noc, len(rangos), len(tablas), len(portados)))
    print("   sin portar, hay que hacerlos a mano: %d" % len(perdidos))
    if solapes:
        print("   OJO, %d SOLAPES:" % len(solapes))
        for x, y in solapes:
            print("      0x%04X..0x%04X %s  con  0x%04X..0x%04X %s"
                  % (x[0], x[1], x[2], y[0], y[1], y[2]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
