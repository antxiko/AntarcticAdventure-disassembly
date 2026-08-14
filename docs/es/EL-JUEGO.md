# El juego

Un pingüino cruza la Antártida de base en base. Corre siempre hacia adelante,
tú lo llevas de un lado a otro de la pista y saltas lo que se le pone por
medio, y en cada tramo hay una distancia que recorrer y un reloj que se acaba.
Todo lo que viene aquí sale de leer el código que lo hace.

## El recorrido: diez paradas

La tabla de 0x4AD9 tiene diez entradas de cuatro bytes, y cada una lleva la
distancia del tramo, la casilla del mapa donde empieza y el tiempo que dan
para hacerlo. La tabla acaba exactamente donde vuelve a haber código, que es lo
que fija su tamaño sin tener que suponerlo.

| Fase | Base | Distancia | Tiempo |
|---|---|---|---|
| 1 | FRANCE | 1500 m | 100 s |
| 2 | USA | 1700 m | 120 s |
| 3 | THE SOUTH POLE | 1100 m | 80 s |
| 4 | USA | 1200 m | 80 s |
| 5 | USA | 1200 m | 80 s |
| 6 | ARGENTINA | 500 m | 40 s |
| 7 | UNITED KINGDOM | 2600 m | 165 s |
| 8 | JAPAN | 1200 m | 90 s |
| 9 | AUSTRALIA | 1500 m | 100 s |
| 10 | AUSTRALIA | 1200 m | 90 s |

La sexta es la carrera corta del juego, medio kilómetro, y la séptima la larga:
2600 metros con casi tres minutos por delante. Al pasar la décima el contador
vuelve a empezar, así que el recorrido da la vuelta entero.

Cada parada tiene además su bandera, que se descomprime en los patrones de
sprite justo antes de llegar. Son siete dibujos para diez paradas —el de
Estados Unidos sale tres veces y el de Australia dos— y se emparejan con el
país que toca, incluido el pingüino que hace de bandera en el Polo Sur.

## El tiempo que sobra no se regala

Al llegar a una base, lo que quede de reloj se cambia por puntos, cien por
segundo, con su tic-tic mientras baja. Pero además se guarda: el sobrante de
cada fase se apunta en su casilla y **la próxima vuelta se le descuenta al
tiempo de esa misma fase**, en cuanto pase de diez. Cuanto mejor lo haces, menos
margen te dan la vuelta siguiente.

## El acelerador no está invertido: lo que hay ahí es un periodo

Los mandos son cuatro direcciones y un botón. Izquierda y derecha mueven al
pingüino por la pista, entre las columnas 20 y 204, y el botón salta. Arriba y
abajo gobiernan la velocidad, y hacen lo que uno espera: **arriba acelera y
abajo frena**.

Lo que despista es lo que el juego guarda en 0xE100, que no es la velocidad
sino su **periodo**: cuántos fotogramas pasan entre dos avances. Cuanto más
alto, más se espera y más lento se va. Por eso acelerar es restarle y frenar es
sumarle, y por eso el velocímetro tiene que invertirlo con un `cpl` antes de
pintar la barra. El periodo vive entre 8 —a todo correr— y 19, y cada fase
arranca en 16.

Lo que sí es asimétrico es lo que cuesta cada cosa: ganar un escalón lleva doce
fotogramas y perderlo solo cuatro, así que **se frena tres veces más rápido de
lo que se acelera**.

## Lo que hay por la pista

Hay siete clases de obstáculo, y la tabla que las define reparte a cada una un
puntero a su dibujo y dos ventanas de choque: una posición y una anchura, dos
veces. El choque solo se mira en el paso 13 de los quince que dura la
aproximación, que es cuando el obstáculo está justo a la altura del pingüino.

De los siete, tres son agujeros en el hielo. Si lo pillas por el borde
tropiezas y ruedas; si lo pillas de lleno, te caes dentro y ahí te quedas
manoteando hasta que pulses el botón, mientras el reloj sigue corriendo, que es
el castigo de verdad. Y de esos mismos agujeros sale el pez: cuando uno llega
al paso siete, asoma con su arco propio, y pisarlo vale 300 puntos.

El pez es **un solo sprite** —el atributo 15— y tiene ocho dibujos, cuatro
mirando a cada lado. El dibujo alterna cada dieciséis fotogramas mientras sube,
y al empezar a caer cambia al grande, que es la forma barata de que parezca que
se te acerca.

Saltar por encima de un obstáculo también puntúa, aunque poco: treinta puntos.
Y hay dos clases de obstáculo, las dos últimas, que se recogen en vez de
esquivarse: al tocarlas suenan, se borran del hielo y valen 500.

## El marcador

Las dos primeras filas de la pantalla no son un dibujo: las escribe una sola
cadena que pone cinco rótulos en cinco sitios distintos, y encima van los
números.

    1P  <marcador>     HI  <récord>     STAGE  <fase>
    TIME  <reloj>          <distancia que queda>

Todo va en decimal empaquetado, dos cifras por byte, que es lo que permite
sumarlo con una sola instrucción y escribirlo sin dividir por diez. El marcador
son tres bytes y se clava en 999999 si te pasas; el récord son otros tres, y
son los únicos que sobreviven a un `reinicia partida`, porque el borrón empieza
tres bytes más allá.

## La demo

Si dejas el juego solo, arranca una partida que se juega sola durante 1852
pasos. No hay ninguna inteligencia detrás: los mandos salen de una grabación de
64 bytes que va en el propio cartucho, y el lector coge uno cada 32 fotogramas.

Mientras corre, el bit que dice «hay partida de verdad» está apagado, y eso
tiene una consecuencia bonita: la rutina de sumar puntos se sale por la puerta
de atrás en su segunda instrucción. La demo juega, choca y salta, pero no
puntúa.

## Empezar a jugar

Se pulsa **1** para jugar con joystick o **2** para jugar con teclado. Esa
tecla se mira en cada fotograma, en cualquier pantalla, y la rutina que la
atiende hace algo poco habitual: se come su propia dirección de retorno para no
volver a donde la llamaron, y planta el menú ahí mismo.

Del teclado se usan la fila de las flechas y la barra espaciadora, y el código
las coloca en los mismos bits en los que vienen las del joystick, así que a
partir de ahí el juego ya no sabe cuál de los dos estás usando.
