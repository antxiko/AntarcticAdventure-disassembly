; ==========================================================================
; ANTARCTIC ADVENTURE - Konami (1984) - MSX1 - cartucho de 16 KB
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x04000


; ----------------------------------------------------------------------
; DATOS cabecera_del_cartucho: La cabecera que lee la BIOS: "AB", INIT=0x4010, y a cero los otros tres vectores (STATEMENT, DEVICE y TEXT). Con eso la BIOS llama a 0x4010 nada mas terminar de arrancar la maquina
;   0x4000..0x4010  (16 bytes)
; ----------------------------------------------------------------------
	defb 041h,042h,010h,040h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 4000  AB.@............

; ======================================================================
; CODIGO 0x4010..0x411f  (271 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; INIT - lo primero que se ejecuta del cartucho
; ############################################################
; La BIOS llega aqui con la maquina ya inicializada. Este INIT
; no vuelve nunca: se queda dando vueltas en 0x405B y a partir
; de ahi TODO el juego corre dentro de la interrupcion.
; ----------------------------------------------------------------------
INIT:		; Punto de entrada del cartucho, declarado en la cabecera
	di			;4010
	im 1			;4011
	ld hl,0fd00h		;4013   ; Rellena de RET los 512 bytes de hooks de la BIOS (0xFD00-0xFEFF)
	ld de,0fd01h		;4016
	ld bc,00200h		;4019
	ld (hl),0c9h		;401c
	ldir			;401e
	ld a,0c3h		;4020   ; Pone un JP en el hook de interrupcion H.TIMI (0xFD9A)
	ld (0fd9ah),a		;4022
	ld hl,H_TIMI		;4025   ; ...y lo apunta a la rutina de abajo: desde aqui el juego es la interrupcion
	ld (0fd9bh),hl		;4028
	ld sp,0e400h		;402b   ; Pila en 0xE400, justo debajo de las variables
	ld hl,0e000h		;402e   ; Borra los 2 KB de 0xE000-0xE7FF, que es donde vive todo el estado
	ld de,0e001h		;4031
	ld bc,007ffh		;4034
	ld (hl),000h		;4037
	ldir			;4039
	ld a,001h		;403b   ; Estado 1: arranca. El cerrojo de 0xE005 se pone para que la interrupcion no entre todavia
	ld (0e005h),a		;403d
	call ARRANCA_MAQUINA		;4040   ; Registros del VDP, PSG y VRAM a cero
	di			;4043
	xor a			;4044
	ld (0e005h),a		;4045
	inc a			;4048
	ld (0e000h),a		;4049   ; Estado 1 en 0xE000; ya puede empezar la maquina de estados

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; ESTOS CUATRO SON UN LDIR CONTRA LA PROPIA ROM
; ----------------------------------------------------------------------
; Copia los tres bytes de 0x411F -que son C3 00 00, o sea
; `jp 0000h`- encima de 0x40B2, que es el despachador de aqui
; abajo. En un cartucho eso no hace nada: la pagina 1 es ROM y
; la escritura se pierde. Pero si el cartucho estuviera copiado
; en RAM, el despachador quedaria convertido en un salto a 0 y
; la maquina se reiniciaria en el primer fotograma, porque
; 0x4122 lo llama enseguida.
; Que hace: comprobado leyendo los bytes. Para que: es una
; proteccion contra copias en RAM (?), no se puede demostrar
; desde el binario.
; ----------------------------------------------------------------------
	ld hl,0411fh		;404c   ; Origen: los tres bytes `jp 0000h` de 0x411F
	ld de,DESPACHA		;404f   ; Destino: 0x40B2, el despachador. Es ROM, asi que no pasa nada
	ld bc,00003h		;4052
	ldir			;4055
	call 0013eh		;4057   ; BIOS RDVDP - Reads VDP status register | Lee el registro de estado del VDP para descartar la interrupcion pendiente
	ei			;405a
PARADO:		; INIT acaba aqui: bucle vacio. El juego entero corre en la interrupcion
	jr PARADO		;405b

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
	push af			;405d
	push bc			;405e
	push de			;405f
	push hl			;4060
	di			;4061
	call 0013eh		;4062   ; BIOS RDVDP - Reads VDP status register | Descarta la interrupcion leyendo el estado del VDP
	ld a,(0e000h)		;4065   ; Con el estado a 0 no suena nada
	or a			;4068
	jr z,HT_TRAS_SONIDO		;4069
	call ATIENDE_SONIDO		;406b   ; El reproductor de sonido, que por eso va siempre a compas
HT_TRAS_SONIDO:		; Del estado 12 en adelante (fin de partida) ya no se mueve nada
	ld a,(0e000h)		;406e
	cp 00ch			;4071
	jr nc,HT_CERROJO		;4073
	ld a,(0e140h)		;4075   ; Suma el sentido de marcha y el empuje: si dan cero, el pinguino esta quieto
	ld hl,0e142h		;4078
	add a,(hl)		;407b
	jr nz,HT_MUEVE		;407c
	call ANIMA_ANDAR		;407e   ; Rutina de estar parado
HT_MUEVE:		; Mueve al pinguino y descuenta el tiempo
	call CUENTA_EL_TIEMPO		;4081
	ld a,(0e081h)		;4084   ; Bit 7 de 0xE081: el signo de la velocidad lateral
	bit 7,a			;4087
	ld a,000h		;4089
	jr z,HT_SENTIDO		;408b
	inc a			;408d
HT_SENTIDO:
	ld (0e0fch),a		;408e   ; 0xE0FC queda a 0 o 1 segun hacia donde mira
HT_CERROJO:		; Cerrojo de reentrada: 0xE005 dice si ya hay una vuelta dentro
	ld hl,0e005h		;4091
	bit 0,(hl)		;4094
	jr nz,HT_YA_DENTRO		;4096
	ld (hl),001h		;4098   ; Echa el cerrojo y abre las interrupciones: el paso puede durar mas de un fotograma
	ei			;409a
	call LEE_MANDOS		;409b   ; Lee los mandos
	call PASO_DE_JUEGO		;409e   ; Un paso de la maquina de estados
	di			;40a1
	pop hl			;40a2
	pop de			;40a3
	pop bc			;40a4
	xor a			;40a5
	ld (0e005h),a		;40a6   ; Quita el cerrojo
	pop af			;40a9
	ei			;40aa
	ret			;40ab
HT_YA_DENTRO:		; Salida cuando la vuelta anterior sigue trabajando: este fotograma se pierde
	pop hl			;40ac
	pop de			;40ad
	pop bc			;40ae
	pop af			;40af
	ei			;40b0
	ret			;40b1

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
	add a,a			;40b2
	pop hl			;40b3   ; La direccion de retorno es la tabla
	call SUMA_A_HL		;40b4
	ld e,(hl)		;40b7
	inc hl			;40b8
	ld d,(hl)		;40b9
	ex de,hl		;40ba
	jp (hl)			;40bb

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LOS MANDOS
; ----------------------------------------------------------------------
; Tres fuentes distintas segun 0xE002:
; bit 6 a 0  -> no hay partida: los mandos se leen de una
; GRABACION que va en la propia ROM (la demo)
; bit 4 a 1  -> teclado, leyendo la matriz
; bit 4 a 0  -> joystick, por el registro 14 del PSG
; Las tres acaban en 0x40D5, que guarda la lectura de este
; fotograma en 0xE009 y la del anterior en 0xE008.
; ----------------------------------------------------------------------
LEE_MANDOS:		; Deja en 0xE009 lo pulsado ahora y en 0xE008 lo de antes
	ld a,(0e000h)		;40bc
	cp 007h			;40bf   ; Antes del estado 7 (la demo) no se lee nada
	ret c			;40c1
	ld a,(0e002h)		;40c2
	bit 6,a			;40c5
	jr z,LEE_MANDOS_GRABADOS		;40c7
	bit 4,a			;40c9
	jr nz,LEE_TECLADO		;40cb
	ld a,00eh		;40cd
	call 00096h		;40cf   ; BIOS RDPSG - Reads value from PSG-register | Registro 14 del PSG: el puerto del joystick
	cpl			;40d2
	and 03fh		;40d3   ; Bits 0-3 direcciones, 4 y 5 gatillos, en logica positiva
GUARDA_MANDOS:		; 0xE009 = ahora, 0xE008 = el fotograma anterior
	ld hl,0e009h		;40d5
	ld c,(hl)		;40d8
	ld (hl),a		;40d9
	dec hl			;40da
	ld (hl),c		;40db
	ret			;40dc
LEE_TECLADO:		; Monta con las filas 7 y 8 de la matriz el mismo mapa de bits que el joystick
	ld a,007h		;40dd
	call 00141h		;40df   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix | Fila 7: flechas arriba y ...
	cpl			;40e2
	rrca			;40e3
	and 020h		;40e4
	ld e,a			;40e6
	ld a,008h		;40e7
	call 00141h		;40e9   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix | Fila 8: el resto de flechas y la barra espaciadora
	cpl			;40ec
	rrca			;40ed
	rrca			;40ee
	ld b,a			;40ef
	and 004h		;40f0
	or e			;40f2
	ld c,a			;40f3
	ld a,b			;40f4
	rrca			;40f5
	rrca			;40f6
	ld b,a			;40f7
	and 018h		;40f8
	or c			;40fa
	ld c,a			;40fb
	ld a,b			;40fc
	rrca			;40fd
	and 003h		;40fe
	or c			;4100
	jr GUARDA_MANDOS		;4101

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LA DEMO SE JUEGA SOLA CON UNA GRABACION
; ----------------------------------------------------------------------
; 0xE0EC apunta a una tira de bytes de la ROM (empieza en
; 0x584A, ver 0x41AC). Cada 32 fotogramas coge el siguiente y
; lo usa de "lo pulsado"; entre medias repite el nibble bajo de
; la lectura anterior. O sea que la partida de demostracion no
; la juega ninguna inteligencia: va grabada.
; ----------------------------------------------------------------------
LEE_MANDOS_GRABADOS:		; Los mandos de la demo, leidos de la ROM
	ld de,(0e0ech)		;4103
	ld hl,0e0ebh		;4107
	inc (hl)		;410a   ; 0xE0EB es el contador; solo cada 32 fotogramas se avanza
	ld a,(hl)		;410b
	and 01fh		;410c
	jr nz,REPITE_MANDO		;410e
	ld a,(de)		;4110
	inc de			;4111
	ld (0e0ech),de		;4112
	jr GUARDA_MANDOS		;4116
REPITE_MANDO:		; Entre byte y byte se mantiene la direccion anterior
	ld a,(0e009h)		;4118
	and 00fh		;411b
	jr GUARDA_MANDOS		;411d

; ----------------------------------------------------------------------
; DATOS tres_bytes_jp_cero: Los tres bytes C3 00 00 que INIT copia encima del despachador. Ver la nota de 0x404C
;   0x411f..0x4122  (3 bytes)
; ----------------------------------------------------------------------
	defb 0c3h,000h,000h	; 411f  ...

; ======================================================================
; CODIGO 0x4122..0x412f  (13 bytes)
; ======================================================================


PASO_DE_JUEGO:		; Un paso de la maquina de estados: cuenta el fotograma y despacha por 0xE000
	ld hl,0e003h		;4122   ; 0xE003 es el contador de fotogramas, y se usa de reloj por todo el juego
	inc (hl)		;4125
	call MIRA_TECLAS_1_2		;4126   ; Mira si se ha pulsado 1 o 2 para empezar la partida
	ld a,(0e000h)		;4129
	call DESPACHA		;412c

; ----------------------------------------------------------------------
; DATOS tabla_de_estados: Los DIECISEIS destinos de la maquina de estados, indexados por 0xE000. Va incrustada detras del CALL de 0x412C y acaba justo donde empieza su primer destino, que es lo que fija su tamano
;   0x412f..0x414f  (32 bytes)
; ----------------------------------------------------------------------
	defb 04fh,041h,050h,041h,066h,041h,078h,041h,083h,041h,091h,041h,099h,041h,0a0h,041h	; 412f  OAPAfAxA.A.A.A.A
	defb 0efh,041h,05bh,042h,09dh,042h,0b6h,042h,0dch,042h,001h,043h,012h,043h,008h,049h	; 413f  .A[B.B.B.B.C.C.I

; ======================================================================
; CODIGO 0x414f..0x41a6  (87 bytes)
; ======================================================================


ESTADO_00_PARADO:		; Estado 0: no hace nada. Es el que deja INIT hasta que se pone el 1
	ret			;414f
ESTADO_01_ARRANCA:		; Estado 1: prepara la pantalla de presentacion
	call MONTA_LA_FUENTE		;4150
	ld a,00eh		;4153   ; 0xE00A: catorce filas para que suba el logotipo
	ld (0e00ah),a		;4155
	ld hl,00000h		;4158
	ld (0e00eh),hl		;415b
	ld b,0e4h		;415e   ; Registro 7 del VDP: fondo y borde en 0xE4
	call PONE_REGISTRO_7		;4160
	jp SIGUIENTE_ESTADO		;4163
ESTADO_02_LOGO:		; Estado 2: sube el logotipo una fila cada dos fotogramas, y al llegar descomprime la pantalla de titulo
	ld a,(0e003h)		;4166
	rra			;4169   ; Un fotograma si y otro no
	ret nc			;416a
	call SUBE_LOGO		;416b
	ret nz			;416e
	ld hl,05839h		;416f   ; Los datos comprimidos de la pantalla de titulo
	call DESCOMPRIME		;4172
	jp ESPERA_80_Y_ESTADO		;4175
ESTADO_03_ESPERA:		; Estado 3: espera a que 0xE004 llegue a cero y prepara el rotulo
	ld hl,0e004h		;4178
	dec (hl)		;417b
	ret nz			;417c
	call PREPARA_ROTULO		;417d
	jp ESPERA_A_Y_ESTADO		;4180
ESTADO_04_ROTULO:		; Estado 4: dibuja el rotulo columna a columna; mientras dibuja, vuelve con acarreo
	call DIBUJA_ROTULO		;4183
	ret c			;4186
	ld hl,057eeh		;4187   ; "PLAY SELECT", "1 JOYSTICK" y "2 KEYBOARD"
	call ESCRIBE_CADENA		;418a
	xor a			;418d
	jp ESPERA_A_Y_ESTADO		;418e
ESTADO_05_ESPERA:		; Estado 5: otra espera de 0xE004 fotogramas
	ld hl,0e004h		;4191
	dec (hl)		;4194
	ret nz			;4195
	jp ESPERA_80_Y_ESTADO		;4196
ESTADO_06_CORTINILLA:		; Estado 6: borra la pantalla por columnas; sale cuando la cortinilla vuelve negativa
	call CORTINILLA		;4199
	ret p			;419c
	jp SIGUIENTE_ESTADO		;419d

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; ESTADO 7 - LA DEMO
; ----------------------------------------------------------------------
; Juega una partida entera con los mandos grabados de 0x584A y
; sin sumar puntos (0x462D se sale si el bit 6 de 0xE002 esta a
; cero). Dura 0x073C = 1852 pasos, y al acabar vuelve al titulo.
; ----------------------------------------------------------------------
ESTADO_07_DEMO:		; Estado 7: la partida de demostracion, en tres pasos
	ld a,(0e001h)		;41a0
	call DESPACHA		;41a3

; ----------------------------------------------------------------------
; DATOS tabla_demo: Los TRES pasos del estado 7, del CALL de 0x41A3
;   0x41a6..0x41ac  (6 bytes)
; ----------------------------------------------------------------------
	defb 0ach,041h,0c3h,041h,0e4h,041h	; 41a6  .A.A.A

; ======================================================================
; CODIGO 0x41ac..0x41f5  (73 bytes)
; ======================================================================


DEMO_0_ARRANCA:		; Paso 0: pone a cero la partida y arranca la grabacion
	call REINICIA_PARTIDA		;41ac
	ld hl,0e002h		;41af
	res 6,(hl)		;41b2   ; Bit 6 a cero: no hay partida de verdad, asi que no se puntua
	ld hl,0073ch		;41b4   ; 1852 pasos de demostracion
	ld (0e0eeh),hl		;41b7
	ld hl,0584ah		;41ba   ; Aqui empieza la tira de mandos grabados
	ld (0e0ech),hl		;41bd
	jp ESTADO_09_PREPARA		;41c0   ; Y a partir de aqui, como una fase normal
DEMO_1_CORRE:		; Paso 1: mientras corre la demo, escribe el aviso y descuenta
	ld hl,057e1h		;41c3   ; El texto de 0x57DF pero en otro sitio: aqui empieza el cuerpo, sin la palabra de destino
	ld de,038cah		;41c6
	call ESCRIBE_CADENA_EN_DE		;41c9
	ld a,001h		;41cc
	ld (0e133h),a		;41ce   ; 0xE133: el reloj de la fase corre
	call PASO_DE_PARTIDA		;41d1   ; Un paso de partida
	ld hl,(0e0eeh)		;41d4
	dec hl			;41d7
	ld (0e0eeh),hl		;41d8
	ld a,h			;41db
	or l			;41dc
	ret nz			;41dd
	ld (0e133h),a		;41de
	jp ESPERA_80_Y_PASO		;41e1
DEMO_2_SALE:		; Paso 2: cortinilla, y vuelta al estado 0
	call CORTINILLA		;41e4
	ret p			;41e7
	xor a			;41e8
	ld (0e000h),a		;41e9
	jp SIGUIENTE_ESTADO		;41ec

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; ESTADO 8 - EL MENU
; ----------------------------------------------------------------------
; Pinta "PLAY SELECT" con las dos opciones y hace parpadear seis
; veces la que se ha elegido con la tecla 1 o la 2. Quien elige
; de verdad es 0x4433, que corre en cada fotograma.
; ----------------------------------------------------------------------
ESTADO_08_MENU:		; Estado 8: el menu de eleccion de mando, en cuatro pasos
	ld a,(0e001h)		;41ef
	call DESPACHA		;41f2

; ----------------------------------------------------------------------
; DATOS tabla_menu: Los CUATRO pasos del estado 8, del CALL de 0x41F2
;   0x41f5..0x41fd  (8 bytes)
; ----------------------------------------------------------------------
	defb 0fdh,041h,00eh,042h,021h,042h,051h,042h	; 41f5  .A.B!BQB

; ======================================================================
; CODIGO 0x41fd..0x4318  (283 bytes)
; ======================================================================


MENU_0_PINTA:		; Paso 0: limpia y prepara el rotulo
	call BORRA_SPRITES		;41fd
	call BORRA_NOMBRES		;4200
	call PREPARA_ROTULO		;4203
	ld a,092h		;4206
	call PIDE_SONIDO		;4208   ; Sonido 0x92
	jp SIGUIENTE_PASO		;420b
MENU_1_ROTULO:		; Paso 1: dibuja el rotulo entero de una vez, sin repartirlo por fotogramas
	call DIBUJA_ROTULO		;420e
	jr c,MENU_1_ROTULO		;4211
	ld hl,057eeh		;4213
	call ESCRIBE_CADENA		;4216
	ld a,006h		;4219
	ld (0e18dh),a		;421b   ; Seis parpadeos
	jp SIGUIENTE_PASO		;421e
MENU_2_PARPADEA:		; Paso 2: parpadea la linea elegida, ocho fotogramas encendida y ocho apagada
	ld hl,0e003h		;4221
	ld a,(hl)		;4224
	and 007h		;4225
	ret nz			;4227
	ld a,(hl)		;4228
	bit 3,a			;4229
	jr nz,MENU_2_ENCIENDE		;422b
	ld de,03a00h		;422d
	ld bc,00020h		;4230
	ld a,(0e002h)		;4233   ; Bit 4 de 0xE002: 0 joystick (fila 16), 1 teclado (fila 18)
	and 010h		;4236
	rlca			;4238
	rlca			;4239
	call SUMA_A_DE		;423a   ; Suma 0x00 o 0x40 al destino, o sea dos filas
	ld a,001h		;423d
	call RELLENA_VRAM		;423f
	ret			;4242
MENU_2_ENCIENDE:		; La otra mitad del parpadeo: repinta el texto
	ld hl,057eeh		;4243
	call ESCRIBE_CADENA		;4246
	ld hl,0e18dh		;4249
	dec (hl)		;424c
	ret nz			;424d
	jp ESPERA_80_Y_PASO		;424e
MENU_3_CORTINILLA:		; Paso 3: cortinilla y a empezar la partida
	call CORTINILLA		;4251
	ret p			;4254
	call REINICIA_PARTIDA		;4255
	jp SIGUIENTE_ESTADO		;4258
ESTADO_09_PREPARA:		; Estado 9: saca de la tabla la distancia y el tiempo de la fase que toca
	ld a,(0e0e8h)		;425b   ; 0xE0E8: la fase dentro del recorrido, 0-9
	ld hl,04ad9h		;425e
	add a,a			;4261   ; Cuatro bytes por fase
	add a,a			;4262
	call SUMA_A_HL		;4263
	ld e,(hl)		;4266
	inc hl			;4267
	ld d,(hl)		;4268
	inc hl			;4269
	ld (0e0e6h),de		;426a   ; Centenas de metros y posicion en el mapa
	ld e,(hl)		;426e
	inc hl			;426f
	ld d,(hl)		;4270
	ld a,(0e0e1h)		;4271   ; Al tiempo de la fase se le resta lo que sobro de esa misma fase la vuelta anterior
	ld hl,0e0d5h		;4274
	call SUMA_A_HL		;4277
	ld a,(hl)		;427a
	sub 010h		;427b   ; Menos de 0x10 guardado: no se descuenta nada
	jr c,PREPARA_TIEMPO		;427d
	daa			;427f
	ld c,a			;4280
	ld a,e			;4281
	sub c			;4282
	jr nc,PREPARA_AJUSTA		;4283
	daa			;4285
	dec d			;4286
	jr PREPARA_GUARDA		;4287
PREPARA_AJUSTA:
	daa			;4289
PREPARA_GUARDA:
	ld e,a			;428a
PREPARA_TIEMPO:
	ld (0e0e3h),de		;428b   ; El tiempo de la fase, en BCD
	call PINTA_PANEL		;428f
	call MONTA_LA_FUENTE		;4292
	ld a,00eh		;4295   ; Estado 14 y el avance de abajo lo deja en 15: primero el mapa
	ld (0e000h),a		;4297
	jp ESPERA_80_Y_ESTADO		;429a
ESTADO_10_ENTRA:		; Estado 10: cortinilla, monta la pista y suena la musica de salida
	call CORTINILLA		;429d
	ret p			;42a0
	call MONTA_LA_FASE		;42a1
	ld a,(0e002h)		;42a4
	bit 6,a			;42a7   ; En la demo no suena
	ld a,08ah		;42a9
	call nz,PIDE_SONIDO		;42ab
	ld a,001h		;42ae
	ld (0e133h),a		;42b0
	jp SIGUIENTE_ESTADO		;42b3
ESTADO_11_PARTIDA:		; Estado 11: la partida. Un paso de juego por fotograma hasta que se acaba el tiempo o se llega a la meta
	ld a,(0e002h)		;42b6
	bit 6,a			;42b9
	jr z,PARTIDA_ERA_DEMO		;42bb
	call PASO_DE_PARTIDA		;42bd   ; Un paso de partida
	ld hl,(0e00ch)		;42c0   ; 0xE00C: se acabo el tiempo. 0xE00D: se ha llegado a la meta
	ld a,l			;42c3
	add a,h			;42c4
	ret z			;42c5
	ld a,l			;42c6
	ld hl,0e133h		;42c7
	ld (hl),000h		;42ca
	or a			;42cc
	ld a,00ch		;42cd   ; Estado 12, se acabo el tiempo
	jr nz,PARTIDA_CAMBIA		;42cf
	ld a,00eh		;42d1   ; Estado 14, meta
PARTIDA_CAMBIA:
	ld (0e000h),a		;42d3
	ret			;42d6
PARTIDA_ERA_DEMO:		; Si no habia partida de verdad, vuelve al paso 1 de la demo
	ld hl,00107h		;42d7
	jr PONE_ESTADO		;42da
ESTADO_12_TIME_OUT:		; Estado 12: se acabo el tiempo
	xor a			;42dc
	ld (0e00ch),a		;42dd
	ld hl,0e0b8h		;42e0   ; Aparca las cuatro nubes fuera de la pantalla
	ld de,00004h		;42e3
	ld b,004h		;42e6
TIME_OUT_SPRITES:
	ld (hl),0e0h		;42e8
	add hl,de		;42ea
	djnz TIME_OUT_SPRITES		;42eb
	call VUELCA_ATRIBUTOS		;42ed
	ld (0e0e2h),a		;42f0
	ld a,08ch		;42f3
	call PIDE_SONIDO		;42f5   ; Sonido 0x8C
	ld hl,0582eh		;42f8   ; El rotulo "TIME OUT"
	call ESCRIBE_CADENA		;42fb
	jp ESPERA_80_Y_ESTADO		;42fe
ESTADO_13_FIN:		; Estado 13: espera a que acabe la musica y vuelve a la demo
	ld a,(0e012h)		;4301   ; 0xE012 lo pone a cero el reproductor cuando termina
	or a			;4304
	ret nz			;4305
	ld hl,0e002h		;4306
	res 6,(hl)		;4309   ; Se acabo la partida: a partir de aqui los mandos vuelven a ser los grabados
	ld hl,00207h		;430b   ; Estado 7, paso 2
PONE_ESTADO:		; Estado en L y paso en H, de una sentada
	ld (0e000h),hl		;430e
	ret			;4311

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; ESTADO 14 - LA META
; ----------------------------------------------------------------------
; Llegada a la base: la animacion, el cambio de fase, el bonus
; por el tiempo que ha sobrado y la cortinilla para la siguiente.
; ----------------------------------------------------------------------
ESTADO_14_META:		; Estado 14: la llegada a la base, en ocho pasos
	ld a,(0e001h)		;4312
	call DESPACHA		;4315

; ----------------------------------------------------------------------
; DATOS tabla_meta: Los OCHO pasos del estado 14, del CALL de 0x4315
;   0x4318..0x4328  (16 bytes)
; ----------------------------------------------------------------------
	defb 028h,043h,03bh,043h,07bh,043h,089h,043h,0a6h,043h,0d0h,043h,0d9h,043h,000h,044h	; 4318  (C;C{C.C.C.C.C.D

; ======================================================================
; CODIGO 0x4328..0x4491  (361 bytes)
; ======================================================================


META_0_FRENA:		; Paso 0: espera a que el pinguino termine de frenar
	ld hl,0e0f9h		;4328
	ld a,(hl)		;432b
	or a			;432c
	jp z,SIGUIENTE_PASO		;432d
	call SIGUE_SALTO		;4330
	ld a,(0e0f9h)		;4333
	or a			;4336
	ret nz			;4337
	jp SIGUIENTE_PASO		;4338
META_1_SIGUIENTE:		; Paso 1: sube el numero de fase y guarda el tiempo que ha sobrado. Son DOS contadores distintos y conviene no mezclarlos: 0xE0E0 es el numero que se ve en el panel, en BCD y SIN TOPE -sigue subiendo a 11, 12...-, y 0xE0E1 es el indice 0-9 de la base, que DA LA VUELTA al llegar a diez. Esa pareja es la vuelta completa: el juego arranca con 0xE0E1 = 0, que es FRANCE (los valores iniciales estan en 0x4491), y cada llegada lo sube UNO, asi que se va de una base a la siguiente hasta que en la decima se vuelve al 0 y se cierra el circuito en Francia. Como el numero del panel no se reinicia, la vuelta siguiente son las mismas diez bases pero mas dificiles, que es lo que mira 0x76F7
	ld hl,0e0e0h		;433b
	ld a,(hl)		;433e
	add a,001h		;433f   ; El numero que se ve, en BCD
	daa			;4341
	ld (hl),a		;4342
	inc hl			;4343
	ld a,(hl)		;4344   ; Y el indice 0-9, que da la vuelta al llegar a diez
	ld c,a			;4345
	inc a			;4346
	cp 00ah			;4347
	jr c,META_1_GUARDA		;4349
	xor a			;434b
	ld (0e0e2h),a		;434c
META_1_GUARDA:
	ld (hl),a		;434f
	ld a,c			;4350
	ld hl,0e0d5h		;4351   ; Lo que sobro de tiempo se guarda en 0xE0D5+fase y se descuenta la proxima vuelta
	call SUMA_A_HL		;4354
	ld a,(0e0e3h)		;4357
	ld (hl),a		;435a
	xor a			;435b
	ld (0e00dh),a		;435c
	ld hl,0e0e8h		;435f   ; La casilla del mapa tambien avanza y da la vuelta
	inc (hl)		;4362
	ld a,(hl)		;4363
	cp 00ah			;4364
	jr nz,META_1_ANIMA		;4366
	ld (hl),000h		;4368
META_1_ANIMA:
	ld a,(0e079h)		;436a
	ld h,a			;436d
	ld l,001h		;436e
	ld (0e138h),hl		;4370
	ld a,013h		;4373
	ld (0e100h),a		;4375   ; Velocidad 0x13 para la animacion
	jp SIGUIENTE_PASO		;4378
META_2_ANDA:		; Paso 2: el pinguino sigue andando hasta la bandera
	ld c,0ffh		;437b
	call ANDA_HASTA_LA_BASE		;437d
	ret nz			;4380
	ld a,00ch		;4381
	ld (0e138h),a		;4383
	jp SIGUIENTE_PASO		;4386
META_3_LLEGA:		; Paso 3: llega, se monta el decorado de la base y suena la musica
	ld c,000h		;4389
	ld a,(0e079h)		;438b
	ld h,a			;438e
	call ANDA_HASTA_LA_BASE		;438f
	ret nz			;4392
	call MONTA_SPRITES_BASE		;4393
	call DIBUJA_LA_BASE		;4396
	call MONTA_LA_BASE		;4399
	ld a,08fh		;439c
	call PIDE_SONIDO		;439e   ; Sonido 0x8F
	ld a,004h		;43a1   ; Se salta el paso 4... no: entra en el, poniendolo a mano
	ld (0e001h),a		;43a3
META_4_SALUDA:		; Paso 4: la escena de la base
	ld a,(0e01ah)		;43a6
	dec a			;43a9
	ret nz			;43aa
	call SUBE_LA_BANDERA		;43ab
	ld a,(0e0e1h)		;43ae
	or a			;43b1
	jr z,META_4_FASE_ESPECIAL		;43b2
	cp 002h			;43b4
	jr nz,META_4_NORMAL		;43b6
META_4_FASE_ESPECIAL:		; Cuando 0xE0E1 vale 0 o 2, la llegada tiene un remate propio, y esos dos numeros son EL POLO SUR y FRANCIA. 0xE0E1 es el indice 0-9 de la base a la que se llega, y 0x433B lo sube UN PASO ANTES, en el paso 1 de esta misma escena, asi que aqui ya apunta a la base de destino: 0 es FRANCE y 2 es THE SOUTH POLE en la tabla de 0x55D9. El caso 2 esta MEDIDO en la partida grabada (t=270,2), con STAGE-02 en el panel y el rotulo SOUTH POLE debajo. El caso 0 no sale en esa partida: le toca a la llegada de la fase 10, la que cierra la vuelta volviendo a FRANCE, y por eso tiene remate propio igual que el Polo. Eso ultimo esta DEDUCIDO de como gira el indice en 0x433B, no medido todavia
	ld a,(0e13ah)		;43b8
	cp 00fh			;43bb
	jr nz,META_4_NORMAL		;43bd
	call DIBUJA_EL_POLO		;43bf
	jp SIGUIENTE_PASO		;43c2
META_4_NORMAL:
	call DIBUJA_LA_BASE_PASO		;43c5
	ld a,(0e13ah)		;43c8
	cp 010h			;43cb
	ret nz			;43cd
	jr SIGUIENTE_PASO		;43ce
META_5_ESPERA:		; Paso 5: espera a que se acabe la musica
	ld a,(0e012h)		;43d0
	or a			;43d3
	ret nz			;43d4
	ld a,010h		;43d5
	jr ESPERA_A_Y_PASO		;43d7
META_6_BONUS:		; Paso 6: cada cuatro fotogramas cambia un segundo que sobra por 100 puntos
	ld hl,0e004h		;43d9
	ld a,(hl)		;43dc
	or a			;43dd
	jr z,BONUS_PASO		;43de
	dec (hl)		;43e0
	ret			;43e1
BONUS_PASO:
	ld a,(0e003h)		;43e2
	and 003h		;43e5
	ret nz			;43e7
	ld hl,(0e0e3h)		;43e8   ; Cuando el reloj llega a cero se acabo el bonus
	ld a,h			;43eb
	add a,l			;43ec
	jr z,ESPERA_80_Y_PASO		;43ed
	ld c,000h		;43ef
	call RESTA_UN_SEGUNDO		;43f1
	ld de,00100h		;43f4   ; Cien puntos por segundo
	call SUMA_AL_MARCADOR		;43f7
	ld a,001h		;43fa
	call PIDE_SONIDO		;43fc   ; Sonido 1, el tic-tic del bonus
	ret			;43ff
META_7_CORTINILLA:		; Paso 7: cortinilla y vuelta al estado 9 con la fase siguiente
	call CORTINILLA		;4400
	ret p			;4403
	ld a,008h		;4404
	ld (0e000h),a		;4406

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
	ld a,050h		;4409
ESPERA_A_Y_ESTADO:		; Espera A fotogramas y pasa al estado siguiente
	ld (0e004h),a		;440b
SIGUIENTE_ESTADO:		; Sube 0xE000 y pone el paso a cero
	ld hl,0e000h		;440e
	inc (hl)		;4411
	xor a			;4412
	ld (0e001h),a		;4413
	ret			;4416
ESPERA_80_Y_PASO:		; Espera 80 fotogramas y pasa al paso siguiente
	ld a,050h		;4417
ESPERA_A_Y_PASO:		; Espera A fotogramas y pasa al paso siguiente
	ld (0e004h),a		;4419
SIGUIENTE_PASO:		; Sube 0xE001 dentro del mismo estado
	ld hl,0e001h		;441c
	inc (hl)		;441f
	ret			;4420

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; CODIGO MUERTO: EL NUMERO DE JUGADOR
; ----------------------------------------------------------------------
; Escribe una cadena y detras un '1' o un '2' sacado del bit 7
; de 0xE002. Nadie la llama: la palabra 0x4421 no aparece en los
; 16 KB. Y el bit 7 de 0xE002 no lo pone nadie tampoco, porque
; los dos valores que se le escriben son 0x40 y 0x50. Es lo que
; queda de un modo de dos jugadores, a juego con el rotulo fijo
; "1P" del marcador.
; ----------------------------------------------------------------------
MUERTA_JUGADOR:		; Codigo muerto: escribe el numero de jugador. No la llama nadie
	call ESCRIBE_CADENA		;4421
	ld a,(0e002h)		;4424
	rlca			;4427   ; Bit 7 de 0xE002: el jugador. Nadie lo pone
	and 001h		;4428
	add a,031h		;442a
	ld de,03933h		;442c
	call ESCRIBE_BYTE_VRAM		;442f
	ret			;4432

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
	ld a,(0e13bh)		;4433   ; 0xE13B: durante la llegada a la base no se puede empezar otra
	or a			;4436
	ret nz			;4437
	ld a,(0e002h)		;4438
	bit 6,a			;443b   ; Con una partida en marcha tampoco
	ret nz			;443d
	ld a,000h		;443e
	call 00141h		;4440   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix | Fila 0 de la matriz: bit 1 la tecla 1, bit 2 la tecla 2
	cpl			;4443
	and 006h		;4444
	ld b,040h		;4446   ; Tecla 1 -> 0x40: partida con joystick
	cp 002h			;4448
	jr z,EMPIEZA_PARTIDA		;444a
	ld b,050h		;444c   ; Tecla 2 -> 0x50: partida con teclado (el bit 4 es el que lo dice)
	cp 004h			;444e
	ret nz			;4450
EMPIEZA_PARTIDA:
	xor a			;4451
	ld (0e133h),a		;4452
	ld a,b			;4455
	ld (0e002h),a		;4456
	pop hl			;4459   ; Tira la direccion de retorno: no se vuelve del paso de juego
	ld a,007h		;445a   ; Estado 7, y el avance de abajo lo deja en 8: el menu
	ld (0e000h),a		;445c
	jp ESPERA_80_Y_ESTADO		;445f
MUERTA_RET:		; Codigo muerto: un RET suelto que no llama nadie
	ret			;4462
REINICIA_PARTIDA:		; Deja a cero el marcador y todas las variables de partida
	ld hl,0e043h		;4463   ; Borra 0x100 bytes desde 0xE043: marcador, pinguino y objetos. El record de 0xE040 se salva por tres bytes
	ld de,0e044h		;4466
	ld bc,00100h		;4469
	ld (hl),000h		;446c
	ldir			;446e
	ld hl,04491h		;4470   ; Los nueve valores iniciales de 0xE0E0 (fase, tiempo, distancia...)
	ld de,0e0e0h		;4473
	ld bc,00009h		;4476
	ldir			;4479
	ld de,00900h		;447b   ; Colores del banco 0 de la VRAM
	ld bc,00100h		;447e
	ld a,0f0h		;4481
	call RELLENA_VRAM		;4483
	ld b,00ah		;4486   ; Los diez huecos de tiempo sobrante, uno por fase, a 5
	ld hl,0e0d5h		;4488
REINICIA_HUECOS:
	ld (hl),005h		;448b
	inc hl			;448d
	djnz REINICIA_HUECOS		;448e
	ret			;4490

; ----------------------------------------------------------------------
; DATOS valores_iniciales: Los nueve bytes que 0x4470 copia a 0xE0E0: fase 1, indice 0, y el resto a cero salvo 0xE0E4=2 y 0xE0E6=0x17. Solo los cinco primeros se usan: 0x425B machaca la distancia y el tiempo en cuanto empieza la fase
;   0x4491..0x449a  (9 bytes)
; ----------------------------------------------------------------------
	defb 001h,000h,000h,000h,002h,000h,017h,000h,000h	; 4491  .........

; ======================================================================
; CODIGO 0x449a..0x44df  (69 bytes)
; ======================================================================


ARRANCA_MAQUINA:		; Registros del VDP, mezclador del PSG y VRAM a cero
	call PONE_REGISTROS_VDP		;449a
	ld a,007h		;449d   ; Registro 7 del PSG: los tres tonos abiertos, el ruido cerrado
	ld e,0b8h		;449f
	call 00093h		;44a1   ; BIOS WRTPSG - Writes data to PSG-register
	call ABRE_VOLUMENES		;44a4
	call SUENA_95		;44a7
	ld de,00000h		;44aa   ; Los 16 KB de VRAM a cero
	ld bc,04000h		;44ad
BORRA_VRAM:		; Rellena de ceros BC bytes desde DE
	xor a			;44b0
	call RELLENA_VRAM		;44b1
	ret			;44b4
BORRA_NOMBRES:		; Las 768 casillas de la tabla de nombres
	ld de,03800h		;44b5
	ld bc,00300h		;44b8
	jr BORRA_VRAM		;44bb
SUENA_95:		; Sonido 0x95
	ld a,095h		;44bd
	call PIDE_SONIDO		;44bf
	ret			;44c2
PONE_REGISTROS_VDP:		; Copia los ocho registros a 0xE038 y los manda al VDP con WRTVDP
	ld hl,044dfh		;44c3
	ld de,0e038h		;44c6
	ld bc,00008h		;44c9
	ldir			;44cc
	ld hl,0e038h		;44ce
	ld d,008h		;44d1
	ld c,000h		;44d3
PONE_REGISTROS_BUCLE:
	ld b,(hl)		;44d5
	call 00047h		;44d6   ; BIOS WRTVDP - Writes data in the VDP-register
	inc hl			;44d9
	inc c			;44da
	dec d			;44db
	jr nz,PONE_REGISTROS_BUCLE		;44dc
	ret			;44de

; ----------------------------------------------------------------------
; DATOS registros_vdp: Los ocho registros del VDP: 02 E2 0E 7F 07 76 03 E4. Colores en 0x0000 y patrones en 0x2000, al reves de lo corriente; nombres en 0x3800, patrones de sprite en 0x1800 y atributos de sprite en 0x3B00. Sprites de 16x16 sin ampliar, y SCREEN 2
;   0x44df..0x44e7  (8 bytes)
; ----------------------------------------------------------------------
	defb 002h,0e2h,00eh,07fh,007h,076h,003h,0e4h	; 44df  .....v..

; ======================================================================
; CODIGO 0x44e7..0x4787  (672 bytes)
; ======================================================================


PONE_REGISTRO_7:		; Escribe B en el registro 7 del VDP: color de fondo y de borde
	ld c,007h		;44e7
	jp 00047h		;44e9   ; BIOS WRTVDP - Writes data in the VDP-register
COPIA_A_VRAM:		; Copia BC bytes de (HL) a la VRAM DE
	call APUNTA_VRAM		;44ec
	di			;44ef
COPIA_A_VRAM_BUCLE:
	ld a,(hl)		;44f0
	exx			;44f1
	out (c),a		;44f2   ; El puerto de datos vive en C', puesto por APUNTA_VRAM
	exx			;44f4
	inc hl			;44f5
	dec bc			;44f6
	ld a,b			;44f7
	or c			;44f8
	jr nz,COPIA_A_VRAM_BUCLE		;44f9
	ei			;44fb
	ret			;44fc
RELLENA_VRAM:		; Escribe el byte A en BC posiciones de la VRAM desde DE
	di			;44fd
	ld h,a			;44fe
	set 6,d			;44ff   ; Bit 14 de la direccion: la escritura
	call APUNTA_VRAM		;4501
	res 6,d			;4504
RELLENA_VRAM_BUCLE:
	ld a,h			;4506
	exx			;4507
	out (c),a		;4508
	exx			;450a
	dec bc			;450b
	ld a,b			;450c
	or c			;450d
	jr nz,RELLENA_VRAM_BUCLE		;450e
	ei			;4510
	ret			;4511
PINTA_FRANJAS:		; Rellena tiras de la tabla de nombres a partir de una lista (largo, posicion), con el byte que va delante
	ld a,(hl)		;4512
	inc hl			;4513
	ld (0e0dfh),a		;4514   ; El byte con el que se rellena, que va el primero de la lista
	ld d,039h		;4517
FRANJAS_BUCLE:
	ld c,(hl)		;4519
	inc hl			;451a
	xor a			;451b
	cp c			;451c
	ret z			;451d
	ld b,a			;451e
	ld e,(hl)		;451f
	inc hl			;4520
	ld a,e			;4521
	cp 020h			;4522   ; Posicion menor de 0x20: la fila de mas abajo
	jr nc,FRANJAS_PINTA		;4524
	inc d			;4526
FRANJAS_PINTA:
	ld a,(0e0dfh)		;4527
	push hl			;452a
	push de			;452b
	call RELLENA_VRAM		;452c
	pop de			;452f
	pop hl			;4530
	jr FRANJAS_BUCLE		;4531

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
; 0x732D-0x7518 y los 92 trozos de pista de 0x6BE9-0x7241.
; ----------------------------------------------------------------------
DIBUJA_BLOQUE:		; Interprete de los bloques de decorado y de pista
	ld a,(hl)		;4533
	or a			;4534
	ret z			;4535
	and 0f0h		;4536
	ld c,a			;4538
	ld a,(hl)		;4539
	inc hl			;453a
	and 003h		;453b
	add a,078h		;453d
	ld d,a			;453f
	ld a,c			;4540
BLOQUE_FILA:
	ld b,(hl)		;4541
	inc hl			;4542
	ld a,020h		;4543
	add a,c			;4545
	ld c,a			;4546
	jr nc,BLOQUE_APUNTA		;4547
	inc d			;4549
BLOQUE_APUNTA:
	ld a,c			;454a
	add a,b			;454b
	sub 0e0h		;454c
	ld e,a			;454e
	call APUNTA_VRAM		;454f
BLOQUE_CASILLA:
	ld a,(hl)		;4552
	or a			;4553
	ret z			;4554
	cp 0e0h			;4555
	jr nc,BLOQUE_FILA		;4557
	inc hl			;4559
	exx			;455a
	out (c),a		;455b
	exx			;455d
	jr BLOQUE_CASILLA		;455e

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
	ld e,(hl)		;4560
	inc hl			;4561
	ld d,(hl)		;4562
	inc hl			;4563
DESCOMPRIME_DE:		; El destino ya viene en DE
	ld c,000h		;4564
	jr DESCOMPRIME_APUNTA		;4566
DESCOMPRIME_ESPEJO:		; El destino en DE, y ademas espeja cada byte
	ld c,001h		;4568
DESCOMPRIME_APUNTA:
	call APUNTA_VRAM		;456a
DESCOMPRIME_SIGUE:		; El bucle
	ld a,(hl)		;456d
	inc hl			;456e
	cp 080h			;456f   ; Un 0x80 cierra este bloque y arriba se lee otro destino
	jr z,DESCOMPRIME		;4571
	or a			;4573
	jr z,DESCOMPRIME_FIN		;4574   ; Un 0x00 acaba
	bit 7,a			;4576
	jr nz,DESCOMPRIME_TIRADA		;4578
	ld b,a			;457a
	call LEE_BYTE_QUIZA_ESPEJADO		;457b
DESCOMPRIME_REPITE:
	exx			;457e
	out (c),a		;457f
	exx			;4581
	push hl			;4582   ; Dos bytes de relleno para dar tiempo al VDP entre escritura y escritura
	pop hl			;4583
	djnz DESCOMPRIME_REPITE		;4584
	jr DESCOMPRIME_SIGUE		;4586
DESCOMPRIME_TIRADA:
	res 7,a			;4588
	ld b,a			;458a
DESCOMPRIME_TIRADA_BUCLE:
	call LEE_BYTE_QUIZA_ESPEJADO		;458b
	exx			;458e
	out (c),a		;458f
	exx			;4591
	djnz DESCOMPRIME_TIRADA_BUCLE		;4592
	jr DESCOMPRIME_SIGUE		;4594
DESCOMPRIME_FIN:
	ei			;4596
	ret			;4597
LEE_BYTE_QUIZA_ESPEJADO:		; Lee (HL) y, con el bit 0 de C, le da la vuelta a los bits: espejo horizontal
	ld a,(hl)		;4598
	inc hl			;4599
	bit 0,c			;459a
	ret z			;459c
	push bc			;459d
	ld b,008h		;459e
	ld c,a			;45a0
ESPEJA_BUCLE:
	rr c			;45a1
	rla			;45a3
	djnz ESPEJA_BUCLE		;45a4
	pop bc			;45a6
	ret			;45a7

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
	ld e,(hl)		;45a8
	inc hl			;45a9
	ld d,(hl)		;45aa
	inc hl			;45ab
ESCRIBE_CADENA_EN_DE:		; Igual, pero el destino ya viene en DE
	ld a,(hl)		;45ac
	inc hl			;45ad
	ld b,a			;45ae
	inc b			;45af
	ret z			;45b0   ; 0xFF: se acabo
	inc b			;45b1
	jr z,ESCRIBE_CADENA		;45b2   ; 0xFE: sigue en otro sitio de la pantalla
	call ESCRIBE_BYTE_VRAM		;45b4
	inc de			;45b7
	jr ESCRIBE_CADENA_EN_DE		;45b8
REPITE_4_BYTES:		; Copia C veces los mismos cuatro bytes de (HL) a (DE): un atributo de sprite repetido
	push hl			;45ba
	ld b,004h		;45bb
REPITE_4_BUCLE:
	ld a,(hl)		;45bd
	ld (de),a		;45be
	inc hl			;45bf
	inc de			;45c0
	djnz REPITE_4_BUCLE		;45c1
	dec c			;45c3
	jr z,REPITE_4_FIN		;45c4
	pop hl			;45c6
	jr REPITE_4_BYTES		;45c7
REPITE_4_FIN:
	pop bc			;45c9   ; Recoge el ultimo PUSH HL en BC, que ya no hace falta
	ret			;45ca

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
	call BORRA_SPRITES		;45cb
	ld d,038h		;45ce
	ld hl,0e004h		;45d0
	ld b,018h		;45d3
	bit 6,(hl)		;45d5   ; Bit 6 de 0xE004: un lado o el otro
	jr nz,CORTINILLA_DERECHA		;45d7
	ld a,01fh		;45d9
	sub (hl)		;45db
	ld e,a			;45dc
	set 6,(hl)		;45dd
	jr CORTINILLA_COLUMNA		;45df
CORTINILLA_DERECHA:
	res 6,(hl)		;45e1
	dec (hl)		;45e3
	ret m			;45e4
	ld e,(hl)		;45e5
CORTINILLA_COLUMNA:
	ld a,(0e000h)		;45e6   ; En partida no se toca el panel: dos filas menos y 0x40 mas abajo
	cp 00ah			;45e9
	jr c,CORTINILLA_BUCLE		;45eb
	ld a,040h		;45ed
	add a,e			;45ef
	ld e,a			;45f0
	dec b			;45f1
	dec b			;45f2
CORTINILLA_BUCLE:
	xor a			;45f3
	call ESCRIBE_BYTE_VRAM		;45f4
	ld a,020h		;45f7
	call SUMA_A_DE		;45f9   ; Baja una fila
	djnz CORTINILLA_BUCLE		;45fc
	xor a			;45fe
	ret			;45ff
BORRA_SPRITES:		; Deja a cero los 128 bytes de atributos de sprite (VRAM 0x3B00), pasando por 0xE050
	ld hl,0e050h		;4600
	push hl			;4603
	ld b,080h		;4604
BORRA_SPRITES_BUCLE:
	ld (hl),000h		;4606
	inc hl			;4608
	djnz BORRA_SPRITES_BUCLE		;4609
	ld de,03b00h		;460b
	pop hl			;460e
	ld bc,00080h		;460f
	jp COPIA_A_VRAM		;4612
ABRE_VOLUMENES:		; Registro 15 del PSG a 0x8F (?)
	ld e,08fh		;4615
	ld a,00fh		;4617
	call 00093h		;4619   ; BIOS WRTPSG - Writes data to PSG-register
	ret			;461c
LEE_GATILLOS_NUEVOS:		; Deja en A los gatillos que se acaban de pulsar en este fotograma
	ld a,(0e009h)		;461d
	ld b,a			;4620
	ld a,(0e008h)		;4621
	and 030h		;4624
	cpl			;4626
	ld c,a			;4627
	ld a,b			;4628
	and 030h		;4629
	and c			;462b
	ret			;462c
SUMA_AL_MARCADOR:		; Suma DE al marcador, en BCD, y actualiza el record
	ld a,(0e002h)		;462d   ; Bit 6 de 0xE002 al bit de signo: en la demo no se puntua
	add a,a			;4630
	ret p			;4631
	ld hl,0e043h		;4632
	ld a,(hl)		;4635
	add a,e			;4636
	daa			;4637
	ld (hl),a		;4638
	ld e,a			;4639
	inc hl			;463a
	ld a,(hl)		;463b
	adc a,d			;463c
	daa			;463d
	ld (hl),a		;463e
	ld d,a			;463f
	inc hl			;4640
	jr nc,COMPARA_RECORD		;4641
	ld a,(hl)		;4643
	adc a,000h		;4644
	daa			;4646
	ld (hl),a		;4647
	jr nc,COMPARA_RECORD		;4648
	ld bc,09999h		;464a   ; Al pasarse de 999999 el record se clava en ese tope
	ld (0e040h),bc		;464d
	ld (0e041h),bc		;4651
	jr PINTA_RECORD		;4655
COMPARA_RECORD:
	ld a,(0e042h)		;4657
	ld b,(hl)		;465a
	sub (hl)		;465b
	jr c,NUEVO_RECORD		;465c
	jr nz,PINTA_MARCADOR		;465e
	ld hl,(0e040h)		;4660
	sbc hl,de		;4663
	jr nc,PINTA_MARCADOR		;4665
NUEVO_RECORD:
	ld (0e040h),de		;4667
	ld a,b			;466b
	ld (0e042h),a		;466c
	jr PINTA_RECORD		;466f
CUENTA_EL_TIEMPO:		; Descuenta un segundo cada 64 fotogramas mientras 0xE133 diga que el reloj corre
	ld a,(0e133h)		;4671
	or a			;4674
	ret z			;4675
	ld hl,(0e0e3h)		;4676   ; Si el reloj esta a cero, 0xE00C avisa de que se acabo el tiempo
	ld a,h			;4679
	add a,l			;467a
	jr nz,TIEMPO_CADA_64		;467b
	inc a			;467d
	ld (0e00ch),a		;467e
	ret			;4681
TIEMPO_CADA_64:
	ld a,(0e003h)		;4682
	and 03fh		;4685
	ret nz			;4687
	ld c,001h		;4688
RESTA_UN_SEGUNDO:		; Baja el reloj en uno, en BCD, y avisa con un pitido cuando quedan menos de once
	ld hl,0e0e3h		;468a
	ld a,(hl)		;468d
	sub 001h		;468e
	daa			;4690
	ld (hl),a		;4691
	inc hl			;4692
	ld a,(hl)		;4693
	jr nc,TIEMPO_MIRA_AVISO		;4694
	sub 001h		;4696
	daa			;4698
	ld (hl),a		;4699
TIEMPO_MIRA_AVISO:
	dec hl			;469a
	or a			;469b
	jr nz,PINTA_TIEMPO		;469c
	ld a,(hl)		;469e
	cp 011h			;469f   ; Menos de 0x11 segundos: el aviso
	jr nc,PINTA_TIEMPO		;46a1
	dec c			;46a3
	jr nz,PINTA_TIEMPO		;46a4
	push af			;46a6
	push hl			;46a7
	ld a,009h		;46a8
	call PIDE_SONIDO		;46aa   ; Sonido 9
	pop hl			;46ad
	pop af			;46ae
PINTA_TIEMPO:		; Las cuatro cifras del reloj
	ld b,002h		;46af
	ld de,03827h		;46b1
	ld hl,0e0e4h		;46b4
	jp PINTA_BCD		;46b7
PINTA_PANEL:		; Pinta el panel entero: rotulos, tiempo, distancia, fase, record y marcador
	ld hl,057b0h		;46ba
	call ESCRIBE_CADENA		;46bd
	call PINTA_TIEMPO		;46c0
	call PINTA_DISTANCIA		;46c3
	call PINTA_FASE		;46c6
PINTA_RECORD:		; Las seis cifras del record
	ld hl,0e042h		;46c9
	ld de,0380fh		;46cc
	call PINTA_TRES_BYTES		;46cf
PINTA_MARCADOR:		; Las seis cifras del marcador
	ld de,03805h		;46d2
	ld hl,0e045h		;46d5
PINTA_TRES_BYTES:
	ld b,003h		;46d8
	jr PINTA_BCD		;46da
AVANZA_DISTANCIA:		; Descuenta la distancia que queda al ritmo que marca la velocidad
	ld hl,0e0e9h		;46dc
	dec (hl)		;46df   ; 0xE0E9 es el contador; se recarga con la mitad de la velocidad
	ret nz			;46e0
	ld a,(0e100h)		;46e1
	srl a			;46e4
	dec a			;46e6
	ld (hl),a		;46e7
	ld hl,0e0e6h		;46e8   ; Distancia a cero: 0xE00D avisa de que se ha llegado a la meta
	ld a,(hl)		;46eb
	dec hl			;46ec
	or (hl)			;46ed
	jr nz,DISTANCIA_RESTA		;46ee
	inc a			;46f0
	ld (0e00dh),a		;46f1
	ret			;46f4
DISTANCIA_RESTA:
	ld a,(hl)		;46f5
	sub 001h		;46f6
	daa			;46f8
	ld (hl),a		;46f9
	ld c,a			;46fa
	inc hl			;46fb
	jr nc,DISTANCIA_MIRA		;46fc
	ld a,(hl)		;46fe
	sub 001h		;46ff
	daa			;4701
	ld (hl),a		;4702
DISTANCIA_MIRA:
	ld a,c			;4703
	or a			;4704
	jr nz,DISTANCIA_PINTA		;4705
	or (hl)			;4707
	jr z,DISTANCIA_PINTA		;4708
	ld a,(hl)		;470a
	and 003h		;470b
	jr nz,DISTANCIA_PINTA		;470d
	inc a			;470f
	ld (0e107h),a		;4710   ; Cada 400 metros (?), 0xE107
DISTANCIA_PINTA:
	call MIRA_LA_CURVA		;4713
PINTA_DISTANCIA:		; Las cuatro cifras de la distancia
	ld b,002h		;4716
	ld de,0382fh		;4718
	ld hl,0e0e6h		;471b
	jr PINTA_BCD		;471e
PINTA_FASE:		; Las dos cifras del numero de fase
	ld de,0381ch		;4720
	ld hl,0e0e0h		;4723
	ld b,001h		;4726
PINTA_BCD:		; Escribe B bytes BCD de (HL) hacia abajo en la VRAM (DE) hacia arriba, dos cifras por byte
	ld a,(hl)		;4728
	push af			;4729
	and 00fh		;472a
	or 010h			;472c   ; Los digitos empiezan en la casilla 0x10, que es el '0' de la fuente
	ld c,a			;472e
	pop af			;472f
	and 0f0h		;4730
	rra			;4732
	rra			;4733
	rra			;4734
	rra			;4735
	or 010h			;4736
	call ESCRIBE_BYTE_VRAM		;4738
	inc de			;473b
	ld a,c			;473c
	call ESCRIBE_BYTE_VRAM		;473d
	dec hl			;4740
	inc de			;4741
	djnz PINTA_BCD		;4742
	ret			;4744

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; QUE DECORADO TOCA
; ----------------------------------------------------------------------
; Cuatro tablas encadenadas, y las cuatro cierran clavadas:
; 0x4787  dos bytes por fase; elige uno de los dos segun el
; bit 4 de la distancia -> 0xE18A
; 0x47C3  un puntero por fase, que apunta dentro de la tabla
; de abajo (las ventanas se solapan)
; 0x47D7  veinte punteros a las listas
; 0x479B  cinco listas de ocho bytes -> 0xE18B
; ----------------------------------------------------------------------
ELIGE_DECORADO:		; Segun la fase y la distancia, deja en 0xE18A y 0xE18B lo que toca dibujar a los lados de la pista
	ld a,(0e0e0h)		;4745
	and 00fh		;4748
	ld hl,04787h		;474a
	add a,a			;474d
	call SUMA_A_HL		;474e
	ld a,(0e0e6h)		;4751
	and 010h		;4754   ; Bit 4 de la distancia: uno u otro
	jr z,DECORADO_SEGUNDA		;4756
	inc hl			;4758
DECORADO_SEGUNDA:
	ld a,(hl)		;4759
	ld (0e18ah),a		;475a
	ld a,(0e0e0h)		;475d
	and 00fh		;4760
	ld hl,047c3h		;4762
	add a,a			;4765
	call SUMA_A_HL		;4766
	ld e,(hl)		;4769
	inc hl			;476a
	ld d,(hl)		;476b
	ex de,hl		;476c
	ld a,(0e0e6h)		;476d   ; La distancia, por cuartos
	and 0fch		;4770
	rrca			;4772
	rrca			;4773
	res 3,a			;4774
	cp 004h			;4776
	jr c,DECORADO_INDICE		;4778
	dec a			;477a
DECORADO_INDICE:
	add a,a			;477b
	call SUMA_A_HL		;477c
	ld e,(hl)		;477f
	inc hl			;4780
	ld d,(hl)		;4781
	ex de,hl		;4782
	ld (0e18bh),hl		;4783
	ret			;4786

; ----------------------------------------------------------------------
; DATOS decorado_por_fase: Dos bytes por fase, diez fases: 0x474A los indexa y el bit 4 de la distancia elige cual de los dos. Acaba justo donde empiezan las listas
;   0x4787..0x479b  (20 bytes)
; DATOS listas_de_decorado: Cinco listas de ocho bytes. Es a donde apuntan los veinte punteros de 0x47D7, y acaban clavadas donde empieza la tabla de fases
;   0x479b..0x47c3  (40 bytes)
; DATOS decorado_puntero_por_fase: Diez punteros, uno por fase, que apuntan DENTRO de la tabla de al lado con ventanas que se solapan. 0x4762 lo indexa
;   0x47c3..0x47d7  (20 bytes)
; DATOS decorado_punteros: Veinte punteros a las cinco listas. Cierra clavado en 0x47FF, donde vuelve a haber codigo
;   0x47d7..0x47ff  (40 bytes)
; ----------------------------------------------------------------------
	defb 080h,000h,0a0h,0a0h,050h,050h,0e0h,0e0h,050h,050h,000h,020h,0e0h,0e0h,020h,020h	; 4787  ....PP..PP. ..  
	defb 000h,000h,0ffh,0ffh,001h,005h,0ffh,000h,012h,005h,0ffh,000h,011h,001h,000h,012h	; 4797  ................
	defb 000h,001h,012h,000h,000h,0ffh,003h,011h,001h,005h,0ffh,003h,000h,0ffh,003h,003h	; 47a7  ................
	defb 000h,011h,001h,012h,005h,0ffh,005h,0ffh,003h,012h,005h,0ffh,0f7h,047h,0e5h,047h	; 47b7  .............G.G
	defb 0edh,047h,0f7h,047h,0efh,047h,0f1h,047h,0f9h,047h,0e5h,047h,0f1h,047h,0d7h,047h	; 47c7  .G.G.G.G.G.G.G.G
	defb 0b3h,047h,09bh,047h,0b3h,047h,09bh,047h,0bbh,047h,0abh,047h,09bh,047h,0abh,047h	; 47d7  .G.G.G.G.G.G.G.G
	defb 0a3h,047h,0b3h,047h,0a3h,047h,09bh,047h,0b3h,047h,0a3h,047h,0abh,047h,0a3h,047h	; 47e7  .G.G.G.G.G.G.G.G
	defb 0bbh,047h,0a3h,047h,0bbh,047h,0a3h,047h	; 47f7  .G.G.G.G

; ======================================================================
; CODIGO 0x47ff..0x4839  (58 bytes)
; ======================================================================


HAY_SORPRESA:		; Mientras 0xE18E este encendido devuelve C=3, y descuenta 0xE18F hasta apagarlo
	ld a,(0e18eh)		;47ff
	rra			;4802
	ret nc			;4803
	ld hl,0e18fh		;4804
	dec (hl)		;4807
	jr nz,SORPRESA_SI		;4808
	xor a			;480a
	ld (0e18eh),a		;480b
SORPRESA_SI:
	ld c,003h		;480e
	ret			;4810
MIRA_SORPRESA:		; Enciende 0xE18E en ciertos multiplos de 100 metros, con la duracion que da la tabla de al lado
	ld a,(0e0e0h)		;4811
	and 00fh		;4814
	ld hl,04839h		;4816
	call SUMA_A_HL		;4819
	ld de,(0e0e5h)		;481c
	ld a,d			;4820
	cp 004h			;4821   ; Solo con 400 metros o mas por delante
	ret c			;4823
	ld a,e			;4824   ; Y justo en la centena exacta
	or a			;4825
	ret nz			;4826
	ld a,(0e0e0h)		;4827
	add a,d			;482a
	and 003h		;482b   ; Una de cada cuatro centenas, corrida segun la fase
	cp 002h			;482d
	ret nz			;482f
	inc a			;4830
	ld (0e18eh),a		;4831
	ld a,(hl)		;4834
	ld (0e18fh),a		;4835
	ret			;4838

; ----------------------------------------------------------------------
; DATOS duracion_sorpresa: Diez bytes, uno por fase: cuanto dura lo que enciende 0x4811. La fase 1 lleva 7 y las demas entre 2 y 6
;   0x4839..0x4843  (10 bytes)
; ----------------------------------------------------------------------
	defb 007h,002h,002h,003h,003h,004h,004h,005h,006h,006h	; 4839  ..........

; ======================================================================
; CODIGO 0x4843..0x490e  (203 bytes)
; ======================================================================


PREPARA_ROTULO:		; Limpia la pantalla y pone en blanco los colores del tercio de abajo para el rotulo
	call MONTA_LA_FUENTE		;4843
	ld de,01080h		;4846   ; Colores del banco 2, casillas 0x10 a 0x40
	ld bc,00180h		;4849
	ld a,070h		;484c
	call RELLENA_VRAM		;484e
	xor a			;4851
	ld (0e00ah),a		;4852
	ld b,0e0h		;4855   ; Fondo y borde a 0xE0
	call PONE_REGISTRO_7		;4857
	ld de,03800h		;485a
	ld bc,00300h		;485d
	xor a			;4860
	call RELLENA_VRAM		;4861
DIBUJA_ROTULO:		; Dibuja una columna del rotulo por llamada, 23 columnas de dos casillas; devuelve C mientras queda
	ld hl,0e00ah		;4864
	ld a,(hl)		;4867
	inc (hl)		;4868
	cp 017h			;4869   ; 23 columnas
	jr nc,ROTULO_ESPERA		;486b
	ld de,03885h		;486d
	ld c,a			;4870
	add a,e			;4871
	ld e,a			;4872
	ld a,c			;4873
	add a,a			;4874
	add a,0b2h		;4875   ; Las casillas van de dos en dos: 0xB2, 0xB4, 0xB6...
	ld c,a			;4877
	ld b,003h		;4878
	xor a			;487a
ROTULO_COLUMNA:
	call ESCRIBE_BYTE_VRAM		;487b
	ld a,020h		;487e
	call SUMA_A_DE		;4880
	ld a,c			;4883
	inc c			;4884
	djnz ROTULO_COLUMNA		;4885
	scf			;4887
	ret			;4888
ROTULO_ESPERA:
	push af			;4889
	ld hl,057dfh		;488a   ; "(c)KONAMI 1984"
	call ESCRIBE_CADENA		;488d
	pop af			;4890
	cp 034h			;4891   ; Y despues, 29 fotogramas mas de pausa antes de seguir
	ret c			;4893
	or a			;4894
	ret			;4895
SUBE_LOGO:		; Dibuja el logotipo de 3x3 casillas una fila mas arriba cada vez, y borra el rastro que deja debajo
	ld hl,(0e00eh)		;4896
	ld de,00020h		;4899
	add hl,de		;489c   ; Una fila menos en cada llamada
	ld (0e00eh),hl		;489d
	ex de,hl		;48a0
	or a			;48a1
	ld hl,03aaah		;48a2
	sbc hl,de		;48a5
	ex de,hl		;48a7
	ld a,044h		;48a8   ; Las nueve casillas van seguidas desde la 0x44
	ld bc,00303h		;48aa
LOGO_FILA:
	push de			;48ad
LOGO_CASILLA:
	call ESCRIBE_BYTE_VRAM		;48ae
	inc de			;48b1
	inc a			;48b2
	djnz LOGO_CASILLA		;48b3
	pop de			;48b5
	ld hl,00020h		;48b6
	add hl,de		;48b9
	ex de,hl		;48ba
	ld h,a			;48bb
	ld a,00eh		;48bc
	sub c			;48be
	ld b,a			;48bf
	ld a,h			;48c0
	dec c			;48c1
	jr nz,LOGO_FILA		;48c2
	ld bc,0000ch		;48c4   ; Borra las doce casillas que quedan debajo
	xor a			;48c7
	call RELLENA_VRAM		;48c8
	ld hl,0e00ah		;48cb
	dec (hl)		;48ce
	ret			;48cf
ESCRIBE_BYTE_VRAM:		; Escribe A en la VRAM (DE)
	call APUNTA_VRAM		;48d0
	exx			;48d3
	out (c),a		;48d4
	exx			;48d6
	ei			;48d7
	ret			;48d8
MUERTA_LEE_BYTE_VRAM:		; Codigo muerto: lee un byte de la VRAM (DE). Gemela de la de escribir, que se usa diez veces
	call MUERTA_APUNTA_VRAM_LEER		;48d9
	exx			;48dc
	in a,(c)		;48dd
	exx			;48df
	ei			;48e0
	ret			;48e1
APUNTA_VRAM:		; Apunta la VRAM para ESCRIBIR y deja el puerto de datos en C'
	ex af,af'		;48e2
	ex de,hl		;48e3
	call 00053h		;48e4   ; BIOS SETWRT - Enables VDP to write
	di			;48e7
	ex de,hl		;48e8
	exx			;48e9
	ld a,(00006h)		;48ea   ; El puerto de datos del VDP, que la BIOS guarda en 0x0006
	ld c,a			;48ed
	exx			;48ee
	ex af,af'		;48ef
	ret			;48f0
MUERTA_APUNTA_VRAM_LEER:		; Codigo muerto: apunta la VRAM para LEER. Solo la llama la otra rutina muerta
	ex de,hl		;48f1
	call 00050h		;48f2   ; BIOS SETRD - Enables VDP to read
	di			;48f5
	ex de,hl		;48f6
	exx			;48f7
	ld a,(00007h)		;48f8   ; El puerto de lectura, en 0x0007
	ld c,a			;48fb
	exx			;48fc
	ret			;48fd
SUMA_A_HL:		; HL = HL + A
	add a,l			;48fe
	ld l,a			;48ff
	ret nc			;4900
	inc h			;4901
	ret			;4902
SUMA_A_DE:		; DE = DE + A
	add a,e			;4903
	ld e,a			;4904
	ret nc			;4905
	inc d			;4906
	ret			;4907
ESTADO_15_MAPA:		; Estado 15: el mapa, en siete pasos
	ld a,(0e001h)		;4908
	call DESPACHA		;490b

; ----------------------------------------------------------------------
; DATOS tabla_mapa: Los SIETE pasos del estado 15, del CALL de 0x490B
;   0x490e..0x491c  (14 bytes)
; ----------------------------------------------------------------------
	defb 01ch,049h,036h,049h,03dh,049h,074h,049h,090h,049h,09dh,049h,0f4h,049h	; 490e  .I6I=ItI.I.I.I

; ======================================================================
; CODIGO 0x491c..0x4a01  (229 bytes)
; ======================================================================


MAPA_0_PREPARA:		; Paso 0: prepara los punteros y pinta de blanco los colores del mapa
	ld hl,04a01h		;491c   ; Aqui empiezan las filas del dibujo
	ld (0e0f2h),hl		;491f
	ld hl,03884h		;4922   ; Y esta es la casilla por la que se empieza a pintar
	ld (0e0f0h),hl		;4925
	ld de,01080h		;4928
	ld bc,00180h		;492b
	ld a,0f4h		;492e
	call RELLENA_VRAM		;4930
	jp SIGUIENTE_PASO		;4933
MAPA_1_BORDE:		; Paso 1: la linea de arriba del marco
	ld de,03883h		;4936
	ld a,092h		;4939
	jr MAPA_BORDE		;493b
MAPA_2_FILA:		; Paso 2: una fila del mapa cada dos fotogramas, hasta el 0x00 que cierra los datos
	ld a,(0e003h)		;493d
	rra			;4940
	ret c			;4941
	ld hl,(0e0f0h)		;4942
	ld a,020h		;4945   ; Baja una fila
	call SUMA_A_HL		;4947
	ld (0e0f0h),hl		;494a
	ex de,hl		;494d
	push de			;494e
	ld a,00ah		;494f   ; Limpia la fila antes de escribirla
	ld bc,00018h		;4951
	call RELLENA_VRAM		;4954
	pop de			;4957
	inc de			;4958
	ld a,004h		;4959
	ld c,016h		;495b
	call RELLENA_VRAM		;495d
	ld hl,(0e0f2h)		;4960
	ld a,(hl)		;4963
	inc hl			;4964
	or a			;4965
	jp z,SIGUIENTE_PASO		;4966   ; Un 0x00 en los datos: se acabo el dibujo
	ld e,a			;4969
	inc a			;496a
	jr z,MAPA_2_GUARDA		;496b   ; 0xFF: esta fila no lleva texto
	call ESCRIBE_CADENA_EN_DE		;496d
MAPA_2_GUARDA:
	ld (0e0f2h),hl		;4970
	ret			;4973
MAPA_3_BORDE:		; Paso 3: la linea de abajo del marco
	ld de,03aa3h		;4974
	ld a,091h		;4977
MAPA_BORDE:
	call ESCRIBE_BYTE_VRAM		;4979
	inc de			;497c
	ld bc,00018h		;497d
	add a,004h		;4980
	push af			;4982
	call RELLENA_VRAM		;4983
	pop af			;4986
	sub 002h		;4987
	exx			;4989
	out (c),a		;498a
	exx			;498c
	jp SIGUIENTE_PASO		;498d
MAPA_4_TRAZO:		; Paso 4: prepara el trazado del recorrido
	ld hl,03a14h		;4990   ; Por donde empieza el camino, en la tabla de nombres
	ld (0e0f4h),hl		;4993
	xor a			;4996
	ld (0e0f6h),a		;4997
	jp SIGUIENTE_PASO		;499a
MAPA_5_TRAZA:		; Paso 5: un paso del recorrido cada dos fotogramas
	ld a,(0e003h)		;499d
	rra			;49a0
	ret c			;49a1
	ld hl,0e0f6h		;49a2
	ld a,(hl)		;49a5
	ld de,04ab0h		;49a6   ; El paso que toca, de la lista de 0x4AB0
	call SUMA_A_DE		;49a9
	ld a,(de)		;49ac
	ld (0e0d0h),a		;49ad
	cp 020h			;49b0   ; Un 0x20 cierra la lista
	jp z,SIGUIENTE_PASO		;49b2
	inc (hl)		;49b5
	ld c,097h		;49b6
	ld a,(0e0e7h)		;49b8   ; Hasta donde ha llegado el pinguino va de un color, y lo que falta de otro
	cp (hl)			;49bb
	jr c,TRAZO_PARTE		;49bc
	ld c,0a4h		;49be
TRAZO_PARTE:
	ld hl,0e0d0h		;49c0
	xor a			;49c3
	rrd			;49c4   ; El RRD parte el byte: nibble bajo a B (la casilla) y nibble alto a A (la direccion)
	ld b,a			;49c6
	ld a,(hl)		;49c7
	ld hl,PASO_ARRIBA		;49c8   ; El nibble alto indexa el codigo de abajo, que va de cuatro en cuatro bytes
	call SUMA_A_HL		;49cb
	ld de,(0e0f4h)		;49ce
	call SALTA_A_HL		;49d2
	ld (0e0f4h),de		;49d5
	ld a,b			;49d9
	add a,c			;49da
	call ESCRIBE_BYTE_VRAM		;49db
	scf			;49de
	ret			;49df
SALTA_A_HL:		; El otro despachador: aqui A no indexa direcciones sino el codigo de abajo
	jp (hl)			;49e0

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LOS CUATRO PASOS DEL RECORRIDO
; ----------------------------------------------------------------------
; Cuatro trozos de cuatro bytes justos, para que el nibble alto
; del dato (0, 4, 8 o C) caiga clavado en uno de ellos.
; ----------------------------------------------------------------------
PASO_ARRIBA:		; Una fila menos: -0x20
	ld a,0e0h		;49e1
	jr PASO_ARRIBA_SUMA		;49e3
PASO_DERECHA:		; Una casilla mas
	ld a,001h		;49e5
	jr PASO_SUMA		;49e7
PASO_ABAJO:		; Una fila mas: +0x20
	ld a,020h		;49e9
	jr PASO_SUMA		;49eb
PASO_IZQUIERDA:		; Una casilla menos
	ld a,0ffh		;49ed
PASO_ARRIBA_SUMA:
	dec d			;49ef
PASO_SUMA:
	call SUMA_A_DE		;49f0
	ret			;49f3
MAPA_6_ESPERA:		; Paso 6: espera y salta al estado 9, que prepara la fase
	ld hl,0e004h		;49f4
	dec (hl)		;49f7
	ret nz			;49f8
	ld a,009h		;49f9
	ld (0e000h),a		;49fb
	jp ESPERA_80_Y_ESTADO		;49fe

; ----------------------------------------------------------------------
; DATOS mapa_dibujo: Las filas del mapa, una detras de otra: un byte de columna y detras las casillas, o un 0xFF si la fila va vacia. El 0x00 de 0x4AAF lo cierra. Son dieciseis filas, y la ultima es el rotulo ANTARCTICA (c)KONAMI
;   0x4a01..0x4ab0  (175 bytes)
; DATOS mapa_recorrido: Los cuarenta pasos del camino: nibble alto la direccion (0 arriba, 4 derecha, 8 abajo, C izquierda) y nibble bajo la casilla que se dibuja. El 0x20 de 0x4AD8 lo cierra
;   0x4ab0..0x4ad9  (41 bytes)
; DATOS tabla_de_fases: Las DIEZ fases, cuatro bytes cada una: centenas de metros, casilla del mapa donde empieza, y el tiempo en BCD. Cierra clavada en 0x4B01, donde vuelve a haber codigo. Salen 1500 m/100 s, 1700/120, 1100/80, 1200/80, 1200/80, 500/40, 2600/165, 1200/90, 1500/100 y 1200/90
;   0x4ad9..0x4b01  (40 bytes)
; ----------------------------------------------------------------------
	defb 0ffh,0ceh,05eh,05fh,060h,061h,0ffh,0edh,062h,00fh,00fh,00fh,00fh,00fh,063h,064h	; 4a01  ..^_`a..b.....cd
	defb 065h,0ffh,008h,066h,004h,004h,004h,004h,067h,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 4a11  e..f....g.......
	defb 068h,0ffh,028h,069h,06ah,064h,088h,089h,07eh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 4a21  h.(ijd..~.......
	defb 06bh,0ffh,049h,06ch,06dh,07fh,007h,080h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,061h	; 4a31  k.Ilm..........a
	defb 0ffh,06ah,067h,081h,082h,00fh,00fh,00fh,08dh,08eh,08fh,090h,00fh,00fh,06eh,0ffh	; 4a41  .jg...........n.
	defb 08ah,06fh,00fh,00fh,00fh,00fh,00fh,08ch,00fh,00fh,00fh,00fh,00fh,070h,0ffh,0abh	; 4a51  .o...........p..
	defb 071h,00fh,00fh,083h,084h,00fh,00fh,00fh,00fh,00fh,00fh,072h,0ffh,0cbh,073h,00fh	; 4a61  q..........r..s.
	defb 00fh,085h,007h,086h,00fh,00fh,00fh,00fh,00fh,074h,0ffh,0ebh,069h,075h,076h,08ah	; 4a71  .........t..iuv.
	defb 08bh,087h,00fh,00fh,00fh,00fh,077h,0ffh,010h,078h,00fh,00fh,00fh,00fh,079h,0ffh	; 4a81  ......w..x....y.
	defb 030h,07ah,075h,07bh,07ch,07dh,0ffh,0ffh,067h,021h,02eh,034h,021h,032h,023h,034h	; 4a91  0zu{|}..g!.4!2#4
	defb 029h,023h,021h,004h,004h,01ah,02bh,02fh,02eh,021h,02dh,029h,0ffh,0ffh,000h,0c4h	; 4aa1  )#!...+/.!-)....
	defb 0c4h,0c0h,00bh,002h,002h,0c5h,00ch,0c5h,0c5h,0c6h,086h,087h,0c5h,002h,00ch,00ah	; 4ab1  ................
	defb 009h,048h,043h,00ch,00ch,001h,045h,045h,045h,042h,085h,047h,042h,082h,082h,085h	; 4ac1  .HC...EEEB.GB...
	defb 04bh,082h,082h,08bh,0c4h,082h,08bh,020h,015h,000h,000h,001h,017h,003h,020h,001h	; 4ad1  K...... ...... .
	defb 011h,008h,080h,000h,012h,00ch,080h,000h,012h,010h,080h,000h,005h,015h,040h,000h	; 4ae1  ..............@.
	defb 026h,016h,065h,001h,012h,01dh,090h,000h,015h,022h,000h,001h,012h,025h,090h,000h	; 4af1  &.e......"...%..

; ======================================================================
; CODIGO 0x4b01..0x4b84  (131 bytes)
; ======================================================================


MONTA_LA_FASE:		; Prepara la fase entera: borra las variables de pista, carga los graficos y monta el decorado
	ld hl,0e0f0h		;4b01   ; Borra 0x130 bytes de variables de pista, obstaculos y sonido
	ld de,0e0f1h		;4b04
	ld bc,00130h		;4b07
	ld (hl),000h		;4b0a
	ldir			;4b0c
	ld a,010h		;4b0e
	ld h,a			;4b10
	ld l,a			;4b11
	ld (0e100h),hl		;4b12   ; Velocidad inicial 0x10
	ld (0e110h),a		;4b15
	ld a,008h		;4b18
	ld (0e149h),a		;4b1a
	ld a,005h		;4b1d
	ld (0e0e9h),a		;4b1f
	ld hl,03030h		;4b22   ; Segun sea la fase par o impar, una pareja de casillas u otra
	ld a,(0e0e0h)		;4b25
	rra			;4b28
	jr nc,FASE_CASILLAS		;4b29
	ld hl,03434h		;4b2b
FASE_CASILLAS:
	ld (0e10eh),hl		;4b2e
	ld a,001h		;4b31
	ld (0e13bh),a		;4b33   ; Mientras se monta la fase no se puede empezar otra partida
	call CARGA_BANCO_1		;4b36   ; Los cuatro cargadores de graficos comprimidos
	call CARGA_BANCO_2		;4b39
	call CARGA_SPRITES		;4b3c
	call MONTA_SPRITES_PARTIDA		;4b3f
	call MONTA_LA_PISTA		;4b42   ; Y el montaje de la pista
	xor a			;4b45
	ld (0e13bh),a		;4b46
	ret			;4b49

; ----------------------------------------------------------------------
; ############################################################
; UN PASO DE PARTIDA
; ############################################################
; ----------------------------------------------------------------------
PASO_DE_PARTIDA:		; Todo lo que pasa en un fotograma de juego
	call PINTA_VELOCIMETRO		;4b4a
	call MUEVE_EL_PEZ		;4b4d
	ld a,(0e140h)		;4b50   ; 0xE140: esta en el agua, y entonces no se juega
	or a			;4b53
	jp nz,SIGUE_EN_EL_AGUA		;4b54
	ld a,(0e142h)		;4b57   ; 0xE142: se esta cayendo
	or a			;4b5a
	jp nz,SIGUE_CAIDA		;4b5b
	call AJUSTA_DIFICULTAD		;4b5e
	call MUEVE_PINGUINO		;4b61   ; Los mandos
	call ARRASTRA_PINGUINO		;4b64
	call MIRA_EL_PEZ		;4b67   ; El pez
	call MIRA_EL_BORDE		;4b6a
	ld a,(0e140h)		;4b6d
	or a			;4b70
	ret nz			;4b71
	call AVANZA_LA_PISTA		;4b72
	call DIBUJA_LA_META		;4b75
	call AVANZA_DISTANCIA		;4b78   ; La distancia que queda y el decorado que toca
	call ELIGE_DECORADO		;4b7b
	call CREA_OBSTACULO		;4b7e
	jp LAS_NUBES		;4b81

; ----------------------------------------------------------------------
; DATOS poses_del_pinguino: Diez poses de cuatro bytes: los cuatro patrones de sprite que forman el pinguino en cada postura. 0x4BD5 las reparte de cuatro en cuatro por los atributos
;   0x4b84..0x4bac  (40 bytes)
; ----------------------------------------------------------------------
	defb 000h,004h,008h,00ch,010h,014h,018h,01ch,020h,024h,028h,02ch,000h,004h,030h,034h	; 4b84  ........ $(,..04
	defb 038h,03ch,040h,044h,060h,064h,068h,06ch,020h,048h,04ch,050h,054h,014h,058h,05ch	; 4b94  8<@D`dhl HLPT.X\
	defb 010h,0a8h,018h,0ach,0b0h,024h,0b4h,02ch	; 4ba4  .....$.,

; ======================================================================
; CODIGO 0x4bac..0x4c80  (212 bytes)
; ======================================================================


MUEVE_PINGUINO:		; Lee los mandos y mueve al pinguino, o sigue el salto si ya estaba saltando
	ld hl,0e0f9h		;4bac   ; 0xE0F9 distinto de cero: hay un salto en marcha
	ld a,(hl)		;4baf
	or a			;4bb0
	jp nz,SIGUE_SALTO		;4bb1
	call LEE_GATILLOS_NUEVOS		;4bb4   ; Gatillo recien pulsado: empieza el salto
	jp nz,EMPIEZA_SALTO		;4bb7
	ld a,b			;4bba
	ld de,(0e078h)		;4bbb   ; Posicion actual: E la Y, D la X
	call MUEVE_A_LOS_LADOS		;4bbf
PINGUINO_COLOCA:
	ex de,hl		;4bc2
PINGUINO_SPRITES:
	call COLOCA_SPRITES		;4bc3
PINGUINO_A_VRAM:		; Vuelca los cuatro atributos del pinguino a la VRAM
	ld hl,0e078h		;4bc6
	ld de,03b28h		;4bc9   ; Sprites 10 a 13
	ld bc,00010h		;4bcc
	call COPIA_A_VRAM		;4bcf
	jp COLOCA_SOMBRA		;4bd2
PONE_POSE:		; Copia los cuatro patrones de la pose A a los atributos, saltando de cuatro en cuatro
	exx			;4bd5
	ld hl,04b84h		;4bd6
	call SUMA_A_HL		;4bd9
	ld de,0e07ah		;4bdc
	ld b,004h		;4bdf
POSE_BUCLE:
	ld a,(hl)		;4be1
	ld (de),a		;4be2
	ld a,004h		;4be3
	add a,e			;4be5
	ld e,a			;4be6
	inc hl			;4be7
	djnz POSE_BUCLE		;4be8
	exx			;4bea
	ret			;4beb
COLOCA_SPRITES:		; Reparte HL (Y en L, X en H) por los cuatro sprites, sumando 16 a la derecha y abajo
	ld d,h			;4bec
	ld (0e078h),hl		;4bed
	ld a,h			;4bf0
	add a,010h		;4bf1
	ld h,a			;4bf3
	ld (0e07ch),hl		;4bf4
	ld a,l			;4bf7
	add a,010h		;4bf8
	ld l,a			;4bfa
	ld e,a			;4bfb
	ld (0e080h),de		;4bfc
	ld (0e084h),hl		;4c00
	ret			;4c03

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; EL SALTO
; ----------------------------------------------------------------------
; Once pasos, uno cada cuatro fotogramas, contados en 0xE0F9.
; Mientras dura, la Y del pinguino se corrige con la curva de
; 0x4C80, que sube cuatro pixeles y baja otros cuatro; y si el
; gatillo se pulso con una direccion metida, ademas se mueve al
; doble de velocidad hacia ese lado.
; ----------------------------------------------------------------------
EMPIEZA_SALTO:		; Gatillo: suena el salto y se apunta hacia donde va
	ld a,002h		;4c04
	call PIDE_SONIDO		;4c06   ; Sonido 2
	ld a,b			;4c09
	and 00ch		;4c0a   ; Bits 2 y 3: izquierda y derecha
	jr z,SALTO_SENTIDO		;4c0c
	ld a,(0e0fah)		;4c0e
	and 003h		;4c11
SALTO_SENTIDO:
	ld (0e0fbh),a		;4c13
	jr SALTO_PASO		;4c16
SIGUE_SALTO:		; Un paso de salto cada cuatro fotogramas
	ld a,(0e003h)		;4c18
	and 003h		;4c1b
	ret nz			;4c1d
SALTO_PASO:
	ld a,(hl)		;4c1e
	inc (hl)		;4c1f
	cp 00bh			;4c20   ; Once pasos y vuelta a cero
	jr nz,SALTO_POSE		;4c22
	ld (hl),000h		;4c24
SALTO_POSE:
	push af			;4c26
	ld c,000h		;4c27
	cp 00bh			;4c29
	jr z,SALTO_COLOCA		;4c2b
	ld c,010h		;4c2d
	rra			;4c2f
	jr c,SALTO_COLOCA		;4c30
	ld c,00ch		;4c32
SALTO_COLOCA:
	ld a,c			;4c34
	call PONE_POSE		;4c35
	pop af			;4c38
	ld hl,04c80h		;4c39   ; La curva del salto, que se suma a la Y
	call SUMA_A_HL		;4c3c
	ld a,(hl)		;4c3f
	ld de,(0e078h)		;4c40
	add a,e			;4c44
	ld e,a			;4c45
	ld hl,0e0fbh		;4c46
	ld a,(hl)		;4c49
	dec a			;4c4a
	jr z,SALTO_A_LA_IZQUIERDA		;4c4b   ; 0xE0FB dice si el salto lleva ademas movimiento lateral
	dec a			;4c4d
	jr z,SALTO_A_LA_DERECHA		;4c4e
SALTO_TERMINA:
	ex de,hl		;4c50
	call PINGUINO_SPRITES		;4c51
	ld a,(0e0f9h)		;4c54
	or a			;4c57
	ret nz			;4c58
	call MIRA_CHOQUES		;4c59   ; La sombra
	ld a,(0e140h)		;4c5c
	ld hl,0e142h		;4c5f
	add a,(hl)		;4c62
	ret nz			;4c63
	ld hl,0e132h		;4c64
	cp (hl)			;4c67
	ret z			;4c68
	ld (hl),a		;4c69
	ld de,00030h		;4c6a   ; Treinta puntos por saltar (?)
	jp SUMA_AL_MARCADOR		;4c6d
SALTO_A_LA_IZQUIERDA:
	call MUEVE_IZQUIERDA		;4c70
	call MUEVE_IZQUIERDA		;4c73
	jr SALTO_TERMINA		;4c76
SALTO_A_LA_DERECHA:
	call MUEVE_DERECHA		;4c78
	call MUEVE_DERECHA		;4c7b
	jr SALTO_TERMINA		;4c7e

; ----------------------------------------------------------------------
; DATOS curva_del_salto: Doce correcciones con signo para la Y del pinguino: -4,-3,-3,-2,-1,-1,+1,+1,+2,+3,+3,+4. Es el arco del salto, y tambien el balanceo de andar
;   0x4c80..0x4c8c  (12 bytes)
; ----------------------------------------------------------------------
	defb 0fch,0fdh,0fdh,0feh,0ffh,0ffh,001h,001h,002h,003h,003h,004h	; 4c80  ............

; ======================================================================
; CODIGO 0x4c8c..0x4d2a  (158 bytes)
; ======================================================================


MUEVE_A_LOS_LADOS:		; Mueve al pinguino a izquierda o derecha segun los bits 2 y 3 de los mandos
	and 00ch		;4c8c   ; Sin izquierda ni derecha no hay nada que hacer
	ret z			;4c8e
	ld hl,0e0fah		;4c8f
	cp 00ch			;4c92   ; Las dos a la vez: se mantiene el sentido que llevaba
	jr z,MANTIENE_SENTIDO		;4c94
	res 7,(hl)		;4c96
	cp 004h			;4c98
	jr nz,MUEVE_DERECHA		;4c9a
MUEVE_IZQUIERDA:		; Una columna a la izquierda; el borde esta en X=0x14
	ld a,d			;4c9c
	cp 014h			;4c9d
	ret c			;4c9f
	dec d			;4ca0
	set 0,(hl)		;4ca1
	res 1,(hl)		;4ca3
	ret			;4ca5
MANTIENE_SENTIDO:		; Con las dos direcciones metidas sigue por donde iba, mirando los bits de 0xE0FA
	ld a,(hl)		;4ca6
	or a			;4ca7
	ret z			;4ca8
	bit 7,a			;4ca9
	jr z,SENTIDO_CAMBIA		;4cab
	bit 0,a			;4cad
	jr nz,MUEVE_IZQUIERDA		;4caf
	jr MUEVE_DERECHA		;4cb1
SENTIDO_CAMBIA:
	set 7,(hl)		;4cb3
	bit 1,a			;4cb5
	jr nz,MUEVE_IZQUIERDA		;4cb7
MUEVE_DERECHA:		; Una columna a la derecha; el borde esta en X=0xCC
	ld a,d			;4cb9
	cp 0cch			;4cba
	ret nc			;4cbc
	set 1,(hl)		;4cbd
	res 0,(hl)		;4cbf
	inc d			;4cc1
	ret			;4cc2
ANIMA_ANDAR:		; Las tres poses de andar, una cada ocho fotogramas. La llama la interrupcion, no el paso de partida
	ld hl,0e0f9h		;4cc3   ; Ni saltando ni en la escena de la base
	ld a,(0e130h)		;4cc6
	or (hl)			;4cc9
	ret nz			;4cca
	ld a,(0e003h)		;4ccb
	and 007h		;4cce
	ret nz			;4cd0
ANDAR_PASO:
	ld hl,0e0f8h		;4cd1
	inc (hl)		;4cd4
	ld a,(hl)		;4cd5
	ld c,000h		;4cd6
	rra			;4cd8
	jr nc,ANDAR_POSE		;4cd9
	ld c,004h		;4cdb
	rra			;4cdd
	jr nc,ANDAR_POSE		;4cde
	ld c,008h		;4ce0
ANDAR_POSE:
	ld a,c			;4ce2
	call PONE_POSE		;4ce3
	jp PINGUINO_A_VRAM		;4ce6
COLOCA_SOMBRA:		; Los dos sprites de debajo del pinguino, que se separan siguiendo el arco del salto o el de la caida
	ld hl,(0e078h)		;4ce9
	ld a,l			;4cec
	add a,01eh		;4ced
	ld l,a			;4cef
	ld c,a			;4cf0
	ld a,h			;4cf1
	add a,010h		;4cf2
	ld b,a			;4cf4
	ld de,04d29h		;4cf5   ; La tabla del salto, apuntada un byte antes (ver la nota de abajo)
	ld a,(0e0f9h)		;4cf8
	or a			;4cfb
	jr nz,SOMBRA_SEPARA		;4cfc
	ld de,04d33h		;4cfe   ; Y la de la caida
	ld a,(0e143h)		;4d01
	or a			;4d04
	jr z,SOMBRA_GUARDA		;4d05
SOMBRA_SEPARA:
	ex de,hl		;4d07
	call SUMA_A_HL		;4d08
	ld l,(hl)		;4d0b
	ld a,d			;4d0c
	add a,l			;4d0d
	ld d,a			;4d0e
	ld a,b			;4d0f
	sub l			;4d10
	ld b,a			;4d11
	ld e,0aeh		;4d12
	ld c,0aeh		;4d14
	ex de,hl		;4d16
SOMBRA_GUARDA:
	ld (0e0a0h),hl		;4d17
	ld (0e0a4h),bc		;4d1a
SOMBRA_A_VRAM:
	ld hl,0e0a0h		;4d1e
	ld de,03b50h		;4d21   ; Sprites 20 y 21
	ld bc,00008h		;4d24
	jp COPIA_A_VRAM		;4d27

; ----------------------------------------------------------------------
; DATOS arco_del_salto: Diez alturas, indexadas de 1 a 10 desde 0x4D29: lo que se separa la sombra en cada paso del salto
;   0x4d2a..0x4d34  (10 bytes)
; DATOS arco_de_la_caida: Veintiuna alturas, indexadas de 1 a 21 desde 0x4D33 con 0xE143, que es el contador de la caida. Cierra clavada en 0x4D49
;   0x4d34..0x4d49  (21 bytes)
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; TRES TABLAS QUE SE APUNTAN UN BYTE ANTES DE EMPEZAR
; ----------------------------------------------------------------------
; El indice de las tres empieza en 1, nunca en 0, asi que en vez
; de restarle uno se apunta a la direccion anterior y se deja
; que el byte 0 caiga donde caiga: 0x4D29 es el ultimo byte de un
; `jp`, 0x4D33 es el ultimo dato de la tabla de encima y 0x4EEC
; es un RET. Ninguna de las tres lee su byte cero.
; ----------------------------------------------------------------------
	defb 001h,002h,002h,003h,003h,003h,003h,003h,002h,002h,001h,001h,002h,002h,003h,002h	; 4d2a  ................
	defb 002h,001h,000h,001h,002h,002h,002h,001h,000h,001h,002h,002h,002h,001h,000h	; 4d3a  ...............

; ======================================================================
; CODIGO 0x4d49..0x4dc8  (127 bytes)
; ======================================================================


MIRA_CHOQUES:		; Con el pinguino en el suelo: recorre las fichas y mira si alguna esta en el paso 13 a su altura
	ld a,(0e0f9h)		;4d49
	or a			;4d4c
	ret nz			;4d4d
	ld b,004h		;4d4e
	ld a,(0e0e0h)		;4d50   ; A partir de la fase 5 hay una ficha mas
	cp 005h			;4d53
	jr c,CHOQUES_EMPIEZA		;4d55
	inc b			;4d57
CHOQUES_EMPIEZA:
	ld hl,0e112h		;4d58
CHOQUES_FICHA:
	ld a,(hl)		;4d5b
	cp 00dh			;4d5c   ; El paso 13 es el que esta a la altura del pinguino
	ld a,005h		;4d5e
	jr nz,CHOQUES_SIGUIENTE		;4d60
	inc hl			;4d62
	ld c,(hl)		;4d63
	inc hl			;4d64
	inc hl			;4d65
	inc hl			;4d66
	ld e,(hl)		;4d67
	inc hl			;4d68
	ld d,(hl)		;4d69
	ex de,hl		;4d6a
	dec a			;4d6b
	cp c			;4d6c
	ld a,(0e079h)		;4d6d   ; La X del pinguino
	jr nc,CHOQUES_AGUJERO		;4d70
	sub (hl)		;4d72
	inc hl			;4d73
	cp (hl)			;4d74
	jp c,COGE_OBJETO		;4d75   ; Tipos 5 y 6: se cogen y dan puntos
	jr CHOQUES_NADA		;4d78
CHOQUES_AGUJERO:
	ld c,(hl)		;4d7a
	dec c			;4d7b
	jr z,CHOQUES_BORDE		;4d7c
	ld c,a			;4d7e
	sub (hl)		;4d7f
	inc hl			;4d80
	cp (hl)			;4d81
	jp c,CAE_AL_AGUA		;4d82   ; El hueco de dentro: se cae al agua
	ld a,c			;4d85
CHOQUES_BORDE:
	inc hl			;4d86
	sub (hl)		;4d87
	inc hl			;4d88
	cp (hl)			;4d89
	jp c,TROPIEZA		;4d8a   ; Y el borde: tropieza
CHOQUES_NADA:
	ex de,hl		;4d8d
	xor a			;4d8e
CHOQUES_SIGUIENTE:
	inc a			;4d8f
	call SUMA_A_HL		;4d90
	djnz CHOQUES_FICHA		;4d93
	ret			;4d95
MIRA_CHOQUES_SALTANDO:		; Lo mismo, pero en el aire: solo mira una lista propia, la de 0x4DC8
	ld a,(0e0f9h)		;4d96
	or a			;4d99
	ret z			;4d9a
	ld b,005h		;4d9b
	ld hl,0e112h		;4d9d
SALTANDO_FICHA:
	ld a,(hl)		;4da0
	inc hl			;4da1
	cp 00dh			;4da2
	ld a,005h		;4da4
	jr nz,SALTANDO_SIGUIENTE		;4da6
	ex de,hl		;4da8
	ld a,(de)		;4da9
	cp 005h			;4daa
	add a,a			;4dac
	ld hl,04dc8h		;4dad
	call SUMA_A_HL		;4db0
	ld a,(0e079h)		;4db3
	sub (hl)		;4db6
	inc hl			;4db7
	cp (hl)			;4db8
	jr c,SALTANDO_ACIERTA		;4db9
	ex de,hl		;4dbb
SALTANDO_SIGUIENTE:
	call SUMA_A_HL		;4dbc
	djnz SALTANDO_FICHA		;4dbf
	ret			;4dc1
SALTANDO_ACIERTA:
	ld a,001h		;4dc2   ; 0xE132: se ha saltado por encima, y eso se premia en 0x4C6A
	ld (0e132h),a		;4dc4
	ret			;4dc7

; ----------------------------------------------------------------------
; DATOS choque_en_el_aire: Cinco pares (posicion, ancho) para los choques con el pinguino saltando: 0x58/0x30, 0x18/0x30, 0x98/0x30, 0x2C/0x58 y 0x64/0x58
;   0x4dc8..0x4dd2  (10 bytes)
; ----------------------------------------------------------------------
	defb 058h,030h,018h,030h,098h,030h,02ch,058h,064h,058h	; 4dc8  X0.0.0,XdX

; ======================================================================
; CODIGO 0x4dd2..0x4eed  (283 bytes)
; ======================================================================


MIRA_EL_PEZ:		; Si el pinguino pisa el pez, suena, se lo lleva y suma 300 puntos
	ld a,(0e142h)		;4dd2
	ld hl,0e140h		;4dd5
	add a,(hl)		;4dd8
	ret nz			;4dd9
	ld de,(0e188h)		;4dda
	ld a,e			;4dde
	cp 0e0h			;4ddf   ; 0xE0 en la Y: el pez no esta en la pantalla
	ret z			;4de1
	ld hl,(0e078h)		;4de2
	sub l			;4de5
	ld e,a			;4de6
	sub 00ah		;4de7   ; Tiene que estar a menos de diez pixeles en vertical
	ret nc			;4de9
	ld a,013h		;4dea
	add a,e			;4dec
	ld l,a			;4ded
	ld a,e			;4dee
	add a,a			;4def
	add a,017h		;4df0
	ld e,a			;4df2
	ld a,d			;4df3
	sub h			;4df4
	sub l			;4df5
	add a,e			;4df6
	ret nc			;4df7
	ld a,007h		;4df8
	call PIDE_SONIDO		;4dfa   ; Sonido 7
	ld hl,0e08ch		;4dfd
	ld de,0e183h		;4e00
	call QUITA_EL_PEZ		;4e03
	call PEZ_PASO		;4e06
	ld de,00300h		;4e09   ; Trescientos puntos
	jp SUMA_AL_MARCADOR		;4e0c
MIRA_EL_BORDE:		; Choque con lo que haya en 0xE090 cuando esta abajo del todo
	ld hl,(0e090h)		;4e0f
	ld a,l			;4e12
	cp 08fh			;4e13
	ret nz			;4e15
	ld a,(0e079h)		;4e16
	ld l,a			;4e19
	ld a,h			;4e1a
	sub l			;4e1b
	push af			;4e1c
	sub 018h		;4e1d
	add a,023h		;4e1f
	jp c,CHOCA		;4e21
	pop af			;4e24
	ret			;4e25
TROPIEZA:		; El pinguino tropieza y rueda hacia el lado por el que iba
	ld a,(0e135h)		;4e26   ; Durante la escena de la base no se tropieza
	or a			;4e29
	ret nz			;4e2a
	ld a,003h		;4e2b
	call PIDE_SONIDO		;4e2d   ; Sonido 3
	ld hl,00101h		;4e30
	ld a,(0e0fah)		;4e33
	cpl			;4e36
	rra			;4e37
	jr PONE_CAIDA		;4e38
CHOCA:		; Choque de frente: se cae hacia atras
	ld hl,00101h		;4e3a
	ld (0e136h),hl		;4e3d
	ld a,008h		;4e40
	call PIDE_SONIDO		;4e42   ; Sonido 8
	ld hl,00102h		;4e45
	ld a,(0e0f9h)		;4e48
	or a			;4e4b
	jr z,CAIDA_RECUPERA		;4e4c
	inc l			;4e4e
CAIDA_RECUPERA:
	pop af			;4e4f
PONE_CAIDA:		; Deja la caida montada en 0xE142 y le pone la pose
	ld (0e142h),hl		;4e50
	ld a,020h		;4e53   ; Pose 0x20 o 0x24 segun el lado
	jr nc,CAIDA_POSE		;4e55
	ld a,024h		;4e57
CAIDA_POSE:
	ld (0e144h),a		;4e59
	call PONE_POSE		;4e5c
	call PINGUINO_A_VRAM		;4e5f
	ld hl,01313h		;4e62   ; Y la velocidad baja a 0x13
	ld (0e100h),hl		;4e65
	ret			;4e68
SIGUE_CAIDA:		; Un paso de caida cada cuatro fotogramas: rueda de lado y baja
	ld a,(0e003h)		;4e69
	and 003h		;4e6c
	ret nz			;4e6e
	ld hl,0e142h		;4e6f
	ld a,(hl)		;4e72
	cp 003h			;4e73   ; Tres pasos y se acaba
	jp z,CAIDA_TERCER_PASO		;4e75
	inc hl			;4e78
	ld a,(hl)		;4e79
	inc (hl)		;4e7a
	ld hl,RET_COMPARTIDO		;4e7b   ; El desplazamiento de este paso, apuntado un byte antes
	call SUMA_A_HL		;4e7e
	ld c,(hl)		;4e81
	ld de,(0e078h)		;4e82
CAIDA_LADO:
	ld hl,0e0d0h		;4e86
	ld a,(0e144h)		;4e89
	bit 2,a			;4e8c   ; Bit 2 de 0xE144: hacia que lado rueda
	call z,TRES_A_LA_IZQUIERDA	;4e8e
	call nz,TRES_A_LA_DERECHA	;4e91
	ld hl,0e142h		;4e94
	ld a,(hl)		;4e97
	dec a			;4e98
	jr z,CAIDA_COLOCA		;4e99
	dec (hl)		;4e9b
	jr CAIDA_LADO		;4e9c
CAIDA_COLOCA:
	ex de,hl		;4e9e
	ld a,l			;4e9f
	add a,c			;4ea0
	ld l,a			;4ea1
	call PINGUINO_SPRITES		;4ea2
	ld a,(0e078h)		;4ea5
	cp 090h			;4ea8   ; Y=0x90: ya ha llegado abajo
	jr nz,CAIDA_CUENTA		;4eaa
CAIDA_ABAJO:
	ld a,004h		;4eac
	call PIDE_SONIDO		;4eae   ; Sonido 4
	call PISTA_GRUPO_B		;4eb1
	call PISTA_SIGUIENTE		;4eb4
	xor a			;4eb7
	ld b,a			;4eb8
	ld hl,0e136h		;4eb9
	cp (hl)			;4ebc
	jr z,CAIDA_REPINTA		;4ebd
	ld (hl),a		;4ebf
	inc a			;4ec0
	ld (0e135h),a		;4ec1
CAIDA_REPINTA:
	call MUEVE_OBSTACULOS		;4ec4
	xor a			;4ec7
	ld (0e135h),a		;4ec8
CAIDA_CUENTA:
	ld hl,0e143h		;4ecb
	ld a,(hl)		;4ece
	sub 015h		;4ecf   ; Veintiun pasos y se acabo la caida
	ret nz			;4ed1
	ld (hl),a		;4ed2
	dec hl			;4ed3
	ld (hl),a		;4ed4
	ld (0e137h),a		;4ed5
	ret			;4ed8
TRES_A_LA_DERECHA:		; Tres columnas de golpe
	call MUEVE_DERECHA		;4ed9
	call MUEVE_DERECHA		;4edc
	jp MUEVE_DERECHA		;4edf
TRES_A_LA_IZQUIERDA:
	call MUEVE_IZQUIERDA		;4ee2
	call MUEVE_IZQUIERDA		;4ee5
	call MUEVE_IZQUIERDA		;4ee8
	xor a			;4eeb
RET_COMPARTIDO:		; Un RET que ademas hace de base de la tabla de al lado
	ret			;4eec

; ----------------------------------------------------------------------
; DATOS rodada_de_la_caida: Veinte desplazamientos con signo, indexados de 1 a 20 desde 0x4EEC con 0xE143. Son tres tramos casi iguales: cada vuelta el pinguino rueda un poco menos
;   0x4eed..0x4f01  (20 bytes)
; ----------------------------------------------------------------------
	defb 0fdh,0feh,0feh,0ffh,001h,002h,002h,003h,0feh,0feh,0ffh,001h,002h,002h,0feh,0feh	; 4eed  ................
	defb 0ffh,001h,002h,002h	; 4efd  ....

; ======================================================================
; CODIGO 0x4f01..0x5145  (580 bytes)
; ======================================================================


CAIDA_TERCER_PASO:		; El tercer paso de la caida, que ya es levantarse
	ld hl,0e0f9h		;4f01
	ld a,(hl)		;4f04
	inc (hl)		;4f05
	cp 00bh			;4f06
	jr nz,CAIDA_LEVANTA		;4f08
	ld (hl),000h		;4f0a
CAIDA_LEVANTA:
	push af			;4f0c
	ld a,(0e144h)		;4f0d
	ld c,a			;4f10
	call PONE_POSE		;4f11
	pop af			;4f14
	ld hl,04c80h		;4f15   ; La misma curva que el salto
	call SUMA_A_HL		;4f18
	ld a,(hl)		;4f1b
	ld de,(0e078h)		;4f1c
	add a,e			;4f20
	ld e,a			;4f21
	bit 2,c			;4f22
	ld hl,0e0d0h		;4f24
	call z,TRES_A_LA_IZQUIERDA		;4f27
	call nz,TRES_A_LA_DERECHA		;4f2a
	ex de,hl		;4f2d
	call PINGUINO_SPRITES		;4f2e
	ld a,(0e0f9h)		;4f31
	or a			;4f34
	ret nz			;4f35
	ld a,001h		;4f36
	ld (0e135h),a		;4f38
	call CAIDA_ABAJO		;4f3b
	xor a			;4f3e
	ld (0e135h),a		;4f3f
	dec hl			;4f42
	inc a			;4f43
	ld (hl),a		;4f44
	ld a,004h		;4f45
	call PIDE_SONIDO		;4f47   ; Sonido 4
	ret			;4f4a

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
	ld hl,00001h		;4f4b
	ld (0e140h),hl		;4f4e   ; 0xE140: esta en el agua
	xor a			;4f51
	ld (0e142h),a		;4f52
	ld a,0ffh		;4f55
	ld (0e0f8h),a		;4f57
	ld a,005h		;4f5a
	call PIDE_SONIDO		;4f5c   ; Sonido 5
	ld hl,0e068h		;4f5f
	ld bc,004b6h		;4f62
AGUA_SPRITES:
	ld (hl),c		;4f65
	ld a,004h		;4f66
	call SUMA_A_HL		;4f68
	djnz AGUA_SPRITES		;4f6b

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LAS PATAS AMARILLAS, QUE SON LA SOMBRA PINTADA DE OTRO COLOR
; ----------------------------------------------------------------------
; Mientras el pinguino chapotea en el agujero se le ven dos patas
; amarillas moviendose. No hay un sprite nuevo para eso: es el
; MISMO atributo que hace de sombra, al que estas dos
; instrucciones le cambian el color de azul oscuro a amarillo.
; Luego 0x4FC6 le va poniendo los patrones 0x70, 0x74 y 0x78,
; que son las patas en tres posturas, y al salir del agua
; 0x5012 le devuelve el patron 0xA0 y el color 4.
; Es la misma idea que las banderas o la foca: el color de un
; sprite no esta en su dibujo, esta en su entrada de atributo,
; asi que se puede cambiar sin tocar un solo byte de grafico.
; ----------------------------------------------------------------------
DIBUJA_EN_EL_AGUA:		; Coloca al pinguino asomando por el agujero, en Y=0x9F, y le PONE LAS PATAS AMARILLAS
	ld hl,(0e078h)		;4f6d
	ld l,09fh		;4f70
	call COLOCA_SPRITES		;4f72
	ld a,010h		;4f75
	call PONE_POSE		;4f77
	ld a,0e0h		;4f7a
	ld (0e0a0h),a		;4f7c   ; Saca de la pantalla el sprite de la sombra...
	ld hl,0e00ah		;4f7f   ; ...y con este par de bytes le cambia el COLOR a 0x0A, que es amarillo, y aparca el de al lado
	ld (0e0a3h),hl		;4f82
VUELCA_OCHO_SPRITES:		; Los ocho atributos de 0xE068 a la VRAM, sprites 6 a 13
	ld hl,0e068h		;4f85
	ld de,03b18h		;4f88
	ld bc,00020h		;4f8b
	call COPIA_A_VRAM		;4f8e
	jp SOMBRA_A_VRAM		;4f91
SIGUE_EN_EL_AGUA:		; Manotea hasta que se pulsa el gatillo
	ld hl,0e141h		;4f94
	inc (hl)		;4f97
	res 7,(hl)		;4f98
	ld a,(hl)		;4f9a
	cp 020h			;4f9b   ; Los primeros 32 fotogramas no vale pulsar
	jr c,DIBUJA_EN_EL_AGUA		;4f9d
	call LEE_GATILLOS_NUEVOS		;4f9f
	jr nz,SALE_DEL_AGUA		;4fa2
	ld a,(0e003h)		;4fa4
	ld c,a			;4fa7
	and 007h		;4fa8   ; Las patas cambian cada ocho fotogramas
	ret nz			;4faa
	ld a,008h		;4fab
	ld b,099h		;4fad
	ld de,01470h		;4faf   ; Los tres patrones de pataleo: 0x70, 0x74 y 0x78
	bit 3,c			;4fb2
	jr z,AGUA_ANIMA		;4fb4
	ld a,004h		;4fb6
	ld b,096h		;4fb8
	ld de,01874h		;4fba
	bit 4,c			;4fbd
	jr z,AGUA_ANIMA		;4fbf
	ld a,00bh		;4fc1
	ld de,01c78h		;4fc3
AGUA_ANIMA:		; Mueve las patas: el patron va cambiando entre 0x70, 0x74 y 0x78, y la posicion los sigue
	ld hl,(0e078h)		;4fc6
	ld l,b			;4fc9
	add a,h			;4fca
	ld c,a			;4fcb
	ld a,b			;4fcc
	ld b,e			;4fcd
	ld (0e0a1h),bc		;4fce
	add a,010h		;4fd2
	ld (0e0a0h),a		;4fd4
	push de			;4fd7
	call COLOCA_SPRITES		;4fd8
	pop af			;4fdb
	call PONE_POSE		;4fdc
	jp VUELCA_OCHO_SPRITES		;4fdf
SALE_DEL_AGUA:		; Con el gatillo se sale, y la velocidad vuelve a 0x13
	xor a			;4fe2
	ld (0e140h),a		;4fe3
	ld (0e0f8h),a		;4fe6
	ld hl,00313h		;4fe9
	ld (0e100h),hl		;4fec
	ld a,(0e079h)		;4fef
	push af			;4ff2
	ld hl,066f0h		;4ff3
	ld de,0e068h		;4ff6
	ld c,004h		;4ff9
	call REPITE_4_BYTES		;4ffb
	ld b,004h		;4ffe
SALIDA_SPRITES:
	ld c,(hl)		;5000
	inc hl			;5001
	push bc			;5002
	call REPITE_4_BYTES		;5003
	pop bc			;5006
	djnz SALIDA_SPRITES		;5007
	pop hl			;5009
	ld l,090h		;500a
	call COLOCA_SPRITES		;500c
	ld hl,004a0h		;500f
	ld (0e0a2h),hl		;5012
	call PINGUINO_A_VRAM		;5015
	call VUELCA_ATRIBUTOS		;5018
	ret			;501b
COGE_OBJETO:		; Tipos 5 y 6: se borra la ficha, se repinta el hueco y suma 500 puntos
	ex de,hl		;501c
	dec hl			;501d
	dec hl			;501e
	ld d,(hl)		;501f
	dec hl			;5020
	ld e,(hl)		;5021
	dec hl			;5022
	dec hl			;5023
	ld (hl),000h		;5024
	ex de,hl		;5026
	inc hl			;5027
	ld de,0e1a0h		;5028   ; Los trece bytes del dibujo se copian a RAM para poder rematarlos con un cero
	ld bc,0000dh		;502b
	ldir			;502e
	xor a			;5030
	ld (de),a		;5031
	ld a,006h		;5032
	call PIDE_SONIDO		;5034   ; Sonido 6
	ld hl,0e1a0h		;5037
	call DIBUJA_BLOQUE		;503a
	ld de,00500h		;503d   ; Quinientos puntos
	call SUMA_AL_MARCADOR		;5040
	ret			;5043
MONTA_LA_PISTA:		; Monta la pista de la fase: colores, cielo, hielo, decorados y la lista de lo que va saliendo
	ld a,(0e0e1h)		;5044   ; La fase elige la pareja de colores
	ld hl,05195h		;5047
	call SUMA_A_HL		;504a
	ld a,007h		;504d
	bit 0,(hl)		;504f
	jr z,PISTA_COLORES		;5051
	ld a,009h		;5053
PISTA_COLORES:
	ld (0e10ch),a		;5055
	ld a,(hl)		;5058
	ld hl,05de4h		;5059   ; Dos juegos de colores comprimidos, uno para cada tipo de fase
	ld de,06246h		;505c
	or a			;505f
	jr z,PISTA_DESCOMPRIME		;5060
	ld hl,05defh		;5062
	ld de,06263h		;5065
PISTA_DESCOMPRIME:
	push de			;5068
	ld de,04588h		;5069
	call DESCOMPRIME_DE		;506c
	pop hl			;506f
	ld de,04f78h		;5070
	call DESCOMPRIME_DE		;5073
	ld de,03860h		;5076   ; El cielo, con la casilla 7 o la 9
	ld bc,000e0h		;5079
	ld a,(0e10ch)		;507c
	call RELLENA_VRAM		;507f
	ld de,03940h		;5082   ; Y el hielo, con la 0x0F
	ld bc,001c0h		;5085
	ld a,00fh		;5088
	call RELLENA_VRAM		;508a
	ld hl,07251h		;508d
	call PINTA_DECORADO		;5090
	ld hl,0728eh		;5093
	call PINTA_DECORADO		;5096
	ld hl,05145h		;5099   ; Ocho bytes por fase: la lista de decorados que van saliendo
	ld a,(0e0e1h)		;509c
	add a,a			;509f
	add a,a			;50a0
	add a,a			;50a1
	call SUMA_A_HL		;50a2
	ld (0e10ah),hl		;50a5
	xor a			;50a8
	ld (0e102h),a		;50a9
	ld (0e108h),a		;50ac
	ld hl,07249h		;50af
	ld (0e103h),hl		;50b2
	ld hl,07286h		;50b5
	ld (0e105h),hl		;50b8
	call PISTA_GRUPO_B		;50bb
	call PISTA_GRUPO_A		;50be
	ret			;50c1
SIGUIENTE_DECORADO:		; Coge el siguiente decorado de la lista de la fase; 0xFF quiere decir que ya no hay mas
	ld hl,0e108h		;50c2
	ld a,(hl)		;50c5
	inc (hl)		;50c6
	ld hl,(0e10ah)		;50c7
	call SUMA_A_HL		;50ca
	ld a,(hl)		;50cd
	cp 0ffh			;50ce
	ret z			;50d0
	ld (0e109h),a		;50d1
	ld bc,0e103h		;50d4
	bit 0,a			;50d7
	jr z,DECORADO_GRUPO		;50d9
	inc bc			;50db
	inc bc			;50dc
DECORADO_GRUPO:
	add a,a			;50dd
	ld hl,07241h		;50de   ; Los cuatro grupos de decorado
	call SUMA_A_HL		;50e1
	ld a,(hl)		;50e4
	ld e,a			;50e5
	ld (bc),a		;50e6
	inc hl			;50e7
	inc bc			;50e8
	ld a,(hl)		;50e9
	ld d,a			;50ea
	ld (bc),a		;50eb
	ex de,hl		;50ec
	ld a,008h		;50ed
	call SUMA_A_HL		;50ef
PINTA_DECORADO:		; Pinta un decorado: franjas, cadena y las dieciseis casillas que se guardan en 0xE1xx
	call PINTA_FRANJAS		;50f2
	call ESCRIBE_CADENA		;50f5
	ld e,(hl)		;50f8
DECORADO_CASILLAS:
	ld a,(0e10ch)		;50f9   ; Los ceros se cambian por la casilla del cielo de esta fase
	ld c,a			;50fc
	ld b,010h		;50fd
	ld d,0e1h		;50ff
DECORADO_BUCLE:
	inc hl			;5101
	ld a,(hl)		;5102
	or a			;5103
	jr nz,DECORADO_CASILLA		;5104
	ld a,c			;5106
DECORADO_CASILLA:
	ld (de),a		;5107
	inc de			;5108
	djnz DECORADO_BUCLE		;5109
PINTA_FILA_DE_PISTA:		; Escribe la fila compuesta en 0xE14E, que va siempre a la fila 9
	ld de,03920h		;510b
	ld (0e14eh),de		;510e
	ld a,0ffh		;5112
	ld (0e170h),a		;5114
	ld hl,0e14eh		;5117
	call ESCRIBE_CADENA		;511a
	xor a			;511d
	ret			;511e
AVANZA_DECORADO:		; Cada 400 metros toca decorado nuevo
	call DESPLAZA_LA_PISTA		;511f
	ld hl,0e107h		;5122
	ld a,(hl)		;5125
	dec a			;5126
	ret nz			;5127
	ld a,(0e102h)		;5128
	dec a			;512b
	ret nz			;512c
	ld (hl),a		;512d
	call SIGUIENTE_DECORADO		;512e
	or a			;5131
	ret nz			;5132
	ld hl,(0e103h)		;5133
	ld a,(0e109h)		;5136
	bit 0,a			;5139
	jr z,DECORADO_DIBUJA		;513b
	ld hl,(0e105h)		;513d
DECORADO_DIBUJA:
	xor a			;5140
	call PISTA_DIBUJA		;5141
	ret			;5144

; ----------------------------------------------------------------------
; DATOS decorados_por_fase: Ocho bytes por fase, diez fases: la lista de decorados que van saliendo. Un 0xFF acaba la lista y los 0x77 son relleno
;   0x5145..0x5195  (80 bytes)
; DATOS color_por_fase: Un byte por fase: con 0 el cielo es la casilla 7 y con 1 la 9. Cierra clavada en 0x519F, donde vuelve a haber codigo
;   0x5195..0x519f  (10 bytes)
; ----------------------------------------------------------------------
	defb 002h,003h,000h,001h,077h,077h,077h,077h,003h,002h,001h,000h,077h,077h,077h,077h	; 5145  ....wwww....wwww
	defb 003h,0ffh,001h,077h,077h,077h,077h,077h,0ffh,002h,000h,077h,077h,077h,077h,077h	; 5155  ...wwwww...wwwww
	defb 003h,0ffh,001h,077h,077h,077h,077h,077h,0ffh,077h,077h,077h,077h,077h,077h,077h	; 5165  ...wwwww.wwwwwww
	defb 002h,003h,000h,002h,001h,000h,0ffh,077h,002h,0ffh,000h,077h,077h,077h,077h,077h	; 5175  .......w...wwwww
	defb 002h,000h,003h,001h,077h,077h,077h,077h,0ffh,003h,001h,077h,077h,077h,077h,077h	; 5185  ....wwww...wwwww
	defb 000h,000h,001h,000h,001h,001h,000h,000h,001h,000h	; 5195  ..........

; ======================================================================
; CODIGO 0x519f..0x52cb  (300 bytes)
; ======================================================================


AVANZA_LA_PISTA:		; Al ritmo de la velocidad, va sacando los trozos de decorado y moviendo los obstaculos
	ld hl,0e100h		;519f
	ld c,(hl)		;51a2
	inc hl			;51a3
	dec (hl)		;51a4
	jr z,PISTA_RECARGA		;51a5
	ld a,(hl)		;51a7
	cp 003h			;51a8
	jp z,AVANZA_DECORADO		;51aa
	dec a			;51ad
	jr nz,PISTA_MIRA		;51ae
PISTA_GRUPO_B:
	ld hl,(0e105h)		;51b0
	ld a,(0e102h)		;51b3
	jr PISTA_DIBUJA		;51b6
PISTA_RECARGA:
	ld (hl),c		;51b8
PISTA_SIGUIENTE:
	ld hl,0e102h		;51b9
	ld a,(hl)		;51bc
	inc (hl)		;51bd
	res 2,(hl)		;51be
PISTA_GRUPO_A:
	ld hl,(0e103h)		;51c0
PISTA_DIBUJA:		; Dibuja el trozo A de la tabla que apunta HL
	add a,a			;51c3
	call SUMA_A_HL		;51c4
	ld e,(hl)		;51c7
	inc hl			;51c8
	ld d,(hl)		;51c9
	ex de,hl		;51ca
	call DIBUJA_BLOQUE		;51cb
	ret			;51ce
PISTA_MIRA:
	ld b,000h		;51cf
	dec a			;51d1
	jr z,MUEVE_OBSTACULOS		;51d2
	inc b			;51d4
	srl c			;51d5
	ld a,(hl)		;51d7
	cp c			;51d8
	ret nz			;51d9
MUEVE_OBSTACULOS:		; Da un paso a cada ficha de obstaculo y dibuja el trozo que le toca
	ld hl,0e112h		;51da
	ld c,b			;51dd
	ld b,004h		;51de
	ld a,(0e0e0h)		;51e0   ; Cuatro fichas, y cinco a partir de la fase 5
	cp 005h			;51e3
	jr c,OBSTACULO_FICHA		;51e5
	inc b			;51e7
OBSTACULO_FICHA:
	ld a,c			;51e8
	or a			;51e9
	jr z,OBSTACULO_PASO		;51ea
	ld a,(hl)		;51ec
	cp 00bh			;51ed
	ld a,006h		;51ef
	jr c,OBSTACULO_SIGUIENTE		;51f1
OBSTACULO_PASO:
	ld a,(hl)		;51f3
	or a			;51f4
	ld a,006h		;51f5
	jr z,OBSTACULO_SIGUIENTE		;51f7
	inc (hl)		;51f9
	ld a,(hl)		;51fa
	cp 010h			;51fb   ; Quince pasos y la ficha vuelve a quedar libre
	jr c,OBSTACULO_DIBUJA		;51fd
	ld (hl),000h		;51ff
OBSTACULO_DIBUJA:
	inc hl			;5201
	inc hl			;5202
	ld e,(hl)		;5203   ; El trozo de dibujo que toca, que avanza en cada paso
	inc hl			;5204
	ld d,(hl)		;5205
	ex de,hl		;5206
	push de			;5207
	push bc			;5208
	call DIBUJA_BLOQUE		;5209
	pop bc			;520c
	pop de			;520d
	inc hl			;520e
	ex de,hl		;520f
	ld (hl),d		;5210
	dec hl			;5211
	ld (hl),e		;5212
	ld a,004h		;5213
OBSTACULO_SIGUIENTE:
	call SUMA_A_HL		;5215
	djnz OBSTACULO_FICHA		;5218
	call SUELTA_EL_PEZ		;521a
	call ANIMA_LA_FOCA		;521d
	call MIRA_CHOQUES		;5220
	call MIRA_CHOQUES_SALTANDO		;5223
	ret			;5226
CREA_OBSTACULO:		; Cada cierto numero de pasos mete un obstaculo nuevo en la primera ficha libre
	call MIRA_SORPRESA		;5227
	ld hl,(0e0e5h)		;522a   ; Con menos de 0x186 metros por delante ya no salen mas
	ld a,h			;522d
	and a			;522e
	jr nz,CREA_CUENTA		;522f
	ld a,l			;5231
	cp 086h			;5232
	ret c			;5234
CREA_CUENTA:
	ld hl,0e10eh		;5235   ; 0xE10E es el periodo y 0xE10F la cuenta
	ld a,(hl)		;5238
	inc hl			;5239
	dec (hl)		;523a
	ret nz			;523b
	ld (hl),a		;523c
	ld hl,0e112h		;523d
	ld b,003h		;5240
	ld a,(0e0e0h)		;5242
	cp 005h			;5245
	jr c,CREA_BUSCA_FICHA		;5247
	inc b			;5249
CREA_BUSCA_FICHA:
	ld a,(hl)		;524a
	or a			;524b
	jr z,CREA_EN_ESTA		;524c
	ld a,006h		;524e
	call SUMA_A_HL		;5250
	djnz CREA_BUSCA_FICHA		;5253
	ret			;5255
CREA_EN_ESTA:
	inc (hl)		;5256
	inc hl			;5257
	ex de,hl		;5258
	ld hl,0e111h		;5259
	inc (hl)		;525c
	res 3,(hl)		;525d
	ld a,(hl)		;525f
	ld hl,(0e18bh)		;5260   ; Que obstaculo toca sale de la lista que dejo ELIGE_DECORADO
	call SUMA_A_HL		;5263
	ld c,(hl)		;5266
	push de			;5267
	call HAY_SORPRESA		;5268
	pop de			;526b
	ld a,c			;526c
	inc a			;526d
	jr z,CREA_NADA		;526e
	dec a			;5270
	bit 4,a			;5271   ; Bit 4: el obstaculo viene emparejado con otro
	jr z,CREA_CORRE		;5273
	ld hl,0e190h		;5275
	ld (hl),001h		;5278
	inc hl			;527a
	and 003h		;527b
	ld c,a			;527d
	ld (hl),a		;527e
	jr CREA_RELLENA		;527f
CREA_CORRE:
	ld a,c			;5281
	or a			;5282
	jr z,CREA_RELLENA		;5283
	ld a,(0e0fch)		;5285   ; Con el pinguino en la mitad derecha, el obstaculo se corre uno
	or a			;5288
	jr z,CREA_RELLENA		;5289
	inc c			;528b
CREA_RELLENA:
	ex de,hl		;528c
	call RELLENA_FICHA		;528d
	ld a,(0e190h)		;5290
	rra			;5293
	ret nc			;5294
	ld a,(0e191h)		;5295
	cpl			;5298
	and 003h		;5299
	ld c,a			;529b
	ld hl,0e12ah		;529c
	ld a,(hl)		;529f
	or a			;52a0
	jr nz,CREA_PAREJA_FIN		;52a1
	inc (hl)		;52a3
	inc hl			;52a4
	call RELLENA_FICHA		;52a5
CREA_PAREJA_FIN:
	ld hl,0e190h		;52a8
	ld (hl),000h		;52ab
	ret			;52ad
CREA_NADA:
	ex de,hl		;52ae
	dec hl			;52af
	ld (hl),a		;52b0
	ret			;52b1
RELLENA_FICHA:		; Copia a la ficha el tipo, el puntero de dibujo y el de choque, sacados de la tabla de al lado
	ld (hl),c		;52b2
	inc hl			;52b3
	ld de,052cbh		;52b4
	ld a,c			;52b7
	add a,a			;52b8
	ld c,a			;52b9
	add a,a			;52ba
	add a,c			;52bb
	call SUMA_A_DE		;52bc
	ld a,(de)		;52bf
	ld (hl),a		;52c0
	inc de			;52c1
	inc hl			;52c2
	ld a,(de)		;52c3
	ld (hl),a		;52c4
	inc de			;52c5
	inc hl			;52c6
	ld (hl),e		;52c7
	inc hl			;52c8
	ld (hl),d		;52c9
	ret			;52ca

; ----------------------------------------------------------------------
; DATOS tabla_de_obstaculos: Los SIETE obstaculos, seis bytes cada uno: los dos primeros son el puntero al primer trozo de dibujo, y los cuatro siguientes los pares (posicion, ancho) con los que se mira el choque. Los siete dibujos caen dentro de los 92 trozos de 0x6BE9-0x7241, que es lo que confirma para que son. Cierra clavada en 0x52F5
;   0x52cb..0x52f5  (42 bytes)
; ----------------------------------------------------------------------
	defb 019h,06fh,001h,053h,03ah,000h,0d2h,06fh,001h,013h,03bh,000h,091h,070h,001h,092h	; 52cb  .o.S:..o..;..p..
	defb 03bh,000h,0e9h,06bh,02bh,05bh,010h,090h,085h,06dh,064h,053h,048h,088h,0c8h,071h	; 52db  ;..k+[...mdSH..q
	defb 080h,02ch,000h,000h,050h,071h,02eh,02ch,000h,000h	; 52eb  .,..Pq.,..

; ======================================================================
; CODIGO 0x52f5..0x53e1  (236 bytes)
; ======================================================================


MIRA_LA_CURVA:		; Cada 512 metros mira en la tabla de nibbles que curva toca y monta el cambio
	ld hl,(0e0e5h)		;52f5
	ld a,h			;52f8
	and 001h		;52f9
	ret z			;52fb
	ld a,l			;52fc
	cp 082h			;52fd
	ret nz			;52ff
	ld hl,0e0e2h		;5300
	ld a,(hl)		;5303
	inc (hl)		;5304
	srl a			;5305   ; Dos curvas por byte: el acarreo dice si toca la mitad alta o la baja
	push af			;5307
	ld hl,053e1h		;5308
	call SUMA_A_HL		;530b
	pop af			;530e
	ld a,(hl)		;530f
	jr c,CURVA_MONTA		;5310
	rra			;5312
	rra			;5313
	rra			;5314
	rra			;5315
CURVA_MONTA:
	ld c,a			;5316
	and 003h		;5317
	cp 003h			;5319
	ret z			;531b
	bit 3,c			;531c
	jr z,CURVA_GUARDA		;531e
	set 1,a			;5320
CURVA_GUARDA:
	ld hl,0e194h		;5322
	ld (hl),a		;5325
	inc hl			;5326
	bit 2,c			;5327
	jr z,CURVA_RITMO		;5329
	ld (hl),002h		;532b
CURVA_RITMO:
	inc hl			;532d
	ld (hl),001h		;532e
	inc hl			;5330
	ld (hl),000h		;5331
	inc hl			;5333
	ld a,(0e100h)		;5334   ; La velocidad marca cada cuantos fotogramas se desplaza la pista
	srl a			;5337
	srl a			;5339
	ld (hl),a		;533b
	call RETOCA_DECORADO_B		;533c
PINTA_HORIZONTE:		; Dibuja el horizonte que corresponde a la curva
	ld hl,05402h		;533f
PINTA_HORIZONTE_HL:
	ld a,(0e194h)		;5342
	add a,a			;5345
	call SUMA_A_HL		;5346
	ld e,(hl)		;5349
	inc hl			;534a
	ld d,(hl)		;534b
	ex de,hl		;534c
	call ESCRIBE_CADENA		;534d
	ret			;5350
DESPLAZA_LA_PISTA:		; Gira la fila de 32 casillas a un lado o al otro: eso es la curva
	ld a,(0e196h)		;5351
	or a			;5354
	ret z			;5355
	ld bc,0001fh		;5356
	ld a,(0e194h)		;5359
	rra			;535c   ; Bit 0 de 0xE194: a que lado gira
	jr c,DESPLAZA_DERECHA		;535d
	ld a,(0e150h)		;535f   ; Hacia la izquierda, con LDIR
	ld hl,0e151h		;5362
	ld de,0e150h		;5365
	ldir			;5368
	ld (0e16fh),a		;536a
	jr DESPLAZA_PINTA		;536d
DESPLAZA_DERECHA:
	ld a,(0e16fh)		;536f   ; Hacia la derecha, con LDDR
	ld hl,0e16eh		;5372
	ld de,0e16fh		;5375
	lddr			;5378
	ld (0e150h),a		;537a
DESPLAZA_PINTA:
	call PINTA_FILA_DE_PISTA		;537d
	ld hl,0e197h		;5380
	inc (hl)		;5383
	ld a,(hl)		;5384
	and 00fh		;5385
	jr nz,CURVA_ENDEREZA		;5387
	dec hl			;5389
	dec hl			;538a
	cp (hl)			;538b
	jr z,CURVA_ENDEREZA		;538c
	dec (hl)		;538e
	jr nz,CURVA_ENDEREZA		;538f
	dec hl			;5391
	ld a,(hl)		;5392
	xor 001h		;5393
	ld (hl),a		;5395
	call PINTA_HORIZONTE		;5396
CURVA_ENDEREZA:
	ld hl,(0e0e5h)		;5399
	ld a,h			;539c
	and 001h		;539d
	ret nz			;539f
	ld a,l			;53a0
	cp 045h			;53a1   ; Con menos de 0x145 metros la pista se endereza para llegar a la base
	ret nc			;53a3
	ld hl,0e197h		;53a4
	ld a,(hl)		;53a7
	and 00fh		;53a8
	ret nz			;53aa
	dec hl			;53ab
	ld (hl),a		;53ac
	ld hl,0540ah		;53ad
	call PINTA_HORIZONTE_HL		;53b0
	call RETOCA_DECORADO		;53b3
ARRASTRA_PINGUINO:		; En las curvas el pinguino se va de lado solo, al ritmo de la velocidad
	ld hl,0e196h		;53b6
	ld a,(hl)		;53b9
	or a			;53ba
	ret z			;53bb
	inc hl			;53bc
	inc hl			;53bd
	dec (hl)		;53be
	ret nz			;53bf
	ld a,(0e100h)		;53c0
	srl a			;53c3
	srl a			;53c5
	ld (hl),a		;53c7
	ld hl,0e0d1h		;53c8
	ld de,(0e078h)		;53cb
	ld a,(0e194h)		;53cf
	rra			;53d2
	jr c,ARRASTRA_DERECHA		;53d3
	call MUEVE_IZQUIERDA		;53d5
	jp PINGUINO_COLOCA		;53d8
ARRASTRA_DERECHA:
	call MUEVE_DERECHA		;53db
	jp PINGUINO_COLOCA		;53de

; ----------------------------------------------------------------------
; DATOS curvas_por_fase: Sesenta y seis curvas en treinta y tres bytes, a nibble por curva: 0x5305 elige la mitad alta o la baja. Cierra con el 0xFF de 0x5401, justo delante de los punteros
;   0x53e1..0x5402  (33 bytes)
; DATOS punteros_del_horizonte: Ocho punteros a los siete dibujos de horizonte (dos apuntan al mismo). Cierra clavada en 0x5412, que es el primero de ellos
;   0x5402..0x5412  (16 bytes)
; DATOS dibujos_del_horizonte: Los siete horizontes, en el formato de las cadenas: recto, curva a un lado, curva al otro, y los cuatro de la llegada a la base. Todos escriben en las filas 10 y 11. Acaba clavado en 0x54C1
;   0x5412..0x54c1  (175 bytes)
; ----------------------------------------------------------------------
	defb 0f8h,0ffh,0ffh,0ffh,099h,0f8h,08fh,0f9h,0f9h,0ffh,0ffh,088h,01fh,0f9h,0f9h,00fh	; 53e1  ................
	defb 01fh,0ffh,08fh,099h,0ffh,081h,00fh,0ffh,0f8h,08fh,0ffh,08fh,099h,0ffh,0f0h,099h	; 53f1  ................
	defb 0ffh,012h,054h,023h,054h,045h,054h,064h,054h,034h,054h,034h,054h,0a2h,054h,083h	; 5401  ..T#TETdT4T4T.T.
	defb 054h,049h,039h,014h,014h,013h,013h,015h,030h,030h,031h,010h,010h,010h,032h,033h	; 5411  TI9.....001...23
	defb 023h,0ffh,049h,039h,023h,074h,032h,010h,010h,010h,031h,030h,030h,015h,013h,013h	; 5421  #.I9#t2...100...
	defb 014h,014h,0ffh,049h,039h,015h,014h,013h,012h,052h,010h,00fh,00fh,010h,011h,012h	; 5431  ...I9....R......
	defb 013h,014h,015h,0ffh,049h,039h,014h,014h,013h,013h,015h,030h,030h,031h,010h,010h	; 5441  ....I9.....001..
	defb 010h,041h,047h,053h,053h,054h,054h,054h,054h,054h,054h,054h,054h,0feh,072h,039h	; 5451  .AGSSTTTTTTTT.r9
	defb 00fh,03eh,0ffh,040h,039h,054h,054h,054h,054h,054h,054h,054h,054h,053h,053h,088h	; 5461  .>.@9TTTTTTTTSS.
	defb 082h,010h,010h,010h,031h,030h,030h,015h,013h,013h,014h,014h,0feh,06ch,039h,07fh	; 5471  ....100......l9.
	defb 00fh,0ffh,040h,039h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h	; 5481  ..@9............
	defb 004h,07dh,07ah,00fh,00fh,010h,011h,012h,013h,014h,015h,0feh,06ch,039h,079h,078h	; 5491  .}z.........l9yx
	defb 0ffh,049h,039h,015h,014h,013h,012h,052h,010h,00fh,00fh,039h,03ch,004h,004h,004h	; 54a1  .I9....R...9<...
	defb 004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,0feh,072h,039h,037h,038h,0ffh	; 54b1  ...........r978.

; ======================================================================
; CODIGO 0x54c1..0x554c  (139 bytes)
; ======================================================================


RETOCA_DECORADO:		; Con la pista torcida, cambia las casillas del decorado para que encajen
	ld hl,072e7h		;54c1
	jr RETOCA_LADO		;54c4
RETOCA_DECORADO_B:		; La otra entrada, con el otro juego de casillas
	ld hl,07275h		;54c6
RETOCA_LADO:
	ld a,(0e194h)		;54c9
	bit 1,a			;54cc
	ret z			;54ce
	rra			;54cf
	ld a,(hl)		;54d0
	jr nc,RETOCA_ESCRIBE		;54d1
	sub 010h		;54d3
RETOCA_ESCRIBE:
	ld e,a			;54d5
	jp DECORADO_CASILLAS		;54d6
ANDA_HASTA_LA_BASE:		; Dieciseis pasos subiendo por la pantalla, interpolando la X entre donde estaba y donde esta la bandera
	ld a,(0e003h)		;54d9   ; Un paso cada cuatro fotogramas
	and 003h		;54dc
	ret nz			;54de
	inc c			;54df   ; Con C=0xFF se calcula la X de destino; con C=0 se sigue con la que habia
	jr nz,BASE_ANDA		;54e0
	ld a,(0e139h)		;54e2
	ld c,a			;54e5
	xor a			;54e6
	ld b,a			;54e7
	ld hl,00070h		;54e8
	sbc hl,bc		;54eb
	ld a,(0e138h)		;54ed
	ld b,a			;54f0
	ld e,l			;54f1
	ld d,h			;54f2
BASE_MULTIPLICA:
	add hl,de		;54f3   ; Multiplicar sumando: no hay instruccion de multiplicar
	djnz BASE_MULTIPLICA		;54f4
	ld a,h			;54f6
	rlca			;54f7
	rlca			;54f8
	rlca			;54f9
	rlca			;54fa
	and 0f0h		;54fb
	ld e,a			;54fd
	ld a,l			;54fe
	rrca			;54ff
	rrca			;5500
	rrca			;5501
	rrca			;5502
	and 00fh		;5503
	or e			;5505
	add a,c			;5506
	ld h,a			;5507
BASE_ANDA:
	ld a,(0e078h)		;5508
	dec a			;550b   ; Una linea mas arriba en cada paso
	ld l,a			;550c
	call COLOCA_SPRITES		;550d
	call ANDAR_PASO		;5510
	ld hl,0e138h		;5513
	inc (hl)		;5516
	ld a,010h		;5517   ; Dieciseis pasos
	cp (hl)			;5519
	ret			;551a
DIBUJA_LA_BASE:		; Empieza a dibujar la base
	xor a			;551b
	ld (0e13ah),a		;551c
DIBUJA_LA_BASE_PASO:		; Alterna los dos bloques de la escena de la base
	ld hl,0e13ah		;551f
	ld a,(hl)		;5522
	inc (hl)		;5523
	ld hl,0554ch		;5524
	rra			;5527
	jr nc,BASE_DIBUJA		;5528
	ld hl,05560h		;552a
BASE_DIBUJA:
	call DIBUJA_BLOQUE		;552d
	ret			;5530
DIBUJA_EL_POLO:		; El remate del POLO SUR: descomprime cuatro sprites mas (0x6B81 -> VRAM 0x1F80, o sea los patrones 0xF0, 0xF4, 0xF8 y 0xFC), copia sus cuatro atributos de 0x6746 encima de los numeros 7 a 10 -dos en amarillo y dos en negro- y dibuja un tercer bloque de casillas. Los cuatro completan al pinguino inclinado que dibujan las casillas: el pico y la mancha de la barriga en amarillo, el ala y el lomo en negro
	ld hl,06b81h		;5531
	call DESCOMPRIME		;5534
	ld hl,06746h		;5537
	ld de,0e06ch		;553a
	ld bc,00010h		;553d
	ldir			;5540
	call VUELCA_ATRIBUTOS		;5542
	ld hl,0556ah		;5545
	call DIBUJA_BLOQUE		;5548
	ret			;554b

; ----------------------------------------------------------------------
; DATOS bloque_base_a: Uno de los dos bloques que se van alternando para dibujar la base
;   0x554c..0x5560  (20 bytes)
; DATOS bloque_base_b: El otro
;   0x5560..0x556a  (10 bytes)
; DATOS bloque_base_polo: El tercero, el del remate de 0x5531
;   0x556a..0x557f  (21 bytes)
; ----------------------------------------------------------------------
	defb 0e1h,0efh,0b6h,0b7h,0eeh,0b8h,0b9h,0bah,0bbh,0eeh,0beh,0bfh,0c0h,0bch,0eeh,0c3h	; 554c  ................
	defb 0c4h,0c5h,0c6h,000h,002h,0eeh,0c2h,0eeh,0bdh,0c1h,0eeh,0c7h,0c8h,000h,0e1h,0eeh	; 555c  ................
	defb 0d2h,0d5h,0d8h,0eeh,0d3h,0d6h,0d9h,0dbh,0eeh,0d4h,0d7h,0dah,0dch,0eeh,0ddh,0deh	; 556c  ................
	defb 0dfh,00fh,000h	; 557c  ...

; ======================================================================
; CODIGO 0x557f..0x55d9  (90 bytes)
; ======================================================================


MONTA_LA_BASE:		; Escribe el nombre de la base y descomprime su bandera en los patrones de sprite
	ld hl,06650h		;557f   ; Los dibujos de la base, a la VRAM 0x1100
	ld de,05100h		;5582
	call DESCOMPRIME_DE		;5585
	ld hl,055d9h		;5588   ; El nombre que toca, de la tabla de las diez fases
	ld a,(0e0e1h)		;558b
	ld c,a			;558e
	add a,a			;558f
	call SUMA_A_HL		;5590
	ld e,(hl)		;5593
	inc hl			;5594
	ld d,(hl)		;5595
	ex de,hl		;5596
	call ESCRIBE_CADENA		;5597
	ld hl,0565ch		;559a   ; La bandera, indexada aparte con 0xE0E0
	ld a,(0e0e0h)		;559d
	and 00fh		;55a0
	add a,a			;55a2
	call SUMA_A_HL		;55a3
	ld e,(hl)		;55a6
	inc hl			;55a7
	ld d,(hl)		;55a8
	ex de,hl		;55a9
	ld de,05f40h		;55aa   ; VRAM 0x1F40: los patrones de sprite
	call DESCOMPRIME_DE		;55ad
	ld a,(hl)		;55b0   ; Y detras de la bandera van los dos colores
	ld (0e063h),a		;55b1
	inc hl			;55b4
	ld a,(hl)		;55b5
	ld (0e067h),a		;55b6
	jr BANDERA_A_VRAM		;55b9
SUBE_LA_BANDERA:		; Sube la bandera dos pixeles por llamada hasta Y=0x36, que es el tope del mastil
	ld a,(0e060h)		;55bb
	sub 002h		;55be
	cp 036h			;55c0
	ret z			;55c2
	ld (0e060h),a		;55c3
	ld (0e064h),a		;55c6
	ld (0e068h),a		;55c9
BANDERA_A_VRAM:		; Los TRES sprites de la bandera, a la VRAM. Son doce bytes, o sea tres atributos: el patron 0xE8 con el primer color, el 0xEC con el segundo, y el 0xE4 con blanco fijo. Ese tercero no viene en el flujo comprimido -sale de la carga general de sprites- y es un rectangulo blanco macizo de 16x12 que hace de fondo. Y como en un MSX el sprite de numero mas bajo va DELANTE, el orden de dibujo es blanco, segundo color y primer color encima
	ld hl,0e060h		;55cc
	ld de,03b10h		;55cf
	ld bc,0000ch		;55d2
	call COPIA_A_VRAM		;55d5
	ret			;55d8

; ----------------------------------------------------------------------
; DATOS punteros_de_las_bases: Diez punteros, uno por fase, a los nombres de las bases. Cierra clavada en 0x55ED, que es la primera cadena; con ocho, nueve, once o doce entradas no cierra
;   0x55d9..0x55ed  (20 bytes)
; DATOS nombres_de_las_bases: OCHO cadenas para diez fases: JAPAN, AUSTRALIA, FRANCE, NEW ZEALAND, ARGENTINA, UNITED KINGDOM, THE SOUTH POLE y USA. El reparto que sale de la tabla de arriba es FRANCE, USA, THE SOUTH POLE, USA, USA, ARGENTINA, UNITED KINGDOM, JAPAN, AUSTRALIA y AUSTRALIA. NEW ZEALAND (0x5611) NO LA VISITA NADIE: no esta en la tabla, ninguna instruccion la apunta, y ninguna de sus veinte direcciones aparece como palabra en los 16 KB
;   0x55ed..0x565c  (111 bytes)
; DATOS punteros_de_banderas: Diez punteros a los graficos de bandera. Cierra clavada en 0x5670
;   0x565c..0x5670  (20 bytes)
; DATOS banderas_comprimidas: Siete banderas distintas para diez ranuras. Los diez flujos miden entre 11 y 59 bytes y TODOS descomprimen a 64 bytes exactos, que son dos sprites de 16x16; detras de cada uno van sus dos colores
;   0x5670..0x57b7  (327 bytes)
; DATOS rotulos: Los rotulos de pantalla, en el formato de las cadenas: el panel (1P, HI, STAGE, TIME), (c)KONAMI 1984, PLAY SELECT con JOYSTICK y KEYBOARD, y TIME OUT
;   0x57b7..0x5839  (130 bytes)
; DATOS titulo_comprimido: La pantalla de titulo: relleno y el rotulo SOFTWARE en la fila 10. Pasado por el descompresor son veinte casillas en dos sitios (VRAM 0x394A y 0x396C) y el flujo se acaba en 0x584A
;   0x5839..0x584a  (17 bytes)
; DATOS mandos_de_la_demo: LOS MANDOS GRABADOS DE LA DEMO. Sesenta y cuatro bytes, uno cada 32 fotogramas: 0x41BA los apunta y 0x4103 los va leyendo. La demo dura 0x073C pasos, asi que gasta 58 de los 64. Cada byte lleva los mismos bits que el joystick, y se ve: 0x01 arriba, 0x09 arriba y derecha, 0x11 arriba y gatillo... La partida de demostracion no la juega ninguna inteligencia, va grabada. Cierra clavada en 0x588A, la primera instruccion de MONTA_LA_FUENTE
;   0x584a..0x588a  (64 bytes)
; ----------------------------------------------------------------------
	defb 005h,056h,020h,056h,049h,056h,020h,056h,020h,056h,028h,056h,036h,056h,0edh,055h	; 55d9  .V VIV V V(V6V.U
	defb 0f7h,055h,0f7h,055h,0cdh,03ah,020h,02ah,021h,030h,021h,02eh,020h,0ffh,0cbh,03ah	; 55e9  .U.U.: *!0!. ..:
	defb 020h,021h,035h,033h,034h,032h,021h,02ch,029h,021h,020h,0ffh,0cch,03ah,020h,0c9h	; 55f9   !5342!,)! ..: .
	defb 032h,021h,02eh,023h,025h,020h,0ffh,0cah,03ah,020h,02eh,025h,0cah,00fh,0cbh,025h	; 5609  2!.#% ..: .%...%
	defb 021h,02ch,021h,02eh,024h,020h,0ffh,0ceh,03ah,020h,035h,033h,021h,020h,0ffh,0cbh	; 5619  !,!.$ ..: 53! ..
	defb 03ah,020h,021h,032h,027h,025h,02eh,034h,029h,02eh,021h,020h,0ffh,0c8h,03ah,020h	; 5629  : !2'%.4).! ..: 
	defb 035h,02eh,029h,034h,025h,024h,00fh,02bh,029h,02eh,027h,024h,02fh,02dh,020h,0ffh	; 5639  5.)4%$.+).'$/- .
	defb 0c8h,03ah,020h,034h,028h,025h,00fh,033h,02fh,035h,034h,028h,00fh,030h,02fh,02ch	; 5649  .: 4(%.3/54(.0/,
	defb 025h,020h,0ffh,089h,056h,0b8h,056h,0f1h,056h,075h,057h,0f1h,056h,0f1h,056h,015h	; 5659  % ..V.V.VuW.V.V.
	defb 057h,038h,057h,070h,056h,089h,056h,002h,000h,082h,003h,007h,003h,00fh,082h,007h	; 5669  W8WpV.V.........
	defb 003h,009h,000h,082h,080h,0c0h,003h,0e0h,082h,0c0h,080h,027h,000h,000h,006h,00fh	; 5679  ...........'....
	defb 087h,0cch,06dh,00ch,0ffh,00ch,06dh,0cch,009h,000h,087h,0c0h,080h,000h,0c0h,000h	; 5689  ..m...m.........
	defb 080h,0c0h,009h,000h,007h,000h,002h,0ffh,002h,0fbh,001h,0ffh,004h,000h,089h,03fh	; 5699  ...............?
	defb 03bh,03fh,03dh,02fh,03bh,03fh,0ffh,0f7h,003h,0ffh,004h,000h,000h,006h,00dh,010h	; 56a9  ;?=/;?..........
	defb 000h,00ch,03fh,004h,000h,00ch,0f8h,014h,000h,000h,006h,004h,087h,0cch,06dh,00ch	; 56b9  ..?...........m.
	defb 0ffh,00ch,06dh,0cch,009h,000h,087h,0c0h,080h,000h,0c0h,000h,080h,0c0h,009h,000h	; 56c9  ..m.............
	defb 007h,000h,005h,0ffh,004h,000h,08ch,03fh,03fh,037h,03fh,03bh,02fh,03fh,0ffh,0ffh	; 56d9  .......??7?;/?..
	defb 0f7h,0ffh,0ffh,004h,000h,000h,006h,00dh,007h,000h,085h,0ffh,000h,0ffh,000h,0ffh	; 56e9  ................
	defb 005h,000h,08bh,0ffh,000h,0ffh,000h,0ffh,000h,0ffh,000h,0ffh,000h,0ffh,004h,000h	; 56f9  ................
	defb 086h,055h,0aah,055h,0aah,055h,0aah,01ah,000h,000h,006h,004h,004h,000h,084h,001h	; 5709  .U.U.U..........
	defb 003h,003h,001h,00ch,000h,084h,080h,0c0h,0c0h,080h,008h,000h,004h,0ffh,004h,000h	; 5719  ................
	defb 004h,0ffh,004h,000h,004h,0ffh,004h,000h,004h,0ffh,004h,000h,000h,00ah,007h,08ch	; 5729  ................
	defb 061h,031h,019h,00dh,001h,0ffh,0ffh,001h,00dh,019h,031h,061h,004h,000h,08ch,086h	; 5739  a1........1a....
	defb 08ch,098h,0b0h,080h,0ffh,0ffh,080h,0b0h,098h,08ch,086h,004h,000h,084h,00ch,084h	; 5749  ................
	defb 0c0h,0e0h,004h,000h,084h,0e0h,0c0h,084h,00ch,004h,000h,084h,030h,021h,003h,007h	; 5759  ............0!..
	defb 004h,000h,084h,007h,003h,021h,030h,004h,000h,000h,008h,005h,08bh,003h,004h,00ah	; 5769  .....!0.........
	defb 00ch,02ch,03eh,018h,008h,008h,00ch,007h,005h,000h,08bh,0c0h,020h,050h,010h,030h	; 5779  .,>......... P.0
	defb 078h,01ch,014h,010h,030h,0e0h,005h,000h,085h,000h,000h,002h,001h,003h,003h,000h	; 5789  x...0...........
	defb 083h,000h,000h,018h,005h,000h,085h,000h,000h,040h,080h,0c0h,003h,000h,083h,000h	; 5799  .........@......
	defb 000h,018h,005h,000h,000h,001h,00ah,00ch,038h,028h,029h,020h,0feh,016h,038h,033h	; 57a9  ........8() ..83
	defb 034h,021h,027h,025h,020h,0feh,022h,038h,034h,029h,02dh,025h,020h,0feh,02ch,038h	; 57b9  4!'% ."84)-% .,8
	defb 038h,03ah,03bh,000h,000h,000h,000h,040h,041h,0feh,036h,038h,026h,031h,037h,0feh	; 57c9  8:;....@A.68&17.
	defb 002h,038h,011h,030h,020h,0ffh,00ah,039h,01ah,02bh,02fh,02eh,021h,02dh,029h,000h	; 57d9  .8.0 ..9.+/.!-).
	defb 011h,019h,018h,014h,0ffh,0abh,039h,030h,02ch,021h,039h,000h,033h,025h,02ch,025h	; 57e9  ......90,!9.3%,%
	defb 023h,034h,0feh,006h,03ah,011h,020h,03ch,03dh,000h,000h,030h,02ch,021h,039h,000h	; 57f9  #4..:. <=..0,!9.
	defb 03eh,03fh,000h,02ah,02fh,039h,033h,034h,029h,023h,02bh,0feh,046h,03ah,012h,020h	; 5809  >?.*/934)#+.F:. 
	defb 03ch,03dh,000h,000h,030h,02ch,021h,039h,000h,03eh,03fh,000h,02bh,025h,039h,022h	; 5819  <=..0,!9.>?.+%9"
	defb 02fh,021h,032h,024h,0ffh,0ech,038h,034h,029h,02dh,025h,000h,02fh,035h,034h,0ffh	; 5829  /!2$..84)-%./54.
	defb 04ah,039h,00ch,01dh,080h,06ch,039h,088h,033h,02fh,01bh,034h,01ch,021h,032h,025h	; 5839  J9...l9.3/.4.!2%
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,009h,001h,001h	; 5849  ................
	defb 011h,005h,005h,009h,009h,001h,006h,004h,010h,001h,001h,011h,010h,001h,001h,009h	; 5859  ................
	defb 009h,001h,005h,015h,009h,019h,001h,001h,005h,011h,001h,001h,001h,011h,001h,001h	; 5869  ................
	defb 001h,011h,001h,000h,018h,019h,009h,001h,011h,001h,001h,001h,001h,001h,001h,001h	; 5879  ................
	defb 001h	; 5889  .

; ======================================================================
; CODIGO 0x588a..0x58db  (81 bytes)
; ======================================================================


MONTA_LA_FUENTE:		; Monta la fuente y los colores en los tres bancos de la pantalla. OJO: que la fuente se escriba tres veces NO quiere decir que los tres bancos acaben iguales. Cada escena descomprime luego sus dibujos ENCIMA, banco por banco, y comparando los tres en una VRAM de verdad solo quedan iguales DIECINUEVE casillas: la 0x00-0x0F, que son los cuadrados de color liso, y la 0xFD-0xFF, que estan vacias. Cada tercio de la pantalla tiene su propio juego de 256 casillas, y por eso render_tiles.py saca una hoja por banco y no una para todo
	ld de,00000h		;588a
	call MONTA_UN_BANCO		;588d
	ld de,00800h		;5890
	call MONTA_UN_BANCO		;5893
	ld de,01000h		;5896
	jp MONTA_UN_BANCO		;5899
MONTA_UN_BANCO:		; Un banco: los dieciseis primeros caracteres en color liso, el resto blanco sobre negro, y encima la fuente
	push de			;589c
	xor a			;589d
	ld c,010h		;589e   ; Los caracteres 0 a 15 se pintan de un color liso cada uno: son los que se usan para rellenar el cielo y el hielo
BANCO_CARACTER:
	ld b,008h		;58a0
BANCO_LINEA:
	call ESCRIBE_BYTE_VRAM		;58a2
	inc de			;58a5
	djnz BANCO_LINEA		;58a6
	inc a			;58a8
	dec c			;58a9
	jr nz,BANCO_CARACTER		;58aa
	ld bc,00270h		;58ac   ; El resto del banco, blanco sobre negro
	ld a,0f0h		;58af
	call RELLENA_VRAM		;58b1
	ld hl,05db0h		;58b4   ; Y ahora los dibujos
	call DESCOMPRIME_SIGUE		;58b7
	ld b,016h		;58ba
BANCO_REPITE:
	ld hl,05de6h		;58bc   ; La misma tira veintidos veces
	push bc			;58bf
	call DESCOMPRIME_SIGUE		;58c0
	pop bc			;58c3
	djnz BANCO_REPITE		;58c4
	pop de			;58c6
	ld hl,06000h		;58c7   ; Los patrones del banco que toca
	add hl,de		;58ca
	ex de,hl		;58cb
	ld hl,058dbh		;58cc
	call DESCOMPRIME_DE		;58cf
	ld hl,05c5bh		;58d2
	call DESCOMPRIME_SIGUE		;58d5
	jp DESCOMPRIME_SIGUE		;58d8

; ----------------------------------------------------------------------
; DATOS fuente_comprimida: La fuente y el logotipo de KONAMI, que van a los tres bancos
;   0x58db..0x5df2  (1303 bytes)
; ----------------------------------------------------------------------
	defb 040h,000h,040h,000h,083h,000h,01ch,022h,003h,063h,085h,022h,01ch,000h,018h,038h	; 58db  @.@....".c."...8
	defb 004h,018h,0aeh,07eh,000h,03eh,063h,003h,00eh,03ch,070h,07fh,000h,03eh,063h,003h	; 58eb  ...~.>c..<p..>c.
	defb 00eh,003h,063h,03eh,000h,00eh,01eh,036h,066h,066h,07fh,006h,000h,07fh,060h,07eh	; 58fb  ..c>...6ff....`~
	defb 063h,003h,063h,03eh,000h,03eh,063h,060h,07eh,063h,063h,03eh,000h,07fh,063h,006h	; 590b  c.c>.>c`~cc>..c.
	defb 00ch,003h,018h,090h,000h,03eh,063h,063h,03eh,063h,063h,03eh,000h,03eh,063h,063h	; 591b  .....>cc>cc>.>cc
	defb 03fh,003h,063h,03eh,0a0h,03ch,042h,099h,0a1h,0a1h,099h,042h,03ch,000h,07fh,060h	; 592b  ?.c>.<B....B<..`
	defb 060h,07eh,060h,060h,060h,000h,063h,063h,06bh,06bh,07fh,077h,022h,000h,000h,000h	; 593b  `~```.cckk.w"...
	defb 0ffh,000h,000h,000h,000h,010h,000h,004h,000h,081h,07eh,004h,000h,092h,01ch,036h	; 594b  ..........~....6
	defb 063h,063h,07fh,063h,063h,000h,07eh,063h,063h,07eh,063h,063h,07eh,000h,03eh,063h	; 595b  cc.cc.~cc~cc~.>c
	defb 003h,060h,085h,063h,03eh,000h,07ch,066h,003h,063h,09bh,066h,07ch,000h,07fh,060h	; 596b  .`.c>.|f.c.f|..`
	defb 060h,07eh,060h,060h,07fh,000h,0eeh,0aah,08ah,0eah,02eh,0a8h,0e8h,000h,03eh,063h	; 597b  `~``..........>c
	defb 060h,067h,063h,063h,03fh,000h,003h,063h,081h,07fh,003h,063h,082h,000h,03ch,005h	; 598b  `gcc?..c...c..<.
	defb 018h,083h,03ch,000h,01fh,004h,006h,08bh,066h,03ch,000h,063h,066h,06ch,078h,07ch	; 599b  ..<.....f<.cflx|
	defb 06eh,067h,000h,006h,060h,093h,07fh,000h,063h,077h,07fh,07fh,06bh,063h,063h,000h	; 59ab  ng..`...cw..kcc.
	defb 063h,073h,07bh,07fh,06fh,067h,063h,000h,03eh,005h,063h,083h,03eh,000h,07eh,003h	; 59bb  cs{.ogc.>.c.>.~.
	defb 063h,09dh,07eh,060h,060h,000h,0eeh,088h,088h,0eeh,088h,088h,0eeh,000h,07eh,063h	; 59cb  c.~``.........~c
	defb 063h,062h,07ch,066h,063h,000h,03eh,063h,060h,03eh,003h,063h,03eh,000h,07eh,006h	; 59db  cb|fc.>c`>.c>.~.
	defb 018h,081h,000h,006h,063h,082h,03eh,000h,004h,063h,085h,036h,01ch,008h,000h,0c0h	; 59eb  ....c.>..c.6....
	defb 005h,0a0h,083h,0c0h,000h,0f3h,003h,0dbh,088h,0f3h,0d3h,0dbh,000h,066h,066h,07eh	; 59fb  .............ff~
	defb 03ch,003h,018h,08dh,000h,0dfh,01ah,018h,0cch,006h,016h,0deh,000h,0f8h,060h,060h	; 5a0b  <.............``
	defb 067h,003h,060h,0a8h,000h,000h,040h,049h,05ah,073h,052h,059h,000h,000h,000h,092h	; 5a1b  g.`...@IZsRY....
	defb 052h,0ceh,002h,0dch,000h,000h,002h,000h,08ah,0aah,0aah,0dah,000h,000h,008h,048h	; 5a2b  R..............H
	defb 0eeh,04ah,04ah,06ah,000h,000h,020h,024h,02dh,039h,029h,02dh,004h,000h,001h,0f0h	; 5a3b  .JJj.. $-9)-....
	defb 003h,050h,001h,000h,007h,0eeh,001h,000h,007h,0e0h,00eh,000h,082h,007h,00fh,006h	; 5a4b  .P..............
	defb 000h,082h,0f8h,0f0h,004h,03eh,004h,03fh,08bh,01fh,03fh,07fh,0ffh,0feh,0fch,0f8h	; 5a5b  .....>.?..?.....
	defb 0f0h,0e0h,0c0h,080h,003h,000h,002h,03eh,005h,000h,083h,01fh,07fh,0fbh,005h,000h	; 5a6b  .......>........
	defb 083h,00fh,0cfh,0efh,005h,000h,083h,078h,0fch,0bch,005h,000h,083h,03fh,07fh,0f3h	; 5a7b  .......x.....?..
	defb 005h,000h,083h,087h,0c7h,0c7h,005h,000h,083h,0bch,0feh,0dfh,005h,000h,088h,078h	; 5a8b  ...............x
	defb 0fch,0bch,060h,0f0h,0f0h,060h,000h,003h,0f0h,002h,03fh,006h,03eh,088h,0f8h,0fch	; 5a9b  ..`..`....?.>...
	defb 0feh,07fh,03fh,01fh,00fh,007h,003h,03eh,085h,07eh,0fch,0fch,0f8h,0e0h,005h,0f1h	; 5aab  ..?....>.~......
	defb 083h,0fbh,07fh,01fh,006h,0efh,082h,0cfh,00fh,008h,01eh,088h,0e1h,003h,03fh,0f1h	; 5abb  ..............?.
	defb 0e1h,0f3h,07fh,01eh,007h,0e7h,081h,0f7h,008h,08fh,008h,01eh,082h,0f1h,0f2h,004h	; 5acb  ................
	defb 0f5h,097h,0f2h,0f1h,0e0h,010h,0c8h,068h,0c8h,028h,010h,0e0h,000h,000h,008h,02eh	; 5adb  .......h.(......
	defb 06fh,07fh,03fh,07fh,000h,003h,007h,00fh,0dfh,003h,0ffh,083h,000h,0e0h,0fch,005h	; 5aeb  o.?.............
	defb 0ffh,004h,000h,090h,0e0h,0f0h,0fch,0ffh,000h,003h,003h,000h,001h,001h,003h,007h	; 5afb  ................
	defb 0c0h,080h,087h,0e7h,004h,0ffh,003h,000h,085h,0c0h,0f0h,0fch,0ffh,0ffh,004h,000h	; 5b0b  ................
	defb 089h,0c0h,0e0h,0e0h,0f0h,010h,018h,018h,01dh,01dh,003h,00fh,002h,01fh,002h,03fh	; 5b1b  ...............?
	defb 002h,07fh,002h,0ffh,002h,0f8h,003h,0e0h,003h,0f0h,083h,007h,003h,001h,005h,000h	; 5b2b  ................
	defb 088h,080h,0ceh,0ffh,07fh,00fh,00fh,01fh,000h,003h,0f8h,003h,0fch,08eh,0ffh,0c0h	; 5b3b  ................
	defb 000h,03eh,03fh,003h,003h,007h,006h,006h,01fh,01fh,00fh,08fh,003h,0cfh,089h,00fh	; 5b4b  .>?.............
	defb 000h,080h,0c0h,0c0h,0e0h,0e0h,0f0h,0f0h,003h,07fh,085h,0ffh,07fh,07fh,05fh,04ch	; 5b5b  .............._L
	defb 006h,0f0h,002h,0f8h,002h,07fh,004h,03fh,084h,07fh,07fh,0f8h,0fch,003h,0f0h,003h	; 5b6b  .......?........
	defb 0e0h,003h,07fh,087h,03fh,03fh,01fh,01fh,00fh,0c0h,080h,003h,000h,083h,080h,0c0h	; 5b7b  ....??..........
	defb 0c0h,004h,0ffh,084h,01fh,007h,000h,000h,003h,0ffh,097h,0feh,03eh,01ch,0c0h,000h	; 5b8b  ............>...
	defb 0ffh,0ffh,0feh,0feh,0fch,0fch,0f8h,0f0h,00fh,007h,007h,003h,003h,007h,01fh,01fh	; 5b9b  ................
	defb 0f0h,0f0h,004h,0e0h,082h,0c0h,080h,003h,01fh,082h,00fh,007h,003h,000h,005h,0ffh	; 5bab  ................
	defb 083h,0feh,0f0h,000h,005h,0ffh,083h,038h,000h,000h,085h,0feh,0fch,0f8h,0e0h,080h	; 5bbb  .......8........
	defb 003h,000h,08ah,07fh,067h,001h,003h,007h,007h,00fh,00fh,080h,0c0h,003h,0e0h,084h	; 5bcb  ....g...........
	defb 0c0h,0c0h,080h,00fh,005h,01fh,08fh,00fh,00fh,080h,0fch,0f8h,0f1h,0f3h,0f3h,0ffh	; 5bdb  ................
	defb 0ffh,001h,00fh,01fh,03fh,03fh,007h,0ffh,084h,0fdh,0fch,0fch,0f8h,005h,0ffh,084h	; 5beb  ....??..........
	defb 03fh,01fh,003h,0f8h,004h,0f0h,089h,030h,010h,000h,0ffh,0ffh,07fh,03fh,01fh,00fh	; 5bfb  ?......0.....?..
	defb 003h,003h,084h,007h,00fh,01fh,00fh,003h,007h,005h,000h,088h,001h,00fh,0ffh,000h	; 5c0b  ................
	defb 000h,001h,003h,03fh,006h,0ffh,085h,07fh,03fh,001h,000h,000h,006h,0ffh,082h,01fh	; 5c1b  ...?....?.......
	defb 000h,083h,040h,0e0h,040h,005h,000h,098h,0e0h,0a0h,080h,0e0h,020h,0a8h,0e8h,000h	; 5c2b  ..@.@....... ...
	defb 0eeh,0aah,0aah,0aah,0eah,08ah,08eh,000h,08eh,088h,088h,08eh,088h,088h,0eeh,000h	; 5c3b  ................
	defb 008h,000h,005h,000h,006h,00fh,00ah,000h,006h,0f0h,00ah,000h,006h,0ffh,005h,000h	; 5c4b  ................
	defb 006h,0c0h,004h,0ffh,010h,0c0h,00ch,000h,004h,0ffh,006h,000h,008h,003h,003h,007h	; 5c5b  ................
	defb 005h,000h,002h,0ffh,004h,0e0h,084h,0c0h,000h,0ffh,0ffh,013h,0c0h,006h,0e0h,005h	; 5c6b  ................
	defb 0c0h,000h,001h,003h,007h,001h,002h,003h,002h,007h,003h,00fh,083h,01fh,01eh,01eh	; 5c7b  ................
	defb 003h,03fh,08dh,07ch,078h,0f8h,0e0h,0e0h,0f0h,0f0h,0f8h,0f8h,078h,07ch,03ch,03ch	; 5c8b  .?.|x.......x|<<
	defb 003h,0feh,083h,01fh,00fh,00fh,006h,000h,084h,03bh,03fh,03fh,03bh,005h,039h,001h	; 5c9b  .........;??;.9.
	defb 0b9h,003h,000h,086h,003h,007h,007h,01fh,09fh,0dfh,005h,0c7h,082h,0c3h,0c1h,006h	; 5cab  ................
	defb 000h,08ah,0c7h,0cfh,0cfh,000h,00fh,01fh,09ch,0dfh,0cfh,0c7h,006h,000h,083h,0c3h	; 5cbb  ................
	defb 0e3h,0e3h,003h,0f3h,084h,073h,0f3h,0f3h,0bbh,006h,000h,08ah,018h,0b9h,0fbh,0f3h	; 5ccb  .....s..........
	defb 0c3h,083h,083h,081h,081h,080h,006h,000h,003h,0fbh,084h,0c0h,080h,080h,0c0h,003h	; 5cdb  ................
	defb 0f8h,086h,000h,001h,003h,063h,0e1h,0e0h,003h,0fbh,003h,0e3h,094h,0f3h,0fbh,07bh	; 5ceb  .....c.........{
	defb 03bh,000h,000h,080h,080h,000h,000h,08fh,09fh,0bfh,0bch,0b8h,0b8h,0bch,0bfh,09fh	; 5cfb  ;...............
	defb 08fh,006h,000h,003h,080h,004h,000h,003h,080h,002h,003h,002h,007h,003h,00fh,083h	; 5d0b  ................
	defb 01fh,01eh,01eh,003h,03fh,08dh,07ch,078h,0f8h,0e0h,0e0h,0f0h,0f0h,0f8h,0f8h,078h	; 5d1b  ....?.|x.......x
	defb 07ch,03ch,03ch,003h,0feh,083h,01fh,00fh,00fh,006h,000h,08bh,01eh,03fh,07fh,079h	; 5d2b  |<<..........?.y
	defb 070h,070h,078h,07fh,03fh,09eh,000h,005h,0e0h,001h,0efh,003h,0e7h,003h,0e3h,083h	; 5d3b  ppx.?...........
	defb 0e1h,0e1h,0e0h,006h,000h,08ah,01eh,01ch,0bch,0bdh,0b9h,0f9h,0f9h,0f0h,0f0h,0e0h	; 5d4b  ................
	defb 006h,000h,08ah,03ch,0feh,0eeh,0c7h,0ffh,0ffh,0c0h,0e7h,0ffh,03eh,006h,000h,084h	; 5d5b  ...<........>...
	defb 076h,07fh,07fh,07bh,006h,073h,003h,000h,086h,006h,00eh,00eh,03fh,03fh,0bfh,003h	; 5d6b  v..{.s......??..
	defb 08eh,084h,08fh,08fh,087h,083h,006h,000h,003h,0b9h,004h,039h,083h,0bdh,09fh,08eh	; 5d7b  ...........9....
	defb 006h,000h,085h,0dch,0ddh,0dfh,0dfh,0deh,005h,0dch,006h,000h,08ah,0c3h,0cfh,0ceh	; 5d8b  ................
	defb 0dch,01fh,01fh,01ch,00eh,00fh,003h,006h,000h,08ah,0c0h,0e0h,0e0h,070h,0f0h,0f0h	; 5d9b  .............p..
	defb 000h,070h,0f0h,0e0h,000h,018h,0f4h,078h,0f4h,070h,0f4h,050h,0f7h,020h,074h,028h	; 5dab  .p.....x.p.P. t(
	defb 01fh,020h,060h,010h,06ah,038h,0efh,002h,01eh,006h,01fh,002h,0efh,006h,07fh,00ah	; 5dbb  . `.j8..........
	defb 0e7h,00bh,0efh,006h,01fh,005h,0efh,038h,06fh,002h,016h,006h,01fh,002h,06fh,006h	; 5dcb  .......8o.....o.
	defb 07fh,00ah,067h,00bh,06fh,006h,01fh,005h,06fh,008h,017h,00ah,0f1h,003h,071h,002h	; 5ddb  ..g.o...o.....q.
	defb 051h,001h,041h,000h,008h,019h,000h	; 5deb  Q.A....

; ======================================================================
; CODIGO 0x5df2..0x5e22  (48 bytes)
; ======================================================================


CARGA_BANCO_1:		; Descomprime los dibujos del banco 1
	ld hl,05e22h		;5df2
	call DESCOMPRIME		;5df5
	ld hl,05e24h		;5df8
	ld de,06a88h		;5dfb
	call DESCOMPRIME_ESPEJO		;5dfe   ; Este va espejado: la mitad derecha del dibujo se saca dandole la vuelta a los bits de la izquierda
	call DESCOMPRIME		;5e01   ; Sin `ld hl` delante: sigue con el flujo que quedo
	ld hl,061aah		;5e04
	call DESCOMPRIME		;5e07
	ld hl,061b1h		;5e0a
	ld de,04a88h		;5e0d
	call DESCOMPRIME_DE		;5e10
	call DESCOMPRIME		;5e13
	ld hl,061afh		;5e16
	call DESCOMPRIME		;5e19
	ld hl,06280h		;5e1c
	jp DESCOMPRIME		;5e1f

; ----------------------------------------------------------------------
; DATOS dibujos_banco1: Dibujos y colores del banco 1, comprimidos
;   0x5e22..0x6263  (1089 bytes)
; DATOS colores_de_pista_b: LOS COLORES DE LA PISTA DEL SEGUNDO TIPO DE FASE: 29 bytes que descomprimen a 112 en la VRAM 0x0F78. Van EN PAREJA con los otros 29 de 0x6246-0x6262 -que son los del primer tipo y caen dentro del rango de arriba-, y 0x5044 elige entre las dos parejas mirando el bit 0 de la tabla de 0x5195 con la fase: o 0x5DE4 y 0x6246, o 0x5DEF y 0x6263. EL PUNTERO NO SE VE MIRANDO LAS INSTRUCCIONES DE AL LADO, y por eso el reconstructor se saltaba estos bytes: 0x5065 hace `ld de,06263h`, 0x5068 lo GUARDA EN LA PILA y quien lo usa es el `pop hl` de 0x506F, dos descompresiones despues. Es el mismo truco que la fuente en 0x58CF. Cierra clavado en 0x6280, donde empieza el remate del banco 1
;   0x6263..0x6280  (29 bytes)
; DATOS dibujos_banco1_resto: El remate del banco 1
;   0x6280..0x628f  (15 bytes)
; ----------------------------------------------------------------------
	defb 080h,068h,082h,000h,0ffh,007h,000h,084h,0ffh,000h,007h,0ffh,004h,000h,0a5h,0ffh	; 5e22  .h..............
	defb 000h,0ffh,0ffh,000h,000h,0ffh,000h,0ffh,000h,000h,0ffh,000h,0ffh,0ffh,000h,0ffh	; 5e32  ................
	defb 000h,0ffh,0ffh,000h,0ffh,0ffh,000h,0ffh,000h,000h,0ffh,000h,000h,0ffh,000h,003h	; 5e42  ................
	defb 01fh,0ffh,015h,002h,003h,000h,003h,0ffh,082h,055h,0aah,003h,000h,003h,0ffh,089h	; 5e52  .........U......
	defb 005h,083h,01fh,0ffh,000h,000h,0ffh,0ffh,000h,003h,0ffh,08ch,000h,000h,0ffh,0ffh	; 5e62  ................
	defb 000h,0e0h,0ffh,0ffh,000h,000h,0ffh,0ffh,003h,000h,001h,0ffh,003h,000h,087h,0ffh	; 5e72  ................
	defb 000h,000h,0ffh,0ffh,02ah,005h,006h,000h,089h,0aah,054h,003h,01fh,0ffh,02ah,005h	; 5e82  ....*.....T...*.
	defb 000h,000h,004h,0ffh,085h,0aah,055h,022h,000h,000h,003h,0ffh,08bh,0aah,050h,007h	; 5e92  ......U"......P.
	defb 000h,000h,0ffh,0ffh,0e0h,01fh,0ffh,0ffh,003h,000h,082h,0ffh,000h,003h,0ffh,003h	; 5ea2  ................
	defb 000h,089h,0ffh,0ffh,000h,0ffh,0ffh,000h,000h,00fh,001h,004h,000h,088h,017h,0ffh	; 5eb2  ................
	defb 0ffh,055h,02ah,005h,000h,000h,003h,0ffh,083h,055h,0aah,011h,005h,000h,082h,00fh	; 5ec2  .U*......U......
	defb 002h,004h,000h,088h,01fh,0ffh,0ffh,0aah,054h,003h,01fh,000h,003h,0ffh,001h,000h	; 5ed2  ........T.......
	defb 003h,0ffh,001h,000h,003h,0ffh,086h,000h,000h,0ffh,0ffh,0aah,055h,007h,000h,004h	; 5ee2  ............U...
	defb 0ffh,085h,0a8h,047h,03fh,000h,000h,003h,0ffh,088h,000h,0ffh,0ffh,000h,00fh,0ffh	; 5ef2  ...G?...........
	defb 015h,002h,004h,000h,003h,0ffh,089h,000h,0e0h,0ffh,0ffh,000h,0ffh,000h,0ffh,0ffh	; 5f02  ................
	defb 004h,000h,084h,0ffh,000h,000h,0ffh,00ah,000h,001h,0ffh,004h,000h,084h,03fh,000h	; 5f12  ..............?.
	defb 0ffh,0ffh,003h,000h,08ah,080h,0ffh,000h,000h,0ffh,07fh,01fh,00fh,003h,001h,003h	; 5f22  ................
	defb 000h,005h,0ffh,085h,07fh,03fh,00fh,007h,001h,006h,000h,003h,0ffh,08dh,03fh,01fh	; 5f32  .....?........?.
	defb 007h,003h,000h,0ffh,07fh,01fh,00fh,007h,001h,000h,000h,007h,0ffh,085h,07fh,01fh	; 5f42  ................
	defb 00fh,007h,001h,004h,000h,006h,0ffh,082h,07fh,03fh,004h,0ffh,091h,01fh,007h,003h	; 5f52  .........?......
	defb 000h,007h,00fh,01fh,01fh,01fh,00fh,007h,003h,0ffh,03fh,00fh,003h,001h,003h,000h	; 5f62  ..........?.....
	defb 084h,0ffh,07fh,01fh,00fh,004h,000h,006h,000h,002h,01fh,005h,0ffh,003h,000h,003h	; 5f72  ................
	defb 0ffh,082h,07fh,01fh,003h,000h,003h,0ffh,005h,000h,090h,07fh,01fh,00fh,01fh,03fh	; 5f82  ...............?
	defb 00fh,007h,001h,007h,00fh,01fh,03fh,007h,003h,000h,000h,004h,000h,002h,001h,005h	; 5f92  ......?.........
	defb 0ffh,087h,03fh,01fh,03fh,07fh,0ffh,000h,003h,009h,000h,082h,001h,003h,003h,000h	; 5fa2  ..?.?...........
	defb 083h,001h,003h,007h,005h,000h,001h,07fh,005h,03fh,082h,01fh,00fh,006h,0ffh,006h	; 5fb2  .........?......
	defb 07fh,08ch,01fh,00fh,007h,001h,07fh,01fh,00fh,003h,001h,000h,003h,007h,003h,0ffh	; 5fc2  ................
	defb 005h,03fh,000h,090h,06ch,00bh,000h,001h,0ffh,00bh,000h,001h,003h,007h,000h,001h	; 5fd2  .?..l...........
	defb 0ffh,007h,000h,001h,0f0h,004h,000h,001h,01fh,007h,000h,001h,0ffh,004h,000h,082h	; 5fe2  ................
	defb 03fh,0ffh,006h,000h,002h,0ffh,006h,000h,082h,0fch,0ffh,005h,000h,082h,001h,00fh	; 5ff2  ?...............
	defb 006h,000h,002h,0ffh,006h,000h,082h,0f0h,0feh,006h,000h,004h,0ffh,013h,000h,001h	; 6002  ................
	defb 00fh,007h,000h,001h,0c0h,004h,000h,001h,0f8h,003h,000h,082h,00fh,07fh,006h,000h	; 6012  ................
	defb 082h,080h,0f0h,009h,000h,001h,003h,007h,000h,001h,0e0h,007h,000h,001h,00fh,007h	; 6022  ................
	defb 000h,001h,0c0h,004h,000h,001h,07fh,003h,00fh,004h,000h,001h,0feh,003h,0f0h,01fh	; 6032  ................
	defb 000h,001h,001h,007h,000h,001h,080h,007h,000h,001h,007h,007h,000h,001h,0e0h,00bh	; 6042  ................
	defb 000h,001h,0f8h,007h,000h,001h,01fh,004h,000h,001h,07fh,007h,000h,001h,0feh,009h	; 6052  ................
	defb 000h,002h,007h,006h,000h,085h,0e0h,0e0h,000h,01fh,01fh,006h,000h,002h,0ffh,006h	; 6062  ................
	defb 000h,002h,0f8h,005h,000h,002h,01fh,006h,000h,002h,0f8h,006h,000h,002h,0ffh,00ah	; 6072  ................
	defb 000h,001h,003h,007h,000h,001h,0c0h,003h,000h,084h,07fh,07fh,0ffh,07fh,004h,000h	; 6082  ................
	defb 084h,0feh,0feh,0ffh,0feh,004h,000h,004h,0ffh,016h,000h,002h,004h,00ah,000h,002h	; 6092  ................
	defb 030h,006h,000h,002h,003h,003h,000h,002h,0c0h,009h,000h,004h,0f0h,00ch,000h,006h	; 60a2  0...............
	defb 0ffh,003h,080h,001h,0c0h,003h,00eh,002h,008h,003h,000h,002h,003h,004h,002h,002h	; 60b2  ................
	defb 000h,001h,000h,003h,00fh,001h,009h,004h,000h,003h,0e0h,001h,020h,004h,000h,093h	; 60c2  ............ ...
	defb 07bh,0e0h,0e4h,0e4h,0e0h,0e0h,098h,000h,0f6h,0ffh,0bfh,0bfh,0ffh,0ffh,053h,000h	; 60d2  {.............S.
	defb 030h,070h,077h,00bh,0f8h,087h,0e0h,000h,026h,0eeh,0efh,0ffh,0ffh,004h,09fh,004h	; 60e2  0pw.....&.......
	defb 0ffh,088h,0feh,0cch,000h,024h,0eeh,0efh,0ffh,087h,00fh,07fh,09bh,06fh,003h,001h	; 60f2  .....$.......o..
	defb 000h,000h,022h,063h,063h,0f3h,0f7h,0f7h,0ffh,0ffh,0ddh,088h,000h,0dbh,0ffh,0ffh	; 6102  .."cc...........
	defb 000h,000h,002h,063h,063h,0f3h,0f7h,0f7h,003h,0ffh,007h,0feh,009h,0ffh,082h,0c3h	; 6112  ...cc...........
	defb 081h,003h,000h,002h,0ffh,001h,00fh,00ch,0ffh,001h,000h,003h,0ffh,085h,0f7h,0c7h	; 6122  ................
	defb 082h,000h,000h,003h,0ffh,007h,01fh,009h,0ffh,007h,0c3h,008h,0ffh,001h,0f8h,00dh	; 6132  ................
	defb 0f7h,00bh,0fch,001h,000h,008h,0ffh,084h,07fh,022h,000h,000h,004h,0f7h,084h,077h	; 6142  .........".....w
	defb 022h,000h,000h,002h,04fh,006h,07fh,001h,003h,015h,001h,082h,003h,00fh,004h,000h	; 6152  "...O...........
	defb 084h,080h,0c0h,0e0h,0ffh,005h,000h,082h,00fh,0ffh,005h,000h,093h,0f8h,0e7h,04dh	; 6162  ...............M
	defb 018h,000h,000h,00fh,01fh,0fah,0ebh,0c5h,080h,000h,000h,0f0h,0fch,03fh,0dch,068h	; 6172  .............?.h
	defb 003h,000h,085h,003h,0ffh,0ffh,0b5h,016h,005h,000h,003h,01fh,001h,03fh,004h,000h	; 6182  .............?..
	defb 004h,0ffh,004h,000h,084h,0c0h,0fch,0fch,0ffh,004h,000h,084h,0ffh,0efh,0ffh,0f7h	; 6192  ................
	defb 004h,000h,084h,0ffh,0d3h,0fdh,0ceh,000h,098h,06ah,010h,000h,000h,080h,048h,078h	; 61a2  .........j....Hx
	defb 0efh,078h,0efh,038h,0efh,060h,04fh,006h,04fh,082h,01fh,041h,02ch,04fh,082h,01fh	; 61b2  .x.8.`O.O..A,O..
	defb 041h,00ah,04fh,018h,01fh,002h,04fh,003h,041h,00ah,04fh,001h,041h,003h,041h,00bh	; 61c2  A.O...O.A.O.A.A.
	defb 04fh,002h,01fh,005h,04fh,003h,041h,000h,090h,04ch,070h,04fh,030h,04fh,020h,01fh	; 61d2  O...O.A..LpO0O .
	defb 002h,04fh,002h,041h,006h,04fh,002h,041h,004h,04fh,078h,05fh,030h,05fh,001h,0efh	; 61e2  .O.A.O.A.Ox_0_..
	defb 007h,05fh,001h,0efh,007h,05fh,001h,0efh,007h,05fh,04ch,03fh,004h,0efh,003h,03fh	; 61f2  ._..._..._L?...?
	defb 005h,0efh,002h,03fh,006h,0efh,010h,09fh,002h,08fh,006h,089h,008h,09fh,004h,08fh	; 6202  ...?............
	defb 00bh,089h,004h,06fh,003h,09fh,004h,097h,006h,09fh,003h,06fh,003h,09fh,00fh,096h	; 6212  ...o.......o....
	defb 003h,09fh,007h,06fh,001h,09fh,005h,0f6h,003h,096h,007h,06eh,001h,08eh,009h,097h	; 6222  ...o.......n....
	defb 01fh,09fh,008h,08fh,020h,097h,003h,09fh,00dh,096h,00bh,076h,00dh,09fh,003h,096h	; 6232  .... ......v....
	defb 005h,09fh,008h,096h,017h,017h,001h,01fh,008h,0f7h,007h,0f7h,001h,0f4h,005h,0f7h	; 6242  ................
	defb 003h,0f4h,004h,0f7h,004h,0f4h,004h,0f7h,004h,0f4h,003h,0f7h,005h,0f4h,028h,0f7h	; 6252  ..............(.
	defb 000h,017h,019h,001h,01fh,008h,0f9h,007h,0f9h,001h,0f4h,005h,0f9h,003h,0f4h,004h	; 6262  ................
	defb 0f9h,004h,0f4h,004h,0f9h,004h,0f4h,003h,0f9h,005h,0f4h,028h,0f9h,000h,098h,04ah	; 6272  ...........(...J
	defb 004h,04fh,001h,041h,003h,044h,003h,04fh,001h,041h,004h,044h,000h	; 6282  .O.A.D.O.A.D.

; ======================================================================
; CODIGO 0x628f..0x62c5  (54 bytes)
; ======================================================================


CARGA_BANCO_2:		; Descomprime los dibujos del banco 2
	ld hl,062c5h		;628f
	call DESCOMPRIME		;6292
	call DESCOMPRIME		;6295
	ld hl,05c2ch		;6298
	call DESCOMPRIME_SIGUE		;629b
	ld hl,062c7h		;629e
	ld de,072b0h		;62a1
	call DESCOMPRIME_ESPEJO		;62a4
	ld hl,06655h		;62a7
	call DESCOMPRIME		;62aa
	ld hl,06579h		;62ad
	call DESCOMPRIME		;62b0
	call DESCOMPRIME		;62b3
	ld hl,0657bh		;62b6
	ld de,052b0h		;62b9
	call DESCOMPRIME_DE		;62bc
	ld hl,066b3h		;62bf
	jp DESCOMPRIME		;62c2

; ----------------------------------------------------------------------
; DATOS dibujos_banco2: Dibujos y colores del banco 2, comprimidos
;   0x62c5..0x66c2  (1021 bytes)
; ----------------------------------------------------------------------
	defb 000h,072h,085h,07fh,01fh,00fh,003h,001h,003h,000h,005h,0ffh,085h,07fh,03fh,00fh	; 62c5  .r............?.
	defb 007h,001h,006h,000h,003h,0ffh,08dh,03fh,01fh,007h,003h,000h,0ffh,07fh,01fh,00fh	; 62d5  .......?........
	defb 007h,001h,000h,000h,007h,0ffh,085h,07fh,01fh,00fh,007h,001h,004h,000h,005h,0ffh	; 62e5  ................
	defb 083h,07fh,01fh,00fh,003h,0ffh,085h,07fh,01fh,00fh,007h,001h,004h,0ffh,086h,01fh	; 62f5  ................
	defb 007h,003h,000h,0ffh,07fh,006h,000h,085h,0ffh,0ffh,00fh,003h,001h,003h,000h,004h	; 6305  ................
	defb 0ffh,004h,000h,005h,0ffh,08dh,07fh,000h,000h,001h,003h,007h,00fh,00fh,01fh,000h	; 6315  ................
	defb 000h,001h,003h,006h,000h,084h,007h,007h,00fh,01fh,005h,000h,087h,001h,003h,007h	; 6325  ................
	defb 00fh,00fh,01fh,03fh,003h,0ffh,001h,07fh,00ah,03fh,092h,01fh,00fh,07fh,01fh,00fh	; 6335  ...?.....?......
	defb 003h,001h,000h,003h,007h,03fh,03fh,01fh,00fh,007h,001h,000h,000h,000h,060h,073h	; 6345  .....??.......`s
	defb 003h,000h,005h,0ffh,001h,000h,007h,0ffh,002h,000h,00dh,0ffh,004h,000h,085h,003h	; 6355  ................
	defb 000h,000h,00fh,07fh,003h,000h,086h,0f8h,000h,000h,0f0h,0ffh,001h,004h,000h,096h	; 6365  ................
	defb 001h,00fh,000h,0ffh,03fh,000h,000h,00fh,0ffh,0ffh,03fh,0ffh,0fch,0f8h,0c0h,000h	; 6375  ....?.....?.....
	defb 0f0h,0ffh,0ffh,0f0h,0c0h,080h,003h,000h,084h,0f8h,0ffh,01fh,003h,003h,000h,083h	; 6385  ................
	defb 01fh,0ffh,003h,003h,000h,085h,0e0h,000h,000h,0e0h,0feh,006h,000h,082h,080h,0f0h	; 6395  ................
	defb 003h,000h,001h,00fh,006h,000h,086h,007h,0ffh,0ffh,007h,000h,000h,003h,0ffh,087h	; 63a5  ................
	defb 0fch,0f0h,0ffh,00fh,000h,0c0h,080h,003h,000h,083h,0c0h,0f0h,07fh,007h,000h,089h	; 63b5  ................
	defb 0f0h,0fch,0f8h,0f0h,0c0h,000h,0fch,0ffh,007h,007h,000h,001h,0ffh,003h,000h,082h	; 63c5  ................
	defb 0ffh,00fh,004h,000h,086h,00fh,07fh,0ffh,0ffh,07fh,00ch,004h,000h,002h,0ffh,003h	; 63d5  ................
	defb 03fh,003h,000h,002h,0ffh,003h,0f8h,002h,0ffh,00dh,00fh,001h,000h,003h,0ffh,001h	; 63e5  ?...............
	defb 0fch,00bh,0f0h,001h,0ffh,008h,007h,003h,000h,001h,00fh,004h,0ffh,001h,00fh,004h	; 63f5  ................
	defb 0f7h,084h,0f0h,0c0h,000h,000h,007h,01fh,007h,00fh,001h,000h,007h,0f0h,002h,000h	; 6405  ................
	defb 007h,0f8h,002h,0f0h,006h,0f0h,082h,000h,0c0h,006h,00fh,082h,000h,003h,006h,0f0h	; 6415  ................
	defb 082h,00fh,03fh,006h,00fh,001h,0ffh,004h,07fh,001h,00fh,005h,000h,085h,003h,003h	; 6425  ..?.............
	defb 00fh,00fh,003h,00bh,000h,08eh,0c0h,0c0h,0f0h,0f0h,0c0h,000h,000h,001h,007h,007h	; 6435  ................
	defb 01fh,01fh,001h,0ffh,009h,000h,08ch,080h,0e0h,0e0h,0f8h,0f8h,080h,000h,000h,007h	; 6445  ................
	defb 01fh,0f0h,0e0h,004h,000h,084h,0e0h,0f8h,01fh,007h,006h,000h,004h,00fh,085h,000h	; 6455  ................
	defb 007h,03fh,0f8h,0c0h,004h,000h,084h,0e0h,0fch,01fh,003h,007h,000h,004h,0f0h,084h	; 6465  .?..............
	defb 0ffh,0ffh,03fh,001h,004h,000h,004h,0ffh,004h,000h,084h,0ffh,0ffh,0fch,080h,004h	; 6475  ..?.............
	defb 000h,083h,00fh,00fh,003h,005h,000h,003h,0ffh,001h,01fh,004h,000h,003h,0ffh,001h	; 6485  ................
	defb 0f8h,004h,000h,083h,0f0h,0f0h,0c0h,009h,000h,083h,00fh,07fh,0f8h,006h,0ffh,003h	; 6495  ................
	defb 000h,006h,0ffh,002h,000h,003h,0ffh,005h,000h,083h,0ffh,0ffh,03fh,005h,000h,083h	; 64a5  ............?...
	defb 0ffh,0ffh,0fch,005h,000h,008h,0f0h,004h,000h,004h,0ffh,008h,00fh,006h,080h,082h	; 64b5  ................
	defb 0c0h,0e0h,005h,080h,083h,0c0h,000h,000h,006h,008h,082h,00ch,00fh,005h,008h,001h	; 64c5  ................
	defb 00fh,00fh,000h,09bh,00fh,000h,000h,007h,01fh,03fh,07ch,078h,0f2h,0f2h,0f0h,0e0h	; 64d5  .........?|x....
	defb 0f8h,0fch,03eh,01eh,04fh,04fh,00fh,000h,000h,001h,007h,00fh,01fh,03ch,030h,005h	; 64e5  ..>.OO.......<0.
	defb 0f8h,083h,0fch,0f0h,0c0h,005h,01fh,083h,03fh,00fh,003h,087h,000h,080h,0e0h,0f0h	; 64f5  ........?.......
	defb 0f8h,01ch,00ch,006h,080h,00ah,000h,007h,001h,002h,000h,005h,080h,083h,0c0h,0c0h	; 6505  ................
	defb 0e0h,005h,001h,083h,003h,003h,007h,003h,080h,098h,0c0h,040h,060h,0a0h,0e0h,030h	; 6515  ...........@`..0
	defb 03ch,01fh,00fh,007h,003h,001h,000h,000h,001h,001h,003h,007h,003h,000h,000h,070h	; 6525  <..............p
	defb 0ffh,0e3h,003h,0ffh,085h,000h,000h,006h,0ffh,0e7h,003h,0ffh,003h,000h,088h,080h	; 6535  ................
	defb 080h,0c0h,0e0h,0c0h,000h,000h,001h,003h,000h,001h,001h,003h,000h,088h,0f0h,07fh	; 6545  ................
	defb 033h,07fh,0ffh,0ffh,000h,000h,098h,000h,07fh,060h,060h,07eh,060h,060h,060h,000h	; 6555  3........``~```.
	defb 063h,063h,06bh,06bh,07fh,077h,022h,000h,07fh,007h,00eh,01ch,038h,070h,07fh,006h	; 6565  cckk.w".....8p..
	defb 000h,002h,060h,000h,000h,052h,070h,04fh,020h,01fh,006h,04fh,008h,041h,008h,04fh	; 6575  ..`..RpO ..O.A.O
	defb 002h,01fh,002h,041h,006h,04fh,000h,060h,053h,026h,04fh,002h,01fh,006h,04fh,002h	; 6585  ...A.O.`S&O...O.
	defb 01fh,005h,04fh,003h,01fh,004h,04fh,004h,01fh,004h,04fh,004h,01fh,004h,04fh,004h	; 6595  ..O...O...O...O.
	defb 01fh,004h,04fh,004h,01fh,004h,04fh,054h,01fh,006h,04fh,002h,041h,006h,04fh,002h	; 65a5  ..O...OT..O.A.O.
	defb 041h,003h,04fh,005h,041h,006h,041h,002h,04fh,005h,04fh,003h,041h,007h,041h,002h	; 65b5  A.O.A.A.O.O.A.A.
	defb 0f4h,009h,054h,007h,01fh,004h,01dh,004h,01fh,00eh,045h,001h,04fh,007h,045h,002h	; 65c5  ..T.......E.O.E.
	defb 04fh,007h,045h,002h,04fh,006h,045h,002h,05fh,006h,045h,002h,05fh,006h,045h,002h	; 65d5  O.E.O.E._.E._.E.
	defb 04fh,006h,045h,005h,01dh,003h,01fh,004h,0efh,006h,05fh,002h,0feh,004h,0f5h,004h	; 65e5  O.E......._.....
	defb 0efh,004h,05fh,004h,0efh,004h,05fh,003h,0feh,005h,0f5h,004h,0efh,004h,05fh,004h	; 65f5  .._..._......._.
	defb 0efh,002h,0e5h,002h,0f5h,004h,0efh,002h,0e5h,002h,0f5h,006h,0efh,002h,05fh,003h	; 6605  .............._.
	defb 0efh,002h,0e5h,003h,0f5h,003h,0efh,002h,0e5h,003h,0f5h,006h,0efh,06ah,05fh,018h	; 6615  .............j_.
	defb 03fh,017h,0efh,001h,0e1h,005h,0efh,001h,0e1h,012h,01fh,01ah,01fh,002h,016h,006h	; 6625  ?...............
	defb 01fh,002h,016h,047h,01fh,005h,04fh,003h,01fh,005h,04fh,003h,01fh,005h,04fh,003h	; 6635  ...G..O...O...O.
	defb 01fh,005h,04fh,003h,01fh,005h,04fh,003h,01fh,005h,04fh,078h,04fh,078h,04fh,000h	; 6645  ..O...O...OxOxO.
	defb 090h,076h,082h,002h,005h,002h,000h,006h,007h,002h,001h,006h,002h,003h,001h,003h	; 6655  .v..............
	defb 000h,084h,027h,057h,007h,007h,006h,0ffh,082h,007h,001h,009h,000h,083h,080h,040h	; 6665  ..'W...........@
	defb 020h,004h,0ffh,002h,0feh,083h,0fch,0feh,0feh,004h,0ffh,08bh,07fh,03fh,01fh,01fh	; 6675   ............?..
	defb 00fh,007h,001h,000h,002h,004h,008h,003h,000h,003h,080h,002h,0c0h,084h,0e0h,0f0h	; 6685  ................
	defb 0f8h,0c0h,004h,000h,098h,000h,001h,001h,001h,000h,000h,000h,000h,0f8h,0f0h,0e0h	; 6695  ................
	defb 0ffh,000h,000h,000h,000h,000h,0f0h,0fch,0f8h,000h,000h,000h,000h,000h,090h,056h	; 66a5  ...............V
	defb 058h,01fh,003h,0afh,001h,04fh,005h,0afh,002h,0a4h,00dh,04fh,000h	; 66b5  X....O.....O.

; ======================================================================
; CODIGO 0x66c2..0x66ef  (45 bytes)
; ======================================================================


MONTA_SPRITES_PARTIDA:		; Monta la tabla de atributos de sprite de la partida
	ld hl,066efh		;66c2
	jr MONTA_SPRITES		;66c5
MONTA_SPRITES_BASE:		; La de la escena de la base
	ld hl,0672ch		;66c7
MONTA_SPRITES:		; Compone en 0xE050 los 128 bytes de atributos a partir de una lista (cuantos, y los cuatro bytes) y los vuelca a la VRAM
	push hl			;66ca
	ld hl,0e050h		;66cb
	push hl			;66ce
	ld b,080h		;66cf
SPRITES_BORRA:
	ld (hl),000h		;66d1
	inc hl			;66d3
	djnz SPRITES_BORRA		;66d4
	pop de			;66d6
	pop hl			;66d7
SPRITES_BUCLE:
	ld a,(hl)		;66d8
	inc hl			;66d9
	or a			;66da
	jr z,VUELCA_ATRIBUTOS		;66db
	ld c,a			;66dd
	call REPITE_4_BYTES		;66de
	jr SPRITES_BUCLE		;66e1
VUELCA_ATRIBUTOS:		; Copia los 128 bytes de 0xE050 a la tabla de atributos de sprite
	ld hl,0e050h		;66e3
	ld de,03b00h		;66e6
	ld bc,00080h		;66e9
	jp COPIA_A_VRAM		;66ec

; ----------------------------------------------------------------------
; DATOS atributos_de_partida: La lista con la que se monta la tabla de atributos durante la partida: pares (cuantos, cuatro bytes) y un cero al final. De aqui sale el color de cada sprite, que NO va en su dibujo: el pinguino negro, la foca negra y roja, el pez rojo, la sombra azul. Y AQUI ESTA EL ATRIBUTO 14, con patron 0xD4 -que dibujado es una EXPLOSION de puntas- y color amarillo, que no se ve nunca: se monta con Y=0xE0 -fuera de la pantalla- y nadie se la cambia. MEDIDO sobre los diez minutos de partida grabada con un punto de observacion de escritura en 0xE088-0xE08B (tools/omsx_atributo14.tcl): las UNICAS cuatro cosas que lo tocan son barridos de la tabla entera -el ldir de 0x446E, el copiador de cuatro bytes de 0x45BE, BORRA_SPRITES en 0x4606 y el borrado previo de 0x66D1-, y ninguna va a por el. Al acabar la partida su entrada en la VRAM sigue siendo Y=0xE0, patron 0xD4, color 0x0A: cargado, coloreado y aparcado fuera del encuadre. El control -los mismos puntos en el atributo 13- recibe ademas 4426 y 41740 escrituras de las rutinas del pinguino, asi que los ceros del 14 son datos y no instrumentacion rota. Y de propina el control mide una cosa que estaba deducida: el 13 recibe 12 escrituras MAS que el 14 desde 0x45BE, que son las tres salidas del agua por cuatro bytes, o sea la cadena que rehace los sprites parandose justo antes del 14
;   0x66ef..0x672c  (61 bytes)
; DATOS atributos_de_base: La misma lista para la escena de la base, pero de OCHO entradas en vez de treinta: 0x66CB pone los 128 bytes a cero antes de aplicarla, asi que del atributo 8 en adelante no queda nada. Cierra clavada en 0x6756, donde vuelve a haber codigo. Sus bytes de 0x6746 los copia ademas 0x5537. Y AQUI ESTA EL UNICO SPRITE DEL PINGUINO QUE SE GIRA Y SONRIE: el atributo 7, con el patron 0xD0 en amarillo, que es el PICO. Todo lo demas de ese pinguino -la cara, los ojos, la boca roja y hasta la sombra azul de debajo- son CASILLAS, no sprites. Comprobado a t=126,6 de la partida grabada de dos maneras: la tabla de atributos solo tiene ocho entradas puestas, y comparando el fotograma real con la pantalla pintada SOLO con casillas quedan 224 pixeles sin explicar, que son 96+72+24 de la bandera y 32 del pico. Y 32 son exactamente los bits encendidos del patron 0xD0
;   0x672c..0x6756  (42 bytes)
; ----------------------------------------------------------------------
	defb 00ah,0e0h,000h,07ch,000h,001h,090h,070h,000h,001h,001h,090h,080h,004h,001h,001h	; 66ef  ...|...p........
	defb 0a0h,070h,008h,001h,001h,0a0h,080h,00ch,001h,001h,0e0h,000h,0d4h,00ah,001h,0e0h	; 66ff  .p..............
	defb 000h,000h,008h,001h,0e0h,000h,07ch,001h,003h,0e0h,000h,07ch,006h,001h,0aeh,070h	; 670f  ......|....|...p
	defb 0a0h,004h,001h,0aeh,080h,0a4h,004h,008h,008h,000h,070h,000h,000h,004h,04fh,080h	; 671f  ..........p...O.
	defb 07ch,000h,001h,052h,080h,0e8h,000h,001h,052h,080h,0ech,000h,001h,052h,080h,0e4h	; 672f  |..R....R....R..
	defb 00fh,001h,07fh,078h,0d0h,00ah,000h,07fh,070h,0f0h,00ah,087h,078h,0f4h,00ah,077h	; 673f  ...x....p...x..w
	defb 070h,0f8h,001h,077h,080h,0fch,001h	; 674f  p..w...

; ======================================================================
; CODIGO 0x6756..0x675c  (6 bytes)
; ======================================================================


CARGA_SPRITES:		; Descomprime los patrones de sprite
	ld hl,0675ch		;6756
	jp DESCOMPRIME		;6759

; ----------------------------------------------------------------------
; DATOS sprites_comprimidos: Los patrones de sprite: los pinguinos, los peces y las focas
;   0x675c..0x6be9  (1165 bytes)
; DATOS trozos_de_pista: Los 92 trozos incrementales de la pista, en el mismo formato que los decorados: cada uno pone entre una y seis casillas, o sea que son INCREMENTOS y no pantallas enteras. Se consumen en cadena, uno por paso, y asi va creciendo lo que se acerca. Los siete obstaculos de 0x52CB empiezan cada uno en uno de estos trozos
;   0x6be9..0x7241  (1624 bytes)
; DATOS arbol_de_decorados: Cuatro punteros en 0x7241 llevan a cuatro grupos, cada uno con otros cuatro, y los dieciseis bloques de abajo embaldosan 0x732D-0x7518 sin dejar hueco. Pasados por el interprete de 0x4533 dibujan los bordes de la pista
;   0x7241..0x7519  (728 bytes)
; ----------------------------------------------------------------------
	defb 000h,058h,00dh,000h,083h,003h,00fh,01fh,003h,000h,08ah,003h,00fh,01bh,037h,06fh	; 675c  .X............7o
	defb 05fh,0ffh,0ffh,0bfh,0bfh,003h,0ffh,003h,000h,086h,0c0h,0f0h,0f8h,0fch,0feh,0feh	; 676c  _...............
	defb 007h,0ffh,00dh,000h,086h,0c0h,0e0h,0f0h,03fh,070h,060h,007h,001h,003h,000h,083h	; 677c  ........?p`.....
	defb 003h,003h,000h,00ch,0ffh,084h,07fh,0ffh,0e3h,001h,00ch,0ffh,087h,0feh,0ffh,0c7h	; 678c  ................
	defb 080h,0f8h,018h,008h,006h,080h,004h,000h,082h,0c0h,0c0h,00bh,000h,005h,001h,001h	; 679c  ................
	defb 003h,003h,000h,08ah,007h,01fh,037h,06fh,0dfh,0bfh,0ffh,0ffh,0bfh,0bfh,003h,0ffh	; 67ac  ......7o........
	defb 003h,000h,085h,0c0h,0f0h,0f8h,0fch,0fch,003h,0feh,005h,0ffh,00ch,000h,08bh,0e0h	; 67bc  ................
	defb 0f0h,0f8h,0f8h,007h,00fh,01fh,03eh,038h,030h,020h,009h,000h,008h,0ffh,088h,07fh	; 67cc  ......>80 ......
	defb 07fh,03fh,01fh,07fh,077h,000h,000h,00dh,0ffh,086h,0fdh,039h,008h,00ch,000h,000h	; 67dc  .?..w......9....
	defb 007h,080h,086h,000h,0c0h,0e0h,0a0h,0e0h,0e0h,00ch,000h,084h,007h,01fh,03fh,07fh	; 67ec  ..............?.
	defb 003h,000h,08ah,003h,00fh,01bh,037h,02fh,06fh,07fh,07fh,0dfh,0bfh,003h,0ffh,003h	; 67fc  ......7/o.......
	defb 000h,084h,0e0h,0f8h,0fch,0feh,009h,0ffh,00ah,000h,006h,080h,083h,060h,000h,000h	; 680c  .............`..
	defb 007h,001h,086h,000h,003h,007h,005h,007h,007h,00dh,0ffh,083h,0bfh,09ch,010h,008h	; 681c  ................
	defb 0ffh,08fh,0feh,0feh,0fch,0f8h,0feh,0eeh,000h,000h,0e0h,0f0h,0f8h,038h,01ch,00ch	; 682c  .............8..
	defb 004h,009h,000h,083h,03fh,070h,060h,005h,001h,085h,002h,006h,007h,007h,003h,003h	; 683c  ....?p`.........
	defb 000h,00ch,0ffh,084h,03fh,00fh,001h,000h,00ch,0ffh,087h,0feh,0f8h,0e0h,080h,0f8h	; 684c  ....?...........
	defb 018h,008h,005h,080h,085h,040h,060h,0e0h,0e0h,0c0h,00dh,000h,086h,020h,030h,018h	; 685c  .....@`...... 0.
	defb 01fh,00fh,007h,003h,000h,08ah,003h,00fh,01bh,037h,06fh,05fh,0ffh,0ffh,0bfh,0bfh	; 686c  .........7o_....
	defb 003h,0ffh,003h,000h,086h,0c0h,0f0h,0f8h,0fch,0feh,0feh,007h,0ffh,00ah,000h,089h	; 687c  ................
	defb 004h,00ch,01ch,0f8h,0f0h,0e0h,003h,000h,000h,005h,001h,085h,002h,006h,007h,007h	; 688c  ................
	defb 003h,003h,000h,00ch,0ffh,084h,07fh,01fh,007h,001h,00ch,0ffh,087h,0fch,0f0h,080h	; 689c  ................
	defb 000h,0c0h,000h,000h,005h,080h,085h,040h,060h,0e0h,0e0h,0c0h,006h,000h,084h,0e0h	; 68ac  .......@`.......
	defb 0f8h,0fch,0feh,009h,0ffh,009h,000h,005h,080h,083h,0e0h,0f0h,060h,003h,001h,00ch	; 68bc  ............`...
	defb 000h,006h,0ffh,08ah,07fh,07fh,03fh,03fh,01fh,01fh,00eh,00ch,008h,000h,007h,0ffh	; 68cc  ......??........
	defb 084h,0feh,0feh,0fch,0b8h,005h,000h,083h,0f8h,0fch,00ch,016h,000h,005h,001h,082h	; 68dc  ................
	defb 007h,00fh,003h,000h,08ah,007h,01fh,037h,06fh,0dfh,0bfh,0ffh,0ffh,0bfh,0bfh,003h	; 68ec  .......7o.......
	defb 0ffh,083h,01fh,03fh,030h,00dh,000h,007h,0ffh,085h,07fh,07fh,03fh,01bh,001h,004h	; 68fc  ...?0.......?...
	defb 000h,006h,0ffh,08bh,0feh,0feh,0fch,0fch,0f8h,0f8h,0f0h,030h,010h,000h,00ch,003h	; 690c  ...........0....
	defb 080h,018h,000h,084h,01eh,03fh,03fh,003h,003h,000h,089h,003h,00fh,01bh,037h,06fh	; 691c  .....??.......7o
	defb 05fh,0ffh,0dfh,0dfh,004h,0ffh,003h,000h,086h,0c0h,0f0h,0f8h,0fch,0feh,0feh,007h	; 692c  _...............
	defb 0ffh,00ch,000h,085h,078h,0fch,0fch,0c0h,001h,00fh,000h,008h,0ffh,082h,05fh,00fh	; 693c  ....x........._.
	defb 003h,007h,083h,003h,001h,001h,008h,0ffh,082h,0fah,0f0h,003h,0e0h,084h,080h,000h	; 694c  ................
	defb 000h,080h,017h,000h,086h,020h,070h,0d8h,0f8h,0f8h,070h,00ah,000h,086h,004h,00eh	; 695c  ..... p...p.....
	defb 01bh,01fh,01fh,00eh,005h,000h,004h,078h,001h,038h,012h,000h,086h,004h,00eh,01bh	; 696c  .......x.8......
	defb 01fh,01fh,00eh,00ah,000h,086h,020h,070h,0d8h,0f8h,0f8h,070h,003h,000h,004h,00fh	; 697c  ...... p...p....
	defb 001h,00eh,02dh,000h,083h,003h,001h,001h,00eh,000h,085h,080h,080h,0a0h,0c0h,020h	; 698c  ..-............ 
	defb 009h,000h,088h,003h,007h,001h,000h,000h,001h,000h,001h,008h,000h,087h,080h,0c0h	; 699c  ................
	defb 0e0h,0e0h,060h,060h,0c0h,008h,000h,086h,007h,01fh,037h,07fh,03fh,00ch,00ah,000h	; 69ac  ..``......7.?...
	defb 001h,080h,003h,0e0h,087h,0f0h,070h,030h,018h,01ch,010h,010h,004h,000h,089h,030h	; 69bc  ......p0.......0
	defb 038h,03ch,03fh,01fh,03fh,02fh,027h,003h,00ah,000h,086h,080h,008h,088h,0feh,0f0h	; 69cc  8<?.?/'.........
	defb 080h,00bh,000h,085h,001h,001h,005h,003h,004h,00ah,000h,083h,0c0h,080h,080h,00ch	; 69dc  ................
	defb 000h,087h,001h,003h,007h,007h,006h,006h,003h,009h,000h,088h,0c0h,0e0h,080h,000h	; 69ec  ................
	defb 000h,080h,000h,080h,007h,000h,001h,001h,003h,007h,087h,00fh,00eh,00ch,018h,038h	; 69fc  ...............8
	defb 008h,008h,005h,000h,086h,0e0h,0f8h,0ech,0feh,0fch,030h,00ch,000h,086h,001h,080h	; 6a0c  ..........0.....
	defb 081h,07fh,00fh,001h,007h,000h,089h,00ch,01ch,03ch,0fch,0f8h,0fch,0f4h,0e4h,0c0h	; 6a1c  .........<......
	defb 006h,000h,082h,007h,007h,00dh,000h,001h,07fh,003h,0ffh,00ch,000h,001h,0feh,003h	; 6a2c  ................
	defb 0ffh,00dh,000h,082h,0e0h,0e0h,010h,000h,087h,0c0h,0f0h,0f8h,0fch,0fch,0feh,0feh	; 6a3c  ................
	defb 006h,0ffh,007h,000h,089h,00ch,01ch,03ch,0f8h,0f8h,0f0h,0c0h,000h,080h,00bh,0ffh	; 6a4c  .......<........
	defb 085h,0feh,0fch,0fch,038h,008h,006h,080h,084h,0b8h,0f8h,0f0h,0e0h,00dh,000h,089h	; 6a5c  ....8...........
	defb 030h,038h,03ch,01fh,01fh,00fh,003h,000h,001h,003h,000h,088h,003h,00fh,01bh,037h	; 6a6c  08<............7
	defb 02fh,07fh,05fh,0dfh,005h,0ffh,006h,001h,084h,01dh,01fh,00fh,007h,006h,000h,00bh	; 6a7c  /._.............
	defb 0ffh,085h,07fh,03fh,03fh,01ch,010h,006h,000h,088h,006h,000h,020h,013h,029h,001h	; 6a8c  ...??....... .).
	defb 009h,006h,008h,000h,088h,060h,000h,004h,0c8h,094h,080h,090h,060h,004h,000h,085h	; 6a9c  .....`......`...
	defb 003h,00fh,01fh,03fh,03fh,009h,07fh,087h,000h,000h,0c0h,0f0h,0f8h,0fch,0fch,009h	; 6aac  ...??...........
	defb 0feh,008h,000h,088h,006h,00ch,020h,013h,029h,011h,029h,006h,008h,000h,08fh,060h	; 6abc  ...... .).)....`
	defb 030h,004h,0c8h,094h,088h,094h,060h,001h,001h,003h,00dh,01eh,03fh,03fh,003h,07fh	; 6acc  0.....`.....??..
	defb 003h,0feh,084h,0fch,0f0h,060h,07fh,00bh,0ffh,081h,03fh,006h,000h,085h,003h,00fh	; 6adc  .....`....?.....
	defb 03fh,07fh,07fh,008h,0ffh,003h,000h,085h,0c0h,0f0h,0fch,0feh,0feh,008h,0ffh,081h	; 6aec  ?...............
	defb 0feh,00bh,0ffh,081h,0fch,003h,000h,087h,080h,080h,0c0h,0b0h,078h,0fch,0fch,003h	; 6afc  ............x...
	defb 0feh,003h,07fh,083h,03fh,00fh,006h,008h,000h,086h,003h,00fh,038h,00ch,007h,003h	; 6b0c  ....?.......8...
	defb 00ah,000h,086h,0c0h,0f0h,01ch,030h,0e0h,0c0h,007h,000h,08bh,004h,004h,0cch,0dfh	; 6b1c  ......0.........
	defb 07fh,03fh,07fh,0ffh,03fh,00dh,010h,007h,000h,089h,040h,0c0h,080h,080h,0c0h,0e0h	; 6b2c  .?..?.....@.....
	defb 0f0h,080h,080h,00bh,000h,085h,01fh,0ffh,07fh,03fh,003h,00bh,000h,085h,0c0h,0f0h	; 6b3c  .........?......
	defb 0ffh,0feh,0f0h,00ch,000h,084h,00fh,03fh,01fh,007h,00dh,000h,083h,0f0h,0fch,0c0h	; 6b4c  .......?........
	defb 00dh,000h,083h,007h,00fh,007h,00dh,000h,083h,080h,0f0h,000h,00ch,0ffh,004h,000h	; 6b5c  ................
	defb 00ch,0ffh,004h,000h,006h,000h,084h,003h,00fh,01fh,01fh,00ch,000h,084h,0c0h,0f0h	; 6b6c  ................
	defb 0f8h,0f8h,006h,000h,000h,080h,05fh,004h,000h,086h,00fh,01fh,01bh,01dh,01ch,00fh	; 6b7c  ......_.........
	defb 00ah,000h,086h,0f0h,0f8h,0dch,0beh,07ch,0f0h,006h,000h,00bh,000h,084h,003h,007h	; 6b8c  .......|........
	defb 007h,003h,00ch,000h,085h,0c0h,0c0h,0c0h,080h,000h,0a0h,000h,038h,03ch,00fh,00fh	; 6b9c  ............8<..
	defb 006h,004h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0feh,0ffh,0ffh	; 6bac  ................
	defb 01fh,00fh,007h,000h,000h,000h,000h,000h,000h,000h,000h,0a0h,000h,000h,000h,080h	; 6bbc  ................
	defb 0c1h,0c3h,0e7h,0efh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,080h	; 6bcc  ................
	defb 080h,080h,080h,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,041h,0efh	; 6bdc  ..............A.
	defb 093h,000h,041h,0eeh,0a1h,095h,0a2h,000h,041h,0eeh,00fh,00fh,00fh,0eeh,098h,098h	; 6bec  ..A.....A.......
	defb 0a3h,000h,061h,0eeh,00fh,00fh,00fh,0edh,099h,09ah,09ah,09bh,000h,081h,0edh,00fh	; 6bfc  ..a.............
	defb 00fh,00fh,00fh,0ech,0a4h,09dh,09dh,09dh,09dh,0a5h,000h,0a1h,0ech,00fh,00fh,00fh	; 6c0c  ................
	defb 00fh,00fh,00fh,0eah,0a8h,0aah,09fh,09fh,09fh,09fh,09fh,0abh,0a7h,000h,0c1h,0eah	; 6c1c  ................
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e9h,070h,082h,06ch,06ch,06ch,06ch	; 6c2c  ..........p.llll
	defb 06ch,06ch,083h,071h,000h,0e1h,0e9h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6c3c  ll.q............
	defb 00fh,0e8h,0e7h,072h,073h,084h,08bh,06dh,06dh,06dh,06dh,06dh,06dh,08eh,086h,075h	; 6c4c  ...rs..mmmmmm..u
	defb 000h,022h,0e7h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6c5c  ."..............
	defb 0e6h,072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h	; 6c6c  .rs..nnnnnnn..tx
	defb 0e5h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh	; 6c7c  .yz...ooooooo.o{
	defb 07ch,07dh,000h,042h,0e6h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6c8c  |}.B............
	defb 00fh,00fh,00fh,00fh,0e5h,072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh	; 6c9c  .....rs..nnnnnnn
	defb 06eh,06eh,092h,086h,075h,00fh,0e4h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh	; 6cac  nn..u..yz...oooo
	defb 06fh,06fh,06fh,06fh,06fh,08ch,087h,07eh,07fh,000h,062h,0e5h,00fh,00fh,00fh,00fh	; 6cbc  ooooo..~..b.....
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e4h,072h,073h,084h	; 6ccc  .............rs.
	defb 090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h,0e3h	; 6cdc  .nnnnnnnnnn..tx.
	defb 079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh	; 6cec  yz...oooooooooo.
	defb 06fh,07bh,07ch,07dh,000h,082h,0e4h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6cfc  o{|}............
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e3h,072h,073h,084h,090h,06eh,06eh	; 6d0c  ..........rs..nn
	defb 06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,092h,086h,075h,00fh,0e2h,079h	; 6d1c  nnnnnnnnnn..u..y
	defb 07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh	; 6d2c  z...oooooooooooo
	defb 08ch,087h,07eh,07fh,000h,0a2h,0e3h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6d3c  ..~.............
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e2h,072h,073h,084h,090h,06eh	; 6d4c  ...........rs..n
	defb 06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h	; 6d5c  nnnnnnnnnnnn..tx
	defb 000h,0c2h,0e2h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6d6c  ................
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0f0h,093h,000h,041h,0efh	; 6d7c  ..........A...A.
	defb 094h,095h,096h,000h,041h,0efh,00fh,00fh,00fh,0efh,097h,098h,098h,000h,061h,0efh	; 6d8c  ....A.........a.
	defb 00fh,00fh,00fh,0efh,099h,09ah,09ah,09bh,000h,081h,0efh,00fh,00fh,00fh,00fh,0eeh	; 6d9c  ................
	defb 09ch,09dh,09dh,09dh,09dh,09eh,000h,0a1h,0eeh,00fh,00fh,00fh,00fh,00fh,00fh,0edh	; 6dac  ................
	defb 0a6h,0aah,09fh,09fh,09fh,09fh,09fh,0abh,0a7h,000h,0c1h,0edh,00fh,00fh,00fh,00fh	; 6dbc  ................
	defb 00fh,00fh,00fh,00fh,00fh,0edh,070h,082h,06ch,06ch,06ch,06ch,06ch,06ch,083h,077h	; 6dcc  ......p.llllll.w
	defb 000h,0e1h,0edh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0edh,0ech,076h	; 6ddc  ...............v
	defb 089h,088h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,08eh,086h,075h,000h,022h,0ech,00fh	; 6dec  ..mmmmmmm..u."..
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0ech,076h,089h,08fh	; 6dfc  .............v..
	defb 06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h,0ebh,080h,081h,093h,085h	; 6e0c  nnnnnnn..tx.....
	defb 06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,042h,0ech,00fh	; 6e1c  ooooooo.o{|}.B..
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0ebh,072h,073h	; 6e2c  ..............rs
	defb 084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h,0eah,079h	; 6e3c  ..nnnnnnnn..tx.y
	defb 07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch	; 6e4c  z...oooooooo.o{|
	defb 07dh,000h,062h,0ebh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6e5c  }.b.............
	defb 00fh,00fh,00fh,00fh,0eah,00fh,076h,089h,08fh,06eh,06eh,06eh,06eh,06eh,06eh,06eh	; 6e6c  ......v..nnnnnnn
	defb 06eh,06eh,06eh,091h,004h,074h,078h,0eah,080h,081h,093h,08dh,06fh,06fh,06fh,06fh	; 6e7c  nnn..tx.....oooo
	defb 06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,082h,0ebh,00fh,00fh	; 6e8c  oooooo.o{|}.....
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0eah	; 6e9c  ................
	defb 072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h	; 6eac  rs..nnnnnnnnnnn.
	defb 004h,074h,078h,0e9h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh	; 6ebc  .tx.yz...ooooooo
	defb 06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,0a2h,0eah,00fh,00fh,00fh,00fh	; 6ecc  oooo.o{|}.......
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e9h	; 6edc  ................
	defb 00fh,076h,089h,08fh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh	; 6eec  .v..nnnnnnnnnnnn
	defb 06eh,091h,004h,077h,078h,000h,0c2h,0eah,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6efc  n..wx...........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0efh	; 6f0c  ..............A.
	defb 0afh,0b0h,000h,041h,0efh,094h,0a2h,000h,041h,0efh,00fh,00fh,0efh,0bfh,0c0h,000h	; 6f1c  ...A....A.......
	defb 061h,0efh,00fh,00fh,0efh,0b7h,0b8h,000h,081h,0efh,00fh,00fh,0efh,0bch,0bdh,000h	; 6f2c  a...............
	defb 0a1h,0efh,00fh,00fh,0efh,0c1h,0c2h,000h,0c1h,0efh,00fh,00fh,0eeh,094h,095h,095h	; 6f3c  ................
	defb 096h,000h,0e1h,0eeh,00fh,00fh,00fh,00fh,0ffh,0eeh,097h,098h,098h,099h,000h,022h	; 6f4c  ..............."
	defb 0eeh,00fh,00fh,00fh,00fh,0eeh,09ah,098h,098h,09bh,0eeh,0abh,0aah,0aah,0ach,000h	; 6f5c  ................
	defb 042h,0eeh,00fh,00fh,00fh,00fh,0edh,09ch,09dh,098h,098h,09eh,09fh,0edh,0a3h,0a4h	; 6f6c  B...............
	defb 0a1h,0a1h,0a5h,0a6h,000h,062h,0edh,00fh,00fh,00fh,00fh,00fh,00fh,0edh,09ah,098h	; 6f7c  .....b..........
	defb 098h,098h,098h,09bh,0edh,0abh,0a1h,0a8h,0a8h,0a1h,0ach,000h,082h,0edh,00fh,00fh	; 6f8c  ................
	defb 00fh,00fh,00fh,00fh,0ech,09ch,09dh,098h,098h,098h,098h,09eh,09fh,0ech,0a3h,0a4h	; 6f9c  ................
	defb 0a8h,0a9h,0a9h,0a9h,0a5h,0a6h,000h,0a2h,0ech,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6fac  ................
	defb 00fh,0ech,09ah,098h,098h,098h,098h,098h,098h,09bh,000h,0c2h,0ech,00fh,00fh,00fh	; 6fbc  ................
	defb 00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0efh,0b2h,000h,041h,0eeh,0b4h,00fh,000h	; 6fcc  .......A...A....
	defb 041h,0eeh,00fh,0edh,0bfh,0b6h,000h,061h,0edh,00fh,00fh,0edh,0bah,0bbh,000h,081h	; 6fdc  A......a........
	defb 0edh,00fh,00fh,0ech,0beh,0beh,000h,0a1h,0ech,00fh,00fh,0ebh,0c1h,0c3h,0c2h,000h	; 6fec  ................
	defb 0c1h,0ebh,00fh,00fh,00fh,0e9h,094h,095h,095h,095h,096h,000h,0e1h,0e9h,00fh,00fh	; 6ffc  ................
	defb 00fh,00fh,00fh,0ffh,0e8h,097h,098h,098h,098h,099h,000h,022h,0e8h,00fh,00fh,00fh	; 700c  ..........."....
	defb 00fh,00fh,0e7h,09ah,098h,098h,098h,09bh,0e7h,0abh,0aah,0aah,0aah,0ach,000h,042h	; 701c  ...............B
	defb 0e7h,00fh,00fh,00fh,00fh,00fh,0e6h,09ah,098h,098h,098h,09eh,09fh,0e6h,0a0h,0a1h	; 702c  ................
	defb 0a1h,0a1h,0a5h,0a6h,000h,062h,0e6h,00fh,00fh,00fh,00fh,00fh,00fh,0e5h,09ah,098h	; 703c  .....b..........
	defb 098h,098h,098h,09bh,00fh,0e5h,0a0h,0a1h,0a8h,0a8h,0a1h,0a2h,000h,082h,0e5h,00fh	; 704c  ................
	defb 00fh,00fh,00fh,00fh,00fh,0e4h,09ah,098h,098h,098h,098h,09eh,09fh,0e4h,0a0h,0a1h	; 705c  ................
	defb 0a8h,0a8h,0a1h,0a2h,0a6h,000h,0a2h,0e4h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e3h	; 706c  ................
	defb 09ah,098h,098h,098h,098h,098h,098h,09bh,00fh,000h,0c2h,0e3h,00fh,00fh,00fh,00fh	; 707c  ................
	defb 00fh,00fh,00fh,00fh,000h,000h,041h,0f0h,0b1h,000h,041h,0f0h,00fh,0b3h,000h,041h	; 708c  ......A...A....A
	defb 0f1h,00fh,0f1h,0b5h,0c0h,000h,061h,0f1h,00fh,00fh,0f1h,0b9h,0bah,000h,081h,0f1h	; 709c  ......a.........
	defb 00fh,00fh,0f2h,0beh,0beh,000h,0a1h,0f2h,00fh,00fh,0f2h,0c1h,0c3h,0c2h,000h,0c1h	; 70ac  ................
	defb 0f2h,00fh,00fh,00fh,0f2h,094h,095h,095h,095h,096h,000h,0e1h,0f2h,00fh,00fh,00fh	; 70bc  ................
	defb 00fh,00fh,0ffh,0f3h,097h,098h,098h,098h,099h,000h,022h,0f3h,00fh,00fh,00fh,00fh	; 70cc  ..........".....
	defb 00fh,0f4h,09ah,098h,098h,098h,09bh,0f4h,0abh,0aah,0aah,0aah,0ach,000h,042h,0f4h	; 70dc  ..............B.
	defb 00fh,00fh,00fh,00fh,00fh,0f4h,09ch,09dh,098h,098h,098h,09eh,0f4h,0a3h,0a4h,0a1h	; 70ec  ................
	defb 0a1h,0a1h,0a2h,000h,062h,0f4h,00fh,00fh,00fh,00fh,00fh,00fh,0f4h,00fh,09ah,098h	; 70fc  ....b...........
	defb 098h,098h,098h,09bh,0f5h,0a0h,0a1h,0a8h,0a8h,0a1h,0a2h,000h,082h,0f5h,00fh,00fh	; 710c  ................
	defb 00fh,00fh,00fh,00fh,0f5h,09ch,09dh,098h,098h,098h,098h,09eh,0f5h,0a3h,0a4h,0a8h	; 711c  ................
	defb 0a9h,0a8h,0a1h,0a2h,000h,0a2h,0f5h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0f5h,00fh	; 712c  ................
	defb 09ah,098h,098h,098h,098h,098h,098h,09bh,000h,0c2h,0f6h,00fh,00fh,00fh,00fh,00fh	; 713c  ................
	defb 00fh,00fh,00fh,000h,000h,000h,041h,0efh,0c6h,000h,041h,0efh,0c7h,000h,041h,0efh	; 714c  ......A...A...A.
	defb 00fh,0efh,0c9h,000h,061h,0efh,00fh,0eeh,0ceh,000h,081h,0edh,0c8h,0cah,0edh,0cfh	; 715c  ....a...........
	defb 0cbh,000h,081h,0edh,00fh,00fh,0edh,0cch,00fh,0ech,0a1h,0cdh,000h,0a1h,0edh,00fh	; 716c  ................
	defb 0ech,00fh,00fh,0ech,003h,0adh,0ebh,0b5h,0b1h,000h,0e1h,0ech,00fh,00fh,0ebh,0aeh	; 717c  ................
	defb 0aeh,0ebh,003h,003h,0eah,07fh,0b0h,000h,000h,002h,0ebh,00fh,00fh,0ebh,00fh,00fh	; 718c  ................
	defb 0e9h,0afh,003h,003h,0e9h,0afh,003h,003h,0e8h,07fh,0b2h,000h,000h,042h,0e9h,00fh	; 719c  .............B..
	defb 00fh,00fh,0e9h,00fh,00fh,00fh,0e8h,00fh,00fh,0e5h,003h,003h,003h,0e5h,003h,003h	; 71ac  ................
	defb 003h,000h,0a2h,0e5h,00fh,00fh,00fh,0e5h,00fh,00fh,00fh,000h,000h,000h,041h,0f0h	; 71bc  ..............A.
	defb 0c6h,000h,041h,0f0h,0c8h,000h,041h,0f0h,00fh,0f1h,0c9h,000h,061h,0f1h,00fh,0f1h	; 71cc  ..A...A.....a...
	defb 0ceh,000h,081h,0f1h,0c8h,0cah,0f1h,0cfh,0cbh,000h,081h,0f1h,00fh,00fh,0f1h,00fh	; 71dc  ................
	defb 0cch,0f1h,0a1h,0cdh,000h,0a1h,0f2h,00fh,0f1h,00fh,00fh,0f2h,0afh,003h,0f2h,0b2h	; 71ec  ................
	defb 000h,0e1h,0f2h,00fh,00fh,0f2h,00fh,0aeh,0aeh,0f3h,003h,003h,0f2h,07fh,0b0h,000h	; 71fc  ................
	defb 000h,002h,0f3h,00fh,00fh,0f3h,00fh,00fh,0f2h,00fh,0afh,003h,003h,0f3h,0afh,003h	; 720c  ................
	defb 003h,0f2h,07fh,0b2h,000h,000h,042h,0f3h,00fh,00fh,00fh,0f3h,00fh,00fh,00fh,0f2h	; 721c  ......B.........
	defb 00fh,00fh,0f8h,003h,003h,003h,0f8h,003h,003h,003h,000h,0a2h,0f8h,00fh,00fh,00fh	; 722c  ................
	defb 0f8h,00fh,00fh,00fh,000h,049h,072h,086h,072h,0c3h,072h,0f8h,072h,02dh,073h,055h	; 723c  .....Ir.r.r.r-sU
	defb 073h,06dh,073h,08eh,073h,00fh,00fh,051h,00eh,072h,00dh,093h,00bh,0b5h,00ah,0d6h	; 724c  sms.s..Q.r......
	defb 009h,0f7h,008h,018h,006h,03ah,005h,05bh,003h,07dh,002h,09eh,001h,0bfh,000h,051h	; 725c  .....:.[.}.....Q
	defb 039h,00fh,010h,011h,012h,013h,014h,015h,0ffh,060h,000h,000h,000h,0f3h,0f4h,0f3h	; 726c  9........`......
	defb 0f7h,0f5h,0f6h,0f4h,0f3h,0f7h,0f5h,0f6h,000h,000h,0a6h,073h,0ceh,073h,0e6h,073h	; 727c  ...........s.s.s
	defb 007h,074h,00fh,00fh,040h,00eh,060h,00dh,080h,00bh,0a0h,00ah,0c0h,009h,0e0h,008h	; 728c  .t..@.`.........
	defb 000h,006h,020h,005h,040h,003h,060h,002h,080h,001h,0a0h,000h,048h,039h,015h,014h	; 729c  .. .@.`.....H9..
	defb 013h,012h,052h,010h,00fh,0ffh,050h,0f3h,0f5h,0f6h,0f4h,0f5h,0f7h,0f6h,0f4h,0f4h	; 72ac  ..R...P.........
	defb 0f3h,0f5h,0f6h,0f4h,0f5h,0f6h,000h,01fh,074h,040h,074h,061h,074h,07fh,074h,004h	; 72bc  ........t@tat.t.
	defb 00dh,053h,00ch,074h,00ah,096h,009h,0b7h,007h,0d9h,006h,0fah,005h,01bh,003h,03dh	; 72cc  .S.t...........=
	defb 000h,051h,039h,039h,03ch,0feh,072h,039h,037h,038h,0ffh,060h,000h,000h,000h,000h	; 72dc  .Q99<.r978.`....
	defb 0f8h,0fch,0f9h,0fbh,0fch,0f9h,0f9h,0f9h,0fbh,0fah,000h,000h,09ch,074h,0bdh,074h	; 72ec  .............t.t
	defb 0deh,074h,0fch,074h,004h,00dh,040h,00ch,060h,00ah,080h,009h,0a0h,007h,0c0h,006h	; 72fc  .t.t..@.`.......
	defb 0e0h,005h,000h,003h,020h,000h,04dh,039h,07dh,07ah,0feh,06ch,039h,079h,078h,0ffh	; 730c  .... .M9}z.l9yx.
	defb 050h,000h,000h,000h,0f8h,0fbh,0f9h,0fch,0fbh,0f9h,0fbh,0fch,0fah,000h,000h,000h	; 731c  P...............
	defb 000h,021h,0f8h,013h,015h,012h,012h,012h,014h,014h,014h,0f5h,016h,017h,018h,019h	; 732c  .!..............
	defb 019h,01ah,01bh,01ch,01ch,01ch,01ch,0f7h,01dh,01eh,01fh,01fh,01fh,020h,021h,022h	; 733c  ............. !"
	defb 023h,0fah,00fh,024h,025h,026h,026h,026h,000h,021h,0fah,015h,0f5h,027h,028h,029h	; 734c  #..$%&&&.!...'()
	defb 029h,019h,02ah,0f7h,02bh,02bh,01eh,01fh,028h,029h,019h,02dh,0fah,02eh,026h,026h	; 735c  ).*.++..().-..&&
	defb 000h,021h,0f8h,015h,015h,015h,012h,012h,012h,0f5h,016h,017h,018h,019h,019h,02fh	; 736c  .!............./
	defb 01bh,01ch,022h,022h,0f7h,01dh,01eh,01fh,01fh,01fh,020h,021h,022h,0fah,00fh,024h	; 737c  ..""...... !"..$
	defb 025h,000h,021h,0fah,012h,0f5h,027h,028h,029h,029h,019h,02dh,0f7h,02bh,02bh,01eh	; 738c  %.!...'()).-.++.
	defb 01fh,02ch,029h,019h,02dh,0fah,02eh,026h,026h,000h,021h,0e0h,014h,014h,014h,012h	; 739c  .,).-..&&.!.....
	defb 012h,012h,015h,013h,0e0h,05dh,05dh,05dh,05dh,05ch,05bh,05ah,05ah,059h,058h,057h	; 73ac  .....]]]]\[ZZYXW
	defb 0e0h,064h,063h,062h,061h,060h,060h,060h,05fh,05eh,0e0h,067h,067h,067h,066h,065h	; 73bc  .dcba```_^.gggfe
	defb 00fh,000h,021h,0e5h,014h,0e5h,06bh,05ah,06ah,06ah,069h,068h,0e1h,06eh,05ah,06ah	; 73cc  ..!...kZjjih.nZj
	defb 069h,060h,05fh,06ch,06ch,0e3h,067h,067h,06fh,000h,021h,0e2h,012h,012h,012h,015h	; 73dc  i`_ll.ggo.!.....
	defb 015h,015h,0e1h,063h,063h,05dh,05ch,070h,05ah,05ah,059h,058h,057h,0e1h,063h,062h	; 73ec  ...cc]\pZZYXW.cb
	defb 061h,060h,060h,060h,05fh,05eh,0e3h,066h,065h,00fh,000h,021h,0e5h,012h,0e5h,06eh	; 73fc  a```_^.fe..!...n
	defb 05ah,06ah,06ah,069h,068h,0e1h,06eh,05ah,06ah,06dh,060h,05fh,06ch,06ch,0e3h,067h	; 740c  Zjjih.nZjm`_ll.g
	defb 067h,06fh,000h,061h,0f3h,049h,043h,036h,0f5h,037h,048h,0f6h,03bh,042h,036h,0f8h	; 741c  go.a.IC6.7H.;B6.
	defb 037h,038h,0f8h,00fh,00fh,054h,0fah,050h,047h,004h,0fbh,042h,048h,004h,004h,004h	; 742c  78...T.PG..BH...
	defb 0feh,042h,043h,000h,061h,0f3h,00fh,045h,004h,0f6h,038h,0f6h,04ah,04ch,004h,0f7h	; 743c  .BC.a..E..8.JL..
	defb 037h,044h,038h,0fah,040h,041h,0fah,00fh,042h,043h,0fbh,00fh,051h,0fdh,044h,045h	; 744c  7D8.@A..BC..Q.DE
	defb 004h,0feh,046h,04dh,000h,061h,0f4h,04fh,0f5h,040h,03dh,0f6h,00fh,035h,04dh,0f7h	; 745c  ..FM.a.O.@=..5M.
	defb 04bh,04eh,004h,0f9h,04ah,04bh,0ffh,0fch,00fh,040h,041h,0fdh,00fh,042h,052h,0feh	; 746c  KN..JK...@A..BR.
	defb 04eh,053h,000h,061h,0f4h,03fh,036h,0f5h,046h,03ah,0f8h,036h,0f7h,00fh,037h,050h	; 747c  NS.a.?6.F:.6..7P
	defb 0f8h,04fh,055h,045h,004h,0fah,046h,04ch,049h,0ffh,0ffh,043h,0feh,00fh,00fh,000h	; 748c  .OUE..FLI..C....
	defb 061h,0eah,077h,084h,08ah,0e9h,089h,078h,0e7h,077h,083h,07ch,0e6h,079h,078h,0e5h	; 749c  a.w....x.w.|.yx.
	defb 06ah,00fh,00fh,0e3h,004h,05dh,066h,0e0h,004h,004h,004h,05eh,058h,0e0h,059h,058h	; 74ac  j....]f....^X.YX
	defb 000h,061h,0eah,004h,086h,00fh,0e9h,079h,0e7h,004h,08dh,08bh,0e6h,079h,085h,078h	; 74bc  .a.....y.....y.x
	defb 0e4h,057h,056h,0e3h,059h,058h,00fh,0e3h,067h,00fh,0e0h,004h,05bh,05ah,0e0h,063h	; 74cc  .WV.YX..g...[Z.c
	defb 05ch,000h,061h,0ebh,090h,0e9h,07eh,081h,0e7h,08eh,076h,00fh,0e6h,004h,08fh,08ch	; 74dc  \.a...~...v.....
	defb 0e5h,061h,060h,0ffh,0e1h,057h,056h,00fh,0e0h,068h,058h,00fh,0e0h,069h,064h,000h	; 74ec  .a`..WV..hX..id.
	defb 061h,0eah,077h,080h,0e9h,07bh,087h,0e7h,077h,0e6h,091h,078h,00fh,0e4h,004h,05bh	; 74fc  a.w..{..w..x...[
	defb 06bh,065h,0e3h,05fh,062h,05ch,0ffh,0e0h,059h,0e0h,00fh,00fh,000h	; 750c  ke._b\..Y....

; ======================================================================
; CODIGO 0x7519..0x755f  (70 bytes)
; ======================================================================


DIBUJA_LA_META:		; En los ultimos 100 metros, cada 32 dibuja un trozo mas de la llegada
	ld hl,(0e0e5h)		;7519   ; Solo con la centena a cero, o sea en los ultimos cien metros
	ld a,h			;751c
	or a			;751d
	ret nz			;751e
	ld a,l			;751f
	and 01fh		;7520   ; Y solo en los multiplos de 32
	ret nz			;7522
	ld a,l			;7523
	rlca			;7524
	rlca			;7525
	rlca			;7526
	add a,a			;7527
	ld hl,0755fh		;7528
	call SUMA_A_HL		;752b
	ld e,(hl)		;752e
	inc hl			;752f
	ld d,(hl)		;7530
	ex de,hl		;7531
	ld a,(hl)		;7532
	and 0f0h		;7533
	ld c,a			;7535
	ld a,(hl)		;7536
	inc hl			;7537
	and 003h		;7538
	add a,078h		;753a
	ld d,a			;753c
	ld a,c			;753d
META_FILA:
	ld b,(hl)		;753e
	inc hl			;753f
	ld a,020h		;7540
	add a,c			;7542
	ld c,a			;7543
	jr nc,META_APUNTA		;7544
	inc d			;7546
META_APUNTA:
	ld a,c			;7547
	add a,b			;7548
	sub 0e0h		;7549
	ld e,a			;754b
	call APUNTA_VRAM		;754c
META_CASILLA:
	ld a,(hl)		;754f
	or a			;7550
	ret z			;7551
	cp 0e0h			;7552
	jr nc,META_FILA		;7554
	inc hl			;7556
	add a,040h		;7557   ; Igual que el interprete de bloques, pero con las casillas corridas 0x40
	exx			;7559
	out (c),a		;755a
	exx			;755c
	jr META_CASILLA		;755d

; ----------------------------------------------------------------------
; DATOS punteros_de_la_meta: Cinco punteros, uno por cada tramo de 32 metros del final. Cierra clavada en 0x7569, que es el primero de ellos
;   0x755f..0x7569  (10 bytes)
; DATOS bloques_de_la_meta: Los cinco bloques que va dibujando 0x7519
;   0x7569..0x75ef  (134 bytes)
; ----------------------------------------------------------------------
	defb 0a4h,075h,081h,075h,073h,075h,06eh,075h,069h,075h,021h,0efh,090h,091h,000h,021h	; 755f  .u.usunuiu!....!
	defb 0efh,092h,093h,000h,001h,0efh,0afh,0eeh,094h,096h,096h,098h,0eeh,095h,097h,097h	; 756f  ................
	defb 09ah,000h,0e0h,0efh,0afh,0efh,0b1h,0b2h,0edh,09dh,09bh,09ch,09ch,09ch,09bh,0edh	; 757f  ................
	defb 0c8h,09eh,0a4h,0a6h,0a8h,0a1h,0edh,0c8h,09fh,0a5h,0a7h,0a9h,0c9h,0edh,0a3h,0a0h	; 758f  ................
	defb 0a0h,0a0h,0adh,0a0h,000h,0c0h,0efh,071h,0efh,0b0h,0efh,0b1h,0b2h,0ebh,09dh,09dh	; 759f  .......q........
	defb 09bh,09bh,09bh,09ch,09ch,09ch,09ch,09bh,0ebh,0c8h,0c8h,0c9h,0c9h,0c9h,0c9h,0c9h	; 75af  ................
	defb 0a2h,0a2h,0c9h,0ebh,0c8h,0c8h,0c9h,0aah,0c9h,0aah,0c9h,099h,0c9h,0c9h,0ebh,0c8h	; 75bf  ................
	defb 0c8h,0c9h,0abh,0c9h,0abh,0c9h,099h,0c9h,0c9h,0ebh,0c8h,0c8h,0c9h,0c9h,0c9h,0c9h	; 75cf  ................
	defb 0c9h,0aeh,0c9h,0c9h,0ebh,0a3h,0a3h,0ach,0a0h,0a0h,0ach,0ach,09ah,0a0h,0ach,000h	; 75df  ................

; ======================================================================
; CODIGO 0x75ef..0x7733  (324 bytes)
; ======================================================================


SUELTA_EL_PEZ:		; Cuando un agujero llega al paso 7, sale el pez de dentro
	ld hl,0e183h		;75ef
	ld a,(hl)		;75f2
	and 0e3h		;75f3
	ret nz			;75f5
	ld de,0e113h		;75f6   ; Las tres fichas de obstaculo
	ld b,003h		;75f9
PEZ_BUSCA:
	ld a,(de)		;75fb
	cp 003h			;75fc   ; Solo los tipos 0, 1 y 2, que son los agujeros
	jr nc,PEZ_SIGUIENTE		;75fe
	dec de			;7600
	ld a,(de)		;7601
	cp 007h			;7602
	jr z,PEZ_SALE		;7604   ; Y solo en el paso 7
	inc de			;7606
PEZ_SIGUIENTE:
	ld a,006h		;7607
	call SUMA_A_DE		;7609
	djnz PEZ_BUSCA		;760c
	ret			;760e
PEZ_SALE:
	ld (0e181h),de		;760f
	inc de			;7613
	ld a,(0e18ah)		;7614
	ld c,a			;7617
	ld a,(0e003h)		;7618   ; Antes de que se cumpla el plazo de 0xE18A el pez sale; despues ya no
	cp c			;761b
	jr nc,PEZ_TARDE		;761c
	ld a,(0e009h)		;761e
	and 00ch		;7621
	jr z,PEZ_LADO		;7623
	bit 2,a			;7625
	jr PEZ_MONTA		;7627
PEZ_LADO:
	ld a,(0e185h)		;7629
	inc a			;762c
	ld (0e185h),a		;762d
	bit 0,a			;7630
PEZ_MONTA:		; Monta la entrada de atributo del pez. El DIBUJO sale de aqui: 0x90 si mira a un lado y 0x80 si al otro
	ld a,090h		;7632
	set 0,(hl)		;7634
	jr z,PEZ_ALTURA		;7636
	ld a,080h		;7638
	rlc (hl)		;763a
PEZ_ALTURA:
	ld c,a			;763c
	ld hl,0e08ch		;763d
	ld a,(de)		;7640
	ld d,c			;7641
	cp 001h			;7642
	ld bc,07a66h		;7644   ; CUIDADO CON ESTE `ld bc,07a66h`: 0x66, 0x64 y 0x92 son las X de los tres saltos -corto, medio y largo-, NO patrones. El patron es el que quedo en D unas instrucciones antes
	jr c,PEZ_SALTO_CORTO		;7647
	jr z,PEZ_SALTO_MEDIO		;7649
	ld b,092h		;764b
PEZ_SALTO_CORTO:
	jr PEZ_GUARDA		;764d
PEZ_SALTO_MEDIO:
	ld b,064h		;764f
PEZ_GUARDA:
	ld (hl),c		;7651
	inc hl			;7652
	ld (hl),b		;7653
	inc hl			;7654
	ld (hl),d		;7655
	ret			;7656
PEZ_TARDE:		; Ya no da tiempo: se marca el agujero segun su tipo
	xor a			;7657
	ld (0e192h),a		;7658
	ld a,(de)		;765b
	cp 001h			;765c
	jr c,PEZ_TIPO_0		;765e
	jr z,PEZ_TIPO_1		;7660
	set 5,(hl)		;7662
	ret			;7664
PEZ_TIPO_0:
	set 6,(hl)		;7665
	ret			;7667
PEZ_TIPO_1:
	set 7,(hl)		;7668
	ret			;766a
MUEVE_EL_PEZ:		; Un paso del pez cada dos fotogramas
	ld a,(0e003h)		;766b
	rra			;766e
	ret c			;766f
PEZ_PASO:		; Lo coloca, lo copia a la VRAM y le lleva el arco del salto
	ld hl,(0e08ch)		;7670
	ld (0e188h),hl		;7673   ; 0xE188 es lo que mira MIRA_EL_PEZ para saber si el pinguino lo pisa
	ld hl,0e08ch		;7676
	ld de,03b3ch		;7679   ; Sprite 15
	ld bc,00004h		;767c
	call COPIA_A_VRAM		;767f
	ld de,0e183h		;7682
	ld a,(de)		;7685
	and 003h		;7686
	ret z			;7688
	ld hl,0e08eh		;7689
	call PEZ_GIRA		;768c
	ld a,(de)		;768f
	dec hl			;7690
	rra			;7691
	jr c,PEZ_ARCO_SUBE		;7692
	dec (hl)		;7694
	dec (hl)		;7695
	jr PEZ_ARCO		;7696
PEZ_ARCO_SUBE:
	inc (hl)		;7698
	inc (hl)		;7699
PEZ_ARCO:
	push hl			;769a
	ld hl,0e184h		;769b
	inc (hl)		;769e
	ld a,(hl)		;769f
	pop hl			;76a0
	dec hl			;76a1
	cp 008h			;76a2
	jr c,PEZ_SUBE		;76a4
	cp 010h			;76a6
	ret c			;76a8
	jr z,PEZ_CAE		;76a9
	cp 022h			;76ab
	jr nc,QUITA_EL_PEZ		;76ad
	ld c,005h		;76af
	cp 01ah			;76b1
	jr c,PEZ_ARCO_BAJA		;76b3
	inc c			;76b5
	inc c			;76b6
PEZ_ARCO_BAJA:
	ld a,(hl)		;76b7
	add a,c			;76b8
	ld (hl),a		;76b9
	ret			;76ba
PEZ_SUBE:
	dec (hl)		;76bb
	dec (hl)		;76bc
	ret			;76bd
PEZ_CAE:		; Al llegar al paso 0x10 del arco le SUMA 8 al byte del patron (0xE08E): el pez cambia al dibujo grande. Con eso y el bit 2 que voltea 0x76CD salen OCHO dibujos, cuatro por lado: 0x80-0x8C mirando a un lado y 0x90-0x9C al otro. Los ocho estan MEDIDOS en la partida grabada (work/sprites_medidos.txt), siempre en el color del atributo 15
	inc hl			;76be
	inc hl			;76bf
	ld a,(hl)		;76c0
	add a,008h		;76c1
	ld (hl),a		;76c3
	ret			;76c4
QUITA_EL_PEZ:		; Lo saca de la pantalla poniendole Y=0xE0
	ld (hl),0e0h		;76c5
	xor a			;76c7
	ld (de),a		;76c8
	inc de			;76c9
	ld (de),a		;76ca
	jr PEZ_PASO		;76cb
PEZ_GIRA:		; Cada 16 fotogramas le da la vuelta al BIT 2 del patron y le deja los dos de abajo a cero: eso es lo que anima al pez. Los tres `srl` mas el `ccf` mas los tres `rla` dejan (patron & 0xF8) | (bit2 invertido) << 2
	ld a,(0e003h)		;76cd
	and 00fh		;76d0
	ret nz			;76d2
	ld a,(hl)		;76d3
	srl a			;76d4
	srl a			;76d6
	srl a			;76d8
	ccf			;76da
	rla			;76db
	rla			;76dc
	rla			;76dd
	ld (hl),a		;76de
	ret			;76df
AJUSTA_DIFICULTAD:		; De la velocidad y de la fase sale cada cuantos pasos aparece el siguiente obstaculo
	call MANDA_LA_VELOCIDAD		;76e0
	ld a,(0e100h)		;76e3
	or a			;76e6
	rra			;76e7
	ld (0e148h),a		;76e8   ; 0xE148: la mitad de la velocidad, que es el ritmo de los sprites de fondo
	ld a,(0e0e6h)		;76eb
	and 00ch		;76ee
	ld a,02ch		;76f0
	jr nz,DIFICULTAD_FASE		;76f2
	add a,004h		;76f4
DIFICULTAD_FASE:
	ld c,a			;76f6
	ld a,(0e0e0h)		;76f7
	and 0f0h		;76fa   ; De la fase 10 en adelante, cuatro menos; de la 20, otros cuatro
	jr z,DIFICULTAD_VELOCIDAD		;76fc
	and 0e0h		;76fe
	jr z,DIFICULTAD_RESTA		;7700
	ld a,c			;7702
	sub 004h		;7703
	ld c,a			;7705
DIFICULTAD_RESTA:
	ld a,c			;7706
	sub 004h		;7707
	ld c,a			;7709
DIFICULTAD_VELOCIDAD:
	ld a,(0e100h)		;770a   ; Y lo mismo por tramos de velocidad
	cp 00ch			;770d
	jr c,DIFICULTAD_MENOS_12		;770f
	and 00ch		;7711
	jr z,DIFICULTAD_MENOS_4		;7713
	cp 00ch			;7715
	jr z,DIFICULTAD_MENOS_8		;7717
	ld a,c			;7719
DIFICULTAD_GUARDA:
	ld (0e10eh),a		;771a
	ret			;771d
DIFICULTAD_MENOS_12:
	ld a,c			;771e
	sub 004h		;771f
	ld c,a			;7721
DIFICULTAD_MENOS_8:
	ld a,c			;7722
	sub 004h		;7723
	ld c,a			;7725
DIFICULTAD_MENOS_4:
	ld a,c			;7726
	sub 004h		;7727
	jr DIFICULTAD_GUARDA		;7729

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; LA VELOCIDAD
; ----------------------------------------------------------------------
; Los bits 0 y 1 de los mandos son arriba y abajo, y los cuatro
; destinos de la tabla son: no tocar nada, no hace nada; ARRIBA
; FRENA y ABAJO ACELERA; y las dos a la vez, tampoco hace nada.
; Va del reves de lo que uno esperaria, y ademas acelerar cuesta
; cuatro fotogramas por escalon y frenar doce.
; La velocidad vive en 0xE100 y va de 9 a 0x13.
; ----------------------------------------------------------------------
MANDA_LA_VELOCIDAD:		; Despacha por arriba/abajo para frenar o acelerar
	ld a,(0e009h)		;772b
	and 003h		;772e
	call DESPACHA		;7730

; ----------------------------------------------------------------------
; DATOS tabla_velocidad: Los CUATRO destinos, del CALL de 0x7730: nada, frenar, acelerar, nada
;   0x7733..0x773b  (8 bytes)
; ----------------------------------------------------------------------
	defb 069h,077h,03bh,077h,053h,077h,069h,077h	; 7733  iw;wSwiw

; ======================================================================
; CODIGO 0x773b..0x7836  (251 bytes)
; ======================================================================


FRENA:		; Un escalon menos cada doce fotogramas, hasta 9
	ld hl,0e0fdh		;773b
	xor a			;773e
	ld (hl),a		;773f
	inc hl			;7740
	inc hl			;7741
	ld (hl),a		;7742
	dec hl			;7743
	inc (hl)		;7744
	ld a,(hl)		;7745
	sub 00ch		;7746
	ret nz			;7748
	ld (hl),a		;7749
	ld hl,0e100h		;774a
	ld a,(hl)		;774d
	cp 009h			;774e
	ret c			;7750
	dec (hl)		;7751
	ret			;7752
ACELERA:		; Un escalon mas cada cuatro fotogramas, hasta 0x13
	ld hl,0e0fdh		;7753
	xor a			;7756
	ld (hl),a		;7757
	inc hl			;7758
	ld (hl),a		;7759
	inc hl			;775a
	inc (hl)		;775b
	ld a,(hl)		;775c
	sub 004h		;775d
	ret nz			;775f
	ld (hl),a		;7760
	ld hl,0e100h		;7761
	ld a,(hl)		;7764
	cp 013h			;7765
	ret nc			;7767
	inc (hl)		;7768
NI_UNA_COSA_NI_OTRA:
	ret			;7769
PINTA_VELOCIMETRO:		; Las seis casillas del velocimetro, en la fila 0
	ld a,(0e140h)		;776a   ; Cayendose o en el agua, la barra se queda a cero
	ld hl,0e142h		;776d
	add a,(hl)		;7770
	ld hl,0e171h		;7771
	jr nz,VELOCIMETRO_VACIA		;7774
	ld a,(0e100h)		;7776
	ld b,a			;7779
	and 001h		;777a
	add a,042h		;777c
	ld c,a			;777e
	ld a,b			;777f
	rra			;7780
	cpl			;7781
	and 00fh		;7782
	sub 006h		;7784
	jr z,VELOCIMETRO_CASILLA		;7786
	ld b,a			;7788
VELOCIMETRO_LLENA:
	ld (hl),042h		;7789
	inc hl			;778b
	djnz VELOCIMETRO_LLENA		;778c
VELOCIMETRO_CASILLA:
	ld (hl),c		;778e
	inc hl			;778f
	ld a,l			;7790
	cp 078h			;7791   ; Seis casillas
	jr z,VELOCIMETRO_A_VRAM		;7793
VELOCIMETRO_VACIA:
	ld c,000h		;7795
	jr VELOCIMETRO_CASILLA		;7797
VELOCIMETRO_A_VRAM:
	ld hl,0e171h		;7799
	ld de,03839h		;779c
	ld bc,00006h		;779f
	jp COPIA_A_VRAM		;77a2
LAS_NUBES:		; Las cuatro nubes del cielo. Suben por la pantalla al ritmo de la velocidad, se van abriendo hacia los lados y crecen de patron por el camino: es la perspectiva de acercarse a ellas y pasarles por debajo. Se apagan al llegar arriba (Y=8) y vuelven a salir
	ld a,(0e002h)		;77a5   ; En la demo no salen
	bit 6,a			;77a8
	ret z			;77aa
	ld b,004h		;77ab
	ld de,0e0b8h		;77ad
	ld hl,0e14ah		;77b0
NUBE_NUEVA:
	ld a,(hl)		;77b3
	or a			;77b4
	ld a,004h		;77b5
	jr nz,NUBE_SIGUIENTE		;77b7
	push hl			;77b9
	inc (hl)		;77ba
	ld hl,07838h		;77bb   ; Donde empieza cada uno
	ld a,b			;77be
	add a,a			;77bf
	call SUMA_A_HL		;77c0
	ld a,(hl)		;77c3
	ld (de),a		;77c4
	inc hl			;77c5
	inc de			;77c6
	ld a,(hl)		;77c7
	ld (de),a		;77c8
	inc de			;77c9
	ld a,0e0h		;77ca
	ld (de),a		;77cc
	inc de			;77cd
	ld a,00fh		;77ce
	ld (de),a		;77d0
	ld a,001h		;77d1
	pop hl			;77d3
NUBE_SIGUIENTE:
	call SUMA_A_DE		;77d4
	inc hl			;77d7
	djnz NUBE_NUEVA		;77d8
	ld hl,0e149h		;77da
	dec (hl)		;77dd
	ret nz			;77de
	ld a,(0e148h)		;77df   ; El ritmo al que suben, que es la mitad de la velocidad del pinguino
	ld (hl),a		;77e2
	ld b,000h		;77e3
	ld hl,0e14ah		;77e5
	ld de,0e0b8h		;77e8
MUEVE_LAS_NUBES:
	ld a,(hl)		;77eb
	or a			;77ec
	jr z,NUBE_AVANZA		;77ed
	ld a,(de)		;77ef
	cp 008h			;77f0
	jr nz,NUBE_PASO		;77f2
	ld a,0d1h		;77f4   ; EL 0xD1 NO ES UN PATRON: DE apunta al byte de la Y, asi que esto saca la nube por abajo cuando ha llegado arriba del todo. Los patrones de nube son solo TRES -0xE0 al asomar, 0xDC y 0xD8 segun se acerca-, y el color 0x0F se lo pone a mano 0x77CE
	ld (de),a		;77f6
	ld (hl),000h		;77f7
	jr NUBE_AVANZA		;77f9
NUBE_PASO:
	push de			;77fb
	inc (hl)		;77fc
	ex de,hl		;77fd
	dec (hl)		;77fe
	push de			;77ff
	ld de,07836h		;7800
	ld a,b			;7803
	call SUMA_A_DE		;7804
	ld a,(de)		;7807
	inc hl			;7808
	add a,(hl)		;7809
	ld (hl),a		;780a
	ex de,hl		;780b
	pop hl			;780c
	ld a,(hl)		;780d
	cp 00ch			;780e
	ld a,0dch		;7810
	jr z,NUBE_CRECE		;7812
	ld a,(hl)		;7814
	cp 018h			;7815
	ld a,0d8h		;7817
	jr nz,NUBE_RECUPERA		;7819
NUBE_CRECE:
	inc de			;781b
	ld (de),a		;781c
NUBE_RECUPERA:
	pop de			;781d
NUBE_AVANZA:
	ld a,004h		;781e
	call SUMA_A_DE		;7820
	inc hl			;7823
	ld a,004h		;7824
	inc b			;7826
	cp b			;7827
	jr nz,MUEVE_LAS_NUBES		;7828
	ld hl,0e0b8h		;782a
	ld de,03b68h		;782d
	ld bc,00010h		;7830
	jp COPIA_A_VRAM		;7833

; ----------------------------------------------------------------------
; DATOS nubes_desplazamientos: Cuanto se corre de lado cada nube en cada paso: -1, +1, -2 y +2. Con la Y subiendo y la X abriendose, las cuatro se separan del centro segun se acercan
;   0x7836..0x783a  (4 bytes)
; DATOS nubes_posiciones: Por donde asoma cada nube: cuatro parejas (Y, X), las cuatro en la misma columna y a alturas distintas
;   0x783a..0x7842  (8 bytes)
; ----------------------------------------------------------------------
	defb 0ffh,001h,0feh,002h,038h,098h,037h,058h,03ch,07ch,03ah,074h	; 7836  ....8.7X<|:t

; ======================================================================
; CODIGO 0x7842..0x78c1  (127 bytes)
; ======================================================================


ANIMA_LA_FOCA:		; Saca la foca del agujero: ocho pasos, del 7 al 14, con su fotograma sacado de la tabla de 0x78C1. Dibujada, se la reconoce: primero asoma un filo, luego la cabeza, y del paso 10 en adelante el cuerpo entero con las dos aletas
	ld a,(0e183h)		;7842
	and 0e0h		;7845
	ret z			;7847
	ld hl,(0e181h)		;7848   ; 0xE181 apunta al byte de ESTADO de la ficha, asi que esto es EL PASO en que va, no el tipo
	ld a,(hl)		;784b
	ld hl,0e183h		;784c
	sub 00fh		;784f
	jr nz,FOCA_FOTOGRAMA		;7851
	ld (hl),a		;7853
	ld hl,079bdh		;7854
	ld b,004h		;7857
	jr FOCA_COPIA		;7859
FOCA_FOTOGRAMA:		; Coge el fotograma del paso en que va
	ld hl,078c1h		;785b   ; paso-15+8 = paso-7: ocho entradas, para los pasos 7 a 14
	add a,008h		;785e
	ld b,a			;7860
	add a,a			;7861
	call SUMA_A_HL		;7862
	ld e,(hl)		;7865
	inc hl			;7866
	ld d,(hl)		;7867
	ld a,b			;7868
	ld b,004h		;7869
	cp 006h			;786b
	jr c,FOCA_PASO		;786d
	ld hl,0e137h		;786f
	bit 0,(hl)		;7872
	jr nz,FOCA_PASO		;7874
	ld hl,0e192h		;7876
	ld (hl),001h		;7879
FOCA_PASO:
	cp 003h			;787b
	ex de,hl		;787d
	ld d,00ch		;787e
	jr nc,FOCA_AVANZA		;7880
	ld d,006h		;7882
	ld b,002h		;7884
FOCA_AVANZA:
	ld a,(0e183h)		;7886
	cp 040h			;7889
	jr z,FOCA_COPIA		;788b
	jr c,FOCA_AVANZA_UNO		;788d
	ld a,d			;788f
	call SUMA_A_HL		;7890
FOCA_AVANZA_UNO:
	ld a,d			;7893
	call SUMA_A_HL		;7894
FOCA_COPIA:
	ld de,0e090h		;7897
	push de			;789a
FOCA_ENTRADA:
	ld c,003h		;789b
FOCA_BYTE:		; Copia Y, X y patron, y se SALTA el cuarto byte del atributo: el color. Por eso el color de la foca no esta en el fotograma sino en la lista de atributos de 0x66EF, que le deja el primer sprite en NEGRO y los otros tres en ROJO OSCURO. Dibujada asi es una foca con la cara oscura, porque el negro es el atributo 16 y en un MSX el numero mas bajo va delante
	ld a,(hl)		;789d
	ld (de),a		;789e
	inc hl			;789f
	inc de			;78a0
	dec c			;78a1
	jr nz,FOCA_BYTE		;78a2
	inc de			;78a4
	djnz FOCA_ENTRADA		;78a5
	pop hl			;78a7
	ld c,010h		;78a8
	ld a,(0e192h)		;78aa
	rra			;78ad
	ld de,03b00h		;78ae   ; Cuatro sprites, y si hace falta tambien los otros cuatro
	jr nc,FOCA_A_VRAM		;78b1
	call COPIA_A_VRAM		;78b3
	ld hl,0e050h		;78b6
FOCA_A_VRAM:
	ld de,03b40h		;78b9
	ld c,010h		;78bc
	jp COPIA_A_VRAM		;78be

; ----------------------------------------------------------------------
; DATOS punteros_de_la_foca: Ocho punteros, uno por cada paso del 7 al 14. 0x785B los indexa con paso-7, no con el tipo de obstaculo: leido de la otra manera salen punteros que se van fuera del cartucho. Cierra clavada en 0x78D3, que es el primero de ellos
;   0x78c1..0x78d1  (16 bytes)
; DATOS fotogramas_de_la_foca: Los ocho fotogramas, cada uno con TRES variantes que elige 0x7886 con el bit que 0x7657 encendio en 0xE183. Los tres primeros pasos llevan dos sprites (18 bytes = 3 x 2 x 3) y los cinco siguientes cuatro (36 bytes); de cada sprite van tres bytes: Y, X y patron. LAS TRES VARIANTES LLEVAN EL MISMO DIBUJO y solo cambian la X: una sale por el centro (0x78), otra se va a la derecha y otra a la izquierda, separandose mas en cada paso. Y del paso 10 al 14 los cuatro patrones son siempre C0, C4, C8 y CC: lo unico que cambia es la Y, que baja de 0x7B a 0xA1. La foca no se deforma, se acerca
;   0x78d1..0x79bd  (236 bytes)
; DATOS foca_escondida: El fotograma del paso 15, con las cuatro Y a 0xE0 para sacarla de la pantalla. Cierra clavado en 0x79C9, donde vuelve a haber codigo
;   0x79bd..0x79c9  (12 bytes)
; ----------------------------------------------------------------------
	defb 0d3h,078h,0e5h,078h,0f7h,078h,009h,079h,02dh,079h,051h,079h,075h,079h,099h,079h	; 78c1  .x.x.x.y-yQyuy.y
	defb 0bdh,079h,067h,078h,07ch,067h,078h,0e8h,067h,090h,07ch,067h,090h,0e8h,067h,060h	; 78d1  .ygx|gx.g.|g..g`
	defb 07ch,067h,060h,0e8h,06ch,078h,0b8h,06ch,078h,0bch,06ch,094h,0b8h,06ch,094h,0bch	; 78e1  |g`.lx.lx.l..l..
	defb 06ch,05bh,0b8h,06ch,05bh,0bch,078h,078h,0b8h,078h,078h,0bch,078h,09dh,0b8h,078h	; 78f1  l[.l[.xx.xx.x..x
	defb 09dh,0bch,078h,053h,0b8h,078h,053h,0bch,07bh,078h,0c0h,08bh,070h,0c4h,07bh,078h	; 7901  ..xS.xS.{x..p.{x
	defb 0c8h,08bh,080h,0cch,07bh,0a4h,0c0h,08bh,09ch,0c4h,07bh,0a4h,0c8h,08bh,0ach,0cch	; 7911  ....{.....{.....
	defb 07bh,04ch,0c0h,08bh,044h,0c4h,07bh,04ch,0c8h,08bh,054h,0cch,086h,078h,0c0h,096h	; 7921  {L..D.{L..T..x..
	defb 070h,0c4h,086h,078h,0c8h,096h,080h,0cch,086h,0ach,0c0h,096h,0a4h,0c4h,086h,0ach	; 7931  p..x............
	defb 0c8h,096h,0b4h,0cch,086h,044h,0c0h,096h,03ch,0c4h,086h,044h,0c8h,096h,04ch,0cch	; 7941  .....D..<..D..L.
	defb 08fh,078h,0c0h,09fh,070h,0c4h,08fh,078h,0c8h,09fh,080h,0cch,08fh,0b2h,0c0h,09fh	; 7951  .x..p..x........
	defb 0aah,0c4h,08fh,0b2h,0c8h,09fh,0bah,0cch,08fh,03eh,0c0h,09fh,036h,0c4h,08fh,03eh	; 7961  .........>..6..>
	defb 0c8h,09fh,046h,0cch,098h,078h,0c0h,0a8h,070h,0c4h,098h,078h,0c8h,0a8h,080h,0cch	; 7971  ..F..x..p..x....
	defb 098h,0b8h,0c0h,0a8h,0b0h,0c4h,098h,0b8h,0c8h,0a8h,0c0h,0cch,098h,038h,0c0h,0a8h	; 7981  .............8..
	defb 030h,0c4h,098h,038h,0c8h,0a8h,040h,0cch,0a1h,078h,0c0h,0b1h,070h,0c4h,0a1h,078h	; 7991  0..8..@..x..p..x
	defb 0c8h,0b1h,080h,0cch,0a1h,0beh,0c0h,0b1h,0b6h,0c4h,0a1h,0beh,0c8h,0b1h,0c6h,0cch	; 79a1  ................
	defb 0a1h,032h,0c0h,0b1h,02ah,0c4h,0a1h,032h,0c8h,0b1h,03ah,0cch,0e0h,000h,000h,0e0h	; 79b1  .2..*..2..:.....
	defb 000h,000h,0e0h,000h,000h,0e0h,000h,000h	; 79c1  ........

; ======================================================================
; CODIGO 0x79c9..0x7b37  (366 bytes)
; ======================================================================


PIDE_SONIDO:		; Pone en marcha el sonido A, si su numero manda mas que el que ya suena
	di			;79c9
	push hl			;79ca
	push de			;79cb
	push bc			;79cc
	push af			;79cd
	call PIDE_SONIDO_SIN_GUARDAR		;79ce
	pop af			;79d1
	pop bc			;79d2
	pop de			;79d3
	pop hl			;79d4
	ei			;79d5
	ret			;79d6
PIDE_SONIDO_SIN_GUARDAR:
	ld b,002h		;79d7
	ld hl,0e012h		;79d9
	cp 08ah			;79dc   ; Menos de 0x8A: un canal
	jr c,SONIDO_UN_CANAL		;79de
	cp 08ch			;79e0   ; Menos de 0x8C: dos
	jr c,SONIDO_PRIORIDAD		;79e2
	inc b			;79e4   ; De ahi arriba: los tres
	jr SONIDO_PRIORIDAD		;79e5
SONIDO_UN_CANAL:
	dec b			;79e7
	ld hl,0e026h		;79e8
SONIDO_PRIORIDAD:
	cp (hl)			;79eb   ; Si el que suena manda mas, no se toca
	jr c,SONIDO_NO		;79ec
	ld c,a			;79ee
	and 03fh		;79ef
	add a,a			;79f1
	ld de,07b52h		;79f2   ; La tabla de flujos
	call SUMA_A_DE		;79f5
SONIDO_MONTA_CANAL:
	dec hl			;79f8
	dec hl			;79f9
	ld (hl),001h		;79fa
	inc hl			;79fc
	ld (hl),001h		;79fd
	inc hl			;79ff
	ld a,c			;7a00
	ld (hl),a		;7a01
	inc hl			;7a02
	ld a,(de)		;7a03
	ld (hl),a		;7a04
	inc hl			;7a05
	inc de			;7a06
	ld a,(de)		;7a07
	ld (hl),a		;7a08
	ld a,008h		;7a09
	call SUMA_A_HL		;7a0b
	inc de			;7a0e
	djnz SONIDO_MONTA_CANAL		;7a0f
SONIDO_NO:
	ret			;7a11
SONIDO_REPITE:		; El 0xFE: repite el trozo las veces que diga el byte de detras
	inc hl			;7a12
	ld a,(hl)		;7a13
	inc a			;7a14
	jr z,SONIDO_ENCADENA		;7a15
	inc (ix+009h)		;7a17
	dec a			;7a1a
	cp (ix+009h)		;7a1b
	jr nz,SONIDO_ENCADENA		;7a1e
	xor a			;7a20
	ld (ix+009h),a		;7a21
	jp CALLA_CANAL		;7a24
SONIDO_ENCADENA:		; Al acabarse un flujo puede arrancar otro
	ld a,(ix+002h)		;7a27
	push bc			;7a2a
	call PIDE_SONIDO_SIN_GUARDAR		;7a2b
	pop bc			;7a2e
	ret			;7a2f
ATIENDE_SONIDO:		; Un paso de los tres canales; la llama la interrupcion
	ld a,007h		;7a30
	call 00096h		;7a32   ; BIOS RDPSG - Reads value from PSG-register | Respeta el mezclador y solo se queda con los bits que le importan
	and 0b8h		;7a35
	ld e,a			;7a37
	ld a,007h		;7a38
	call 00093h		;7a3a   ; BIOS WRTPSG - Writes data to PSG-register
	ld c,001h		;7a3d
	ld ix,0e010h		;7a3f   ; Los tres bloques de estado, de diez en diez bytes
	exx			;7a43
	ld b,003h		;7a44
	ld de,0000ah		;7a46
SONIDO_CANAL:
	exx			;7a49
	ld a,(ix+002h)		;7a4a
	or a			;7a4d
	call nz,PASO_DE_CANAL	;7a4e
	inc c			;7a51
	inc c			;7a52
	exx			;7a53
	add ix,de		;7a54
	djnz SONIDO_CANAL		;7a56
	exx			;7a58
	ret			;7a59
PASO_DE_CANAL:
	jp m,NOTA_DECAE		;7a5a
	dec (ix+000h)		;7a5d
	ret nz			;7a60
LEE_NOTA:		; Saca del flujo la nota que toca
	ld l,(ix+003h)		;7a61
	ld h,(ix+004h)		;7a64
	ld a,(hl)		;7a67
	cp 0feh			;7a68   ; 0xFE repite, 0xFF acaba
	jr z,SONIDO_REPITE		;7a6a
	jr nc,CALLA_CANAL		;7a6c
	bit 7,(ix+002h)		;7a6e
	jp nz,NOTA_CONTROL		;7a72
	and 0f0h		;7a75
	cp 020h			;7a77
	jr nz,NOTA_NORMAL		;7a79
	ld a,(hl)		;7a7b
	and 00fh		;7a7c
	ld (ix+001h),a		;7a7e
	inc hl			;7a81
NOTA_NORMAL:
	ld a,(hl)		;7a82
	and 0f0h		;7a83
	ld b,a			;7a85
	xor (hl)		;7a86
	ld d,a			;7a87
	inc hl			;7a88
	ld e,(hl)		;7a89
	inc hl			;7a8a
	ld (ix+003h),l		;7a8b
	ld (ix+004h),h		;7a8e
	ex de,hl		;7a91
	call ESCRIBE_PERIODO		;7a92
	ld a,b			;7a95
	rrca			;7a96
	rrca			;7a97
	rrca			;7a98
	rrca			;7a99
	and 00fh		;7a9a
NOTA_VOLUMEN:
	ld h,a			;7a9c
	ld a,(ix+001h)		;7a9d
	ld (ix+000h),a		;7aa0
	add a,003h		;7aa3
	ld (ix+008h),a		;7aa5
	jr ESCRIBE_VOLUMEN		;7aa8
CALLA_CANAL:
	xor a			;7aaa
	ld (ix+002h),a		;7aab
	ld h,a			;7aae
	jr ESCRIBE_VOLUMEN		;7aaf
NOTA_DECAE:		; Mientras dura la nota le va bajando el volumen
	dec (ix+000h)		;7ab1
	jr z,LEE_NOTA		;7ab4
	dec (ix+008h)		;7ab6
	ld a,(ix+008h)		;7ab9
	cp (ix+000h)		;7abc
	jr nz,DECAE_MAS		;7abf
	cp 001h			;7ac1
	jr c,DECAE_VOLUMEN		;7ac3
	ret			;7ac5
DECAE_MAS:
	dec (ix+008h)		;7ac6
DECAE_VOLUMEN:
	ld a,(ix+007h)		;7ac9
	dec a			;7acc
	ret m			;7acd
	ld (ix+007h),a		;7ace
	ld h,a			;7ad1
ESCRIBE_VOLUMEN:
	ld a,c			;7ad2
	rrca			;7ad3
	add a,088h		;7ad4
	ld e,h			;7ad6
	jp 00093h		;7ad7   ; BIOS WRTPSG - Writes data to PSG-register
NOTA_CONTROL:		; El 0xFD: cambia la octava y el decaimiento
	cp 0fdh			;7ada
	jr nz,NOTA_MONTA		;7adc
	inc hl			;7ade
	ld a,(hl)		;7adf
	and 007h		;7ae0
	ld (ix+005h),a		;7ae2
	xor (hl)		;7ae5
	rrca			;7ae6
	rrca			;7ae7
	rrca			;7ae8
	ld (ix+006h),a		;7ae9
	inc hl			;7aec
	ld a,(hl)		;7aed
NOTA_MONTA:
	and 00fh		;7aee
	ld b,a			;7af0
	xor (hl)		;7af1
	inc hl			;7af2
	ld (ix+003h),l		;7af3
	ld (ix+004h),h		;7af6
	rrca			;7af9
	rrca			;7afa
	rrca			;7afb
	rrca			;7afc
	ld hl,07b44h		;7afd
	call SUMA_A_HL		;7b00
	ld a,(hl)		;7b03
	ld (ix+001h),a		;7b04
	ld a,b			;7b07
	sub 00ch		;7b08
	ld (ix+007h),a		;7b0a
	jr z,NOTA_PERIODO		;7b0d
	ld a,(ix+006h)		;7b0f
	ld (ix+007h),a		;7b12
NOTA_PERIODO:
	call NOTA_VOLUMEN		;7b15
	ld a,b			;7b18
	ld hl,07b38h		;7b19
	call SUMA_A_HL		;7b1c
	ld l,(hl)		;7b1f
	ld h,000h		;7b20
	ld a,(ix+005h)		;7b22
	or a			;7b25
	jr z,ESCRIBE_PERIODO		;7b26
	ld b,a			;7b28
NOTA_OCTAVA:		; Subir de octava es doblar el periodo tantas veces como diga
	add hl,hl		;7b29
	djnz NOTA_OCTAVA		;7b2a
ESCRIBE_PERIODO:		; Los dos registros del PSG de este canal
	ld a,c			;7b2c
	ld e,h			;7b2d
	call 00093h		;7b2e   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,c			;7b31
	dec a			;7b32
	ld e,l			;7b33
	jp 00093h		;7b34   ; BIOS WRTPSG - Writes data to PSG-register

; ----------------------------------------------------------------------
; DATOS byte_suelto: Un 0xFF que no apunta nadie, justo delante de la tabla de notas
;   0x7b37..0x7b38  (1 bytes)
; DATOS tabla_de_notas: Doce periodos, una octava cromatica: la desviacion respecto al temperamento igual es de 0,090 semitonos, y los doce bytes de al lado dan 15,8
;   0x7b38..0x7b44  (12 bytes)
; DATOS tabla_de_duraciones: Las doce duraciones, indexadas por el nibble alto de cada nota. Van de 5 a 100 fotogramas y NO son una escala, aunque esten pegadas a la que si lo es
;   0x7b44..0x7b52  (14 bytes)
; DATOS punteros_de_sonido: Veinticuatro punteros a los flujos. Cierra clavada en 0x7B82, que es el primero. El del sonido 0 apunta fuera de la ROM porque no se pide nunca, y los tres ultimos apuntan al 0xFF de 0x7B82: el sonido 0x95, el que llama 0x44BD al arrancar, es un flujo que se acaba en el primer byte, o sea el silencio
;   0x7b52..0x7b82  (48 bytes)
; DATOS flujos_de_sonido: Los veintiun flujos de musica y efectos
;   0x7b82..0x7eb7  (821 bytes)
; DATOS relleno_final: Lo que sobra del cartucho hasta los 16 KB
;   0x7eb7..0x8000  (329 bytes)
; ----------------------------------------------------------------------
	defb 0ffh,06ah,064h,05fh,059h,054h,050h,04bh,047h,043h,03fh,03ch,038h,008h,010h,020h	; 7b37  .jd_YTPKGC?<8.. 
	defb 030h,040h,060h,005h,00ah,00fh,014h,064h,01eh,018h,03ch,050h,028h,046h,07dh,020h	; 7b47  0@`....d..<P(F} 
	defb 07dh,07eh,07dh,086h,07dh,06ah,07dh,05eh,07dh,04ch,07dh,075h,07eh,02eh,07dh,083h	; 7b57  }~}.}j}^}L}u~.}.
	defb 07bh,003h,07ch,022h,07eh,03fh,07eh,062h,07eh,0d9h,07ch,0f7h,07ch,00eh,07dh,08eh	; 7b67  {.|"~?~b~.|.|.}.
	defb 07dh,0c0h,07dh,0f3h,07dh,082h,07bh,082h,07bh,082h,07bh,0ffh,0fdh,05ah,03bh,0fdh	; 7b77  }.}.}.{.{.{..Z;.
	defb 059h,022h,014h,054h,030h,024h,016h,056h,039h,027h,0fdh,05ah,01bh,0fdh,059h,032h	; 7b87  Y".T0$.V9'.Z..Y2
	defb 020h,0fdh,05ah,01bh,03bh,039h,047h,0fdh,059h,002h,007h,004h,007h,002h,007h,004h	; 7b97   .Z.;9G.Y.......
	defb 007h,002h,007h,004h,007h,002h,007h,004h,007h,012h,006h,00ch,006h,00ch,012h,006h	; 7ba7  ................
	defb 00ch,006h,00ch,002h,009h,004h,009h,002h,009h,004h,009h,002h,009h,004h,009h,012h	; 7bb7  ................
	defb 007h,00ch,007h,00ch,012h,007h,00ch,007h,00ch,002h,007h,006h,007h,002h,007h,002h	; 7bc7  ................
	defb 007h,005h,007h,002h,007h,000h,007h,004h,007h,000h,007h,000h,007h,003h,007h,000h	; 7bd7  ................
	defb 007h,0fdh,05ah,00bh,0fdh,059h,007h,002h,007h,0fdh,05ah,00bh,0fdh,059h,007h,000h	; 7be7  ..Z..Y....Z..Y..
	defb 006h,002h,006h,000h,006h,017h,01ch,016h,017h,02ch,0feh,0ffh,0fdh,05bh,017h,0fdh	; 7bf7  .........,...[..
	defb 05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,010h	; 7c07  Z...[..Z...[..Z.
	defb 010h,0fdh,05bh,017h,0fdh,05ah,010h,010h,0fdh,05bh,017h,0fdh,05ah,014h,014h,0fdh	; 7c17  ..[..Z...[..Z...
	defb 05bh,017h,0fdh,05ah,014h,014h,0fdh,05bh,016h,0fdh,05ah,012h,012h,0fdh,05bh,016h	; 7c27  [..Z...[..Z...[.
	defb 0fdh,05ah,012h,012h,0fdh,05bh,010h,019h,019h,017h,0fdh,05ah,012h,012h,0fdh,05bh	; 7c37  .Z...[.....Z...[
	defb 017h,0fdh,05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh	; 7c47  ..Z...[..Z...[..
	defb 05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h	; 7c57  Z...[..Z...[..Z.
	defb 0fdh,05bh,01bh,027h,01ch,01bh,0fdh,05ah,012h,012h,0fdh,05bh,01bh,0fdh,05ah,012h	; 7c67  .[.'...Z...[..Z.
	defb 012h,0fdh,05bh,016h,0fdh,05ah,012h,012h,0fdh,05bh,016h,0fdh,05ah,012h,012h,0fdh	; 7c77  ..[..Z...[..Z...
	defb 05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,017h	; 7c87  [..Z...[..Z...[.
	defb 0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h,012h,0fdh,05bh,012h,017h,01bh	; 7c97  .Z...[..Z...[...
	defb 017h,01bh,0fdh,05ah,012h,0fdh,05bh,017h,0fdh,05ah,010h,014h,0fdh,05bh,017h,0fdh	; 7ca7  ...Z..[..Z...[..
	defb 05ah,010h,014h,0fdh,05bh,017h,0fdh,05ah,012h,01ch,0fdh,05bh,019h,0fdh,05ah,012h	; 7cb7  Z...[..Z...[..Z.
	defb 01ch,012h,01ch,0fdh,05bh,01bh,0fdh,05ah,002h,000h,0fdh,05bh,00bh,009h,007h,00ch	; 7cc7  ....[..Z...[....
	defb 0feh,0ffh,0fdh,059h,090h,080h,060h,090h,0fdh,05ah,08bh,069h,097h,094h,097h,094h	; 7cd7  ...Y..`..Z.i....
	defb 072h,074h,075h,077h,079h,077h,079h,07bh,0fdh,061h,090h,080h,060h,090h,0ffh,0ffh	; 7ce7  rtuwywy{.a..`...
	defb 0fdh,05bh,097h,097h,097h,09ch,097h,097h,097h,09ch,095h,092h,097h,0fdh,05ch,097h	; 7cf7  .[............\.
	defb 0fdh,063h,090h,097h,097h,0ffh,0ffh,0fdh,05bh,090h,090h,090h,09ch,090h,090h,090h	; 7d07  .c......[.......
	defb 09ch,0ach,0fdh,05ah,084h,064h,094h,0ffh,0ffh,022h,0d0h,07fh,0b0h,070h,0b0h,077h	; 7d17  ...Z.d..."...p.w
	defb 0a0h,062h,090h,050h,080h,043h,0ffh,023h,090h,060h,090h,040h,090h,060h,090h,040h	; 7d27  .b.P.C.#.`.@.`.@
	defb 090h,060h,090h,040h,090h,060h,090h,040h,090h,060h,090h,040h,090h,060h,0ffh,021h	; 7d37  .`.@.`.@.`.@.`.!
	defb 0a0h,025h,0a0h,027h,0ffh,021h,0c0h,0ddh,0c0h,0bbh,0b0h,0aah,0b0h,099h,0a0h,088h	; 7d47  .%.'.!..........
	defb 0a0h,077h,090h,066h,090h,055h,0ffh,022h,0c0h,055h,0c0h,066h,0c0h,055h,0b0h,044h	; 7d57  .w.f.U.".U.f.U.D
	defb 0a0h,033h,0ffh,022h,0e0h,0a5h,0c0h,0b5h,0a0h,0c5h,090h,0d5h,080h,0e5h,070h,0f5h	; 7d67  .3."..........p.
	defb 061h,005h,051h,025h,051h,045h,0ffh,021h,0c1h,003h,0c1h,00dh,0c1h,006h,0ffh,021h	; 7d77  a.Q%QE.!.......!
	defb 0c1h,043h,0c1h,04dh,0c1h,046h,0ffh,0fdh,05ah,07bh,0fdh,059h,072h,074h,072h,097h	; 7d87  .C.M.F..Z{.Yrtr.
	defb 076h,074h,0b2h,0fdh,05ah,07bh,097h,067h,069h,06bh,0fdh,059h,060h,0fdh,05ah,07bh	; 7d97  vt..Z{.gik.Y`.Z{
	defb 0fdh,059h,072h,074h,072h,097h,076h,074h,062h,064h,062h,060h,0fdh,05ah,06bh,0fdh	; 7da7  .Yrtr.vtbdb`.Zk.
	defb 059h,060h,0fdh,05ah,06bh,069h,097h,09ch,0ffh,0fdh,05ah,077h,07bh,0fdh,059h,070h	; 7db7  Y`.Zki....Zw{.Yp
	defb 0fdh,05ah,07bh,0fdh,059h,092h,070h,070h,0fdh,05ah,0bbh,077h,092h,09ch,077h,07bh	; 7dc7  .Z{.Y.pp.Z.w..w{
	defb 0fdh,059h,070h,0fdh,05ah,07bh,0fdh,059h,092h,070h,070h,0fdh,05ah,06bh,0fdh,059h	; 7dd7  .Yp.Z{.Y.pp.Zk.Y
	defb 060h,0fdh,05ah,06bh,069h,067h,069h,067h,066h,092h,09ch,0ffh,0fdh,05bh,077h,076h	; 7de7  `.Zkigigf....[wv
	defb 074h,072h,070h,0fdh,05ch,07bh,079h,077h,0fdh,05bh,077h,076h,074h,072h,070h,0fdh	; 7df7  trp.\{yw.[wvtrp.
	defb 05ch,07bh,079h,077h,0fdh,05bh,077h,076h,074h,072h,070h,0fdh,05ch,07bh,079h,077h	; 7e07  \{yw.[wvtrp.\{yw
	defb 0fdh,05bh,072h,0fdh,05ch,072h,074h,076h,077h,09ch,0ffh,0fdh,059h,094h,074h,074h	; 7e17  .[r.\rtvw...Y.tt
	defb 094h,072h,070h,0b5h,0fdh,05ah,075h,0b5h,0fdh,059h,075h,094h,070h,074h,092h,0fdh	; 7e27  .rp..Zu..Yu.pt..
	defb 05ah,079h,07bh,0fdh,059h,0d0h,01ch,0ffh,0fdh,05bh,090h,070h,070h,090h,0fdh,05ah	; 7e37  Zy{.Y....[.pp..Z
	defb 07bh,077h,0fdh,059h,0b0h,0fdh,05ah,070h,0b0h,0fdh,059h,070h,090h,0fdh,05ah,077h	; 7e47  {w.Y..Zp..Yp..Zw
	defb 0fdh,059h,070h,0fdh,05ah,09bh,075h,077h,0d7h,01ch,0ffh,0fdh,05bh,097h,094h,097h	; 7e57  .Yp.Z.uw....[...
	defb 094h,099h,095h,099h,095h,097h,094h,097h,095h,097h,097h,097h,09ch,0ffh,022h,0d1h	; 7e67  ..............".
	defb 0eeh,0d1h,0cch,0c1h,0eeh,0b1h,0ffh,0a1h,099h,091h,088h,081h,077h,071h,066h,061h	; 7e77  ............wqfa
	defb 077h,051h,088h,041h,099h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7e87  wQ.A............
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7e97  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ea7  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7eb7  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ec7  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ed7  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ee7  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ef7  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f07  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f17  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f27  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f37  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f47  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f57  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f67  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f77  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f87  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f97  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fa7  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fb7  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fc7  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fd7  ................
	defb 0ffh,0ffh,0ach,088h,082h,0b7h,09dh,081h,0b7h,08fh,000h,087h,0b3h,086h,0ach,094h	; 7fe7  ................
	defb 000h,087h,0b3h,086h,0b5h,088h,014h,001h,0aah	; 7ff7  .........
