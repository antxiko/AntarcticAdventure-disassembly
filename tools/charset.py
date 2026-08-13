#!/usr/bin/env python3
"""Tabla de caracteres de Temptations (MSX) y buscador de textos.

El juego NO usa ASCII: tiene una fuente propia con su propio mapa de codigos.
Deducido renderizando los glifos de la tabla de patrones (0x4000..0x47FF del
bloque turbo 2) y contrastandolos con la pantalla de menu de 0x5CC0, que
coincide con la captura real del juego.

  espacio  = 0x00   (no 0x20)
  A..Z     = 0x41..0x5A  (posicion ASCII normal)
  0..9     = 0x5C..0x65  (desplazados: '8' es 0x64, verificado en "LUIGILOPEZ '88-")
  "        = 0x68
  .        = 0x6A
  ,        = 0x6B
  :        = 0x6C
  -        = 0x6D

Curiosidad verificada: los codigos 'U' (0x55) y 'V' (0x56) tienen el MISMO
glifo, por eso el texto original escribe indistintamente "PVES" y "NUEUO".
"""
import sys

DEC = {0x00: " ", 0x68: '"', 0x6A: ".", 0x6B: ",", 0x6C: ":", 0x6D: "-"}
for _i in range(26):
    DEC[0x41 + _i] = chr(0x41 + _i)
for _i in range(10):
    DEC[0x5C + _i] = str(_i)

ENC = {}
for _k, _v in DEC.items():
    ENC.setdefault(_v, _k)


def decode(bs):
    return "".join(DEC.get(b, "�") for b in bs)


def is_text_byte(b):
    return b in DEC


def find_strings(data, org=0, minlen=6):
    """Busca tiras de codigos validos. Ignora las de puro espacio."""
    out, run, start = [], [], None
    for i, b in enumerate(data):
        if is_text_byte(b):
            if start is None:
                start = i
            run.append(b)
        else:
            if start is not None and len(run) >= minlen:
                s = decode(run)
                if s.strip():
                    out.append((org + start, s))
            run, start = [], None
    if start is not None and len(run) >= minlen:
        s = decode(run)
        if s.strip():
            out.append((org + start, s))
    return out


if __name__ == "__main__":
    path, org = sys.argv[1], int(sys.argv[2], 0)
    minlen = int(sys.argv[3]) if len(sys.argv) > 3 else 6
    data = open(path, "rb").read()
    res = find_strings(data, org, minlen)
    print(f"# {len(res)} cadenas en {path} (org {org:#06x}, min {minlen})")
    for a, s in res:
        print(f"{a:#06x}  {s!r}")
