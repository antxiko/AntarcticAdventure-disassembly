# El código

## Todo pasa dentro de la interrupción

El programa principal de este juego son dos bytes: un salto a sí mismo. Lo de
verdad ocurre en el gancho del temporizador, que la BIOS llama en cada
retrazado de pantalla, y que hace tres cosas en este orden: atiende el sonido,
mueve al pingüino y el reloj, y da **un paso** de la máquina de estados.

Ese tercer paso puede durar más de un fotograma, así que va protegido por un
cerrojo. Si la vuelta anterior sigue trabajando, esta se salta el paso entero y
se va por la puerta de al lado, en vez de reentrar. El fotograma se pierde y no
pasa nada.

## La máquina de estados

Un byte dice en qué estado está el juego —de 0 a 15— y otro en qué paso dentro
de ese estado. En cada fotograma se ejecuta el paso que toque y ya está. Los
dieciséis destinos son:

| | | | |
|---|---|---|---|
| 0 | parado | 8 | el menú de mando |
| 1 | arranca la presentación | 9 | prepara la fase |
| 2 | sube el logotipo | 10 | entra en la fase |
| 3 | espera | 11 | **la partida** |
| 4 | dibuja el rótulo | 12 | se acabó el tiempo |
| 5 | espera | 13 | fin de partida |
| 6 | cortinilla | 14 | la meta |
| 7 | la demo | 15 | el mapa de la Antártida |

Y el camino normal es: presentación, demo, menú, preparar, mapa, entrar, jugar,
meta, y vuelta a preparar la siguiente. Si se acaba el reloj, en cambio, se sale
por el 12 y el 13 y se vuelve a la demo.

Lo que hace que esto se lea bien son seis rutinas encadenadas que sirven de
salida. Cada una hace lo suyo y **cae en la siguiente**, de más a menos: las
tres de arriba pasan al estado siguiente y ponen el paso a cero, las tres de
abajo solo pasan al paso siguiente, y las que llevan espera dejan puesto un
contador antes de caer. Con eso, casi todos los pasos del juego terminan en un
salto de tres letras.

## El despachador, con la tabla metida detrás del CALL

El corazón de todo esto son diez bytes:

```asm
DESPACHA:
    add a,a           ; el índice, por dos
    pop hl            ; ...y esto NO es un dato de la pila
    call SUMA_A_HL
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    jp (hl)
```

El `pop hl` no recoge nada que nadie haya empujado: recoge **la dirección de
retorno**, que es justo el byte siguiente al `call`. Y ahí es donde está la
tabla. O sea que quien llama escribe la tabla pegada detrás de la llamada, y el
despachador la encuentra sin que nadie se la pase.

Es elegante y tiene un efecto lateral incómodo: un trazador que siga el flujo se
mete de cabeza en la tabla y lee punteros como si fueran instrucciones. Por eso
las seis tablas de este cartucho están declaradas a mano.

Lo bueno es que se delimitan solas. La última palabra de cada tabla acaba
**exactamente** en el byte donde empieza su primer destino, así que solo hay un
tamaño posible: se prueba con N entradas y solo una N cierra. Las seis cierran,
y entre todas dan 42 destinos.

Hay además un segundo despachador que funciona de otra manera. En vez de
indexar direcciones, indexa **código**: cuatro trozos de exactamente cuatro
bytes, colocados para que el índice caiga clavado en uno de ellos. Sirve para
los cuatro movimientos con los que se traza el recorrido en el mapa.

## Los mandos, y tres sitios de donde salen

Lo que se está pulsando acaba siempre en el mismo byte, con el mismo formato:
cuatro direcciones y dos botones. Pero puede venir de tres sitios distintos, y
lo decide un solo byte de banderas: del joystick por el chip de sonido, del
teclado leyendo dos filas de la matriz y recolocando los bits, o **de una
grabación que va dentro del cartucho**, que es lo que mueve la demo.

Como las tres fuentes acaban en el mismo sitio y con la misma forma, el resto
del juego no tiene ni idea de cuál de ellas está usando.

## El pingüino son cuatro sprites

Un sprite de este MSX es de 16x16, así que el pingüino se monta con cuatro
puestos en cuadro: 32x32 píxeles. Solo se lleva la cuenta de la posición del
primero, y las otras tres salen de sumarle dieciséis a lo alto, a lo ancho o a
las dos cosas.

Las posturas viven en una tabla de diez, cuatro bytes cada una, que son los
cuatro dibujos que le tocan a cada sprite. Cambiar de postura es copiar cuatro
bytes salteados.

Andar son tres posturas que rotan cada ocho fotogramas. Saltar son once pasos,
uno cada cuatro, con una curva de doce correcciones que sube al pingüino cuatro
píxeles y lo vuelve a bajar; y si el botón se pulsó con una dirección metida,
además se mueve al doble de velocidad hacia ese lado. Caerse son veintiún pasos
con su propia curva y su propia tabla de rodadas.

## Los obstáculos son fichas de seis bytes

Hay sitio para cuatro obstáculos a la vez, y para cinco a partir de la quinta
fase. Cada uno ocupa una ficha:

| | |
|---|---|
| +0 | en qué paso va, de 1 a 15; con 0 la ficha está libre |
| +1 | el tipo, de 0 a 6 |
| +2 | puntero al trozo de dibujo que toca ahora |
| +4 | puntero a los cuatro bytes con los que se mira el choque |

Y lo interesante es el puntero de dibujo, porque **avanza solo**. Los 92 trozos
que hay entre 0x6BE9 y 0x7241 no son pantallas: cada uno pone entre una y seis
casillas, o sea que son incrementos. La ficha ejecuta el trozo que le toca,
guarda por dónde se quedó, y en el paso siguiente sigue por ahí. Acumulados, lo
que se ve es el obstáculo acercándose.

Que esa es exactamente la lectura buena se comprueba solo: si se encadenan los
quince pasos de los siete tipos, las siete cadenas **embaldosan la zona entera
sin dejar ni un byte suelto**, y cada una acaba justo donde empieza la
siguiente.

## Dibujar es ejecutar

Los decorados de los bordes y los trozos de pista están escritos en un pequeño
lenguaje, y hay un intérprete de 45 bytes que lo ejecuta. Un byte dice en qué
columna y en qué tercio se empieza, y luego, por cada fila, un desplazamiento
y las casillas que se escriben seguidas; un byte alto cierra la fila y abre la
siguiente, y un cero cierra el bloque.

Con eso, los decorados de los lados salen de un árbol de dos niveles —cuatro
grupos de cuatro— y los dieciséis bloques que cuelgan de él embaldosan su zona
sin dejar hueco.

## La pista se mueve sin mover un solo píxel

La fila del horizonte no se dibuja directamente en la pantalla. Se compone en
memoria: 32 casillas, con dos bytes delante que dicen a qué sitio de la
pantalla van y un byte detrás que cierra. Cuando la pista tiene que torcerse,
lo que se hace es **rotar esa fila** con una sola instrucción de copia en
bloque, hacia un lado o hacia el otro, y volver a mandarla.

La curva que toca en cada momento sale de una tabla de nibbles, dos curvas por
byte, y hay siete dibujos de horizonte distintos —recto, torcido a un lado,
torcido al otro, y los cuatro de la llegada a la base— que se eligen con un
índice.

## El sonido: el número es la prioridad

Tres canales, uno por voz del chip, con diez bytes de estado cada uno. Para
pedir un sonido se le pasa un número, y ese número hace dos cosas a la vez:
dice qué flujo suena y **cuánto manda**. Si lo que ya está sonando tiene un
número mayor, la petición se cae ahí mismo sin hacer nada.

Y el número dice además cuántos canales se lleva: por debajo de 0x8A uno solo,
hasta 0x8C dos, y de ahí para arriba los tres. Los efectos son de un canal y la
música de tres, así que un efecto nunca corta una melodía por la mitad.

Cada nota es **un byte**: el nibble bajo es la nota dentro de una octava
cromática de doce, y el nibble alto es la duración, que se busca en otra tabla
de doce que está pegada a la primera. Las dos tienen doce entradas y están una
al lado de la otra, lo cual invita a leerlas como si fueran lo mismo; no lo
son. Subir de octava es doblar el periodo tantas veces como haga falta, y hay
un byte de control para cambiarla, otro para repetir un trozo y otro para
acabar.

De los veinticuatro punteros de flujo, uno apunta fuera del cartucho —el del
sonido cero, que no se pide nunca— y tres apuntan al mismo sitio: a un byte de
fin. Ese es el silencio, y es lo que el arranque pide para dejar el chip
callado.
