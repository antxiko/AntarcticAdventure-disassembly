# Hallazgos

Lo que apareció al desmontar el cartucho, con la evidencia al lado. Todo lo de
esta página se comprueba leyendo el binario; lo que todavía no está cerrado
está en [Preguntas abiertas](PREGUNTAS-ABIERTAS.html).

## La demo va grabada

Cuando el juego se queda solo, arranca una partida que juega sola. No hay
ninguna inteligencia detrás: hay 64 bytes en 0x584A que llevan exactamente los
mismos bits que devuelve el joystick, y el lector de mandos coge uno cada 32
fotogramas. Entre byte y byte se repite la dirección anterior, así que la
grabación va a un ritmo muy lento y aun así basta.

Se ve en los propios bytes: `01` es arriba, `09` arriba y derecha, `11` arriba
y botón. Ni un valor sale del mapa de bits del mando.

Y encaja hasta en la duración. La demo dura 0x073C pasos, que a un byte cada
32 son 58 bytes de los 64 que hay. La tira acaba exactamente donde empieza la
primera instrucción de la rutina siguiente.

## Lo primero que hace el cartucho es escribir sobre sí mismo

Entre inicializar la máquina y arrancar el juego hay estas cuatro
instrucciones:

```asm
    ld hl,0411fh      ; origen: tres bytes que son C3 00 00, o sea jp 0000h
    ld de,DESPACHA    ; destino: 0x40B2, el despachador de todo el juego
    ld bc,00003h
    ldir
```

En un cartucho eso no hace absolutamente nada, porque esa mitad del mapa de
memoria es ROM y la escritura se pierde por el camino. Pero si el cartucho
estuviera copiado en RAM, el despachador quedaría convertido en un salto a cero
y la máquina se reiniciaría en el primer fotograma, porque el bucle de juego lo
llama nada más empezar.

Que hace eso está comprobado leyendo los bytes. Para qué lo hace no se puede
demostrar desde el binario, y lo más razonable es que sea una protección contra
copias en memoria; pero eso es una lectura, no un hecho.

## Hay una base a la que no se llega nunca

El cartucho lleva ocho nombres de base y el recorrido tiene diez paradas. Siete
de esos nombres cubren las diez —Estados Unidos sale tres veces y Australia
dos— y el octavo, **NEW ZEALAND**, no lo pide nadie.

Comprobado por tres caminos distintos, porque una sola comprobación aquí no
basta:

- no está entre las diez entradas de la tabla de nombres;
- ninguna instrucción lo apunta, recorriendo solo inicios de instrucción;
- y ninguna de las veinte direcciones de esa cadena aparece como palabra en
  los 16 KB del cartucho.

Las otras siete sí aparecen apuntadas, así que el control funciona y el cero de
NEW ZEALAND significa algo.

## La foca sale del agujero en ocho pasos

De tres de los siete obstáculos —los agujeros— sale una foca, y está entera en
el cartucho: ocho fotogramas, uno por cada paso del 7 al 14, con la tabla en
0x78C1. El índice de esa tabla es fácil de leer al revés, y el error es
convincente: parece el tipo de obstáculo y es **el paso en que va**. Leída de
la otra manera salen punteros que se van fuera del cartucho; leída bien salen
ocho seguidos, y el último acaba justo en el fotograma que la esconde, que a su
vez acaba donde vuelve a haber código.

Los tres primeros pasos son de dos sprites y los cinco siguientes de cuatro, y
cada fotograma lleva tres variantes. Pero las tres llevan el mismo dibujo: lo
único que cambia es la X, porque una foca sale por el centro, otra se va hacia
la derecha y otra hacia la izquierda. Y del paso 10 al 14 pasa lo mismo con la
otra coordenada —los cuatro dibujos son siempre los mismos y lo que baja es la
Y—, así que la foca no se deforma al acercarse: solo cambia de sitio.

Y el color no está ahí. La rutina que la monta copia tres bytes de cada sprite
—posición y dibujo— y **se salta el cuarto**, que es justo el del color: ese lo
dejó puesto la lista de atributos, que le da el primer sprite en negro y los
otros tres en rojo oscuro. Como en un MSX el sprite de número más bajo va
delante, el negro queda encima y lo que se ve es una foca marrón con la cara
oscura.

## El alfabeto no tiene F

La tipografía va colocada de forma que el número de casilla es su ASCII menos
0x20, así que la A es la 0x21, la B la 0x22 y así. Con esa cuenta, la F
tendría que estar en la 0x26.

No está: en esa casilla hay otro dibujo, en los tres tercios de la pantalla. Y
la única palabra de todo el juego que necesita una F —**FRANCE**, la primera
base del recorrido— se la lleva puesta: su cadena no usa la 0x26 sino la 0xC9,
que es una F suelta guardada aparte, lejos del alfabeto.

## La mitad de hablar con la pantalla viene sin estrenar

Las rutinas que tratan con el chip gráfico van por parejas: una para escribir y
su gemela exacta para leer. Las dos de escribir se usan a todas horas, diez y
seis veces respectivamente.

Las dos de leer no las llama nadie. Y se puede decir sin rodeos porque la
dirección de una de ellas **no aparece ni una sola vez en los 16 KB**, y la
única aparición de la otra es la llamada que le hace su propia gemela muerta.

Este juego no lee la pantalla nunca. Solo escribe.

## Queda el rastro de un modo de dos jugadores

Hay una rutina que escribe una cadena y detrás un `1` o un `2`, sacado del bit
7 de la palabra de banderas. Nadie la llama —su dirección no aparece en el
cartucho— y además ese bit no lo enciende nadie, porque los dos únicos valores
que se escriben ahí son 0x40 y 0x50.

A juego con eso, el rótulo del marcador dice **1P** fijo, escrito en la cadena
de los rótulos como una constante más.

## Las tablas se delatan solas

Saber dónde acaba una tabla suele ser lo peor de un desensamblado, porque el
tamaño no está escrito en ninguna parte y equivocarse no da ningún error.

En este cartucho casi todas lo dicen. La última palabra de la tabla acaba
exactamente en el byte donde empieza su primer destino, así que solo hay un
tamaño posible: se prueba con N entradas y solo una N cierra. Funciona con las
seis tablas de salto, con las diez fases, con las diez banderas, con los siete
horizontes, con los veinticuatro sonidos y con los cinco tramos de la meta.

Y hay un segundo truco de la casa, este para ahorrar instrucciones: **tres
tablas se apuntan un byte antes de donde empiezan**, porque su índice nunca
vale cero y así se evitan un `dec a`. El byte cero de una de ellas es el último
byte de un `jp`; el de otra, un `ret` suelto que hace de dato sin dejar de ser
un `ret`.

## Los siete obstáculos embaldosan su zona sin dejar un byte

Entre 0x6BE9 y 0x7241 hay 92 trozos de dibujo, y la única pista de para qué son
es que los siete punteros de la tabla de obstáculos caen ahí dentro.

Encadenando los quince pasos que dura cada obstáculo, sale esto:

    tipo 3   6BE9 -> 6D85      tipo 2   7091 -> 7150
    tipo 4   6D85 -> 6F19      tipo 6   7150 -> 71C8
    tipo 0   6F19 -> 6FD2      tipo 5   71C8 -> 7241
    tipo 1   6FD2 -> 7091

Cada cadena acaba justo donde empieza la siguiente, y la última acaba justo en
el final de la zona. Los siete se reparten los 92 trozos sin que sobre ni falte
nada, y de paso queda confirmado que los pasos son quince y que el
encadenamiento se lee bien.

Un detalle bonito de ahí: los siete punteros apuntan a un bloque **vacío**. No
es un error de lectura, es que el primer paso de un obstáculo no dibuja nada
porque todavía está detrás del horizonte, y dos de los siete llevan dos pasos
vacíos.

## Arriba frena y abajo acelera

La tabla que gobierna la velocidad tiene cuatro destinos, uno por cada
combinación de arriba y abajo. Sin tocar nada no pasa nada, con las dos a la
vez tampoco, y las otras dos van al revés de lo que uno esperaría: **arriba
baja la velocidad y abajo la sube**.

Además no cuestan igual. Cada escalón de aceleración tarda cuatro fotogramas y
cada escalón de frenada tarda doce, así que el pingüino coge carrera tres veces
más rápido de lo que la suelta.

## Las dos tablas de doce que no son lo mismo

Junto al reproductor de sonido hay dos tablas de doce bytes, pegadas la una a
la otra. La primera es una octava cromática, y se nota: los doce periodos
caen a 0,09 semitonos del temperamento igual.

La segunda invita a leerse igual, y no lo es. Medida como si fuera una escala
da 15,8 semitonos, que no es ninguna escala de nada. Lo que es se ve en el
código que la usa: el nibble alto de cada nota la indexa para sacar **cuánto
dura**. Son duraciones, y van de 5 a 100 fotogramas.

## El silencio es un flujo que se acaba en el primer byte

De los veinticuatro punteros de sonido, el primero apunta fuera del cartucho.
No es un error: el sonido cero no se pide nunca, así que esa entrada no se lee
jamás.

Y los tres últimos apuntan todos al mismo byte, que es un `0xFF`, o sea el
final de un flujo. Ese es el silencio, y es lo que pide el arranque para dejar
el chip callado antes de empezar.
