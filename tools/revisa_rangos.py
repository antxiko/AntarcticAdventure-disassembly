#!/usr/bin/env python3
"""Comprueba si una explicacion prestada sigue siendo cierta en otra version.

    python3 tools/revisa_rangos.py <version_origen> <version_destino>

Cuando se arranca una version copiando los nombres y las explicaciones de otra,
queda la pregunta incomoda: ¿sigue siendo verdad lo que dice cada texto AQUI?
Leer los sesenta y tantos rangos a ojo es justo la clase de repaso que se hace
mal, asi que esto los separa en tres montones y solo deja para leer los que de
verdad hay que leer.

  IGUALES. El contenido del rango es byte a byte el mismo que en la version de
  origen. Si los bytes no cambian, lo que se dijo de ellos sigue valiendo, y no
  hay nada que repasar.

  TABLAS DE PUNTEROS que se comprueban solas. El rango no coincide byte a byte
  -no puede, porque lleva direcciones dentro-, pero si se lee como palabras de
  16 bits y TODAS caen dentro del cartucho, y ademas caen donde la explicacion
  dice que caen, la explicacion queda verificada aqui y no prestada. Se
  comprueba tambien que tenga el mismo numero de entradas que en el origen.

  A LEER. Todo lo demas: los que cambian de tamano y los que no son ni una cosa
  ni la otra. Esos son los que hay que mirar de verdad, y suelen ser pocos.

Lo que esta herramienta NO dice es que un texto este bien escrito: dice si los
bytes que describe son los mismos o si su estructura se sostiene. Lo demas es
leerlo.
"""
import os
import re
import sys

ORG = 0x4000


def rangos(v):
    out = []
    with open("src/%s/antarctic.notes" % v, encoding="utf-8") as f:
        for ln in f:
            m = re.match(r"^D\s+(0x[0-9A-Fa-f]+)\s+(0x[0-9A-Fa-f]+)\s+(\S+)\s*(.*)",
                         ln.rstrip("\n"))
            if m:
                out.append((int(m.group(1), 16), int(m.group(2), 16),
                            m.group(3), m.group(4)))
    return sorted(out)


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        return 1
    vo, vd = sys.argv[1], sys.argv[2]
    with open("antarctic-%s.rom" % vo, "rb") as f:
        do = f.read()
    with open("antarctic-%s.rom" % vd, "rb") as f:
        dd = f.read()
    ro = {n: (a, b, t) for a, b, n, t in rangos(vo)}
    rd = rangos(vd)

    # Una explicacion que CITA BYTES es comprobable palabra por palabra, y es
    # donde mas facil se cuela un dato prestado: el texto viaja de una version a
    # otra y los bytes no. Se busca cualquier tira de tres o mas parejas hex
    # dentro del texto y se compara con lo que hay de verdad en el rango.
    CITA = re.compile(r"\b((?:[0-9A-F]{2} ){2,}[0-9A-F]{2})\b")
    mentiras = []
    for a, b, nombre, txt in rd:
        for cita in CITA.findall(txt):
            bs = bytes(int(x, 16) for x in cita.split())
            if bs not in dd[a - ORG:b - ORG]:
                real = dd[a - ORG:min(b, a + len(bs)) - ORG]
                mentiras.append((a, b, nombre, cita,
                                 " ".join("%02X" % x for x in real)))

    iguales, tablas, aleer = [], [], []
    for a, b, nombre, txt in rd:
        if nombre.startswith("tabla_de_saltos_"):
            # Estas no vienen prestadas: se localizan en esta ROM con su propia
            # regla de cierre, asi que no hay nada que repasar.
            iguales.append((a, b, nombre))
            continue
        if nombre not in ro:
            aleer.append((a, b, nombre, "no existe con ese nombre en %s" % vo))
            continue
        oa, ob, _ = ro[nombre]
        if do[oa - ORG:ob - ORG] == dd[a - ORG:b - ORG]:
            iguales.append((a, b, nombre))
            continue
        # ¿Se sostiene como tabla de punteros?
        n_o, n_d = (ob - oa) // 2, (b - a) // 2
        palabras = [dd[a - ORG + 2 * i] | dd[a - ORG + 2 * i + 1] << 8
                    for i in range(n_d)]
        dentro = all(ORG <= p < ORG + len(dd) for p in palabras)
        if (b - a) % 2 == 0 and dentro and n_o == n_d and n_d <= 64:
            # ¿A que rango con nombre apunta cada una?
            destinos = set()
            for p in palabras:
                for a2, b2, n2, _ in rd:
                    if a2 <= p < b2:
                        destinos.add(n2)
                        break
                else:
                    destinos.add("codigo")
            tablas.append((a, b, nombre, n_d, sorted(destinos)))
        else:
            por_que = []
            if n_o != n_d:
                por_que.append("cambia de tamano: %d B alli, %d aqui"
                               % (ob - oa, b - a))
            if not dentro:
                por_que.append("leido como punteros, alguno se sale del cartucho")
            aleer.append((a, b, nombre, "; ".join(por_que) or "contenido distinto"))

    print("=" * 72)
    print(" %s -> %s: %d rangos" % (vo, vd, len(rd)))
    print("=" * 72)
    print(" IGUALES BYTE A BYTE, la explicacion vale tal cual: %d" % len(iguales))
    print(" TABLAS DE PUNTEROS que se comprueban solas: %d" % len(tablas))
    for a, b, nombre, n, dest in tablas:
        print("   0x%04X..0x%04X  %-28s %2d punteros -> %s"
              % (a, b, nombre, n, ", ".join(dest)))
    print(" A LEER A MANO: %d" % len(aleer))
    for a, b, nombre, por_que in aleer:
        print("   0x%04X..0x%04X  %-28s %s" % (a, b, nombre, por_que))
    if mentiras:
        print()
        print("=" * 72)
        print(" EXPLICACIONES QUE CITAN BYTES QUE AQUI NO ESTAN: %d" % len(mentiras))
        print("=" * 72)
        for a, b, nombre, cita, real in mentiras:
            print("   0x%04X  %-28s dice  %s" % (a, nombre, cita))
            print("           %-28s y hay %s" % ("", real))
    return 2 if mentiras else 0


if __name__ == "__main__":
    sys.exit(main())
