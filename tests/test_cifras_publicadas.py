#!/usr/bin/env python3
"""Que la web y los README no digan una cifra distinta de la que sale del listado.

Esto es el guardian de la documentacion. Publicar "394 etiquetas" y que sean
380 no lo caza ninguna otra comprobacion: el listado reensambla igual, los
rangos siguen cuadrando y la web se genera sin protestar. La unica forma de que
no se despeguen es contar y comparar.

Cuando uno de estos falla al comentar una rutina nueva, NO es una regresion: es
el guardian haciendo su trabajo. Se arregla actualizando la cifra publicada.
"""
import os
import re
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASM = os.path.join(RAIZ, "src", "antarctic.asm")
NOTES = os.path.join(RAIZ, "src", "antarctic.notes")
MAKEWEB = os.path.join(RAIZ, "tools", "make_web.py")

TOTAL = 16384


def lee(p):
    with open(p, encoding="utf-8") as f:
        return f.read()


def cuenta_etiquetas():
    return len(set(re.findall(r"(?m)^([A-Za-z_]\w*):", lee(ASM))))


def cuenta_rutinas():
    """Las que alguien llama con un CALL, que es lo que se publica como rutina."""
    cuerpo = lee(ASM)
    definidas = set(re.findall(r"(?m)^([A-Za-z_]\w*):", cuerpo))
    llamadas = set(re.findall(
        r"\bcall\s+(?:nz,|z,|nc,|c,|po,|pe,|p,|m,)?([A-Za-z_]\w*)", cuerpo))
    return len(llamadas & definidas)


def cuenta_bytes_de_codigo():
    """Suma el tamano de cada region de codigo declarada en el listado."""
    n = 0
    for a, b in re.findall(r"; CODIGO (0x[0-9a-f]+)\.\.(0x[0-9a-f]+)", lee(ASM)):
        n += int(b, 16) - int(a, 16)
    return n


def cuenta_directiva(letra):
    return sum(1 for ln in lee(NOTES).splitlines() if ln.startswith(letra + " "))


class TestCifras(unittest.TestCase):

    def test_codigo_y_datos_suman_el_cartucho(self):
        """La cuenta que sostiene el '0 bytes sin explicar' de la portada."""
        codigo = cuenta_bytes_de_codigo()
        self.assertEqual(codigo, 5947)
        self.assertEqual(TOTAL - codigo, 10437)

    def test_la_portada_publica_esas_mismas_cifras(self):
        web = lee(MAKEWEB)
        codigo = cuenta_bytes_de_codigo()
        datos = TOTAL - codigo
        for cifra, sep in ((codigo, "."), (codigo, ","), (datos, "."), (datos, ",")):
            texto = "%s%s%03d" % (cifra // 1000, sep, cifra % 1000)
            self.assertIn(texto, web,
                          "la portada no publica %s" % texto)

    def test_la_portada_publica_las_rutinas_que_hay(self):
        self.assertIn('("%d", "rutinas identificadas")' % cuenta_rutinas(),
                      lee(MAKEWEB))
        self.assertIn('("%d", "routines identified")' % cuenta_rutinas(),
                      lee(MAKEWEB))

    def test_la_portada_dice_cero_sin_identificar(self):
        web = lee(MAKEWEB)
        self.assertIn('("0", "bytes sin identificar")', web)
        self.assertIn('("0", "bytes unidentified")', web)

    def test_las_dos_paginas_de_empezar_dicen_las_mismas_etiquetas(self):
        n = cuenta_etiquetas()
        for pagina in ("docs/es/EMPEZAR.md", "docs/GETTING-STARTED.md"):
            texto = lee(os.path.join(RAIZ, pagina))
            self.assertIn(str(n), texto,
                          "%s no publica las %d etiquetas" % (pagina, n))

    def test_los_comentarios_publicados_son_los_que_hay(self):
        n = cuenta_directiva("C")
        for pagina in ("docs/es/EMPEZAR.md", "docs/GETTING-STARTED.md",
                       "README.md", "README.es.md"):
            self.assertIn(str(n), lee(os.path.join(RAIZ, pagina)),
                          "%s no publica los %d comentarios" % (pagina, n))

    def test_los_rangos_publicados_son_los_que_hay(self):
        n = cuenta_directiva("D")
        for pagina in ("docs/es/EMPEZAR.md", "docs/GETTING-STARTED.md",
                       "README.md", "README.es.md"):
            self.assertIn(str(n), lee(os.path.join(RAIZ, pagina)),
                          "%s no publica los %d rangos" % (pagina, n))

    def test_el_sha_del_cartucho_es_el_mismo_por_todas_partes(self):
        SHA = "17f4dd654c937134c44c1faf68a9f67141d69ccf251853228aa5211dc8065126"
        for fichero in ("Makefile", "README.md", "README.es.md",
                        "docs/es/EMPEZAR.md", "docs/GETTING-STARTED.md"):
            self.assertIn(SHA, lee(os.path.join(RAIZ, fichero)),
                          "%s no lleva el sha256 del cartucho" % fichero)


class TestLasDiezFases(unittest.TestCase):
    """Las dos paginas del juego tienen que contar el mismo recorrido."""

    FASES = [("FRANCE", "1500", "100"), ("USA", "1700", "120"),
             ("THE SOUTH POLE", "1100", "80"), ("USA", "1200", "80"),
             ("USA", "1200", "80"), ("ARGENTINA", "500", "40"),
             ("UNITED KINGDOM", "2600", "165"), ("JAPAN", "1200", "90"),
             ("AUSTRALIA", "1500", "100"), ("AUSTRALIA", "1200", "90")]

    def test_las_dos_tablas_dicen_lo_mismo(self):
        for pagina in ("docs/es/EL-JUEGO.md", "docs/THE-GAME.md"):
            texto = lee(os.path.join(RAIZ, pagina))
            for i, (base, dist, tiempo) in enumerate(self.FASES, 1):
                fila = "| %d | %s | %s m | %s s |" % (i, base, dist, tiempo)
                self.assertIn(fila, texto, "%s: falta la fila %s" % (pagina, fila))


if __name__ == "__main__":
    unittest.main()
