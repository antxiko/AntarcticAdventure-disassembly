#!/usr/bin/env python3
"""Comprobaciones sobre el listado generado.

Ninguna de estas necesita el cartucho: se hacen sobre src/antarctic.asm y
src/antarctic.notes, que van en el repositorio. Lo que vigilan es que el
listado no se degrade sin que nadie se entere -que no vuelvan a aparecer
etiquetas sin nombre, ni bloques de datos sin identificar, ni comentarios que
se queden por el camino-.
"""
import os
import re
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASM = os.path.join(RAIZ, "src", "antarctic.asm")
NOTES = os.path.join(RAIZ, "src", "antarctic.notes")


def asm():
    with open(ASM, encoding="utf-8") as f:
        return f.read()


def notas():
    with open(NOTES, encoding="utf-8") as f:
        return f.read().splitlines()


class TestListado(unittest.TestCase):

    def test_ninguna_etiqueta_sin_nombre(self):
        """Una L_XXXX es una etiqueta que nadie ha bautizado todavia."""
        sueltas = sorted(set(re.findall(r"\bL_[0-9A-F]{4}\b", asm())))
        self.assertEqual(sueltas, [], "quedan etiquetas sin nombre: %s"
                         % " ".join(sueltas[:12]))

    def test_ningun_bloque_de_datos_sin_identificar(self):
        """Cada zona de datos tiene que tener nombre y explicacion."""
        n = asm().count("DATOS sin identificar")
        self.assertEqual(n, 0, "hay %d bloques de datos sin identificar" % n)

    def test_ninguna_etiqueta_declarada_con_equ(self):
        """Un `equ` suelto senala una direccion que el listado no ha colocado.

        Cuando aparece, casi siempre es una tabla apuntada un byte antes de
        donde empieza, o codigo al que el trazador no llega. En los dos casos
        hay algo que mirar, asi que no debe pasar desapercibido.
        """
        sueltas = re.findall(r"(?m)^(\w+):\tequ", asm())
        self.assertEqual(sueltas, [], "hay etiquetas sin colocar: %s"
                         % " ".join(sueltas))

    def test_todos_los_comentarios_llegan_al_listado(self):
        """Una C anclada a una direccion que no es inicio de instruccion se cae.

        mkasm no avisa de eso: sencillamente no la emite. Como el comentario
        sigue en el .notes, es facil creer que esta puesto cuando no lo esta.
        """
        cuerpo = asm()
        perdidos = []
        for ln in notas():
            ln = ln.strip()
            if ln.startswith("C "):
                p = ln.split(None, 2)
                if len(p) > 2 and p[2] not in cuerpo:
                    perdidos.append(p[1])
        self.assertEqual(perdidos, [], "comentarios que no salen: %s"
                         % " ".join(perdidos[:12]))

    def test_todas_las_cabeceras_llegan_al_listado(self):
        cuerpo = asm()
        perdidas = []
        for ln in notas():
            ln = ln.rstrip()
            if ln.startswith("B "):
                p = ln.split(None, 2)
                if len(p) > 2 and p[2].strip() and p[2] not in cuerpo:
                    perdidas.append(p[1])
        self.assertEqual(perdidas, [], "cabeceras que no salen: %s"
                         % " ".join(perdidas[:12]))

    def test_el_listado_lo_genera_la_herramienta(self):
        """Si alguien edita el .asm a mano, el siguiente `make` se lo come."""
        self.assertIn("Generado por tools/mkasm.py", asm())


class TestRangosDeDatos(unittest.TestCase):

    def test_los_rangos_no_se_solapan(self):
        """Dos rangos D que se pisen quieren decir que uno de los dos miente."""
        rangos = []
        for ln in notas():
            if ln.startswith("D "):
                p = ln.split(None, 3)
                rangos.append((int(p[1], 0), int(p[2], 0), p[2]))
        rangos.sort()
        for (a1, b1, _), (a2, b2, _) in zip(rangos, rangos[1:]):
            self.assertLessEqual(b1, a2,
                                 "se solapan 0x%04X-0x%04X y 0x%04X-0x%04X"
                                 % (a1, b1, a2, b2))

    def test_todos_los_rangos_van_al_derecho(self):
        for ln in notas():
            if ln.startswith("D "):
                p = ln.split(None, 3)
                a, b = int(p[1], 0), int(p[2], 0)
                self.assertLess(a, b, "rango del reves: %s" % ln)

    def test_todos_los_rangos_estan_explicados(self):
        """Un rango con nombre pero sin descripcion no explica nada."""
        mudos = []
        for ln in notas():
            if ln.startswith("D "):
                p = ln.split(None, 4)
                if len(p) < 5 or not p[4].strip():
                    mudos.append(p[1])
        self.assertEqual(mudos, [], "rangos sin explicacion: %s"
                         % " ".join(mudos))


if __name__ == "__main__":
    unittest.main()
