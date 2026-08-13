# Aviso legal y de atribución

*(Also available [in English](LEGAL-NOTICE.md).)*

## De quién es cada cosa

**El juego no es nuestro.** *Antarctic Adventure* (1984) lo publicó **Konami**,
con referencia RC-701. Todos los derechos sobre el juego siguen siendo de sus
titulares.

**Lo que sí es nuestro** son las herramientas de este repositorio, los
comentarios del listado, el análisis y la documentación. Eso se publica bajo la
licencia que consta en `LICENSE`.

## Qué contiene este repositorio

El fichero `src/antarctic.asm` es el desensamblado comentado del cartucho. Se
publica con ánimo de **preservación, estudio y documentación** de un título de
1984 que forma parte de la historia del software para MSX.

La imagen del cartucho (`.rom`) **no** se distribuye aquí. Quien quiera
reconstruir el listado tiene que poner la suya, y el `Makefile` comprueba su
sha256 antes de hacer nada.

Las imágenes de `docs/` no son capturas tomadas del juego: se generan a partir
de los datos del binario con las herramientas del repositorio, descomprimiendo
lo que el juego descomprime y usando las bases de memoria que él mismo escribe
en los registros del chip gráfico. Son parte de la demostración de que el
formato está bien entendido.

## En qué se apoya

En nada de terceros. Todo lo que se afirma aquí sale de leer este binario, y
cada afirmación lleva al lado la evidencia que la sostiene: la instrucción que
lee un dato, la tabla que cierra donde tiene que cerrar, o la cuenta que cuadra
sola. Lo que no está cerrado está dicho como tal en la página de preguntas
abiertas.

## Si eres uno de los autores

Si trabajaste en *Antarctic Adventure* o eres titular de derechos sobre el
juego, y prefieres que este material no esté publicado, **dilo y se retira sin
discusión**. La intención de este trabajo es exactamente la contraria a
perjudicaros: es dejar constancia de cómo estaba hecho.
