#!/usr/bin/env python3
"""Empareja las direcciones de dos compilaciones caminandolas a la vez.

    python3 tools/mapa_direcciones.py <version_a> <version_b> [--difs]

Las tres versiones son el mismo programa ensamblado en sitios distintos, asi
que a casi cada instruccion de una le corresponde una de la otra. Este mapa es
lo que permite traducir las direcciones que aparecen dentro de los comentarios
prestados, y de paso deja senalado lo que de verdad cambia.

COMO SE CONSTRUYE, y por que no es adivinar:

  1. Se parte de ANCLAS que se localizan solas en las dos: INIT, el gancho de
     H.TIMI, el despachador, la rutina HL+=A, y los destinos de las tablas de
     salto emparejados tabla a tabla y entrada a entrada. Las tablas se
     identifican por su regla de cierre, asi que esas parejas no las elige
     nadie a dedo.
  2. Desde cada ancla se avanza POR LAS DOS A LA VEZ, instruccion a
     instruccion, mientras las dos digan lo mismo. Dos instrucciones "dicen lo
     mismo" cuando tienen la misma longitud y los mismos bytes, salvo el
     operando de 16 bits de las que llevan una direccion absoluta, que
     justamente es lo que cambia al mover el codigo.
  3. Cada `call nn`, `jp nn` o `ld rr,nn` que aparece emparejado da un ANCLA
     NUEVA, y se vuelve a empezar. Se repite hasta que no salen mas.

Asi que ninguna pareja se apunta sin haber comprobado antes que las dos
instrucciones coinciden. Donde el paseo se detiene es donde las versiones
divergen de verdad, y con --difs se listan esos puntos, que son el material de
la comparacion.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import localiza_entradas as loc
import z80trace

ORG = 0x4000

# Opcodes con una direccion absoluta de 16 bits, y en que byte empieza.
ABS_BASE = {0x01: 1, 0x11: 1, 0x21: 1, 0x31: 1,
            0x22: 1, 0x2A: 1, 0x32: 1, 0x3A: 1,
            0xC3: 1, 0xCD: 1}
for _op in (0xC2, 0xCA, 0xD2, 0xDA, 0xE2, 0xEA, 0xF2, 0xFA,   # jp cc,nn
            0xC4, 0xCC, 0xD4, 0xDC, 0xE4, 0xEC, 0xF4, 0xFC):  # call cc,nn
    ABS_BASE[_op] = 1
ABS_ED = {0x43, 0x4B, 0x53, 0x5B, 0x63, 0x6B, 0x73, 0x7B}     # ld (nn),rr


def sitio_del_operando(d, a):
    """Devuelve el desplazamiento del operando absoluto, o None si no lleva."""
    op = d[a - ORG]
    if op in ABS_BASE:
        return ABS_BASE[op]
    if op == 0xED and d[a + 1 - ORG] in ABS_ED:
        return 2
    return None


class Version:
    def __init__(self, v):
        self.v = v
        with open("antarctic-%s.rom" % v, "rb") as f:
            self.d = f.read()
        self.t = z80trace.Tracer(self.d, ORG)
        traza = json.load(open("work/%s/antarctic.trace.json" % v))
        self.codigo = set()
        for tipo, a, b in traza["blocks"]:
            if tipo == "c":
                self.codigo.update(range(a, b))

    def ilen(self, a):
        return self.t.ilen(a)

    def es_codigo(self, a):
        return a in self.codigo


def anclas(A, B):
    """Las parejas de partida, todas localizadas por patron en las dos."""
    out = []
    out.append((loc.palabra(A.d, ORG, ORG + 2), loc.palabra(B.d, ORG, ORG + 2)))
    ha, hb = loc.busca_htimi(A.d, ORG), loc.busca_htimi(B.d, ORG)
    if len(ha) == len(hb):
        out.extend(zip(ha, hb))

    def tablas(V):
        sumas = loc.busca_suma_a_hl(V.d, ORG)
        desps = loc.busca_despachador(V.d, ORG, sumas)
        out2 = []
        for dp in desps:
            pat = bytes([0xCD, dp & 0xFF, dp >> 8])
            for m in re.finditer(re.escape(pat), V.d):
                tab, ds = loc.tabla_detras_del_call(V.d, ORG, ORG + m.start())
                if ds:
                    out2.append((ORG + m.start(), ds))
        out2.sort()
        return sumas, desps, out2

    sa, da, ta = tablas(A)
    sb, db, tb = tablas(B)
    if len(sa) == len(sb):
        out.extend(zip(sa, sb))
    if len(da) == len(db):
        out.extend(zip(da, db))
    # Las tablas van en el mismo orden y con el mismo numero de entradas: si no
    # fuera asi no se emparejan, porque seria inventarselo.
    if len(ta) == len(tb) and all(len(x[1]) == len(y[1]) for x, y in zip(ta, tb)):
        for (ca, dsa), (cb, dsb) in zip(ta, tb):
            out.append((ca, cb))
            out.extend(zip(dsa, dsb))
    return out


def construye(A, B):
    mapa, vistos, difs = {}, set(), []
    pendientes = list(anclas(A, B))
    while pendientes:
        pa, pb = pendientes.pop()
        if (pa, pb) in vistos:
            continue
        vistos.add((pa, pb))
        while True:
            if not (A.es_codigo(pa) and B.es_codigo(pb)):
                break
            la, lb = A.ilen(pa), B.ilen(pb)
            if la == 0 or la != lb:
                difs.append((pa, pb, "longitudes distintas"))
                break
            ia = A.d[pa - ORG:pa - ORG + la]
            ib = B.d[pb - ORG:pb - ORG + lb]
            off = sitio_del_operando(A.d, pa)
            if off is None:
                if ia != ib:
                    difs.append((pa, pb, "instrucciones distintas"))
                    break
            else:
                if (ia[:off] != ib[:off]
                        or ia[off + 2:] != ib[off + 2:]
                        or sitio_del_operando(B.d, pb) != off):
                    difs.append((pa, pb, "instrucciones distintas"))
                    break
                va = ia[off] | ia[off + 1] << 8
                vb = ib[off] | ib[off + 1] << 8
                if ORG <= va < ORG + len(A.d) and ORG <= vb < ORG + len(B.d):
                    if (va, vb) not in vistos:
                        pendientes.append((va, vb))
            if pa in mapa and mapa[pa] != pb:
                difs.append((pa, pb, "la misma direccion sale emparejada dos veces"))
                break
            mapa[pa] = pb
            pa += la
            pb += lb
    return mapa, difs


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 1
    A, B = Version(sys.argv[1]), Version(sys.argv[2])
    mapa, difs = construye(A, B)
    cod_a = len(A.codigo)
    cubierto = sum(A.ilen(a) for a in mapa)
    print("# mapa %s -> %s: %d instrucciones emparejadas, %d de %d bytes de "
          "codigo (%.1f %%)"
          % (A.v, B.v, len(mapa), cubierto, cod_a, 100.0 * cubierto / cod_a))
    if "--difs" in sys.argv:
        print("# %d puntos donde el paseo se detiene:" % len(difs))
        for pa, pb, por_que in sorted(set(difs)):
            print("#   0x%04X / 0x%04X  %s" % (pa, pb, por_que))
    else:
        for a in sorted(mapa):
            print("0x%04X 0x%04X" % (a, mapa[a]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
