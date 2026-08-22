# Empezar

## Lo que hace falta

`pasmo` y `z80dasm` para ensamblar y desensamblar, y Python 3 para las
herramientas.

El cartucho no se distribuye con este repositorio, solo el trabajo de
documentación, así que hace falta tu propia copia con el nombre
`antarctic.rom` en la raíz del proyecto. Son 16384 bytes exactos y tiene que
dar este sha256:

    a33f9298bf6f740ebe8d88bdc8ed75c855404d804e07679d6c2f2ad00dc3c452

Si el tuyo no da eso, es otra versión y el listado no reensamblará. `make
comprueba` te lo dice en una línea.

## Las órdenes

```sh
make          # traza, genera el listado y lo comprueba todo
make verify   # solo la prueba de fuego: ¿vuelve a salir el cartucho?
make graficos # descomprime los dibujos y los saca a PNG
```

`make` a secas hace el ciclo entero y falla si algo no cuadra: si el listado
deja de reproducir el cartucho byte a byte, si el trazador se ha metido en una
zona declarada como datos, o si un punto de entrada cae dentro de esa zona.

## La prueba que decide

Lo único que convierte un desensamblado en algo fiable es que vuelva a dar el
original. Aquí eso es `make verify`, y lo que hace es ensamblar el listado
publicado y comparar el sha256 con el del cartucho:

    ensamblado : 16384 bytes  a33f9298...dc3c452
    original   : 16384 bytes  a33f9298...dc3c452
    OK: reproducible byte a byte

Mientras esa línea salga, ni un comentario de este repositorio puede haberse
comido un byte por el camino.

## Sin el cartucho

Se puede leer igualmente el listado de `src/jap2/antarctic.asm` y las notas, que es
donde está de verdad el trabajo: 394 rutinas con nombre, 663 comentarios
anclados a su dirección y 63 rangos de datos con su explicación al lado.

## Cómo está organizado

El listado **no se toca a mano**. Se genera, y lo gobiernan tres ficheros:

| | |
|---|---|
| `src/jap2/antarctic.entries` | los puntos de entrada: por dónde empieza a trazar |
| `src/jap2/antarctic.nocode` | las zonas que NO son código, y por qué se sabe |
| `src/jap2/antarctic.notes` | los nombres, los comentarios y los rangos de datos |

De ahí sale `src/jap2/antarctic.asm`. Si quieres cambiar un comentario o bautizar
una rutina, va en el `.notes`, anclado a su dirección; así el comentario
sobrevive a un retrazado y nunca se despega de la instrucción que explica.

Esa separación es justo lo que evita que el listado y su comprobación se
distancien con el tiempo, porque el fichero que se publica es el mismo que se
verifica.

### Como salen los bloques de datos

Cada rango de datos declarado en el `.notes` sale como un bloque aparte: su
cabecera diciendo para que sirve, su etiqueta y el volcado alineado a su primer
byte, de modo que se ve de un golpe donde acaba una tabla y empieza la
siguiente. Una linea opcional le da al bloque la anchura de fila de su
estructura real -dos bytes por fase, ocho por lista, `defw` si es una tabla de
punteros- y cuando un puntero cae en un bloque
que tiene nombre, ese nombre se escribe al lado.

## Las herramientas

En `tools/` está todo lo que hace falta, y cada una lleva escrito en su
cabecera qué hace y por qué se hizo así:

| | |
|---|---|
| `z80trace.py` | sigue el flujo desde los puntos de entrada |
| `mkasm.py` | monta el listado con las notas ancladas |
| `descomprime.py` | el descompresor del juego, reimplementado |
| `refs.py` | qué instrucciones apuntan a un rango, sin inventarse punteros |
| `render_tiles.py` | dibuja las casillas y los sprites desde la VRAM |
| `render_banderas.py` | las banderas de las diez paradas |
| `render_decorados.py` | los decorados, con el intérprete del propio juego |
| `render_pista.py` | los siete obstáculos, montados paso a paso |
| `render_foca.py` | la foca que sale de los agujeros, fotograma a fotograma |
| `render_pinguino.py` | las diez posturas del pingüino, en su color |
