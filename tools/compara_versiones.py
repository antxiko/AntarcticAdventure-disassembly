#!/usr/bin/env python3
"""Compara los tres volcados de Antarctic Adventure y saca las diferencias que
sostienen la pagina de las versiones.

    python3 tools/compara_versiones.py <1a japonesa> <2a japonesa> <europea>

Ninguno de los tres se distribuye con este repositorio. Los sha256 que espera
estan en la propia pagina; si el tuyo no da eso, es otro volcado y lo dira.

Lo que mira, y por que cada cosa:

  - el sha256 y el tamano, para saber de que estamos hablando;
  - en cuantos tramos y cuantos bytes difieren, que es lo que separa "otra
    compilacion" de "los mismos bytes con un retoque";
  - el registro 7 del VDP, que es el color de fondo y de borde;
  - como llega cada una al VDP: con el puerto escrito en el opcode o leyendolo
    de la zona de trabajo de la BIOS;
  - el LDIR del arranque y a donde apunta;
  - la vuelta al mundo: los diez punteros y los nombres a los que van.
"""
import hashlib
import re
import sys

ORG = 0x4000
# Los ocho registros que las tres copian a 0xE038; el octavo es el que pinta.
REGISTROS_VDP = bytes([0x02, 0xE2, 0x0E, 0x7F, 0x07, 0x76, 0x03])
COLORES = {0: "transparente", 1: "negro", 4: "azul oscuro", 14: "gris"}


def carga(ruta):
    with open(ruta, "rb") as f:
        return f.read()


def tramos(a, b, hueco=8):
    """Los bytes distintos, agrupados: dos diferencias a menos de `hueco` bytes
    cuentan como un solo tramo, que si no salen mil lineas de un byte."""
    d = [i for i in range(min(len(a), len(b))) if a[i] != b[i]]
    if not d:
        return []
    out = [[d[0], d[0]]]
    for i in d[1:]:
        if i - out[-1][1] <= hueco:
            out[-1][1] = i
        else:
            out.append([i, i])
    return out


def registro7(d):
    i = d.find(REGISTROS_VDP)
    if i < 0:
        return None, None
    return ORG + i, d[i + 7]


def puertos(d):
    """Cuantos accesos al VDP llevan el puerto metido en el propio opcode y
    cuantos lo llevan en C, que es como se lee de la BIOS."""
    cuenta = {}
    for nombre, patron in (("out (098h),a", rb"\xd3\x98"),
                           ("out (099h),a", rb"\xd3\x99"),
                           ("in a,(098h)", rb"\xdb\x98"),
                           ("in a,(099h)", rb"\xdb\x99"),
                           ("out (c),a", rb"\xed\x79"),
                           ("call WRTVDP", rb"\xcd\x47\x00")):
        cuenta[nombre] = len(re.findall(patron, d, re.DOTALL))
    return cuenta


def ldir_del_arranque(d):
    """El `ld hl,nn / ld de,nn / ld bc,0003h / ldir` de INIT, si lo lleva."""
    m = re.search(rb"\x21(..)\x11(..)\x01\x03\x00\xed\xb0", d, re.DOTALL)
    if not m:
        return None
    o = m.start()
    return (ORG + o, d[o + 1] | d[o + 2] << 8, d[o + 4] | d[o + 5] << 8)


# La fuente no es un ASCII corrido. La mayoria de las letras son su ASCII menos
# 0x20, pero tres viven sueltas por encima de 0xC0, y se leen solas por donde
# caen: 0xC9 es la unica F del juego (la de FRANCE), y 0xCA y 0xCB son la W y la
# Z de NEW ZEALAND. El 0x0F es el hueco entre palabras y el 0x20 el relleno de
# los extremos. Lo que no se sabe leer sale entre angulos con su byte.
SUELTAS = {0xC9: "F", 0xCA: "W", 0xCB: "Z"}


def cadena(d, p):
    """Un nombre de base, con 0xFF de cierre."""
    j = p - ORG
    # Si los dos primeros bytes son un destino de la tabla de nombres de la
    # VRAM (0x3800-0x3AFF), no son texto: son a donde va escrito.
    dest = d[j] | d[j + 1] << 8
    if 0x3800 <= dest < 0x3B00:
        j += 2
    else:
        dest = None
    s = ""
    while d[j] != 0xFF:
        b = d[j]
        if b in SUELTAS:
            s += SUELTAS[b]
        elif b == 0x0F:
            s += " "
        elif b == 0x20:
            pass
        elif 0x21 <= b + 0x20 < 0x7F:
            s += chr(b + 0x20)
        else:
            s += "<%02X>" % b
        j += 1
    return dest, s.strip()


def ruta(d):
    """Los diez punteros de las fases. La tabla CIERRA CLAVADA contra su
    primera cadena, y eso es lo que la identifica sin tener que suponer nada."""
    for tab in range(0x5500, 0x5620):
        ps = [d[tab - ORG + 2 * i] | d[tab - ORG + 2 * i + 1] << 8
              for i in range(10)]
        if tab + 20 == min(ps) and all(0x5500 < p < 0x5700 for p in ps):
            return tab, [(p,) + cadena(d, p) for p in ps]
    return None, []


def informe(nombre, ruta_fichero):
    d = carga(ruta_fichero)
    print("=" * 70)
    print(" %s" % nombre)
    print("=" * 70)
    print("  %s  %d bytes" % (hashlib.sha256(d).hexdigest(), len(d)))

    dir_tabla, r7 = registro7(d)
    if r7 is not None:
        fondo = r7 & 0x0F
        print("  registro 7 del VDP: tabla en 0x%04X, valor 0x%02X"
              "  -> tinta %d, fondo y borde %d (%s)"
              % (dir_tabla, r7, r7 >> 4, fondo, COLORES.get(fondo, "?")))

    c = puertos(d)
    metidos = c["out (098h),a"] + c["out (099h),a"] + c["in a,(098h)"] + c["in a,(099h)"]
    print("  accesos al VDP con el puerto en el opcode: %d" % metidos)
    print("  accesos con el puerto en C, leido de la BIOS: %d" % c["out (c),a"])
    print("  llamadas a WRTVDP (BIOS 0x0047): %d" % c["call WRTVDP"])

    ld = ldir_del_arranque(d)
    if ld is None:
        print("  LDIR de tres bytes en el arranque: NO LO LLEVA")
    else:
        print("  LDIR de tres bytes en 0x%04X: de 0x%04X a 0x%04X" % ld)

    tab, nombres = ruta(d)
    if tab:
        print("  la vuelta al mundo, de la tabla de 0x%04X:" % tab)
        vistos = set()
        for i, (p, dest, txt) in enumerate(nombres):
            vistos.add(p)
            print("     fase %d: 0x%04X  %s" % (i, p, txt))
        # Cadenas que estan en el cartucho y a las que no apunta nadie.
        fin = max(p for p, _, _ in nombres)
        p = tab + 20
        sueltas = []
        while p <= fin:
            dest, txt = cadena(d, p)
            largo = 2 if dest is not None else 0
            j = p - ORG + largo
            while d[j] != 0xFF:
                j += 1
            if p not in vistos:
                sueltas.append((p, txt))
            p = ORG + j + 1
        for p, txt in sueltas:
            print("     SIN USAR: 0x%04X  %s" % (p, txt))
    print()


def main():
    if len(sys.argv) != 4:
        print(__doc__)
        return 1
    nombres = ("PRIMERA JAPONESA", "SEGUNDA JAPONESA", "EUROPEA")
    for nombre, ruta_fichero in zip(nombres, sys.argv[1:]):
        informe(nombre, ruta_fichero)

    print("=" * 70)
    print(" EN QUE SE DIFERENCIAN")
    print("=" * 70)
    datos = [carga(p) for p in sys.argv[1:]]
    for i in range(3):
        for j in range(i + 1, 3):
            ts = tramos(datos[i], datos[j])
            n = sum(1 for x, y in zip(datos[i], datos[j]) if x != y)
            print("  %s vs %s: %d bytes distintos (%.2f %%) en %d tramo(s)"
                  % (nombres[i], nombres[j], n,
                     100.0 * n / len(datos[i]), len(ts)))
            for ini, f in ts[:6]:
                print("      0x%04X..0x%04X  (%d B)"
                      % (ORG + ini, ORG + f, f - ini + 1))
            if len(ts) > 6:
                print("      ... y %d tramos mas" % (len(ts) - 6))
    return 0


if __name__ == "__main__":
    sys.exit(main())
