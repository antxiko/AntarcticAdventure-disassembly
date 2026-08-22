; ==========================================================================
; ANTARCTIC ADVENTURE - Konami (1984) - MSX1 - cartucho de 16 KB - version europea
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x04000


; ----------------------------------------------------------------------
; DATOS cabecera_del_cartucho: La cabecera que lee la BIOS: "AB", INIT=0x4010,
;   y a cero los otros tres vectores (STATEMENT, DEVICE y TEXT). Con eso la
;   BIOS llama a 0x4010 nada mas terminar de arrancar la maquina
;   0x4000..0x4010  (16 bytes)
DATA_cabecera_del_cartucho:
	defb 041h,042h	; 4000
	defw 04010h,00000h,00000h,00000h	; 4002  -> INIT 0x0000 0x0000 0x0000
	defb 000h,000h,000h,000h,000h,000h	; 400a

; ======================================================================
; CODIGO 0x4010..0x4119  (265 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; INIT - lo primero que se ejecuta del cartucho
; ############################################################
; La BIOS llega aqui con la maquina ya inicializada. Este INIT
; no vuelve nunca: se queda dando vueltas en 0x4042 y a partir
; de ahi TODO el juego corre dentro de la interrupcion.
; ----------------------------------------------------------------------
INIT:		; Punto de entrada del cartucho, declarado en la cabecera
	di			;4010   ; 0xFD9A: el gancho de interrupcion de la BIOS, tres bytes (un `jp`)
	im 1		;4011
	ld a,0c3h		;4013   ; el 0xC3 es el opcode de `jp`: el gancho de la BIOS son tres bytes y hay que escribir el salto entero a mano
	ld (0fd9ah),a		;4015   ; La pila justo debajo de las variables, que empiezan en 0xE000
	ld hl,H_TIMI		;4018   ; Los 2 KB de variables (0xE000-0xE7FF) a cero de un `ldir`
	ld (0fd9bh),hl		;401b
	ld sp,0e400h		;401e   ; la pila arranca en 0xE400, justo por encima de las variables
	ld hl,0e000h		;4021
	ld de,0e001h		;4024
	ld bc,007ffh		;4027   ; El cerrojo puesto ANTES de arrancar la maquina: si entra una interrupcion mientras se monta todo, se va por la salida corta
	ld (hl),000h		;402a
	ldir		;402c
	ld a,001h		;402e   ; Y quitado despues, con el estado ya en 1
	ld (0e005h),a		;4030
	call ARRANCA_MAQUINA		;4033   ; y con el cerrojo puesto se monta la maquina: VDP, sonido y tablas
	di			;4036
	xor a			;4037   ; La lectura del puerto 0x99 limpia la peticion de interrupcion pendiente del VDP
	ld (0e005h),a		;4038
	inc a			;403b
	ld (0e000h),a		;403c   ; 0xE000 es el estado del juego; el 1 es el titulo
	in a,(099h)		;403f
	ei			;4041
PARADO:		; El bucle vacio de dos bytes en el que se queda el arranque: de aqui en adelante el juego entero corre dentro de la interrupcion
	jr PARADO		;4042

; ----------------------------------------------------------------------
; ############################################################
; H.TIMI - el gancho de interrupcion
; ############################################################
; La BIOS salta aqui en cada retrazado. Lo que hace, en orden:
; 1. atiende el sonido (siempre que el estado no sea 0)
; 2. si el estado es menor que 12, mueve al pinguino y el reloj
; 3. lee los mandos y da UN PASO de la maquina de estados
; El paso 3 va protegido por un cerrojo (0xE005): si la vuelta
; anterior aun no ha terminado, esta se salta el paso entero en
; vez de reentrar.
; ----------------------------------------------------------------------
H_TIMI:		; Rutina de interrupcion; INIT la engancha en 0xFD9A
	push af			;4044   ; el gancho H_TIMI guarda los cuatro pares que va a tocar y los devuelve al salir
	push bc			;4045
	push de			;4046
	push hl			;4047
	di			;4048
	in a,(099h)		;4049   ; El `in` del 0x99 acusa recibo de la interrupcion del VDP y deja leer su registro de estado
	ld a,(0e000h)		;404b   ; Con el estado en 0 (antes de arrancar) no suena nada
	or a			;404e
	jr z,HTIMI_MIRA_ESTADO		;404f
	call SUENA_UN_PASO		;4051   ; el sonido va en TODOS los fotogramas, pase lo que pase con la logica
HTIMI_MIRA_ESTADO:		; Por debajo del estado 12 no se mueve nada de lo de abajo
	ld a,(0e000h)		;4054
	cp 00ch		;4057   ; Del estado 12 para arriba ya no hay partida: ni pinguino ni reloj
	jr nc,HTIMI_SIGUE		;4059
	ld a,(0e140h)		;405b   ; 0xE140 (en el agua) mas 0xE142 (cayendose): con cualquiera de los dos no se anima el andar
	ld hl,0e142h		;405e
	add a,(hl)			;4061
	jr nz,HTIMI_LATERAL		;4062
	call ANIMA_ANDAR		;4064
HTIMI_LATERAL:		; Cuenta el tiempo y mira el signo del desplazamiento lateral
	call CUENTA_EL_TIEMPO		;4067   ; y de paso baja el reloj de la fase
	ld a,(0e081h)		;406a   ; El bit 7 de 0xE081 es el signo del desplazamiento lateral...
	bit 7,a		;406d
	ld a,000h		;406f   ; ...que queda en 0xE0FC como 0 o 1
	jr z,HTIMI_GUARDA_LATERAL		;4071
	inc a			;4073
HTIMI_GUARDA_LATERAL:		; Guarda el lateral ya con signo en 0xE0FC
	ld (0e0fch),a		;4074
HTIMI_SIGUE:		; El resto de la interrupcion, que corre en todos los estados
	ld hl,0e005h		;4077
	bit 0,(hl)		;407a   ; Bit 0 de 0xE005: la vuelta anterior sigue trabajando y esta se salta el paso entero
	jr nz,HTIMI_SALE		;407c
	ld (hl),001h		;407e   ; Echa el cerrojo y ABRE las interrupciones: el paso puede durar mas de un fotograma
	ei			;4080
	call LEE_MANDOS		;4081   ; primero los mandos y luego el paso de juego, en ese orden
	call PASO_DE_JUEGO		;4084
	di			;4087
	pop hl			;4088   ; se devuelven los registros con las interrupciones cerradas y se suelta el cerrojo al final
	pop de			;4089   ; Suelta el cerrojo con las interrupciones ya paradas
	pop bc			;408a
	xor a			;408b
	ld (0e005h),a		;408c
	pop af			;408f
	ei			;4090
	ret			;4091
HTIMI_SALE:		; Saca los registros de la pila y vuelve
	pop hl			;4092   ; Los mismos cuatro registros que metio H_TIMI, sin haber tocado nada
	pop de			;4093
	pop bc			;4094
	pop af			;4095
	ei			;4096
	ret			;4097

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; EL DESPACHADOR, con la tabla incrustada detras del CALL
; ----------------------------------------------------------------------
; Se llama con el indice en A. El POP HL no recoge un dato de la
; pila: recoge la DIRECCION DE RETORNO, que es justo donde
; empieza la tabla, porque la tabla va pegada detras del CALL.
; Suma el indice por dos, lee la palabra y salta. Nunca vuelve.
; Lo llaman seis sitios, y cada tabla acaba EXACTAMENTE donde
; empieza su primer destino: eso es lo que fija su tamano sin
; tener que suponerlo.
; ----------------------------------------------------------------------
DESPACHA:		; Salta al destino A de la tabla que va detras del CALL
	add a,a			;4098   ; el indice por dos, que la tabla es de palabras
	pop hl			;4099   ; La direccion de retorno es la tabla
	call SUMA_A_HL		;409a
	ld e,(hl)			;409d   ; la palabra apuntada es el destino, y el `jp (hl)` salta sin volver aqui
	inc hl			;409e
	ld d,(hl)			;409f
	ex de,hl			;40a0
	jp (hl)			;40a1

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LOS MANDOS
; ----------------------------------------------------------------------
; Tres fuentes distintas segun 0xE002:
; bit 6 a 0  -> no hay partida: los mandos se leen de una
; GRABACION que va en la propia ROM (la demo)
; bit 4 a 1  -> teclado, leyendo la matriz
; bit 4 a 0  -> joystick, por el registro 14 del PSG
; Las tres acaban en 0x40BC, que guarda la lectura de este
; fotograma en 0xE009 y la del anterior en 0xE008.
; ----------------------------------------------------------------------
LEE_MANDOS:		; Deja en 0xE009 lo pulsado ahora y en 0xE008 lo de antes
	ld a,(0e000h)		;40a2   ; antes del estado 7 no hay nada que leer: no se juega
	cp 007h		;40a5   ; Antes del estado 7 (la demo) no se lee nada
	ret c			;40a7
	ld a,(0e002h)		;40a8
	bit 6,a		;40ab   ; Bit 6 de 0xE002: sin partida, los mandos salen de la grabacion de la demo
	jr z,LEE_MANDOS_GRABADOS		;40ad   ; Bit 4: teclado o joystick
	bit 4,a		;40af
	jr nz,LEE_TECLADO		;40b1   ; Registro 14 del PSG por el puerto de datos, sin pasar por la BIOS
	ld a,00eh		;40b3   ; el registro 14 del PSG es el puerto del joystick, y se lee por el 0xA2 sin pasar por la BIOS
	out (0a0h),a		;40b5   ; El `cpl` endereza la logica negativa: bits 0-3 direcciones, 4 y 5 gatillos
	in a,(0a2h)		;40b7
	cpl			;40b9
	and 03fh		;40ba   ; seis bits: cuatro direcciones y dos gatillos
GUARDA_MANDOS:		; 0xE009 = ahora, 0xE008 = el fotograma anterior
	ld hl,0e009h		;40bc
	ld c,(hl)			;40bf   ; C hace de tercera mano: lo de 0xE009 baja a 0xE008 sin tocar A
	ld (hl),a			;40c0
	dec hl			;40c1
	ld (hl),c			;40c2
	ret			;40c3
LEE_TECLADO:		; Monta con la matriz del teclado el mismo mapa de bits que trae el joystick, hablandole al PPI a pelo
	ld bc,057aah		;40c4   ; 0x57 en B: fila 7 con el motor de cinta y el CAPS apagados; 0xAA es el puerto del PPI
	out (c),b		;40c7   ; Se escribe dos veces: el PPI necesita que la fila se asiente antes de leerla
	out (c),b		;40c9
	in a,(0a9h)		;40cb   ; el puerto 0xA9 devuelve los ocho bits de la fila seleccionada
	cpl			;40cd
	rrca			;40ce   ; El `cpl` y la rotacion suben la tecla al bit 5: el segundo gatillo
	and 020h		;40cf
	ld e,a			;40d1
	inc b			;40d2   ; Fila 8: el resto de flechas y la barra espaciadora
	out (c),b		;40d3
	out (c),b		;40d5
	in a,(0a9h)		;40d7
	cpl			;40d9
	rrca			;40da
	rrca			;40db
	ld b,a			;40dc   ; Tres tandas de rotaciones recolocan la fila 8 en el mapa del joystick: derecha al bit 2, espacio y arriba al 3 y al 4, y las dos ultimas al 0 y al 1
	and 004h		;40dd   ; las tres tandas de rotaciones dejan el teclado con la MISMA forma que el joystick, y asi el resto del juego no tiene que saber de donde vino
	or e			;40df
	ld c,a			;40e0
	ld a,b			;40e1
	rrca			;40e2
	rrca			;40e3
	ld b,a			;40e4
	and 018h		;40e5
	or c			;40e7
	ld c,a			;40e8
	ld a,b			;40e9
	rrca			;40ea
	and 003h		;40eb
	or c			;40ed
	jr GUARDA_MANDOS		;40ee
LEE_MANDOS_GRABADOS:		; En la demo los mandos no se leen: salen de la grabacion de 64 bytes
	ld de,(0e0ech)		;40f0   ; la demo no lee el mando: lee una grabacion
	ld hl,0e0ebh		;40f4   ; 0xE0EB cuenta los fotogramas y 0xE0EC apunta dentro de la grabacion
	inc (hl)			;40f7
	ld a,(hl)			;40f8
	and 01fh		;40f9   ; Un byte nuevo cada 32 fotogramas; entre medias se repite lo de antes
	jr nz,MANDOS_SOLO_DIRECCIONES		;40fb
	ld a,(de)			;40fd
	inc de			;40fe
	ld (0e0ech),de		;40ff
	jr GUARDA_MANDOS		;4103
MANDOS_SOLO_DIRECCIONES:		; Se queda con las cuatro direcciones y tira los gatillos
	ld a,(0e009h)		;4105   ; y aqui se conservan solo las direcciones, sin los gatillos
	and 00fh		;4108
	jr GUARDA_MANDOS		;410a
PASO_DE_JUEGO:		; Un paso de la maquina de estados: cuenta el fotograma en 0xE003 y despacha por 0xE000
	ld hl,0e003h		;410c   ; 0xE003 es el contador de fotogramas del que cuelgan los parpadeos
	inc (hl)			;410f
	call MIRA_TECLAS_1_2		;4110
	ld a,(0e000h)		;4113   ; el estado (0xE000) elige la rutina de la tabla
	call DESPACHA		;4116

; ----------------------------------------------------------------------
; DATOS tabla_de_estados: Los 16 destinos del CALL de 0x4116. Cierra clavada
;   contra su primer destino. Es la maquina de estados: la indexa 0xE000.
;   0x4119..0x4139  (32 bytes)
DATA_tabla_de_estados:
	defw 04139h	; 4119  -> ESTADO_00_PARADO
	defw 0413ah	; 411b  -> ESTADO_01_ARRANCA
	defw 0414bh	; 411d  -> ESTADO_02_LOGO
	defw 0415dh	; 411f  -> ESTADO_03_ESPERA
	defw 04168h	; 4121  -> ESTADO_04_ROTULO
	defw 04176h	; 4123  -> ESTADO_05_ESPERA
	defw 0417fh	; 4125  -> ESTADO_06_CORTINILLA
	defw 04186h	; 4127  -> ESTADO_07_DEMO
	defw 041d5h	; 4129  -> ESTADO_08_MENU
	defw 04241h	; 412b  -> ESTADO_09_PREPARA
	defw 04283h	; 412d  -> ESTADO_10_ENTRA
	defw 0429ch	; 412f  -> ESTADO_11_PARTIDA
	defw 042c2h	; 4131  -> ESTADO_12_TIME_OUT
	defw 042e7h	; 4133  -> ESTADO_13_FIN
	defw 042f8h	; 4135  -> ESTADO_14_META
	defw 048d9h	; 4137  -> ESTADO_15_MAPA

; ======================================================================
; CODIGO 0x4139..0x418c  (83 bytes)
; ======================================================================


ESTADO_00_PARADO:		; Estado 0: no hace nada. Es el que deja INIT hasta que se pone el 1
	ret			;4139
ESTADO_01_ARRANCA:		; Estado 1: prepara la pantalla de presentacion
	call MONTA_LA_FUENTE		;413a   ; Estado 1: el titulo, con la cortinilla ya montada
	ld a,011h		;413d   ; 0x11 fotogramas de espera para el paso siguiente
	ld (0e00ah),a		;413f
	ld hl,00000h		;4142
	ld (0e00eh),hl		;4145
	jp SIGUIENTE_ESTADO		;4148
ESTADO_02_LOGO:		; Estado 2: sube el logotipo una fila cada dos fotogramas, y al llegar descomprime la pantalla de titulo
	ld a,(0e003h)		;414b   ; el logo sube un fotograma si y otro no: la mitad de velocidad
	rra			;414e   ; Un fotograma si y otro no
	ret nc			;414f
	call SUBE_LOGO		;4150
	ret nz			;4153
	ld hl,05802h		;4154   ; Los datos comprimidos de la pantalla de titulo
	call ESCRIBE_CADENA		;4157   ; la pantalla de titulo va comprimida y se escribe con la misma rutina que los rotulos
	jp ESPERA_80_Y_ESTADO		;415a
ESTADO_03_ESPERA:		; Estado 3: espera a que 0xE004 llegue a cero y prepara el rotulo
	ld hl,0e004h		;415d
	dec (hl)			;4160
	ret nz			;4161
	call PREPARA_ROTULO		;4162   ; el rotulo se prepara antes de dibujarlo, que va letra a letra
	jp ESPERA_A_Y_ESTADO		;4165
ESTADO_04_ROTULO:		; Estado 4: dibuja el rotulo columna a columna; mientras dibuja, vuelve con acarreo
	call DIBUJA_ROTULO		;4168   ; mientras DIBUJA_ROTULO devuelva acarreo, sigue escribiendo
	ret c			;416b
	ld hl,057b7h		;416c   ; "PLAY SELECT", "1 JOYSTICK" y "2 KEYBOARD"
	call ESCRIBE_CADENA		;416f
	xor a			;4172
	jp ESPERA_A_Y_ESTADO		;4173
ESTADO_05_ESPERA:		; Estado 5: en ESTA version es un RET pelado, o sea que la pantalla de titulo se queda quieta y NO SE PASA NUNCA A LA DEMO
	ret			;4176
CUENTA_PARA_LA_DEMO:		; La cuenta atras que en las versiones japonesas dispara la demo. Aqui esta entera y NO LA ALCANZA NADIE, porque el estado 5 vuelve un byte antes
	ld hl,0e004h		;4177   ; una espera mas antes de la cortinilla
	dec (hl)			;417a
	ret nz			;417b
	jp ESPERA_80_Y_ESTADO		;417c
ESTADO_06_CORTINILLA:		; Estado 6: borra la pantalla por columnas; sale cuando la cortinilla vuelve negativa
	call CORTINILLA		;417f   ; la cortinilla devuelve el signo: mientras sea negativo, sigue
	ret p			;4182
	jp SIGUIENTE_ESTADO		;4183

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; ESTADO 7 - LA DEMO
; ----------------------------------------------------------------------
; Juega una partida entera con los mandos grabados de 0x5818 y
; sin sumar puntos (0x4614 se sale si el bit 6 de 0xE002 esta a
; cero). Dura 0x073C = 1852 pasos, y al acabar vuelve al titulo.
; ----------------------------------------------------------------------
ESTADO_07_DEMO:		; Estado 7: la partida de demostracion, en tres pasos
	ld a,(0e001h)		;4186   ; 0xE001 es el paso dentro del estado, y tiene su propia tabla
	call DESPACHA		;4189

; ----------------------------------------------------------------------
; DATOS tabla_demo: Los 3 destinos del CALL de 0x4189. Cierra clavada contra
;   su primer destino. Son los pasos del estado 7, la partida de demostracion.
;   0x418c..0x4192  (6 bytes)
DATA_tabla_demo:
	defw 04192h	; 418c  -> DEMO_0_ARRANCA
	defw 041a9h	; 418e  -> DEMO_1_CORRE
	defw 041cah	; 4190  -> DEMO_2_SALE

; ======================================================================
; CODIGO 0x4192..0x41db  (73 bytes)
; ======================================================================


DEMO_0_ARRANCA:		; Paso 0: pone a cero la partida y arranca la grabacion
	call REINICIA_PARTIDA		;4192   ; la demo empieza como una partida: se reinicia todo igual
	ld hl,0e002h		;4195
	res 6,(hl)		;4198   ; Bit 6 a cero: no hay partida de verdad, asi que no se puntua
	ld hl,0073ch		;419a   ; 1852 pasos de demostracion
	ld (0e0eeh),hl		;419d
	ld hl,05818h		;41a0   ; Aqui empieza la tira de mandos grabados
	ld (0e0ech),hl		;41a3
	jp ESTADO_09_PREPARA		;41a6   ; Y a partir de aqui, como una fase normal
DEMO_1_CORRE:		; Paso 1: mientras corre la demo, escribe el aviso y descuenta
	ld hl,057abh		;41a9   ; El texto de 0x57A9 pero en otro sitio: aqui empieza el cuerpo, sin la palabra de destino
	ld de,038cbh		;41ac
	call ESCRIBE_CADENA_EN_DE		;41af
	ld a,001h		;41b2
	ld (0e133h),a		;41b4   ; 0xE133: el reloj de la fase corre
	call PASO_DE_PARTIDA		;41b7   ; Un paso de partida
	ld hl,(0e0eeh)		;41ba
	dec hl			;41bd   ; un paso menos de los 1852
	ld (0e0eeh),hl		;41be
	ld a,h			;41c1
	or l			;41c2
	ret nz			;41c3
	ld (0e133h),a		;41c4   ; al agotarse se para el reloj y se pasa de estado
	jp ESPERA_80_Y_PASO		;41c7
DEMO_2_SALE:		; Paso 2: cortinilla, y vuelta al estado 0
	call CORTINILLA		;41ca
	ret p			;41cd
	xor a			;41ce   ; el estado vuelve a 0: la demo termina donde empezo
	ld (0e000h),a		;41cf
	jp SIGUIENTE_ESTADO		;41d2

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; ESTADO 8 - EL MENU
; ----------------------------------------------------------------------
; Pinta "PLAY SELECT" con las dos opciones y hace parpadear seis
; veces la que se ha elegido con la tecla 1 o la 2. Quien elige
; de verdad es 0x4416, que corre en cada fotograma.
; ----------------------------------------------------------------------
ESTADO_08_MENU:		; Estado 8: el menu de eleccion de mando, en cuatro pasos
	ld a,(0e001h)		;41d5
	call DESPACHA		;41d8

; ----------------------------------------------------------------------
; DATOS tabla_menu: Los 4 destinos del CALL de 0x41BE. Cierra clavada contra
;   su primer destino. Son los pasos del estado 8, el menu.
;   0x41db..0x41e3  (8 bytes)
DATA_tabla_menu:
	defw 041e3h	; 41db  -> MENU_0_PINTA
	defw 041f4h	; 41dd  -> MENU_1_ROTULO
	defw 04207h	; 41df  -> MENU_2_PARPADEA
	defw 04237h	; 41e1  -> MENU_3_CORTINILLA

; ======================================================================
; CODIGO 0x41e3..0x42fe  (283 bytes)
; ======================================================================


MENU_0_PINTA:		; Paso 0: limpia y prepara el rotulo
	call BORRA_SPRITES		;41e3   ; el menu se monta con la pantalla limpia: sprites y nombres
	call BORRA_NOMBRES		;41e6
	call PREPARA_ROTULO		;41e9
	ld a,092h		;41ec
	call PIDE_SONIDO		;41ee   ; Sonido 0x92
	jp SIGUIENTE_PASO		;41f1
MENU_1_ROTULO:		; Paso 1: dibuja el rotulo entero de una vez, sin repartirlo por fotogramas
	call DIBUJA_ROTULO		;41f4   ; el rotulo se dibuja poco a poco, y mientras haya acarreo se vuelve
	jr c,MENU_1_ROTULO		;41f7
	ld hl,057b7h		;41f9
	call ESCRIBE_CADENA		;41fc
	ld a,006h		;41ff   ; seis parpadeos de la opcion elegida antes de entrar
	ld (0e18dh),a		;4201   ; Seis parpadeos
	jp SIGUIENTE_PASO		;4204
MENU_2_PARPADEA:		; Paso 2: parpadea la linea elegida, ocho fotogramas encendida y ocho apagada
	ld hl,0e003h		;4207
	ld a,(hl)			;420a   ; ocho fotogramas por medio parpadeo: el `and 7` deja pasar uno de cada ocho...
	and 007h		;420b
	ret nz			;420d
	ld a,(hl)			;420e
	bit 3,a		;420f   ; ...y el bit 3 dice si toca encender o apagar
	jr nz,MENU_2_ENCIENDE		;4211
	ld de,03a00h		;4213   ; 0x3A00 es la fila 16 de la tabla de nombres
	ld bc,00020h		;4216   ; 0x20 casillas: la fila entera
	ld a,(0e002h)		;4219   ; Bit 4 de 0xE002: 0 joystick (fila 16), 1 teclado (fila 18)
	and 010h		;421c
	rlca			;421e   ; dos rotaciones: el bit 4 se convierte en 0x40, que son dos filas
	rlca			;421f
	call SUMA_A_DE		;4220   ; Suma 0x00 o 0x40 al destino, o sea dos filas
	ld a,001h		;4223
	call RELLENA_VRAM		;4225   ; el tile 1 es el blanco: apagar la linea es rellenarla con el
	ret			;4228
MENU_2_ENCIENDE:		; La otra mitad del parpadeo: repinta el texto
	ld hl,057b7h		;4229   ; y encenderla es volver a escribir el texto
	call ESCRIBE_CADENA		;422c
	ld hl,0e18dh		;422f   ; 0xE18D cuenta los parpadeos que quedan; agotados, la espera de 0x80 y al paso siguiente
	dec (hl)			;4232   ; y un parpadeo menos
	ret nz			;4233
	jp ESPERA_80_Y_PASO		;4234
MENU_3_CORTINILLA:		; Paso 3: cortinilla y a empezar la partida
	call CORTINILLA		;4237   ; la cortinilla otra vez, y detras el reinicio de la partida
	ret p			;423a   ; el `ret p` vuelve mientras la cortinilla no acabe
	call REINICIA_PARTIDA		;423b
	jp SIGUIENTE_ESTADO		;423e
ESTADO_09_PREPARA:		; Estado 9: saca de la tabla la distancia y el tiempo de la fase que toca
	ld a,(0e0e8h)		;4241   ; 0xE0E8: la fase dentro del recorrido, 0-9
	ld hl,04aa3h		;4244
	add a,a			;4247   ; Cuatro bytes por fase
	add a,a			;4248
	call SUMA_A_HL		;4249
	ld e,(hl)			;424c
	inc hl			;424d
	ld d,(hl)			;424e
	inc hl			;424f
	ld (0e0e6h),de		;4250   ; Centenas de metros y posicion en el mapa
	ld e,(hl)			;4254
	inc hl			;4255
	ld d,(hl)			;4256
	ld a,(0e0e1h)		;4257   ; Al tiempo de la fase se le resta lo que sobro de esa misma fase la vuelta anterior
	ld hl,0e0d5h		;425a
	call SUMA_A_HL		;425d
	ld a,(hl)			;4260
	sub 010h		;4261   ; Menos de 0x10 guardado: no se descuenta nada
	jr c,PREPARA_TIEMPO		;4263
	daa			;4265   ; el `daa` detras de cada resta: el tiempo va en BCD y hay que ajustarlo a mano
	ld c,a			;4266
	ld a,e			;4267
	sub c			;4268   ; y del tiempo de la fase se descuenta lo que sobro
	jr nc,PREPARA_AJUSTA		;4269
	daa			;426b
	dec d			;426c   ; la resta se lleva una centena
	jr PREPARA_GUARDA		;426d
PREPARA_AJUSTA:
	daa			;426f
PREPARA_GUARDA:
	ld e,a			;4270
PREPARA_TIEMPO:
	ld (0e0e3h),de		;4271   ; El tiempo de la fase, en BCD
	call PINTA_PANEL		;4275   ; el panel y la fuente se montan antes de que se vea nada
	call MONTA_LA_FUENTE		;4278
	ld a,00eh		;427b   ; Estado 14 y el avance de abajo lo deja en 15: primero el mapa
	ld (0e000h),a		;427d
	jp ESPERA_80_Y_ESTADO		;4280
ESTADO_10_ENTRA:		; Estado 10: cortinilla, monta la pista y suena la musica de salida
	call CORTINILLA		;4283
	ret p			;4286
	call MONTA_LA_FASE		;4287   ; con la cortinilla ya pasada, la fase se monta entera
	ld a,(0e002h)		;428a
	bit 6,a		;428d   ; En la demo no suena
	ld a,08ah		;428f   ; el sonido 0x8A es el del arranque de la fase
	call nz,PIDE_SONIDO		;4291
	ld a,001h		;4294
	ld (0e133h),a		;4296   ; y el reloj se echa a andar
	jp SIGUIENTE_ESTADO		;4299
ESTADO_11_PARTIDA:		; Estado 11: la partida. Un paso de juego por fotograma hasta que se acaba el tiempo o se llega a la meta
	ld a,(0e002h)		;429c   ; el bit 6 de 0xE002 distingue la partida de verdad de la demo
	bit 6,a		;429f
	jr z,PARTIDA_ERA_DEMO		;42a1
	call PASO_DE_PARTIDA		;42a3   ; Un paso de partida
	ld hl,(0e00ch)		;42a6   ; 0xE00C: se acabo el tiempo. 0xE00D: se ha llegado a la meta
	ld a,l			;42a9
	add a,h			;42aa
	ret z			;42ab
	ld a,l			;42ac
	ld hl,0e133h		;42ad
	ld (hl),000h		;42b0   ; y el reloj se para
	or a			;42b2
	ld a,00ch		;42b3   ; Estado 12, se acabo el tiempo
	jr nz,PARTIDA_CAMBIA		;42b5
	ld a,00eh		;42b7   ; Estado 14, meta
PARTIDA_CAMBIA:
	ld (0e000h),a		;42b9
	ret			;42bc
PARTIDA_ERA_DEMO:		; Si no habia partida de verdad, vuelve al paso 1 de la demo
	ld hl,00107h		;42bd   ; estado 7, paso 1: la demo se recoge por otro lado
	jr PONE_ESTADO		;42c0
ESTADO_12_TIME_OUT:		; Estado 12: se acabo el tiempo
	xor a			;42c2
	ld (0e00ch),a		;42c3
	ld hl,0e0b8h		;42c6   ; Aparca las cuatro nubes fuera de la pantalla
	ld de,00004h		;42c9
	ld b,004h		;42cc   ; cuatro nubes
TIME_OUT_SPRITES:
	ld (hl),0e0h		;42ce   ; la Y 0xE0 deja el sprite fuera de la pantalla
	add hl,de			;42d0
	djnz TIME_OUT_SPRITES		;42d1
	call VUELCA_ATRIBUTOS		;42d3   ; y los atributos se vuelcan ya, sin esperar al fotograma siguiente
	ld (0e0e2h),a		;42d6
	ld a,08ch		;42d9
	call PIDE_SONIDO		;42db   ; Sonido 0x8C
	ld hl,057f7h		;42de   ; El rotulo "TIME OUT"
	call ESCRIBE_CADENA		;42e1
	jp ESPERA_80_Y_ESTADO		;42e4
ESTADO_13_FIN:		; Estado 13: espera a que acabe la musica y vuelve a la demo
	ld a,(0e012h)		;42e7   ; 0xE012 lo pone a cero el reproductor cuando termina
	or a			;42ea
	ret nz			;42eb
	ld hl,0e002h		;42ec   ; y al soltarse se apaga la partida: lo que venga despues es demo otra vez
	res 6,(hl)		;42ef   ; Se acabo la partida: a partir de aqui los mandos vuelven a ser los grabados
	ld hl,00207h		;42f1   ; Estado 7, paso 2
PONE_ESTADO:		; Estado en L y paso en H, de una sentada
	ld (0e000h),hl		;42f4
	ret			;42f7

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; ESTADO 14 - LA META
; ----------------------------------------------------------------------
; Llegada a la base: la animacion, el cambio de fase, el bonus
; por el tiempo que ha sobrado y la cortinilla para la siguiente.
; ----------------------------------------------------------------------
ESTADO_14_META:		; Estado 14: la llegada a la base, en ocho pasos
	ld a,(0e001h)		;42f8
	call DESPACHA		;42fb

; ----------------------------------------------------------------------
; DATOS tabla_meta: Los 8 destinos del CALL de 0x42E1. Cierra clavada contra
;   su primer destino. Son los pasos del estado 14, la llegada a la meta.
;   0x42fe..0x430e  (16 bytes)
DATA_tabla_meta:
	defw 0430eh	; 42fe  -> META_0_FRENA
	defw 04321h	; 4300  -> META_1_SIGUIENTE
	defw 04361h	; 4302  -> META_2_ANDA
	defw 0436fh	; 4304  -> META_3_LLEGA
	defw 0438ch	; 4306  -> META_4_SALUDA
	defw 043b3h	; 4308  -> META_5_ESPERA
	defw 043bch	; 430a  -> META_6_BONUS
	defw 043e3h	; 430c  -> META_7_CORTINILLA

; ======================================================================
; CODIGO 0x430e..0x4477  (361 bytes)
; ======================================================================


META_0_FRENA:		; Paso 0: espera a que el pinguino termine de frenar
	ld hl,0e0f9h		;430e   ; 0xE0F9 es lo que le queda al salto por frenar
	ld a,(hl)			;4311   ; A cero ya estaba parado: al paso siguiente sin mas
	or a			;4312
	jp z,SIGUIENTE_PASO		;4313
	call SIGUE_SALTO		;4316   ; Un paso mas de frenada; si con el llega a cero, al paso siguiente en este mismo fotograma
	ld a,(0e0f9h)		;4319
	or a			;431c
	ret nz			;431d
	jp SIGUIENTE_PASO		;431e
META_1_SIGUIENTE:		; Paso 1: sube el numero de fase y guarda el tiempo que ha sobrado. Son DOS contadores distintos y conviene no mezclarlos: 0xE0E0 es el numero que se ve en el panel, en BCD y SIN TOPE -sigue subiendo a 11, 12...-, y 0xE0E1 es el indice 0-9 de la base, que DA LA VUELTA al llegar a diez. Esa pareja es la vuelta completa: el juego arranca con 0xE0E1 = 0, que es FRANCE (los valores iniciales estan en 0x4477), y cada llegada lo sube UNO, asi que se va de una base a la siguiente hasta que en la decima se vuelve al 0 y se cierra el circuito en Francia. Como el numero del panel no se reinicia, la vuelta siguiente son las mismas diez bases pero mas dificiles, que es lo que mira 0x76CD
	ld hl,0e0e0h		;4321   ; 0xE0E0 es el numero de fase que se ve, en BCD, y 0xE0E1 el indice de verdad
	ld a,(hl)			;4324
	add a,001h		;4325   ; El numero que se ve, en BCD
	daa			;4327   ; el `daa` ajusta la suma, que el numero va en BCD
	ld (hl),a			;4328
	inc hl			;4329
	ld a,(hl)			;432a   ; Y el indice 0-9, que da la vuelta al llegar a diez
	ld c,a			;432b
	inc a			;432c
	cp 00ah		;432d   ; diez fases y vuelta a empezar
	jr c,META_1_GUARDA		;432f
	xor a			;4331
	ld (0e0e2h),a		;4332
META_1_GUARDA:
	ld (hl),a			;4335
	ld a,c			;4336
	ld hl,0e0d5h		;4337   ; Lo que sobro de tiempo se guarda en 0xE0D5+fase y se descuenta la proxima vuelta
	call SUMA_A_HL		;433a
	ld a,(0e0e3h)		;433d
	ld (hl),a			;4340
	xor a			;4341
	ld (0e00dh),a		;4342   ; el aviso de meta se consume
	ld hl,0e0e8h		;4345   ; La casilla del mapa tambien avanza y da la vuelta
	inc (hl)			;4348
	ld a,(hl)			;4349
	cp 00ah		;434a   ; diez fases y vuelta a empezar
	jr nz,META_1_ANIMA		;434c
	ld (hl),000h		;434e
META_1_ANIMA:
	ld a,(0e079h)		;4350
	ld h,a			;4353
	ld l,001h		;4354
	ld (0e138h),hl		;4356   ; 0xE138 arranca la animacion de la vuelta completa
	ld a,013h		;4359
	ld (0e100h),a		;435b   ; Periodo 0x13 en 0xE100, que es lo mas lento que hay, para la animacion
	jp SIGUIENTE_PASO		;435e
META_2_ANDA:		; Paso 2: el pinguino sigue andando hasta la bandera
	ld c,0ffh		;4361   ; C = 0xFF: que ANDA_HASTA_LA_BASE calcule la X de destino en su primer paso
	call ANDA_HASTA_LA_BASE		;4363   ; el pinguino anda solo hasta la base; hasta que no llega, no se pasa de paso
	ret nz			;4366   ; hasta que no llega, no se pasa de paso
	ld a,00ch		;4367   ; Llegado (dieciseis pasos), el paso 3 arranca con la cuenta en 12: cuatro pasos mas de subida
	ld (0e138h),a		;4369
	jp SIGUIENTE_PASO		;436c
META_3_LLEGA:		; Paso 3: llega, se monta el decorado de la base y suena la musica
	ld c,000h		;436f   ; C = 0: el andar de vuelta no lleva prisa
	ld a,(0e079h)		;4371
	ld h,a			;4374
	call ANDA_HASTA_LA_BASE		;4375
	ret nz			;4378
	call MONTA_SPRITES_BASE		;4379   ; los sprites de la base, el dibujo y el montaje, en ese orden
	call DIBUJA_LA_BASE		;437c
	call MONTA_LA_BASE		;437f
	ld a,08fh		;4382   ; el sonido 0x8F es el de la llegada a la base
	call PIDE_SONIDO		;4384   ; Sonido 0x8F
	ld a,004h		;4387   ; Se salta el paso 4... no: entra en el, poniendolo a mano
	ld (0e001h),a		;4389
META_4_SALUDA:		; Paso 4: la escena de la base
	ld a,(0e01ah)		;438c   ; 0xE01A es el "lo que queda de nota" del segundo canal de sonido: la escena avanza justo cuando la nota va a acabar, al compas de la musica
	dec a			;438f   ; 0xE01A es el 'lo que queda de nota' del segundo canal: la escena avanza al compas de la musica
	ret nz			;4390
	call SUBE_LA_BANDERA		;4391
	ld a,(0e0e1h)		;4394   ; la bandera solo se sube en la fase 2
	cp 002h		;4397
	jr nz,META_4_PASO		;4399
	ld a,(0e13ah)		;439b   ; y ademas con la animacion en su cuadro 15
	cp 00fh		;439e
	jr nz,META_4_PASO		;43a0
	call DIBUJA_EL_POLO		;43a2   ; el polo se dibuja al llegar ahi
	jp SIGUIENTE_PASO		;43a5
META_4_PASO:		; Un paso mas de la escena de la base
	call DIBUJA_LA_BASE_PASO		;43a8
	ld a,(0e13ah)		;43ab   ; el cuadro 16 cierra el dibujo de la base
	cp 010h		;43ae
	ret nz			;43b0
	jr SIGUIENTE_PASO		;43b1
META_5_ESPERA:		; Paso 5: espera a que se acabe la musica
	ld a,(0e012h)		;43b3   ; no se sigue hasta que el reproductor suelta 0xE012: la musica se oye entera
	or a			;43b6
	ret nz			;43b7
	ld a,010h		;43b8
	jr ESPERA_A_Y_PASO		;43ba
META_6_BONUS:		; Paso 6: cada cuatro fotogramas cambia un segundo que sobra por 100 puntos
	ld hl,0e004h		;43bc   ; 0xE004 es la espera que dejo el paso anterior: se descuenta antes de empezar a canjear
	ld a,(hl)			;43bf   ; una espera con su propio contador
	or a			;43c0
	jr z,BONUS_PASO		;43c1
	dec (hl)			;43c3   ; y mientras quede, se descuenta
	ret			;43c4
BONUS_PASO:
	ld a,(0e003h)		;43c5   ; uno de cada cuatro fotogramas: el bonus se descuenta despacio para que se vea
	and 003h		;43c8   ; los dos bits bajos: uno de cada cuatro
	ret nz			;43ca
	ld hl,(0e0e3h)		;43cb   ; Cuando el reloj llega a cero se acabo el bonus
	ld a,h			;43ce   ; los dos bytes del tiempo juntos: a cero, se acabo el bonus
	add a,l			;43cf
	jr z,ESPERA_80_Y_PASO		;43d0
	ld c,000h		;43d2
	call RESTA_UN_SEGUNDO		;43d4   ; un segundo menos de tiempo...
	ld de,00100h		;43d7   ; Cien puntos por segundo
	call SUMA_AL_MARCADOR		;43da   ; ...y sus puntos al marcador
	ld a,001h		;43dd
	call PIDE_SONIDO		;43df   ; Sonido 1, el tic-tic del bonus
	ret			;43e2
META_7_CORTINILLA:		; Paso 7: cortinilla y vuelta al estado 9 con la fase siguiente
	call CORTINILLA		;43e3
	ret p			;43e6   ; el `ret p` vuelve mientras la cortinilla no acabe
	ld a,008h		;43e7   ; el estado 8 con 0x50 fotogramas de espera
	ld (0e000h),a		;43e9

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LAS SEIS SALIDAS QUE HACEN AVANZAR LA MAQUINA
; ----------------------------------------------------------------------
; Van encadenadas de mas a menos: cada una hace lo suyo y cae en
; la siguiente. Las tres de arriba pasan al ESTADO siguiente
; (y ponen el paso a cero); las tres de abajo, solo al PASO
; siguiente. 0xE004 es la espera en fotogramas.
; ----------------------------------------------------------------------
ESPERA_80_Y_ESTADO:		; Espera 80 fotogramas y pasa al estado siguiente
	ld a,050h		;43ec
ESPERA_A_Y_ESTADO:		; Espera A fotogramas y pasa al estado siguiente
	ld (0e004h),a		;43ee
SIGUIENTE_ESTADO:		; Sube 0xE000 y pone el paso a cero
	ld hl,0e000h		;43f1   ; el estado sube uno y el paso vuelve a cero
	inc (hl)			;43f4
	xor a			;43f5
	ld (0e001h),a		;43f6
	ret			;43f9
ESPERA_80_Y_PASO:		; Espera 80 fotogramas y pasa al paso siguiente
	ld a,050h		;43fa   ; 0x50 fotogramas de espera y un paso mas
ESPERA_A_Y_PASO:		; Espera A fotogramas y pasa al paso siguiente
	ld (0e004h),a		;43fc
SIGUIENTE_PASO:		; Sube 0xE001 dentro del mismo estado
	ld hl,0e001h		;43ff
	inc (hl)			;4402
	ret			;4403

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; CODIGO MUERTO: EL NUMERO DE JUGADOR
; ----------------------------------------------------------------------
; Escribe una cadena y detras un '1' o un '2' sacado del bit 7
; de 0xE002. Nadie la llama: la palabra 0x4404 no aparece en los
; 16 KB. Y el bit 7 de 0xE002 no lo pone nadie tampoco, porque
; los dos valores que se le escriben son 0x40 y 0x50. Es lo que
; queda de un modo de dos jugadores, a juego con el rotulo fijo
; "1P" del marcador.
; ----------------------------------------------------------------------
MUERTA_JUGADOR:		; Codigo muerto: escribe el numero de jugador. No la llama nadie
	call ESCRIBE_CADENA		;4404
	ld a,(0e002h)		;4407
	rlca			;440a   ; Bit 7 de 0xE002: el jugador. Nadie lo pone
	and 001h		;440b
	add a,031h		;440d   ; el 0x31 es el tile del "1": el numero de jugador sale de sumarle el bit 0 de 0xE002
	ld de,03933h		;440f   ; 0x3933 es la casilla donde va ese digito
	call ESCRIBE_EN_VRAM		;4412
	ret			;4415

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LAS TECLAS 1 Y 2, QUE ES POR DONDE SE EMPIEZA A JUGAR
; ----------------------------------------------------------------------
; Se mira en cada fotograma, en cualquier estado. El POP HL de
; 0x4459 tira la direccion de retorno, o sea que no vuelve a
; quien la llamo: corta el paso de juego en seco y planta el
; estado 7.
; ----------------------------------------------------------------------
MIRA_TECLAS_1_2:		; Empieza la partida si se pulsa 1 (joystick) o 2 (teclado)
	ld a,(0e13bh)		;4416   ; 0xE13B: durante la llegada a la base no se puede empezar otra
	or a			;4419
	ret nz			;441a
	ld a,(0e002h)		;441b
	bit 6,a		;441e   ; Con una partida en marcha tampoco
	ret nz			;4420
	ld a,050h		;4421   ; el 0x50 en el puerto 0xAA selecciona la fila del teclado, y se escribe dos veces para que se asiente
	out (0aah),a		;4423
	out (0aah),a		;4425
	in a,(0a9h)		;4427
	cpl			;4429
	and 006h		;442a   ; dos bits: las teclas 1 y 2
	ld b,040h		;442c   ; 0x40 con la tecla 1 -joystick- y 0x50 con la 2, que ademas enciende el bit del teclado
	cp 002h		;442e
	jr z,TECLA_GUARDA		;4430
	ld b,050h		;4432
	cp 004h		;4434
	ret nz			;4436
TECLA_GUARDA:		; Apunta que tecla se ha elegido y monta el menu
	xor a			;4437   ; La tecla elegida (0 a 3) queda en los bits 4-5 de 0xE002
	ld (0e133h),a		;4438
	ld a,b			;443b
	ld (0e002h),a		;443c
	pop hl			;443f   ; el `pop hl` tira la direccion de retorno: de aqui se sale por el estado, no volviendo
	ld a,007h		;4440   ; estado 7, que es donde empieza la partida
	ld (0e000h),a		;4442
	jp ESPERA_80_Y_ESTADO		;4445
TECLA_SALE:		; Un RET suelto al que no llega nadie
	ret			;4448
REINICIA_PARTIDA:		; Deja a cero el marcador y todas las variables de partida
	ld hl,0e043h		;4449   ; Borra 0x100 bytes desde 0xE043: marcador, pinguino y objetos. El record de 0xE040 se salva por tres bytes
	ld de,0e044h		;444c   ; 0x100 bytes desde 0xE044 a cero: las fichas de los objetos
	ld bc,00100h		;444f
	ld (hl),000h		;4452
	ldir		;4454
	ld hl,04477h		;4456   ; Los nueve valores iniciales de 0xE0E0 (fase, tiempo, distancia...)
	ld de,0e0e0h		;4459   ; y nueve bytes mas desde 0xE0E0: fase, mapa y tiempo
	ld bc,00009h		;445c
	ldir		;445f
	ld de,00900h		;4461   ; Colores del banco 0 de la VRAM
	ld bc,00100h		;4464
	ld a,0f0h		;4467   ; el tile 0xF0 rellena la pantalla: el fondo de la fase
	call RELLENA_VRAM		;4469
	ld b,00ah		;446c   ; Los diez huecos de tiempo sobrante, uno por fase, a 5
	ld hl,0e0d5h		;446e   ; los diez huecos de tiempo sobrante vuelven a cinco segundos cada uno
REINICIA_HUECOS:
	ld (hl),005h		;4471
	inc hl			;4473
	djnz REINICIA_HUECOS		;4474
	ret			;4476

; ----------------------------------------------------------------------
; DATOS valores_iniciales: Los nueve bytes que 0x4456 copia a 0xE0E0: fase 1,
;   indice 0, y el resto a cero salvo 0xE0E4=2 y 0xE0E6=0x17. Solo los cinco
;   primeros se usan: 0x4241 machaca la distancia y el tiempo en cuanto
;   empieza la fase
;   0x4477..0x4480  (9 bytes)
DATA_valores_iniciales:
	defb 001h,000h,000h,000h,002h,000h,017h,000h,000h	; 4477  .........

; ======================================================================
; CODIGO 0x4480..0x44d4  (84 bytes)
; ======================================================================


ARRANCA_MAQUINA:		; Registros del VDP, mezclador del PSG y VRAM a cero. Hace lo mismo que en la segunda japonesa, pero hablandole a los chips directamente
	call PONE_REGISTROS_VDP		;4480   ; Los registros del VDP, los tres volumenes del PSG y la VRAM entera: el encendido completo
	ld a,007h		;4483   ; registro 7 del PSG con 0xB8: los tres canales de tono abiertos y el ruido cerrado
	out (0a0h),a		;4485
	ld a,0b8h		;4487
	out (0a1h),a		;4489
	call PREPARA_EL_MANDO		;448b
	call APAGA_LOS_TRES_CANALES		;448e
	ld de,00000h		;4491
	ld bc,04000h		;4494   ; los 16 KB de VRAM a cero de una vez
VRAM_A_CERO:		; Rellena de ceros los 16 KB de VRAM
	xor a			;4497
	call RELLENA_VRAM		;4498
	ret			;449b
BORRA_NOMBRES:		; Las 768 casillas de la tabla de nombres
	ld de,03800h		;449c   ; 0x3800 son las 24 filas de la tabla de nombres, 0x300 bytes
	ld bc,00300h		;449f
	jr VRAM_A_CERO		;44a2
APAGA_LOS_TRES_CANALES:		; Pone a cero los registros 8, 9 y 10 del PSG, que son los tres volumenes, escribiendo el puerto a pelo
	xor a			;44a4
	ld bc,003a0h		;44a5   ; 0xA0 en C es el puerto de seleccion de registro del PSG, y D arranca en el 8: los tres volumenes
	ld d,008h		;44a8   ; los registros del PSG del 8 al 10 son los tres volumenes
APAGA_CANAL:		; Registro tras registro, los tres volumenes a cero
	out (c),d		;44aa   ; El numero de registro por 0xA0 y el cero por 0xA1: escritura del PSG a pelo, sin WRTPSG
	inc d			;44ac
	out (0a1h),a		;44ad
	djnz APAGA_CANAL		;44af   ; Y detras el sonido 0x95, que es lo que suena al encender
	ld a,095h		;44b1   ; el sonido 0x95 acompana al arranque
	call PIDE_SONIDO		;44b3
	ret			;44b6
PONE_REGISTROS_VDP:		; Copia los ocho registros a 0xE038 y los manda al VDP por el puerto 0x99, con el bit 0x80 del numero de registro que va sumando en D
	ld hl,044d4h		;44b7   ; 0xE038 guarda la copia en RAM de los ocho registros, que el VDP no deja leer
	ld de,0e038h		;44ba   ; los ocho registros del VDP se copian a 0xE038 y de ahi se mandan
	ld bc,00008h		;44bd
	ldir		;44c0
	ld hl,0e038h		;44c2
	ld b,008h		;44c5
	ld d,080h		;44c7   ; D arranca en 0x80: el bit alto es lo que convierte la escritura en 'a un registro'
MANDA_UN_REGISTRO:		; Manda un registro del VDP: el valor en E y el numero con el bit 0x80 en D
	ld e,(hl)			;44c9   ; El valor en E y el numero en D, que es exactamente el par que APUNTA_VRAM manda por el 0x99
	di			;44ca   ; el volcado va con las interrupciones cerradas: entre poner la direccion y escribir no puede meterse nadie
	call APUNTA_VRAM		;44cb
	ei			;44ce
	inc hl			;44cf   ; El `inc d` recorre 0x80-0x87: los ocho registros seguidos
	inc d			;44d0   ; el numero de registro sube con D, que es lo que pide el VDP
	djnz MANDA_UN_REGISTRO		;44d1
	ret			;44d3

; ----------------------------------------------------------------------
; DATOS registros_vdp: Los ocho registros del VDP: 02 E2 0E 7F 07 76 03 E1. El
;   ultimo es el registro 7, tinta y fondo: aqui el fondo y el borde son
;   NEGROS. Colores en 0x0000 y patrones en 0x2000, al reves de lo corriente;
;   nombres en 0x3800, patrones de sprite en 0x1800 y atributos de sprite en
;   0x3B00. Sprites de 16x16 sin ampliar, y SCREEN 2
;   0x44d4..0x44dc  (8 bytes)
DATA_registros_vdp:
	defb 002h	; 44d4
	defb 0e2h	; 44d5
	defb 00eh	; 44d6
	defb 07fh	; 44d7
	defb 007h	; 44d8
	defb 076h	; 44d9
	defb 003h	; 44da
	defb 0e1h	; 44db

; ======================================================================
; CODIGO 0x44dc..0x476e  (658 bytes)
; ======================================================================


COPIA_A_VRAM:		; Copia BC bytes de (HL) a la VRAM DE. Apunta con el bit 6 puesto -escritura- y suelta los bytes por el puerto 0x98
	di			;44dc
	set 6,d		;44dd   ; Bit 6 de la direccion: es para escribir, y se quita despues para que el llamante vea DE como lo dejo
	call APUNTA_VRAM		;44df
	res 6,d		;44e2   ; el bit 6 fuera: la direccion se pone para LEER, no para escribir
COPIA_BYTE:		; Suelta un byte por el puerto de datos del VDP
	ld a,(hl)			;44e4
	out (098h),a		;44e5   ; Al puerto de datos del VDP, sin pasar por la BIOS: la direccion ya quedo apuntada y el VDP la sube solo
	inc hl			;44e7
	dec bc			;44e8   ; El `dec bc` no toca banderas: el `ld a,b / or c` es el 'BC == 0' de un contador de 16 bits
	ld a,b			;44e9   ; el `or c` mira los dos bytes de la cuenta de una vez
	or c			;44ea
	jr nz,COPIA_BYTE		;44eb
	ei			;44ed
	ret			;44ee
RELLENA_VRAM:		; Escribe el byte A en BC posiciones de la VRAM desde DE
	di			;44ef
	ld h,a			;44f0
	set 6,d		;44f1   ; Bit 14 de la direccion: la escritura
	call APUNTA_VRAM		;44f3
	res 6,d		;44f6
RELLENA_VRAM_BUCLE:
	ld a,h			;44f8   ; El byte se relee de H en cada vuelta, porque el `or c` del final gasta A
	out (098h),a		;44f9   ; el puerto 0x98 es el de datos de la VRAM: se escribe byte a byte sin volver a poner la direccion
	dec bc			;44fb
	ld a,b			;44fc
	or c			;44fd
	jr nz,RELLENA_VRAM_BUCLE		;44fe
	ei			;4500
	ret			;4501
PINTA_FRANJAS:		; Rellena tiras de la tabla de nombres a partir de una lista (largo, posicion), con el byte que va delante
	ld a,(hl)			;4502   ; el primer byte de la lista es el que se va a escribir; detras vienen las parejas de largo y posicion
	inc hl			;4503
	ld (0e0dfh),a		;4504   ; El byte con el que se rellena, que va el primero de la lista
	ld d,039h		;4507   ; 0x3900 es la tabla de nombres mas 0x100, o sea la fila 8: por ahi empiezan las franjas
FRANJAS_BUCLE:
	ld c,(hl)			;4509
	inc hl			;450a
	xor a			;450b   ; Un largo 0 cierra la lista
	cp c			;450c
	ret z			;450d
	ld b,a			;450e   ; B a cero: el largo cabe en un byte y el otro no se usa
	ld e,(hl)			;450f
	inc hl			;4510
	ld a,e			;4511
	cp 020h		;4512   ; Posicion menor de 0x20: la fila de mas abajo
	jr nc,FRANJAS_PINTA		;4514
	inc d			;4516   ; el `inc d` suma 0x100, que en la tabla de nombres son ocho filas
FRANJAS_PINTA:
	ld a,(0e0dfh)		;4517
	push hl			;451a   ; La lista y el destino se salvan alrededor del relleno, que gasta los seis registros
	push de			;451b
	call RELLENA_VRAM		;451c
	pop de			;451f
	pop hl			;4520
	jr FRANJAS_BUCLE		;4521

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; EL INTERPRETE DE BLOQUES, que dibuja los decorados y la pista
; ----------------------------------------------------------------------
; Un bloque es una tira de bytes que se lee asi:
; primer byte: nibble alto = columna, nibble bajo = tercio de
; pantalla (0-3), que se suma a 0x78 y da la fila
; luego, por cada fila: un byte de desplazamiento y detras las
; casillas que se escriben seguidas
; un byte >= 0xE0 cierra la fila y abre la siguiente
; un 0x00 cierra el bloque
; Con esto se dibujan los dieciseis bloques de decorado de
; 0x7305-0x74F0 y los 92 trozos de pista de 0x6BC1-0x7219.
; ----------------------------------------------------------------------
DIBUJA_BLOQUE:		; Interprete de los bloques de decorado y de pista
	ld a,(hl)			;4523
	or a			;4524
	ret z			;4525
	and 0f0h		;4526   ; El nibble alto del primer byte es la columna
	ld c,a			;4528
	ld a,(hl)			;4529
	inc hl			;452a
	and 003h		;452b   ; El nibble bajo (0-3) mas 0x78: el byte alto de la casilla en la tabla de nombres, con el bit de escritura ya puesto
	add a,078h		;452d
	ld d,a			;452f   ; y con eso D queda hecho: el byte alto de la casilla, con el bit de escritura ya dentro
	ld a,c			;4530
BLOQUE_FILA:
	ld b,(hl)			;4531
	inc hl			;4532
	ld a,020h		;4533   ; Una fila mas abajo son 32 casillas: se suman al byte bajo y el acarreo sube el alto
	add a,c			;4535
	ld c,a			;4536
	jr nc,BLOQUE_APUNTA		;4537
	inc d			;4539
BLOQUE_APUNTA:
	ld a,c			;453a
	add a,b			;453b
	sub 0e0h		;453c   ; El byte que cerro la fila hace de desplazamiento de la siguiente: el `sub 0xE0` le quita la marca
	ld e,a			;453e
	call APUNTA_VRAM		;453f
BLOQUE_CASILLA:
	ld a,(hl)			;4542   ; El 0x00 cierra el bloque
	or a			;4543
	ret z			;4544   ; Y un byte de 0xE0 para arriba cierra la fila y abre la siguiente
	cp 0e0h		;4545
	jr nc,BLOQUE_FILA		;4547
	inc hl			;4549   ; Las casillas de la fila salen seguidas por el puerto de datos
	out (098h),a		;454a
	jr BLOQUE_CASILLA		;454c

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; EL DESCOMPRESOR, con cuatro entradas
; ----------------------------------------------------------------------
; El flujo se lee asi:
; 0x00          se acabo todo
; 0x80          cierra el bloque y vuelve arriba a leer OTRO
; destino del propio flujo
; n con bit7=0  repite n veces el byte siguiente
; n con bit7=1  (n & 0x7F) bytes copiados tal cual
; Es facil leerlo al reves, y lo que lo decide son los dos DJNZ:
; el de 0x4584 vuelve DESPUES de leer el byte, asi que lo
; repite; el de 0x4592 vuelve ANTES, asi que lee uno cada vez.
; OJO: dos llamadas seguidas sin `ld hl` en medio siguen con el
; HL que quedo, o sea con el flujo de al lado.
; ----------------------------------------------------------------------
DESCOMPRIME:		; El destino de VRAM viene en el propio flujo
	ld e,(hl)			;454e
	inc hl			;454f
	ld d,(hl)			;4550
	inc hl			;4551
DESCOMPRIME_DE:		; El destino ya viene en DE
	ld c,000h		;4552
	jr DESCOMPRIME_APUNTA		;4554
DESCOMPRIME_ESPEJO:		; El destino en DE, y ademas espeja cada byte
	ld c,001h		;4556
DESCOMPRIME_APUNTA:
	call APUNTA_VRAM		;4558
DESCOMPRIME_SIGUE:		; El bucle
	ld a,(hl)			;455b
	inc hl			;455c
	or a			;455d   ; Un 0x80 cierra este bloque y arriba se lee otro destino
	jr z,DESCOMPRIME_FIN		;455e
	bit 7,a		;4560   ; Un 0x00 acaba del todo
	jr nz,DESCOMPRIME_TIRADA		;4562   ; Bit 7: tirada de literales; si no, repeticion
	ld b,a			;4564   ; la repeticion: B veces el MISMO byte, leido una vez por vuelta
	call LEE_Y_ESPEJA		;4565
DESCOMPRIME_REPITE:		; Repite el mismo byte n veces: no lo vuelve a leer, y ese es el detalle que distingue esta rama de la de al lado
	out (098h),a		;4568
	push hl			;456a   ; el `push hl / pop hl` no mueve nada: son doce ciclos de espera para que el VDP no se atragante
	pop hl			;456b
	djnz DESCOMPRIME_REPITE		;456c
	jr DESCOMPRIME_SIGUE		;456e
DESCOMPRIME_TIRADA:		; Una tirada de bytes literales, con el bit 7 quitado de la cuenta
	res 7,a		;4570   ; el bit 7 fuera y lo que queda es cuantos literales vienen detras
	ld b,a			;4572
TIRADA_BYTE:		; Aqui SI se relee cada vez, por eso es literal y no repeticion
	call LEE_Y_ESPEJA		;4573
	out (098h),a		;4576
	djnz TIRADA_BYTE		;4578
	jr DESCOMPRIME_SIGUE		;457a
DESCOMPRIME_FIN:		; Vuelve a permitir la interrupcion y sale
	ei			;457c
	ret			;457d
LEE_Y_ESPEJA:		; Lee (HL) y, si C tiene el bit 0, le INVIERTE LOS BITS: el espejo horizontal del descompresor
	ld a,(hl)			;457e   ; el espejo se decide al entrar y vale para todo el bloque
	inc hl			;457f
	bit 0,c		;4580   ; El bit 0 de C lo fijo la entrada del descompresor: sin el, el byte sale tal cual
	ret z			;4582
	push bc			;4583   ; Ocho vueltas rotando en un sentido y metiendo por el otro: el espejo horizontal
	ld b,008h		;4584
	ld c,a			;4586
ESPEJA_BIT:		; Los ocho bits, rotando en un sentido y metiendolos en el otro
	rr c		;4587   ; `rr c` saca por abajo y `rla` mete por arriba: eso es dar la vuelta al byte
	rla			;4589
	djnz ESPEJA_BIT		;458a
	pop bc			;458c
	ret			;458d

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LAS CADENAS
; ----------------------------------------------------------------------
; Formato: palabra de destino en la VRAM, los caracteres, y de
; remate un 0xFF. Un 0xFE en medio no acaba: cambia de destino y
; sigue, que es como una sola cadena pone rotulos en cinco
; sitios de la pantalla.
; EL TEXTO VA CIFRADO A LA MANERA DE KONAMI: cada byte es su
; ASCII menos 0x20. No es cifrado de verdad, es que la fuente
; empieza en el espacio: el codigo 0x11 es el '1' y el 0x21 la
; 'A'. Por eso los rotulos no se ven al mirar el volcado.
; ----------------------------------------------------------------------
ESCRIBE_CADENA:		; Escribe la cadena de (HL); el destino va en los dos primeros bytes
	ld e,(hl)			;458e   ; cada cadena trae delante su destino de VRAM, dos bytes
	inc hl			;458f
	ld d,(hl)			;4590
	inc hl			;4591
ESCRIBE_CADENA_EN_DE:		; Igual, pero el destino ya viene en DE
	ld a,(hl)			;4592
	inc hl			;4593
	ld b,a			;4594   ; el byte se mira con dos `inc b` seguidos: el primero caza el 0xFF y el segundo el 0xFE
	inc b			;4595
	ret z			;4596   ; 0xFF: se acabo
	inc b			;4597
	jr z,ESCRIBE_CADENA		;4598   ; 0xFE: sigue en otro sitio de la pantalla
	call ESCRIBE_EN_VRAM		;459a
	inc de			;459d
	jr ESCRIBE_CADENA_EN_DE		;459e
REPITE_4_BYTES:		; Copia C veces los mismos cuatro bytes de (HL) a (DE): un atributo de sprite repetido
	push hl			;45a0   ; cuatro bytes por vuelta, y HL vuelve atras: el mismo grupo repetido C veces
	ld b,004h		;45a1
REPITE_4_BUCLE:
	ld a,(hl)			;45a3
	ld (de),a			;45a4
	inc hl			;45a5
	inc de			;45a6
	djnz REPITE_4_BUCLE		;45a7
	dec c			;45a9
	jr z,REPITE_4_FIN		;45aa
	pop hl			;45ac   ; HL vuelve al principio de los cuatro bytes; DE sigue avanzando y la copia se repite
	jr REPITE_4_BYTES		;45ad
REPITE_4_FIN:
	pop bc			;45af   ; Recoge el ultimo PUSH HL en BC, que ya no hace falta
	ret			;45b0

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LA CORTINILLA
; ----------------------------------------------------------------------
; Borra la pantalla dos columnas por vuelta, una por cada lado,
; cerrandose hacia el centro. 0xE004 lleva la cuenta y el bit 6
; del mismo byte dice si toca la columna de la izquierda o la de
; la derecha. Devuelve M cuando ya no queda nada que borrar, que
; es como los estados saben que pueden seguir.
; ----------------------------------------------------------------------
CORTINILLA:		; Borra la pantalla por columnas; devuelve M al terminar
	call BORRA_SPRITES		;45b1
	ld d,038h		;45b4   ; 0x3800 es la tabla de nombres; la cortinilla se pinta ahi
	ld hl,0e004h		;45b6
	ld b,018h		;45b9   ; 0x18 filas: la pantalla entera
	bit 6,(hl)		;45bb   ; Bit 6 de 0xE004: un lado o el otro
	jr nz,CORTINILLA_DERECHA		;45bd
	ld a,01fh		;45bf   ; La columna izquierda es 0x1F menos la cuenta: las dos avanzan a la vez hacia el centro
	sub (hl)			;45c1
	ld e,a			;45c2
	set 6,(hl)		;45c3   ; el bit 6 se enciende y se apaga en vueltas alternas: una columna por lado y por fotograma
	jr CORTINILLA_COLUMNA		;45c5
CORTINILLA_DERECHA:
	res 6,(hl)		;45c7
	dec (hl)			;45c9   ; y solo se descuenta al cerrar la pareja; con el signo negativo, se acabo
	ret m			;45ca
	ld e,(hl)			;45cb
CORTINILLA_COLUMNA:
	ld a,(0e000h)		;45cc   ; En partida no se toca el panel: dos filas menos y 0x40 mas abajo
	cp 00ah		;45cf
	jr c,CORTINILLA_BUCLE		;45d1
	ld a,040h		;45d3
	add a,e			;45d5
	ld e,a			;45d6
	dec b			;45d7   ; los dos `dec b` se comen las dos filas del panel
	dec b			;45d8
CORTINILLA_BUCLE:
	xor a			;45d9
	call ESCRIBE_EN_VRAM		;45da
	ld a,020h		;45dd   ; 0x20 casillas para bajar una fila
	call SUMA_A_DE		;45df   ; Baja una fila
	djnz CORTINILLA_BUCLE		;45e2
	xor a			;45e4
	ret			;45e5
BORRA_SPRITES:		; Deja a cero los 128 bytes de atributos de sprite (VRAM 0x3B00), pasando por 0xE050
	ld hl,0e050h		;45e6   ; los sprites se borran en la copia de RAM y luego se vuelca entera
	push hl			;45e9
	ld b,080h		;45ea   ; 0x80 bytes son los 32 atributos de sprite
BORRA_SPRITES_BUCLE:
	ld (hl),000h		;45ec
	inc hl			;45ee
	djnz BORRA_SPRITES_BUCLE		;45ef
	ld de,03b00h		;45f1   ; Y la copia limpia entera a la tabla de atributos: 0xE050 es su espejo en RAM
	pop hl			;45f4
	ld bc,00080h		;45f5
	jp COPIA_A_VRAM		;45f8
PREPARA_EL_MANDO:		; Registro 15 del PSG a 0x8F, que es como se deja el puerto por el que se lee el joystick
	ld a,00fh		;45fb
	out (0a0h),a		;45fd   ; el 0xA0 selecciona el registro y el 0xA1 escribe: dos puertos, uno para elegir y otro para el dato
	ld a,08fh		;45ff
	out (0a1h),a		;4601
	ret			;4603
LEE_GATILLOS_NUEVOS:		; Deja en A los gatillos que se acaban de pulsar en este fotograma
	ld a,(0e009h)		;4604   ; 0xE009 es lo pulsado ahora y 0xE008 lo de la vuelta anterior
	ld b,a			;4607
	ld a,(0e008h)		;4608
	and 030h		;460b
	cpl			;460d   ; Lo de antes negado y en AND con lo de ahora: el flanco de los bits 4-5, los gatillos recien pulsados
	ld c,a			;460e
	ld a,b			;460f
	and 030h		;4610
	and c			;4612   ; y el `and` de los dos deja solo lo que acaba de pulsarse
	ret			;4613
SUMA_AL_MARCADOR:		; Suma DE al marcador, en BCD, y actualiza el record
	ld a,(0e002h)		;4614   ; Bit 6 de 0xE002 al bit de signo: en la demo no se puntua
	add a,a			;4617
	ret p			;4618
	ld hl,0e043h		;4619   ; el marcador son tres parejas BCD en 0xE043, y se suma pareja a pareja
	ld a,(hl)			;461c
	add a,e			;461d
	daa			;461e
	ld (hl),a			;461f
	ld e,a			;4620   ; Las dos parejas bajas vuelven a DE: COMPARA_RECORD las compara de golpe con el `sbc hl,de`
	inc hl			;4621
	ld a,(hl)			;4622
	adc a,d			;4623   ; la pareja de en medio va con `adc`: el acarreo viene de la de abajo
	daa			;4624
	ld (hl),a			;4625
	ld d,a			;4626
	inc hl			;4627
	jr nc,COMPARA_RECORD		;4628
	ld a,(hl)			;462a
	adc a,000h		;462b   ; y la de arriba igual, con su `daa`
	daa			;462d
	ld (hl),a			;462e
	jr nc,COMPARA_RECORD		;462f
	ld bc,09999h		;4631   ; Al pasarse de 999999 el record se clava en ese tope
	ld (0e040h),bc		;4634   ; los seis nueves se escriben dos veces, en 0xE040 y 0xE041, que es como se cubre la pareja de en medio
	ld (0e041h),bc		;4638
	jr PINTA_RECORD		;463c
COMPARA_RECORD:
	ld a,(0e042h)		;463e   ; el record se compara de arriba abajo, y solo se mira lo de abajo si lo de arriba empata
	ld b,(hl)			;4641
	sub (hl)			;4642   ; Byte alto contra byte alto: con acarreo hay record nuevo; empatados, deciden las parejas bajas
	jr c,NUEVO_RECORD		;4643
	jr nz,PINTA_MARCADOR		;4645
	ld hl,(0e040h)		;4647
	sbc hl,de		;464a
	jr nc,PINTA_MARCADOR		;464c
NUEVO_RECORD:
	ld (0e040h),de		;464e   ; el record nuevo son las dos parejas bajas y la alta, en ese orden
	ld a,b			;4652
	ld (0e042h),a		;4653
	jr PINTA_RECORD		;4656
CUENTA_EL_TIEMPO:		; Descuenta un segundo cada 64 fotogramas mientras 0xE133 diga que el reloj corre
	ld a,(0e133h)		;4658   ; 0xE133 apagado es el reloj parado: en el menu y en las cortinillas no corre
	or a			;465b
	ret z			;465c
	ld hl,(0e0e3h)		;465d   ; Si el reloj esta a cero, 0xE00C avisa de que se acabo el tiempo
	ld a,h			;4660
	add a,l			;4661
	jr nz,TIEMPO_CADA_64		;4662
	inc a			;4664
	ld (0e00ch),a		;4665
	ret			;4668
TIEMPO_CADA_64:
	ld a,(0e003h)		;4669   ; uno de cada 64 fotogramas, y 0xE003 sube uno por interrupcion: el "segundo" del juego dura 1,28 s en una maquina PAL y 1,07 en una NTSC, o sea que en las dos es mas largo que el de verdad
	and 03fh		;466c
	ret nz			;466e
	ld c,001h		;466f
RESTA_UN_SEGUNDO:		; Baja el reloj en uno, en BCD, y avisa con un pitido cuando quedan menos de once
	ld hl,0e0e3h		;4671   ; el reloj tambien va en BCD, dos parejas
	ld a,(hl)			;4674
	sub 001h		;4675   ; `sub 1 / daa` en vez de `dec`: el `dec` no deja el acarreo que la pareja alta BCD necesita
	daa			;4677
	ld (hl),a			;4678
	inc hl			;4679
	ld a,(hl)			;467a   ; La pareja alta solo baja si la baja pidio prestamo
	jr nc,TIEMPO_MIRA_AVISO		;467b
	sub 001h		;467d
	daa			;467f
	ld (hl),a			;4680
TIEMPO_MIRA_AVISO:
	dec hl			;4681
	or a			;4682
	jr nz,PINTA_TIEMPO		;4683
	ld a,(hl)			;4685
	cp 011h		;4686   ; Menos de 0x11 segundos: el aviso
	jr nc,PINTA_TIEMPO		;4688
	dec c			;468a
	jr nz,PINTA_TIEMPO		;468b
	push af			;468d   ; el aviso suena y la vuelta sigue: el `push` guarda las banderas que hacen falta despues
	push hl			;468e
	ld a,009h		;468f
	call PIDE_SONIDO		;4691   ; Sonido 9
	pop hl			;4694
	pop af			;4695
PINTA_TIEMPO:		; Las cuatro cifras del reloj
	ld b,002h		;4696   ; dos parejas BCD: los cuatro digitos del reloj
	ld de,03827h		;4698
	ld hl,0e0e4h		;469b
	jp PINTA_BCD		;469e
PINTA_PANEL:		; Pinta el panel entero: rotulos, tiempo, distancia, fase, record y marcador
	ld hl,0577ah		;46a1   ; el panel se pinta entero de una vez: rotulos, reloj, distancia, fase, record y marcador
	call ESCRIBE_CADENA		;46a4
	call PINTA_TIEMPO		;46a7
	call PINTA_DISTANCIA		;46aa
	call PINTA_FASE		;46ad
PINTA_RECORD:		; Las seis cifras del record
	ld hl,0e042h		;46b0   ; el record va en 0x380F, tres bytes
	ld de,0380fh		;46b3
	call PINTA_TRES_BYTES		;46b6
PINTA_MARCADOR:		; Las seis cifras del marcador
	ld de,03805h		;46b9   ; y el marcador en 0x3805
	ld hl,0e045h		;46bc
PINTA_TRES_BYTES:
	ld b,003h		;46bf
	jr PINTA_BCD		;46c1
AVANZA_DISTANCIA:		; Descuenta la distancia que queda al ritmo que marca la velocidad
	ld hl,0e0e9h		;46c3
	dec (hl)			;46c6   ; 0xE0E9 es el contador; se recarga con la mitad del periodo de 0xE100, y esa recarga es lo que demuestra que 0xE100 es un periodo y no una velocidad
	ret nz			;46c7
	ld a,(0e100h)		;46c8
	srl a		;46cb   ; la mitad del periodo: la distancia baja al doble de ritmo que la animacion
	dec a			;46cd
	ld (hl),a			;46ce
	ld hl,0e0e6h		;46cf   ; Distancia a cero: 0xE00D avisa de que se ha llegado a la meta
	ld a,(hl)			;46d2   ; los dos bytes de la distancia mirados de una vez con el `or`
	dec hl			;46d3
	or (hl)			;46d4
	jr nz,DISTANCIA_RESTA		;46d5
	inc a			;46d7
	ld (0e00dh),a		;46d8
	ret			;46db
DISTANCIA_RESTA:
	ld a,(hl)			;46dc   ; un metro por paso, en BCD
	sub 001h		;46dd   ; Un descuento por paso, en BCD, con el prestamo subiendo al byte alto
	daa			;46df
	ld (hl),a			;46e0
	ld c,a			;46e1   ; C se queda el byte bajo, que DISTANCIA_MIRA consulta
	inc hl			;46e2
	jr nc,DISTANCIA_MIRA		;46e3
	ld a,(hl)			;46e5
	sub 001h		;46e6
	daa			;46e8
	ld (hl),a			;46e9
DISTANCIA_MIRA:
	ld a,c			;46ea
	or a			;46eb
	jr nz,DISTANCIA_PINTA		;46ec
	or (hl)			;46ee   ; con el byte bajo a cero y el alto distinto, se acaba de cruzar una centena
	jr z,DISTANCIA_PINTA		;46ef
	ld a,(hl)			;46f1
	and 003h		;46f2   ; y de esas, una de cada cuatro: cada 400 metros
	jr nz,DISTANCIA_PINTA		;46f4
	inc a			;46f6
	ld (0e107h),a		;46f7   ; Cada 400 metros (?), 0xE107
DISTANCIA_PINTA:
	call MIRA_LA_CURVA		;46fa
PINTA_DISTANCIA:		; Las cuatro cifras de la distancia
	ld b,002h		;46fd   ; dos parejas: los cuatro digitos de la distancia
	ld de,0382fh		;46ff
	ld hl,0e0e6h		;4702
	jr PINTA_BCD		;4705
PINTA_FASE:		; Las dos cifras del numero de fase
	ld de,0381ch		;4707   ; la fase es un solo byte, dos digitos
	ld hl,0e0e0h		;470a
	ld b,001h		;470d
PINTA_BCD:		; Escribe B bytes BCD de (HL) hacia abajo en la VRAM (DE) hacia arriba, dos cifras por byte
	ld a,(hl)			;470f
	push af			;4710
	and 00fh		;4711
	or 010h		;4713   ; Los digitos empiezan en la casilla 0x10, que es el '0' de la fuente
	ld c,a			;4715   ; el nibble bajo se guarda en C mientras se saca el alto
	pop af			;4716   ; El mismo byte otra vez: ahora el nibble alto, bajado con las cuatro rotaciones
	and 0f0h		;4717
	rra			;4719
	rra			;471a
	rra			;471b
	rra			;471c
	or 010h		;471d
	call ESCRIBE_EN_VRAM		;471f
	inc de			;4722   ; el alto se escribe primero y el bajo detras, que en pantalla van en ese orden
	ld a,c			;4723
	call ESCRIBE_EN_VRAM		;4724
	dec hl			;4727   ; Los bytes BCD se recorren hacia abajo y la pantalla hacia arriba: van al reves
	inc de			;4728
	djnz PINTA_BCD		;4729
	ret			;472b

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; QUE DECORADO TOCA
; ----------------------------------------------------------------------
; Cuatro tablas encadenadas, y las cuatro cierran clavadas:
; 0x476E  dos bytes por fase; elige uno de los dos segun el
; bit 4 de la distancia -> 0xE18A
; 0x47AA  un puntero por fase, que apunta dentro de la tabla
; de abajo (las ventanas se solapan)
; 0x47BE  veinte punteros a las listas
; 0x4782  cinco listas de ocho bytes -> 0xE18B
; ----------------------------------------------------------------------
ELIGE_DECORADO:		; Segun la fase y la distancia, deja en 0xE18A y 0xE18B lo que toca dibujar a los lados de la pista
	ld a,(0e0e0h)		;472c   ; la fase, en su nibble bajo, elige la pareja de decorados
	and 00fh		;472f
	ld hl,0476eh		;4731
	add a,a			;4734   ; por dos: la tabla son parejas
	call SUMA_A_HL		;4735
	ld a,(0e0e6h)		;4738
	and 010h		;473b   ; Bit 4 de la distancia: uno u otro
	jr z,DECORADO_SEGUNDA		;473d
	inc hl			;473f
DECORADO_SEGUNDA:
	ld a,(hl)			;4740
	ld (0e18ah),a		;4741   ; 0xE18A se queda el byte del decorado elegido por la fase y el bit 4 de la distancia
	ld a,(0e0e0h)		;4744
	and 00fh		;4747
	ld hl,047aah		;4749
	add a,a			;474c
	call SUMA_A_HL		;474d
	ld e,(hl)			;4750   ; El puntero de la fase abre una VENTANA dentro de la tabla de veinte punteros; la distancia elige dentro de ella
	inc hl			;4751
	ld d,(hl)			;4752
	ex de,hl			;4753
	ld a,(0e0e6h)		;4754   ; La distancia, por cuartos
	and 0fch		;4757   ; los dos bits de abajo fuera y dos rotaciones: la distancia partida en cuartos de centena
	rrca			;4759
	rrca			;475a
	res 3,a		;475b
	cp 004h		;475d   ; por debajo de cuatro se coge la entrada tal cual
	jr c,DECORADO_INDICE		;475f
	dec a			;4761
DECORADO_INDICE:
	add a,a			;4762
	call SUMA_A_HL		;4763
	ld e,(hl)			;4766
	inc hl			;4767
	ld d,(hl)			;4768
	ex de,hl			;4769
	ld (0e18bh),hl		;476a   ; 0xE18B queda apuntando a la lista de ocho bytes que toca
	ret			;476d

; ----------------------------------------------------------------------
; DATOS decorado_por_fase: Dos bytes por fase, diez fases: 0x4731 los indexa y
;   el bit 4 de la distancia elige cual de los dos. Acaba justo donde empiezan
;   las listas
;   0x476e..0x4782  (20 bytes)
DATA_decorado_por_fase:
	defb 080h,000h	; 476e
	defb 0a0h,0a0h	; 4770
	defb 050h,050h	; 4772
	defb 0e0h,0e0h	; 4774
	defb 050h,050h	; 4776
	defb 000h,020h	; 4778
	defb 0e0h,0e0h	; 477a
	defb 020h,020h	; 477c
	defb 000h,000h	; 477e
	defb 0ffh,0ffh	; 4780

; ----------------------------------------------------------------------
; DATOS listas_de_decorado: Cinco listas de ocho bytes. Es a donde apuntan los
;   veinte punteros de 0x47BE, y acaban clavadas donde empieza la tabla de
;   fases
;   0x4782..0x47aa  (40 bytes)
DATA_listas_de_decorado:
	defb 001h,005h,0ffh,000h,012h,005h,0ffh,000h	; 4782  ........
	defb 011h,001h,000h,012h,000h,001h,012h,000h	; 478a  ........
	defb 000h,0ffh,003h,011h,001h,005h,0ffh,003h	; 4792  ........
	defb 000h,0ffh,003h,003h,000h,011h,001h,012h	; 479a  ........
	defb 005h,0ffh,005h,0ffh,003h,012h,005h,0ffh	; 47a2  ........

; ----------------------------------------------------------------------
; DATOS decorado_puntero_por_fase: Diez punteros, uno por fase, que apuntan
;   DENTRO de la tabla de al lado con ventanas que se solapan. 0x4749 lo
;   indexa
;   0x47aa..0x47be  (20 bytes)
DATA_decorado_puntero_por_fase:
	defw 047deh,047cch,047d4h,047deh,047d6h,047d8h,047e0h,047cch,047d8h,047beh	; 47aa

; ----------------------------------------------------------------------
; DATOS decorado_punteros: Veinte punteros a las cinco listas. Cierra clavado
;   en 0x47E6, donde vuelve a haber codigo
;   0x47be..0x47e6  (40 bytes)
DATA_decorado_punteros:
	defw 0479ah,04782h,0479ah,04782h,047a2h,04792h,04782h,04792h,0478ah,0479ah	; 47be
	defw 0478ah,04782h,0479ah,0478ah,04792h,0478ah,047a2h,0478ah,047a2h,0478ah	; 47d2

; ======================================================================
; CODIGO 0x47e6..0x4820  (58 bytes)
; ======================================================================


HAY_SORPRESA:		; Mientras 0xE18E este encendido devuelve C=3, y descuenta 0xE18F hasta apagarlo
	ld a,(0e18eh)		;47e6   ; la sorpresa es la que aparece de tarde en tarde y no en cada tramo
	rra			;47e9   ; El bit 0 de 0xE18E al acarreo: apagado, no hay sorpresa
	ret nc			;47ea
	ld hl,0e18fh		;47eb
	dec (hl)			;47ee   ; 0xE18F es la vida que le queda; al agotarse, la sorpresa se apaga sola
	jr nz,SORPRESA_SI		;47ef
	xor a			;47f1
	ld (0e18eh),a		;47f2
SORPRESA_SI:
	ld c,003h		;47f5   ; C = 3 al apagarse: es lo que el llamador lee para saber que ya no esta
	ret			;47f7
MIRA_SORPRESA:		; Enciende 0xE18E en ciertos multiplos de 100 metros, con la duracion que da la tabla de al lado
	ld a,(0e0e0h)		;47f8   ; la tabla de 0x4820 da la vida de la sorpresa, una por fase
	and 00fh		;47fb
	ld hl,04820h		;47fd
	call SUMA_A_HL		;4800
	ld de,(0e0e5h)		;4803
	ld a,d			;4807
	cp 004h		;4808   ; Solo con 400 metros o mas por delante
	ret c			;480a
	ld a,e			;480b   ; Y justo en la centena exacta
	or a			;480c
	ret nz			;480d
	ld a,(0e0e0h)		;480e
	add a,d			;4811   ; y la fase corre el reparto, asi que no salen siempre en los mismos sitios
	and 003h		;4812   ; Una de cada cuatro centenas, corrida segun la fase
	cp 002h		;4814
	ret nz			;4816
	inc a			;4817
	ld (0e18eh),a		;4818   ; encendida, con su vida cargada
	ld a,(hl)			;481b
	ld (0e18fh),a		;481c
	ret			;481f

; ----------------------------------------------------------------------
; DATOS duracion_sorpresa: Diez bytes, uno por fase: cuanto dura lo que
;   enciende 0x47F8. La fase 1 lleva 7 y las demas entre 2 y 6
;   0x4820..0x482a  (10 bytes)
DATA_duracion_sorpresa:
	defb 007h,002h,002h,003h,003h,004h,004h,005h,006h,006h	; 4820  ..........

; ======================================================================
; CODIGO 0x482a..0x48df  (181 bytes)
; ======================================================================


PREPARA_ROTULO:		; Limpia la pantalla y pone en blanco los colores del tercio de abajo para el rotulo
	call MONTA_LA_FUENTE		;482a
	ld de,01080h		;482d   ; Colores del banco 2, casillas 0x10 a 0x40
	ld bc,00180h		;4830
	ld a,070h		;4833   ; el 0x70 en los colores del banco 2 antes de escribir nada
	call RELLENA_VRAM		;4835
	xor a			;4838
	ld (0e00ah),a		;4839
	ld de,03966h		;483c   ; 0x13 casillas en 0x3966: el hueco del rotulo, limpio
	ld bc,00013h		;483f
	jp RELLENA_VRAM		;4842
DIBUJA_ROTULO:		; Dibuja una columna del rotulo por llamada, 23 columnas de dos casillas; devuelve C mientras queda
	ld hl,0e00ah		;4845   ; 0xE00A cuenta por que columna va el rotulo
	ld a,(hl)			;4848
	inc (hl)			;4849
	cp 017h		;484a   ; 23 columnas
	jr nc,ROTULO_ESPERA		;484c
	ld de,03885h		;484e   ; 0x3885 es la casilla por la que empieza
	ld c,a			;4851
	add a,e			;4852
	ld e,a			;4853
	ld a,c			;4854
	add a,a			;4855
	add a,0b2h		;4856   ; Las casillas van de dos en dos: 0xB2, 0xB4, 0xB6...
	ld c,a			;4858
	ld b,003h		;4859   ; tres escrituras por columna, una fila cada una
	xor a			;485b
ROTULO_COLUMNA:
	call ESCRIBE_EN_VRAM		;485c   ; La primera pasada escribe un 0 -la casilla vacia de encima- y las otras dos, las dos casillas del rotulo, una fila cada una
	ld a,020h		;485f   ; 0x20 casillas para bajar de fila
	call SUMA_A_DE		;4861
	ld a,c			;4864
	inc c			;4865
	djnz ROTULO_COLUMNA		;4866
	scf			;4868   ; El acarreo dice que quedan columnas
	ret			;4869
ROTULO_ESPERA:
	push af			;486a   ; y con las 23 columnas puestas, el copyright debajo
	ld hl,057a9h		;486b   ; "(c)KONAMI 1984"
	call ESCRIBE_CADENA		;486e
	pop af			;4871
	cp 034h		;4872   ; Y despues, 29 fotogramas mas de pausa antes de seguir
	ret c			;4874
	or a			;4875
	ret			;4876
SUBE_LOGO:		; Dibuja el logotipo -tres filas de 3, 11 y 12 casillas- una fila mas arriba cada vez, y borra el rastro que deja debajo
	ld hl,(0e00eh)		;4877   ; 0xE00E lleva la altura a la que va el logotipo
	ld de,00020h		;487a
	add hl,de			;487d   ; Una fila menos en cada llamada
	ld (0e00eh),hl		;487e
	ex de,hl			;4881
	or a			;4882
	ld hl,03aaah		;4883
	sbc hl,de		;4886
	ex de,hl			;4888
	ld a,044h		;4889   ; Las 26 casillas van seguidas desde la 0x44; las filas las corta el 0x0E - C de abajo: 3, 11 y 12 de ancho
	ld bc,00303h		;488b   ; tres filas y tres columnas para empezar
LOGO_FILA:
	push de			;488e
LOGO_CASILLA:
	call ESCRIBE_EN_VRAM		;488f
	inc de			;4892   ; A no se reinicia entre filas: las casillas van seguidas por todo el logotipo
	inc a			;4893
	djnz LOGO_CASILLA		;4894
	pop de			;4896
	ld hl,00020h		;4897
	add hl,de			;489a
	ex de,hl			;489b
	ld h,a			;489c
	ld a,00eh		;489d   ; B se recarga con 0x0E menos C: la fila de arriba lleva 3 casillas y las dos de abajo 11 y 12
	sub c			;489f
	ld b,a			;48a0
	ld a,h			;48a1
	dec c			;48a2
	jr nz,LOGO_FILA		;48a3
	ld bc,0000ch		;48a5   ; Borra las doce casillas que quedan debajo
	xor a			;48a8
	call RELLENA_VRAM		;48a9
	ld hl,0e00ah		;48ac
	dec (hl)			;48af
	ret			;48b0
ESCRIBE_EN_VRAM:		; Escribe el byte A en la VRAM DE: apunta con el bit de escritura y lo suelta por el puerto 0x98
	push af			;48b1   ; El byte se aparta en la pila porque A hace falta para la direccion
	set 6,d		;48b2   ; Bit 6: para escribir; y se quita para devolver DE intacto
	call APUNTA_VRAM		;48b4
	res 6,d		;48b7
	pop af			;48b9
	out (098h),a		;48ba
	ei			;48bc   ; El dato por el puerto 0x98
	ret			;48bd
LEE_DE_VRAM_MUERTA:		; Lee un byte de la VRAM. Nadie la llama: el juego solo escribe en pantalla
	call APUNTA_VRAM		;48be   ; leer es igual, pero sin encender el bit 6
	nop			;48c1   ; Los dos `nop` son la espera que el VDP pide entre la direccion y el dato; la gemela de escribir no los necesita
	nop			;48c2
	in a,(098h)		;48c3
	ei			;48c5
	ret			;48c6
APUNTA_VRAM:		; Manda DE al puerto 0x99 en dos escrituras, que es como se le dice al VDP donde va a escribir
	di			;48c7   ; Sale con las interrupciones PARADAS: las abre el que llama, cuando ha terminado con el VDP
	ld a,e			;48c8   ; Primero el byte bajo y luego el alto, los dos por el 0x99: asi se le dice al VDP donde va a escribir
	out (099h),a		;48c9
	ld a,d			;48cb
	out (099h),a		;48cc
	ret			;48ce
SUMA_A_HL:		; HL = HL + A
	add a,l			;48cf   ; suma A a HL de 16 bits, que el Z80 no tiene `add hl,a`
	ld l,a			;48d0
	ret nc			;48d1
	inc h			;48d2
	ret			;48d3
SUMA_A_DE:		; DE = DE + A
	add a,e			;48d4   ; y la misma para DE
	ld e,a			;48d5
	ret nc			;48d6
	inc d			;48d7
	ret			;48d8
ESTADO_15_MAPA:		; Estado 15: el mapa, en siete pasos
	ld a,(0e001h)		;48d9   ; el mapa tambien va por pasos, con su tabla
	call DESPACHA		;48dc

; ----------------------------------------------------------------------
; DATOS tabla_mapa: Los 7 destinos del CALL de 0x48DC. Cierra clavada contra
;   su primer destino. Son los pasos del estado 15, el mapa del recorrido.
;   0x48df..0x48ed  (14 bytes)
DATA_tabla_mapa:
	defw 048edh	; 48df  -> MAPA_0_PREPARA
	defw 04907h	; 48e1  -> MAPA_1_BORDE
	defw 0490eh	; 48e3  -> MAPA_2_FILA
	defw 04945h	; 48e5  -> MAPA_3_BORDE
	defw 0495fh	; 48e7  -> MAPA_4_TRAZO
	defw 0496ch	; 48e9  -> MAPA_5_TRAZA
	defw 049c3h	; 48eb  -> MAPA_6_ESPERA

; ======================================================================
; CODIGO 0x48ed..0x49d0  (227 bytes)
; ======================================================================


MAPA_0_PREPARA:		; Paso 0: prepara los punteros y pinta de blanco los colores del mapa
	ld hl,049d0h		;48ed   ; Aqui empiezan las filas del dibujo
	ld (0e0f2h),hl		;48f0
	ld hl,03884h		;48f3   ; Y esta es la casilla por la que se empieza a pintar
	ld (0e0f0h),hl		;48f6
	ld de,01080h		;48f9   ; los colores del banco 2 a 0xF4 antes de dibujar el mapa
	ld bc,00180h		;48fc
	ld a,0f4h		;48ff
	call RELLENA_VRAM		;4901
	jp SIGUIENTE_PASO		;4904
MAPA_1_BORDE:		; Paso 1: la linea de arriba del marco
	ld de,03883h		;4907   ; y el borde de arriba con el tile 0x92
	ld a,092h		;490a
	jr MAPA_BORDE		;490c
MAPA_2_FILA:		; Paso 2: una fila del mapa cada dos fotogramas, hasta el 0x00 que cierra los datos
	ld a,(0e003h)		;490e   ; una fila cada dos fotogramas: el mapa se dibuja a la vista
	rra			;4911
	ret c			;4912
	ld hl,(0e0f0h)		;4913
	ld a,020h		;4916   ; Baja una fila
	call SUMA_A_HL		;4918
	ld (0e0f0h),hl		;491b
	ex de,hl			;491e
	push de			;491f
	ld a,00ah		;4920   ; Limpia la fila antes de escribirla
	ld bc,00018h		;4922
	call RELLENA_VRAM		;4925
	pop de			;4928
	inc de			;4929   ; y por dentro el 4, 0x16 casillas: el marco deja una a cada lado
	ld a,004h		;492a
	ld c,016h		;492c
	call RELLENA_VRAM		;492e
	ld hl,(0e0f2h)		;4931
	ld a,(hl)			;4934
	inc hl			;4935
	or a			;4936
	jp z,SIGUIENTE_PASO		;4937   ; Un 0x00 en los datos: se acabo el dibujo
	ld e,a			;493a
	inc a			;493b
	jr z,MAPA_2_GUARDA		;493c   ; 0xFF: esta fila no lleva texto
	call ESCRIBE_CADENA_EN_DE		;493e
MAPA_2_GUARDA:
	ld (0e0f2h),hl		;4941
	ret			;4944
MAPA_3_BORDE:		; Paso 3: la linea de abajo del marco
	ld de,03aa3h		;4945   ; el borde de abajo: esquina, tramo de 24 y la otra esquina
	ld a,091h		;4948
MAPA_BORDE:
	call ESCRIBE_EN_VRAM		;494a
	inc de			;494d
	ld bc,00018h		;494e
	add a,004h		;4951   ; Tres casillas: la esquina (A), el tramo (A + 4, 24 veces) y la otra esquina (A + 2)
	push af			;4953
	call RELLENA_VRAM		;4954
	pop af			;4957
	sub 002h		;4958
	out (098h),a		;495a
	jp SIGUIENTE_PASO		;495c
MAPA_4_TRAZO:		; Paso 4: prepara el trazado del recorrido
	ld hl,03a14h		;495f   ; Por donde empieza el camino, en la tabla de nombres
	ld (0e0f4h),hl		;4962
	xor a			;4965
	ld (0e0f6h),a		;4966
	jp SIGUIENTE_PASO		;4969
MAPA_5_TRAZA:		; Paso 5: un paso del recorrido cada dos fotogramas
	ld a,(0e003h)		;496c   ; tambien uno de cada dos fotogramas
	rra			;496f
	ret c			;4970
	ld hl,0e0f6h		;4971
	ld a,(hl)			;4974
	ld de,04a7ah		;4975   ; El paso que toca, de la lista de 0x4A7A
	call SUMA_A_DE		;4978
	ld a,(de)			;497b
	ld (0e0d0h),a		;497c
	cp 020h		;497f   ; Un 0x20 cierra la lista
	jp z,SIGUIENTE_PASO		;4981
	inc (hl)			;4984
	ld c,097h		;4985
	ld a,(0e0e7h)		;4987   ; Hasta donde ha llegado el pinguino va de un color, y lo que falta de otro
	cp (hl)			;498a
	jr c,TRAZO_PARTE		;498b
	ld c,0a4h		;498d
TRAZO_PARTE:
	ld hl,0e0d0h		;498f
	xor a			;4992
	rrd		;4993   ; El RRD parte el byte: nibble bajo a B (la casilla) y nibble alto a A (la direccion)
	ld b,a			;4995
	ld a,(hl)			;4996
	ld hl,PASO_ARRIBA		;4997   ; El nibble alto indexa el codigo de abajo, que va de cuatro en cuatro bytes
	call SUMA_A_HL		;499a
	ld de,(0e0f4h)		;499d
	call SALTA_A_HL		;49a1
	ld (0e0f4h),de		;49a4
	ld a,b			;49a8
	add a,c			;49a9
	call ESCRIBE_EN_VRAM		;49aa
	scf			;49ad   ; el acarreo dice que quedan pasos por trazar
	ret			;49ae
SALTA_A_HL:		; El otro despachador: aqui A no indexa direcciones sino el codigo de abajo
	jp (hl)			;49af

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LOS CUATRO PASOS DEL RECORRIDO
; ----------------------------------------------------------------------
; Cuatro trozos de cuatro bytes justos, para que el nibble alto
; del dato (0, 4, 8 o C) caiga clavado en uno de ellos.
; ----------------------------------------------------------------------
PASO_ARRIBA:		; Una fila menos: -0x20
	ld a,0e0h		;49b0   ; arriba es restar 0x20, o sea sumar 0xE0
	jr PASO_ARRIBA_SUMA		;49b2
PASO_DERECHA:		; Una casilla mas
	ld a,001h		;49b4   ; y a la derecha, una casilla
	jr PASO_SUMA		;49b6
PASO_ABAJO:		; Una fila mas: +0x20
	ld a,020h		;49b8
	jr PASO_SUMA		;49ba
PASO_IZQUIERDA:		; Una casilla menos
	ld a,0ffh		;49bc
PASO_ARRIBA_SUMA:
	dec d			;49be
PASO_SUMA:
	call SUMA_A_DE		;49bf
	ret			;49c2
MAPA_6_ESPERA:		; Paso 6: espera y pone 0xE000 a 9, pero ESPERA_80_Y_ESTADO lo sube: cae en el estado 10, el que monta la fase (el 9 ya corrio antes del mapa)
	ld hl,0e004h		;49c3
	dec (hl)			;49c6
	ret nz			;49c7
	ld a,009h		;49c8   ; El 9 que ESPERA_80_Y_ESTADO subira a 10
	ld (0e000h),a		;49ca
	jp ESPERA_80_Y_ESTADO		;49cd

; ----------------------------------------------------------------------
; DATOS mapa_dibujo: Las filas del mapa, una detras de otra: un byte de
;   columna y detras las casillas, o un 0xFF si la fila va vacia. El 0x00 de
;   0x4AAF lo cierra. Son dieciseis filas, y la ultima es el rotulo ANTARCTICA
;   (c)KONAMI
;   0x49d0..0x4a7a  (170 bytes)
DATA_mapa_dibujo:
	defb 0ffh,0ceh,05eh,05fh,060h,061h,0ffh,0edh,062h,00fh,00fh,00fh,00fh,00fh,063h,064h	; 49d0  ..^_`a..b.....cd
	defb 065h,0ffh,008h,066h,004h,004h,004h,004h,067h,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 49e0  e..f....g.......
	defb 068h,0ffh,028h,069h,06ah,064h,088h,089h,07eh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 49f0  h.(ijd..~.......
	defb 06bh,0ffh,049h,06ch,06dh,07fh,007h,080h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,061h	; 4a00  k.Ilm..........a
	defb 0ffh,06ah,067h,081h,082h,00fh,00fh,00fh,08dh,08eh,08fh,090h,00fh,00fh,06eh,0ffh	; 4a10  .jg...........n.
	defb 08ah,06fh,00fh,00fh,00fh,00fh,00fh,08ch,00fh,00fh,00fh,00fh,00fh,070h,0ffh,0abh	; 4a20  .o...........p..
	defb 071h,00fh,00fh,083h,084h,00fh,00fh,00fh,00fh,00fh,00fh,072h,0ffh,0cbh,073h,00fh	; 4a30  q..........r..s.
	defb 00fh,085h,007h,086h,00fh,00fh,00fh,00fh,00fh,074h,0ffh,0ebh,069h,075h,076h,08ah	; 4a40  .........t..iuv.
	defb 08bh,087h,00fh,00fh,00fh,00fh,077h,0ffh,010h,078h,00fh,00fh,00fh,00fh,079h,0ffh	; 4a50  ......w..x....y.
	defb 030h,07ah,075h,07bh,07ch,07dh,0ffh,0ffh,06ch,021h,02eh,034h,021h,032h,023h,034h	; 4a60  0zu{|}..l!.4!2#4
	defb 029h,023h,021h,004h,004h,004h,004h,0ffh,0ffh,000h	; 4a70  )#!.......

; ----------------------------------------------------------------------
; DATOS mapa_recorrido: Los cuarenta pasos del camino: nibble alto la
;   direccion (0 arriba, 4 derecha, 8 abajo, C izquierda) y nibble bajo la
;   casilla que se dibuja. El 0x20 de 0x4AA2 lo cierra
;   0x4a7a..0x4aa3  (41 bytes)
DATA_mapa_recorrido:
	defb 0c4h,0c4h,0c0h,00bh,002h,002h,0c5h,00ch,0c5h,0c5h,0c6h,086h,087h,0c5h,002h,00ch	; 4a7a  ................
	defb 00ah,009h,048h,043h,00ch,00ch,001h,045h,045h,045h,042h,085h,047h,042h,082h,082h	; 4a8a  ..HC...EEEB.GB..
	defb 085h,04bh,082h,082h,08bh,0c4h,082h,08bh,020h	; 4a9a  .K...... 

; ----------------------------------------------------------------------
; DATOS tabla_de_fases: Las DIEZ fases, cuatro bytes cada una: centenas de
;   metros, casilla del mapa donde empieza, y el tiempo en BCD. Cierra clavada
;   en 0x4ACB, donde vuelve a haber codigo. Salen 1500 m/100 s, 1700/120,
;   1100/80, 1200/80, 1200/80, 500/40, 2600/165, 1200/90, 1500/100 y 1200/90
;   0x4aa3..0x4acb  (40 bytes)
DATA_tabla_de_fases:
	defb 015h,000h,000h,001h	; 4aa3
	defb 017h,003h,020h,001h	; 4aa7
	defb 011h,008h,080h,000h	; 4aab
	defb 012h,00ch,080h,000h	; 4aaf
	defb 012h,010h,080h,000h	; 4ab3
	defb 005h,015h,040h,000h	; 4ab7
	defb 026h,016h,065h,001h	; 4abb
	defb 012h,01dh,090h,000h	; 4abf
	defb 015h,022h,000h,001h	; 4ac3
	defb 012h,025h,090h,000h	; 4ac7

; ======================================================================
; CODIGO 0x4acb..0x4b4e  (131 bytes)
; ======================================================================


MONTA_LA_FASE:		; Prepara la fase entera: borra las variables de pista, carga los graficos y monta el decorado
	ld hl,0e0f0h		;4acb   ; Borra 0x130 bytes de variables de pista, obstaculos y sonido
	ld de,0e0f1h		;4ace
	ld bc,00130h		;4ad1
	ld (hl),000h		;4ad4   ; el `ld (hl),0` mas el `ldir` es el borrado clasico: se siembra el primero y se arrastra
	ldir		;4ad6
	ld a,010h		;4ad8
	ld h,a			;4ada
	ld l,a			;4adb
	ld (0e100h),hl		;4adc   ; Periodo inicial 0x10, cerca del tope lento: cada fase arranca despacio
	ld (0e110h),a		;4adf   ; 0xE110 es el otro periodo, el del decorado
	ld a,008h		;4ae2   ; 0xE149 arranca en 8
	ld (0e149h),a		;4ae4
	ld a,005h		;4ae7
	ld (0e0e9h),a		;4ae9   ; y 0xE0E9 en 5, que es lo que tarda el primer descuento de distancia
	ld hl,03030h		;4aec   ; Segun sea la fase par o impar, una pareja de casillas u otra
	ld a,(0e0e0h)		;4aef   ; el bit 0 de la fase: par o impar
	rra			;4af2
	jr nc,FASE_CASILLAS		;4af3
	ld hl,03434h		;4af5
FASE_CASILLAS:
	ld (0e10eh),hl		;4af8
	ld a,001h		;4afb
	ld (0e13bh),a		;4afd   ; Mientras se monta la fase no se puede empezar otra partida
	call CARGA_BANCO_1		;4b00   ; Los cuatro cargadores de graficos comprimidos
	call CARGA_BANCO_2		;4b03
	call CARGA_SPRITES		;4b06
	call MONTA_SPRITES_PARTIDA		;4b09
	call MONTA_LA_PISTA		;4b0c   ; Y el montaje de la pista
	xor a			;4b0f
	ld (0e13bh),a		;4b10   ; montada la fase, se levanta el cerrojo
	ret			;4b13

; ----------------------------------------------------------------------
; ############################################################
; UN PASO DE PARTIDA
; ############################################################
; ----------------------------------------------------------------------
PASO_DE_PARTIDA:		; Todo lo que pasa en un fotograma de juego
	call PINTA_VELOCIMETRO		;4b14   ; el paso de partida empieza por lo que se ve: el velocimetro y el pez
	call MUEVE_EL_PEZ		;4b17
	ld a,(0e140h)		;4b1a   ; 0xE140: esta en el agua, y entonces no se juega
	or a			;4b1d
	jp nz,SIGUE_EN_EL_AGUA		;4b1e
	ld a,(0e142h)		;4b21   ; 0xE142: se esta cayendo
	or a			;4b24
	jp nz,SIGUE_CAIDA		;4b25
	call AJUSTA_DIFICULTAD		;4b28   ; la dificultad se ajusta antes de leer el mando
	call MUEVE_PINGUINO		;4b2b   ; Los mandos
	call ARRASTRA_PINGUINO		;4b2e
	call MIRA_EL_PEZ		;4b31   ; El pez
	call MIRA_EL_BORDE		;4b34   ; y el borde se mira despues de moverse, no antes
	ld a,(0e140h)		;4b37   ; si se ha caido al agua, la pista ya no avanza en este paso
	or a			;4b3a
	ret nz			;4b3b
	call AVANZA_LA_PISTA		;4b3c
	call DIBUJA_LA_META		;4b3f
	call AVANZA_DISTANCIA		;4b42   ; La distancia que queda y el decorado que toca
	call ELIGE_DECORADO		;4b45
	call CREA_OBSTACULO		;4b48   ; y por ultimo los obstaculos nuevos y las nubes
	jp LAS_NUBES		;4b4b

; ----------------------------------------------------------------------
; DATOS poses_del_pinguino: Diez poses de cuatro bytes: los cuatro patrones de
;   sprite que forman el pinguino en cada postura. 0x4B9F las reparte de
;   cuatro en cuatro por los atributos
;   0x4b4e..0x4b76  (40 bytes)
DATA_poses_del_pinguino:
	defb 000h,004h,008h,00ch	; 4b4e
	defb 010h,014h,018h,01ch	; 4b52
	defb 020h,024h,028h,02ch	; 4b56
	defb 000h,004h,030h,034h	; 4b5a
	defb 038h,03ch,040h,044h	; 4b5e
	defb 060h,064h,068h,06ch	; 4b62
	defb 020h,048h,04ch,050h	; 4b66
	defb 054h,014h,058h,05ch	; 4b6a
	defb 010h,0a8h,018h,0ach	; 4b6e
	defb 0b0h,024h,0b4h,02ch	; 4b72

; ======================================================================
; CODIGO 0x4b76..0x4c4a  (212 bytes)
; ======================================================================


MUEVE_PINGUINO:		; Lee los mandos y mueve al pinguino, o sigue el salto si ya estaba saltando
	ld hl,0e0f9h		;4b76   ; 0xE0F9 distinto de cero: hay un salto en marcha
	ld a,(hl)			;4b79
	or a			;4b7a
	jp nz,SIGUE_SALTO		;4b7b
	call LEE_GATILLOS_NUEVOS		;4b7e   ; Gatillo recien pulsado: empieza el salto
	jp nz,EMPIEZA_SALTO		;4b81
	ld a,b			;4b84   ; B trae el mando: en el salto solo importan los bits de los lados
	ld de,(0e078h)		;4b85   ; Posicion actual: E la Y, D la X
	call MUEVE_A_LOS_LADOS		;4b89
PINGUINO_COLOCA:
	ex de,hl			;4b8c
PINGUINO_SPRITES:
	call COLOCA_SPRITES		;4b8d
PINGUINO_A_VRAM:		; Vuelca los cuatro atributos del pinguino a la VRAM
	ld hl,0e078h		;4b90
	ld de,03b28h		;4b93   ; Sprites 10 a 13
	ld bc,00010h		;4b96   ; 0x10 bytes: cuatro atributos de cuatro
	call COPIA_A_VRAM		;4b99
	jp COLOCA_SOMBRA		;4b9c
PONE_POSE:		; Copia los cuatro patrones de la pose A a los atributos, saltando de cuatro en cuatro
	exx			;4b9f   ; la pose se escribe en el juego alterno para no gastar los registros del llamador
	ld hl,04b4eh		;4ba0   ; la tabla de 0x4B4E son los cuatro patrones de cada pose
	call SUMA_A_HL		;4ba3
	ld de,0e07ah		;4ba6
	ld b,004h		;4ba9
POSE_BUCLE:
	ld a,(hl)			;4bab
	ld (de),a			;4bac
	ld a,004h		;4bad   ; De cuatro en cuatro: el campo de patron de cada uno de los cuatro atributos
	add a,e			;4baf
	ld e,a			;4bb0
	inc hl			;4bb1
	djnz POSE_BUCLE		;4bb2
	exx			;4bb4
	ret			;4bb5
COLOCA_SPRITES:		; Reparte HL (Y en L, X en H) por los cuatro sprites, sumando 16 a la derecha y abajo
	ld d,h			;4bb6   ; El pinguino son cuatro sprites de 16x16 en cuadro: 0xE078, 0xE07C, 0xE080 y 0xE084
	ld (0e078h),hl		;4bb7
	ld a,h			;4bba
	add a,010h		;4bbb   ; la pareja de la derecha, 16 pixeles mas alla
	ld h,a			;4bbd
	ld (0e07ch),hl		;4bbe
	ld a,l			;4bc1
	add a,010h		;4bc2   ; Con la Y bajada 16, la pareja de abajo
	ld l,a			;4bc4
	ld e,a			;4bc5
	ld (0e080h),de		;4bc6
	ld (0e084h),hl		;4bca
	ret			;4bcd

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; EL SALTO
; ----------------------------------------------------------------------
; Once pasos, uno cada cuatro fotogramas, contados en 0xE0F9.
; Mientras dura, la Y del pinguino se corrige con la curva de
; 0x4C4A, que sube cuatro pixeles y baja otros cuatro; y si el
; gatillo se pulso con una direccion metida, ademas se mueve al
; doble de velocidad hacia ese lado.
; ----------------------------------------------------------------------
EMPIEZA_SALTO:		; Gatillo: suena el salto y se apunta hacia donde va
	ld a,002h		;4bce
	call PIDE_SONIDO		;4bd0   ; Sonido 2
	ld a,b			;4bd3   ; el mando se mira una sola vez, al arrancar el salto: lo que se pulse despues ya no cambia el rumbo
	and 00ch		;4bd4   ; Bits 2 y 3: izquierda y derecha
	jr z,SALTO_SENTIDO		;4bd6
	ld a,(0e0fah)		;4bd8
	and 003h		;4bdb
SALTO_SENTIDO:
	ld (0e0fbh),a		;4bdd
	jr SALTO_PASO		;4be0
SIGUE_SALTO:		; Un paso de salto cada cuatro fotogramas
	ld a,(0e003h)		;4be2   ; el salto avanza uno de cada cuatro fotogramas
	and 003h		;4be5
	ret nz			;4be7
SALTO_PASO:
	ld a,(hl)			;4be8
	inc (hl)			;4be9   ; el paso sube y el valor leido es el de antes
	cp 00bh		;4bea   ; Once pasos y vuelta a cero
	jr nz,SALTO_POSE		;4bec
	ld (hl),000h		;4bee
SALTO_POSE:
	push af			;4bf0
	ld c,000h		;4bf1   ; Tres poses: al rematar (paso 11) la de parado (0); durante el salto alternan la 0x10 y la 0x0C con el bit 0 del paso
	cp 00bh		;4bf3
	jr z,SALTO_COLOCA		;4bf5
	ld c,010h		;4bf7
	rra			;4bf9
	jr c,SALTO_COLOCA		;4bfa
	ld c,00ch		;4bfc
SALTO_COLOCA:
	ld a,c			;4bfe
	call PONE_POSE		;4bff
	pop af			;4c02
	ld hl,04c4ah		;4c03   ; La curva del salto, que se suma a la Y
	call SUMA_A_HL		;4c06
	ld a,(hl)			;4c09
	ld de,(0e078h)		;4c0a   ; la altura se le suma a la Y del pinguino
	add a,e			;4c0e
	ld e,a			;4c0f
	ld hl,0e0fbh		;4c10
	ld a,(hl)			;4c13
	dec a			;4c14
	jr z,SALTO_A_LA_IZQUIERDA		;4c15   ; 0xE0FB dice si el salto lleva ademas movimiento lateral
	dec a			;4c17
	jr z,SALTO_A_LA_DERECHA		;4c18
SALTO_TERMINA:
	ex de,hl			;4c1a
	call PINGUINO_SPRITES		;4c1b
	ld a,(0e0f9h)		;4c1e   ; si el salto se acabo en este paso, no se miran choques
	or a			;4c21
	ret nz			;4c22
	call MIRA_CHOQUES		;4c23   ; La sombra
	ld a,(0e140h)		;4c26   ; ni en el agua ni cayendose se puntua el salto
	ld hl,0e142h		;4c29
	add a,(hl)			;4c2c
	ret nz			;4c2d
	ld hl,0e132h		;4c2e   ; 0xE132 evita cobrar el mismo salto dos veces
	cp (hl)			;4c31
	ret z			;4c32
	ld (hl),a			;4c33
	ld de,00030h		;4c34   ; Treinta puntos por saltar (?)
	jp SUMA_AL_MARCADOR		;4c37
SALTO_A_LA_IZQUIERDA:
	call MUEVE_IZQUIERDA		;4c3a   ; el salto lateral mueve DOS casillas, no una: por eso las dos llamadas seguidas
	call MUEVE_IZQUIERDA		;4c3d
	jr SALTO_TERMINA		;4c40
SALTO_A_LA_DERECHA:
	call MUEVE_DERECHA		;4c42
	call MUEVE_DERECHA		;4c45
	jr SALTO_TERMINA		;4c48

; ----------------------------------------------------------------------
; DATOS curva_del_salto: Doce correcciones con signo para la Y del pinguino:
;   -4,-3,-3,-2,-1,-1,+1,+1,+2,+3,+3,+4. Es el arco del salto, y tambien el
;   balanceo de andar
;   0x4c4a..0x4c56  (12 bytes)
DATA_curva_del_salto:
	defb 0fch,0fdh,0fdh,0feh,0ffh,0ffh,001h,001h,002h,003h,003h,004h	; 4c4a  ............

; ======================================================================
; CODIGO 0x4c56..0x4cf4  (158 bytes)
; ======================================================================


MUEVE_A_LOS_LADOS:		; Mueve al pinguino a izquierda o derecha segun los bits 2 y 3 de los mandos
	and 00ch		;4c56   ; Sin izquierda ni derecha no hay nada que hacer
	ret z			;4c58
	ld hl,0e0fah		;4c59
	cp 00ch		;4c5c   ; Las dos a la vez: se mantiene el sentido que llevaba
	jr z,MANTIENE_SENTIDO		;4c5e
	res 7,(hl)		;4c60
	cp 004h		;4c62
	jr nz,MUEVE_DERECHA		;4c64
MUEVE_IZQUIERDA:		; Una columna a la izquierda; el borde esta en X=0x14
	ld a,d			;4c66   ; con la columna por debajo de 0x14 no se puede ir mas a la izquierda
	cp 014h		;4c67
	ret c			;4c69
	dec d			;4c6a
	set 0,(hl)		;4c6b   ; Los bits 0 y 1 de 0xE0FA apuntan el ultimo sentido: izquierda enciende el 0 y apaga el 1
	res 1,(hl)		;4c6d
	ret			;4c6f
MANTIENE_SENTIDO:		; Con las dos direcciones metidas, la primera vez INVIERTE el sentido que llevaba y lo deja apuntado (bit 7 de 0xE0FA); las siguientes repite el nuevo
	ld a,(hl)			;4c70   ; 0xE0FA a cero: no habia sentido anterior que mantener
	or a			;4c71
	ret z			;4c72
	bit 7,a		;4c73   ; El bit 7 marca el empate ya resuelto: la primera vez se invierte el sentido (bit 1: venia de la derecha) y las siguientes se repite el nuevo (bit 0)
	jr z,SENTIDO_CAMBIA		;4c75
	bit 0,a		;4c77
	jr nz,MUEVE_IZQUIERDA		;4c79
	jr MUEVE_DERECHA		;4c7b
SENTIDO_CAMBIA:
	set 7,(hl)		;4c7d
	bit 1,a		;4c7f
	jr nz,MUEVE_IZQUIERDA		;4c81
MUEVE_DERECHA:		; Una columna a la derecha; el borde esta en X=0xCC
	ld a,d			;4c83
	cp 0cch		;4c84   ; y por la derecha el tope es 0xCC
	ret nc			;4c86
	set 1,(hl)		;4c87   ; El espejo de la izquierda: enciende el bit 1 y apaga el 0
	res 0,(hl)		;4c89
	inc d			;4c8b
	ret			;4c8c
ANIMA_ANDAR:		; Las tres poses de andar, una cada ocho fotogramas. La llama la interrupcion, no el paso de partida
	ld hl,0e0f9h		;4c8d   ; Ni saltando ni en la escena de la base
	ld a,(0e130h)		;4c90
	or (hl)			;4c93
	ret nz			;4c94
	ld a,(0e003h)		;4c95   ; uno de cada ocho fotogramas: una zancada
	and 007h		;4c98
	ret nz			;4c9a
ANDAR_PASO:
	ld hl,0e0f8h		;4c9b
	inc (hl)			;4c9e   ; 0xE0F8 cuenta las zancadas
	ld a,(hl)			;4c9f
	ld c,000h		;4ca0   ; Los bits 0-1 de la cuenta reparten el ciclo de poses 0, 4, 0, 8: el paso central entre cada zancada
	rra			;4ca2
	jr nc,ANDAR_POSE		;4ca3
	ld c,004h		;4ca5
	rra			;4ca7
	jr nc,ANDAR_POSE		;4ca8
	ld c,008h		;4caa
ANDAR_POSE:
	ld a,c			;4cac
	call PONE_POSE		;4cad
	jp PINGUINO_A_VRAM		;4cb0
COLOCA_SOMBRA:		; Los dos sprites de debajo del pinguino; en el salto y en la caida las dos mitades se MONTAN una sobre otra y la sombra se estrecha cuanto mas alto va
	ld hl,(0e078h)		;4cb3
	ld a,l			;4cb6   ; la sombra va 0x1E pixeles mas abajo y 0x10 a la derecha del pinguino
	add a,01eh		;4cb7
	ld l,a			;4cb9
	ld c,a			;4cba
	ld a,h			;4cbb
	add a,010h		;4cbc
	ld b,a			;4cbe
	ld de,04cf3h		;4cbf   ; La tabla del salto, apuntada un byte antes (ver la nota de abajo)
	ld a,(0e0f9h)		;4cc2
	or a			;4cc5
	jr nz,SOMBRA_SEPARA		;4cc6
	ld de,04cfdh		;4cc8   ; Y la de la caida
	ld a,(0e143h)		;4ccb
	or a			;4cce
	jr z,SOMBRA_GUARDA		;4ccf
SOMBRA_SEPARA:
	ex de,hl			;4cd1   ; la tabla se recorre con el paso de la caida
	call SUMA_A_HL		;4cd2
	ld l,(hl)			;4cd5
	ld a,d			;4cd6   ; La separacion se SUMA a la mitad izquierda y se RESTA a la derecha: las medias sombras se montan y la sombra se estrecha
	add a,l			;4cd7
	ld d,a			;4cd8
	ld a,b			;4cd9
	sub l			;4cda
	ld b,a			;4cdb
	ld e,0aeh		;4cdc   ; La Y de la sombra se clava en 0xAE, el suelo: no acompana al pinguino
	ld c,0aeh		;4cde
	ex de,hl			;4ce0
SOMBRA_GUARDA:
	ld (0e0a0h),hl		;4ce1   ; las dos mitades de la sombra van a 0xE0A0 y 0xE0A4
	ld (0e0a4h),bc		;4ce4
SOMBRA_A_VRAM:
	ld hl,0e0a0h		;4ce8
	ld de,03b50h		;4ceb   ; Sprites 20 y 21
	ld bc,00008h		;4cee   ; ocho bytes: los dos atributos de la sombra
	jp COPIA_A_VRAM		;4cf1

; ----------------------------------------------------------------------
; DATOS arco_del_salto: Diez alturas, indexadas de 1 a 10 desde 0x4CF3: lo que
;   se separa la sombra en cada paso del salto
;   0x4cf4..0x4cfe  (10 bytes)

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; TRES TABLAS QUE SE APUNTAN UN BYTE ANTES DE EMPEZAR
; ----------------------------------------------------------------------
; El indice de las tres empieza en 1, nunca en 0, asi que en vez
; de restarle uno se apunta a la direccion anterior y se deja
; que el byte 0 caiga donde caiga: 0x4CF3 es el ultimo byte de un
; `jp`, 0x4CFD es el ultimo dato de la tabla de encima y 0x4EB6
; es un RET. Ninguna de las tres lee su byte cero.
; ----------------------------------------------------------------------
DATA_arco_del_salto:
	defb 001h,002h,002h,003h,003h,003h,003h,003h,002h,002h	; 4cf4  ..........

; ----------------------------------------------------------------------
; DATOS arco_de_la_caida: Veintiuna alturas, indexadas de 1 a 21 desde 0x4CFD
;   con 0xE143, que es el contador de la caida. Cierra clavada en 0x4D13
;   0x4cfe..0x4d13  (21 bytes)
DATA_arco_de_la_caida:
	defb 001h,001h,002h,002h,003h,002h,002h,001h,000h,001h,002h,002h,002h,001h,000h,001h	; 4cfe  ................
	defb 002h,002h,002h,001h,000h	; 4d0e

; ======================================================================
; CODIGO 0x4d13..0x4d92  (127 bytes)
; ======================================================================


MIRA_CHOQUES:		; Con el pinguino en el suelo: recorre las fichas y mira si alguna esta en el paso 13 a su altura
	ld a,(0e0f9h)		;4d13   ; saltando no se choca con nada: se pasa por encima
	or a			;4d16
	ret nz			;4d17
	ld b,004h		;4d18   ; cuatro fichas de obstaculo, cinco a partir de la fase 5
	ld a,(0e0e0h)		;4d1a   ; A partir de la fase 5 hay una ficha mas
	cp 005h		;4d1d
	jr c,CHOQUES_EMPIEZA		;4d1f
	inc b			;4d21
CHOQUES_EMPIEZA:
	ld hl,0e112h		;4d22
CHOQUES_FICHA:
	ld a,(hl)			;4d25
	cp 00dh		;4d26   ; El paso 13 es el que esta a la altura del pinguino
	ld a,005h		;4d28
	jr nz,CHOQUES_SIGUIENTE		;4d2a
	inc hl			;4d2c
	ld c,(hl)			;4d2d
	inc hl			;4d2e
	inc hl			;4d2f
	inc hl			;4d30
	ld e,(hl)			;4d31
	inc hl			;4d32
	ld d,(hl)			;4d33
	ex de,hl			;4d34
	dec a			;4d35   ; el tipo se compara con 5: los de mas arriba son objetos que se cogen
	cp c			;4d36
	ld a,(0e079h)		;4d37   ; La X del pinguino
	jr nc,CHOQUES_AGUJERO		;4d3a
	sub (hl)			;4d3c
	inc hl			;4d3d
	cp (hl)			;4d3e
	jp c,COGE_OBJETO		;4d3f   ; Tipos 5 y 6: se cogen y dan puntos
	jr CHOQUES_NADA		;4d42
CHOQUES_AGUJERO:
	ld c,(hl)			;4d44   ; el hueco tiene dos zonas: el agua por dentro y el borde por fuera
	dec c			;4d45
	jr z,CHOQUES_BORDE		;4d46
	ld c,a			;4d48
	sub (hl)			;4d49
	inc hl			;4d4a
	cp (hl)			;4d4b
	jp c,CAE_AL_AGUA		;4d4c   ; El hueco de dentro: se cae al agua
	ld a,c			;4d4f
CHOQUES_BORDE:
	inc hl			;4d50
	sub (hl)			;4d51
	inc hl			;4d52
	cp (hl)			;4d53
	jp c,TROPIEZA		;4d54   ; Y el borde: tropieza
CHOQUES_NADA:
	ex de,hl			;4d57
	xor a			;4d58
CHOQUES_SIGUIENTE:
	inc a			;4d59   ; seis bytes de una ficha a la siguiente
	call SUMA_A_HL		;4d5a
	djnz CHOQUES_FICHA		;4d5d
	ret			;4d5f
MIRA_CHOQUES_SALTANDO:		; Lo mismo, pero en el aire: solo mira una lista propia, la de 0x4D92
	ld a,(0e0f9h)		;4d60   ; esta es la gemela de arriba para cuando SI se esta saltando
	or a			;4d63
	ret z			;4d64
	ld b,005h		;4d65   ; aqui siempre son cinco fichas
	ld hl,0e112h		;4d67
SALTANDO_FICHA:
	ld a,(hl)			;4d6a
	inc hl			;4d6b
	cp 00dh		;4d6c   ; Solo las fichas que van por el paso 0x0D
	ld a,005h		;4d6e   ; El 5 mas el `inc hl` de arriba: seis bytes por ficha
	jr nz,SALTANDO_SIGUIENTE		;4d70
	ex de,hl			;4d72
	ld a,(de)			;4d73
	cp 005h		;4d74   ; el `cp 5` y el `add a,a` juntos: el tipo por dos, que la tabla son parejas
	add a,a			;4d76
	ld hl,04d92h		;4d77
	call SUMA_A_HL		;4d7a
	ld a,(0e079h)		;4d7d   ; La X del pinguino contra el par (posicion, ancho): dentro del ancho, se ha saltado por encima
	sub (hl)			;4d80
	inc hl			;4d81
	cp (hl)			;4d82
	jr c,SALTANDO_ACIERTA		;4d83
	ex de,hl			;4d85
SALTANDO_SIGUIENTE:
	call SUMA_A_HL		;4d86   ; y a la ficha siguiente
	djnz SALTANDO_FICHA		;4d89
	ret			;4d8b
SALTANDO_ACIERTA:
	ld a,001h		;4d8c   ; 0xE132: se ha saltado por encima, y eso se premia en 0x4C34
	ld (0e132h),a		;4d8e
	ret			;4d91

; ----------------------------------------------------------------------
; DATOS choque_en_el_aire: Cinco pares (posicion, ancho) para los choques con
;   el pinguino saltando: 0x58/0x30, 0x18/0x30, 0x98/0x30, 0x2C/0x58 y
;   0x64/0x58
;   0x4d92..0x4d9c  (10 bytes)
DATA_choque_en_el_aire:
	defb 058h,030h	; 4d92
	defb 018h,030h	; 4d94
	defb 098h,030h	; 4d96
	defb 02ch,058h	; 4d98
	defb 064h,058h	; 4d9a

; ======================================================================
; CODIGO 0x4d9c..0x4eb7  (283 bytes)
; ======================================================================


MIRA_EL_PEZ:		; Si el pinguino pisa el pez, suena, se lo lleva y suma 300 puntos
	ld a,(0e142h)		;4d9c   ; ni en el agua ni cayendose se puede coger el pez
	ld hl,0e140h		;4d9f
	add a,(hl)			;4da2
	ret nz			;4da3
	ld de,(0e188h)		;4da4   ; 0xE188 es donde esta el pez
	ld a,e			;4da8
	cp 0e0h		;4da9   ; 0xE0 en la Y: el pez no esta en la pantalla
	ret z			;4dab
	ld hl,(0e078h)		;4dac
	sub l			;4daf
	ld e,a			;4db0
	sub 00ah		;4db1   ; Tiene que estar a menos de diez pixeles en vertical
	ret nc			;4db3
	ld a,013h		;4db4   ; la caja del pez no es un rectangulo: el ancho depende de la diferencia de altura, asi que es un rombo
	add a,e			;4db6
	ld l,a			;4db7
	ld a,e			;4db8
	add a,a			;4db9
	add a,017h		;4dba
	ld e,a			;4dbc
	ld a,d			;4dbd
	sub h			;4dbe
	sub l			;4dbf
	add a,e			;4dc0
	ret nc			;4dc1
	ld a,007h		;4dc2
	call PIDE_SONIDO		;4dc4   ; Sonido 7
	ld hl,0e08ch		;4dc7   ; cogido el pez, se le quita de la pantalla y se avanza su ciclo
	ld de,0e183h		;4dca
	call QUITA_EL_PEZ		;4dcd
	call PEZ_PASO		;4dd0
	ld de,00300h		;4dd3   ; Trescientos puntos
	jp SUMA_AL_MARCADOR		;4dd6
MIRA_EL_BORDE:		; Choque con lo que haya en 0xE090 cuando esta abajo del todo
	ld hl,(0e090h)		;4dd9   ; la foca solo pilla cuando esta asomada del todo
	ld a,l			;4ddc
	cp 08fh		;4ddd   ; Solo con la Y de 0xE090 en 0x8F: la foca asomada del todo
	ret nz			;4ddf
	ld a,(0e079h)		;4de0
	ld l,a			;4de3
	ld a,h			;4de4
	sub l			;4de5
	push af			;4de6
	sub 018h		;4de7   ; La pareja `sub`/`add` deja el acarreo con la diferencia de X entre -11 y +23: el ancho del choque
	add a,023h		;4de9
	jp c,CHOCA		;4deb
	pop af			;4dee
	ret			;4def
TROPIEZA:		; El pinguino tropieza y rueda hacia el lado por el que iba
	ld a,(0e135h)		;4df0   ; Durante la escena de la base no se tropieza
	or a			;4df3
	ret nz			;4df4
	ld a,003h		;4df5   ; el sonido 3 es el tropiezo
	call PIDE_SONIDO		;4df7   ; Sonido 3
	ld hl,00101h		;4dfa   ; el bit 0 de 0xE0FA -el ultimo sentido- decide hacia donde se cae
	ld a,(0e0fah)		;4dfd
	cpl			;4e00
	rra			;4e01
	jr PONE_CAIDA		;4e02
CHOCA:		; Choque de frente: se cae hacia atras
	ld hl,00101h		;4e04   ; y esta es la caida al agua, con su sonido 8
	ld (0e136h),hl		;4e07
	ld a,008h		;4e0a
	call PIDE_SONIDO		;4e0c   ; Sonido 8
	ld hl,00102h		;4e0f
	ld a,(0e0f9h)		;4e12   ; cayendo desde un salto la cuenta empieza un paso mas alla
	or a			;4e15
	jr z,CAIDA_RECUPERA		;4e16
	inc l			;4e18
CAIDA_RECUPERA:
	pop af			;4e19
PONE_CAIDA:		; Deja la caida montada en 0xE142 y le pone la pose
	ld (0e142h),hl		;4e1a
	ld a,020h		;4e1d   ; Pose 0x20 o 0x24 segun el lado
	jr nc,CAIDA_POSE		;4e1f
	ld a,024h		;4e21
CAIDA_POSE:
	ld (0e144h),a		;4e23
	call PONE_POSE		;4e26
	call PINGUINO_A_VRAM		;4e29
	ld hl,01313h		;4e2c   ; Y el periodo SUBE a 0x13, o sea que al caerse se queda a la minima velocidad
	ld (0e100h),hl		;4e2f
	ret			;4e32
SIGUE_CAIDA:		; Un paso de caida cada cuatro fotogramas: rueda de lado y baja
	ld a,(0e003h)		;4e33   ; la caida avanza uno de cada cuatro fotogramas, como el salto
	and 003h		;4e36
	ret nz			;4e38
	ld hl,0e142h		;4e39
	ld a,(hl)			;4e3c
	cp 003h		;4e3d   ; Tres pasos y se acaba
	jp z,CAIDA_TERCER_PASO		;4e3f
	inc hl			;4e42
	ld a,(hl)			;4e43   ; y su propio contador de paso
	inc (hl)			;4e44
	ld hl,RET_COMPARTIDO		;4e45   ; El desplazamiento de este paso, apuntado un byte antes
	call SUMA_A_HL		;4e48
	ld c,(hl)			;4e4b   ; C se queda el desplazamiento de este paso
	ld de,(0e078h)		;4e4c
CAIDA_LADO:
	ld hl,0e0d0h		;4e50
	ld a,(0e144h)		;4e53
	bit 2,a		;4e56   ; Bit 2 de 0xE144: hacia que lado rueda
	call z,TRES_A_LA_IZQUIERDA		;4e58
	call nz,TRES_A_LA_DERECHA		;4e5b
	ld hl,0e142h		;4e5e   ; Mientras 0xE142 pase de 1, otra tanda: el tropiezo entra con 1, el choque con 2 y el choque saltando con 3 tandas de tres columnas
	ld a,(hl)			;4e61
	dec a			;4e62
	jr z,CAIDA_COLOCA		;4e63
	dec (hl)			;4e65
	jr CAIDA_LADO		;4e66
CAIDA_COLOCA:
	ex de,hl			;4e68
	ld a,l			;4e69   ; el desplazamiento se le suma a la Y y se recolocan los cuatro sprites
	add a,c			;4e6a
	ld l,a			;4e6b
	call PINGUINO_SPRITES		;4e6c
	ld a,(0e078h)		;4e6f
	cp 090h		;4e72   ; Y=0x90: ya ha llegado abajo
	jr nz,CAIDA_CUENTA		;4e74
CAIDA_ABAJO:
	ld a,004h		;4e76
	call PIDE_SONIDO		;4e78   ; Sonido 4
	call PISTA_GRUPO_B		;4e7b   ; al tocar el suelo se cambia de grupo de pista y se pasa a la siguiente
	call PISTA_SIGUIENTE		;4e7e
	xor a			;4e81
	ld b,a			;4e82
	ld hl,0e136h		;4e83   ; Si 0xE136 (el choque de frente) estaba puesto, se apaga y el repintado corre con 0xE135 levantado
	cp (hl)			;4e86
	jr z,CAIDA_REPINTA		;4e87
	ld (hl),a			;4e89
	inc a			;4e8a
	ld (0e135h),a		;4e8b
CAIDA_REPINTA:
	call MUEVE_OBSTACULOS		;4e8e   ; los obstaculos se mueven con el repintado especial levantado
	xor a			;4e91
	ld (0e135h),a		;4e92
CAIDA_CUENTA:
	ld hl,0e143h		;4e95
	ld a,(hl)			;4e98
	sub 015h		;4e99   ; Veintiun pasos y se acabo la caida
	ret nz			;4e9b
	ld (hl),a			;4e9c
	dec hl			;4e9d   ; los tres contadores de la caida a cero
	ld (hl),a			;4e9e
	ld (0e137h),a		;4e9f
	ret			;4ea2
TRES_A_LA_DERECHA:		; Tres columnas de golpe
	call MUEVE_DERECHA		;4ea3   ; tres a la derecha de una vez: la caida arrastra tres columnas por tanda
	call MUEVE_DERECHA		;4ea6
	jp MUEVE_DERECHA		;4ea9
TRES_A_LA_IZQUIERDA:
	call MUEVE_IZQUIERDA		;4eac   ; y su espejo, tres a la izquierda
	call MUEVE_IZQUIERDA		;4eaf
	call MUEVE_IZQUIERDA		;4eb2
	xor a			;4eb5
RET_COMPARTIDO:		; Un RET que ademas hace de base de la tabla de al lado
	ret			;4eb6

; ----------------------------------------------------------------------
; DATOS rodada_de_la_caida: Veinte desplazamientos con signo, indexados de 1 a
;   20 desde 0x4EB6 con 0xE143. Son tres tramos casi iguales: cada vuelta el
;   pinguino rueda un poco menos
;   0x4eb7..0x4ecb  (20 bytes)
DATA_rodada_de_la_caida:
	defb 0fdh,0feh,0feh,0ffh,001h,002h,002h,003h,0feh,0feh,0ffh,001h,002h,002h,0feh,0feh	; 4eb7  ................
	defb 0ffh,001h,002h,002h	; 4ec7

; ======================================================================
; CODIGO 0x4ecb..0x510f  (580 bytes)
; ======================================================================


CAIDA_TERCER_PASO:		; El tercer paso de la caida, que ya es levantarse
	ld hl,0e0f9h		;4ecb   ; levantarse son once pasos, contados con el mismo byte que el salto
	ld a,(hl)			;4ece   ; 0xE0F9 vuelve a contar como en el salto: once pasos de levantarse
	inc (hl)			;4ecf
	cp 00bh		;4ed0
	jr nz,CAIDA_LEVANTA		;4ed2
	ld (hl),000h		;4ed4   ; y a los once vuelve a cero
CAIDA_LEVANTA:
	push af			;4ed6
	ld a,(0e144h)		;4ed7   ; la pose de levantarse sale de 0xE144, el lado por el que se cayo
	ld c,a			;4eda
	call PONE_POSE		;4edb
	pop af			;4ede
	ld hl,04c4ah		;4edf   ; La misma curva que el salto
	call SUMA_A_HL		;4ee2
	ld a,(hl)			;4ee5
	ld de,(0e078h)		;4ee6
	add a,e			;4eea
	ld e,a			;4eeb
	bit 2,c		;4eec   ; El bit 2 de la pose (en C) dice el lado: se sigue rodando tres columnas por paso mientras se levanta
	ld hl,0e0d0h		;4eee
	call z,TRES_A_LA_IZQUIERDA		;4ef1
	call nz,TRES_A_LA_DERECHA		;4ef4
	ex de,hl			;4ef7
	call PINGUINO_SPRITES		;4ef8
	ld a,(0e0f9h)		;4efb
	or a			;4efe
	ret nz			;4eff
	ld a,001h		;4f00   ; el remate levanta 0xE135 para que el repintado sepa que es especial
	ld (0e135h),a		;4f02
	call CAIDA_ABAJO		;4f05   ; El remate reutiliza CAIDA_ABAJO para repintar la fila y los obstaculos donde ha quedado
	xor a			;4f08
	ld (0e135h),a		;4f09
	dec hl			;4f0c   ; y deja la cuenta de la caida como se la encontro
	inc a			;4f0d
	ld (hl),a			;4f0e
	ld a,004h		;4f0f
	call PIDE_SONIDO		;4f11   ; Sonido 4
	ret			;4f14

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; CAERSE AL AGUA
; ----------------------------------------------------------------------
; Al caer al agujero se encienden OCHO sprites en vez de cuatro
; -0xE068 a 0xE087, que se vuelcan de una vez a la VRAM 0x3B18-,
; y el pinguino se queda ahi hasta que se pulsa el gatillo. El
; tiempo sigue corriendo, que es el castigo.
; ----------------------------------------------------------------------
CAE_AL_AGUA:		; Se cae por el agujero: ocho sprites y a esperar
	ld hl,00001h		;4f15   ; caer al agua enciende 0xE140 y apaga la caida
	ld (0e140h),hl		;4f18   ; 0xE140: esta en el agua
	xor a			;4f1b
	ld (0e142h),a		;4f1c
	ld a,0ffh		;4f1f   ; 0xE0F8 a 0xFF: el ciclo de zancadas se reinicia al salir
	ld (0e0f8h),a		;4f21
	ld a,005h		;4f24
	call PIDE_SONIDO		;4f26   ; Sonido 5
	ld hl,0e068h		;4f29
	ld bc,004b6h		;4f2c   ; los cuatro sprites del chapoteo, de cuatro en cuatro bytes
AGUA_SPRITES:
	ld (hl),c			;4f2f   ; el 0xB6 es el primer patron del chapoteo
	ld a,004h		;4f30
	call SUMA_A_HL		;4f32
	djnz AGUA_SPRITES		;4f35   ; cuatro sprites

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LAS PATAS AMARILLAS, QUE SON LA SOMBRA PINTADA DE OTRO COLOR
; ----------------------------------------------------------------------
; Mientras el pinguino chapotea en el agujero se le ven dos patas
; amarillas moviendose. No hay un sprite nuevo para eso: es el
; MISMO atributo que hace de sombra, al que estas dos
; instrucciones le cambian el color de azul oscuro a amarillo.
; Luego 0x4F90 le va poniendo los patrones 0x70, 0x74 y 0x78,
; que son las patas en tres posturas, y al salir del agua
; 0x4FDC le devuelve el patron 0xA0 y el color 4.
; Es la misma idea que las banderas o la foca: el color de un
; sprite no esta en su dibujo, esta en su entrada de atributo,
; asi que se puede cambiar sin tocar un solo byte de grafico.
; ----------------------------------------------------------------------
DIBUJA_EN_EL_AGUA:		; Coloca al pinguino asomando por el agujero, en Y=0x9F, y le PONE LAS PATAS AMARILLAS
	ld hl,(0e078h)		;4f37
	ld l,09fh		;4f3a   ; la Y se clava en 0x9F: la altura del agua
	call COLOCA_SPRITES		;4f3c
	ld a,010h		;4f3f
	call PONE_POSE		;4f41
	ld a,0e0h		;4f44   ; la Y 0xE0 deja el sprite fuera de la pantalla
	ld (0e0a0h),a		;4f46   ; Saca de la pantalla el sprite de la sombra...
	ld hl,0e00ah		;4f49   ; ...y con este par de bytes le cambia el COLOR a 0x0A, que es amarillo, y aparca el de al lado
	ld (0e0a3h),hl		;4f4c
VUELCA_OCHO_SPRITES:		; Los ocho atributos de 0xE068 a la VRAM, sprites 6 a 13
	ld hl,0e068h		;4f4f
	ld de,03b18h		;4f52   ; 0x3B18 son los sprites 6 a 13
	ld bc,00020h		;4f55   ; 0x20 bytes: los ocho atributos
	call COPIA_A_VRAM		;4f58
	jp SOMBRA_A_VRAM		;4f5b
SIGUE_EN_EL_AGUA:		; Manotea hasta que se pulsa el gatillo
	ld hl,0e141h		;4f5e   ; 0xE141 cuenta lo que se lleva en el agua
	inc (hl)			;4f61
	res 7,(hl)		;4f62   ; el bit 7 se apaga cada vuelta: la cuenta no pasa de 0x7F
	ld a,(hl)			;4f64
	cp 020h		;4f65   ; Los primeros 32 fotogramas no vale pulsar
	jr c,DIBUJA_EN_EL_AGUA		;4f67
	call LEE_GATILLOS_NUEVOS		;4f69
	jr nz,SALE_DEL_AGUA		;4f6c
	ld a,(0e003h)		;4f6e
	ld c,a			;4f71
	and 007h		;4f72   ; Las patas cambian cada ocho fotogramas
	ret nz			;4f74
	ld a,008h		;4f75
	ld b,099h		;4f77
	ld de,01470h		;4f79   ; Los tres patrones de pataleo: 0x70, 0x74 y 0x78
	bit 3,c		;4f7c   ; los bits 3 y 4 del contador reparten los tres dibujos
	jr z,AGUA_ANIMA		;4f7e
	ld a,004h		;4f80
	ld b,096h		;4f82
	ld de,01874h		;4f84
	bit 4,c		;4f87
	jr z,AGUA_ANIMA		;4f89
	ld a,00bh		;4f8b
	ld de,01c78h		;4f8d
AGUA_ANIMA:		; Mueve las patas: el patron va cambiando entre 0x70, 0x74 y 0x78, y la posicion los sigue
	ld hl,(0e078h)		;4f90   ; A trae el ajuste de X, B la Y del chapoteo y DE la pareja pose (D) y patron de las patas (E)
	ld l,b			;4f93
	add a,h			;4f94
	ld c,a			;4f95
	ld a,b			;4f96
	ld b,e			;4f97
	ld (0e0a1h),bc		;4f98
	add a,010h		;4f9c   ; La Y del sprite de las patas queda 16 por debajo del cuerpo, que sube y baja con el manoteo
	ld (0e0a0h),a		;4f9e
	push de			;4fa1
	call COLOCA_SPRITES		;4fa2   ; los cuatro sprites del pinguino se recolocan con la Y del manoteo
	pop af			;4fa5
	call PONE_POSE		;4fa6
	jp VUELCA_OCHO_SPRITES		;4fa9
SALE_DEL_AGUA:		; Con el gatillo se sale, y el periodo vuelve a 0x13: se sale del agua a la minima velocidad
	xor a			;4fac   ; salir del agua apaga las dos banderas y reinicia las zancadas
	ld (0e140h),a		;4fad
	ld (0e0f8h),a		;4fb0
	ld hl,00313h		;4fb3   ; 0xE100 vuelve al periodo 0x13: del agua se sale a la minima velocidad
	ld (0e100h),hl		;4fb6
	ld a,(0e079h)		;4fb9
	push af			;4fbc
	ld hl,066c8h		;4fbd   ; El atributo de 0x66C8, cuatro veces sobre los sprites 6 a 9: los que encendio el agua se recogen
	ld de,0e068h		;4fc0
	ld c,004h		;4fc3   ; cuatro sprites con el mismo atributo
	call REPITE_4_BYTES		;4fc5
	ld b,004h		;4fc8   ; cuatro juegos mas
SALIDA_SPRITES:
	ld c,(hl)			;4fca   ; La lista sigue con cuatro juegos mas: un byte de cuantas veces y los cuatro del atributo
	inc hl			;4fcb
	push bc			;4fcc
	call REPITE_4_BYTES		;4fcd
	pop bc			;4fd0
	djnz SALIDA_SPRITES		;4fd1   ; tantos juegos como diga B
	pop hl			;4fd3
	ld l,090h		;4fd4   ; y el pinguino vuelve a la Y de andar, 0x90
	call COLOCA_SPRITES		;4fd6
	ld hl,004a0h		;4fd9   ; El patron 0xA0 y el color 4: la sombra vuelve a ser sombra
	ld (0e0a2h),hl		;4fdc
	call PINGUINO_A_VRAM		;4fdf
	call VUELCA_ATRIBUTOS		;4fe2
	ret			;4fe5
COGE_OBJETO:		; LAS BANDERAS DE LA PISTA. Los tipos 5 y 6 son las dos banderas que hay plantadas en el hielo -una inclinada a cada lado- y NO se esquivan: se recogen. Al tocarlas suena, se borra la ficha, se repinta el hueco y suman 500 puntos. Lo dice tambien el reparto de 0x4D35: los tipos 0 a 4 se van al choque y solo el 5 y el 6 caen aqui. OJO, no confundirlas con la bandera que sube por el mastil de la base, que es otra cosa y va por sprites (0x5577)
	ex de,hl			;4fe6   ; el dibujo se lee hacia ATRAS: los bytes que van delante del puntero
	dec hl			;4fe7
	dec hl			;4fe8
	ld d,(hl)			;4fe9
	dec hl			;4fea
	ld e,(hl)			;4feb
	dec hl			;4fec
	dec hl			;4fed
	ld (hl),000h		;4fee
	ex de,hl			;4ff0
	inc hl			;4ff1
	ld de,0e1a0h		;4ff2   ; Los trece bytes del dibujo se copian a RAM para poder rematarlos con un cero
	ld bc,0000dh		;4ff5
	ldir		;4ff8
	xor a			;4ffa
	ld (de),a			;4ffb
	ld a,006h		;4ffc
	call PIDE_SONIDO		;4ffe   ; Sonido 6
	ld hl,0e1a0h		;5001
	call DIBUJA_BLOQUE		;5004   ; y de ahi lo pinta el interprete de bloques normal
	ld de,00500h		;5007   ; Quinientos puntos
	call SUMA_AL_MARCADOR		;500a
	ret			;500d
MONTA_LA_PISTA:		; Monta la pista de la fase: colores, cielo, hielo, decorados y la lista de lo que va saliendo
	ld a,(0e0e1h)		;500e   ; La fase elige la pareja de colores
	ld hl,0515fh		;5011
	call SUMA_A_HL		;5014
	ld a,007h		;5017
	bit 0,(hl)		;5019   ; el bit 0 elige entre la casilla 7 y la 9 para el cielo
	jr z,PISTA_COLORES		;501b
	ld a,009h		;501d
PISTA_COLORES:
	ld (0e10ch),a		;501f
	ld a,(hl)			;5022
	ld hl,05dbch		;5023   ; Dos juegos de colores comprimidos, uno para cada tipo de fase
	ld de,0621eh		;5026
	or a			;5029
	jr z,PISTA_DESCOMPRIME		;502a
	ld hl,05dc7h		;502c
	ld de,0623bh		;502f
PISTA_DESCOMPRIME:
	push de			;5032   ; Las dos tiradas del descompresor -a 0x4588 y a 0x4F78- van con el juego de flujos del tipo de fase
	ld de,04588h		;5033   ; y se descomprimen en dos sitios: la tabla de colores y los patrones
	call DESCOMPRIME_DE		;5036
	pop hl			;5039
	ld de,04f78h		;503a
	call DESCOMPRIME_DE		;503d
	ld de,03860h		;5040   ; El cielo, con la casilla 7 o la 9
	ld bc,000e0h		;5043   ; 0xE0 casillas: siete filas de cielo
	ld a,(0e10ch)		;5046
	call RELLENA_VRAM		;5049
	ld de,03940h		;504c   ; Y el hielo, con la 0x0F
	ld bc,001c0h		;504f
	ld a,00fh		;5052
	call RELLENA_VRAM		;5054
	ld hl,07229h		;5057
	call PINTA_DECORADO		;505a
	ld hl,07266h		;505d
	call PINTA_DECORADO		;5060
	ld hl,0510fh		;5063   ; Ocho bytes por fase: la lista de decorados que van saliendo
	ld a,(0e0e1h)		;5066
	add a,a			;5069
	add a,a			;506a
	add a,a			;506b
	call SUMA_A_HL		;506c
	ld (0e10ah),hl		;506f
	xor a			;5072
	ld (0e102h),a		;5073
	ld (0e108h),a		;5076
	ld hl,07221h		;5079   ; Los punteros de los dos grupos de trozos arrancan en 0x7221 y 0x725E
	ld (0e103h),hl		;507c
	ld hl,0725eh		;507f
	ld (0e105h),hl		;5082
	call PISTA_GRUPO_B		;5085
	call PISTA_GRUPO_A		;5088
	ret			;508b
SIGUIENTE_DECORADO:		; Coge el siguiente decorado de la lista de la fase; 0xFF quiere decir que ya no hay mas
	ld hl,0e108h		;508c
	ld a,(hl)			;508f
	inc (hl)			;5090
	ld hl,(0e10ah)		;5091
	call SUMA_A_HL		;5094
	ld a,(hl)			;5097   ; El 0xFF de la lista: ya no hay mas decorados en esta fase
	cp 0ffh		;5098
	ret z			;509a
	ld (0e109h),a		;509b
	ld bc,0e103h		;509e   ; El bit 0 del decorado elige la pareja de punteros: 0xE103 (grupo A) o 0xE105 (grupo B)
	bit 0,a		;50a1
	jr z,DECORADO_GRUPO		;50a3
	inc bc			;50a5
	inc bc			;50a6
DECORADO_GRUPO:
	add a,a			;50a7
	ld hl,07219h		;50a8   ; Los cuatro grupos de decorado
	call SUMA_A_HL		;50ab
	ld a,(hl)			;50ae
	ld e,a			;50af
	ld (bc),a			;50b0   ; El puntero elegido se apunta en la pareja y queda tambien en DE, que se dibuja ya
	inc hl			;50b1
	inc bc			;50b2
	ld a,(hl)			;50b3
	ld d,a			;50b4
	ld (bc),a			;50b5
	ex de,hl			;50b6
	ld a,008h		;50b7   ; Los ocho primeros bytes del grupo son sus cuatro punteros de trozos; el dibujo empieza en el byte 8
	call SUMA_A_HL		;50b9
PINTA_DECORADO:		; Pinta un decorado: franjas, cadena y las dieciseis casillas que se guardan en 0xE1xx
	call PINTA_FRANJAS		;50bc
	call ESCRIBE_CADENA		;50bf
	ld e,(hl)			;50c2
DECORADO_CASILLAS:
	ld a,(0e10ch)		;50c3   ; Los ceros se cambian por la casilla del cielo de esta fase
	ld c,a			;50c6
	ld b,010h		;50c7
	ld d,0e1h		;50c9
DECORADO_BUCLE:
	inc hl			;50cb
	ld a,(hl)			;50cc
	or a			;50cd
	jr nz,DECORADO_CASILLA		;50ce
	ld a,c			;50d0
DECORADO_CASILLA:
	ld (de),a			;50d1
	inc de			;50d2
	djnz DECORADO_BUCLE		;50d3
PINTA_FILA_DE_PISTA:		; Escribe la fila compuesta en 0xE14E, que va siempre a la fila 9
	ld de,03920h		;50d5   ; La cabecera 0x3920 (la fila 9) y el 0xFF de cierre arropan la fila compuesta, y ESCRIBE_CADENA la lleva a pantalla
	ld (0e14eh),de		;50d8
	ld a,0ffh		;50dc
	ld (0e170h),a		;50de
	ld hl,0e14eh		;50e1
	call ESCRIBE_CADENA		;50e4
	xor a			;50e7
	ret			;50e8
AVANZA_DECORADO:		; Cada 400 metros toca decorado nuevo
	call DESPLAZA_LA_PISTA		;50e9
	ld hl,0e107h		;50ec   ; 0xE107 lo enciende el marcador de la distancia (0x46F7)
	ld a,(hl)			;50ef
	dec a			;50f0
	ret nz			;50f1
	ld a,(0e102h)		;50f2   ; Y solo con el contador de trozos en 1, para no pisar un trozo a medias
	dec a			;50f5
	ret nz			;50f6
	ld (hl),a			;50f7   ; el aviso se consume al atenderlo
	call SIGUIENTE_DECORADO		;50f8
	or a			;50fb
	ret nz			;50fc
	ld hl,(0e103h)		;50fd
	ld a,(0e109h)		;5100
	bit 0,a		;5103   ; el bit 0 de 0xE109 elige entre los dos decorados apuntados
	jr z,DECORADO_DIBUJA		;5105
	ld hl,(0e105h)		;5107
DECORADO_DIBUJA:
	xor a			;510a
	call PISTA_DIBUJA		;510b
	ret			;510e

; ----------------------------------------------------------------------
; DATOS decorados_por_fase: Ocho bytes por fase, diez fases: la lista de
;   decorados que van saliendo. Un 0xFF acaba la lista y los 0x77 son relleno
;   0x510f..0x515f  (80 bytes)
DATA_decorados_por_fase:
	defb 002h,003h,000h,001h,077h,077h,077h,077h	; 510f  ....wwww
	defb 003h,002h,001h,000h,077h,077h,077h,077h	; 5117  ....wwww
	defb 003h,0ffh,001h,077h,077h,077h,077h,077h	; 511f  ...wwwww
	defb 0ffh,002h,000h,077h,077h,077h,077h,077h	; 5127  ...wwwww
	defb 003h,0ffh,001h,077h,077h,077h,077h,077h	; 512f  ...wwwww
	defb 0ffh,077h,077h,077h,077h,077h,077h,077h	; 5137  .wwwwwww
	defb 002h,003h,000h,002h,001h,000h,0ffh,077h	; 513f  .......w
	defb 002h,0ffh,000h,077h,077h,077h,077h,077h	; 5147  ...wwwww
	defb 002h,000h,003h,001h,077h,077h,077h,077h	; 514f  ....wwww
	defb 0ffh,003h,001h,077h,077h,077h,077h,077h	; 5157  ...wwwww

; ----------------------------------------------------------------------
; DATOS color_por_fase: Un byte por fase: con 0 el cielo es la casilla 7 y con
;   1 la 9. Cierra clavada en 0x5169, donde vuelve a haber codigo
;   0x515f..0x5169  (10 bytes)
DATA_color_por_fase:
	defb 000h,000h,001h,000h,001h,001h,000h,000h,001h,000h	; 515f  ..........

; ======================================================================
; CODIGO 0x5169..0x5295  (300 bytes)
; ======================================================================


AVANZA_LA_PISTA:		; Al ritmo de la velocidad, va sacando los trozos de decorado y moviendo los obstaculos
	ld hl,0e100h		;5169   ; 0xE100 es el periodo y 0xE101 su cuenta atras: los trabajos del dibujo se reparten dentro del periodo (3 el decorado, 1 el grupo B, 0 la recarga y el grupo A)
	ld c,(hl)			;516c
	inc hl			;516d
	dec (hl)			;516e
	jr z,PISTA_RECARGA		;516f
	ld a,(hl)			;5171
	cp 003h		;5172
	jp z,AVANZA_DECORADO		;5174
	dec a			;5177
	jr nz,PISTA_MIRA		;5178
PISTA_GRUPO_B:
	ld hl,(0e105h)		;517a
	ld a,(0e102h)		;517d
	jr PISTA_DIBUJA		;5180
PISTA_RECARGA:
	ld (hl),c			;5182
PISTA_SIGUIENTE:
	ld hl,0e102h		;5183
	ld a,(hl)			;5186
	inc (hl)			;5187
	res 2,(hl)		;5188
PISTA_GRUPO_A:
	ld hl,(0e103h)		;518a
PISTA_DIBUJA:		; Dibuja el trozo A de la tabla que apunta HL
	add a,a			;518d   ; A por dos: la tabla del grupo es de punteros y el trozo se dibuja con el interprete de bloques
	call SUMA_A_HL		;518e
	ld e,(hl)			;5191
	inc hl			;5192
	ld d,(hl)			;5193
	ex de,hl			;5194
	call DIBUJA_BLOQUE		;5195
	ret			;5198
PISTA_MIRA:
	ld b,000h		;5199
	dec a			;519b
	jr z,MUEVE_OBSTACULOS		;519c
	inc b			;519e
	srl c		;519f   ; A media cuenta (periodo/2 contra la cuenta) se entra con B = 1
	ld a,(hl)			;51a1
	cp c			;51a2
	ret nz			;51a3
MUEVE_OBSTACULOS:		; Da un paso a cada ficha de obstaculo y dibuja el trozo que le toca
	ld hl,0e112h		;51a4
	ld c,b			;51a7
	ld b,004h		;51a8
	ld a,(0e0e0h)		;51aa   ; Cuatro fichas, y cinco a partir de la fase 5
	cp 005h		;51ad
	jr c,OBSTACULO_FICHA		;51af
	inc b			;51b1
OBSTACULO_FICHA:
	ld a,c			;51b2
	or a			;51b3
	jr z,OBSTACULO_PASO		;51b4
	ld a,(hl)			;51b6
	cp 00bh		;51b7   ; A media cuenta solo avanzan las fichas del paso 0x0B en adelante: lo cercano corre el doble, que es la perspectiva
	ld a,006h		;51b9
	jr c,OBSTACULO_SIGUIENTE		;51bb
OBSTACULO_PASO:
	ld a,(hl)			;51bd
	or a			;51be
	ld a,006h		;51bf
	jr z,OBSTACULO_SIGUIENTE		;51c1
	inc (hl)			;51c3
	ld a,(hl)			;51c4
	cp 010h		;51c5   ; Quince pasos y la ficha vuelve a quedar libre
	jr c,OBSTACULO_DIBUJA		;51c7
	ld (hl),000h		;51c9
OBSTACULO_DIBUJA:
	inc hl			;51cb
	inc hl			;51cc
	ld e,(hl)			;51cd   ; El trozo de dibujo que toca, que avanza en cada paso
	inc hl			;51ce
	ld d,(hl)			;51cf
	ex de,hl			;51d0
	push de			;51d1
	push bc			;51d2
	call DIBUJA_BLOQUE		;51d3   ; el bloque se pinta antes de avanzar el puntero
	pop bc			;51d6
	pop de			;51d7
	inc hl			;51d8   ; El puntero de dibujo se guarda avanzado: cada paso dibuja el trozo siguiente de la secuencia
	ex de,hl			;51d9
	ld (hl),d			;51da
	dec hl			;51db
	ld (hl),e			;51dc
	ld a,004h		;51dd   ; cuatro bytes por ficha de obstaculo
OBSTACULO_SIGUIENTE:
	call SUMA_A_HL		;51df
	djnz OBSTACULO_FICHA		;51e2
	call SUELTA_EL_PEZ		;51e4   ; Detras del barrido van el pez, la foca y los dos choques: una vez por paso de pista
	call ANIMA_LA_FOCA		;51e7
	call MIRA_CHOQUES		;51ea
	call MIRA_CHOQUES_SALTANDO		;51ed
	ret			;51f0
CREA_OBSTACULO:		; Cada cierto numero de pasos mete un obstaculo nuevo en la primera ficha libre
	call MIRA_SORPRESA		;51f1
	ld hl,(0e0e5h)		;51f4   ; Con menos de 0x186 metros por delante ya no salen mas
	ld a,h			;51f7
	and a			;51f8
	jr nz,CREA_CUENTA		;51f9
	ld a,l			;51fb
	cp 086h		;51fc
	ret c			;51fe
CREA_CUENTA:
	ld hl,0e10eh		;51ff   ; 0xE10E es el periodo y 0xE10F la cuenta
	ld a,(hl)			;5202
	inc hl			;5203
	dec (hl)			;5204
	ret nz			;5205
	ld (hl),a			;5206   ; Al dispararse, la cuenta se recarga con el periodo de 0xE10E y se busca ficha libre
	ld hl,0e112h		;5207
	ld b,003h		;520a   ; Tres fichas donde elegir (cuatro desde la fase 5); la de 0xE12A no entra: es la reservada de la pareja
	ld a,(0e0e0h)		;520c
	cp 005h		;520f
	jr c,CREA_BUSCA_FICHA		;5211
	inc b			;5213
CREA_BUSCA_FICHA:
	ld a,(hl)			;5214
	or a			;5215
	jr z,CREA_EN_ESTA		;5216
	ld a,006h		;5218   ; El 6 salta a la ficha siguiente
	call SUMA_A_HL		;521a
	djnz CREA_BUSCA_FICHA		;521d
	ret			;521f
CREA_EN_ESTA:
	inc (hl)			;5220
	inc hl			;5221
	ex de,hl			;5222
	ld hl,0e111h		;5223   ; 0xE111 cuenta 0-7 (el `res 3` lo pliega): la posicion en la lista de ocho del decorado
	inc (hl)			;5226
	res 3,(hl)		;5227
	ld a,(hl)			;5229
	ld hl,(0e18bh)		;522a   ; Que obstaculo toca sale de la lista que dejo ELIGE_DECORADO
	call SUMA_A_HL		;522d
	ld c,(hl)			;5230
	push de			;5231
	call HAY_SORPRESA		;5232
	pop de			;5235
	ld a,c			;5236
	inc a			;5237
	jr z,CREA_NADA		;5238
	dec a			;523a
	bit 4,a		;523b   ; Bit 4: el obstaculo viene emparejado con otro
	jr z,CREA_CORRE		;523d
	ld hl,0e190h		;523f
	ld (hl),001h		;5242
	inc hl			;5244
	and 003h		;5245
	ld c,a			;5247
	ld (hl),a			;5248
	jr CREA_RELLENA		;5249
CREA_CORRE:
	ld a,c			;524b
	or a			;524c
	jr z,CREA_RELLENA		;524d
	ld a,(0e0fch)		;524f   ; Con el pinguino en la mitad derecha, el obstaculo se corre uno
	or a			;5252
	jr z,CREA_RELLENA		;5253
	inc c			;5255
CREA_RELLENA:
	ex de,hl			;5256
	call RELLENA_FICHA		;5257
	ld a,(0e190h)		;525a   ; Si 0xE190 quedo levantado, la pareja: el complemento del lado en 0xE191 y la ficha reservada de 0xE12A
	rra			;525d
	ret nc			;525e
	ld a,(0e191h)		;525f
	cpl			;5262
	and 003h		;5263   ; los dos bits bajos son el lado
	ld c,a			;5265
	ld hl,0e12ah		;5266
	ld a,(hl)			;5269   ; Solo si la reservada esta libre; si no, la pareja se pierde
	or a			;526a
	jr nz,CREA_PAREJA_FIN		;526b
	inc (hl)			;526d   ; la ficha reservada queda ocupada
	inc hl			;526e
	call RELLENA_FICHA		;526f
CREA_PAREJA_FIN:
	ld hl,0e190h		;5272
	ld (hl),000h		;5275
	ret			;5277
CREA_NADA:
	ex de,hl			;5278
	dec hl			;5279
	ld (hl),a			;527a
	ret			;527b
RELLENA_FICHA:		; Copia a la ficha el tipo, el puntero de dibujo y el de choque, sacados de la tabla de al lado
	ld (hl),c			;527c
	inc hl			;527d
	ld de,05295h		;527e
	ld a,c			;5281
	add a,a			;5282   ; Tipo por seis -el doble, el cuadruple y la suma-: lo que ocupa cada entrada de la tabla
	ld c,a			;5283
	add a,a			;5284
	add a,c			;5285
	call SUMA_A_DE		;5286
	ld a,(de)			;5289
	ld (hl),a			;528a   ; Los dos primeros bytes de la entrada, el puntero al primer trozo de dibujo
	inc de			;528b
	inc hl			;528c
	ld a,(de)			;528d
	ld (hl),a			;528e
	inc de			;528f
	inc hl			;5290
	ld (hl),e			;5291   ; Y como puntero de choque se guarda DE mismo: los cuatro bytes de pares estan ahi, en la propia tabla
	inc hl			;5292
	ld (hl),d			;5293
	ret			;5294

; ----------------------------------------------------------------------
; DATOS tabla_de_obstaculos: Los SIETE obstaculos: los tipos 0, 1 y 2 son los
;   agujeros -de los que salen la foca y el pez-, el 3 y el 4 los dos
;   monticulos con los que se choca, y el 5 y el 6 LAS DOS BANDERAS que se
;   recogen por 500 puntos. Seis bytes cada uno: los dos primeros son el
;   puntero al primer trozo de dibujo, y los cuatro siguientes los pares
;   (posicion, ancho) con los que se mira el choque. Los siete dibujos caen
;   dentro de los 92 trozos de 0x6BC1-0x7219, que es lo que confirma para que
;   son. Cierra clavada en 0x52BF
;   0x5295..0x52bf  (42 bytes)
DATA_tabla_de_obstaculos:
	defb 0f1h,06eh,001h,053h,03ah,000h	; 5295
	defb 0aah,06fh,001h,013h,03bh,000h	; 529b
	defb 069h,070h,001h,092h,03bh,000h	; 52a1
	defb 0c1h,06bh,02bh,05bh,010h,090h	; 52a7
	defb 05dh,06dh,064h,053h,048h,088h	; 52ad
	defb 0a0h,071h,080h,02ch,000h,000h	; 52b3
	defb 028h,071h,02eh,02ch,000h,000h	; 52b9

; ======================================================================
; CODIGO 0x52bf..0x53ab  (236 bytes)
; ======================================================================


MIRA_LA_CURVA:		; Cada 200 del marcador (la distancia va en BCD: dispara con las centenas impares y el resto en 82) mira en la tabla de nibbles que curva toca y monta el cambio
	ld hl,(0e0e5h)		;52bf
	ld a,h			;52c2   ; La distancia va en BCD: dispara con las centenas impares y el resto en 82, cada 200 del marcador
	and 001h		;52c3
	ret z			;52c5
	ld a,l			;52c6
	cp 082h		;52c7
	ret nz			;52c9
	ld hl,0e0e2h		;52ca   ; 0xE0E2 es el indice de curva, que solo avanza aqui
	ld a,(hl)			;52cd
	inc (hl)			;52ce
	srl a		;52cf   ; Dos curvas por byte: el acarreo dice si toca la mitad alta o la baja
	push af			;52d1
	ld hl,053abh		;52d2
	call SUMA_A_HL		;52d5
	pop af			;52d8
	ld a,(hl)			;52d9
	jr c,CURVA_MONTA		;52da
	rra			;52dc
	rra			;52dd
	rra			;52de
	rra			;52df
CURVA_MONTA:
	ld c,a			;52e0
	and 003h		;52e1   ; El nibble: los bits 0-1 son el rumbo de 0xE194 (11: recto, nada que hacer) y el bit 3 enciende el "va torcida" (bit 1)
	cp 003h		;52e3
	ret z			;52e5
	bit 3,c		;52e6
	jr z,CURVA_GUARDA		;52e8
	set 1,a		;52ea
CURVA_GUARDA:
	ld hl,0e194h		;52ec
	ld (hl),a			;52ef
	inc hl			;52f0
	bit 2,c		;52f1   ; El bit 2 del nibble alarga la curva: 0xE195 a 2
	jr z,CURVA_RITMO		;52f3
	ld (hl),002h		;52f5
CURVA_RITMO:
	inc hl			;52f7
	ld (hl),001h		;52f8
	inc hl			;52fa
	ld (hl),000h		;52fb
	inc hl			;52fd
	ld a,(0e100h)		;52fe   ; El periodo de 0xE100, dividido por cuatro, marca cada cuantos fotogramas se desplaza la pista
	srl a		;5301
	srl a		;5303
	ld (hl),a			;5305
	call RETOCA_DECORADO_B		;5306
PINTA_HORIZONTE:		; Dibuja el horizonte que corresponde a la curva
	ld hl,053cch		;5309
PINTA_HORIZONTE_HL:
	ld a,(0e194h)		;530c   ; 0xE194 por dos indexa los punteros: cada rumbo tiene su dibujo de horizonte
	add a,a			;530f
	call SUMA_A_HL		;5310
	ld e,(hl)			;5313
	inc hl			;5314
	ld d,(hl)			;5315
	ex de,hl			;5316
	call ESCRIBE_CADENA		;5317
	ret			;531a
DESPLAZA_LA_PISTA:		; Gira la fila de 32 casillas a un lado o al otro: eso es la curva
	ld a,(0e196h)		;531b
	or a			;531e
	ret z			;531f
	ld bc,0001fh		;5320
	ld a,(0e194h)		;5323
	rra			;5326   ; Bit 0 de 0xE194: a que lado gira
	jr c,DESPLAZA_DERECHA		;5327
	ld a,(0e150h)		;5329   ; Hacia la izquierda, con LDIR
	ld hl,0e151h		;532c
	ld de,0e150h		;532f
	ldir		;5332
	ld (0e16fh),a		;5334
	jr DESPLAZA_PINTA		;5337
DESPLAZA_DERECHA:
	ld a,(0e16fh)		;5339   ; Hacia la derecha, con LDDR
	ld hl,0e16eh		;533c
	ld de,0e16fh		;533f
	lddr		;5342
	ld (0e150h),a		;5344
DESPLAZA_PINTA:
	call PINTA_FILA_DE_PISTA		;5347
	ld hl,0e197h		;534a
	inc (hl)			;534d   ; 0xE197 cuenta los desplazamientos: cada dieciseis se consume una tanda de 0xE195
	ld a,(hl)			;534e
	and 00fh		;534f   ; los cuatro bits bajos: una tanda cada dieciseis pasos
	jr nz,CURVA_ENDEREZA		;5351
	dec hl			;5353
	dec hl			;5354
	cp (hl)			;5355
	jr z,CURVA_ENDEREZA		;5356
	dec (hl)			;5358   ; y una tanda menos
	jr nz,CURVA_ENDEREZA		;5359
	dec hl			;535b   ; Agotadas las tandas, el rumbo (bit 0 de 0xE194) se INVIERTE y se repinta el horizonte: la curva se deshace girando al otro lado
	ld a,(hl)			;535c
	xor 001h		;535d
	ld (hl),a			;535f
	call PINTA_HORIZONTE		;5360
CURVA_ENDEREZA:
	ld hl,(0e0e5h)		;5363
	ld a,h			;5366
	and 001h		;5367
	ret nz			;5369
	ld a,l			;536a
	cp 045h		;536b   ; Con menos de 0x145 metros la pista se endereza para llegar a la base
	ret nc			;536d
	ld hl,0e197h		;536e
	ld a,(hl)			;5371
	and 00fh		;5372   ; Solo con la cuenta de 0xE197 redonda, para no cortar una tanda a medias
	ret nz			;5374
	dec hl			;5375   ; 0xE196 a cero -la pista deja de girar- y el horizonte pasa a los dibujos de la llegada (0x53D4)
	ld (hl),a			;5376
	ld hl,053d4h		;5377
	call PINTA_HORIZONTE_HL		;537a
	call RETOCA_DECORADO		;537d
ARRASTRA_PINGUINO:		; En las curvas el pinguino se va de lado solo, al ritmo de la velocidad
	ld hl,0e196h		;5380
	ld a,(hl)			;5383   ; Sin curva en marcha (0xE196 a cero) no hay arrastre
	or a			;5384
	ret z			;5385
	inc hl			;5386
	inc hl			;5387
	dec (hl)			;5388
	ret nz			;5389
	ld a,(0e100h)		;538a   ; El mismo ritmo que el desplazamiento de la pista: periodo/4, contado en 0xE198
	srl a		;538d
	srl a		;538f
	ld (hl),a			;5391
	ld hl,0e0d1h		;5392   ; HL apunta a 0xE0D1, un byte de paso: el arrastre usa MUEVE_* sin tocar los bits de sentido de 0xE0FA
	ld de,(0e078h)		;5395
	ld a,(0e194h)		;5399
	rra			;539c
	jr c,ARRASTRA_DERECHA		;539d
	call MUEVE_IZQUIERDA		;539f
	jp PINGUINO_COLOCA		;53a2
ARRASTRA_DERECHA:
	call MUEVE_DERECHA		;53a5
	jp PINGUINO_COLOCA		;53a8

; ----------------------------------------------------------------------
; DATOS curvas_por_fase: Sesenta y seis curvas en treinta y tres bytes, a
;   nibble por curva: 0x52CF elige la mitad alta o la baja. Cierra con el 0xFF
;   de 0x53CB, justo delante de los punteros
;   0x53ab..0x53cc  (33 bytes)
DATA_curvas_por_fase:
	defb 0f8h,0ffh,0ffh,0ffh,099h,0f8h,08fh,0f9h,0f9h,0ffh,0ffh,088h,01fh,0f9h,0f9h,00fh	; 53ab  ................
	defb 01fh,0ffh,08fh,099h,0ffh,081h,00fh,0ffh,0f8h,08fh,0ffh,08fh,099h,0ffh,0f0h,099h	; 53bb  ................
	defb 0ffh	; 53cb

; ----------------------------------------------------------------------
; DATOS punteros_del_horizonte: Ocho punteros a los siete dibujos de horizonte
;   (dos apuntan al mismo). Cierra clavada en 0x53DC, que es el primero de
;   ellos
;   0x53cc..0x53dc  (16 bytes)
DATA_punteros_del_horizonte:
	defw 053dch,053edh,0540fh,0542eh,053feh,053feh,0546ch,0544dh	; 53cc

; ----------------------------------------------------------------------
; DATOS dibujos_del_horizonte: Los siete horizontes, en el formato de las
;   cadenas: recto, curva a un lado, curva al otro, y los cuatro de la llegada
;   a la base. Todos escriben en las filas 10 y 11. Acaba clavado en 0x548B
;   0x53dc..0x548b  (175 bytes)
DATA_dibujos_del_horizonte:
	defb 049h,039h,014h,014h,013h,013h,015h,030h,030h,031h,010h,010h,010h,032h,033h,023h	; 53dc  I9.....001...23#
	defb 0ffh,049h,039h,023h,074h,032h,010h,010h,010h,031h,030h,030h,015h,013h,013h,014h	; 53ec  .I9#t2...100....
	defb 014h,0ffh,049h,039h,015h,014h,013h,012h,052h,010h,00fh,00fh,010h,011h,012h,013h	; 53fc  ..I9....R.......
	defb 014h,015h,0ffh,049h,039h,014h,014h,013h,013h,015h,030h,030h,031h,010h,010h,010h	; 540c  ...I9.....001...
	defb 041h,047h,053h,053h,054h,054h,054h,054h,054h,054h,054h,054h,0feh,072h,039h,00fh	; 541c  AGSSTTTTTTTT.r9.
	defb 03eh,0ffh,040h,039h,054h,054h,054h,054h,054h,054h,054h,054h,053h,053h,088h,082h	; 542c  >.@9TTTTTTTTSS..
	defb 010h,010h,010h,031h,030h,030h,015h,013h,013h,014h,014h,0feh,06ch,039h,07fh,00fh	; 543c  ...100......l9..
	defb 0ffh,040h,039h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h	; 544c  .@9.............
	defb 07dh,07ah,00fh,00fh,010h,011h,012h,013h,014h,015h,0feh,06ch,039h,079h,078h,0ffh	; 545c  }z.........l9yx.
	defb 049h,039h,015h,014h,013h,012h,052h,010h,00fh,00fh,039h,03ch,004h,004h,004h,004h	; 546c  I9....R...9<....
	defb 004h,004h,004h,004h,004h,004h,004h,004h,004h,0feh,072h,039h,037h,038h,0ffh	; 547c  ..........r978.

; ======================================================================
; CODIGO 0x548b..0x5516  (139 bytes)
; ======================================================================


RETOCA_DECORADO:		; Con la pista torcida, cambia las casillas del decorado para que encajen
	ld hl,072bfh		;548b
	jr RETOCA_LADO		;548e
RETOCA_DECORADO_B:		; La otra entrada, con el otro juego de casillas
	ld hl,0724dh		;5490
RETOCA_LADO:
	ld a,(0e194h)		;5493
	bit 1,a		;5496   ; El bit 1 de 0xE194 dice que la pista va torcida; el bit 0 (al acarreo por el `rra`) elige el juego de casillas, 0x10 mas abajo en un lado
	ret z			;5498
	rra			;5499
	ld a,(hl)			;549a
	jr nc,RETOCA_ESCRIBE		;549b
	sub 010h		;549d
RETOCA_ESCRIBE:
	ld e,a			;549f
	jp DECORADO_CASILLAS		;54a0
ANDA_HASTA_LA_BASE:		; Dieciseis pasos subiendo por la pantalla, interpolando la X entre donde estaba y donde esta la bandera
	ld a,(0e003h)		;54a3   ; Un paso cada cuatro fotogramas
	and 003h		;54a6
	ret nz			;54a8
	inc c			;54a9   ; Con C=0xFF se calcula la X de destino; con C=0 se sigue con la que habia
	jr nz,BASE_ANDA		;54aa
	ld a,(0e139h)		;54ac
	ld c,a			;54af
	xor a			;54b0
	ld b,a			;54b1
	ld hl,00070h		;54b2
	sbc hl,bc		;54b5
	ld a,(0e138h)		;54b7
	ld b,a			;54ba
	ld e,l			;54bb
	ld d,h			;54bc
BASE_MULTIPLICA:
	add hl,de			;54bd   ; Multiplicar sumando: no hay instruccion de multiplicar
	djnz BASE_MULTIPLICA		;54be
	ld a,h			;54c0   ; Las ocho rotaciones en dos tandas montan HL/16: el nibble bajo de H y el alto de L
	rlca			;54c1
	rlca			;54c2
	rlca			;54c3
	rlca			;54c4
	and 0f0h		;54c5
	ld e,a			;54c7
	ld a,l			;54c8
	rrca			;54c9
	rrca			;54ca
	rrca			;54cb
	rrca			;54cc
	and 00fh		;54cd
	or e			;54cf
	add a,c			;54d0   ; Sumado a la X de partida: la interpolacion lineal, paso/16 del camino hasta la bandera
	ld h,a			;54d1
BASE_ANDA:
	ld a,(0e078h)		;54d2
	dec a			;54d5   ; Una linea mas arriba en cada paso
	ld l,a			;54d6
	call COLOCA_SPRITES		;54d7
	call ANDAR_PASO		;54da
	ld hl,0e138h		;54dd
	inc (hl)			;54e0
	ld a,010h		;54e1   ; Dieciseis pasos
	cp (hl)			;54e3
	ret			;54e4
DIBUJA_LA_BASE:		; Empieza a dibujar la base
	xor a			;54e5
	ld (0e13ah),a		;54e6
DIBUJA_LA_BASE_PASO:		; Alterna los dos bloques de la escena de la base
	ld hl,0e13ah		;54e9
	ld a,(hl)			;54ec
	inc (hl)			;54ed
	ld hl,05516h		;54ee   ; El bit 0 de la cuenta 0xE13A elige bloque: pares el A (0x5516), impares el B (0x552A)
	rra			;54f1
	jr nc,BASE_DIBUJA		;54f2
	ld hl,0552ah		;54f4
BASE_DIBUJA:
	call DIBUJA_BLOQUE		;54f7
	ret			;54fa
DIBUJA_EL_POLO:		; El remate del POLO SUR: descomprime cuatro sprites mas (0x6B59 -> VRAM 0x1F80, o sea los patrones 0xF0, 0xF4, 0xF8 y 0xFC), copia sus cuatro atributos de 0x671E encima de los numeros 7 a 10 -dos en amarillo y dos en negro- y dibuja un tercer bloque de casillas. Los cuatro completan al pinguino inclinado que dibujan las casillas: el pico y la mancha de la barriga en amarillo, el ala y el lomo en negro
	ld hl,06b59h		;54fb   ; 0x6B59: los patrones comprimidos de los cuatro sprites del remate (0xF0-0xFC)
	call DESCOMPRIME		;54fe
	ld hl,0671eh		;5501
	ld de,0e06ch		;5504   ; Los dieciseis bytes de 0x671E, los atributos, encima de los sprites 7 a 10
	ld bc,00010h		;5507
	ldir		;550a
	call VUELCA_ATRIBUTOS		;550c
	ld hl,05534h		;550f
	call DIBUJA_BLOQUE		;5512
	ret			;5515

; ----------------------------------------------------------------------
; DATOS bloque_base_a: Uno de los dos bloques que se van alternando para
;   dibujar la base
;   0x5516..0x552a  (20 bytes)
DATA_bloque_base_a:
	defb 0e1h,0efh,0b6h,0b7h,0eeh,0b8h,0b9h,0bah,0bbh,0eeh,0beh,0bfh,0c0h,0bch,0eeh,0c3h	; 5516  ................
	defb 0c4h,0c5h,0c6h,000h	; 5526

; ----------------------------------------------------------------------
; DATOS bloque_base_b: El otro
;   0x552a..0x5534  (10 bytes)
DATA_bloque_base_b:
	defb 002h,0eeh,0c2h,0eeh,0bdh,0c1h,0eeh,0c7h,0c8h,000h	; 552a  ..........

; ----------------------------------------------------------------------
; DATOS bloque_base_polo: El tercero, el del remate de 0x54FB
;   0x5534..0x5549  (21 bytes)
DATA_bloque_base_polo:
	defb 0e1h,0eeh,0d2h,0d5h,0d8h,0eeh,0d3h,0d6h,0d9h,0dbh,0eeh,0d4h,0d7h,0dah,0dch,0eeh	; 5534  ................
	defb 0ddh,0deh,0dfh,00fh,000h	; 5544

; ======================================================================
; CODIGO 0x5549..0x55a3  (90 bytes)
; ======================================================================


MONTA_LA_BASE:		; Escribe el nombre de la base y descomprime su bandera en los patrones de sprite
	ld hl,06628h		;5549   ; Los dibujos de la base, a la VRAM 0x1100
	ld de,05100h		;554c
	call DESCOMPRIME_DE		;554f
	ld hl,055a3h		;5552   ; El nombre que toca, de la tabla de las diez fases
	ld a,(0e0e1h)		;5555
	ld c,a			;5558   ; El nombre que toca sale de la tabla de las diez fases
	add a,a			;5559
	call SUMA_A_HL		;555a
	ld e,(hl)			;555d
	inc hl			;555e
	ld d,(hl)			;555f
	ex de,hl			;5560
	call ESCRIBE_CADENA		;5561
	ld hl,05626h		;5564   ; La bandera, indexada aparte con 0xE0E0
	ld a,(0e0e0h)		;5567   ; La bandera se indexa aparte, con 0xE0E0, que es el numero del panel
	and 00fh		;556a
	add a,a			;556c
	call SUMA_A_HL		;556d
	ld e,(hl)			;5570
	inc hl			;5571
	ld d,(hl)			;5572
	ex de,hl			;5573
	ld de,05f40h		;5574   ; VRAM 0x1F40: los patrones de sprite
	call DESCOMPRIME_DE		;5577
	ld a,(hl)			;557a   ; Y detras de la bandera van los dos colores
	ld (0e063h),a		;557b
	inc hl			;557e
	ld a,(hl)			;557f
	ld (0e067h),a		;5580
	jr BANDERA_A_VRAM		;5583
SUBE_LA_BANDERA:		; Sube la bandera dos pixeles por llamada hasta el tope del mastil. OJO CON DONDE SE PARA: el `cp 036h / ret z` se vuelve SIN GUARDAR el valor nuevo, asi que la bandera nunca llega a Y=0x36; se queda en 0x38. Medido en la llegada a Francia de la partida grabada: 0x50, 0x48, 0x3E y 0x38, y ahi se queda clavada
	ld a,(0e060h)		;5585
	sub 002h		;5588
	cp 036h		;558a
	ret z			;558c
	ld (0e060h),a		;558d   ; La misma Y en los tres atributos: los tres sprites de la bandera van montados en el mismo sitio
	ld (0e064h),a		;5590
	ld (0e068h),a		;5593
BANDERA_A_VRAM:		; Los TRES sprites de la bandera, a la VRAM. Son doce bytes, o sea tres atributos: el patron 0xE8 con el primer color, el 0xEC con el segundo, y el 0xE4 con blanco fijo. Ese tercero no viene en el flujo comprimido -sale de la carga general de sprites- y es un rectangulo blanco macizo de 16x12 que hace de fondo. Y como en un MSX el sprite de numero mas bajo va DELANTE, el orden de dibujo es blanco, segundo color y primer color encima
	ld hl,0e060h		;5596
	ld de,03b10h		;5599
	ld bc,0000ch		;559c
	call COPIA_A_VRAM		;559f
	ret			;55a2

; ----------------------------------------------------------------------
; DATOS punteros_de_las_bases: Diez punteros, uno por fase, a los nombres de
;   las bases. Cierra clavada en 0x55B7, que es la primera cadena; con ocho,
;   nueve, once o doce entradas no cierra
;   0x55a3..0x55b7  (20 bytes)
DATA_punteros_de_las_bases:
	defw 055cfh,055eah,05613h,055eah,055eah,055f2h,05600h,055b7h,055c1h,055c1h	; 55a3

; ----------------------------------------------------------------------
; DATOS nombres_de_las_bases: OCHO cadenas para diez fases: JAPAN, AUSTRALIA,
;   FRANCE, NEW ZEALAND, ARGENTINA, UNITED KINGDOM, THE SOUTH POLE y USA. El
;   reparto que sale de la tabla de arriba es FRANCE, USA, THE SOUTH POLE,
;   USA, USA, ARGENTINA, UNITED KINGDOM, JAPAN, AUSTRALIA y AUSTRALIA. NEW
;   ZEALAND (0x55DA..0x55E9) NO LA VISITA NADIE: no esta en la tabla, ninguna
;   instruccion la apunta, y ninguna de sus dieciseis direcciones aparece como
;   palabra en los 16 KB. En la PRIMERA version japonesa del cartucho si se
;   visita, y es la fase 4; ver la pagina de las versiones. Los dos primeros
;   bytes de cada cadena son el destino en la tabla de nombres de la VRAM, o
;   sea el centrado: 0x3AC8 para las dos de catorce letras y 0x3ACE para USA
;   0x55b7..0x5626  (111 bytes)
DATA_nombres_de_las_bases:
	defb 0cdh,03ah,020h,02ah,021h,030h,021h,02eh,020h,0ffh,0cbh,03ah,020h,021h,035h,033h	; 55b7  .: *!0!. ..: !53
	defb 034h,032h,021h,02ch,029h,021h,020h,0ffh,0cch,03ah,020h,0c9h,032h,021h,02eh,023h	; 55c7  42!,)! ..: .2!.#
	defb 025h,020h,0ffh,0cah,03ah,020h,02eh,025h,0cah,00fh,0cbh,025h,021h,02ch,021h,02eh	; 55d7  % ..: .%...%!,!.
	defb 024h,020h,0ffh,0ceh,03ah,020h,035h,033h,021h,020h,0ffh,0cbh,03ah,020h,021h,032h	; 55e7  $ ..: 53! ..: !2
	defb 027h,025h,02eh,034h,029h,02eh,021h,020h,0ffh,0c8h,03ah,020h,035h,02eh,029h,034h	; 55f7  '%.4).! ..: 5.)4
	defb 025h,024h,00fh,02bh,029h,02eh,027h,024h,02fh,02dh,020h,0ffh,0c8h,03ah,020h,034h	; 5607  %$.+).'$/- ..: 4
	defb 028h,025h,00fh,033h,02fh,035h,034h,028h,00fh,030h,02fh,02ch,025h,020h,0ffh	; 5617  (%.3/54(.0/,% .

; ----------------------------------------------------------------------
; DATOS punteros_de_banderas: Diez punteros a los graficos de bandera. Cierra
;   clavada en 0x563A
;   0x5626..0x563a  (20 bytes)
DATA_punteros_de_banderas:
	defw 05653h,05682h,056bbh,0573fh,056bbh,056bbh,056dfh,05702h,0563ah,05653h	; 5626

; ----------------------------------------------------------------------
; DATOS banderas_comprimidas: Siete banderas distintas para diez ranuras. Los
;   diez flujos miden entre 11 y 59 bytes y TODOS descomprimen a 64 bytes
;   exactos, que son dos sprites de 16x16; detras de cada uno van sus dos
;   colores
;   0x563a..0x5781  (327 bytes)
DATA_banderas_comprimidas:
	defb 002h,000h,082h,003h,007h,003h,00fh,082h,007h,003h,009h,000h,082h,080h,0c0h,003h	; 563a  ................
	defb 0e0h,082h,0c0h,080h,027h,000h,000h,006h,00fh,087h,0cch,06dh,00ch,0ffh,00ch,06dh	; 564a  ....'......m...m
	defb 0cch,009h,000h,087h,0c0h,080h,000h,0c0h,000h,080h,0c0h,009h,000h,007h,000h,002h	; 565a  ................
	defb 0ffh,002h,0fbh,001h,0ffh,004h,000h,089h,03fh,03bh,03fh,03dh,02fh,03bh,03fh,0ffh	; 566a  ........?;?=/;?.
	defb 0f7h,003h,0ffh,004h,000h,000h,006h,00dh,010h,000h,00ch,03fh,004h,000h,00ch,0f8h	; 567a  ...........?....
	defb 014h,000h,000h,006h,004h,087h,0cch,06dh,00ch,0ffh,00ch,06dh,0cch,009h,000h,087h	; 568a  .......m...m....
	defb 0c0h,080h,000h,0c0h,000h,080h,0c0h,009h,000h,007h,000h,005h,0ffh,004h,000h,08ch	; 569a  ................
	defb 03fh,03fh,037h,03fh,03bh,02fh,03fh,0ffh,0ffh,0f7h,0ffh,0ffh,004h,000h,000h,006h	; 56aa  ??7?;/?.........
	defb 00dh,007h,000h,085h,0ffh,000h,0ffh,000h,0ffh,005h,000h,08bh,0ffh,000h,0ffh,000h	; 56ba  ................
	defb 0ffh,000h,0ffh,000h,0ffh,000h,0ffh,004h,000h,086h,055h,0aah,055h,0aah,055h,0aah	; 56ca  ..........U.U.U.
	defb 01ah,000h,000h,006h,004h,004h,000h,084h,001h,003h,003h,001h,00ch,000h,084h,080h	; 56da  ................
	defb 0c0h,0c0h,080h,008h,000h,004h,0ffh,004h,000h,004h,0ffh,004h,000h,004h,0ffh,004h	; 56ea  ................
	defb 000h,004h,0ffh,004h,000h,000h,00ah,007h,08ch,061h,031h,019h,00dh,001h,0ffh,0ffh	; 56fa  .........a1.....
	defb 001h,00dh,019h,031h,061h,004h,000h,08ch,086h,08ch,098h,0b0h,080h,0ffh,0ffh,080h	; 570a  ...1a...........
	defb 0b0h,098h,08ch,086h,004h,000h,084h,00ch,084h,0c0h,0e0h,004h,000h,084h,0e0h,0c0h	; 571a  ................
	defb 084h,00ch,004h,000h,084h,030h,021h,003h,007h,004h,000h,084h,007h,003h,021h,030h	; 572a  .....0!.......!0
	defb 004h,000h,000h,008h,005h,08bh,003h,004h,00ah,00ch,02ch,03eh,018h,008h,008h,00ch	; 573a  ..........,>....
	defb 007h,005h,000h,08bh,0c0h,020h,050h,010h,030h,078h,01ch,014h,010h,030h,0e0h,005h	; 574a  ..... P.0x...0..
	defb 000h,085h,000h,000h,002h,001h,003h,003h,000h,083h,000h,000h,018h,005h,000h,085h	; 575a  ................
	defb 000h,000h,040h,080h,0c0h,003h,000h,083h,000h,000h,018h,005h,000h,000h,001h,00ah	; 576a  ..@.............
	defb 00ch,038h,028h,029h,020h,0feh,016h	; 577a

; ----------------------------------------------------------------------
; DATOS rotulos: Los rotulos de pantalla, en el formato de las cadenas: el
;   panel (1P, HI, STAGE, TIME), el logotipo de KONAMI con su 1984 -las letras
;   del logotipo son dibujos propios, no la fuente-, PLAY SELECT con JOYSTICK
;   y KEYBOARD, TIME OUT, y el VIDEO CARTRIDGE de la portada
;   0x5781..0x5803  (130 bytes)
DATA_rotulos:
	defb 038h,033h,034h,021h,027h,025h,020h,0feh,022h,038h,034h,029h,02dh,025h,020h,0feh	; 5781  834!'% ."84)-% .
	defb 02ch,038h,038h,03ah,03bh,000h,000h,000h,000h,040h,041h,0feh,036h,038h,026h,031h	; 5791  ,88:;....@A.68&1
	defb 037h,0feh,002h,038h,011h,030h,020h,0ffh,00bh,039h,01ah,01bh,01ch,01dh,01eh,01fh	; 57a1  7..8.0 ..9......
	defb 000h,011h,019h,018h,014h,0ffh,0abh,039h,030h,02ch,021h,039h,000h,033h,025h,02ch	; 57b1  .......90,!9.3%,
	defb 025h,023h,034h,0feh,006h,03ah,011h,020h,03ch,03dh,000h,000h,030h,02ch,021h,039h	; 57c1  %#4..:. <=..0,!9
	defb 000h,03eh,03fh,000h,02ah,02fh,039h,033h,034h,029h,023h,02bh,0feh,046h,03ah,012h	; 57d1  .>?.*/934)#+.F:.
	defb 020h,03ch,03dh,000h,000h,030h,02ch,021h,039h,000h,03eh,03fh,000h,02bh,025h,039h	; 57e1   <=..0,!9.>?.+%9
	defb 022h,02fh,021h,032h,024h,0ffh,0ech,038h,034h,029h,02dh,025h,000h,02fh,035h,034h	; 57f1  "/!2$..84)-%./54
	defb 0ffh,066h	; 5801

; ----------------------------------------------------------------------
; DATOS titulo_comprimido: La pantalla de titulo: relleno y el rotulo SOFTWARE
;   en la fila 10. Pasado por el descompresor son veinte casillas en dos
;   sitios (VRAM 0x394A y 0x396C) y el flujo se acaba en 0x5818
;   0x5803..0x5818  (21 bytes)
DATA_titulo_comprimido:
	defb 039h,020h,000h,036h,029h,024h,025h,02fh,000h,023h,021h,032h,034h,032h,029h,024h	; 5803  9 .6)$%/.#!242)$
	defb 027h,025h,000h,020h,0ffh	; 5813

; ----------------------------------------------------------------------
; DATOS mandos_de_la_demo: LOS MANDOS GRABADOS DE LA DEMO. Sesenta y cuatro
;   bytes, uno cada 32 fotogramas: 0x41A0 los apunta y 0x4103 los va leyendo.
;   La demo dura 0x073C pasos, asi que gasta 58 de los 64. Cada byte lleva los
;   mismos bits que el joystick, y se ve: 0x01 arriba, 0x09 arriba y derecha,
;   0x11 arriba y gatillo... La partida de demostracion no la juega ninguna
;   inteligencia, va grabada. Cierra clavada en 0x5858, la primera instruccion
;   de MONTA_LA_FUENTE
;   0x5818..0x5858  (64 bytes)
DATA_mandos_de_la_demo:
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,009h,001h,001h,011h	; 5818  ................
	defb 005h,005h,009h,009h,001h,006h,004h,010h,001h,001h,011h,010h,001h,001h,009h,009h	; 5828  ................
	defb 001h,005h,015h,009h,019h,001h,001h,005h,011h,001h,001h,001h,011h,001h,001h,001h	; 5838  ................
	defb 011h,001h,000h,018h,019h,009h,001h,011h,001h,001h,001h,001h,001h,001h,001h,001h	; 5848  ................

; ======================================================================
; CODIGO 0x5858..0x58a9  (81 bytes)
; ======================================================================


MONTA_LA_FUENTE:		; Monta la fuente y los colores en los tres bancos de la pantalla. OJO: que la fuente se escriba tres veces NO quiere decir que los tres bancos acaben iguales. Cada escena descomprime luego sus dibujos ENCIMA, banco por banco, y comparando los tres en una VRAM de verdad solo quedan iguales DIECINUEVE casillas: la 0x00-0x0F, que son los cuadrados de color liso, y la 0xFD-0xFF, que estan vacias. Cada tercio de la pantalla tiene su propio juego de 256 casillas, y por eso render_tiles.py saca una hoja por banco y no una para todo
	ld de,00000h		;5858   ; Los tres bancos de colores de SCREEN 2 (0x0000, 0x0800 y 0x1000), uno por llamada, con el `jp` haciendo de tercera
	call MONTA_UN_BANCO		;585b
	ld de,00800h		;585e
	call MONTA_UN_BANCO		;5861
	ld de,01000h		;5864
	jp MONTA_UN_BANCO		;5867
MONTA_UN_BANCO:		; Un banco: los dieciseis primeros caracteres en color liso, el resto blanco sobre negro, y encima la fuente
	push de			;586a
	xor a			;586b
	ld c,010h		;586c   ; Los caracteres 0 a 15 se pintan de un color liso cada uno: son los que se usan para rellenar el cielo y el hielo
BANCO_CARACTER:
	ld b,008h		;586e
BANCO_LINEA:
	call ESCRIBE_EN_VRAM		;5870
	inc de			;5873
	djnz BANCO_LINEA		;5874
	inc a			;5876
	dec c			;5877
	jr nz,BANCO_CARACTER		;5878
	ld bc,00270h		;587a   ; El resto del banco, blanco sobre negro
	ld a,0f0h		;587d
	call RELLENA_VRAM		;587f
	ld hl,05d88h		;5882   ; Y ahora los dibujos
	call DESCOMPRIME_SIGUE		;5885
	ld b,016h		;5888
BANCO_REPITE:
	ld hl,05dbeh		;588a   ; La misma tira veintidos veces
	push bc			;588d
	call DESCOMPRIME_SIGUE		;588e
	pop bc			;5891
	djnz BANCO_REPITE		;5892
	pop de			;5894
	ld hl,06000h		;5895   ; Los patrones del banco que toca
	add hl,de			;5898
	ex de,hl			;5899
	ld hl,058a9h		;589a
	call DESCOMPRIME_DE		;589d
	ld hl,05c33h		;58a0
	call DESCOMPRIME_SIGUE		;58a3
	jp DESCOMPRIME_SIGUE		;58a6

; ----------------------------------------------------------------------
; DATOS fuente_comprimida: La fuente y el logotipo de KONAMI, que van a los
;   tres bancos
;   0x58a9..0x5dca  (1313 bytes)
DATA_fuente_comprimida:
	defb 040h,000h,040h,000h,083h,000h,01ch,022h,003h,063h,085h,022h,01ch,000h,018h,038h	; 58a9  @.@....".c."...8
	defb 004h,018h,0aeh,07eh,000h,03eh,063h,003h,00eh,03ch,070h,07fh,000h,03eh,063h,003h	; 58b9  ...~.>c..<p..>c.
	defb 00eh,003h,063h,03eh,000h,00eh,01eh,036h,066h,066h,07fh,006h,000h,07fh,060h,07eh	; 58c9  ..c>...6ff....`~
	defb 063h,003h,063h,03eh,000h,03eh,063h,060h,07eh,063h,063h,03eh,000h,07fh,063h,006h	; 58d9  c.c>.>c`~cc>..c.
	defb 00ch,003h,018h,09ah,000h,03eh,063h,063h,03eh,063h,063h,03eh,000h,03eh,063h,063h	; 58e9  .....>cc>cc>.>cc
	defb 03fh,003h,063h,03eh,00fh,010h,026h,028h,028h,026h,010h,00fh,003h,083h,004h,043h	; 58f9  ?.c>..&((&.....C
	defb 08ah,083h,003h,01ch,038h,070h,0e1h,0cdh,0cdh,0fdh,079h,003h,000h,081h,0eeh,003h	; 5909  ....8p....y.....
	defb 06bh,081h,0ebh,003h,000h,089h,073h,01ah,07ah,05ah,07ah,000h,003h,000h,0f3h,004h	; 5919  k.....s.zZz.....
	defb 05bh,004h,000h,081h,07eh,004h,000h,092h,01ch,036h,063h,063h,07fh,063h,063h,000h	; 5929  [...~....6cc.cc.
	defb 07eh,063h,063h,07eh,063h,063h,07eh,000h,03eh,063h,003h,060h,085h,063h,03eh,000h	; 5939  ~cc~cc~.>c.`.c>.
	defb 07ch,066h,003h,063h,09bh,066h,07ch,000h,07fh,060h,060h,07eh,060h,060h,07fh,000h	; 5949  |f.c.f|..``~``..
	defb 0eeh,0aah,08ah,0eah,02eh,0a8h,0e8h,000h,03eh,063h,060h,067h,063h,063h,03fh,000h	; 5959  ........>c`gcc?.
	defb 003h,063h,081h,07fh,003h,063h,082h,000h,03ch,005h,018h,083h,03ch,000h,01fh,004h	; 5969  .c...c..<...<...
	defb 006h,08bh,066h,03ch,000h,063h,066h,06ch,078h,07ch,06eh,067h,000h,006h,060h,093h	; 5979  ..f<.cflx|ng..`.
	defb 07fh,000h,063h,077h,07fh,07fh,06bh,063h,063h,000h,063h,073h,07bh,07fh,06fh,067h	; 5989  ..cw..kcc.cs{.og
	defb 063h,000h,03eh,005h,063h,083h,03eh,000h,07eh,003h,063h,09dh,07eh,060h,060h,000h	; 5999  c.>.c.>.~.c.~``.
	defb 0eeh,088h,088h,0eeh,088h,088h,0eeh,000h,07eh,063h,063h,062h,07ch,066h,063h,000h	; 59a9  ........~ccb|fc.
	defb 03eh,063h,060h,03eh,003h,063h,03eh,000h,07eh,006h,018h,081h,000h,006h,063h,082h	; 59b9  >c`>.c>.~.....c.
	defb 03eh,000h,004h,063h,085h,036h,01ch,008h,000h,0c0h,005h,0a0h,083h,0c0h,000h,0f3h	; 59c9  >..c.6..........
	defb 003h,0dbh,088h,0f3h,0d3h,0dbh,000h,066h,066h,07eh,03ch,003h,018h,08dh,000h,0dfh	; 59d9  .......ff~<.....
	defb 01ah,018h,0cch,006h,016h,0deh,000h,0f8h,060h,060h,067h,003h,060h,0a8h,000h,000h	; 59e9  ........``g.`...
	defb 040h,049h,05ah,073h,052h,059h,000h,000h,000h,092h,052h,0ceh,002h,0dch,000h,000h	; 59f9  @IZsRY....R.....
	defb 002h,000h,08ah,0aah,0aah,0dah,000h,000h,008h,048h,0eeh,04ah,04ah,06ah,000h,000h	; 5a09  .........H.JJj..
	defb 020h,024h,02dh,039h,029h,02dh,004h,000h,001h,0f0h,003h,050h,001h,000h,007h,0eeh	; 5a19   $-9)-.....P....
	defb 001h,000h,007h,0e0h,00eh,000h,082h,007h,00fh,006h,000h,082h,0f8h,0f0h,004h,03eh	; 5a29  ...............>
	defb 004h,03fh,08bh,01fh,03fh,07fh,0ffh,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h,003h,000h	; 5a39  .?..?...........
	defb 002h,03eh,005h,000h,083h,01fh,07fh,0fbh,005h,000h,083h,00fh,0cfh,0efh,005h,000h	; 5a49  .>..............
	defb 083h,078h,0fch,0bch,005h,000h,083h,03fh,07fh,0f3h,005h,000h,083h,087h,0c7h,0c7h	; 5a59  .x.....?........
	defb 005h,000h,083h,0bch,0feh,0dfh,005h,000h,088h,078h,0fch,0bch,060h,0f0h,0f0h,060h	; 5a69  .........x..`..`
	defb 000h,003h,0f0h,002h,03fh,006h,03eh,088h,0f8h,0fch,0feh,07fh,03fh,01fh,00fh,007h	; 5a79  ....?.>.....?...
	defb 003h,03eh,085h,07eh,0fch,0fch,0f8h,0e0h,005h,0f1h,083h,0fbh,07fh,01fh,006h,0efh	; 5a89  .>.~............
	defb 082h,0cfh,00fh,008h,01eh,088h,0e1h,003h,03fh,0f1h,0e1h,0f3h,07fh,01eh,007h,0e7h	; 5a99  ........?.......
	defb 081h,0f7h,008h,08fh,008h,01eh,082h,0f1h,0f2h,004h,0f5h,097h,0f2h,0f1h,0e0h,010h	; 5aa9  ................
	defb 0c8h,068h,0c8h,028h,010h,0e0h,000h,000h,008h,02eh,06fh,07fh,03fh,07fh,000h,003h	; 5ab9  .h.(......o.?...
	defb 007h,00fh,0dfh,003h,0ffh,083h,000h,0e0h,0fch,005h,0ffh,004h,000h,090h,0e0h,0f0h	; 5ac9  ................
	defb 0fch,0ffh,000h,003h,003h,000h,001h,001h,003h,007h,0c0h,080h,087h,0e7h,004h,0ffh	; 5ad9  ................
	defb 003h,000h,085h,0c0h,0f0h,0fch,0ffh,0ffh,004h,000h,089h,0c0h,0e0h,0e0h,0f0h,010h	; 5ae9  ................
	defb 018h,018h,01dh,01dh,003h,00fh,002h,01fh,002h,03fh,002h,07fh,002h,0ffh,002h,0f8h	; 5af9  .........?......
	defb 003h,0e0h,003h,0f0h,083h,007h,003h,001h,005h,000h,088h,080h,0ceh,0ffh,07fh,00fh	; 5b09  ................
	defb 00fh,01fh,000h,003h,0f8h,003h,0fch,08eh,0ffh,0c0h,000h,03eh,03fh,003h,003h,007h	; 5b19  ...........>?...
	defb 006h,006h,01fh,01fh,00fh,08fh,003h,0cfh,089h,00fh,000h,080h,0c0h,0c0h,0e0h,0e0h	; 5b29  ................
	defb 0f0h,0f0h,003h,07fh,085h,0ffh,07fh,07fh,05fh,04ch,006h,0f0h,002h,0f8h,002h,07fh	; 5b39  ........_L......
	defb 004h,03fh,084h,07fh,07fh,0f8h,0fch,003h,0f0h,003h,0e0h,003h,07fh,087h,03fh,03fh	; 5b49  .?............??
	defb 01fh,01fh,00fh,0c0h,080h,003h,000h,083h,080h,0c0h,0c0h,004h,0ffh,084h,01fh,007h	; 5b59  ................
	defb 000h,000h,003h,0ffh,097h,0feh,03eh,01ch,0c0h,000h,0ffh,0ffh,0feh,0feh,0fch,0fch	; 5b69  ......>.........
	defb 0f8h,0f0h,00fh,007h,007h,003h,003h,007h,01fh,01fh,0f0h,0f0h,004h,0e0h,082h,0c0h	; 5b79  ................
	defb 080h,003h,01fh,082h,00fh,007h,003h,000h,005h,0ffh,083h,0feh,0f0h,000h,005h,0ffh	; 5b89  ................
	defb 083h,038h,000h,000h,085h,0feh,0fch,0f8h,0e0h,080h,003h,000h,08ah,07fh,067h,001h	; 5b99  .8............g.
	defb 003h,007h,007h,00fh,00fh,080h,0c0h,003h,0e0h,084h,0c0h,0c0h,080h,00fh,005h,01fh	; 5ba9  ................
	defb 08fh,00fh,00fh,080h,0fch,0f8h,0f1h,0f3h,0f3h,0ffh,0ffh,001h,00fh,01fh,03fh,03fh	; 5bb9  ..............??
	defb 007h,0ffh,084h,0fdh,0fch,0fch,0f8h,005h,0ffh,084h,03fh,01fh,003h,0f8h,004h,0f0h	; 5bc9  ..........?.....
	defb 089h,030h,010h,000h,0ffh,0ffh,07fh,03fh,01fh,00fh,003h,003h,084h,007h,00fh,01fh	; 5bd9  .0.....?........
	defb 00fh,003h,007h,005h,000h,088h,001h,00fh,0ffh,000h,000h,001h,003h,03fh,006h,0ffh	; 5be9  .............?..
	defb 085h,07fh,03fh,001h,000h,000h,006h,0ffh,082h,01fh,000h,083h,040h,0e0h,040h,005h	; 5bf9  ..?.........@.@.
	defb 000h,098h,0e0h,0a0h,080h,0e0h,020h,0a8h,0e8h,000h,0eeh,0aah,0aah,0aah,0eah,08ah	; 5c09  ...... .........
	defb 08eh,000h,08eh,088h,088h,08eh,088h,088h,0eeh,000h,008h,000h,005h,000h,006h,00fh	; 5c19  ................
	defb 00ah,000h,006h,0f0h,00ah,000h,006h,0ffh,005h,000h,006h,0c0h,004h,0ffh,010h,0c0h	; 5c29  ................
	defb 00ch,000h,004h,0ffh,006h,000h,008h,003h,003h,007h,005h,000h,002h,0ffh,004h,0e0h	; 5c39  ................
	defb 084h,0c0h,000h,0ffh,0ffh,013h,0c0h,006h,0e0h,005h,0c0h,000h,001h,003h,007h,001h	; 5c49  ................
	defb 002h,003h,002h,007h,003h,00fh,083h,01fh,01eh,01eh,003h,03fh,08dh,07ch,078h,0f8h	; 5c59  ...........?.|x.
	defb 0e0h,0e0h,0f0h,0f0h,0f8h,0f8h,078h,07ch,03ch,03ch,003h,0feh,083h,01fh,00fh,00fh	; 5c69  ......x|<<......
	defb 006h,000h,084h,03bh,03fh,03fh,03bh,005h,039h,001h,0b9h,003h,000h,086h,003h,007h	; 5c79  ...;??;.9.......
	defb 007h,01fh,09fh,0dfh,005h,0c7h,082h,0c3h,0c1h,006h,000h,08ah,0c7h,0cfh,0cfh,000h	; 5c89  ................
	defb 00fh,01fh,09ch,0dfh,0cfh,0c7h,006h,000h,083h,0c3h,0e3h,0e3h,003h,0f3h,084h,073h	; 5c99  ...............s
	defb 0f3h,0f3h,0bbh,006h,000h,08ah,018h,0b9h,0fbh,0f3h,0c3h,083h,083h,081h,081h,080h	; 5ca9  ................
	defb 006h,000h,003h,0fbh,084h,0c0h,080h,080h,0c0h,003h,0f8h,086h,000h,001h,003h,063h	; 5cb9  ...............c
	defb 0e1h,0e0h,003h,0fbh,003h,0e3h,094h,0f3h,0fbh,07bh,03bh,000h,000h,080h,080h,000h	; 5cc9  .........{;.....
	defb 000h,08fh,09fh,0bfh,0bch,0b8h,0b8h,0bch,0bfh,09fh,08fh,006h,000h,003h,080h,004h	; 5cd9  ................
	defb 000h,003h,080h,002h,003h,002h,007h,003h,00fh,083h,01fh,01eh,01eh,003h,03fh,08dh	; 5ce9  ..............?.
	defb 07ch,078h,0f8h,0e0h,0e0h,0f0h,0f0h,0f8h,0f8h,078h,07ch,03ch,03ch,003h,0feh,083h	; 5cf9  |x.......x|<<...
	defb 01fh,00fh,00fh,006h,000h,08bh,01eh,03fh,07fh,079h,070h,070h,078h,07fh,03fh,09eh	; 5d09  .......?.yppx.?.
	defb 000h,005h,0e0h,001h,0efh,003h,0e7h,003h,0e3h,083h,0e1h,0e1h,0e0h,006h,000h,08ah	; 5d19  ................
	defb 01eh,01ch,0bch,0bdh,0b9h,0f9h,0f9h,0f0h,0f0h,0e0h,006h,000h,08ah,03ch,0feh,0eeh	; 5d29  .............<..
	defb 0c7h,0ffh,0ffh,0c0h,0e7h,0ffh,03eh,006h,000h,084h,076h,07fh,07fh,07bh,006h,073h	; 5d39  ......>...v..{.s
	defb 003h,000h,086h,006h,00eh,00eh,03fh,03fh,0bfh,003h,08eh,084h,08fh,08fh,087h,083h	; 5d49  ......??........
	defb 006h,000h,003h,0b9h,004h,039h,083h,0bdh,09fh,08eh,006h,000h,085h,0dch,0ddh,0dfh	; 5d59  .....9..........
	defb 0dfh,0deh,005h,0dch,006h,000h,08ah,0c3h,0cfh,0ceh,0dch,01fh,01fh,01ch,00eh,00fh	; 5d69  ................
	defb 003h,006h,000h,08ah,0c0h,0e0h,0e0h,070h,0f0h,0f0h,000h,070h,0f0h,0e0h,000h,018h	; 5d79  .......p...p....
	defb 0f4h,078h,0f4h,070h,0f4h,050h,0f7h,020h,074h,028h,01fh,020h,060h,010h,06ah,038h	; 5d89  .x.p.P. t(. `.j8
	defb 0efh,002h,01eh,006h,01fh,002h,0efh,006h,07fh,00ah,0e7h,00bh,0efh,006h,01fh,005h	; 5d99  ................
	defb 0efh,038h,06fh,002h,016h,006h,01fh,002h,06fh,006h,07fh,00ah,067h,00bh,06fh,006h	; 5da9  .8o.....o...g.o.
	defb 01fh,005h,06fh,008h,017h,00ah,0f1h,003h,071h,002h,051h,001h,041h,000h,008h,019h	; 5db9  ..o.....q.Q.A...
	defb 000h	; 5dc9

; ======================================================================
; CODIGO 0x5dca..0x5dfa  (48 bytes)
; ======================================================================


CARGA_BANCO_1:		; Descomprime los dibujos del banco 1
	ld hl,05dfah		;5dca
	call DESCOMPRIME		;5dcd
	ld hl,05dfch		;5dd0
	ld de,06a88h		;5dd3
	call DESCOMPRIME_ESPEJO		;5dd6   ; Este va espejado: la mitad derecha del dibujo se saca dandole la vuelta a los bits de la izquierda
	call DESCOMPRIME		;5dd9   ; Sin `ld hl` delante: sigue con el flujo que quedo
	ld hl,06182h		;5ddc
	call DESCOMPRIME		;5ddf
	ld hl,06189h		;5de2
	ld de,04a88h		;5de5
	call DESCOMPRIME_DE		;5de8
	call DESCOMPRIME		;5deb
	ld hl,06187h		;5dee
	call DESCOMPRIME		;5df1
	ld hl,06258h		;5df4
	jp DESCOMPRIME		;5df7

; ----------------------------------------------------------------------
; DATOS dibujos_banco1: Dibujos y colores del banco 1, comprimidos
;   0x5dfa..0x623b  (1089 bytes)
DATA_dibujos_banco1:
	defb 080h,068h,082h,000h,0ffh,007h,000h,084h,0ffh,000h,007h,0ffh,004h,000h,0a5h,0ffh	; 5dfa  .h..............
	defb 000h,0ffh,0ffh,000h,000h,0ffh,000h,0ffh,000h,000h,0ffh,000h,0ffh,0ffh,000h,0ffh	; 5e0a  ................
	defb 000h,0ffh,0ffh,000h,0ffh,0ffh,000h,0ffh,000h,000h,0ffh,000h,000h,0ffh,000h,003h	; 5e1a  ................
	defb 01fh,0ffh,015h,002h,003h,000h,003h,0ffh,082h,055h,0aah,003h,000h,003h,0ffh,089h	; 5e2a  .........U......
	defb 005h,083h,01fh,0ffh,000h,000h,0ffh,0ffh,000h,003h,0ffh,08ch,000h,000h,0ffh,0ffh	; 5e3a  ................
	defb 000h,0e0h,0ffh,0ffh,000h,000h,0ffh,0ffh,003h,000h,001h,0ffh,003h,000h,087h,0ffh	; 5e4a  ................
	defb 000h,000h,0ffh,0ffh,02ah,005h,006h,000h,089h,0aah,054h,003h,01fh,0ffh,02ah,005h	; 5e5a  ....*.....T...*.
	defb 000h,000h,004h,0ffh,085h,0aah,055h,022h,000h,000h,003h,0ffh,08bh,0aah,050h,007h	; 5e6a  ......U"......P.
	defb 000h,000h,0ffh,0ffh,0e0h,01fh,0ffh,0ffh,003h,000h,082h,0ffh,000h,003h,0ffh,003h	; 5e7a  ................
	defb 000h,089h,0ffh,0ffh,000h,0ffh,0ffh,000h,000h,00fh,001h,004h,000h,088h,017h,0ffh	; 5e8a  ................
	defb 0ffh,055h,02ah,005h,000h,000h,003h,0ffh,083h,055h,0aah,011h,005h,000h,082h,00fh	; 5e9a  .U*......U......
	defb 002h,004h,000h,088h,01fh,0ffh,0ffh,0aah,054h,003h,01fh,000h,003h,0ffh,001h,000h	; 5eaa  ........T.......
	defb 003h,0ffh,001h,000h,003h,0ffh,086h,000h,000h,0ffh,0ffh,0aah,055h,007h,000h,004h	; 5eba  ............U...
	defb 0ffh,085h,0a8h,047h,03fh,000h,000h,003h,0ffh,088h,000h,0ffh,0ffh,000h,00fh,0ffh	; 5eca  ...G?...........
	defb 015h,002h,004h,000h,003h,0ffh,089h,000h,0e0h,0ffh,0ffh,000h,0ffh,000h,0ffh,0ffh	; 5eda  ................
	defb 004h,000h,084h,0ffh,000h,000h,0ffh,00ah,000h,001h,0ffh,004h,000h,084h,03fh,000h	; 5eea  ..............?.
	defb 0ffh,0ffh,003h,000h,08ah,080h,0ffh,000h,000h,0ffh,07fh,01fh,00fh,003h,001h,003h	; 5efa  ................
	defb 000h,005h,0ffh,085h,07fh,03fh,00fh,007h,001h,006h,000h,003h,0ffh,08dh,03fh,01fh	; 5f0a  .....?........?.
	defb 007h,003h,000h,0ffh,07fh,01fh,00fh,007h,001h,000h,000h,007h,0ffh,085h,07fh,01fh	; 5f1a  ................
	defb 00fh,007h,001h,004h,000h,006h,0ffh,082h,07fh,03fh,004h,0ffh,091h,01fh,007h,003h	; 5f2a  .........?......
	defb 000h,007h,00fh,01fh,01fh,01fh,00fh,007h,003h,0ffh,03fh,00fh,003h,001h,003h,000h	; 5f3a  ..........?.....
	defb 084h,0ffh,07fh,01fh,00fh,004h,000h,006h,000h,002h,01fh,005h,0ffh,003h,000h,003h	; 5f4a  ................
	defb 0ffh,082h,07fh,01fh,003h,000h,003h,0ffh,005h,000h,090h,07fh,01fh,00fh,01fh,03fh	; 5f5a  ...............?
	defb 00fh,007h,001h,007h,00fh,01fh,03fh,007h,003h,000h,000h,004h,000h,002h,001h,005h	; 5f6a  ......?.........
	defb 0ffh,087h,03fh,01fh,03fh,07fh,0ffh,000h,003h,009h,000h,082h,001h,003h,003h,000h	; 5f7a  ..?.?...........
	defb 083h,001h,003h,007h,005h,000h,001h,07fh,005h,03fh,082h,01fh,00fh,006h,0ffh,006h	; 5f8a  .........?......
	defb 07fh,08ch,01fh,00fh,007h,001h,07fh,01fh,00fh,003h,001h,000h,003h,007h,003h,0ffh	; 5f9a  ................
	defb 005h,03fh,000h,090h,06ch,00bh,000h,001h,0ffh,00bh,000h,001h,003h,007h,000h,001h	; 5faa  .?..l...........
	defb 0ffh,007h,000h,001h,0f0h,004h,000h,001h,01fh,007h,000h,001h,0ffh,004h,000h,082h	; 5fba  ................
	defb 03fh,0ffh,006h,000h,002h,0ffh,006h,000h,082h,0fch,0ffh,005h,000h,082h,001h,00fh	; 5fca  ?...............
	defb 006h,000h,002h,0ffh,006h,000h,082h,0f0h,0feh,006h,000h,004h,0ffh,013h,000h,001h	; 5fda  ................
	defb 00fh,007h,000h,001h,0c0h,004h,000h,001h,0f8h,003h,000h,082h,00fh,07fh,006h,000h	; 5fea  ................
	defb 082h,080h,0f0h,009h,000h,001h,003h,007h,000h,001h,0e0h,007h,000h,001h,00fh,007h	; 5ffa  ................
	defb 000h,001h,0c0h,004h,000h,001h,07fh,003h,00fh,004h,000h,001h,0feh,003h,0f0h,01fh	; 600a  ................
	defb 000h,001h,001h,007h,000h,001h,080h,007h,000h,001h,007h,007h,000h,001h,0e0h,00bh	; 601a  ................
	defb 000h,001h,0f8h,007h,000h,001h,01fh,004h,000h,001h,07fh,007h,000h,001h,0feh,009h	; 602a  ................
	defb 000h,002h,007h,006h,000h,085h,0e0h,0e0h,000h,01fh,01fh,006h,000h,002h,0ffh,006h	; 603a  ................
	defb 000h,002h,0f8h,005h,000h,002h,01fh,006h,000h,002h,0f8h,006h,000h,002h,0ffh,00ah	; 604a  ................
	defb 000h,001h,003h,007h,000h,001h,0c0h,003h,000h,084h,07fh,07fh,0ffh,07fh,004h,000h	; 605a  ................
	defb 084h,0feh,0feh,0ffh,0feh,004h,000h,004h,0ffh,016h,000h,002h,004h,00ah,000h,002h	; 606a  ................
	defb 030h,006h,000h,002h,003h,003h,000h,002h,0c0h,009h,000h,004h,0f0h,00ch,000h,006h	; 607a  0...............
	defb 0ffh,003h,080h,001h,0c0h,003h,00eh,002h,008h,003h,000h,002h,003h,004h,002h,002h	; 608a  ................
	defb 000h,001h,000h,003h,00fh,001h,009h,004h,000h,003h,0e0h,001h,020h,004h,000h,093h	; 609a  ............ ...
	defb 07bh,0e0h,0e4h,0e4h,0e0h,0e0h,098h,000h,0f6h,0ffh,0bfh,0bfh,0ffh,0ffh,053h,000h	; 60aa  {.............S.
	defb 030h,070h,077h,00bh,0f8h,087h,0e0h,000h,026h,0eeh,0efh,0ffh,0ffh,004h,09fh,004h	; 60ba  0pw.....&.......
	defb 0ffh,088h,0feh,0cch,000h,024h,0eeh,0efh,0ffh,087h,00fh,07fh,09bh,06fh,003h,001h	; 60ca  .....$.......o..
	defb 000h,000h,022h,063h,063h,0f3h,0f7h,0f7h,0ffh,0ffh,0ddh,088h,000h,0dbh,0ffh,0ffh	; 60da  .."cc...........
	defb 000h,000h,002h,063h,063h,0f3h,0f7h,0f7h,003h,0ffh,007h,0feh,009h,0ffh,082h,0c3h	; 60ea  ...cc...........
	defb 081h,003h,000h,002h,0ffh,001h,00fh,00ch,0ffh,001h,000h,003h,0ffh,085h,0f7h,0c7h	; 60fa  ................
	defb 082h,000h,000h,003h,0ffh,007h,01fh,009h,0ffh,007h,0c3h,008h,0ffh,001h,0f8h,00dh	; 610a  ................
	defb 0f7h,00bh,0fch,001h,000h,008h,0ffh,084h,07fh,022h,000h,000h,004h,0f7h,084h,077h	; 611a  .........".....w
	defb 022h,000h,000h,002h,04fh,006h,07fh,001h,003h,015h,001h,082h,003h,00fh,004h,000h	; 612a  "...O...........
	defb 084h,080h,0c0h,0e0h,0ffh,005h,000h,082h,00fh,0ffh,005h,000h,093h,0f8h,0e7h,04dh	; 613a  ...............M
	defb 018h,000h,000h,00fh,01fh,0fah,0ebh,0c5h,080h,000h,000h,0f0h,0fch,03fh,0dch,068h	; 614a  .............?.h
	defb 003h,000h,085h,003h,0ffh,0ffh,0b5h,016h,005h,000h,003h,01fh,001h,03fh,004h,000h	; 615a  .............?..
	defb 004h,0ffh,004h,000h,084h,0c0h,0fch,0fch,0ffh,004h,000h,084h,0ffh,0efh,0ffh,0f7h	; 616a  ................
	defb 004h,000h,084h,0ffh,0d3h,0fdh,0ceh,000h,098h,06ah,010h,000h,000h,080h,048h,078h	; 617a  .........j....Hx
	defb 0efh,078h,0efh,038h,0efh,060h,04fh,006h,04fh,082h,01fh,041h,02ch,04fh,082h,01fh	; 618a  .x.8.`O.O..A,O..
	defb 041h,00ah,04fh,018h,01fh,002h,04fh,003h,041h,00ah,04fh,001h,041h,003h,041h,00bh	; 619a  A.O...O.A.O.A.A.
	defb 04fh,002h,01fh,005h,04fh,003h,041h,000h,090h,04ch,070h,04fh,030h,04fh,020h,01fh	; 61aa  O...O.A..LpO0O .
	defb 002h,04fh,002h,041h,006h,04fh,002h,041h,004h,04fh,078h,05fh,030h,05fh,001h,0efh	; 61ba  .O.A.O.A.Ox_0_..
	defb 007h,05fh,001h,0efh,007h,05fh,001h,0efh,007h,05fh,04ch,03fh,004h,0efh,003h,03fh	; 61ca  ._..._..._L?...?
	defb 005h,0efh,002h,03fh,006h,0efh,010h,09fh,002h,08fh,006h,089h,008h,09fh,004h,08fh	; 61da  ...?............
	defb 00bh,089h,004h,06fh,003h,09fh,004h,097h,006h,09fh,003h,06fh,003h,09fh,00fh,096h	; 61ea  ...o.......o....
	defb 003h,09fh,007h,06fh,001h,09fh,005h,0f6h,003h,096h,007h,06eh,001h,08eh,009h,097h	; 61fa  ...o.......n....
	defb 01fh,09fh,008h,08fh,020h,097h,003h,09fh,00dh,096h,00bh,076h,00dh,09fh,003h,096h	; 620a  .... ......v....
	defb 005h,09fh,008h,096h,017h,017h,001h,01fh,008h,0f7h,007h,0f7h,001h,0f4h,005h,0f7h	; 621a  ................
	defb 003h,0f4h,004h,0f7h,004h,0f4h,004h,0f7h,004h,0f4h,003h,0f7h,005h,0f4h,028h,0f7h	; 622a  ..............(.
	defb 000h	; 623a

; ----------------------------------------------------------------------
; DATOS colores_de_pista_b: LOS COLORES DE LA PISTA DEL SEGUNDO TIPO DE FASE:
;   29 bytes que descomprimen a 112 en la VRAM 0x0F78. Van EN PAREJA con los
;   otros 29 de 0x621E-0x623A -que son los del primer tipo y caen dentro del
;   rango de arriba-, y 0x500E elige entre las dos parejas mirando el bit 0 de
;   la tabla de 0x515F con la fase: o 0x5DB2 y 0x621E, o 0x5DBD y 0x623B. EL
;   PUNTERO NO SE VE MIRANDO LAS INSTRUCCIONES DE AL LADO, y por eso el
;   reconstructor se saltaba estos bytes: 0x502F hace `ld de,06263h`, 0x5032
;   lo GUARDA EN LA PILA y quien lo usa es el `pop hl` de 0x5039, dos
;   descompresiones despues. Es el mismo truco que la fuente en 0x589D. Cierra
;   clavado en 0x6258, donde empieza el remate del banco 1
;   0x623b..0x6258  (29 bytes)
DATA_colores_de_pista_b:
	defb 017h,019h,001h,01fh,008h,0f9h,007h,0f9h,001h,0f4h,005h,0f9h,003h,0f4h,004h,0f9h	; 623b  ................
	defb 004h,0f4h,004h,0f9h,004h,0f4h,003h,0f9h,005h,0f4h,028h,0f9h,000h	; 624b  ..........(..

; ----------------------------------------------------------------------
; DATOS dibujos_banco1_resto: El remate del banco 1
;   0x6258..0x6267  (15 bytes)
DATA_dibujos_banco1_resto:
	defb 098h,04ah,004h,04fh,001h,041h,003h,044h,003h,04fh,001h,041h,004h,044h,000h	; 6258  .J.O.A.D.O.A.D.

; ======================================================================
; CODIGO 0x6267..0x629d  (54 bytes)
; ======================================================================


CARGA_BANCO_2:		; Descomprime los dibujos del banco 2
	ld hl,0629dh		;6267
	call DESCOMPRIME		;626a   ; Dos llamadas seguidas sin recargar HL: la segunda sigue el flujo donde acabo la primera, que cada bloque trae su destino
	call DESCOMPRIME		;626d
	ld hl,05c04h		;6270
	call DESCOMPRIME_SIGUE		;6273
	ld hl,0629fh		;6276
	ld de,072b0h		;6279   ; La entrada con espejo: el mismo dibujo con los bits del reves
	call DESCOMPRIME_ESPEJO		;627c
	ld hl,0662dh		;627f
	call DESCOMPRIME		;6282
	ld hl,06551h		;6285
	call DESCOMPRIME		;6288
	call DESCOMPRIME		;628b
	ld hl,06553h		;628e
	ld de,052b0h		;6291
	call DESCOMPRIME_DE		;6294
	ld hl,0668bh		;6297
	jp DESCOMPRIME		;629a

; ----------------------------------------------------------------------
; DATOS dibujos_banco2: Dibujos y colores del banco 2, comprimidos
;   0x629d..0x669a  (1021 bytes)
DATA_dibujos_banco2:
	defb 000h,072h,085h,07fh,01fh,00fh,003h,001h,003h,000h,005h,0ffh,085h,07fh,03fh,00fh	; 629d  .r............?.
	defb 007h,001h,006h,000h,003h,0ffh,08dh,03fh,01fh,007h,003h,000h,0ffh,07fh,01fh,00fh	; 62ad  .......?........
	defb 007h,001h,000h,000h,007h,0ffh,085h,07fh,01fh,00fh,007h,001h,004h,000h,005h,0ffh	; 62bd  ................
	defb 083h,07fh,01fh,00fh,003h,0ffh,085h,07fh,01fh,00fh,007h,001h,004h,0ffh,086h,01fh	; 62cd  ................
	defb 007h,003h,000h,0ffh,07fh,006h,000h,085h,0ffh,0ffh,00fh,003h,001h,003h,000h,004h	; 62dd  ................
	defb 0ffh,004h,000h,005h,0ffh,08dh,07fh,000h,000h,001h,003h,007h,00fh,00fh,01fh,000h	; 62ed  ................
	defb 000h,001h,003h,006h,000h,084h,007h,007h,00fh,01fh,005h,000h,087h,001h,003h,007h	; 62fd  ................
	defb 00fh,00fh,01fh,03fh,003h,0ffh,001h,07fh,00ah,03fh,092h,01fh,00fh,07fh,01fh,00fh	; 630d  ...?.....?......
	defb 003h,001h,000h,003h,007h,03fh,03fh,01fh,00fh,007h,001h,000h,000h,000h,060h,073h	; 631d  .....??.......`s
	defb 003h,000h,005h,0ffh,001h,000h,007h,0ffh,002h,000h,00dh,0ffh,004h,000h,085h,003h	; 632d  ................
	defb 000h,000h,00fh,07fh,003h,000h,086h,0f8h,000h,000h,0f0h,0ffh,001h,004h,000h,096h	; 633d  ................
	defb 001h,00fh,000h,0ffh,03fh,000h,000h,00fh,0ffh,0ffh,03fh,0ffh,0fch,0f8h,0c0h,000h	; 634d  ....?.....?.....
	defb 0f0h,0ffh,0ffh,0f0h,0c0h,080h,003h,000h,084h,0f8h,0ffh,01fh,003h,003h,000h,083h	; 635d  ................
	defb 01fh,0ffh,003h,003h,000h,085h,0e0h,000h,000h,0e0h,0feh,006h,000h,082h,080h,0f0h	; 636d  ................
	defb 003h,000h,001h,00fh,006h,000h,086h,007h,0ffh,0ffh,007h,000h,000h,003h,0ffh,087h	; 637d  ................
	defb 0fch,0f0h,0ffh,00fh,000h,0c0h,080h,003h,000h,083h,0c0h,0f0h,07fh,007h,000h,089h	; 638d  ................
	defb 0f0h,0fch,0f8h,0f0h,0c0h,000h,0fch,0ffh,007h,007h,000h,001h,0ffh,003h,000h,082h	; 639d  ................
	defb 0ffh,00fh,004h,000h,086h,00fh,07fh,0ffh,0ffh,07fh,00ch,004h,000h,002h,0ffh,003h	; 63ad  ................
	defb 03fh,003h,000h,002h,0ffh,003h,0f8h,002h,0ffh,00dh,00fh,001h,000h,003h,0ffh,001h	; 63bd  ?...............
	defb 0fch,00bh,0f0h,001h,0ffh,008h,007h,003h,000h,001h,00fh,004h,0ffh,001h,00fh,004h	; 63cd  ................
	defb 0f7h,084h,0f0h,0c0h,000h,000h,007h,01fh,007h,00fh,001h,000h,007h,0f0h,002h,000h	; 63dd  ................
	defb 007h,0f8h,002h,0f0h,006h,0f0h,082h,000h,0c0h,006h,00fh,082h,000h,003h,006h,0f0h	; 63ed  ................
	defb 082h,00fh,03fh,006h,00fh,001h,0ffh,004h,07fh,001h,00fh,005h,000h,085h,003h,003h	; 63fd  ..?.............
	defb 00fh,00fh,003h,00bh,000h,08eh,0c0h,0c0h,0f0h,0f0h,0c0h,000h,000h,001h,007h,007h	; 640d  ................
	defb 01fh,01fh,001h,0ffh,009h,000h,08ch,080h,0e0h,0e0h,0f8h,0f8h,080h,000h,000h,007h	; 641d  ................
	defb 01fh,0f0h,0e0h,004h,000h,084h,0e0h,0f8h,01fh,007h,006h,000h,004h,00fh,085h,000h	; 642d  ................
	defb 007h,03fh,0f8h,0c0h,004h,000h,084h,0e0h,0fch,01fh,003h,007h,000h,004h,0f0h,084h	; 643d  .?..............
	defb 0ffh,0ffh,03fh,001h,004h,000h,004h,0ffh,004h,000h,084h,0ffh,0ffh,0fch,080h,004h	; 644d  ..?.............
	defb 000h,083h,00fh,00fh,003h,005h,000h,003h,0ffh,001h,01fh,004h,000h,003h,0ffh,001h	; 645d  ................
	defb 0f8h,004h,000h,083h,0f0h,0f0h,0c0h,009h,000h,083h,00fh,07fh,0f8h,006h,0ffh,003h	; 646d  ................
	defb 000h,006h,0ffh,002h,000h,003h,0ffh,005h,000h,083h,0ffh,0ffh,03fh,005h,000h,083h	; 647d  ............?...
	defb 0ffh,0ffh,0fch,005h,000h,008h,0f0h,004h,000h,004h,0ffh,008h,00fh,006h,080h,082h	; 648d  ................
	defb 0c0h,0e0h,005h,080h,083h,0c0h,000h,000h,006h,008h,082h,00ch,00fh,005h,008h,001h	; 649d  ................
	defb 00fh,00fh,000h,09bh,00fh,000h,000h,007h,01fh,03fh,07ch,078h,0f2h,0f2h,0f0h,0e0h	; 64ad  .........?|x....
	defb 0f8h,0fch,03eh,01eh,04fh,04fh,00fh,000h,000h,001h,007h,00fh,01fh,03ch,030h,005h	; 64bd  ..>.OO.......<0.
	defb 0f8h,083h,0fch,0f0h,0c0h,005h,01fh,083h,03fh,00fh,003h,087h,000h,080h,0e0h,0f0h	; 64cd  ........?.......
	defb 0f8h,01ch,00ch,006h,080h,00ah,000h,007h,001h,002h,000h,005h,080h,083h,0c0h,0c0h	; 64dd  ................
	defb 0e0h,005h,001h,083h,003h,003h,007h,003h,080h,098h,0c0h,040h,060h,0a0h,0e0h,030h	; 64ed  ...........@`..0
	defb 03ch,01fh,00fh,007h,003h,001h,000h,000h,001h,001h,003h,007h,003h,000h,000h,070h	; 64fd  <..............p
	defb 0ffh,0e3h,003h,0ffh,085h,000h,000h,006h,0ffh,0e7h,003h,0ffh,003h,000h,088h,080h	; 650d  ................
	defb 080h,0c0h,0e0h,0c0h,000h,000h,001h,003h,000h,001h,001h,003h,000h,088h,0f0h,07fh	; 651d  ................
	defb 033h,07fh,0ffh,0ffh,000h,000h,098h,000h,07fh,060h,060h,07eh,060h,060h,060h,000h	; 652d  3........``~```.
	defb 063h,063h,06bh,06bh,07fh,077h,022h,000h,07fh,007h,00eh,01ch,038h,070h,07fh,006h	; 653d  cckk.w".....8p..
	defb 000h,002h,060h,000h,000h,052h,070h,04fh,020h,01fh,006h,04fh,008h,041h,008h,04fh	; 654d  ..`..RpO ..O.A.O
	defb 002h,01fh,002h,041h,006h,04fh,000h,060h,053h,026h,04fh,002h,01fh,006h,04fh,002h	; 655d  ...A.O.`S&O...O.
	defb 01fh,005h,04fh,003h,01fh,004h,04fh,004h,01fh,004h,04fh,004h,01fh,004h,04fh,004h	; 656d  ..O...O...O...O.
	defb 01fh,004h,04fh,004h,01fh,004h,04fh,054h,01fh,006h,04fh,002h,041h,006h,04fh,002h	; 657d  ..O...OT..O.A.O.
	defb 041h,003h,04fh,005h,041h,006h,041h,002h,04fh,005h,04fh,003h,041h,007h,041h,002h	; 658d  A.O.A.A.O.O.A.A.
	defb 0f4h,009h,054h,007h,01fh,004h,01dh,004h,01fh,00eh,045h,001h,04fh,007h,045h,002h	; 659d  ..T.......E.O.E.
	defb 04fh,007h,045h,002h,04fh,006h,045h,002h,05fh,006h,045h,002h,05fh,006h,045h,002h	; 65ad  O.E.O.E._.E._.E.
	defb 04fh,006h,045h,005h,01dh,003h,01fh,004h,0efh,006h,05fh,002h,0feh,004h,0f5h,004h	; 65bd  O.E......._.....
	defb 0efh,004h,05fh,004h,0efh,004h,05fh,003h,0feh,005h,0f5h,004h,0efh,004h,05fh,004h	; 65cd  .._..._......._.
	defb 0efh,002h,0e5h,002h,0f5h,004h,0efh,002h,0e5h,002h,0f5h,006h,0efh,002h,05fh,003h	; 65dd  .............._.
	defb 0efh,002h,0e5h,003h,0f5h,003h,0efh,002h,0e5h,003h,0f5h,006h,0efh,06ah,05fh,018h	; 65ed  .............j_.
	defb 03fh,017h,0efh,001h,0e1h,005h,0efh,001h,0e1h,012h,01fh,01ah,01fh,002h,016h,006h	; 65fd  ?...............
	defb 01fh,002h,016h,047h,01fh,005h,04fh,003h,01fh,005h,04fh,003h,01fh,005h,04fh,003h	; 660d  ...G..O...O...O.
	defb 01fh,005h,04fh,003h,01fh,005h,04fh,003h,01fh,005h,04fh,078h,04fh,078h,04fh,000h	; 661d  ..O...O...OxOxO.
	defb 090h,076h,082h,002h,005h,002h,000h,006h,007h,002h,001h,006h,002h,003h,001h,003h	; 662d  .v..............
	defb 000h,084h,027h,057h,007h,007h,006h,0ffh,082h,007h,001h,009h,000h,083h,080h,040h	; 663d  ..'W...........@
	defb 020h,004h,0ffh,002h,0feh,083h,0fch,0feh,0feh,004h,0ffh,08bh,07fh,03fh,01fh,01fh	; 664d   ............?..
	defb 00fh,007h,001h,000h,002h,004h,008h,003h,000h,003h,080h,002h,0c0h,084h,0e0h,0f0h	; 665d  ................
	defb 0f8h,0c0h,004h,000h,098h,000h,001h,001h,001h,000h,000h,000h,000h,0f8h,0f0h,0e0h	; 666d  ................
	defb 0ffh,000h,000h,000h,000h,000h,0f0h,0fch,0f8h,000h,000h,000h,000h,000h,090h,056h	; 667d  ...............V
	defb 058h,01fh,003h,0afh,001h,04fh,005h,0afh,002h,0a4h,00dh,04fh,000h	; 668d  X....O.....O.

; ======================================================================
; CODIGO 0x669a..0x66c7  (45 bytes)
; ======================================================================


MONTA_SPRITES_PARTIDA:		; Monta la tabla de atributos de sprite de la partida
	ld hl,066c7h		;669a
	jr MONTA_SPRITES		;669d
MONTA_SPRITES_BASE:		; La de la escena de la base
	ld hl,06704h		;669f
MONTA_SPRITES:		; Compone en 0xE050 los 128 bytes de atributos a partir de una lista (cuantos, y los cuatro bytes) y los vuelca a la VRAM
	push hl			;66a2
	ld hl,0e050h		;66a3
	push hl			;66a6
	ld b,080h		;66a7
SPRITES_BORRA:
	ld (hl),000h		;66a9
	inc hl			;66ab
	djnz SPRITES_BORRA		;66ac
	pop de			;66ae
	pop hl			;66af
SPRITES_BUCLE:
	ld a,(hl)			;66b0
	inc hl			;66b1
	or a			;66b2
	jr z,VUELCA_ATRIBUTOS		;66b3
	ld c,a			;66b5   ; Un byte de cuantos y los cuatro del atributo; el cero cierra y se vuelca todo de una vez
	call REPITE_4_BYTES		;66b6
	jr SPRITES_BUCLE		;66b9
VUELCA_ATRIBUTOS:		; Copia los 128 bytes de 0xE050 a la tabla de atributos de sprite
	ld hl,0e050h		;66bb
	ld de,03b00h		;66be
	ld bc,00080h		;66c1
	jp COPIA_A_VRAM		;66c4

; ----------------------------------------------------------------------
; DATOS atributos_de_partida: La lista con la que se monta la tabla de
;   atributos durante la partida: pares (cuantos, cuatro bytes) y un cero al
;   final. De aqui sale el color de cada sprite, que NO va en su dibujo: el
;   pinguino negro, la foca negra y roja, el pez rojo, la sombra azul. Y AQUI
;   ESTA EL ATRIBUTO 14, con patron 0xD4 -que dibujado es un SOL de puntas- y
;   color amarillo, que no se ve nunca. COMPROBADO QUE ES UN SOL Y QUE SE
;   VERIA: parcheando en una COPIA del cartucho los dos bytes de su posicion
;   (0x66E1 y 0x66E2, la Y y la X) para sacarlo al cielo, aparece un sol
;   amarillo de puntas sobre el azul, sin tocarle ni el dibujo ni el color. La
;   captura y el cartucho parcheado estan fuera del repositorio, en work/,
;   porque esto NO es una modificacion del juego sino la forma de ver lo que
;   el juego tiene y no ensena: se monta con Y=0xE0 -fuera de la pantalla- y
;   nadie se la cambia. MEDIDO sobre los diez minutos de partida grabada con
;   un punto de observacion de escritura en 0xE088-0xE08B
;   (tools/omsx_atributo14.tcl): las UNICAS cuatro cosas que lo tocan son
;   barridos de la tabla entera -el ldir de 0x4454, el copiador de cuatro
;   bytes de 0x45A4, BORRA_SPRITES en 0x45EC y el borrado previo de 0x66A9-, y
;   ninguna va a por el. Al acabar la partida su entrada en la VRAM sigue
;   siendo Y=0xE0, patron 0xD4, color 0x0A: cargado, coloreado y aparcado
;   fuera del encuadre. El control -los mismos puntos en el atributo 13-
;   recibe ademas 4426 y 41740 escrituras de las rutinas del pinguino, asi que
;   los ceros del 14 son datos y no instrumentacion rota. Y de propina el
;   control mide una cosa que estaba deducida: el 13 recibe 12 escrituras MAS
;   que el 14 desde 0x45A4, que son las tres salidas del agua por cuatro
;   bytes, o sea la cadena que rehace los sprites parandose justo antes del 14
;   0x66c7..0x6704  (61 bytes)
DATA_atributos_de_partida:
	defb 00ah,0e0h,000h,07ch,000h	; 66c7
	defb 001h,090h,070h,000h,001h	; 66cc
	defb 001h,090h,080h,004h,001h	; 66d1
	defb 001h,0a0h,070h,008h,001h	; 66d6
	defb 001h,0a0h,080h,00ch,001h	; 66db
	defb 001h,0e0h,000h,0d4h,00ah	; 66e0
	defb 001h,0e0h,000h,000h,008h	; 66e5
	defb 001h,0e0h,000h,07ch,001h	; 66ea
	defb 003h,0e0h,000h,07ch,006h	; 66ef
	defb 001h,0aeh,070h,0a0h,004h	; 66f4
	defb 001h,0aeh,080h,0a4h,004h	; 66f9
	defb 008h,008h,000h,070h,000h	; 66fe
	defb 000h	; 6703

; ----------------------------------------------------------------------
; DATOS atributos_de_base: La misma lista para la escena de la base, pero de
;   OCHO entradas en vez de treinta: 0x66A3 pone los 128 bytes a cero antes de
;   aplicarla, asi que del atributo 8 en adelante no queda nada. Cierra
;   clavada en 0x672E, donde vuelve a haber codigo. Sus bytes de 0x671E los
;   copia ademas 0x5501. Y AQUI ESTA EL UNICO SPRITE DEL PINGUINO QUE SE GIRA
;   Y SONRIE: el atributo 7, con el patron 0xD0 en amarillo, que es el PICO.
;   Todo lo demas de ese pinguino -la cara, los ojos, la boca roja y hasta la
;   sombra azul de debajo- son CASILLAS, no sprites. Comprobado a t=126,6 de
;   la partida grabada de dos maneras: la tabla de atributos solo tiene ocho
;   entradas puestas, y comparando el fotograma real con la pantalla pintada
;   SOLO con casillas quedan 224 pixeles sin explicar, que son 96+72+24 de la
;   bandera y 32 del pico. Y 32 son exactamente los bits encendidos del patron
;   0xD0
;   0x6704..0x672e  (42 bytes)
DATA_atributos_de_base:
	defb 004h,04fh,080h,07ch,000h	; 6704
	defb 001h,052h,080h,0e8h,000h	; 6709
	defb 001h,052h,080h,0ech,000h	; 670e
	defb 001h,052h,080h,0e4h,00fh	; 6713
	defb 001h,07fh,078h,0d0h,00ah	; 6718
	defb 000h,07fh,070h,0f0h,00ah	; 671d
	defb 087h,078h,0f4h,00ah,077h	; 6722
	defb 070h,0f8h,001h,077h,080h	; 6727
	defb 0fch,001h	; 672c

; ======================================================================
; CODIGO 0x672e..0x6734  (6 bytes)
; ======================================================================


CARGA_SPRITES:		; Descomprime los patrones de sprite
	ld hl,06734h		;672e
	jp DESCOMPRIME		;6731

; ----------------------------------------------------------------------
; DATOS sprites_comprimidos: Los patrones de sprite: los pinguinos, los peces
;   y las focas
;   0x6734..0x6bc1  (1165 bytes)
DATA_sprites_comprimidos:
	defb 000h,058h,00dh,000h,083h,003h,00fh,01fh,003h,000h,08ah,003h,00fh,01bh,037h,06fh	; 6734  .X............7o
	defb 05fh,0ffh,0ffh,0bfh,0bfh,003h,0ffh,003h,000h,086h,0c0h,0f0h,0f8h,0fch,0feh,0feh	; 6744  _...............
	defb 007h,0ffh,00dh,000h,086h,0c0h,0e0h,0f0h,03fh,070h,060h,007h,001h,003h,000h,083h	; 6754  ........?p`.....
	defb 003h,003h,000h,00ch,0ffh,084h,07fh,0ffh,0e3h,001h,00ch,0ffh,087h,0feh,0ffh,0c7h	; 6764  ................
	defb 080h,0f8h,018h,008h,006h,080h,004h,000h,082h,0c0h,0c0h,00bh,000h,005h,001h,001h	; 6774  ................
	defb 003h,003h,000h,08ah,007h,01fh,037h,06fh,0dfh,0bfh,0ffh,0ffh,0bfh,0bfh,003h,0ffh	; 6784  ......7o........
	defb 003h,000h,085h,0c0h,0f0h,0f8h,0fch,0fch,003h,0feh,005h,0ffh,00ch,000h,08bh,0e0h	; 6794  ................
	defb 0f0h,0f8h,0f8h,007h,00fh,01fh,03eh,038h,030h,020h,009h,000h,008h,0ffh,088h,07fh	; 67a4  ......>80 ......
	defb 07fh,03fh,01fh,07fh,077h,000h,000h,00dh,0ffh,086h,0fdh,039h,008h,00ch,000h,000h	; 67b4  .?..w......9....
	defb 007h,080h,086h,000h,0c0h,0e0h,0a0h,0e0h,0e0h,00ch,000h,084h,007h,01fh,03fh,07fh	; 67c4  ..............?.
	defb 003h,000h,08ah,003h,00fh,01bh,037h,02fh,06fh,07fh,07fh,0dfh,0bfh,003h,0ffh,003h	; 67d4  ......7/o.......
	defb 000h,084h,0e0h,0f8h,0fch,0feh,009h,0ffh,00ah,000h,006h,080h,083h,060h,000h,000h	; 67e4  .............`..
	defb 007h,001h,086h,000h,003h,007h,005h,007h,007h,00dh,0ffh,083h,0bfh,09ch,010h,008h	; 67f4  ................
	defb 0ffh,08fh,0feh,0feh,0fch,0f8h,0feh,0eeh,000h,000h,0e0h,0f0h,0f8h,038h,01ch,00ch	; 6804  .............8..
	defb 004h,009h,000h,083h,03fh,070h,060h,005h,001h,085h,002h,006h,007h,007h,003h,003h	; 6814  ....?p`.........
	defb 000h,00ch,0ffh,084h,03fh,00fh,001h,000h,00ch,0ffh,087h,0feh,0f8h,0e0h,080h,0f8h	; 6824  ....?...........
	defb 018h,008h,005h,080h,085h,040h,060h,0e0h,0e0h,0c0h,00dh,000h,086h,020h,030h,018h	; 6834  .....@`...... 0.
	defb 01fh,00fh,007h,003h,000h,08ah,003h,00fh,01bh,037h,06fh,05fh,0ffh,0ffh,0bfh,0bfh	; 6844  .........7o_....
	defb 003h,0ffh,003h,000h,086h,0c0h,0f0h,0f8h,0fch,0feh,0feh,007h,0ffh,00ah,000h,089h	; 6854  ................
	defb 004h,00ch,01ch,0f8h,0f0h,0e0h,003h,000h,000h,005h,001h,085h,002h,006h,007h,007h	; 6864  ................
	defb 003h,003h,000h,00ch,0ffh,084h,07fh,01fh,007h,001h,00ch,0ffh,087h,0fch,0f0h,080h	; 6874  ................
	defb 000h,0c0h,000h,000h,005h,080h,085h,040h,060h,0e0h,0e0h,0c0h,006h,000h,084h,0e0h	; 6884  .......@`.......
	defb 0f8h,0fch,0feh,009h,0ffh,009h,000h,005h,080h,083h,0e0h,0f0h,060h,003h,001h,00ch	; 6894  ............`...
	defb 000h,006h,0ffh,08ah,07fh,07fh,03fh,03fh,01fh,01fh,00eh,00ch,008h,000h,007h,0ffh	; 68a4  ......??........
	defb 084h,0feh,0feh,0fch,0b8h,005h,000h,083h,0f8h,0fch,00ch,016h,000h,005h,001h,082h	; 68b4  ................
	defb 007h,00fh,003h,000h,08ah,007h,01fh,037h,06fh,0dfh,0bfh,0ffh,0ffh,0bfh,0bfh,003h	; 68c4  .......7o.......
	defb 0ffh,083h,01fh,03fh,030h,00dh,000h,007h,0ffh,085h,07fh,07fh,03fh,01bh,001h,004h	; 68d4  ...?0.......?...
	defb 000h,006h,0ffh,08bh,0feh,0feh,0fch,0fch,0f8h,0f8h,0f0h,030h,010h,000h,00ch,003h	; 68e4  ...........0....
	defb 080h,018h,000h,084h,01eh,03fh,03fh,003h,003h,000h,089h,003h,00fh,01bh,037h,06fh	; 68f4  .....??.......7o
	defb 05fh,0ffh,0dfh,0dfh,004h,0ffh,003h,000h,086h,0c0h,0f0h,0f8h,0fch,0feh,0feh,007h	; 6904  _...............
	defb 0ffh,00ch,000h,085h,078h,0fch,0fch,0c0h,001h,00fh,000h,008h,0ffh,082h,05fh,00fh	; 6914  ....x........._.
	defb 003h,007h,083h,003h,001h,001h,008h,0ffh,082h,0fah,0f0h,003h,0e0h,084h,080h,000h	; 6924  ................
	defb 000h,080h,017h,000h,086h,020h,070h,0d8h,0f8h,0f8h,070h,00ah,000h,086h,004h,00eh	; 6934  ..... p...p.....
	defb 01bh,01fh,01fh,00eh,005h,000h,004h,078h,001h,038h,012h,000h,086h,004h,00eh,01bh	; 6944  .......x.8......
	defb 01fh,01fh,00eh,00ah,000h,086h,020h,070h,0d8h,0f8h,0f8h,070h,003h,000h,004h,00fh	; 6954  ...... p...p....
	defb 001h,00eh,02dh,000h,083h,003h,001h,001h,00eh,000h,085h,080h,080h,0a0h,0c0h,020h	; 6964  ..-............ 
	defb 009h,000h,088h,003h,007h,001h,000h,000h,001h,000h,001h,008h,000h,087h,080h,0c0h	; 6974  ................
	defb 0e0h,0e0h,060h,060h,0c0h,008h,000h,086h,007h,01fh,037h,07fh,03fh,00ch,00ah,000h	; 6984  ..``......7.?...
	defb 001h,080h,003h,0e0h,087h,0f0h,070h,030h,018h,01ch,010h,010h,004h,000h,089h,030h	; 6994  ......p0.......0
	defb 038h,03ch,03fh,01fh,03fh,02fh,027h,003h,00ah,000h,086h,080h,008h,088h,0feh,0f0h	; 69a4  8<?.?/'.........
	defb 080h,00bh,000h,085h,001h,001h,005h,003h,004h,00ah,000h,083h,0c0h,080h,080h,00ch	; 69b4  ................
	defb 000h,087h,001h,003h,007h,007h,006h,006h,003h,009h,000h,088h,0c0h,0e0h,080h,000h	; 69c4  ................
	defb 000h,080h,000h,080h,007h,000h,001h,001h,003h,007h,087h,00fh,00eh,00ch,018h,038h	; 69d4  ...............8
	defb 008h,008h,005h,000h,086h,0e0h,0f8h,0ech,0feh,0fch,030h,00ch,000h,086h,001h,080h	; 69e4  ..........0.....
	defb 081h,07fh,00fh,001h,007h,000h,089h,00ch,01ch,03ch,0fch,0f8h,0fch,0f4h,0e4h,0c0h	; 69f4  .........<......
	defb 006h,000h,082h,007h,007h,00dh,000h,001h,07fh,003h,0ffh,00ch,000h,001h,0feh,003h	; 6a04  ................
	defb 0ffh,00dh,000h,082h,0e0h,0e0h,010h,000h,087h,0c0h,0f0h,0f8h,0fch,0fch,0feh,0feh	; 6a14  ................
	defb 006h,0ffh,007h,000h,089h,00ch,01ch,03ch,0f8h,0f8h,0f0h,0c0h,000h,080h,00bh,0ffh	; 6a24  .......<........
	defb 085h,0feh,0fch,0fch,038h,008h,006h,080h,084h,0b8h,0f8h,0f0h,0e0h,00dh,000h,089h	; 6a34  ....8...........
	defb 030h,038h,03ch,01fh,01fh,00fh,003h,000h,001h,003h,000h,088h,003h,00fh,01bh,037h	; 6a44  08<............7
	defb 02fh,07fh,05fh,0dfh,005h,0ffh,006h,001h,084h,01dh,01fh,00fh,007h,006h,000h,00bh	; 6a54  /._.............
	defb 0ffh,085h,07fh,03fh,03fh,01ch,010h,006h,000h,088h,006h,000h,020h,013h,029h,001h	; 6a64  ...??....... .).
	defb 009h,006h,008h,000h,088h,060h,000h,004h,0c8h,094h,080h,090h,060h,004h,000h,085h	; 6a74  .....`......`...
	defb 003h,00fh,01fh,03fh,03fh,009h,07fh,087h,000h,000h,0c0h,0f0h,0f8h,0fch,0fch,009h	; 6a84  ...??...........
	defb 0feh,008h,000h,088h,006h,00ch,020h,013h,029h,011h,029h,006h,008h,000h,08fh,060h	; 6a94  ...... .).)....`
	defb 030h,004h,0c8h,094h,088h,094h,060h,001h,001h,003h,00dh,01eh,03fh,03fh,003h,07fh	; 6aa4  0.....`.....??..
	defb 003h,0feh,084h,0fch,0f0h,060h,07fh,00bh,0ffh,081h,03fh,006h,000h,085h,003h,00fh	; 6ab4  .....`....?.....
	defb 03fh,07fh,07fh,008h,0ffh,003h,000h,085h,0c0h,0f0h,0fch,0feh,0feh,008h,0ffh,081h	; 6ac4  ?...............
	defb 0feh,00bh,0ffh,081h,0fch,003h,000h,087h,080h,080h,0c0h,0b0h,078h,0fch,0fch,003h	; 6ad4  ............x...
	defb 0feh,003h,07fh,083h,03fh,00fh,006h,008h,000h,086h,003h,00fh,038h,00ch,007h,003h	; 6ae4  ....?.......8...
	defb 00ah,000h,086h,0c0h,0f0h,01ch,030h,0e0h,0c0h,007h,000h,08bh,004h,004h,0cch,0dfh	; 6af4  ......0.........
	defb 07fh,03fh,07fh,0ffh,03fh,00dh,010h,007h,000h,089h,040h,0c0h,080h,080h,0c0h,0e0h	; 6b04  .?..?.....@.....
	defb 0f0h,080h,080h,00bh,000h,085h,01fh,0ffh,07fh,03fh,003h,00bh,000h,085h,0c0h,0f0h	; 6b14  .........?......
	defb 0ffh,0feh,0f0h,00ch,000h,084h,00fh,03fh,01fh,007h,00dh,000h,083h,0f0h,0fch,0c0h	; 6b24  .......?........
	defb 00dh,000h,083h,007h,00fh,007h,00dh,000h,083h,080h,0f0h,000h,00ch,0ffh,004h,000h	; 6b34  ................
	defb 00ch,0ffh,004h,000h,006h,000h,084h,003h,00fh,01fh,01fh,00ch,000h,084h,0c0h,0f0h	; 6b44  ................
	defb 0f8h,0f8h,006h,000h,000h,080h,05fh,004h,000h,086h,00fh,01fh,01bh,01dh,01ch,00fh	; 6b54  ......_.........
	defb 00ah,000h,086h,0f0h,0f8h,0dch,0beh,07ch,0f0h,006h,000h,00bh,000h,084h,003h,007h	; 6b64  .......|........
	defb 007h,003h,00ch,000h,085h,0c0h,0c0h,0c0h,080h,000h,0a0h,000h,038h,03ch,00fh,00fh	; 6b74  ............8<..
	defb 006h,004h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0feh,0ffh,0ffh	; 6b84  ................
	defb 01fh,00fh,007h,000h,000h,000h,000h,000h,000h,000h,000h,0a0h,000h,000h,000h,080h	; 6b94  ................
	defb 0c1h,0c3h,0e7h,0efh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,080h	; 6ba4  ................
	defb 080h,080h,080h,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 6bb4  .............

; ----------------------------------------------------------------------
; DATOS trozos_de_pista: Los 92 trozos incrementales de la pista, en el mismo
;   formato que los decorados: cada uno pone entre una y seis casillas, o sea
;   que son INCREMENTOS y no pantallas enteras. Se consumen en cadena, uno por
;   paso, y asi va creciendo lo que se acerca. Los siete obstaculos de 0x5295
;   empiezan cada uno en uno de estos trozos
;   0x6bc1..0x7219  (1624 bytes)
DATA_trozos_de_pista:
	defb 000h,041h,0efh,093h,000h,041h,0eeh,0a1h,095h,0a2h,000h,041h,0eeh,00fh,00fh,00fh	; 6bc1  .A...A.....A....
	defb 0eeh,098h,098h,0a3h,000h,061h,0eeh,00fh,00fh,00fh,0edh,099h,09ah,09ah,09bh,000h	; 6bd1  .....a..........
	defb 081h,0edh,00fh,00fh,00fh,00fh,0ech,0a4h,09dh,09dh,09dh,09dh,0a5h,000h,0a1h,0ech	; 6be1  ................
	defb 00fh,00fh,00fh,00fh,00fh,00fh,0eah,0a8h,0aah,09fh,09fh,09fh,09fh,09fh,0abh,0a7h	; 6bf1  ................
	defb 000h,0c1h,0eah,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e9h,070h,082h,06ch	; 6c01  .............p.l
	defb 06ch,06ch,06ch,06ch,06ch,083h,071h,000h,0e1h,0e9h,00fh,00fh,00fh,00fh,00fh,00fh	; 6c11  lllll.q.........
	defb 00fh,00fh,00fh,00fh,0e8h,0e7h,072h,073h,084h,08bh,06dh,06dh,06dh,06dh,06dh,06dh	; 6c21  ......rs..mmmmmm
	defb 08eh,086h,075h,000h,022h,0e7h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6c31  ..u."...........
	defb 00fh,00fh,00fh,0e6h,072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h	; 6c41  ....rs..nnnnnnn.
	defb 004h,074h,078h,0e5h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh	; 6c51  .tx.yz...ooooooo
	defb 08dh,06fh,07bh,07ch,07dh,000h,042h,0e6h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6c61  .o{|}.B.........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e5h,072h,073h,084h,090h,06eh,06eh,06eh,06eh	; 6c71  ........rs..nnnn
	defb 06eh,06eh,06eh,06eh,06eh,092h,086h,075h,00fh,0e4h,079h,07ah,08ah,085h,08ch,06fh	; 6c81  nnnnn..u..yz...o
	defb 06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08ch,087h,07eh,07fh,000h,062h,0e5h,00fh	; 6c91  oooooooo..~..b..
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e4h	; 6ca1  ................
	defb 072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h	; 6cb1  rs..nnnnnnnnnn..
	defb 074h,078h,0e3h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh	; 6cc1  tx.yz...oooooooo
	defb 06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,082h,0e4h,00fh,00fh,00fh,00fh,00fh,00fh	; 6cd1  oo.o{|}.........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e3h,072h,073h,084h	; 6ce1  .............rs.
	defb 090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,092h,086h,075h	; 6cf1  .nnnnnnnnnnnn..u
	defb 00fh,0e2h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh	; 6d01  ..yz...ooooooooo
	defb 06fh,06fh,06fh,08ch,087h,07eh,07fh,000h,0a2h,0e3h,00fh,00fh,00fh,00fh,00fh,00fh	; 6d11  ooo..~..........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e2h,072h,073h	; 6d21  ..............rs
	defb 084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h	; 6d31  ..nnnnnnnnnnnnn.
	defb 004h,074h,078h,000h,0c2h,0e2h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6d41  .tx.............
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0f0h,093h	; 6d51  .............A..
	defb 000h,041h,0efh,094h,095h,096h,000h,041h,0efh,00fh,00fh,00fh,0efh,097h,098h,098h	; 6d61  .A.....A........
	defb 000h,061h,0efh,00fh,00fh,00fh,0efh,099h,09ah,09ah,09bh,000h,081h,0efh,00fh,00fh	; 6d71  .a..............
	defb 00fh,00fh,0eeh,09ch,09dh,09dh,09dh,09dh,09eh,000h,0a1h,0eeh,00fh,00fh,00fh,00fh	; 6d81  ................
	defb 00fh,00fh,0edh,0a6h,0aah,09fh,09fh,09fh,09fh,09fh,0abh,0a7h,000h,0c1h,0edh,00fh	; 6d91  ................
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0edh,070h,082h,06ch,06ch,06ch,06ch,06ch	; 6da1  .........p.lllll
	defb 06ch,083h,077h,000h,0e1h,0edh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6db1  l.w.............
	defb 0edh,0ech,076h,089h,088h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,08eh,086h,075h,000h	; 6dc1  ..v..mmmmmmm..u.
	defb 022h,0ech,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0ech	; 6dd1  "...............
	defb 076h,089h,08fh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h,0ebh,080h	; 6de1  v..nnnnnnn..tx..
	defb 081h,093h,085h,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h	; 6df1  ...ooooooo.o{|}.
	defb 042h,0ech,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6e01  B...............
	defb 0ebh,072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h	; 6e11  .rs..nnnnnnnn..t
	defb 078h,0eah,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh	; 6e21  x.yz...oooooooo.
	defb 06fh,07bh,07ch,07dh,000h,062h,0ebh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6e31  o{|}.b..........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,0eah,00fh,076h,089h,08fh,06eh,06eh,06eh,06eh	; 6e41  .........v..nnnn
	defb 06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h,0eah,080h,081h,093h,08dh,06fh	; 6e51  nnnnnn..tx.....o
	defb 06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,082h	; 6e61  ooooooooo.o{|}..
	defb 0ebh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6e71  ................
	defb 00fh,00fh,0eah,072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh	; 6e81  ...rs..nnnnnnnnn
	defb 06eh,06eh,091h,004h,074h,078h,0e9h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh	; 6e91  nn..tx.yz...oooo
	defb 06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,0a2h,0eah,00fh	; 6ea1  ooooooo.o{|}....
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6eb1  ................
	defb 00fh,00fh,0e9h,00fh,076h,089h,08fh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh	; 6ec1  ....v..nnnnnnnnn
	defb 06eh,06eh,06eh,06eh,091h,004h,077h,078h,000h,0c2h,0eah,00fh,00fh,00fh,00fh,00fh	; 6ed1  nnnn..wx........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,000h	; 6ee1  ................
	defb 000h,041h,0efh,0afh,0b0h,000h,041h,0efh,094h,0a2h,000h,041h,0efh,00fh,00fh,0efh	; 6ef1  .A....A....A....
	defb 0bfh,0c0h,000h,061h,0efh,00fh,00fh,0efh,0b7h,0b8h,000h,081h,0efh,00fh,00fh,0efh	; 6f01  ...a............
	defb 0bch,0bdh,000h,0a1h,0efh,00fh,00fh,0efh,0c1h,0c2h,000h,0c1h,0efh,00fh,00fh,0eeh	; 6f11  ................
	defb 094h,095h,095h,096h,000h,0e1h,0eeh,00fh,00fh,00fh,00fh,0ffh,0eeh,097h,098h,098h	; 6f21  ................
	defb 099h,000h,022h,0eeh,00fh,00fh,00fh,00fh,0eeh,09ah,098h,098h,09bh,0eeh,0abh,0aah	; 6f31  ..".............
	defb 0aah,0ach,000h,042h,0eeh,00fh,00fh,00fh,00fh,0edh,09ch,09dh,098h,098h,09eh,09fh	; 6f41  ...B............
	defb 0edh,0a3h,0a4h,0a1h,0a1h,0a5h,0a6h,000h,062h,0edh,00fh,00fh,00fh,00fh,00fh,00fh	; 6f51  ........b.......
	defb 0edh,09ah,098h,098h,098h,098h,09bh,0edh,0abh,0a1h,0a8h,0a8h,0a1h,0ach,000h,082h	; 6f61  ................
	defb 0edh,00fh,00fh,00fh,00fh,00fh,00fh,0ech,09ch,09dh,098h,098h,098h,098h,09eh,09fh	; 6f71  ................
	defb 0ech,0a3h,0a4h,0a8h,0a9h,0a9h,0a9h,0a5h,0a6h,000h,0a2h,0ech,00fh,00fh,00fh,00fh	; 6f81  ................
	defb 00fh,00fh,00fh,00fh,0ech,09ah,098h,098h,098h,098h,098h,098h,09bh,000h,0c2h,0ech	; 6f91  ................
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0efh,0b2h,000h,041h,0eeh	; 6fa1  ..........A...A.
	defb 0b4h,00fh,000h,041h,0eeh,00fh,0edh,0bfh,0b6h,000h,061h,0edh,00fh,00fh,0edh,0bah	; 6fb1  ...A......a.....
	defb 0bbh,000h,081h,0edh,00fh,00fh,0ech,0beh,0beh,000h,0a1h,0ech,00fh,00fh,0ebh,0c1h	; 6fc1  ................
	defb 0c3h,0c2h,000h,0c1h,0ebh,00fh,00fh,00fh,0e9h,094h,095h,095h,095h,096h,000h,0e1h	; 6fd1  ................
	defb 0e9h,00fh,00fh,00fh,00fh,00fh,0ffh,0e8h,097h,098h,098h,098h,099h,000h,022h,0e8h	; 6fe1  ..............".
	defb 00fh,00fh,00fh,00fh,00fh,0e7h,09ah,098h,098h,098h,09bh,0e7h,0abh,0aah,0aah,0aah	; 6ff1  ................
	defb 0ach,000h,042h,0e7h,00fh,00fh,00fh,00fh,00fh,0e6h,09ah,098h,098h,098h,09eh,09fh	; 7001  ..B.............
	defb 0e6h,0a0h,0a1h,0a1h,0a1h,0a5h,0a6h,000h,062h,0e6h,00fh,00fh,00fh,00fh,00fh,00fh	; 7011  ........b.......
	defb 0e5h,09ah,098h,098h,098h,098h,09bh,00fh,0e5h,0a0h,0a1h,0a8h,0a8h,0a1h,0a2h,000h	; 7021  ................
	defb 082h,0e5h,00fh,00fh,00fh,00fh,00fh,00fh,0e4h,09ah,098h,098h,098h,098h,09eh,09fh	; 7031  ................
	defb 0e4h,0a0h,0a1h,0a8h,0a8h,0a1h,0a2h,0a6h,000h,0a2h,0e4h,00fh,00fh,00fh,00fh,00fh	; 7041  ................
	defb 00fh,00fh,0e3h,09ah,098h,098h,098h,098h,098h,098h,09bh,00fh,000h,0c2h,0e3h,00fh	; 7051  ................
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0f0h,0b1h,000h,041h,0f0h,00fh	; 7061  .........A...A..
	defb 0b3h,000h,041h,0f1h,00fh,0f1h,0b5h,0c0h,000h,061h,0f1h,00fh,00fh,0f1h,0b9h,0bah	; 7071  ..A......a......
	defb 000h,081h,0f1h,00fh,00fh,0f2h,0beh,0beh,000h,0a1h,0f2h,00fh,00fh,0f2h,0c1h,0c3h	; 7081  ................
	defb 0c2h,000h,0c1h,0f2h,00fh,00fh,00fh,0f2h,094h,095h,095h,095h,096h,000h,0e1h,0f2h	; 7091  ................
	defb 00fh,00fh,00fh,00fh,00fh,0ffh,0f3h,097h,098h,098h,098h,099h,000h,022h,0f3h,00fh	; 70a1  ............."..
	defb 00fh,00fh,00fh,00fh,0f4h,09ah,098h,098h,098h,09bh,0f4h,0abh,0aah,0aah,0aah,0ach	; 70b1  ................
	defb 000h,042h,0f4h,00fh,00fh,00fh,00fh,00fh,0f4h,09ch,09dh,098h,098h,098h,09eh,0f4h	; 70c1  .B..............
	defb 0a3h,0a4h,0a1h,0a1h,0a1h,0a2h,000h,062h,0f4h,00fh,00fh,00fh,00fh,00fh,00fh,0f4h	; 70d1  .......b........
	defb 00fh,09ah,098h,098h,098h,098h,09bh,0f5h,0a0h,0a1h,0a8h,0a8h,0a1h,0a2h,000h,082h	; 70e1  ................
	defb 0f5h,00fh,00fh,00fh,00fh,00fh,00fh,0f5h,09ch,09dh,098h,098h,098h,098h,09eh,0f5h	; 70f1  ................
	defb 0a3h,0a4h,0a8h,0a9h,0a8h,0a1h,0a2h,000h,0a2h,0f5h,00fh,00fh,00fh,00fh,00fh,00fh	; 7101  ................
	defb 00fh,0f5h,00fh,09ah,098h,098h,098h,098h,098h,098h,09bh,000h,0c2h,0f6h,00fh,00fh	; 7111  ................
	defb 00fh,00fh,00fh,00fh,00fh,00fh,000h,000h,000h,041h,0efh,0c6h,000h,041h,0efh,0c7h	; 7121  .........A...A..
	defb 000h,041h,0efh,00fh,0efh,0c9h,000h,061h,0efh,00fh,0eeh,0ceh,000h,081h,0edh,0c8h	; 7131  .A.....a........
	defb 0cah,0edh,0cfh,0cbh,000h,081h,0edh,00fh,00fh,0edh,0cch,00fh,0ech,0a1h,0cdh,000h	; 7141  ................
	defb 0a1h,0edh,00fh,0ech,00fh,00fh,0ech,003h,0adh,0ebh,0b5h,0b1h,000h,0e1h,0ech,00fh	; 7151  ................
	defb 00fh,0ebh,0aeh,0aeh,0ebh,003h,003h,0eah,07fh,0b0h,000h,000h,002h,0ebh,00fh,00fh	; 7161  ................
	defb 0ebh,00fh,00fh,0e9h,0afh,003h,003h,0e9h,0afh,003h,003h,0e8h,07fh,0b2h,000h,000h	; 7171  ................
	defb 042h,0e9h,00fh,00fh,00fh,0e9h,00fh,00fh,00fh,0e8h,00fh,00fh,0e5h,003h,003h,003h	; 7181  B...............
	defb 0e5h,003h,003h,003h,000h,0a2h,0e5h,00fh,00fh,00fh,0e5h,00fh,00fh,00fh,000h,000h	; 7191  ................
	defb 000h,041h,0f0h,0c6h,000h,041h,0f0h,0c8h,000h,041h,0f0h,00fh,0f1h,0c9h,000h,061h	; 71a1  .A...A...A.....a
	defb 0f1h,00fh,0f1h,0ceh,000h,081h,0f1h,0c8h,0cah,0f1h,0cfh,0cbh,000h,081h,0f1h,00fh	; 71b1  ................
	defb 00fh,0f1h,00fh,0cch,0f1h,0a1h,0cdh,000h,0a1h,0f2h,00fh,0f1h,00fh,00fh,0f2h,0afh	; 71c1  ................
	defb 003h,0f2h,0b2h,000h,0e1h,0f2h,00fh,00fh,0f2h,00fh,0aeh,0aeh,0f3h,003h,003h,0f2h	; 71d1  ................
	defb 07fh,0b0h,000h,000h,002h,0f3h,00fh,00fh,0f3h,00fh,00fh,0f2h,00fh,0afh,003h,003h	; 71e1  ................
	defb 0f3h,0afh,003h,003h,0f2h,07fh,0b2h,000h,000h,042h,0f3h,00fh,00fh,00fh,0f3h,00fh	; 71f1  .........B......
	defb 00fh,00fh,0f2h,00fh,00fh,0f8h,003h,003h,003h,0f8h,003h,003h,003h,000h,0a2h,0f8h	; 7201  ................
	defb 00fh,00fh,00fh,0f8h,00fh,00fh,00fh,000h	; 7211  ........

; ----------------------------------------------------------------------
; DATOS arbol_de_decorados: Cuatro punteros en 0x7219 llevan a cuatro grupos,
;   cada uno con otros cuatro, y los dieciseis bloques de abajo embaldosan
;   0x7305-0x74F0 sin dejar hueco. Pasados por el interprete de 0x4523 dibujan
;   los bordes de la pista
;   0x7219..0x74f1  (728 bytes)
DATA_arbol_de_decorados:
	defw 07221h,0725eh,0729bh,072d0h	; 7219
	defw 07305h,0732dh,07345h,07366h	; 7221
	defw 00f0fh,00e51h,00d72h,00b93h	; 7229
	defw 00ab5h,009d6h,008f7h,00618h	; 7231
	defw 0053ah,0035bh,0027dh,0019eh	; 7239
	defb 0bfh,000h,051h,039h,00fh,010h,011h,012h,013h,014h,015h,0ffh,060h,000h,000h,000h	; 7241  ..Q9........`...
	defb 0f3h,0f4h,0f3h,0f7h,0f5h,0f6h,0f4h,0f3h,0f7h,0f5h,0f6h,000h,000h,07eh,073h,0a6h	; 7251  .............~s.
	defb 073h,0beh,073h,0dfh,073h,00fh,00fh,040h,00eh,060h,00dh,080h,00bh,0a0h,00ah,0c0h	; 7261  s.s.s..@.`......
	defb 009h,0e0h,008h,000h,006h,020h,005h,040h,003h,060h,002h,080h,001h,0a0h,000h,048h	; 7271  ..... .@.`.....H
	defb 039h,015h,014h,013h,012h,052h,010h,00fh,0ffh,050h,0f3h,0f5h,0f6h,0f4h,0f5h,0f7h	; 7281  9....R...P......
	defb 0f6h,0f4h,0f4h,0f3h,0f5h,0f6h,0f4h,0f5h,0f6h,000h,0f7h,073h,018h,074h,039h,074h	; 7291  ...........s.t9t
	defb 057h,074h,004h,00dh,053h,00ch,074h,00ah,096h,009h,0b7h,007h,0d9h,006h,0fah,005h	; 72a1  Wt..S.t.........
	defb 01bh,003h,03dh,000h,051h,039h,039h,03ch,0feh,072h,039h,037h,038h,0ffh,060h,000h	; 72b1  ..=.Q99<.r978.`.
	defb 000h,000h,000h,0f8h,0fch,0f9h,0fbh,0fch,0f9h,0f9h,0f9h,0fbh,0fah,000h,000h,074h	; 72c1  ...............t
	defb 074h,095h,074h,0b6h,074h,0d4h,074h,004h,00dh,040h,00ch,060h,00ah,080h,009h,0a0h	; 72d1  t.t.t.t..@.`....
	defb 007h,0c0h,006h,0e0h,005h,000h,003h,020h,000h,04dh,039h,07dh,07ah,0feh,06ch,039h	; 72e1  ....... .M9}z.l9
	defb 079h,078h,0ffh,050h,000h,000h,000h,0f8h,0fbh,0f9h,0fch,0fbh,0f9h,0fbh,0fch,0fah	; 72f1  yx.P............
	defb 000h,000h,000h,000h,021h,0f8h,013h,015h,012h,012h,012h,014h,014h,014h,0f5h,016h	; 7301  ....!...........
	defb 017h,018h,019h,019h,01ah,01bh,01ch,01ch,01ch,01ch,0f7h,01dh,01eh,01fh,01fh,01fh	; 7311  ................
	defb 020h,021h,022h,023h,0fah,00fh,024h,025h,026h,026h,026h,000h,021h,0fah,015h,0f5h	; 7321   !"#..$%&&&.!...
	defb 027h,028h,029h,029h,019h,02ah,0f7h,02bh,02bh,01eh,01fh,028h,029h,019h,02dh,0fah	; 7331  '()).*.++..().-.
	defb 02eh,026h,026h,000h,021h,0f8h,015h,015h,015h,012h,012h,012h,0f5h,016h,017h,018h	; 7341  .&&.!...........
	defb 019h,019h,02fh,01bh,01ch,022h,022h,0f7h,01dh,01eh,01fh,01fh,01fh,020h,021h,022h	; 7351  ../..""...... !"
	defb 0fah,00fh,024h,025h,000h,021h,0fah,012h,0f5h,027h,028h,029h,029h,019h,02dh,0f7h	; 7361  ..$%.!...'()).-.
	defb 02bh,02bh,01eh,01fh,02ch,029h,019h,02dh,0fah,02eh,026h,026h,000h,021h,0e0h,014h	; 7371  ++..,).-..&&.!..
	defb 014h,014h,012h,012h,012h,015h,013h,0e0h,05dh,05dh,05dh,05dh,05ch,05bh,05ah,05ah	; 7381  ........]]]]\[ZZ
	defb 059h,058h,057h,0e0h,064h,063h,062h,061h,060h,060h,060h,05fh,05eh,0e0h,067h,067h	; 7391  YXW.dcba```_^.gg
	defb 067h,066h,065h,00fh,000h,021h,0e5h,014h,0e5h,06bh,05ah,06ah,06ah,069h,068h,0e1h	; 73a1  gfe..!...kZjjih.
	defb 06eh,05ah,06ah,069h,060h,05fh,06ch,06ch,0e3h,067h,067h,06fh,000h,021h,0e2h,012h	; 73b1  nZji`_ll.ggo.!..
	defb 012h,012h,015h,015h,015h,0e1h,063h,063h,05dh,05ch,070h,05ah,05ah,059h,058h,057h	; 73c1  ......cc]\pZZYXW
	defb 0e1h,063h,062h,061h,060h,060h,060h,05fh,05eh,0e3h,066h,065h,00fh,000h,021h,0e5h	; 73d1  .cba```_^.fe..!.
	defb 012h,0e5h,06eh,05ah,06ah,06ah,069h,068h,0e1h,06eh,05ah,06ah,06dh,060h,05fh,06ch	; 73e1  ..nZjjih.nZjm`_l
	defb 06ch,0e3h,067h,067h,06fh,000h,061h,0f3h,049h,043h,036h,0f5h,037h,048h,0f6h,03bh	; 73f1  l.ggo.a.IC6.7H.;
	defb 042h,036h,0f8h,037h,038h,0f8h,00fh,00fh,054h,0fah,050h,047h,004h,0fbh,042h,048h	; 7401  B6.78...T.PG..BH
	defb 004h,004h,004h,0feh,042h,043h,000h,061h,0f3h,00fh,045h,004h,0f6h,038h,0f6h,04ah	; 7411  ....BC.a..E..8.J
	defb 04ch,004h,0f7h,037h,044h,038h,0fah,040h,041h,0fah,00fh,042h,043h,0fbh,00fh,051h	; 7421  L..7D8.@A..BC..Q
	defb 0fdh,044h,045h,004h,0feh,046h,04dh,000h,061h,0f4h,04fh,0f5h,040h,03dh,0f6h,00fh	; 7431  .DE..FM.a.O.@=..
	defb 035h,04dh,0f7h,04bh,04eh,004h,0f9h,04ah,04bh,0ffh,0fch,00fh,040h,041h,0fdh,00fh	; 7441  5M.KN..JK...@A..
	defb 042h,052h,0feh,04eh,053h,000h,061h,0f4h,03fh,036h,0f5h,046h,03ah,0f8h,036h,0f7h	; 7451  BR.NS.a.?6.F:.6.
	defb 00fh,037h,050h,0f8h,04fh,055h,045h,004h,0fah,046h,04ch,049h,0ffh,0ffh,043h,0feh	; 7461  .7P.OUE..FLI..C.
	defb 00fh,00fh,000h,061h,0eah,077h,084h,08ah,0e9h,089h,078h,0e7h,077h,083h,07ch,0e6h	; 7471  ...a.w....x.w.|.
	defb 079h,078h,0e5h,06ah,00fh,00fh,0e3h,004h,05dh,066h,0e0h,004h,004h,004h,05eh,058h	; 7481  yx.j....]f....^X
	defb 0e0h,059h,058h,000h,061h,0eah,004h,086h,00fh,0e9h,079h,0e7h,004h,08dh,08bh,0e6h	; 7491  .YX.a.....y.....
	defb 079h,085h,078h,0e4h,057h,056h,0e3h,059h,058h,00fh,0e3h,067h,00fh,0e0h,004h,05bh	; 74a1  y.x.WV.YX..g...[
	defb 05ah,0e0h,063h,05ch,000h,061h,0ebh,090h,0e9h,07eh,081h,0e7h,08eh,076h,00fh,0e6h	; 74b1  Z.c\.a...~...v..
	defb 004h,08fh,08ch,0e5h,061h,060h,0ffh,0e1h,057h,056h,00fh,0e0h,068h,058h,00fh,0e0h	; 74c1  ....a`..WV..hX..
	defb 069h,064h,000h,061h,0eah,077h,080h,0e9h,07bh,087h,0e7h,077h,0e6h,091h,078h,00fh	; 74d1  id.a.w..{..w..x.
	defb 0e4h,004h,05bh,06bh,065h,0e3h,05fh,062h,05ch,0ffh,0e0h,059h,0e0h,00fh,00fh,000h	; 74e1  ..[ke._b\..Y....

; ======================================================================
; CODIGO 0x74f1..0x7535  (68 bytes)
; ======================================================================


DIBUJA_LA_META:		; En los ultimos 100 metros, cada 32 dibuja un trozo mas de la llegada
	ld hl,(0e0e5h)		;74f1   ; Solo con la centena a cero, o sea en los ultimos cien metros
	ld a,h			;74f4
	or a			;74f5
	ret nz			;74f6
	ld a,l			;74f7
	and 01fh		;74f8   ; Y solo en los multiplos de 32
	ret nz			;74fa
	ld a,l			;74fb
	rlca			;74fc   ; Las tres rotaciones y el doble convierten 0x00/0x20/0x40/0x60/0x80 en 0, 2, 4, 6 y 8: la palabra de la tabla que toca
	rlca			;74fd
	rlca			;74fe
	add a,a			;74ff   ; el `add a,a` remata el por 16
	ld hl,07535h		;7500
	call SUMA_A_HL		;7503
	ld e,(hl)			;7506
	inc hl			;7507
	ld d,(hl)			;7508
	ex de,hl			;7509
	ld a,(hl)			;750a
	and 0f0h		;750b   ; el nibble alto es el caracter
	ld c,a			;750d
	ld a,(hl)			;750e
	inc hl			;750f
	and 003h		;7510   ; y los dos bits bajos, el tercio
	add a,078h		;7512
	ld d,a			;7514
	ld a,c			;7515
META_FILA:
	ld b,(hl)			;7516
	inc hl			;7517
	ld a,020h		;7518   ; La misma cuenta que el interprete de bloques: 32 casillas por fila y el cierre 0xE0 de desplazamiento
	add a,c			;751a
	ld c,a			;751b
	jr nc,META_APUNTA		;751c
	inc d			;751e
META_APUNTA:
	ld a,c			;751f
	add a,b			;7520
	sub 0e0h		;7521
	ld e,a			;7523
	call APUNTA_VRAM		;7524
META_CASILLA:
	ld a,(hl)			;7527
	or a			;7528   ; El 0x00 cierra el bloque, igual que en DIBUJA_BLOQUE
	ret z			;7529
	cp 0e0h		;752a
	jr nc,META_FILA		;752c
	inc hl			;752e
	add a,040h		;752f   ; Igual que el interprete de bloques, pero con las casillas corridas 0x40
	out (098h),a		;7531
	jr META_CASILLA		;7533

; ----------------------------------------------------------------------
; DATOS punteros_de_la_meta: Cinco punteros, uno por cada tramo de 32 metros
;   del final. Cierra clavada en 0x753F, que es el primero de ellos
;   0x7535..0x753f  (10 bytes)
DATA_punteros_de_la_meta:
	defw 0757ah,07557h,07549h,07544h,0753fh	; 7535

; ----------------------------------------------------------------------
; DATOS bloques_de_la_meta: Los cinco bloques que va dibujando 0x74F1
;   0x753f..0x75c5  (134 bytes)
DATA_bloques_de_la_meta:
	defb 021h,0efh,090h,091h,000h,021h,0efh,092h,093h,000h,001h,0efh,0afh,0eeh,094h,096h	; 753f  !....!..........
	defb 096h,098h,0eeh,095h,097h,097h,09ah,000h,0e0h,0efh,0afh,0efh,0b1h,0b2h,0edh,09dh	; 754f  ................
	defb 09bh,09ch,09ch,09ch,09bh,0edh,0c8h,09eh,0a4h,0a6h,0a8h,0a1h,0edh,0c8h,09fh,0a5h	; 755f  ................
	defb 0a7h,0a9h,0c9h,0edh,0a3h,0a0h,0a0h,0a0h,0adh,0a0h,000h,0c0h,0efh,071h,0efh,0b0h	; 756f  .............q..
	defb 0efh,0b1h,0b2h,0ebh,09dh,09dh,09bh,09bh,09bh,09ch,09ch,09ch,09ch,09bh,0ebh,0c8h	; 757f  ................
	defb 0c8h,0c9h,0c9h,0c9h,0c9h,0c9h,0a2h,0a2h,0c9h,0ebh,0c8h,0c8h,0c9h,0aah,0c9h,0aah	; 758f  ................
	defb 0c9h,099h,0c9h,0c9h,0ebh,0c8h,0c8h,0c9h,0abh,0c9h,0abh,0c9h,099h,0c9h,0c9h,0ebh	; 759f  ................
	defb 0c8h,0c8h,0c9h,0c9h,0c9h,0c9h,0c9h,0aeh,0c9h,0c9h,0ebh,0a3h,0a3h,0ach,0a0h,0a0h	; 75af  ................
	defb 0ach,0ach,09ah,0a0h,0ach,000h	; 75bf

; ======================================================================
; CODIGO 0x75c5..0x7709  (324 bytes)
; ======================================================================


SUELTA_EL_PEZ:		; Cuando un agujero llega al paso 7, sale el pez de dentro
	ld hl,0e183h		;75c5
	ld a,(hl)			;75c8
	and 0e3h		;75c9
	ret nz			;75cb
	ld de,0e113h		;75cc   ; Las tres fichas de obstaculo
	ld b,003h		;75cf
PEZ_BUSCA:
	ld a,(de)			;75d1
	cp 003h		;75d2   ; Solo los tipos 0, 1 y 2, que son los agujeros
	jr nc,PEZ_SIGUIENTE		;75d4
	dec de			;75d6
	ld a,(de)			;75d7
	cp 007h		;75d8
	jr z,PEZ_SALE		;75da   ; Y solo en el paso 7
	inc de			;75dc
PEZ_SIGUIENTE:
	ld a,006h		;75dd
	call SUMA_A_DE		;75df
	djnz PEZ_BUSCA		;75e2
	ret			;75e4
PEZ_SALE:
	ld (0e181h),de		;75e5   ; 0xE181 se queda apuntando al agujero; DE, a su tipo
	inc de			;75e9
	ld a,(0e18ah)		;75ea
	ld c,a			;75ed
	ld a,(0e003h)		;75ee   ; Antes de que se cumpla el plazo de 0xE18A el pez sale; despues ya no
	cp c			;75f1
	jr nc,PEZ_TARDE		;75f2
	ld a,(0e009h)		;75f4
	and 00ch		;75f7   ; Con izquierda o derecha pulsadas el pez sale mirando alli; sin mando, alterna con 0xE185
	jr z,PEZ_LADO		;75f9
	bit 2,a		;75fb
	jr PEZ_MONTA		;75fd
PEZ_LADO:
	ld a,(0e185h)		;75ff
	inc a			;7602
	ld (0e185h),a		;7603
	bit 0,a		;7606
PEZ_MONTA:		; Monta la entrada de atributo del pez. El DIBUJO sale de aqui: 0x90 si mira a un lado y 0x80 si al otro
	ld a,090h		;7608
	set 0,(hl)		;760a
	jr z,PEZ_ALTURA		;760c
	ld a,080h		;760e
	rlc (hl)		;7610
PEZ_ALTURA:
	ld c,a			;7612
	ld hl,0e08ch		;7613
	ld a,(de)			;7616
	ld d,c			;7617
	cp 001h		;7618
	ld bc,07a66h		;761a   ; CUIDADO CON ESTE `ld bc,07a66h`: 0x66, 0x64 y 0x92 son las X de los tres saltos -corto, medio y largo-, NO patrones. El patron es el que quedo en D unas instrucciones antes
	jr c,PEZ_SALTO_CORTO		;761d
	jr z,PEZ_SALTO_MEDIO		;761f
	ld b,092h		;7621
PEZ_SALTO_CORTO:
	jr PEZ_GUARDA		;7623
PEZ_SALTO_MEDIO:
	ld b,064h		;7625
PEZ_GUARDA:
	ld (hl),c			;7627   ; C traia el 0x7A del `ld bc`: la Y de salida; B la X del salto y D el patron que quedo antes
	inc hl			;7628
	ld (hl),b			;7629
	inc hl			;762a
	ld (hl),d			;762b
	ret			;762c
PEZ_TARDE:		; Ya no da tiempo: se marca el agujero segun su tipo
	xor a			;762d
	ld (0e192h),a		;762e   ; El agujero queda marcado en los bits 5-7 de 0xE183 segun su tipo: de ahi saldra la foca
	ld a,(de)			;7631
	cp 001h		;7632
	jr c,PEZ_TIPO_0		;7634
	jr z,PEZ_TIPO_1		;7636
	set 5,(hl)		;7638
	ret			;763a
PEZ_TIPO_0:
	set 6,(hl)		;763b
	ret			;763d
PEZ_TIPO_1:
	set 7,(hl)		;763e
	ret			;7640
MUEVE_EL_PEZ:		; Un paso del pez cada dos fotogramas
	ld a,(0e003h)		;7641
	rra			;7644
	ret c			;7645
PEZ_PASO:		; Lo coloca, lo copia a la VRAM y le lleva el arco del salto
	ld hl,(0e08ch)		;7646
	ld (0e188h),hl		;7649   ; 0xE188 es lo que mira MIRA_EL_PEZ para saber si el pinguino lo pisa
	ld hl,0e08ch		;764c
	ld de,03b3ch		;764f   ; Sprite 15
	ld bc,00004h		;7652   ; cuatro bytes: el atributo entero del sprite
	call COPIA_A_VRAM		;7655
	ld de,0e183h		;7658
	ld a,(de)			;765b
	and 003h		;765c   ; los dos bits bajos: la fase del vuelo del pez
	ret z			;765e
	ld hl,0e08eh		;765f
	call PEZ_GIRA		;7662
	ld a,(de)			;7665
	dec hl			;7666
	rra			;7667
	jr c,PEZ_ARCO_SUBE		;7668
	dec (hl)			;766a   ; dos pixeles por paso al subir
	dec (hl)			;766b
	jr PEZ_ARCO		;766c
PEZ_ARCO_SUBE:
	inc (hl)			;766e
	inc (hl)			;766f
PEZ_ARCO:
	push hl			;7670
	ld hl,0e184h		;7671   ; 0xE184 cuenta el vuelo: sube hasta el 8, plano hasta el 0x10, cae desde ahi y en el 0x22 se recoge
	inc (hl)			;7674
	ld a,(hl)			;7675
	pop hl			;7676
	dec hl			;7677
	cp 008h		;7678   ; hasta el 8 sube
	jr c,PEZ_SUBE		;767a
	cp 010h		;767c   ; del 8 al 0x10 vuela plano
	ret c			;767e
	jr z,PEZ_CAE		;767f
	cp 022h		;7681
	jr nc,QUITA_EL_PEZ		;7683
	ld c,005h		;7685   ; Cinco por paso al caer, y siete desde el 0x1A
	cp 01ah		;7687
	jr c,PEZ_ARCO_BAJA		;7689
	inc c			;768b
	inc c			;768c
PEZ_ARCO_BAJA:
	ld a,(hl)			;768d
	add a,c			;768e
	ld (hl),a			;768f
	ret			;7690
PEZ_SUBE:
	dec (hl)			;7691
	dec (hl)			;7692
	ret			;7693
PEZ_CAE:		; Al llegar al paso 0x10 del arco le SUMA 8 al byte del patron (0xE08E): el pez cambia al dibujo grande. Con eso y el bit 2 que voltea 0x76A3 salen OCHO dibujos, cuatro por lado: 0x80-0x8C mirando a un lado y 0x90-0x9C al otro. Los ocho estan MEDIDOS en la partida grabada (work/sprites_medidos.txt), siempre en el color del atributo 15
	inc hl			;7694
	inc hl			;7695
	ld a,(hl)			;7696
	add a,008h		;7697   ; Ocho arriba en el patron: el dibujo grande
	ld (hl),a			;7699
	ret			;769a
QUITA_EL_PEZ:		; Lo saca de la pantalla poniendole Y=0xE0
	ld (hl),0e0h		;769b
	xor a			;769d   ; Y borra estado y paso (0xE183/0xE184): el agujero queda libre
	ld (de),a			;769e
	inc de			;769f
	ld (de),a			;76a0
	jr PEZ_PASO		;76a1
PEZ_GIRA:		; Cada 16 fotogramas le da la vuelta al BIT 2 del patron y le deja los dos de abajo a cero: eso es lo que anima al pez. Los tres `srl` mas el `ccf` mas los tres `rla` dejan (patron & 0xF8) | (bit2 invertido) << 2
	ld a,(0e003h)		;76a3
	and 00fh		;76a6   ; Uno de cada dieciseis fotogramas
	ret nz			;76a8
	ld a,(hl)			;76a9
	srl a		;76aa   ; Tres a la derecha, el acarreo invertido y tres a la izquierda: el bit 2 da la vuelta y los bits 0-1 quedan a cero
	srl a		;76ac
	srl a		;76ae
	ccf			;76b0
	rla			;76b1
	rla			;76b2
	rla			;76b3
	ld (hl),a			;76b4
	ret			;76b5
AJUSTA_DIFICULTAD:		; De la velocidad y de la fase sale cada cuantos pasos aparece el siguiente obstaculo
	call MANDA_LA_VELOCIDAD		;76b6
	ld a,(0e100h)		;76b9
	or a			;76bc
	rra			;76bd
	ld (0e148h),a		;76be   ; 0xE148: la mitad del periodo, que es el ritmo de los sprites de fondo
	ld a,(0e0e6h)		;76c1
	and 00ch		;76c4
	ld a,02ch		;76c6
	jr nz,DIFICULTAD_FASE		;76c8
	add a,004h		;76ca
DIFICULTAD_FASE:
	ld c,a			;76cc
	ld a,(0e0e0h)		;76cd
	and 0f0h		;76d0   ; De la fase 10 en adelante, cuatro menos; de la 20, otros cuatro
	jr z,DIFICULTAD_VELOCIDAD		;76d2
	and 0e0h		;76d4
	jr z,DIFICULTAD_RESTA		;76d6
	ld a,c			;76d8
	sub 004h		;76d9
	ld c,a			;76db
DIFICULTAD_RESTA:
	ld a,c			;76dc
	sub 004h		;76dd
	ld c,a			;76df
DIFICULTAD_VELOCIDAD:
	ld a,(0e100h)		;76e0   ; Y lo mismo por tramos de velocidad
	cp 00ch		;76e3
	jr c,DIFICULTAD_MENOS_12		;76e5
	and 00ch		;76e7
	jr z,DIFICULTAD_MENOS_4		;76e9
	cp 00ch		;76eb
	jr z,DIFICULTAD_MENOS_8		;76ed
	ld a,c			;76ef
DIFICULTAD_GUARDA:
	ld (0e10eh),a		;76f0
	ret			;76f3
DIFICULTAD_MENOS_12:
	ld a,c			;76f4
	sub 004h		;76f5
	ld c,a			;76f7
DIFICULTAD_MENOS_8:
	ld a,c			;76f8
	sub 004h		;76f9
	ld c,a			;76fb
DIFICULTAD_MENOS_4:
	ld a,c			;76fc
	sub 004h		;76fd
	jr DIFICULTAD_GUARDA		;76ff

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LA VELOCIDAD
; ----------------------------------------------------------------------
; Los bits 0 y 1 de los mandos son arriba y abajo, y los cuatro
; destinos de la tabla son: no tocar nada, no hace nada; ARRIBA
; ACELERA y ABAJO FRENA; y las dos a la vez, tampoco hace nada.
; En 0xE100 no vive la velocidad sino su PERIODO: los fotogramas
; que pasan entre dos avances. Cuanto mas alto, mas lento. Va de
; 8 -a todo correr- a 0x13, y por eso acelerar es RESTARLE y
; frenar es SUMARLE. Lo confirman sus tres usos: 0x46C3 recarga
; con el la mitad de un contador descendente, 0x52FE con su
; cuarta parte, y el velocimetro tiene que INVERTIRLO con un cpl
; (0x7757) para pintar la barra.
; Y no cuestan lo mismo: ganar un escalon lleva doce fotogramas y
; perderlo solo cuatro, o sea que se FRENA TRES VECES MAS RAPIDO
; de lo que se acelera. Cada rutina pone a cero el contador de la
; otra, asi que cambiar de idea empieza la cuenta de nuevo.
; ----------------------------------------------------------------------
MANDA_LA_VELOCIDAD:		; Despacha por arriba/abajo para acelerar o frenar
	ld a,(0e009h)		;7701
	and 003h		;7704
	call DESPACHA		;7706

; ----------------------------------------------------------------------
; DATOS tabla_velocidad: Los 4 destinos del CALL de 0x76DC. Cierra clavada
;   contra su primer destino. Son los cuatro destinos de la velocidad: nada,
;   acelerar, frenar y el tope.
;   0x7709..0x7711  (8 bytes)
DATA_tabla_velocidad:
	defw 0773fh	; 7709  -> NI_UNA_COSA_NI_OTRA
	defw 07711h	; 770b  -> ACELERA
	defw 07729h	; 770d  -> FRENA
	defw 0773fh	; 770f  -> NI_UNA_COSA_NI_OTRA

; ======================================================================
; CODIGO 0x7711..0x780c  (251 bytes)
; ======================================================================


ACELERA:		; Un escalon MENOS de periodo cada doce fotogramas, hasta 8: el tope de velocidad
	ld hl,0e0fdh		;7711
	xor a			;7714   ; El contador del freno se pone a cero: cambiar de idea empieza la cuenta de nuevo
	ld (hl),a			;7715
	inc hl			;7716
	inc hl			;7717
	ld (hl),a			;7718
	dec hl			;7719
	inc (hl)			;771a
	ld a,(hl)			;771b
	sub 00ch		;771c   ; 0x0C fotogramas para subir un escalon de velocidad
	ret nz			;771e
	ld (hl),a			;771f
	ld hl,0e100h		;7720
	ld a,(hl)			;7723
	cp 009h		;7724   ; Nunca por debajo de 8, que es todo lo rapido que va el juego
	ret c			;7726
	dec (hl)			;7727
	ret			;7728
FRENA:		; Un escalon MAS cada cuatro fotogramas, hasta 0x13
	ld hl,0e0fdh		;7729
	xor a			;772c   ; Y este apaga el del acelerador: cuatro fotogramas contra doce, se frena tres veces mas deprisa
	ld (hl),a			;772d
	inc hl			;772e
	ld (hl),a			;772f
	inc hl			;7730
	inc (hl)			;7731
	ld a,(hl)			;7732
	sub 004h		;7733   ; cuatro fotogramas para bajar un escalon de velocidad
	ret nz			;7735
	ld (hl),a			;7736
	ld hl,0e100h		;7737
	ld a,(hl)			;773a
	cp 013h		;773b   ; El tope lento es 0x13
	ret nc			;773d
	inc (hl)			;773e   ; y se baja un escalon
NI_UNA_COSA_NI_OTRA:
	ret			;773f
PINTA_VELOCIMETRO:		; Las seis casillas del velocimetro, en la fila 0
	ld a,(0e140h)		;7740   ; Cayendose o en el agua, la barra se queda a cero
	ld hl,0e142h		;7743
	add a,(hl)			;7746
	ld hl,0e171h		;7747
	jr nz,VELOCIMETRO_VACIA		;774a
	ld a,(0e100h)		;774c
	ld b,a			;774f
	and 001h		;7750   ; el bit 0 elige entre las dos medias casillas
	add a,042h		;7752
	ld c,a			;7754
	ld a,b			;7755
	rra			;7756   ; La media vuelta y el `cpl` invierten el periodo -barra larga, periodo corto- y el bit 0 elige la media casilla (0x42/0x43)
	cpl			;7757
	and 00fh		;7758   ; los cuatro bits bajos son la longitud de la barra
	sub 006h		;775a
	jr z,VELOCIMETRO_CASILLA		;775c
	ld b,a			;775e
VELOCIMETRO_LLENA:
	ld (hl),042h		;775f
	inc hl			;7761
	djnz VELOCIMETRO_LLENA		;7762
VELOCIMETRO_CASILLA:
	ld (hl),c			;7764
	inc hl			;7765
	ld a,l			;7766
	cp 078h		;7767   ; Seis casillas
	jr z,VELOCIMETRO_A_VRAM		;7769
VELOCIMETRO_VACIA:
	ld c,000h		;776b
	jr VELOCIMETRO_CASILLA		;776d
VELOCIMETRO_A_VRAM:
	ld hl,0e171h		;776f
	ld de,03839h		;7772
	ld bc,00006h		;7775
	jp COPIA_A_VRAM		;7778
LAS_NUBES:		; Las cuatro nubes del cielo. Suben por la pantalla al ritmo de la velocidad, se van abriendo hacia los lados y crecen de patron por el camino: es la perspectiva de acercarse a ellas y pasarles por debajo. Se apagan al llegar arriba (Y=8) y vuelven a salir
	ld a,(0e002h)		;777b   ; En la demo no salen
	bit 6,a		;777e
	ret z			;7780
	ld b,004h		;7781
	ld de,0e0b8h		;7783
	ld hl,0e14ah		;7786
NUBE_NUEVA:
	ld a,(hl)			;7789
	or a			;778a
	ld a,004h		;778b   ; El 4 es el salto de ficha para el `SUMA_A_DE` de abajo: cuatro bytes de atributo por nube
	jr nz,NUBE_SIGUIENTE		;778d
	push hl			;778f
	inc (hl)			;7790
	ld hl,0780eh		;7791   ; Donde empieza cada uno
	ld a,b			;7794
	add a,a			;7795   ; dos bytes por entrada
	call SUMA_A_HL		;7796
	ld a,(hl)			;7799
	ld (de),a			;779a
	inc hl			;779b
	inc de			;779c
	ld a,(hl)			;779d
	ld (de),a			;779e
	inc de			;779f
	ld a,0e0h		;77a0   ; El patron de arranque es el 0xE0 y el color el blanco 0x0F
	ld (de),a			;77a2
	inc de			;77a3
	ld a,00fh		;77a4
	ld (de),a			;77a6
	ld a,001h		;77a7   ; y la nube queda encendida
	pop hl			;77a9
NUBE_SIGUIENTE:
	call SUMA_A_DE		;77aa
	inc hl			;77ad
	djnz NUBE_NUEVA		;77ae
	ld hl,0e149h		;77b0
	dec (hl)			;77b3
	ret nz			;77b4
	ld a,(0e148h)		;77b5   ; El ritmo al que suben, que es la mitad del periodo del pinguino
	ld (hl),a			;77b8
	ld b,000h		;77b9   ; B a cero: ahora hace de indice de nube para los desplazamientos
	ld hl,0e14ah		;77bb
	ld de,0e0b8h		;77be
MUEVE_LAS_NUBES:
	ld a,(hl)			;77c1
	or a			;77c2
	jr z,NUBE_AVANZA		;77c3
	ld a,(de)			;77c5
	cp 008h		;77c6
	jr nz,NUBE_PASO		;77c8
	ld a,0d1h		;77ca   ; EL 0xD1 NO ES UN PATRON: DE apunta al byte de la Y, asi que esto saca la nube por abajo cuando ha llegado arriba del todo. Los patrones de nube son solo TRES -0xE0 al asomar, 0xDC y 0xD8 segun se acerca-, y el color 0x0F se lo pone a mano 0x77A4
	ld (de),a			;77cc
	ld (hl),000h		;77cd
	jr NUBE_AVANZA		;77cf
NUBE_PASO:
	push de			;77d1
	inc (hl)			;77d2
	ex de,hl			;77d3
	dec (hl)			;77d4   ; El paso: la Y sube uno y la X se corre lo que diga la tabla de 0x780C para esa nube
	push de			;77d5
	ld de,0780ch		;77d6   ; La tabla de 0x780C lleva un byte con signo por nube: -1, +1, -2 y +2
	ld a,b			;77d9
	call SUMA_A_DE		;77da
	ld a,(de)			;77dd
	inc hl			;77de
	add a,(hl)			;77df
	ld (hl),a			;77e0
	ex de,hl			;77e1
	pop hl			;77e2   ; La Y de la nube, que el `dec (hl)` acaba de subir un pixel
	ld a,(hl)			;77e3
	cp 00ch		;77e4   ; En los pasos 0x0C y 0x18 el patron pasa a 0xDC y 0xD8: la nube crece al acercarse
	ld a,0dch		;77e6
	jr z,NUBE_CRECE		;77e8
	ld a,(hl)			;77ea
	cp 018h		;77eb
	ld a,0d8h		;77ed
	jr nz,NUBE_RECUPERA		;77ef
NUBE_CRECE:
	inc de			;77f1   ; El patron nuevo, al tercer byte del atributo
	ld (de),a			;77f2
NUBE_RECUPERA:
	pop de			;77f3
NUBE_AVANZA:
	ld a,004h		;77f4   ; El 4 salta al atributo siguiente
	call SUMA_A_DE		;77f6
	inc hl			;77f9
	ld a,004h		;77fa   ; Cuatro nubes, y el volcado de los cuatro atributos de una vez (sprites 26 a 29)
	inc b			;77fc
	cp b			;77fd
	jr nz,MUEVE_LAS_NUBES		;77fe
	ld hl,0e0b8h		;7800
	ld de,03b68h		;7803
	ld bc,00010h		;7806
	jp COPIA_A_VRAM		;7809

; ----------------------------------------------------------------------
; DATOS nubes_desplazamientos: Cuanto se corre de lado cada nube en cada paso:
;   -1, +1, -2 y +2. Con la Y subiendo y la X abriendose, las cuatro se
;   separan del centro segun se acercan
;   0x780c..0x7810  (4 bytes)
DATA_nubes_desplazamientos:
	defb 0ffh,001h,0feh,002h	; 780c

; ----------------------------------------------------------------------
; DATOS nubes_posiciones: Por donde asoma cada nube: cuatro parejas (Y, X),
;   las cuatro en la misma columna y a alturas distintas
;   0x7810..0x7818  (8 bytes)
DATA_nubes_posiciones:
	defb 038h,098h	; 7810
	defb 037h,058h	; 7812
	defb 03ch,07ch	; 7814
	defb 03ah,074h	; 7816

; ======================================================================
; CODIGO 0x7818..0x7897  (127 bytes)
; ======================================================================


ANIMA_LA_FOCA:		; Saca la foca del agujero: ocho pasos, del 7 al 14, con su fotograma sacado de la tabla de 0x7897. Dibujada, se la reconoce: primero asoma un filo, luego la cabeza, y del paso 10 en adelante el cuerpo entero con las dos aletas
	ld a,(0e183h)		;7818
	and 0e0h		;781b   ; Los bits 5-7 de 0xE183 los dejo PEZ_TARDE: sin ellos no hay foca
	ret z			;781d
	ld hl,(0e181h)		;781e   ; 0xE181 apunta al byte de ESTADO de la ficha, asi que esto es EL PASO en que va, no el tipo
	ld a,(hl)			;7821
	ld hl,0e183h		;7822
	sub 00fh		;7825
	jr nz,FOCA_FOTOGRAMA		;7827
	ld (hl),a			;7829
	ld hl,07993h		;782a
	ld b,004h		;782d
	jr FOCA_COPIA		;782f
FOCA_FOTOGRAMA:		; Coge el fotograma del paso en que va
	ld hl,07897h		;7831   ; paso-15+8 = paso-7: ocho entradas, para los pasos 7 a 14
	add a,008h		;7834
	ld b,a			;7836
	add a,a			;7837   ; dos bytes por entrada
	call SUMA_A_HL		;7838
	ld e,(hl)			;783b
	inc hl			;783c
	ld d,(hl)			;783d
	ld a,b			;783e
	ld b,004h		;783f   ; cuatro sprites para la foca
	cp 006h		;7841   ; En los pasos 13 y 14, con 0xE137 apagado, se enciende 0xE192: la foca pasa a los sprites 0-3, delante de todo
	jr c,FOCA_PASO		;7843
	ld hl,0e137h		;7845
	bit 0,(hl)		;7848
	jr nz,FOCA_PASO		;784a
	ld hl,0e192h		;784c
	ld (hl),001h		;784f
FOCA_PASO:
	cp 003h		;7851
	ex de,hl			;7853
	ld d,00ch		;7854   ; D es el tamano de cada variante: 12 bytes (cuatro sprites) o 6 (dos, en los tres primeros pasos)
	jr nc,FOCA_AVANZA		;7856
	ld d,006h		;7858
	ld b,002h		;785a
FOCA_AVANZA:
	ld a,(0e183h)		;785c
	cp 040h		;785f   ; 0x40 (tipo 0): la primera variante; 0x20: una mas alla; 0x80: dos, saltando D bytes por variante
	jr z,FOCA_COPIA		;7861
	jr c,FOCA_AVANZA_UNO		;7863
	ld a,d			;7865
	call SUMA_A_HL		;7866
FOCA_AVANZA_UNO:
	ld a,d			;7869
	call SUMA_A_HL		;786a
FOCA_COPIA:
	ld de,0e090h		;786d
	push de			;7870
FOCA_ENTRADA:
	ld c,003h		;7871
FOCA_BYTE:		; Copia Y, X y patron, y se SALTA el cuarto byte del atributo: el color. Por eso el color de la foca no esta en el fotograma sino en la lista de atributos de 0x66C7, que le deja el primer sprite en NEGRO y los otros tres en ROJO OSCURO. Dibujada asi es una foca con la cara oscura, porque el negro es el atributo 16 y en un MSX el numero mas bajo va delante
	ld a,(hl)			;7873
	ld (de),a			;7874
	inc hl			;7875
	inc de			;7876
	dec c			;7877
	jr nz,FOCA_BYTE		;7878
	inc de			;787a   ; El `inc de` extra salta el byte de color del atributo, que no se toca
	djnz FOCA_ENTRADA		;787b
	pop hl			;787d
	ld c,010h		;787e
	ld a,(0e192h)		;7880
	rra			;7883
	ld de,03b00h		;7884   ; Cuatro sprites, y si hace falta tambien los otros cuatro
	jr nc,FOCA_A_VRAM		;7887
	call COPIA_A_VRAM		;7889
	ld hl,0e050h		;788c
FOCA_A_VRAM:
	ld de,03b40h		;788f
	ld c,010h		;7892
	jp COPIA_A_VRAM		;7894

; ----------------------------------------------------------------------
; DATOS punteros_de_la_foca: Ocho punteros, uno por cada paso del 7 al 14.
;   0x7831 los indexa con paso-7, no con el tipo de obstaculo: leido de la
;   otra manera salen punteros que se van fuera del cartucho. Cierra clavada
;   en 0x78A9, que es el primero de ellos
;   0x7897..0x78a7  (16 bytes)
DATA_punteros_de_la_foca:
	defw 078a9h,078bbh,078cdh,078dfh,07903h,07927h,0794bh,0796fh	; 7897

; ----------------------------------------------------------------------
; DATOS fotogramas_de_la_foca: Los ocho fotogramas, cada uno con TRES
;   variantes que elige 0x785C con el bit que 0x762D encendio en 0xE183. Los
;   tres primeros pasos llevan dos sprites (18 bytes = 3 x 2 x 3) y los cinco
;   siguientes cuatro (36 bytes); de cada sprite van tres bytes: Y, X y
;   patron. LAS TRES VARIANTES LLEVAN EL MISMO DIBUJO y solo cambian la X: una
;   sale por el centro (0x78), otra se va a la derecha y otra a la izquierda,
;   separandose mas en cada paso. Y del paso 10 al 14 los cuatro patrones son
;   siempre C0, C4, C8 y CC: lo unico que cambia es la Y, que baja de 0x7B a
;   0xA1. La foca no se deforma, se acerca
;   0x78a7..0x7993  (236 bytes)
DATA_fotogramas_de_la_foca:
	defb 093h,079h,067h,078h,07ch,067h,078h,0e8h,067h,090h,07ch,067h,090h,0e8h,067h,060h	; 78a7  .ygx|gx.g.|g..g`
	defb 07ch,067h,060h,0e8h,06ch,078h,0b8h,06ch,078h,0bch,06ch,094h,0b8h,06ch,094h,0bch	; 78b7  |g`.lx.lx.l..l..
	defb 06ch,05bh,0b8h,06ch,05bh,0bch,078h,078h,0b8h,078h,078h,0bch,078h,09dh,0b8h,078h	; 78c7  l[.l[.xx.xx.x..x
	defb 09dh,0bch,078h,053h,0b8h,078h,053h,0bch,07bh,078h,0c0h,08bh,070h,0c4h,07bh,078h	; 78d7  ..xS.xS.{x..p.{x
	defb 0c8h,08bh,080h,0cch,07bh,0a4h,0c0h,08bh,09ch,0c4h,07bh,0a4h,0c8h,08bh,0ach,0cch	; 78e7  ....{.....{.....
	defb 07bh,04ch,0c0h,08bh,044h,0c4h,07bh,04ch,0c8h,08bh,054h,0cch,086h,078h,0c0h,096h	; 78f7  {L..D.{L..T..x..
	defb 070h,0c4h,086h,078h,0c8h,096h,080h,0cch,086h,0ach,0c0h,096h,0a4h,0c4h,086h,0ach	; 7907  p..x............
	defb 0c8h,096h,0b4h,0cch,086h,044h,0c0h,096h,03ch,0c4h,086h,044h,0c8h,096h,04ch,0cch	; 7917  .....D..<..D..L.
	defb 08fh,078h,0c0h,09fh,070h,0c4h,08fh,078h,0c8h,09fh,080h,0cch,08fh,0b2h,0c0h,09fh	; 7927  .x..p..x........
	defb 0aah,0c4h,08fh,0b2h,0c8h,09fh,0bah,0cch,08fh,03eh,0c0h,09fh,036h,0c4h,08fh,03eh	; 7937  .........>..6..>
	defb 0c8h,09fh,046h,0cch,098h,078h,0c0h,0a8h,070h,0c4h,098h,078h,0c8h,0a8h,080h,0cch	; 7947  ..F..x..p..x....
	defb 098h,0b8h,0c0h,0a8h,0b0h,0c4h,098h,0b8h,0c8h,0a8h,0c0h,0cch,098h,038h,0c0h,0a8h	; 7957  .............8..
	defb 030h,0c4h,098h,038h,0c8h,0a8h,040h,0cch,0a1h,078h,0c0h,0b1h,070h,0c4h,0a1h,078h	; 7967  0..8..@..x..p..x
	defb 0c8h,0b1h,080h,0cch,0a1h,0beh,0c0h,0b1h,0b6h,0c4h,0a1h,0beh,0c8h,0b1h,0c6h,0cch	; 7977  ................
	defb 0a1h,032h,0c0h,0b1h,02ah,0c4h,0a1h,032h,0c8h,0b1h,03ah,0cch	; 7987  .2..*..2..:.

; ----------------------------------------------------------------------
; DATOS foca_escondida: El fotograma del paso 15, con las cuatro Y a 0xE0 para
;   sacarla de la pantalla. Cierra clavado en 0x799F, donde vuelve a haber
;   codigo
;   0x7993..0x799f  (12 bytes)
DATA_foca_escondida:
	defb 0e0h,000h,000h,0e0h,000h,000h,0e0h,000h,000h,0e0h,000h,000h	; 7993  ............

; ======================================================================
; CODIGO 0x799f..0x7b06  (359 bytes)
; ======================================================================


PIDE_SONIDO:		; Pone en marcha el sonido A, si su numero manda mas que el que ya suena
	di			;799f   ; Con las interrupciones paradas: ATIENDE_SONIDO corre en la interrupcion y toca estos mismos bloques
	push hl			;79a0
	push de			;79a1
	push bc			;79a2
	push af			;79a3
	call PIDE_SONIDO_SIN_GUARDAR		;79a4   ; La entrada sin salvar registros es la que usan el rearranque y el encadenado
	pop af			;79a7
	pop bc			;79a8
	pop de			;79a9
	pop hl			;79aa
	ei			;79ab
	ret			;79ac
PIDE_SONIDO_SIN_GUARDAR:
	ld b,002h		;79ad
	ld hl,0e012h		;79af
	cp 08ah		;79b2   ; Menos de 0x8A: un canal
	jr c,SONIDO_UN_CANAL		;79b4
	cp 08ch		;79b6   ; Menos de 0x8C: dos
	jr c,SONIDO_PRIORIDAD		;79b8
	inc b			;79ba   ; De ahi arriba: los tres
	jr SONIDO_PRIORIDAD		;79bb
SONIDO_UN_CANAL:
	dec b			;79bd
	ld hl,0e026h		;79be
SONIDO_PRIORIDAD:
	cp (hl)			;79c1   ; Si el que suena manda mas, no se toca
	jr c,SONIDO_NO		;79c2
	ld c,a			;79c4
	and 03fh		;79c5
	add a,a			;79c7
	ld de,07b21h		;79c8   ; La tabla de flujos
	call SUMA_A_DE		;79cb
SONIDO_MONTA_CANAL:
	dec hl			;79ce   ; Los dos `dec` bajan del +2 del canal al +0: un fotograma de arranque, duracion 1 y el numero, que es lo que marca el canal ocupado
	dec hl			;79cf
	ld (hl),001h		;79d0   ; la cuenta de arranque, a uno
	inc hl			;79d2
	ld (hl),001h		;79d3
	inc hl			;79d5
	ld a,c			;79d6
	ld (hl),a			;79d7
	inc hl			;79d8
	ld a,(de)			;79d9
	ld (hl),a			;79da
	inc hl			;79db
	inc de			;79dc
	ld a,(de)			;79dd
	ld (hl),a			;79de
	ld a,008h		;79df   ; Ocho mas alla del +4 es el +2 del canal siguiente; los flujos de un sonido de varios canales van seguidos en la tabla
	call SUMA_A_HL		;79e1
	inc de			;79e4
	djnz SONIDO_MONTA_CANAL		;79e5   ; tantos canales como diga B
SONIDO_NO:
	ret			;79e7
SONIDO_REPITE:		; El 0xFE: repite el trozo las veces que diga el byte de detras
	inc hl			;79e8
	ld a,(hl)			;79e9
	inc a			;79ea   ; El 0xFF (el `inc a` lo caza) repite siempre; si no, el +9 cuenta las vueltas
	jr z,SONIDO_ENCADENA		;79eb
	inc (ix+009h)		;79ed
	dec a			;79f0
	cp (ix+009h)		;79f1
	jr nz,SONIDO_ENCADENA		;79f4
	xor a			;79f6   ; Cumplidas las vueltas, el +9 a cero y el canal calla
	ld (ix+009h),a		;79f7
	jp CALLA_CANAL		;79fa
SONIDO_ENCADENA:		; Al acabarse un flujo puede arrancar otro
	ld a,(ix+002h)		;79fd   ; Rearrancar es volver a pedir el numero del +2: como empata consigo mismo, la prioridad lo deja pasar
	push bc			;7a00
	call PIDE_SONIDO_SIN_GUARDAR		;7a01
	pop bc			;7a04
	ret			;7a05
SUENA_UN_PASO:		; Un paso del reproductor de sonido: recorre los TRES canales, con diez bytes de estado cada uno desde 0xE010
	ld c,001h		;7a06   ; C = 1: el registro alto del par de periodo del primer canal
	ld ix,0e010h		;7a08   ; IX recorre los tres bloques de estado, de diez en diez bytes
	exx			;7a0c
	ld b,003h		;7a0d
	ld de,0000ah		;7a0f
CANAL_SIGUIENTE:		; Pasa al canal siguiente, diez bytes de estado mas alla
	exx			;7a12
	ld a,(ix+002h)		;7a13   ; El +2 es el numero del sonido: a cero, el canal esta libre y no se toca
	or a			;7a16
	call nz,CANAL_SIGUE		;7a17
	inc c			;7a1a   ; C sube de dos en dos (1, 3, 5): el registro alto de cada canal del PSG
	inc c			;7a1b
	exx			;7a1c
	add ix,de		;7a1d
	djnz CANAL_SIGUIENTE		;7a1f
	exx			;7a21
	ret			;7a22
CANAL_SIGUE:		; Descuenta lo que le queda a la nota del canal y, si se acaba, coge el byte siguiente de su flujo
	jp m,NOTA_DECAE		;7a23   ; El signo del +2 -o sea su bit 7- separa la musica del efecto
	dec (ix+000h)		;7a26   ; El +0 es lo que le queda a la nota; hasta que no llega a cero no se lee nada mas
	ret nz			;7a29
CANAL_LEE_FLUJO:		; Coge el byte siguiente del flujo de este canal
	ld l,(ix+003h)		;7a2a   ; El puntero del flujo vive en el +3 y el +4
	ld h,(ix+004h)		;7a2d
	ld a,(hl)			;7a30
	cp 0feh		;7a31   ; 0xFE repite y 0xFF calla: los dos eventos comunes a musica y efecto
	jr z,SONIDO_REPITE		;7a33
	jr nc,CALLA_CANAL		;7a35
	bit 7,(ix+002h)		;7a37   ; El bit 7 del NUMERO de sonido -no del evento- es lo que manda
	jp nz,VOLUMEN_MIRA_FD		;7a3b
	and 0f0h		;7a3e   ; Un evento 0x2n de efecto trae duracion nueva en el nibble bajo
	cp 020h		;7a40
	jr nz,CANAL_NOTA		;7a42
	ld a,(hl)			;7a44
	and 00fh		;7a45
	ld (ix+001h),a		;7a47
	inc hl			;7a4a
CANAL_NOTA:		; El nibble alto es la nota y el bajo lo que dura
	ld a,(hl)			;7a4b   ; Nibble alto el volumen; el bajo y el byte siguiente, el periodo de 12 bits
	and 0f0h		;7a4c
	ld b,a			;7a4e
	xor (hl)			;7a4f   ; El `xor (hl)` deja el nibble bajo, que es la parte alta del periodo
	ld d,a			;7a50
	inc hl			;7a51
	ld e,(hl)			;7a52
	inc hl			;7a53
	ld (ix+003h),l		;7a54   ; Se apunta por donde va el flujo antes de tocar el PSG
	ld (ix+004h),h		;7a57
	ex de,hl			;7a5a
	call ESCRIBE_PERIODO		;7a5b
	ld a,b			;7a5e   ; Cuatro rotaciones bajan el volumen a su nibble
	rrca			;7a5f
	rrca			;7a60
	rrca			;7a61
	rrca			;7a62
	and 00fh		;7a63
CANAL_ATACA:		; Arranca la nota: recarga su duracion y prepara el decaimiento del volumen
	ld h,a			;7a65
	ld a,(ix+001h)		;7a66   ; La duracion del +1 pasa al +0, que es lo que se descuenta
	ld (ix+000h),a		;7a69
	add a,003h		;7a6c   ; Y el +8 arranca 3 por encima: ese hueco es el decaimiento
	ld (ix+008h),a		;7a6e
	jr ESCRIBE_VOLUMEN		;7a71
CALLA_CANAL:
	xor a			;7a73
	ld (ix+002h),a		;7a74
	ld h,a			;7a77
	jr ESCRIBE_VOLUMEN		;7a78
NOTA_DECAE:		; Mientras dura la nota le va bajando el volumen
	dec (ix+000h)		;7a7a
	jr z,CANAL_LEE_FLUJO		;7a7d
	dec (ix+008h)		;7a7f   ; El +8 arranco 3 por encima del +0; mientras no se igualen baja DOS por vuelta (esta y DECAE_MAS) y el volumen cae un paso
	ld a,(ix+008h)		;7a82
	cp (ix+000h)		;7a85
	jr nz,DECAE_MAS		;7a88
	cp 001h		;7a8a
	jr c,DECAE_VOLUMEN		;7a8c
	ret			;7a8e
DECAE_MAS:
	dec (ix+008h)		;7a8f
DECAE_VOLUMEN:
	ld a,(ix+007h)		;7a92
	dec a			;7a95
	ret m			;7a96
	ld (ix+007h),a		;7a97
	ld h,a			;7a9a
ESCRIBE_VOLUMEN:
	ld a,c			;7a9b   ; La media vuelta convierte C (1, 3, 5) en 0x80, 0x81 y 0x82, y el `add 0x88` los deja en 8, 9 y 10: el bit alto se va por el acarreo
	rrca			;7a9c
	add a,088h		;7a9d
	out (0a0h),a		;7a9f   ; Registro por 0xA0 y valor por 0xA1: el PSG a pelo
	ld a,h			;7aa1
	out (0a1h),a		;7aa2
	ret			;7aa4
VOLUMEN_MIRA_FD:		; El 0xFD del flujo es una orden, no un volumen
	cp 0fdh		;7aa5   ; El 0xFD es el unico evento de control de la musica: cambia octava y volumen de golpe
	jr nz,VOLUMEN_APLICA		;7aa7
	inc hl			;7aa9
	ld a,(hl)			;7aaa
	and 007h		;7aab   ; Los tres bits bajos son la octava, al +5
	ld (ix+005h),a		;7aad
	xor (hl)			;7ab0   ; El `xor (hl)` deja los cinco altos y tres rotaciones los bajan: el volumen de arranque, al +6
	rrca			;7ab1
	rrca			;7ab2
	rrca			;7ab3
	ld (ix+006h),a		;7ab4
	inc hl			;7ab7   ; Y detras del 0xFD viene ya la nota, sin evento propio
	ld a,(hl)			;7ab8
VOLUMEN_APLICA:		; Deja el volumen del canal como diga el flujo
	and 00fh		;7ab9   ; Nibble bajo: la nota, de 0 a 11, y el 12 es el silencio
	ld b,a			;7abb
	xor (hl)			;7abc   ; El `xor (hl)` deja el alto, que es el indice de duracion
	inc hl			;7abd   ; La pista avanza UN byte: una nota de musica ocupa uno solo
	ld (ix+003h),l		;7abe
	ld (ix+004h),h		;7ac1
	rrca			;7ac4   ; Cuatro rotaciones para bajarlo, que la tabla de duraciones es de bytes
	rrca			;7ac5
	rrca			;7ac6
	rrca			;7ac7
	ld hl,07b13h		;7ac8
	call SUMA_A_HL		;7acb
	ld a,(hl)			;7ace
	ld (ix+001h),a		;7acf   ; Restar 12 mira si la nota era el silencio y de paso deja el volumen a CERO, que es justo lo que toca si lo era; si no, se repone del +6
	ld a,b			;7ad2
	sub 00ch		;7ad3
	ld (ix+007h),a		;7ad5
	jr z,VOLUMEN_ATACA		;7ad8
	ld a,(ix+006h)		;7ada
	ld (ix+007h),a		;7add
VOLUMEN_ATACA:		; Arranca la nota y va a por su periodo
	call CANAL_ATACA		;7ae0   ; Primero el volumen y las cuentas; B ha guardado la nota para el periodo
	ld a,b			;7ae3
	ld hl,07b07h		;7ae4
	call SUMA_A_HL		;7ae7
	ld l,(hl)			;7aea
	ld h,000h		;7aeb   ; La tabla de doce periodos, la octava mas aguda
	ld a,(ix+005h)		;7aed
	or a			;7af0   ; La octava del +5 a cero deja el periodo tal cual
	jr z,ESCRIBE_PERIODO		;7af1
	ld b,a			;7af3
PERIODO_DESPLAZA:		; Desplaza el periodo tantas octavas como diga B
	add hl,hl			;7af4   ; Cada doblado del periodo BAJA una octava
	djnz PERIODO_DESPLAZA		;7af5
ESCRIBE_PERIODO:		; Manda al PSG los dos bytes del periodo del canal, por los puertos 0xA0 y 0xA1
	ld a,c			;7af7   ; Primero el registro alto del par (C) y luego el bajo (C-1), los dos por 0xA0/0xA1
	out (0a0h),a		;7af8
	ld a,h			;7afa
	out (0a1h),a		;7afb
	dec c			;7afd   ; El `dec c` baja al registro bajo del par y el `inc c` de abajo lo deja como estaba
	ld a,c			;7afe
	out (0a0h),a		;7aff
	ld a,l			;7b01
	out (0a1h),a		;7b02
	inc c			;7b04
	ret			;7b05

; ----------------------------------------------------------------------
; DATOS byte_suelto: Un 0xFF que no apunta nadie, justo delante de la tabla de
;   notas
;   0x7b06..0x7b07  (1 bytes)
DATA_byte_suelto:
	defb 0ffh	; 7b06

; ----------------------------------------------------------------------
; DATOS tabla_de_notas: Doce periodos, una octava cromatica: la desviacion
;   respecto al temperamento igual es de 0,090 semitonos, y los doce bytes de
;   al lado dan 15,8
;   0x7b07..0x7b13  (12 bytes)
DATA_tabla_de_notas:
	defb 06ah,064h,05fh,059h,054h,050h,04bh,047h,043h,03fh,03ch,038h	; 7b07  jd_YTPKGC?<8

; ----------------------------------------------------------------------
; DATOS tabla_de_duraciones: Las doce duraciones, indexadas por el nibble alto
;   de cada nota. Van de 5 a 100 fotogramas y NO son una escala, aunque esten
;   pegadas a la que si lo es
;   0x7b13..0x7b21  (14 bytes)
DATA_tabla_de_duraciones:
	defb 008h,010h,020h,030h,040h,060h,005h,00ah,00fh,014h,064h,01eh,018h,03ch	; 7b13  .. 0@`....d..<

; ----------------------------------------------------------------------
; DATOS punteros_de_sonido: Veinticuatro punteros a los flujos. Cierra clavada
;   en 0x7B51, que es el primero. El del sonido 0 apunta fuera de la ROM
;   porque no se pide nunca, y los tres ultimos apuntan al 0xFF de 0x7B51: el
;   sonido 0x95, el que llama 0x44BD al arrancar, es un flujo que se acaba en
;   el primer byte, o sea el silencio
;   0x7b21..0x7b51  (48 bytes)
DATA_punteros_de_sonido:
	defw 02850h,07d15h,07cefh,07d4dh,07d55h,07d39h,07d2dh,07d1bh	; 7b21
	defw 07e44h,07cfdh,07b52h,07bd2h,07df1h,07e0eh,07e31h,07ca8h	; 7b31
	defw 07cc6h,07cddh,07d5dh,07d8fh,07dc2h,07b51h,07b51h,07b51h	; 7b41

; ----------------------------------------------------------------------
; DATOS flujos_de_sonido: Los veintiun flujos de musica y efectos
;   0x7b51..0x7e86  (821 bytes)
DATA_flujos_de_sonido:
	defb 0ffh,0fdh,05ah,03bh,0fdh,059h,022h,014h,054h,030h,024h,016h,056h,039h,027h,0fdh	; 7b51  ..Z;.Y".T0$.V9'.
	defb 05ah,01bh,0fdh,059h,032h,020h,0fdh,05ah,01bh,03bh,039h,047h,0fdh,059h,002h,007h	; 7b61  Z..Y2 .Z.;9G.Y..
	defb 004h,007h,002h,007h,004h,007h,002h,007h,004h,007h,002h,007h,004h,007h,012h,006h	; 7b71  ................
	defb 00ch,006h,00ch,012h,006h,00ch,006h,00ch,002h,009h,004h,009h,002h,009h,004h,009h	; 7b81  ................
	defb 002h,009h,004h,009h,012h,007h,00ch,007h,00ch,012h,007h,00ch,007h,00ch,002h,007h	; 7b91  ................
	defb 006h,007h,002h,007h,002h,007h,005h,007h,002h,007h,000h,007h,004h,007h,000h,007h	; 7ba1  ................
	defb 000h,007h,003h,007h,000h,007h,0fdh,05ah,00bh,0fdh,059h,007h,002h,007h,0fdh,05ah	; 7bb1  .......Z..Y....Z
	defb 00bh,0fdh,059h,007h,000h,006h,002h,006h,000h,006h,017h,01ch,016h,017h,02ch,0feh	; 7bc1  ..Y...........,.
	defb 0ffh,0fdh,05bh,017h,0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h,012h,0fdh	; 7bd1  ..[..Z...[..Z...
	defb 05bh,017h,0fdh,05ah,010h,010h,0fdh,05bh,017h,0fdh,05ah,010h,010h,0fdh,05bh,017h	; 7be1  [..Z...[..Z...[.
	defb 0fdh,05ah,014h,014h,0fdh,05bh,017h,0fdh,05ah,014h,014h,0fdh,05bh,016h,0fdh,05ah	; 7bf1  .Z...[..Z...[..Z
	defb 012h,012h,0fdh,05bh,016h,0fdh,05ah,012h,012h,0fdh,05bh,010h,019h,019h,017h,0fdh	; 7c01  ...[..Z...[.....
	defb 05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h	; 7c11  Z...[..Z...[..Z.
	defb 012h,0fdh,05bh,017h,0fdh,05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h,012h,0fdh	; 7c21  ..[..Z...[..Z...
	defb 05bh,017h,0fdh,05ah,012h,0fdh,05bh,01bh,027h,01ch,01bh,0fdh,05ah,012h,012h,0fdh	; 7c31  [..Z..[.'...Z...
	defb 05bh,01bh,0fdh,05ah,012h,012h,0fdh,05bh,016h,0fdh,05ah,012h,012h,0fdh,05bh,016h	; 7c41  [..Z...[..Z...[.
	defb 0fdh,05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah	; 7c51  .Z...[..Z...[..Z
	defb 012h,012h,0fdh,05bh,017h,0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h,012h	; 7c61  ...[..Z...[..Z..
	defb 0fdh,05bh,012h,017h,01bh,017h,01bh,0fdh,05ah,012h,0fdh,05bh,017h,0fdh,05ah,010h	; 7c71  .[......Z..[..Z.
	defb 014h,0fdh,05bh,017h,0fdh,05ah,010h,014h,0fdh,05bh,017h,0fdh,05ah,012h,01ch,0fdh	; 7c81  ..[..Z...[..Z...
	defb 05bh,019h,0fdh,05ah,012h,01ch,012h,01ch,0fdh,05bh,01bh,0fdh,05ah,002h,000h,0fdh	; 7c91  [..Z.....[..Z...
	defb 05bh,00bh,009h,007h,00ch,0feh,0ffh,0fdh,059h,090h,080h,060h,090h,0fdh,05ah,08bh	; 7ca1  [.......Y..`..Z.
	defb 069h,097h,094h,097h,094h,072h,074h,075h,077h,079h,077h,079h,07bh,0fdh,061h,090h	; 7cb1  i....rtuwywy{.a.
	defb 080h,060h,090h,0ffh,0ffh,0fdh,05bh,097h,097h,097h,09ch,097h,097h,097h,09ch,095h	; 7cc1  .`....[.........
	defb 092h,097h,0fdh,05ch,097h,0fdh,063h,090h,097h,097h,0ffh,0ffh,0fdh,05bh,090h,090h	; 7cd1  ...\..c......[..
	defb 090h,09ch,090h,090h,090h,09ch,0ach,0fdh,05ah,084h,064h,094h,0ffh,0ffh,022h,0d0h	; 7ce1  ........Z.d...".
	defb 07fh,0b0h,070h,0b0h,077h,0a0h,062h,090h,050h,080h,043h,0ffh,023h,090h,060h,090h	; 7cf1  ..p.w.b.P.C.#.`.
	defb 040h,090h,060h,090h,040h,090h,060h,090h,040h,090h,060h,090h,040h,090h,060h,090h	; 7d01  @.`.@.`.@.`.@.`.
	defb 040h,090h,060h,0ffh,021h,0a0h,025h,0a0h,027h,0ffh,021h,0c0h,0ddh,0c0h,0bbh,0b0h	; 7d11  @.`.!.%.'.!.....
	defb 0aah,0b0h,099h,0a0h,088h,0a0h,077h,090h,066h,090h,055h,0ffh,022h,0c0h,055h,0c0h	; 7d21  ......w.f.U.".U.
	defb 066h,0c0h,055h,0b0h,044h,0a0h,033h,0ffh,022h,0e0h,0a5h,0c0h,0b5h,0a0h,0c5h,090h	; 7d31  f.U.D.3.".......
	defb 0d5h,080h,0e5h,070h,0f5h,061h,005h,051h,025h,051h,045h,0ffh,021h,0c1h,003h,0c1h	; 7d41  ...p.a.Q%QE.!...
	defb 00dh,0c1h,006h,0ffh,021h,0c1h,043h,0c1h,04dh,0c1h,046h,0ffh,0fdh,05ah,07bh,0fdh	; 7d51  ....!.C.M.F..Z{.
	defb 059h,072h,074h,072h,097h,076h,074h,0b2h,0fdh,05ah,07bh,097h,067h,069h,06bh,0fdh	; 7d61  Yrtr.vt..Z{.gik.
	defb 059h,060h,0fdh,05ah,07bh,0fdh,059h,072h,074h,072h,097h,076h,074h,062h,064h,062h	; 7d71  Y`.Z{.Yrtr.vtbdb
	defb 060h,0fdh,05ah,06bh,0fdh,059h,060h,0fdh,05ah,06bh,069h,097h,09ch,0ffh,0fdh,05ah	; 7d81  `.Zk.Y`.Zki....Z
	defb 077h,07bh,0fdh,059h,070h,0fdh,05ah,07bh,0fdh,059h,092h,070h,070h,0fdh,05ah,0bbh	; 7d91  w{.Yp.Z{.Y.pp.Z.
	defb 077h,092h,09ch,077h,07bh,0fdh,059h,070h,0fdh,05ah,07bh,0fdh,059h,092h,070h,070h	; 7da1  w..w{.Yp.Z{.Y.pp
	defb 0fdh,05ah,06bh,0fdh,059h,060h,0fdh,05ah,06bh,069h,067h,069h,067h,066h,092h,09ch	; 7db1  .Zk.Y`.Zkigigf..
	defb 0ffh,0fdh,05bh,077h,076h,074h,072h,070h,0fdh,05ch,07bh,079h,077h,0fdh,05bh,077h	; 7dc1  ..[wvtrp.\{yw.[w
	defb 076h,074h,072h,070h,0fdh,05ch,07bh,079h,077h,0fdh,05bh,077h,076h,074h,072h,070h	; 7dd1  vtrp.\{yw.[wvtrp
	defb 0fdh,05ch,07bh,079h,077h,0fdh,05bh,072h,0fdh,05ch,072h,074h,076h,077h,09ch,0ffh	; 7de1  .\{yw.[r.\rtvw..
	defb 0fdh,059h,094h,074h,074h,094h,072h,070h,0b5h,0fdh,05ah,075h,0b5h,0fdh,059h,075h	; 7df1  .Y.tt.rp..Zu..Yu
	defb 094h,070h,074h,092h,0fdh,05ah,079h,07bh,0fdh,059h,0d0h,01ch,0ffh,0fdh,05bh,090h	; 7e01  .pt..Zy{.Y....[.
	defb 070h,070h,090h,0fdh,05ah,07bh,077h,0fdh,059h,0b0h,0fdh,05ah,070h,0b0h,0fdh,059h	; 7e11  pp..Z{w.Y..Zp..Y
	defb 070h,090h,0fdh,05ah,077h,0fdh,059h,070h,0fdh,05ah,09bh,075h,077h,0d7h,01ch,0ffh	; 7e21  p..Zw.Yp.Z.uw...
	defb 0fdh,05bh,097h,094h,097h,094h,099h,095h,099h,095h,097h,094h,097h,095h,097h,097h	; 7e31  .[..............
	defb 097h,09ch,0ffh,022h,0d1h,0eeh,0d1h,0cch,0c1h,0eeh,0b1h,0ffh,0a1h,099h,091h,088h	; 7e41  ..."............
	defb 081h,077h,071h,066h,061h,077h,051h,088h,041h,099h,0ffh,021h,000h,0e0h,001h,000h	; 7e51  .wqfawQ.A..!....
	defb 008h,0f3h,0cdh,0c7h,048h,0dbh,098h,077h,023h,00bh,078h,0b1h,020h,0f7h,0fbh,018h	; 7e61  ....H..w#.x. ...
	defb 0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7e71  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh	; 7e81

; ----------------------------------------------------------------------
; DATOS relleno_final: Lo que sobra del cartucho hasta los 16 KB: 378 bytes,
;   todos 0xFF, sin una sola excepcion
;   0x7e86..0x8000  (378 bytes)
DATA_relleno_final:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7e86  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7e96  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ea6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7eb6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ec6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ed6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ee6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ef6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f06  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f16  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f26  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f36  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f46  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f56  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f66  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f76  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f86  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f96  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fa6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fb6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fc6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fd6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fe6  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ff6  ..........
