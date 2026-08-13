# El cartucho

Son 16384 bytes, y ya está. No hay cargador, ni bloques, ni nada que esperar:
el MSX mapea el cartucho en 0x4000-0x7FFF y lo que hay ahí es lo que hay para
siempre. Eso hace el reparto de bytes mucho más limpio de lo que suele ser,
porque no hay dos cosas distintas ocupando la misma dirección en momentos
distintos: una sola foto de la memoria, sin solapes.

## Por dónde entra

Los primeros dieciséis bytes son la cabecera que lee la BIOS:

    41 42 10 40 00 00 00 00 00 00 00 00 00 00 00 00
    'A' 'B'  \_ INIT = 0x4010

Las dos letras son la firma que le dice a la máquina que ahí hay un cartucho
ejecutable, y detrás van cuatro vectores de dos bytes. Solo el primero está
puesto: los otros tres —los que servirían para añadir instrucciones al BASIC o
para declarar un dispositivo— están a cero. Este cartucho es un juego y nada
más.

Así que la BIOS termina de arrancar la máquina y llama a 0x4010. Y de ahí ya no
se vuelve.

## Lo que hace el arranque

Poco, y muy medido:

- apaga las interrupciones y rellena de `ret` los 512 bytes de ganchos de la
  BIOS, para que ninguno haga nada;
- engancha el suyo en el gancho del temporizador, que es el que la BIOS llama
  en cada retrazado de pantalla;
- pone la pila en 0xE400 y borra los 2 KB que hay justo encima, que es donde va
  a vivir todo el estado del juego;
- escribe los registros del chip gráfico, calla el chip de sonido y deja la
  memoria de vídeo a cero;
- y se mete en un bucle vacío de dos bytes.

Ese bucle vacío es el programa principal. **A partir de ahí el juego entero
corre dentro de la interrupción**, cincuenta o sesenta veces por segundo, y el
hilo que arrancó la máquina no vuelve a hacer nada nunca.

## Dónde vive el estado

En el cartucho no hay ni una variable, porque es ROM. Todo lo que el juego
apunta vive en la RAM del MSX a partir de 0xE000, y por eso el listado está
lleno de direcciones que empiezan por 0xE0: no son datos del cartucho, son
variables.

Las que más se leen:

| | |
|---|---|
| 0xE000 | el estado del juego, de 0 a 15 |
| 0xE001 | el paso dentro de ese estado |
| 0xE003 | el contador de fotogramas, que hace de reloj para todo |
| 0xE005 | el cerrojo que impide que la interrupción se pise a sí misma |
| 0xE009 | lo que se está pulsando, y en 0xE008 lo del fotograma anterior |
| 0xE040 | el récord, y en 0xE043 el marcador |
| 0xE078 | los cuatro sprites del pingüino |
| 0xE100 | la velocidad |
| 0xE112 | las fichas de los obstáculos |

## La pantalla, puesta del revés

El juego no se conforma con lo que deja la BIOS: escribe él mismo los ocho
registros del chip gráfico, con una tabla de ocho bytes que lleva dentro. Y el
reparto que le sale es el contrario del habitual.

| | |
|---|---|
| 0x0000 | los colores |
| 0x1800 | los patrones de sprite |
| 0x2000 | los patrones |
| 0x3800 | la tabla de nombres |
| 0x3B00 | los atributos de sprite |

Lo normal es tener los patrones abajo y los colores arriba; aquí es al revés, y
eso importa más de lo que parece, porque dibujar el cartucho con las bases
cambiadas **no da un error**: da una imagen, y encima convincente, porque una
tabla de colores leída como dibujo tiene toda la pinta de un dibujo. Por eso
las herramientas de este repositorio sacan las bases de los registros que
escribe el juego, y no de una constante puesta a mano.

El modo es el gráfico de 256x192 con sprites de 16x16 sin ampliar, y el borde
queda en azul oscuro.

## Los tres bancos, y las dieciséis casillas de color liso

En este modo la pantalla se parte en tres tercios y cada uno tiene su propio
juego de 256 dibujos. El cartucho monta los tres iguales de salida: la misma
tipografía y los mismos gráficos escritos tres veces, 1792 bytes de dibujo y
otros 1792 de color en cada tercio.

Y hay un detalle que se paga solo: **las dieciséis primeras casillas de cada
tercio son cuadrados de color liso**, una por color de la paleta. Se montan a
mano, sin comprimir, escribiendo el número de color repetido ocho veces. Con
eso, pintar el cielo o el hielo no cuesta ningún dibujo: se rellena la fila con
la casilla del color que toque.

## Y todo lo demás va comprimido

Ni un gráfico está en crudo. Hay un descompresor de 61 bytes que lee un formato
de los que se entienden a la primera —un byte dice si lo que viene se repite
tantas veces o si son tantos bytes tal cual— y cuatro puertas distintas para
entrar en él según de dónde tenga que sacar el destino, o según si hay que
espejar el dibujo por el camino.

De los 16 KB del cartucho, 10437 bytes son datos y 5947 son código.

## El reparto completo

Ni un byte sin dueño. Esto es lo que hay, de arriba abajo:

| | |
|---|---|
| 0x4000-0x4010 | la cabecera |
| 0x4010-0x44DF | arranque, interrupción, mandos y máquina de estados |
| 0x44DF-0x4787 | vídeo, cadenas, descompresor y marcador |
| 0x4787-0x4843 | las tablas de decorado por fase |
| 0x4843-0x4A01 | el rótulo, el acceso a la memoria de vídeo y el mapa |
| 0x4A01-0x4B01 | el dibujo del mapa, el recorrido y las diez fases |
| 0x4B01-0x53E1 | el pingüino, los choques, la pista y los obstáculos |
| 0x53E1-0x55D9 | las curvas y los siete horizontes |
| 0x55D9-0x5839 | los nombres de las bases, las banderas y los rótulos |
| 0x5839-0x588A | la pantalla de título y la grabación de la demo |
| 0x588A-0x6BE9 | la tipografía y todos los dibujos, comprimidos |
| 0x6BE9-0x7241 | los 92 trozos con los que se montan los obstáculos |
| 0x7241-0x7519 | el árbol de decorados |
| 0x7519-0x78C1 | la meta, el pez, la velocidad y los sprites de fondo |
| 0x78C1-0x79C9 | los fotogramas del bicho de los agujeros |
| 0x79C9-0x7B37 | el reproductor de sonido |
| 0x7B37-0x7EB7 | las notas, las duraciones y los flujos de sonido |
| 0x7EB7-0x8000 | el relleno hasta los 16 KB |
