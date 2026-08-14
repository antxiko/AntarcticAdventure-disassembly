#!/usr/bin/env python3
"""Encuentra solo los puntos de entrada que un trazador estatico no puede deducir.

    python3 tools/localiza_entradas.py <rom> [org]

En este cartucho hay dos cosas que el flujo no alcanza por si mismo:

  - LA RUTINA DE INTERRUPCION, que no la llama nadie del programa: INIT la
    engancha en H.TIMI (0xFD9A) y a partir de ahi la llama la BIOS cincuenta o
    sesenta veces por segundo.
  - LOS DESTINOS DE LAS TABLAS DE SALTO, porque la tabla va INCRUSTADA detras
    del CALL al despachador. El despachador hace POP HL para quedarse con la
    direccion de retorno -que es la tabla-, le suma el indice y salta. Para un
    trazador, eso es un `call` a una rutina que nunca vuelve.

Las tres compilaciones del cartucho usan el mismo esquema con el codigo movido
de sitio, asi que en vez de ir a mano version por version se buscan los
patrones:

    HL += A            85 6F D0 24 C9     add a,l / ld l,a / ret nc / inc h / ret
    el despachador     87 E1 CD .. .. 5E 23 56 EB E9
                       add a,a / pop hl / call <HL+=A> / ld e,(hl) / inc hl /
                       ld d,(hl) / ex de,hl / jp (hl)
    el gancho H.TIMI   21 .. .. 22 9B FD  ld hl,nn / ld (0FD9Bh),hl

EL TAMANO DE CADA TABLA NO SE SUPONE: se deduce, y de paso se valida. Las
entradas se van leyendo mientras la posicion siga por debajo del menor destino
visto; la tabla termina cuando la ultima palabra acaba EXACTAMENTE donde
empieza su primer destino. Si no cierra clavada, esta herramienta lo dice en
vez de callarse, porque entonces o el patron no es el que creemos o ahi hay
otra cosa.

Lo que NO saca: el codigo al que no llega nadie porque ninguna instruccion lo
nombra (rutinas sin estrenar y trozos sueltos). Eso hay que encontrarlo
leyendo, y va a mano en el .entries.
"""
import re
import sys

SUMA_A_HL = bytes([0x85, 0x6F, 0xD0, 0x24, 0xC9])
HTIMI = bytes([0x22, 0x9B, 0xFD])          # ld (0FD9Bh),hl


def palabra(d, org, a):
    i = a - org
    return d[i] | d[i + 1] << 8


def busca_suma_a_hl(d, org):
    return [org + m.start() for m in re.finditer(re.escape(SUMA_A_HL), d)]


def busca_despachador(d, org, sumas):
    """add a,a / pop hl / call <suma> / ld e,(hl) / inc hl / ld d,(hl) /
    ex de,hl / jp (hl)"""
    out = []
    for s in sumas:
        pat = bytes([0x87, 0xE1, 0xCD, s & 0xFF, s >> 8,
                     0x5E, 0x23, 0x56, 0xEB, 0xE9])
        for m in re.finditer(re.escape(pat), d):
            out.append(org + m.start())
    return out


def busca_htimi(d, org):
    """El `ld hl,nn` que va justo delante del `ld (0FD9Bh),hl`."""
    out = []
    for m in re.finditer(re.escape(HTIMI), d):
        i = m.start()
        if i >= 3 and d[i - 3] == 0x21:
            out.append(d[i - 2] | d[i - 1] << 8)
    return out


def tabla_detras_del_call(d, org, call_a):
    """Lee la tabla incrustada detras de un `call <despachador>`.

    Devuelve (direccion_de_la_tabla, [destinos]) o (dir, None) si no cierra
    clavada, que es la senal de que ahi no hay una tabla.
    """
    tab = call_a + 3
    pos = tab
    destinos = []
    fin = len(d) + org
    while pos < fin - 1:
        destinos.append(palabra(d, org, pos))
        pos += 2
        menor = min(destinos)
        if pos == menor:
            return tab, destinos
        if pos > menor:
            return tab, None
        if len(destinos) > 64:
            return tab, None
    return tab, None


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 1
    org = int(sys.argv[2], 0) if len(sys.argv) > 2 else 0x4000
    with open(sys.argv[1], "rb") as f:
        d = f.read()
    fin = org + len(d)

    print("# --- Generado por tools/localiza_entradas.py, revisar antes de usar.")
    init = palabra(d, org, org + 2)
    print("0x%04X   # INIT, declarado en la cabecera del cartucho" % init)

    for h in busca_htimi(d, org):
        print("0x%04X   # H.TIMI: la rutina de interrupcion, enganchada por INIT" % h)

    sumas = busca_suma_a_hl(d, org)
    desps = busca_despachador(d, org, sumas)
    if not desps:
        print("# NO SE ENCUENTRA EL DESPACHADOR: revisar a mano", file=sys.stderr)
        return 2
    print("# HL+=A en %s; despachador en %s"
          % (", ".join("0x%04X" % s for s in sumas),
             ", ".join("0x%04X" % x for x in desps)))

    todos = set()
    for dp in desps:
        pat = bytes([0xCD, dp & 0xFF, dp >> 8])
        for m in re.finditer(re.escape(pat), d):
            call_a = org + m.start()
            tab, destinos = tabla_detras_del_call(d, org, call_a)
            if destinos is None:
                print("# 0x%04X: call al despachador cuya tabla NO cierra clavada"
                      % call_a, file=sys.stderr)
                continue
            if not all(org <= x < fin for x in destinos):
                print("# 0x%04X: la tabla se sale del cartucho" % call_a,
                      file=sys.stderr)
                continue
            print("# CALL 0x%04X -> tabla 0x%04X, %d entradas"
                  % (call_a, tab, len(destinos)))
            todos.update(destinos)

    for a in sorted(todos):
        print("0x%04X   # destino de tabla de saltos" % a)
    print("# %d destinos distintos" % len(todos), file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
