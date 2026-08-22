# Antarctic Adventure (Konami, 1984, MSX) — desensamblado comentado

> **Cuál es cuál no está cerrado.** De este cartucho hay varias compilaciones
> distintas, y lo que este repositorio dice sobre **versiones y regiones** puede
> cambiar. El listado y las cifras salen del binario igualmente, y `make` las
> reproduce.

Un cartucho de 16 KB de 1984, desmontado byte a byte. Los 16.384 bytes
están acotados y explicados, y dentro hay un pingüino que cruza la Antártida
entre diez bases de investigación, una demostración que va grabada como una
pianola, y una base a la que no se llega nunca.

📖 **[Documentación completa](https://antxiko.github.io/AntarcticAdventure-disassembly/es/)**
· [In English](https://antxiko.github.io/AntarcticAdventure-disassembly/)
· [README in English](README.md)

---

## Qué es esto

*Antarctic Adventure* es un cartucho que Konami publicó para MSX en 1984, con
referencia RC-701. Este repositorio tiene su código comentado y las
herramientas para reconstruirlo y comprobar que lo que sale es de verdad el
original.

Que sea un cartucho le cambia la forma al trabajo. No hay cargador ni bloques
que esperar: la máquina mapea los 16 KB en 0x4000-0x7FFF y eso es todo, una
sola foto de la memoria sin solapes. La BIOS lee una cabecera «AB», llama al
punto de entrada de 0x4010, y de ahí ya no se vuelve: el arranque se mete en un
bucle vacío de dos bytes y **el juego entero corre dentro de la interrupción**,
cincuenta o sesenta veces por segundo.

Tampoco hay ni una variable en el cartucho, porque es ROM. Todo el estado vive
en la RAM de la máquina a partir de 0xE000, y por eso el listado está lleno de
direcciones que empiezan por 0xE0 y que no son datos.

## Cómo se sabe que esto es verdad

`make` traza el flujo, genera el listado y exige que al ensamblarlo vuelva a
salir exactamente el original:

```
  ensamblado : 16384 bytes  a33f9298...dc3c452
  original   : 16384 bytes  a33f9298...dc3c452
OK: reproducible byte a byte
```

Esa es la prueba que decide si un desensamblado es fiable, pero no es la única
que corre aquí, porque un listado puede reensamblar perfecto y estar mintiendo:
si unos dibujos se leen como instrucciones, los bytes no cambian, solo cambia
lo que decimos de ellos. Así que van dos comprobaciones más al lado:

- ninguna zona declarada como datos puede salir como código;
- y ningún punto de entrada puede caer dentro de una.

## Las cifras

| | |
|---|---|
| bytes de código | 5.947 |
| bytes de datos | 10.437 |
| bytes sin explicar | **0** |
| etiquetas con nombre | 394 |
| comentarios anclados | 713 |
| rangos de datos con explicación | 63 |

## Algunas cosas que aparecieron

- **La demo va grabada.** 64 bytes con exactamente los bits del joystick,
  leídos uno cada 32 fotogramas. No hay ninguna inteligencia detrás.
- **Lo primero que hace el cartucho es escribir encima de la BIOS**, copiando
  un `jp 0000h` sobre 0x0000. Ahí hay ROM, así que no pasa nada; y esa
  instrucción es lo único que separa entre sí a los volcados de esta versión
  que circulan por ahí.
- **Hay una base de investigación que no visita nadie**: NEW ZEALAND está ahí,
  escrita, y ninguna instrucción la apunta. En la primera versión japonesa del
  cartucho sí se visita, y es la quinta parada del recorrido.
- **El alfabeto no tiene F.** La única palabra del juego que necesita una,
  FRANCE, se la lleva puesta, guardada lejos del resto de las letras.
- **En 0xE100 no está la velocidad, sino su periodo**: cuantos más fotogramas
  espera, más lento se va, así que acelerar es restarle. Y frenar cuesta la
  tercera parte que acelerar.

Hay más, con la evidencia al lado, en
[la página de hallazgos](https://antxiko.github.io/AntarcticAdventure-disassembly/es/HALLAZGOS.html).

De este cartucho hay tres compilaciones distintas, y esta que se desensambla
aquí es la **segunda versión japonesa**. Lo que cambia de una a otra —el color
del fondo, el recorrido, y hasta cómo le hablan al chip gráfico— está en
[la página de las versiones](https://antxiko.github.io/AntarcticAdventure-disassembly/es/LAS-VERSIONES.html).

## Lo que queda abierto

El listado está completo y no hay un byte sin explicar, pero todavía no se ha
medido nada en un emulador: lo que se lee explica lo que el programa hace, no
lo que el jugador ve. Una cosa depende de eso, y están con las demás en
[la página de preguntas abiertas](https://antxiko.github.io/AntarcticAdventure-disassembly/es/PREGUNTAS-ABIERTAS.html).

## Para empezar

Hacen falta `pasmo`, `z80dasm` y Python 3. El cartucho **no** se distribuye
aquí: pon tu propia copia en la raíz con el nombre `antarctic.rom`, 16384 bytes,
sha256 `a33f9298bf6f740ebe8d88bdc8ed75c855404d804e07679d6c2f2ad00dc3c452`.

```sh
make          # traza, genera el listado y lo comprueba todo
make verify   # solo la prueba de fuego
make graficos # descomprime los dibujos y los saca a PNG
```

Las instrucciones completas están en
[Empezar](https://antxiko.github.io/AntarcticAdventure-disassembly/es/EMPEZAR.html).

## Licencia y atribución

El juego no es nuestro: *Antarctic Adventure* es de Konami y todos los derechos
sobre él siguen siendo de sus titulares. Lo que sí es nuestro —las
herramientas, los comentarios, el análisis y la documentación— se publica bajo
la licencia que consta en `LICENSE`. La imagen del cartucho no se distribuye.
Ver [AVISO-LEGAL.md](AVISO-LEGAL.md).
