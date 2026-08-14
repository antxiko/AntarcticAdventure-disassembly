; ==========================================================================
; ANTARCTIC ADVENTURE - Konami (1984) - MSX1 - cartucho de 16 KB - primera version japonesa
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x04000


; ----------------------------------------------------------------------
; Direcciones que solo aparecen como VALOR -en un `ld`, no en
; un salto-: son punteros que el codigo se pasa o numeros que
; casualmente coinciden con una direccion. No hay nada que
; trazar en ellas; el equ existe para que el listado ensamble.
; ----------------------------------------------------------------------
l4ebdh:	equ 0x04ebd
l4f78h:	equ 0x04f78

; ----------------------------------------------------------------------
; DATOS cabecera_del_cartucho: La cabecera que lee la BIOS: "AB", INIT=0x4010, y a cero los otros tres vectores (STATEMENT, DEVICE y TEXT). Con eso la BIOS llama a 0x4010 nada mas terminar de arrancar la maquina
;   0x4000..0x4010  (16 bytes)
; ----------------------------------------------------------------------
	defb 041h,042h,010h,040h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 4000  AB.@............

; ======================================================================
; CODIGO 0x4010..0x4119  (265 bytes)
; ======================================================================


L_4010:
	di			;4010
	im 1			;4011
	ld a,0c3h		;4013
	ld (0fd9ah),a		;4015
	ld hl,L_4044		;4018
	ld (0fd9bh),hl		;401b
	ld sp,0e400h		;401e
	ld hl,0e000h		;4021
	ld de,0e001h		;4024
	ld bc,007ffh		;4027
	ld (hl),000h		;402a
	ldir			;402c
	ld a,001h		;402e
	ld (0e005h),a		;4030
	call L_4482		;4033
	di			;4036
	xor a			;4037
	ld (0e005h),a		;4038
	inc a			;403b
	ld (0e000h),a		;403c
	in a,(099h)		;403f
	ei			;4041
L_4042:
	jr L_4042		;4042
L_4044:
	push af			;4044
	push bc			;4045
	push de			;4046
	push hl			;4047
	di			;4048
	in a,(099h)		;4049
	ld a,(0e000h)		;404b
	or a			;404e
	jr z,L_4054		;404f
	call L_79D7		;4051
L_4054:
	ld a,(0e000h)		;4054
	cp 00ch			;4057
	jr nc,L_4077		;4059
	ld a,(0e140h)		;405b
	ld hl,0e142h		;405e
	add a,(hl)		;4061
	jr nz,L_4067		;4062
	call L_4C94		;4064
L_4067:
	call L_465A		;4067
	ld a,(0e081h)		;406a
	bit 7,a			;406d
	ld a,000h		;406f
	jr z,L_4074		;4071
	inc a			;4073
L_4074:
	ld (0e0fch),a		;4074
L_4077:
	ld hl,0e005h		;4077
	bit 0,(hl)		;407a
	jr nz,L_4092		;407c
	ld (hl),001h		;407e
	ei			;4080
	call L_40A2		;4081
	call L_410C		;4084
	di			;4087
	pop hl			;4088
	pop de			;4089
	pop bc			;408a
	xor a			;408b
	ld (0e005h),a		;408c
	pop af			;408f
	ei			;4090
	ret			;4091
L_4092:
	pop hl			;4092
	pop de			;4093
	pop bc			;4094
	pop af			;4095
	ei			;4096
	ret			;4097
L_4098:
	add a,a			;4098
	pop hl			;4099
	call L_48D1		;409a
	ld e,(hl)		;409d
	inc hl			;409e
	ld d,(hl)		;409f
	ex de,hl		;40a0
	jp (hl)			;40a1
L_40A2:
	ld a,(0e000h)		;40a2
	cp 007h			;40a5
	ret c			;40a7
	ld a,(0e002h)		;40a8
	bit 6,a			;40ab
	jr z,L_40F0		;40ad
	bit 4,a			;40af
	jr nz,L_40C4		;40b1
	ld a,00eh		;40b3
	out (0a0h),a		;40b5
	in a,(0a2h)		;40b7
	cpl			;40b9
	and 03fh		;40ba
L_40BC:
	ld hl,0e009h		;40bc
	ld c,(hl)		;40bf
	ld (hl),a		;40c0
	dec hl			;40c1
	ld (hl),c		;40c2
	ret			;40c3
L_40C4:
	ld bc,057aah		;40c4
	out (c),b		;40c7
	out (c),b		;40c9
	in a,(0a9h)		;40cb
	cpl			;40cd
	rrca			;40ce
	and 020h		;40cf
	ld e,a			;40d1
	inc b			;40d2
	out (c),b		;40d3
	out (c),b		;40d5
	in a,(0a9h)		;40d7
	cpl			;40d9
	rrca			;40da
	rrca			;40db
	ld b,a			;40dc
	and 004h		;40dd
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
	jr L_40BC		;40ee
L_40F0:
	ld de,(0e0ech)		;40f0
	ld hl,0e0ebh		;40f4
	inc (hl)		;40f7
	ld a,(hl)		;40f8
	and 01fh		;40f9
	jr nz,L_4105		;40fb
	ld a,(de)		;40fd
	inc de			;40fe
	ld (0e0ech),de		;40ff
	jr L_40BC		;4103
L_4105:
	ld a,(0e009h)		;4105
	and 00fh		;4108
	jr L_40BC		;410a
L_410C:
	ld hl,0e003h		;410c
	inc (hl)		;410f
	call L_4418		;4110
	ld a,(0e000h)		;4113
	call L_4098		;4116

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_4119: Los 16 destinos del CALL de 0x4116. Cierra clavada contra su primer destino
;   0x4119..0x4139  (32 bytes)
; ----------------------------------------------------------------------
	defb 039h,041h,03ah,041h,04bh,041h,05dh,041h,068h,041h,076h,041h,07eh,041h,085h,041h	; 4119  9A:AKA]AhAvA~A.A
	defb 0d4h,041h,040h,042h,082h,042h,09bh,042h,0c1h,042h,0e6h,042h,0f7h,042h,0dbh,048h	; 4129  .A@B.B.B.B.B.B.H

; ======================================================================
; CODIGO 0x4139..0x418b  (82 bytes)
; ======================================================================


L_4139:
	ret			;4139
L_413A:
	call L_5823		;413a
	ld a,011h		;413d
	ld (0e00ah),a		;413f
	ld hl,00000h		;4142
	ld (0e00eh),hl		;4145
	jp L_43F3		;4148
L_414B:
	ld a,(0e003h)		;414b
	rra			;414e
	ret nc			;414f
	call L_4879		;4150
	ret nz			;4153
	ld hl,057cdh		;4154
	call L_4590		;4157
	jp L_43EE		;415a
L_415D:
	ld hl,0e004h		;415d
	dec (hl)		;4160
	ret nz			;4161
	call L_482C		;4162
	jp L_43F0		;4165
L_4168:
	call L_4847		;4168
	ret c			;416b
	ld hl,05782h		;416c
	call L_4590		;416f
	xor a			;4172
	jp L_43F0		;4173
L_4176:
	ld hl,0e004h		;4176
	dec (hl)		;4179
	ret nz			;417a
	jp L_43EE		;417b
L_417E:
	call L_45B3		;417e
	ret p			;4181
	jp L_43F3		;4182
L_4185:
	ld a,(0e001h)		;4185
	call L_4098		;4188

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_418B: Los 3 destinos del CALL de 0x4188. Cierra clavada contra su primer destino
;   0x418b..0x4191  (6 bytes)
; ----------------------------------------------------------------------
	defb 091h,041h,0a8h,041h,0c9h,041h	; 418b  .A.A.A

; ======================================================================
; CODIGO 0x4191..0x41da  (73 bytes)
; ======================================================================


L_4191:
	call L_444B		;4191
	ld hl,0e002h		;4194
	res 6,(hl)		;4197
	ld hl,0073ch		;4199
	ld (0e0eeh),hl		;419c
	ld hl,057e3h		;419f
	ld (0e0ech),hl		;41a2
	jp L_4240		;41a5
L_41A8:
	ld hl,05776h		;41a8
	ld de,038cbh		;41ab
	call L_4594		;41ae
	ld a,001h		;41b1
	ld (0e133h),a		;41b3
	call L_4B1B		;41b6
	ld hl,(0e0eeh)		;41b9
	dec hl			;41bc
	ld (0e0eeh),hl		;41bd
	ld a,h			;41c0
	or l			;41c1
	ret nz			;41c2
	ld (0e133h),a		;41c3
	jp L_43FC		;41c6
L_41C9:
	call L_45B3		;41c9
	ret p			;41cc
	xor a			;41cd
	ld (0e000h),a		;41ce
	jp L_43F3		;41d1
L_41D4:
	ld a,(0e001h)		;41d4
	call L_4098		;41d7

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_41DA: Los 4 destinos del CALL de 0x41BC. Cierra clavada contra su primer destino
;   0x41da..0x41e2  (8 bytes)
; ----------------------------------------------------------------------
	defb 0e2h,041h,0f3h,041h,006h,042h,036h,042h	; 41da  .A.A.B6B

; ======================================================================
; CODIGO 0x41e2..0x42fd  (283 bytes)
; ======================================================================


L_41E2:
	call L_45E8		;41e2
	call L_449E		;41e5
	call L_482C		;41e8
	ld a,092h		;41eb
	call L_7970		;41ed
	jp L_4401		;41f0
L_41F3:
	call L_4847		;41f3
	jr c,L_41F3		;41f6
	ld hl,05782h		;41f8
	call L_4590		;41fb
	ld a,006h		;41fe
	ld (0e18dh),a		;4200
	jp L_4401		;4203
L_4206:
	ld hl,0e003h		;4206
	ld a,(hl)		;4209
	and 007h		;420a
	ret nz			;420c
	ld a,(hl)		;420d
	bit 3,a			;420e
	jr nz,L_4228		;4210
	ld de,03a00h		;4212
	ld bc,00020h		;4215
	ld a,(0e002h)		;4218
	and 010h		;421b
	rlca			;421d
	rlca			;421e
	call L_48D6		;421f
	ld a,001h		;4222
	call L_44F1		;4224
	ret			;4227
L_4228:
	ld hl,05782h		;4228
	call L_4590		;422b
	ld hl,0e18dh		;422e
	dec (hl)		;4231
	ret nz			;4232
	jp L_43FC		;4233
L_4236:
	call L_45B3		;4236
	ret p			;4239
	call L_444B		;423a
	jp L_43F3		;423d
L_4240:
	ld a,(0e0e8h)		;4240
	ld hl,04aaah		;4243
	add a,a			;4246
	add a,a			;4247
	call L_48D1		;4248
	ld e,(hl)		;424b
	inc hl			;424c
	ld d,(hl)		;424d
	inc hl			;424e
	ld (0e0e6h),de		;424f
	ld e,(hl)		;4253
	inc hl			;4254
	ld d,(hl)		;4255
	ld a,(0e0e1h)		;4256
	ld hl,0e0d5h		;4259
	call L_48D1		;425c
	ld a,(hl)		;425f
	sub 010h		;4260
	jr c,L_4270		;4262
	daa			;4264
	ld c,a			;4265
	ld a,e			;4266
	sub c			;4267
	jr nc,L_426E		;4268
	daa			;426a
	dec d			;426b
	jr L_426F		;426c
L_426E:
	daa			;426e
L_426F:
	ld e,a			;426f
L_4270:
	ld (0e0e3h),de		;4270
	call L_46A3		;4274
	call L_5823		;4277
	ld a,00eh		;427a
	ld (0e000h),a		;427c
	jp L_43EE		;427f
L_4282:
	call L_45B3		;4282
	ret p			;4285
	call L_4AD2		;4286
	ld a,(0e002h)		;4289
	bit 6,a			;428c
	ld a,08ah		;428e
	call nz,L_7970		;4290
	ld a,001h		;4293
	ld (0e133h),a		;4295
	jp L_43F3		;4298
L_429B:
	ld a,(0e002h)		;429b
	bit 6,a			;429e
	jr z,L_42BC		;42a0
	call L_4B1B		;42a2
	ld hl,(0e00ch)		;42a5
	ld a,l			;42a8
	add a,h			;42a9
	ret z			;42aa
	ld a,l			;42ab
	ld hl,0e133h		;42ac
	ld (hl),000h		;42af
	or a			;42b1
	ld a,00ch		;42b2
	jr nz,L_42B8		;42b4
	ld a,00eh		;42b6
L_42B8:
	ld (0e000h),a		;42b8
	ret			;42bb
L_42BC:
	ld hl,00107h		;42bc
	jr L_42F3		;42bf
L_42C1:
	xor a			;42c1
	ld (0e00ch),a		;42c2
	ld hl,0e0b8h		;42c5
	ld de,00004h		;42c8
	ld b,004h		;42cb
L_42CD:
	ld (hl),0e0h		;42cd
	add hl,de		;42cf
	djnz L_42CD		;42d0
	call L_668C		;42d2
	ld (0e0e2h),a		;42d5
	ld a,08ch		;42d8
	call L_7970		;42da
	ld hl,057c2h		;42dd
	call L_4590		;42e0
	jp L_43EE		;42e3
L_42E6:
	ld a,(0e012h)		;42e6
	or a			;42e9
	ret nz			;42ea
	ld hl,0e002h		;42eb
	res 6,(hl)		;42ee
	ld hl,00207h		;42f0
L_42F3:
	ld (0e000h),hl		;42f3
	ret			;42f6
L_42F7:
	ld a,(0e001h)		;42f7
	call L_4098		;42fa

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_42FD: Los 8 destinos del CALL de 0x42FA. Cierra clavada contra su primer destino
;   0x42fd..0x430d  (16 bytes)
; ----------------------------------------------------------------------
	defb 00dh,043h,020h,043h,060h,043h,06eh,043h,08bh,043h,0b5h,043h,0beh,043h,0e5h,043h	; 42fd  .C C`CnC.C.C.C.C

; ======================================================================
; CODIGO 0x430d..0x4479  (364 bytes)
; ======================================================================


L_430D:
	ld hl,0e0f9h		;430d
	ld a,(hl)		;4310
	or a			;4311
	jp z,L_4401		;4312
	call L_4BE9		;4315
	ld a,(0e0f9h)		;4318
	or a			;431b
	ret nz			;431c
	jp L_4401		;431d
L_4320:
	ld hl,0e0e0h		;4320
	ld a,(hl)		;4323
	add a,001h		;4324
	daa			;4326
	ld (hl),a		;4327
	inc hl			;4328
	ld a,(hl)		;4329
	ld c,a			;432a
	inc a			;432b
	cp 00ah			;432c
	jr c,L_4334		;432e
	xor a			;4330
	ld (0e0e2h),a		;4331
L_4334:
	ld (hl),a		;4334
	ld a,c			;4335
	ld hl,0e0d5h		;4336
	call L_48D1		;4339
	ld a,(0e0e3h)		;433c
	ld (hl),a		;433f
	xor a			;4340
	ld (0e00dh),a		;4341
	ld hl,0e0e8h		;4344
	inc (hl)		;4347
	ld a,(hl)		;4348
	cp 00ah			;4349
	jr nz,L_434F		;434b
	ld (hl),000h		;434d
L_434F:
	ld a,(0e079h)		;434f
	ld h,a			;4352
	ld l,001h		;4353
	ld (0e138h),hl		;4355
	ld a,013h		;4358
	ld (0e100h),a		;435a
	jp L_4401		;435d
L_4360:
	ld c,0ffh		;4360
	call L_5485		;4362
	ret nz			;4365
	ld a,00ch		;4366
	ld (0e138h),a		;4368
	jp L_4401		;436b
L_436E:
	ld c,000h		;436e
	ld a,(0e079h)		;4370
	ld h,a			;4373
	call L_5485		;4374
	ret nz			;4377
	call L_6670		;4378
	call L_54C7		;437b
	call L_552B		;437e
	ld a,08fh		;4381
	call L_7970		;4383
	ld a,004h		;4386
	ld (0e001h),a		;4388
L_438B:
	ld a,(0e01ah)		;438b
	dec a			;438e
	ret nz			;438f
	call L_556A		;4390
	ld a,(0e0e1h)		;4393
	or a			;4396
	jr z,L_439D		;4397
	cp 005h			;4399
	jr nz,L_43AA		;439b
L_439D:
	ld a,(0e13ah)		;439d
	cp 00fh			;43a0
	jr nz,L_43AA		;43a2
	call L_54DD		;43a4
	jp L_4401		;43a7
L_43AA:
	call L_54CB		;43aa
	ld a,(0e13ah)		;43ad
	cp 010h			;43b0
	ret nz			;43b2
	jr L_4401		;43b3
L_43B5:
	ld a,(0e012h)		;43b5
	or a			;43b8
	ret nz			;43b9
	ld a,010h		;43ba
	jr L_43FE		;43bc
L_43BE:
	ld hl,0e004h		;43be
	ld a,(hl)		;43c1
	or a			;43c2
	jr z,L_43C7		;43c3
	dec (hl)		;43c5
	ret			;43c6
L_43C7:
	ld a,(0e003h)		;43c7
	and 003h		;43ca
	ret nz			;43cc
	ld hl,(0e0e3h)		;43cd
	ld a,h			;43d0
	add a,l			;43d1
	jr z,L_43FC		;43d2
	ld c,000h		;43d4
	call L_4673		;43d6
	ld de,00100h		;43d9
	call L_4616		;43dc
	ld a,001h		;43df
	call L_7970		;43e1
	ret			;43e4
L_43E5:
	call L_45B3		;43e5
	ret p			;43e8
	ld a,008h		;43e9
	ld (0e000h),a		;43eb
L_43EE:
	ld a,050h		;43ee
L_43F0:
	ld (0e004h),a		;43f0
L_43F3:
	ld hl,0e000h		;43f3
	inc (hl)		;43f6
	xor a			;43f7
	ld (0e001h),a		;43f8
	ret			;43fb
L_43FC:
	ld a,050h		;43fc
L_43FE:
	ld (0e004h),a		;43fe
L_4401:
	ld hl,0e001h		;4401
	inc (hl)		;4404
	ret			;4405
L_4406:
	call L_4590		;4406
	ld a,(0e002h)		;4409
	rlca			;440c
	and 001h		;440d
	add a,031h		;440f
	ld de,03933h		;4411
	call L_48B3		;4414
	ret			;4417
L_4418:
	ld a,(0e13bh)		;4418
	or a			;441b
	ret nz			;441c
	ld a,(0e002h)		;441d
	bit 6,a			;4420
	ret nz			;4422
	ld a,050h		;4423
	out (0aah),a		;4425
	out (0aah),a		;4427
	in a,(0a9h)		;4429
	cpl			;442b
	and 006h		;442c
	ld b,040h		;442e
	cp 002h			;4430
	jr z,L_4439		;4432
	ld b,050h		;4434
	cp 004h			;4436
	ret nz			;4438
L_4439:
	xor a			;4439
	ld (0e133h),a		;443a
	ld a,b			;443d
	ld (0e002h),a		;443e
	pop hl			;4441
	ld a,007h		;4442
	ld (0e000h),a		;4444
	jp L_43EE		;4447
L_444A:
	ret			;444a
L_444B:
	ld hl,0e043h		;444b
	ld de,0e044h		;444e
	ld bc,00100h		;4451
	ld (hl),000h		;4454
	ldir			;4456
	ld hl,04479h		;4458
	ld de,0e0e0h		;445b
	ld bc,00009h		;445e
	ldir			;4461
	ld de,00900h		;4463
	ld bc,00100h		;4466
	ld a,0f0h		;4469
	call L_44F1		;446b
	ld b,00ah		;446e
	ld hl,0e0d5h		;4470
L_4473:
	ld (hl),005h		;4473
	inc hl			;4475
	djnz L_4473		;4476
	ret			;4478

; ----------------------------------------------------------------------
; DATOS valores_iniciales: Los nueve bytes que 0x4458 copia a 0xE0E0: fase 1, indice 0, y el resto a cero salvo 0xE0E4=2 y 0xE0E6=0x17. Solo los cinco primeros se usan: 0x4240 machaca la distancia y el tiempo en cuanto empieza la fase
;   0x4479..0x4482  (9 bytes)
; ----------------------------------------------------------------------
	defb 001h,000h,000h,000h,002h,000h,017h,000h,000h	; 4479  .........

; ======================================================================
; CODIGO 0x4482..0x44d6  (84 bytes)
; ======================================================================


L_4482:
	call L_44B9		;4482
	ld a,007h		;4485
	out (0a0h),a		;4487
	ld a,0b8h		;4489
	out (0a1h),a		;448b
	call L_45FD		;448d
	call L_44A6		;4490
	ld de,00000h		;4493
	ld bc,04000h		;4496
L_4499:
	xor a			;4499
	call L_44F1		;449a
	ret			;449d
L_449E:
	ld de,03800h		;449e
	ld bc,00300h		;44a1
	jr L_4499		;44a4
L_44A6:
	xor a			;44a6
	ld bc,003a0h		;44a7
	ld d,008h		;44aa
L_44AC:
	out (c),d		;44ac
	inc d			;44ae
	out (0a1h),a		;44af
	djnz L_44AC		;44b1
	ld a,095h		;44b3
	call L_7970		;44b5
	ret			;44b8
L_44B9:
	ld hl,044d6h		;44b9
	ld de,0e038h		;44bc
	ld bc,00008h		;44bf
	ldir			;44c2
	ld hl,0e038h		;44c4
	ld b,008h		;44c7
	ld d,080h		;44c9
L_44CB:
	ld e,(hl)		;44cb
	di			;44cc
	call L_48C9		;44cd
	ei			;44d0
	inc hl			;44d1
	inc d			;44d2
	djnz L_44CB		;44d3
	ret			;44d5

; ----------------------------------------------------------------------
; DATOS registros_vdp: Los ocho registros del VDP: 02 E2 0E 7F 07 76 03 E4. Colores en 0x0000 y patrones en 0x2000, al reves de lo corriente; nombres en 0x3800, patrones de sprite en 0x1800 y atributos de sprite en 0x3B00. Sprites de 16x16 sin ampliar, y SCREEN 2
;   0x44d6..0x44de  (8 bytes)
; ----------------------------------------------------------------------
	defb 002h,0e2h,00eh,07fh,007h,076h,003h,0e1h	; 44d6  .....v..

; ======================================================================
; CODIGO 0x44de..0x4770  (658 bytes)
; ======================================================================


L_44DE:
	di			;44de
	set 6,d			;44df
	call L_48C9		;44e1
	res 6,d			;44e4
L_44E6:
	ld a,(hl)		;44e6
	out (098h),a		;44e7
	inc hl			;44e9
	dec bc			;44ea
	ld a,b			;44eb
	or c			;44ec
	jr nz,L_44E6		;44ed
	ei			;44ef
	ret			;44f0
L_44F1:
	di			;44f1
	ld h,a			;44f2
	set 6,d			;44f3
	call L_48C9		;44f5
	res 6,d			;44f8
L_44FA:
	ld a,h			;44fa
	out (098h),a		;44fb
	dec bc			;44fd
	ld a,b			;44fe
	or c			;44ff
	jr nz,L_44FA		;4500
	ei			;4502
	ret			;4503
L_4504:
	ld a,(hl)		;4504
	inc hl			;4505
	ld (0e0dfh),a		;4506
	ld d,039h		;4509
L_450B:
	ld c,(hl)		;450b
	inc hl			;450c
	xor a			;450d
	cp c			;450e
	ret z			;450f
	ld b,a			;4510
	ld e,(hl)		;4511
	inc hl			;4512
	ld a,e			;4513
	cp 020h			;4514
	jr nc,L_4519		;4516
	inc d			;4518
L_4519:
	ld a,(0e0dfh)		;4519
	push hl			;451c
	push de			;451d
	call L_44F1		;451e
	pop de			;4521
	pop hl			;4522
	jr L_450B		;4523
L_4525:
	ld a,(hl)		;4525
	or a			;4526
	ret z			;4527
	and 0f0h		;4528
	ld c,a			;452a
	ld a,(hl)		;452b
	inc hl			;452c
	and 003h		;452d
	add a,078h		;452f
	ld d,a			;4531
	ld a,c			;4532
L_4533:
	ld b,(hl)		;4533
	inc hl			;4534
	ld a,020h		;4535
	add a,c			;4537
	ld c,a			;4538
	jr nc,L_453C		;4539
	inc d			;453b
L_453C:
	ld a,c			;453c
	add a,b			;453d
	sub 0e0h		;453e
	ld e,a			;4540
	call L_48C9		;4541
L_4544:
	ld a,(hl)		;4544
	or a			;4545
	ret z			;4546
	cp 0e0h			;4547
	jr nc,L_4533		;4549
	inc hl			;454b
	out (098h),a		;454c
	jr L_4544		;454e
L_4550:
	ld e,(hl)		;4550
	inc hl			;4551
	ld d,(hl)		;4552
	inc hl			;4553
L_4554:
	ld c,000h		;4554
	jr L_455A		;4556
L_4558:
	ld c,001h		;4558
L_455A:
	call L_48C9		;455a
L_455D:
	ld a,(hl)		;455d
	inc hl			;455e
	or a			;455f
	jr z,L_457E		;4560
	bit 7,a			;4562
	jr nz,L_4572		;4564
	ld b,a			;4566
	call L_4580		;4567
L_456A:
	out (098h),a		;456a
	push hl			;456c
	pop hl			;456d
	djnz L_456A		;456e
	jr L_455D		;4570
L_4572:
	res 7,a			;4572
	ld b,a			;4574
L_4575:
	call L_4580		;4575
	out (098h),a		;4578
	djnz L_4575		;457a
	jr L_455D		;457c
L_457E:
	ei			;457e
	ret			;457f
L_4580:
	ld a,(hl)		;4580
	inc hl			;4581
	bit 0,c			;4582
	ret z			;4584
	push bc			;4585
	ld b,008h		;4586
	ld c,a			;4588
L_4589:
	rr c			;4589
	rla			;458b
	djnz L_4589		;458c
	pop bc			;458e
	ret			;458f
L_4590:
	ld e,(hl)		;4590
	inc hl			;4591
	ld d,(hl)		;4592
	inc hl			;4593
L_4594:
	ld a,(hl)		;4594
	inc hl			;4595
	ld b,a			;4596
	inc b			;4597
	ret z			;4598
	inc b			;4599
	jr z,L_4590		;459a
	call L_48B3		;459c
	inc de			;459f
	jr L_4594		;45a0
L_45A2:
	push hl			;45a2
	ld b,004h		;45a3
L_45A5:
	ld a,(hl)		;45a5
	ld (de),a		;45a6
	inc hl			;45a7
	inc de			;45a8
	djnz L_45A5		;45a9
	dec c			;45ab
	jr z,L_45B1		;45ac
	pop hl			;45ae
	jr L_45A2		;45af
L_45B1:
	pop bc			;45b1
	ret			;45b2
L_45B3:
	call L_45E8		;45b3
	ld d,038h		;45b6
	ld hl,0e004h		;45b8
	ld b,018h		;45bb
	bit 6,(hl)		;45bd
	jr nz,L_45C9		;45bf
	ld a,01fh		;45c1
	sub (hl)		;45c3
	ld e,a			;45c4
	set 6,(hl)		;45c5
	jr L_45CE		;45c7
L_45C9:
	res 6,(hl)		;45c9
	dec (hl)		;45cb
	ret m			;45cc
	ld e,(hl)		;45cd
L_45CE:
	ld a,(0e000h)		;45ce
	cp 00ah			;45d1
	jr c,L_45DB		;45d3
	ld a,040h		;45d5
	add a,e			;45d7
	ld e,a			;45d8
	dec b			;45d9
	dec b			;45da
L_45DB:
	xor a			;45db
	call L_48B3		;45dc
	ld a,020h		;45df
	call L_48D6		;45e1
	djnz L_45DB		;45e4
	xor a			;45e6
	ret			;45e7
L_45E8:
	ld hl,0e050h		;45e8
	push hl			;45eb
	ld b,080h		;45ec
L_45EE:
	ld (hl),000h		;45ee
	inc hl			;45f0
	djnz L_45EE		;45f1
	ld de,03b00h		;45f3
	pop hl			;45f6
	ld bc,00080h		;45f7
	jp L_44DE		;45fa
L_45FD:
	ld a,00fh		;45fd
	out (0a0h),a		;45ff
	ld a,08fh		;4601
	out (0a1h),a		;4603
	ret			;4605
L_4606:
	ld a,(0e009h)		;4606
	ld b,a			;4609
	ld a,(0e008h)		;460a
	and 030h		;460d
	cpl			;460f
	ld c,a			;4610
	ld a,b			;4611
	and 030h		;4612
	and c			;4614
	ret			;4615
L_4616:
	ld a,(0e002h)		;4616
	add a,a			;4619
	ret p			;461a
	ld hl,0e043h		;461b
	ld a,(hl)		;461e
	add a,e			;461f
	daa			;4620
	ld (hl),a		;4621
	ld e,a			;4622
	inc hl			;4623
	ld a,(hl)		;4624
	adc a,d			;4625
	daa			;4626
	ld (hl),a		;4627
	ld d,a			;4628
	inc hl			;4629
	jr nc,L_4640		;462a
	ld a,(hl)		;462c
	adc a,000h		;462d
	daa			;462f
	ld (hl),a		;4630
	jr nc,L_4640		;4631
	ld bc,09999h		;4633
	ld (0e040h),bc		;4636
	ld (0e041h),bc		;463a
	jr L_46B2		;463e
L_4640:
	ld a,(0e042h)		;4640
	ld b,(hl)		;4643
	sub (hl)		;4644
	jr c,L_4650		;4645
	jr nz,L_46BB		;4647
	ld hl,(0e040h)		;4649
	sbc hl,de		;464c
	jr nc,L_46BB		;464e
L_4650:
	ld (0e040h),de		;4650
	ld a,b			;4654
	ld (0e042h),a		;4655
	jr L_46B2		;4658
L_465A:
	ld a,(0e133h)		;465a
	or a			;465d
	ret z			;465e
	ld hl,(0e0e3h)		;465f
	ld a,h			;4662
	add a,l			;4663
	jr nz,L_466B		;4664
	inc a			;4666
	ld (0e00ch),a		;4667
	ret			;466a
L_466B:
	ld a,(0e003h)		;466b
	and 03fh		;466e
	ret nz			;4670
	ld c,001h		;4671
L_4673:
	ld hl,0e0e3h		;4673
	ld a,(hl)		;4676
	sub 001h		;4677
	daa			;4679
	ld (hl),a		;467a
	inc hl			;467b
	ld a,(hl)		;467c
	jr nc,L_4683		;467d
	sub 001h		;467f
	daa			;4681
	ld (hl),a		;4682
L_4683:
	dec hl			;4683
	or a			;4684
	jr nz,L_4698		;4685
	ld a,(hl)		;4687
	cp 011h			;4688
	jr nc,L_4698		;468a
	dec c			;468c
	jr nz,L_4698		;468d
	push af			;468f
	push hl			;4690
	ld a,009h		;4691
	call L_7970		;4693
	pop hl			;4696
	pop af			;4697
L_4698:
	ld b,002h		;4698
	ld de,03827h		;469a
	ld hl,0e0e4h		;469d
	jp L_4711		;46a0
L_46A3:
	ld hl,05745h		;46a3
	call L_4590		;46a6
	call L_4698		;46a9
	call L_46FF		;46ac
	call L_4709		;46af
L_46B2:
	ld hl,0e042h		;46b2
	ld de,0380fh		;46b5
	call L_46C1		;46b8
L_46BB:
	ld de,03805h		;46bb
	ld hl,0e045h		;46be
L_46C1:
	ld b,003h		;46c1
	jr L_4711		;46c3
L_46C5:
	ld hl,0e0e9h		;46c5
	dec (hl)		;46c8
	ret nz			;46c9
	ld a,(0e100h)		;46ca
	srl a			;46cd
	dec a			;46cf
	ld (hl),a		;46d0
	ld hl,0e0e6h		;46d1
	ld a,(hl)		;46d4
	dec hl			;46d5
	or (hl)			;46d6
	jr nz,L_46DE		;46d7
	inc a			;46d9
	ld (0e00dh),a		;46da
	ret			;46dd
L_46DE:
	ld a,(hl)		;46de
	sub 001h		;46df
	daa			;46e1
	ld (hl),a		;46e2
	ld c,a			;46e3
	inc hl			;46e4
	jr nc,L_46EC		;46e5
	ld a,(hl)		;46e7
	sub 001h		;46e8
	daa			;46ea
	ld (hl),a		;46eb
L_46EC:
	ld a,c			;46ec
	or a			;46ed
	jr nz,L_46FC		;46ee
	or (hl)			;46f0
	jr z,L_46FC		;46f1
	ld a,(hl)		;46f3
	and 003h		;46f4
	jr nz,L_46FC		;46f6
	inc a			;46f8
	ld (0e107h),a		;46f9
L_46FC:
	call L_52A1		;46fc
L_46FF:
	ld b,002h		;46ff
	ld de,0382fh		;4701
	ld hl,0e0e6h		;4704
	jr L_4711		;4707
L_4709:
	ld de,0381ch		;4709
	ld hl,0e0e0h		;470c
	ld b,001h		;470f
L_4711:
	ld a,(hl)		;4711
	push af			;4712
	and 00fh		;4713
	or 010h			;4715
	ld c,a			;4717
	pop af			;4718
	and 0f0h		;4719
	rra			;471b
	rra			;471c
	rra			;471d
	rra			;471e
	or 010h			;471f
	call L_48B3		;4721
	inc de			;4724
	ld a,c			;4725
	call L_48B3		;4726
	dec hl			;4729
	inc de			;472a
	djnz L_4711		;472b
	ret			;472d
L_472E:
	ld a,(0e0e0h)		;472e
	and 00fh		;4731
	ld hl,04770h		;4733
	add a,a			;4736
	call L_48D1		;4737
	ld a,(0e0e6h)		;473a
	and 010h		;473d
	jr z,L_4742		;473f
	inc hl			;4741
L_4742:
	ld a,(hl)		;4742
	ld (0e18ah),a		;4743
	ld a,(0e0e0h)		;4746
	and 00fh		;4749
	ld hl,047ach		;474b
	add a,a			;474e
	call L_48D1		;474f
	ld e,(hl)		;4752
	inc hl			;4753
	ld d,(hl)		;4754
	ex de,hl		;4755
	ld a,(0e0e6h)		;4756
	and 0fch		;4759
	rrca			;475b
	rrca			;475c
	res 3,a			;475d
	cp 004h			;475f
	jr c,L_4764		;4761
	dec a			;4763
L_4764:
	add a,a			;4764
	call L_48D1		;4765
	ld e,(hl)		;4768
	inc hl			;4769
	ld d,(hl)		;476a
	ex de,hl		;476b
	ld (0e18bh),hl		;476c
	ret			;476f

; ----------------------------------------------------------------------
; DATOS decorado_por_fase: Dos bytes por fase, diez fases: 0x4733 los indexa y el bit 4 de la distancia elige cual de los dos. Acaba justo donde empiezan las listas
;   0x4770..0x4784  (20 bytes)
; DATOS listas_de_decorado: Cinco listas de ocho bytes. Es a donde apuntan los veinte punteros de 0x47C0, y acaban clavadas donde empieza la tabla de fases
;   0x4784..0x47ac  (40 bytes)
; DATOS decorado_puntero_por_fase: Diez punteros, uno por fase, que apuntan DENTRO de la tabla de al lado con ventanas que se solapan. 0x474B lo indexa
;   0x47ac..0x47c0  (20 bytes)
; DATOS decorado_punteros: Veinte punteros a las cinco listas. Cierra clavado en 0x47E8, donde vuelve a haber codigo
;   0x47c0..0x47e8  (40 bytes)
; ----------------------------------------------------------------------
	defb 080h,000h,0a0h,0a0h,050h,050h,0e0h,0e0h,050h,050h,000h,020h,0e0h,0e0h,020h,020h	; 4770  ....PP..PP. ..  
	defb 000h,000h,0ffh,0ffh,001h,005h,0ffh,000h,012h,005h,0ffh,000h,011h,001h,000h,012h	; 4780  ................
	defb 000h,001h,012h,000h,000h,0ffh,003h,011h,001h,005h,0ffh,003h,000h,0ffh,003h,003h	; 4790  ................
	defb 000h,011h,001h,012h,005h,0ffh,005h,0ffh,003h,012h,005h,0ffh,0ceh,047h,0dah,047h	; 47a0  .............G.G
	defb 0c0h,047h,0e0h,047h,0ceh,047h,0d6h,047h,0e0h,047h,0d8h,047h,0dah,047h,0e2h,047h	; 47b0  .G.G.G.G.G.G.G.G
	defb 09ch,047h,084h,047h,09ch,047h,084h,047h,0a4h,047h,094h,047h,084h,047h,094h,047h	; 47c0  .G.G.G.G.G.G.G.G
	defb 08ch,047h,09ch,047h,08ch,047h,084h,047h,09ch,047h,08ch,047h,094h,047h,08ch,047h	; 47d0  .G.G.G.G.G.G.G.G
	defb 0a4h,047h,08ch,047h,0a4h,047h,08ch,047h	; 47e0  .G.G.G.G

; ======================================================================
; CODIGO 0x47e8..0x4822  (58 bytes)
; ======================================================================


L_47E8:
	ld a,(0e18eh)		;47e8
	rra			;47eb
	ret nc			;47ec
	ld hl,0e18fh		;47ed
	dec (hl)		;47f0
	jr nz,L_47F7		;47f1
	xor a			;47f3
	ld (0e18eh),a		;47f4
L_47F7:
	ld c,003h		;47f7
	ret			;47f9
L_47FA:
	ld a,(0e0e0h)		;47fa
	and 00fh		;47fd
	ld hl,04822h		;47ff
	call L_48D1		;4802
	ld de,(0e0e5h)		;4805
	ld a,d			;4809
	cp 004h			;480a
	ret c			;480c
	ld a,e			;480d
	or a			;480e
	ret nz			;480f
	ld a,(0e0e0h)		;4810
	add a,d			;4813
	and 003h		;4814
	cp 002h			;4816
	ret nz			;4818
	inc a			;4819
	ld (0e18eh),a		;481a
	ld a,(hl)		;481d
	ld (0e18fh),a		;481e
	ret			;4821

; ----------------------------------------------------------------------
; DATOS duracion_sorpresa: Diez bytes, uno por fase: cuanto dura lo que enciende 0x47FA. La fase 1 lleva 7 y las demas entre 2 y 6
;   0x4822..0x482c  (10 bytes)
; ----------------------------------------------------------------------
	defb 007h,002h,002h,003h,003h,004h,004h,005h,006h,006h	; 4822  ..........

; ======================================================================
; CODIGO 0x482c..0x48e1  (181 bytes)
; ======================================================================


L_482C:
	call L_5823		;482c
	ld de,01080h		;482f
	ld bc,00180h		;4832
	ld a,070h		;4835
	call L_44F1		;4837
	xor a			;483a
	ld (0e00ah),a		;483b
	ld de,03966h		;483e
	ld bc,00013h		;4841
	jp L_44F1		;4844
L_4847:
	ld hl,0e00ah		;4847
	ld a,(hl)		;484a
	inc (hl)		;484b
	cp 017h			;484c
	jr nc,L_486C		;484e
	ld de,03885h		;4850
	ld c,a			;4853
	add a,e			;4854
	ld e,a			;4855
	ld a,c			;4856
	add a,a			;4857
	add a,0b2h		;4858
	ld c,a			;485a
	ld b,003h		;485b
	xor a			;485d
L_485E:
	call L_48B3		;485e
	ld a,020h		;4861
	call L_48D6		;4863
	ld a,c			;4866
	inc c			;4867
	djnz L_485E		;4868
	scf			;486a
	ret			;486b
L_486C:
	push af			;486c
	ld hl,05774h		;486d
	call L_4590		;4870
	pop af			;4873
	cp 034h			;4874
	ret c			;4876
	or a			;4877
	ret			;4878
L_4879:
	ld hl,(0e00eh)		;4879
	ld de,00020h		;487c
	add hl,de		;487f
	ld (0e00eh),hl		;4880
	ex de,hl		;4883
	or a			;4884
	ld hl,03aaah		;4885
	sbc hl,de		;4888
	ex de,hl		;488a
	ld a,044h		;488b
	ld bc,00303h		;488d
L_4890:
	push de			;4890
L_4891:
	call L_48B3		;4891
	inc de			;4894
	inc a			;4895
	djnz L_4891		;4896
	pop de			;4898
	ld hl,00020h		;4899
	add hl,de		;489c
	ex de,hl		;489d
	ld h,a			;489e
	ld a,00eh		;489f
	sub c			;48a1
	ld b,a			;48a2
	ld a,h			;48a3
	dec c			;48a4
	jr nz,L_4890		;48a5
	ld bc,0000ch		;48a7
	xor a			;48aa
	call L_44F1		;48ab
	ld hl,0e00ah		;48ae
	dec (hl)		;48b1
	ret			;48b2
L_48B3:
	push af			;48b3
	set 6,d			;48b4
	call L_48C9		;48b6
	res 6,d			;48b9
	pop af			;48bb
	out (098h),a		;48bc
	ei			;48be
	ret			;48bf
L_48C0:
	call L_48C9		;48c0
	nop			;48c3
	nop			;48c4
	in a,(098h)		;48c5
	ei			;48c7
	ret			;48c8
L_48C9:
	di			;48c9
	ld a,e			;48ca
	out (099h),a		;48cb
	ld a,d			;48cd
	out (099h),a		;48ce
	ret			;48d0
L_48D1:
	add a,l			;48d1
	ld l,a			;48d2
	ret nc			;48d3
	inc h			;48d4
	ret			;48d5
L_48D6:
	add a,e			;48d6
	ld e,a			;48d7
	ret nc			;48d8
	inc d			;48d9
	ret			;48da
L_48DB:
	ld a,(0e001h)		;48db
	call L_4098		;48de

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_48E1: Los 7 destinos del CALL de 0x48DE. Cierra clavada contra su primer destino
;   0x48e1..0x48ef  (14 bytes)
; ----------------------------------------------------------------------
	defb 0efh,048h,009h,049h,010h,049h,047h,049h,061h,049h,06eh,049h,0c5h,049h	; 48e1  .H.I.IGIaInI.I

; ======================================================================
; CODIGO 0x48ef..0x49d2  (227 bytes)
; ======================================================================


L_48EF:
	ld hl,049d2h		;48ef
	ld (0e0f2h),hl		;48f2
	ld hl,03884h		;48f5
	ld (0e0f0h),hl		;48f8
	ld de,01080h		;48fb
	ld bc,00180h		;48fe
	ld a,0f4h		;4901
	call L_44F1		;4903
	jp L_4401		;4906
L_4909:
	ld de,03883h		;4909
	ld a,092h		;490c
	jr L_494C		;490e
L_4910:
	ld a,(0e003h)		;4910
	rra			;4913
	ret c			;4914
	ld hl,(0e0f0h)		;4915
	ld a,020h		;4918
	call L_48D1		;491a
	ld (0e0f0h),hl		;491d
	ex de,hl		;4920
	push de			;4921
	ld a,00ah		;4922
	ld bc,00018h		;4924
	call L_44F1		;4927
	pop de			;492a
	inc de			;492b
	ld a,004h		;492c
	ld c,016h		;492e
	call L_44F1		;4930
	ld hl,(0e0f2h)		;4933
	ld a,(hl)		;4936
	inc hl			;4937
	or a			;4938
	jp z,L_4401		;4939
	ld e,a			;493c
	inc a			;493d
	jr z,L_4943		;493e
	call L_4594		;4940
L_4943:
	ld (0e0f2h),hl		;4943
	ret			;4946
L_4947:
	ld de,03aa3h		;4947
	ld a,091h		;494a
L_494C:
	call L_48B3		;494c
	inc de			;494f
	ld bc,00018h		;4950
	add a,004h		;4953
	push af			;4955
	call L_44F1		;4956
	pop af			;4959
	sub 002h		;495a
	out (098h),a		;495c
	jp L_4401		;495e
L_4961:
	ld hl,03913h		;4961
	ld (0e0f4h),hl		;4964
	xor a			;4967
	ld (0e0f6h),a		;4968
	jp L_4401		;496b
L_496E:
	ld a,(0e003h)		;496e
	rra			;4971
	ret c			;4972
	ld hl,0e0f6h		;4973
	ld a,(hl)		;4976
	ld de,04a81h		;4977
	call L_48D6		;497a
	ld a,(de)		;497d
	ld (0e0d0h),a		;497e
	cp 020h			;4981
	jp z,L_4401		;4983
	inc (hl)		;4986
	ld c,097h		;4987
	ld a,(0e0e7h)		;4989
	cp (hl)			;498c
	jr c,L_4991		;498d
	ld c,0a4h		;498f
L_4991:
	ld hl,0e0d0h		;4991
	xor a			;4994
	rrd			;4995
	ld b,a			;4997
	ld a,(hl)		;4998
	ld hl,L_49B2		;4999
	call L_48D1		;499c
	ld de,(0e0f4h)		;499f
	call L_49B1		;49a3
	ld (0e0f4h),de		;49a6
	ld a,b			;49aa
	add a,c			;49ab
	call L_48B3		;49ac
	scf			;49af
	ret			;49b0
L_49B1:
	jp (hl)			;49b1
L_49B2:
	ld a,0e0h		;49b2
	jr L_49C0		;49b4
L_49B6:
	ld a,001h		;49b6
	jr L_49C1		;49b8
L_49BA:
	ld a,020h		;49ba
	jr L_49C1		;49bc
L_49BE:
	ld a,0ffh		;49be
L_49C0:
	dec d			;49c0
L_49C1:
	call L_48D6		;49c1
	ret			;49c4
L_49C5:
	ld hl,0e004h		;49c5
	dec (hl)		;49c8
	ret nz			;49c9
	ld a,009h		;49ca
	ld (0e000h),a		;49cc
	jp L_43EE		;49cf

; ----------------------------------------------------------------------
; DATOS mapa_dibujo: Las filas del mapa, una detras de otra: un byte de columna y detras las casillas, o un 0xFF si la fila va vacia. El 0x00 de 0x4A80 lo cierra. Son dieciseis filas, y la ultima es el rotulo ANTARCTICA (c)KONAMI
;   0x49d2..0x4a81  (175 bytes)
; DATOS mapa_recorrido: Los cuarenta pasos del camino: nibble alto la direccion (0 arriba, 4 derecha, 8 abajo, C izquierda) y nibble bajo la casilla que se dibuja. El 0x20 de 0x4AA9 lo cierra
;   0x4a81..0x4aaa  (41 bytes)
; DATOS tabla_de_fases: Las DIEZ fases, cuatro bytes cada una: centenas de metros, casilla del mapa donde empieza, y el tiempo en BCD. Cierra clavada en 0x4AD2, donde vuelve a haber codigo. Salen 1500 m/100 s, 1700/120, 1100/80, 1200/80, 1200/80, 500/40, 2600/165, 1200/90, 1500/100 y 1200/90
;   0x4aaa..0x4ad2  (40 bytes)
; ----------------------------------------------------------------------
	defb 0ffh,0ceh,05eh,05fh,060h,061h,0ffh,0edh,062h,00fh,00fh,00fh,00fh,00fh,063h,064h	; 49d2  ..^_`a..b.....cd
	defb 065h,0ffh,008h,066h,004h,004h,004h,004h,067h,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 49e2  e..f....g.......
	defb 068h,0ffh,028h,069h,06ah,064h,088h,089h,07eh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 49f2  h.(ijd..~.......
	defb 06bh,0ffh,049h,06ch,06dh,07fh,007h,080h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,061h	; 4a02  k.Ilm..........a
	defb 0ffh,06ah,067h,081h,082h,00fh,00fh,00fh,08dh,08eh,08fh,090h,00fh,00fh,06eh,0ffh	; 4a12  .jg...........n.
	defb 08ah,06fh,00fh,00fh,00fh,00fh,00fh,08ch,00fh,00fh,00fh,00fh,00fh,070h,0ffh,0abh	; 4a22  .o...........p..
	defb 071h,00fh,00fh,083h,084h,00fh,00fh,00fh,00fh,00fh,00fh,072h,0ffh,0cbh,073h,00fh	; 4a32  q..........r..s.
	defb 00fh,085h,007h,086h,00fh,00fh,00fh,00fh,00fh,074h,0ffh,0ebh,069h,075h,076h,08ah	; 4a42  .........t..iuv.
	defb 08bh,087h,00fh,00fh,00fh,00fh,077h,0ffh,010h,078h,00fh,00fh,00fh,00fh,079h,0ffh	; 4a52  ......w..x....y.
	defb 030h,07ah,075h,07bh,07ch,07dh,0ffh,0ffh,067h,021h,02eh,034h,021h,032h,023h,034h	; 4a62  0zu{|}..g!.4!2#4
	defb 029h,023h,021h,004h,004h,004h,01ah,01bh,01ch,01dh,01eh,01fh,0ffh,0ffh,000h,042h	; 4a72  )#!............B
	defb 082h,082h,085h,04bh,082h,082h,08bh,0c4h,082h,08bh,0c4h,0c4h,0c0h,00bh,002h,002h	; 4a82  ...K............
	defb 0c5h,00ch,0c5h,0c5h,0c6h,086h,087h,0c5h,002h,00ch,00ah,009h,048h,043h,00ch,00ch	; 4a92  ............HC..
	defb 001h,045h,045h,045h,042h,085h,047h,020h,012h,000h,090h,000h,015h,005h,000h,001h	; 4aa2  .EEEB.G ........
	defb 012h,008h,090h,000h,015h,00bh,000h,001h,017h,00eh,020h,001h,011h,013h,080h,000h	; 4ab2  .......... .....
	defb 012h,017h,080h,000h,012h,01bh,080h,000h,005h,020h,040h,000h,026h,021h,065h,001h	; 4ac2  ......... @.&!e.

; ======================================================================
; CODIGO 0x4ad2..0x4b55  (131 bytes)
; ======================================================================


L_4AD2:
	ld hl,0e0f0h		;4ad2
	ld de,0e0f1h		;4ad5
	ld bc,00130h		;4ad8
	ld (hl),000h		;4adb
	ldir			;4add
	ld a,010h		;4adf
	ld h,a			;4ae1
	ld l,a			;4ae2
	ld (0e100h),hl		;4ae3
	ld (0e110h),a		;4ae6
	ld a,008h		;4ae9
	ld (0e149h),a		;4aeb
	ld a,005h		;4aee
	ld (0e0e9h),a		;4af0
	ld hl,03030h		;4af3
	ld a,(0e0e0h)		;4af6
	rra			;4af9
	jr nc,L_4AFF		;4afa
	ld hl,03434h		;4afc
L_4AFF:
	ld (0e10eh),hl		;4aff
	ld a,001h		;4b02
	ld (0e13bh),a		;4b04
	call L_5D9B		;4b07
	call L_6238		;4b0a
	call L_66FF		;4b0d
	call L_666B		;4b10
	call L_5015		;4b13
	xor a			;4b16
	ld (0e13bh),a		;4b17
	ret			;4b1a
L_4B1B:
	call L_7711		;4b1b
	call L_7612		;4b1e
	ld a,(0e140h)		;4b21
	or a			;4b24
	jp nz,L_4F65		;4b25
	ld a,(0e142h)		;4b28
	or a			;4b2b
	jp nz,L_4E3A		;4b2c
	call L_7687		;4b2f
	call L_4B7D		;4b32
	call L_5362		;4b35
	call L_4DA3		;4b38
	call L_4DE0		;4b3b
	ld a,(0e140h)		;4b3e
	or a			;4b41
	ret nz			;4b42
	call L_514B		;4b43
	call L_74C2		;4b46
	call L_46C5		;4b49
	call L_472E		;4b4c
	call L_51D3		;4b4f
	jp L_774C		;4b52

; ----------------------------------------------------------------------
; DATOS poses_del_pinguino: Diez poses de cuatro bytes: los cuatro patrones de sprite que forman el pinguino en cada postura. 0x4BA6 las reparte de cuatro en cuatro por los atributos
;   0x4b55..0x4b7d  (40 bytes)
; ----------------------------------------------------------------------
	defb 000h,004h,008h,00ch,010h,014h,018h,01ch,020h,024h,028h,02ch,000h,004h,030h,034h	; 4b55  ........ $(,..04
	defb 038h,03ch,040h,044h,060h,064h,068h,06ch,020h,048h,04ch,050h,054h,014h,058h,05ch	; 4b65  8<@D`dhl HLPT.X\
	defb 010h,0a8h,018h,0ach,0b0h,024h,0b4h,02ch	; 4b75  .....$.,

; ======================================================================
; CODIGO 0x4b7d..0x4c51  (212 bytes)
; ======================================================================


L_4B7D:
	ld hl,0e0f9h		;4b7d
	ld a,(hl)		;4b80
	or a			;4b81
	jp nz,L_4BE9		;4b82
	call L_4606		;4b85
	jp nz,L_4BD5		;4b88
	ld a,b			;4b8b
	ld de,(0e078h)		;4b8c
	call L_4C5D		;4b90
L_4B93:
	ex de,hl		;4b93
L_4B94:
	call L_4BBD		;4b94
L_4B97:
	ld hl,0e078h		;4b97
	ld de,03b28h		;4b9a
	ld bc,00010h		;4b9d
	call L_44DE		;4ba0
	jp L_4CBA		;4ba3
L_4BA6:
	exx			;4ba6
	ld hl,04b55h		;4ba7
	call L_48D1		;4baa
	ld de,0e07ah		;4bad
	ld b,004h		;4bb0
L_4BB2:
	ld a,(hl)		;4bb2
	ld (de),a		;4bb3
	ld a,004h		;4bb4
	add a,e			;4bb6
	ld e,a			;4bb7
	inc hl			;4bb8
	djnz L_4BB2		;4bb9
	exx			;4bbb
	ret			;4bbc
L_4BBD:
	ld d,h			;4bbd
	ld (0e078h),hl		;4bbe
	ld a,h			;4bc1
	add a,010h		;4bc2
	ld h,a			;4bc4
	ld (0e07ch),hl		;4bc5
	ld a,l			;4bc8
	add a,010h		;4bc9
	ld l,a			;4bcb
	ld e,a			;4bcc
	ld (0e080h),de		;4bcd
	ld (0e084h),hl		;4bd1
	ret			;4bd4
L_4BD5:
	ld a,002h		;4bd5
	call L_7970		;4bd7
	ld a,b			;4bda
	and 00ch		;4bdb
	jr z,L_4BE4		;4bdd
	ld a,(0e0fah)		;4bdf
	and 003h		;4be2
L_4BE4:
	ld (0e0fbh),a		;4be4
	jr L_4BEF		;4be7
L_4BE9:
	ld a,(0e003h)		;4be9
	and 003h		;4bec
	ret nz			;4bee
L_4BEF:
	ld a,(hl)		;4bef
	inc (hl)		;4bf0
	cp 00bh			;4bf1
	jr nz,L_4BF7		;4bf3
	ld (hl),000h		;4bf5
L_4BF7:
	push af			;4bf7
	ld c,000h		;4bf8
	cp 00bh			;4bfa
	jr z,L_4C05		;4bfc
	ld c,010h		;4bfe
	rra			;4c00
	jr c,L_4C05		;4c01
	ld c,00ch		;4c03
L_4C05:
	ld a,c			;4c05
	call L_4BA6		;4c06
	pop af			;4c09
	ld hl,04c51h		;4c0a
	call L_48D1		;4c0d
	ld a,(hl)		;4c10
	ld de,(0e078h)		;4c11
	add a,e			;4c15
	ld e,a			;4c16
	ld hl,0e0fbh		;4c17
	ld a,(hl)		;4c1a
	dec a			;4c1b
	jr z,L_4C41		;4c1c
	dec a			;4c1e
	jr z,L_4C49		;4c1f
L_4C21:
	ex de,hl		;4c21
	call L_4B94		;4c22
	ld a,(0e0f9h)		;4c25
	or a			;4c28
	ret nz			;4c29
	call L_4D1A		;4c2a
	ld a,(0e140h)		;4c2d
	ld hl,0e142h		;4c30
	add a,(hl)		;4c33
	ret nz			;4c34
	ld hl,0e132h		;4c35
	cp (hl)			;4c38
	ret z			;4c39
	ld (hl),a		;4c3a
	ld de,00030h		;4c3b
	jp L_4616		;4c3e
L_4C41:
	call L_4C6D		;4c41
	call L_4C6D		;4c44
	jr L_4C21		;4c47
L_4C49:
	call L_4C8A		;4c49
	call L_4C8A		;4c4c
	jr L_4C21		;4c4f

; ----------------------------------------------------------------------
; DATOS curva_del_salto: Doce correcciones con signo para la Y del pinguino: -4,-3,-3,-2,-1,-1,+1,+1,+2,+3,+3,+4. Es el arco del salto, y tambien el balanceo de andar
;   0x4c51..0x4c5d  (12 bytes)
; ----------------------------------------------------------------------
	defb 0fch,0fdh,0fdh,0feh,0ffh,0ffh,001h,001h,002h,003h,003h,004h	; 4c51  ............

; ======================================================================
; CODIGO 0x4c5d..0x4cfb  (158 bytes)
; ======================================================================


L_4C5D:
	and 00ch		;4c5d
	ret z			;4c5f
	ld hl,0e0fah		;4c60
	cp 00ch			;4c63
	jr z,L_4C77		;4c65
	res 7,(hl)		;4c67
	cp 004h			;4c69
	jr nz,L_4C8A		;4c6b
L_4C6D:
	ld a,d			;4c6d
	cp 014h			;4c6e
	ret c			;4c70
	dec d			;4c71
	set 0,(hl)		;4c72
	res 1,(hl)		;4c74
	ret			;4c76
L_4C77:
	ld a,(hl)		;4c77
	or a			;4c78
	ret z			;4c79
	bit 7,a			;4c7a
	jr z,L_4C84		;4c7c
	bit 0,a			;4c7e
	jr nz,L_4C6D		;4c80
	jr L_4C8A		;4c82
L_4C84:
	set 7,(hl)		;4c84
	bit 1,a			;4c86
	jr nz,L_4C6D		;4c88
L_4C8A:
	ld a,d			;4c8a
	cp 0cch			;4c8b
	ret nc			;4c8d
	set 1,(hl)		;4c8e
	res 0,(hl)		;4c90
	inc d			;4c92
	ret			;4c93
L_4C94:
	ld hl,0e0f9h		;4c94
	ld a,(0e130h)		;4c97
	or (hl)			;4c9a
	ret nz			;4c9b
	ld a,(0e003h)		;4c9c
	and 007h		;4c9f
	ret nz			;4ca1
L_4CA2:
	ld hl,0e0f8h		;4ca2
	inc (hl)		;4ca5
	ld a,(hl)		;4ca6
	ld c,000h		;4ca7
	rra			;4ca9
	jr nc,L_4CB3		;4caa
	ld c,004h		;4cac
	rra			;4cae
	jr nc,L_4CB3		;4caf
	ld c,008h		;4cb1
L_4CB3:
	ld a,c			;4cb3
	call L_4BA6		;4cb4
	jp L_4B97		;4cb7
L_4CBA:
	ld hl,(0e078h)		;4cba
	ld a,l			;4cbd
	add a,01eh		;4cbe
	ld l,a			;4cc0
	ld c,a			;4cc1
	ld a,h			;4cc2
	add a,010h		;4cc3
	ld b,a			;4cc5
	ld de,04cfah		;4cc6
	ld a,(0e0f9h)		;4cc9
	or a			;4ccc
	jr nz,L_4CD8		;4ccd
	ld de,04d04h		;4ccf
	ld a,(0e143h)		;4cd2
	or a			;4cd5
	jr z,L_4CE8		;4cd6
L_4CD8:
	ex de,hl		;4cd8
	call L_48D1		;4cd9
	ld l,(hl)		;4cdc
	ld a,d			;4cdd
	add a,l			;4cde
	ld d,a			;4cdf
	ld a,b			;4ce0
	sub l			;4ce1
	ld b,a			;4ce2
	ld e,0aeh		;4ce3
	ld c,0aeh		;4ce5
	ex de,hl		;4ce7
L_4CE8:
	ld (0e0a0h),hl		;4ce8
	ld (0e0a4h),bc		;4ceb
L_4CEF:
	ld hl,0e0a0h		;4cef
	ld de,03b50h		;4cf2
	ld bc,00008h		;4cf5
	jp L_44DE		;4cf8

; ----------------------------------------------------------------------
; DATOS arco_del_salto: Diez alturas, indexadas de 1 a 10 desde 0x4CFA: lo que se separa la sombra en cada paso del salto
;   0x4cfb..0x4d05  (10 bytes)
; DATOS arco_de_la_caida: Veintiuna alturas, indexadas de 1 a 21 desde 0x4D04 con 0xE143, que es el contador de la caida. Cierra clavada en 0x4D1A
;   0x4d05..0x4d1a  (21 bytes)
; ----------------------------------------------------------------------
	defb 001h,002h,002h,003h,003h,003h,003h,003h,002h,002h,001h,001h,002h,002h,003h,002h	; 4cfb  ................
	defb 002h,001h,000h,001h,002h,002h,002h,001h,000h,001h,002h,002h,002h,001h,000h	; 4d0b  ...............

; ======================================================================
; CODIGO 0x4d1a..0x4d99  (127 bytes)
; ======================================================================


L_4D1A:
	ld a,(0e0f9h)		;4d1a
	or a			;4d1d
	ret nz			;4d1e
	ld b,004h		;4d1f
	ld a,(0e0e0h)		;4d21
	cp 005h			;4d24
	jr c,L_4D29		;4d26
	inc b			;4d28
L_4D29:
	ld hl,0e112h		;4d29
L_4D2C:
	ld a,(hl)		;4d2c
	cp 00dh			;4d2d
	ld a,005h		;4d2f
	jr nz,L_4D60		;4d31
	inc hl			;4d33
	ld c,(hl)		;4d34
	inc hl			;4d35
	inc hl			;4d36
	inc hl			;4d37
	ld e,(hl)		;4d38
	inc hl			;4d39
	ld d,(hl)		;4d3a
	ex de,hl		;4d3b
	dec a			;4d3c
	cp c			;4d3d
	ld a,(0e079h)		;4d3e
	jr nc,L_4D4B		;4d41
	sub (hl)		;4d43
	inc hl			;4d44
	cp (hl)			;4d45
	jp c,L_4FED		;4d46
	jr L_4D5E		;4d49
L_4D4B:
	ld c,(hl)		;4d4b
	dec c			;4d4c
	jr z,L_4D57		;4d4d
	ld c,a			;4d4f
	sub (hl)		;4d50
	inc hl			;4d51
	cp (hl)			;4d52
	jp c,L_4F1C		;4d53
	ld a,c			;4d56
L_4D57:
	inc hl			;4d57
	sub (hl)		;4d58
	inc hl			;4d59
	cp (hl)			;4d5a
	jp c,L_4DF7		;4d5b
L_4D5E:
	ex de,hl		;4d5e
	xor a			;4d5f
L_4D60:
	inc a			;4d60
	call L_48D1		;4d61
	djnz L_4D2C		;4d64
	ret			;4d66
L_4D67:
	ld a,(0e0f9h)		;4d67
	or a			;4d6a
	ret z			;4d6b
	ld b,005h		;4d6c
	ld hl,0e112h		;4d6e
L_4D71:
	ld a,(hl)		;4d71
	inc hl			;4d72
	cp 00dh			;4d73
	ld a,005h		;4d75
	jr nz,L_4D8D		;4d77
	ex de,hl		;4d79
	ld a,(de)		;4d7a
	cp 005h			;4d7b
	add a,a			;4d7d
	ld hl,04d99h		;4d7e
	call L_48D1		;4d81
	ld a,(0e079h)		;4d84
	sub (hl)		;4d87
	inc hl			;4d88
	cp (hl)			;4d89
	jr c,L_4D93		;4d8a
	ex de,hl		;4d8c
L_4D8D:
	call L_48D1		;4d8d
	djnz L_4D71		;4d90
	ret			;4d92
L_4D93:
	ld a,001h		;4d93
	ld (0e132h),a		;4d95
	ret			;4d98

; ----------------------------------------------------------------------
; DATOS choque_en_el_aire: Cinco pares (posicion, ancho) para los choques con el pinguino saltando: 0x58/0x30, 0x18/0x30, 0x98/0x30, 0x2C/0x58 y 0x64/0x58
;   0x4d99..0x4da3  (10 bytes)
; ----------------------------------------------------------------------
	defb 058h,030h,018h,030h,098h,030h,02ch,058h,064h,058h	; 4d99  X0.0.0,XdX

; ======================================================================
; CODIGO 0x4da3..0x4ebe  (283 bytes)
; ======================================================================


L_4DA3:
	ld a,(0e142h)		;4da3
	ld hl,0e140h		;4da6
	add a,(hl)		;4da9
	ret nz			;4daa
	ld de,(0e188h)		;4dab
	ld a,e			;4daf
	cp 0e0h			;4db0
	ret z			;4db2
	ld hl,(0e078h)		;4db3
	sub l			;4db6
	ld e,a			;4db7
	sub 00ah		;4db8
	ret nc			;4dba
	ld a,013h		;4dbb
	add a,e			;4dbd
	ld l,a			;4dbe
	ld a,e			;4dbf
	add a,a			;4dc0
	add a,017h		;4dc1
	ld e,a			;4dc3
	ld a,d			;4dc4
	sub h			;4dc5
	sub l			;4dc6
	add a,e			;4dc7
	ret nc			;4dc8
	ld a,007h		;4dc9
	call L_7970		;4dcb
	ld hl,0e08ch		;4dce
	ld de,0e183h		;4dd1
	call L_766C		;4dd4
	call L_7617		;4dd7
	ld de,00300h		;4dda
	jp L_4616		;4ddd
L_4DE0:
	ld hl,(0e090h)		;4de0
	ld a,l			;4de3
	cp 08fh			;4de4
	ret nz			;4de6
	ld a,(0e079h)		;4de7
	ld l,a			;4dea
	ld a,h			;4deb
	sub l			;4dec
	push af			;4ded
	sub 018h		;4dee
	add a,023h		;4df0
	jp c,L_4E0B		;4df2
	pop af			;4df5
	ret			;4df6
L_4DF7:
	ld a,(0e135h)		;4df7
	or a			;4dfa
	ret nz			;4dfb
	ld a,003h		;4dfc
	call L_7970		;4dfe
	ld hl,00101h		;4e01
	ld a,(0e0fah)		;4e04
	cpl			;4e07
	rra			;4e08
	jr L_4E21		;4e09
L_4E0B:
	ld hl,00101h		;4e0b
	ld (0e136h),hl		;4e0e
	ld a,008h		;4e11
	call L_7970		;4e13
	ld hl,00102h		;4e16
	ld a,(0e0f9h)		;4e19
	or a			;4e1c
	jr z,L_4E20		;4e1d
	inc l			;4e1f
L_4E20:
	pop af			;4e20
L_4E21:
	ld (0e142h),hl		;4e21
	ld a,020h		;4e24
	jr nc,L_4E2A		;4e26
	ld a,024h		;4e28
L_4E2A:
	ld (0e144h),a		;4e2a
	call L_4BA6		;4e2d
	call L_4B97		;4e30
	ld hl,01313h		;4e33
	ld (0e100h),hl		;4e36
	ret			;4e39
L_4E3A:
	ld a,(0e003h)		;4e3a
	and 003h		;4e3d
	ret nz			;4e3f
	ld hl,0e142h		;4e40
	ld a,(hl)		;4e43
	cp 003h			;4e44
	jp z,L_4ED2		;4e46
	inc hl			;4e49
	ld a,(hl)		;4e4a
	inc (hl)		;4e4b
	ld hl,l4ebdh		;4e4c
	call L_48D1		;4e4f
	ld c,(hl)		;4e52
	ld de,(0e078h)		;4e53
L_4E57:
	ld hl,0e0d0h		;4e57
	ld a,(0e144h)		;4e5a
	bit 2,a			;4e5d
	call z,L_4EB3	;4e5f
	call nz,L_4EAA	;4e62
	ld hl,0e142h		;4e65
	ld a,(hl)		;4e68
	dec a			;4e69
	jr z,L_4E6F		;4e6a
	dec (hl)		;4e6c
	jr L_4E57		;4e6d
L_4E6F:
	ex de,hl		;4e6f
	ld a,l			;4e70
	add a,c			;4e71
	ld l,a			;4e72
	call L_4B94		;4e73
	ld a,(0e078h)		;4e76
	cp 090h			;4e79
	jr nz,L_4E9C		;4e7b
L_4E7D:
	ld a,004h		;4e7d
	call L_7970		;4e7f
	call L_515C		;4e82
	call L_5165		;4e85
	xor a			;4e88
	ld b,a			;4e89
	ld hl,0e136h		;4e8a
	cp (hl)			;4e8d
	jr z,L_4E95		;4e8e
	ld (hl),a		;4e90
	inc a			;4e91
	ld (0e135h),a		;4e92
L_4E95:
	call L_5186		;4e95
	xor a			;4e98
	ld (0e135h),a		;4e99
L_4E9C:
	ld hl,0e143h		;4e9c
	ld a,(hl)		;4e9f
	sub 015h		;4ea0
	ret nz			;4ea2
	ld (hl),a		;4ea3
	dec hl			;4ea4
	ld (hl),a		;4ea5
	ld (0e137h),a		;4ea6
	ret			;4ea9
L_4EAA:
	call L_4C8A		;4eaa
	call L_4C8A		;4ead
	jp L_4C8A		;4eb0
L_4EB3:
	call L_4C6D		;4eb3
	call L_4C6D		;4eb6
	call L_4C6D		;4eb9
	xor a			;4ebc
L_4EBD:
	ret			;4ebd

; ----------------------------------------------------------------------
; DATOS rodada_de_la_caida: Veinte desplazamientos con signo, indexados de 1 a 20 desde 0x4EBD con 0xE143. Son tres tramos casi iguales: cada vuelta el pinguino rueda un poco menos
;   0x4ebe..0x4ed2  (20 bytes)
; ----------------------------------------------------------------------
	defb 0fdh,0feh,0feh,0ffh,001h,002h,002h,003h,0feh,0feh,0ffh,001h,002h,002h,0feh,0feh	; 4ebe  ................
	defb 0ffh,001h,002h,002h	; 4ece  ....

; ======================================================================
; CODIGO 0x4ed2..0x5115  (579 bytes)
; ======================================================================


L_4ED2:
	ld hl,0e0f9h		;4ed2
	ld a,(hl)		;4ed5
	inc (hl)		;4ed6
	cp 00bh			;4ed7
	jr nz,L_4EDD		;4ed9
	ld (hl),000h		;4edb
L_4EDD:
	push af			;4edd
	ld a,(0e144h)		;4ede
	ld c,a			;4ee1
	call L_4BA6		;4ee2
	pop af			;4ee5
	ld hl,04c51h		;4ee6
	call L_48D1		;4ee9
	ld a,(hl)		;4eec
	ld de,(0e078h)		;4eed
	add a,e			;4ef1
	ld e,a			;4ef2
	bit 2,c			;4ef3
	ld hl,0e0d0h		;4ef5
	call z,L_4EB3		;4ef8
	call nz,L_4EAA		;4efb
	ex de,hl		;4efe
	call L_4B94		;4eff
	ld a,(0e0f9h)		;4f02
	or a			;4f05
	ret nz			;4f06
	ld a,001h		;4f07
	ld (0e135h),a		;4f09
	call L_4E7D		;4f0c
	xor a			;4f0f
	ld (0e135h),a		;4f10
	dec hl			;4f13
	inc a			;4f14
	ld (hl),a		;4f15
	ld a,004h		;4f16
	call L_7970		;4f18
	ret			;4f1b
L_4F1C:
	ld hl,00001h		;4f1c
	ld (0e140h),hl		;4f1f
	xor a			;4f22
	ld (0e142h),a		;4f23
	ld a,0ffh		;4f26
	ld (0e0f8h),a		;4f28
	ld a,005h		;4f2b
	call L_7970		;4f2d
	ld hl,0e068h		;4f30
	ld bc,004b6h		;4f33
L_4F36:
	ld (hl),c		;4f36
	ld a,004h		;4f37
	call L_48D1		;4f39
	djnz L_4F36		;4f3c
L_4F3E:
	ld hl,(0e078h)		;4f3e
	ld l,09fh		;4f41
	call L_4BBD		;4f43
	ld a,010h		;4f46
	call L_4BA6		;4f48
	ld a,0e0h		;4f4b
	ld (0e0a0h),a		;4f4d
	ld hl,0e00ah		;4f50
	ld (0e0a3h),hl		;4f53
L_4F56:
	ld hl,0e068h		;4f56
	ld de,03b18h		;4f59
	ld bc,00020h		;4f5c
	call L_44DE		;4f5f
	jp L_4CEF		;4f62
L_4F65:
	ld hl,0e141h		;4f65
	inc (hl)		;4f68
	res 7,(hl)		;4f69
	ld a,(hl)		;4f6b
	cp 020h			;4f6c
	jr c,L_4F3E		;4f6e
	call L_4606		;4f70
	jr nz,L_4FB3		;4f73
	ld a,(0e003h)		;4f75
L_4F78:
	ld c,a			;4f78
	and 007h		;4f79
	ret nz			;4f7b
	ld a,008h		;4f7c
	ld b,099h		;4f7e
	ld de,01470h		;4f80
	bit 3,c			;4f83
	jr z,L_4F97		;4f85
	ld a,004h		;4f87
	ld b,096h		;4f89
	ld de,01874h		;4f8b
	bit 4,c			;4f8e
	jr z,L_4F97		;4f90
	ld a,00bh		;4f92
	ld de,01c78h		;4f94
L_4F97:
	ld hl,(0e078h)		;4f97
	ld l,b			;4f9a
	add a,h			;4f9b
	ld c,a			;4f9c
	ld a,b			;4f9d
	ld b,e			;4f9e
	ld (0e0a1h),bc		;4f9f
	add a,010h		;4fa3
	ld (0e0a0h),a		;4fa5
	push de			;4fa8
	call L_4BBD		;4fa9
	pop af			;4fac
	call L_4BA6		;4fad
	jp L_4F56		;4fb0
L_4FB3:
	xor a			;4fb3
	ld (0e140h),a		;4fb4
	ld (0e0f8h),a		;4fb7
	ld hl,00313h		;4fba
	ld (0e100h),hl		;4fbd
	ld a,(0e079h)		;4fc0
	push af			;4fc3
	ld hl,06699h		;4fc4
	ld de,0e068h		;4fc7
	ld c,004h		;4fca
	call L_45A2		;4fcc
	ld b,004h		;4fcf
L_4FD1:
	ld c,(hl)		;4fd1
	inc hl			;4fd2
	push bc			;4fd3
	call L_45A2		;4fd4
	pop bc			;4fd7
	djnz L_4FD1		;4fd8
	pop hl			;4fda
	ld l,090h		;4fdb
	call L_4BBD		;4fdd
	ld hl,004a0h		;4fe0
	ld (0e0a2h),hl		;4fe3
	call L_4B97		;4fe6
	call L_668C		;4fe9
	ret			;4fec
L_4FED:
	ex de,hl		;4fed
	dec hl			;4fee
	dec hl			;4fef
	ld d,(hl)		;4ff0
	dec hl			;4ff1
	ld e,(hl)		;4ff2
	dec hl			;4ff3
	dec hl			;4ff4
	ld (hl),000h		;4ff5
	ex de,hl		;4ff7
	inc hl			;4ff8
	ld de,0e1a0h		;4ff9
	ld bc,0000dh		;4ffc
	ldir			;4fff
	xor a			;5001
	ld (de),a		;5002
	ld a,006h		;5003
	call L_7970		;5005
	ld hl,0e1a0h		;5008
	call L_4525		;500b
	ld de,00500h		;500e
	call L_4616		;5011
	ret			;5014
L_5015:
	ld a,(0e0e1h)		;5015
	ld hl,05141h		;5018
	call L_48D1		;501b
	ld a,007h		;501e
	bit 0,(hl)		;5020
	jr z,L_5026		;5022
	ld a,009h		;5024
L_5026:
	ld (0e10ch),a		;5026
	ld a,(hl)		;5029
	ld hl,05d8dh		;502a
	ld de,061efh		;502d
	or a			;5030
	jr z,L_5039		;5031
	ld hl,05d98h		;5033
	ld de,0620ch		;5036
L_5039:
	push de			;5039
	ld de,04588h		;503a
	call L_4554		;503d
	pop hl			;5040
	ld de,l4f78h		;5041
	call L_4554		;5044
	ld de,03860h		;5047
	ld bc,000e0h		;504a
	ld a,(0e10ch)		;504d
	call L_44F1		;5050
	ld de,03940h		;5053
	ld bc,001c0h		;5056
	ld a,00fh		;5059
	call L_44F1		;505b
	ld hl,071fah		;505e
	call L_50C2		;5061
	ld hl,07237h		;5064
	call L_50C2		;5067
	ld hl,05115h		;506a
	ld a,(0e0e1h)		;506d
	add a,a			;5070
	add a,a			;5071
	call L_48D1		;5072
	ld (0e10ah),hl		;5075
	xor a			;5078
	ld (0e102h),a		;5079
	ld (0e108h),a		;507c
	ld hl,071f2h		;507f
	ld (0e103h),hl		;5082
	ld hl,0722fh		;5085
	ld (0e105h),hl		;5088
	call L_515C		;508b
	call L_516C		;508e
	ret			;5091
L_5092:
	ld hl,0e108h		;5092
	ld a,(hl)		;5095
	inc (hl)		;5096
	ld hl,(0e10ah)		;5097
	call L_48D1		;509a
	ld a,(hl)		;509d
	cp 0ffh			;509e
	ret z			;50a0
	ld (0e109h),a		;50a1
	ld bc,0e103h		;50a4
	bit 0,a			;50a7
	jr z,L_50AD		;50a9
	inc bc			;50ab
	inc bc			;50ac
L_50AD:
	add a,a			;50ad
	ld hl,071eah		;50ae
	call L_48D1		;50b1
	ld a,(hl)		;50b4
	ld e,a			;50b5
	ld (bc),a		;50b6
	inc hl			;50b7
	inc bc			;50b8
	ld a,(hl)		;50b9
	ld d,a			;50ba
	ld (bc),a		;50bb
	ex de,hl		;50bc
	ld a,008h		;50bd
	call L_48D1		;50bf
L_50C2:
	call L_4504		;50c2
	call L_4590		;50c5
	ld e,(hl)		;50c8
L_50C9:
	ld a,(0e10ch)		;50c9
	ld c,a			;50cc
	ld b,010h		;50cd
	ld d,0e1h		;50cf
L_50D1:
	inc hl			;50d1
	ld a,(hl)		;50d2
	or a			;50d3
	jr nz,L_50D7		;50d4
	ld a,c			;50d6
L_50D7:
	ld (de),a		;50d7
	inc de			;50d8
	djnz L_50D1		;50d9
L_50DB:
	ld de,03920h		;50db
	ld (0e14eh),de		;50de
	ld a,0ffh		;50e2
	ld (0e170h),a		;50e4
	ld hl,0e14eh		;50e7
	call L_4590		;50ea
	xor a			;50ed
	ret			;50ee
L_50EF:
	call L_52FD		;50ef
	ld hl,0e107h		;50f2
	ld a,(hl)		;50f5
	dec a			;50f6
	ret nz			;50f7
	ld a,(0e102h)		;50f8
	dec a			;50fb
	ret nz			;50fc
	ld (hl),a		;50fd
	call L_5092		;50fe
	or a			;5101
	ret nz			;5102
	ld hl,(0e103h)		;5103
	ld a,(0e109h)		;5106
	bit 0,a			;5109
	jr z,L_5110		;510b
	ld hl,(0e105h)		;510d
L_5110:
	xor a			;5110
	call L_516F		;5111
	ret			;5114

; ----------------------------------------------------------------------
; DATOS decorados_por_fase: Ocho bytes por fase, diez fases: la lista de decorados que van saliendo. Un 0xFF acaba la lista y los 0x77 son relleno
;   0x5115..0x5165  (80 bytes)
; ----------------------------------------------------------------------
	defb 003h,0ffh,001h,077h,003h,002h,001h,000h,0ffh,003h,001h,077h,002h,003h,000h,001h	; 5115  ...w.......w....
	defb 002h,0ffh,000h,0ffh,0ffh,003h,001h,077h,002h,000h,0ffh,077h,003h,0ffh,001h,077h	; 5125  .......w...w...w
	defb 0ffh,077h,077h,077h,0ffh,002h,003h,000h,001h,003h,001h,077h,000h,001h,000h,000h	; 5135  .www.......w....
	defb 000h,001h,000h,001h,000h,000h	; 5145  ......

; ======================================================================
; CODIGO 0x514b..0x5277  (300 bytes)
; ======================================================================


L_514B:
	ld hl,0e100h		;514b
	ld c,(hl)		;514e
	inc hl			;514f
	dec (hl)		;5150
	jr z,L_5164		;5151
	ld a,(hl)		;5153
	cp 003h			;5154
	jp z,L_50EF		;5156
	dec a			;5159
	jr nz,L_517B		;515a
L_515C:
	ld hl,(0e105h)		;515c
	ld a,(0e102h)		;515f
	jr L_516F		;5162
L_5164:
	ld (hl),c		;5164
L_5165:
	ld hl,0e102h		;5165
	ld a,(hl)		;5168
	inc (hl)		;5169
	res 2,(hl)		;516a
L_516C:
	ld hl,(0e103h)		;516c
L_516F:
	add a,a			;516f
	call L_48D1		;5170
	ld e,(hl)		;5173
	inc hl			;5174
	ld d,(hl)		;5175
	ex de,hl		;5176
	call L_4525		;5177
	ret			;517a
L_517B:
	ld b,000h		;517b
	dec a			;517d
	jr z,L_5186		;517e
	inc b			;5180
	srl c			;5181
	ld a,(hl)		;5183
	cp c			;5184
	ret nz			;5185
L_5186:
	ld hl,0e112h		;5186
	ld c,b			;5189
	ld b,004h		;518a
	ld a,(0e0e0h)		;518c
	cp 005h			;518f
	jr c,L_5194		;5191
	inc b			;5193
L_5194:
	ld a,c			;5194
	or a			;5195
	jr z,L_519F		;5196
	ld a,(hl)		;5198
	cp 00bh			;5199
	ld a,006h		;519b
	jr c,L_51C1		;519d
L_519F:
	ld a,(hl)		;519f
	or a			;51a0
	ld a,006h		;51a1
	jr z,L_51C1		;51a3
	inc (hl)		;51a5
	ld a,(hl)		;51a6
	cp 010h			;51a7
	jr c,L_51AD		;51a9
	ld (hl),000h		;51ab
L_51AD:
	inc hl			;51ad
	inc hl			;51ae
	ld e,(hl)		;51af
	inc hl			;51b0
	ld d,(hl)		;51b1
	ex de,hl		;51b2
	push de			;51b3
	push bc			;51b4
	call L_4525		;51b5
	pop bc			;51b8
	pop de			;51b9
	inc hl			;51ba
	ex de,hl		;51bb
	ld (hl),d		;51bc
	dec hl			;51bd
	ld (hl),e		;51be
	ld a,004h		;51bf
L_51C1:
	call L_48D1		;51c1
	djnz L_5194		;51c4
	call L_7596		;51c6
	call L_77E9		;51c9
	call L_4D1A		;51cc
	call L_4D67		;51cf
	ret			;51d2
L_51D3:
	call L_47FA		;51d3
	ld hl,(0e0e5h)		;51d6
	ld a,h			;51d9
	and a			;51da
	jr nz,L_51E1		;51db
	ld a,l			;51dd
	cp 086h			;51de
	ret c			;51e0
L_51E1:
	ld hl,0e10eh		;51e1
	ld a,(hl)		;51e4
	inc hl			;51e5
	dec (hl)		;51e6
	ret nz			;51e7
	ld (hl),a		;51e8
	ld hl,0e112h		;51e9
	ld b,003h		;51ec
	ld a,(0e0e0h)		;51ee
	cp 005h			;51f1
	jr c,L_51F6		;51f3
	inc b			;51f5
L_51F6:
	ld a,(hl)		;51f6
	or a			;51f7
	jr z,L_5202		;51f8
	ld a,006h		;51fa
	call L_48D1		;51fc
	djnz L_51F6		;51ff
	ret			;5201
L_5202:
	inc (hl)		;5202
	inc hl			;5203
	ex de,hl		;5204
	ld hl,0e111h		;5205
	inc (hl)		;5208
	res 3,(hl)		;5209
	ld a,(hl)		;520b
	ld hl,(0e18bh)		;520c
	call L_48D1		;520f
	ld c,(hl)		;5212
	push de			;5213
	call L_47E8		;5214
	pop de			;5217
	ld a,c			;5218
	inc a			;5219
	jr z,L_525A		;521a
	dec a			;521c
	bit 4,a			;521d
	jr z,L_522D		;521f
	ld hl,0e190h		;5221
	ld (hl),001h		;5224
	inc hl			;5226
	and 003h		;5227
	ld c,a			;5229
	ld (hl),a		;522a
	jr L_5238		;522b
L_522D:
	ld a,c			;522d
	or a			;522e
	jr z,L_5238		;522f
	ld a,(0e0fch)		;5231
	or a			;5234
	jr z,L_5238		;5235
	inc c			;5237
L_5238:
	ex de,hl		;5238
	call L_525E		;5239
	ld a,(0e190h)		;523c
	rra			;523f
	ret nc			;5240
	ld a,(0e191h)		;5241
	cpl			;5244
	and 003h		;5245
	ld c,a			;5247
	ld hl,0e12ah		;5248
	ld a,(hl)		;524b
	or a			;524c
	jr nz,L_5254		;524d
	inc (hl)		;524f
	inc hl			;5250
	call L_525E		;5251
L_5254:
	ld hl,0e190h		;5254
	ld (hl),000h		;5257
	ret			;5259
L_525A:
	ex de,hl		;525a
	dec hl			;525b
	ld (hl),a		;525c
	ret			;525d
L_525E:
	ld (hl),c		;525e
	inc hl			;525f
	ld de,05277h		;5260
	ld a,c			;5263
	add a,a			;5264
	ld c,a			;5265
	add a,a			;5266
	add a,c			;5267
	call L_48D6		;5268
	ld a,(de)		;526b
	ld (hl),a		;526c
	inc de			;526d
	inc hl			;526e
	ld a,(de)		;526f
	ld (hl),a		;5270
	inc de			;5271
	inc hl			;5272
	ld (hl),e		;5273
	inc hl			;5274
	ld (hl),d		;5275
	ret			;5276

; ----------------------------------------------------------------------
; DATOS tabla_de_obstaculos: Los SIETE obstaculos: los tipos 0, 1 y 2 son los agujeros -de los que salen la foca y el pez-, el 3 y el 4 los dos monticulos con los que se choca, y el 5 y el 6 LAS DOS BANDERAS que se recogen por 500 puntos. Seis bytes cada uno: los dos primeros son el puntero al primer trozo de dibujo, y los cuatro siguientes los pares (posicion, ancho) con los que se mira el choque. Los siete dibujos caen dentro de los 92 trozos de 0x6B92-0x71EA, que es lo que confirma para que son. Cierra clavada en 0x52A1
;   0x5277..0x52a1  (42 bytes)
; ----------------------------------------------------------------------
	defb 0c2h,06eh,001h,053h,03ah,000h,07bh,06fh,001h,013h,03bh,000h,03ah,070h,001h,092h	; 5277  .n.S:.{o..;.:p..
	defb 03bh,000h,092h,06bh,02bh,05bh,010h,090h,02eh,06dh,064h,053h,048h,088h,071h,071h	; 5287  ;..k+[...mdSH.qq
	defb 080h,02ch,000h,000h,0f9h,070h,02eh,02ch,000h,000h	; 5297  .,...p.,..

; ======================================================================
; CODIGO 0x52a1..0x538d  (236 bytes)
; ======================================================================


L_52A1:
	ld hl,(0e0e5h)		;52a1
	ld a,h			;52a4
	and 001h		;52a5
	ret z			;52a7
	ld a,l			;52a8
	cp 082h			;52a9
	ret nz			;52ab
	ld hl,0e0e2h		;52ac
	ld a,(hl)		;52af
	inc (hl)		;52b0
	srl a			;52b1
	push af			;52b3
	ld hl,0538dh		;52b4
	call L_48D1		;52b7
	pop af			;52ba
	ld a,(hl)		;52bb
	jr c,L_52C2		;52bc
	rra			;52be
	rra			;52bf
	rra			;52c0
	rra			;52c1
L_52C2:
	ld c,a			;52c2
	and 003h		;52c3
	cp 003h			;52c5
	ret z			;52c7
	bit 3,c			;52c8
	jr z,L_52CE		;52ca
	set 1,a			;52cc
L_52CE:
	ld hl,0e194h		;52ce
	ld (hl),a		;52d1
	inc hl			;52d2
	bit 2,c			;52d3
	jr z,L_52D9		;52d5
	ld (hl),002h		;52d7
L_52D9:
	inc hl			;52d9
	ld (hl),001h		;52da
	inc hl			;52dc
	ld (hl),000h		;52dd
	inc hl			;52df
	ld a,(0e100h)		;52e0
	srl a			;52e3
	srl a			;52e5
	ld (hl),a		;52e7
	call L_5472		;52e8
L_52EB:
	ld hl,053aeh		;52eb
L_52EE:
	ld a,(0e194h)		;52ee
	add a,a			;52f1
	call L_48D1		;52f2
	ld e,(hl)		;52f5
	inc hl			;52f6
	ld d,(hl)		;52f7
	ex de,hl		;52f8
	call L_4590		;52f9
	ret			;52fc
L_52FD:
	ld a,(0e196h)		;52fd
	or a			;5300
	ret z			;5301
	ld bc,0001fh		;5302
	ld a,(0e194h)		;5305
	rra			;5308
	jr c,L_531B		;5309
	ld a,(0e150h)		;530b
	ld hl,0e151h		;530e
	ld de,0e150h		;5311
	ldir			;5314
	ld (0e16fh),a		;5316
	jr L_5329		;5319
L_531B:
	ld a,(0e16fh)		;531b
	ld hl,0e16eh		;531e
	ld de,0e16fh		;5321
	lddr			;5324
	ld (0e150h),a		;5326
L_5329:
	call L_50DB		;5329
	ld hl,0e197h		;532c
	inc (hl)		;532f
	ld a,(hl)		;5330
	and 00fh		;5331
	jr nz,L_5345		;5333
	dec hl			;5335
	dec hl			;5336
	cp (hl)			;5337
	jr z,L_5345		;5338
	dec (hl)		;533a
	jr nz,L_5345		;533b
	dec hl			;533d
	ld a,(hl)		;533e
	xor 001h		;533f
	ld (hl),a		;5341
	call L_52EB		;5342
L_5345:
	ld hl,(0e0e5h)		;5345
	ld a,h			;5348
	and 001h		;5349
	ret nz			;534b
	ld a,l			;534c
	cp 045h			;534d
	ret nc			;534f
	ld hl,0e197h		;5350
	ld a,(hl)		;5353
	and 00fh		;5354
	ret nz			;5356
	dec hl			;5357
	ld (hl),a		;5358
	ld hl,053b6h		;5359
	call L_52EE		;535c
	call L_546D		;535f
L_5362:
	ld hl,0e196h		;5362
	ld a,(hl)		;5365
	or a			;5366
	ret z			;5367
	inc hl			;5368
	inc hl			;5369
	dec (hl)		;536a
	ret nz			;536b
	ld a,(0e100h)		;536c
	srl a			;536f
	srl a			;5371
	ld (hl),a		;5373
	ld hl,0e0d1h		;5374
	ld de,(0e078h)		;5377
	ld a,(0e194h)		;537b
	rra			;537e
	jr c,L_5387		;537f
	call L_4C6D		;5381
	jp L_4B93		;5384
L_5387:
	call L_4C8A		;5387
	jp L_4B93		;538a

; ----------------------------------------------------------------------
; DATOS curvas_por_fase: Sesenta y seis curvas en treinta y tres bytes, a nibble por curva: 0x52B1 elige la mitad alta o la baja. Cierra con el 0xFF de 0x53AD, justo delante de los punteros
;   0x538d..0x53ae  (33 bytes)
; DATOS punteros_del_horizonte: Ocho punteros a los siete dibujos de horizonte (dos apuntan al mismo). Cierra clavada en 0x53BE, que es el primero de ellos
;   0x53ae..0x53be  (16 bytes)
; DATOS dibujos_del_horizonte: Los siete horizontes, en el formato de las cadenas: recto, curva a un lado, curva al otro, y los cuatro de la llegada a la base. Todos escriben en las filas 10 y 11. Acaba clavado en 0x546D
;   0x53be..0x546d  (175 bytes)
; ----------------------------------------------------------------------
	defb 0ffh,0ffh,0ffh,099h,0f8h,080h,0ffh,00fh,090h,0f8h,08fh,0f9h,01fh,01fh,0f8h,055h	; 538d  ...............U
	defb 05fh,009h,0f4h,0ffh,0f0h,01fh,0f0h,09fh,090h,0f5h,0ffh,0f1h,08fh,0ffh,090h,099h	; 539d  _...............
	defb 00fh,0beh,053h,0cfh,053h,0f1h,053h,010h,054h,0e0h,053h,0e0h,053h,04eh,054h,02fh	; 53ad  ..S.S.S.T.S.SNT/
	defb 054h,049h,039h,014h,014h,013h,013h,015h,030h,030h,031h,010h,010h,010h,032h,033h	; 53bd  TI9.....001...23
	defb 023h,0ffh,049h,039h,023h,074h,032h,010h,010h,010h,031h,030h,030h,015h,013h,013h	; 53cd  #.I9#t2...100...
	defb 014h,014h,0ffh,049h,039h,015h,014h,013h,012h,052h,010h,00fh,00fh,010h,011h,012h	; 53dd  ...I9....R......
	defb 013h,014h,015h,0ffh,049h,039h,014h,014h,013h,013h,015h,030h,030h,031h,010h,010h	; 53ed  ....I9.....001..
	defb 010h,041h,047h,053h,053h,054h,054h,054h,054h,054h,054h,054h,054h,0feh,072h,039h	; 53fd  .AGSSTTTTTTTT.r9
	defb 00fh,03eh,0ffh,040h,039h,054h,054h,054h,054h,054h,054h,054h,054h,053h,053h,088h	; 540d  .>.@9TTTTTTTTSS.
	defb 082h,010h,010h,010h,031h,030h,030h,015h,013h,013h,014h,014h,0feh,06ch,039h,07fh	; 541d  ....100......l9.
	defb 00fh,0ffh,040h,039h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h	; 542d  ..@9............
	defb 004h,07dh,07ah,00fh,00fh,010h,011h,012h,013h,014h,015h,0feh,06ch,039h,079h,078h	; 543d  .}z.........l9yx
	defb 0ffh,049h,039h,015h,014h,013h,012h,052h,010h,00fh,00fh,039h,03ch,004h,004h,004h	; 544d  .I9....R...9<...
	defb 004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,0feh,072h,039h,037h,038h,0ffh	; 545d  ...........r978.

; ======================================================================
; CODIGO 0x546d..0x54f8  (139 bytes)
; ======================================================================


L_546D:
	ld hl,07290h		;546d
	jr L_5475		;5470
L_5472:
	ld hl,0721eh		;5472
L_5475:
	ld a,(0e194h)		;5475
	bit 1,a			;5478
	ret z			;547a
	rra			;547b
	ld a,(hl)		;547c
	jr nc,L_5481		;547d
	sub 010h		;547f
L_5481:
	ld e,a			;5481
	jp L_50C9		;5482
L_5485:
	ld a,(0e003h)		;5485
	and 003h		;5488
	ret nz			;548a
	inc c			;548b
	jr nz,L_54B4		;548c
	ld a,(0e139h)		;548e
	ld c,a			;5491
	xor a			;5492
	ld b,a			;5493
	ld hl,00070h		;5494
	sbc hl,bc		;5497
	ld a,(0e138h)		;5499
	ld b,a			;549c
	ld e,l			;549d
	ld d,h			;549e
L_549F:
	add hl,de		;549f
	djnz L_549F		;54a0
	ld a,h			;54a2
	rlca			;54a3
	rlca			;54a4
	rlca			;54a5
	rlca			;54a6
	and 0f0h		;54a7
	ld e,a			;54a9
	ld a,l			;54aa
	rrca			;54ab
	rrca			;54ac
	rrca			;54ad
	rrca			;54ae
	and 00fh		;54af
	or e			;54b1
	add a,c			;54b2
	ld h,a			;54b3
L_54B4:
	ld a,(0e078h)		;54b4
	dec a			;54b7
	ld l,a			;54b8
	call L_4BBD		;54b9
	call L_4CA2		;54bc
	ld hl,0e138h		;54bf
	inc (hl)		;54c2
	ld a,010h		;54c3
	cp (hl)			;54c5
	ret			;54c6
L_54C7:
	xor a			;54c7
	ld (0e13ah),a		;54c8
L_54CB:
	ld hl,0e13ah		;54cb
	ld a,(hl)		;54ce
	inc (hl)		;54cf
	ld hl,054f8h		;54d0
	rra			;54d3
	jr nc,L_54D9		;54d4
	ld hl,0550ch		;54d6
L_54D9:
	call L_4525		;54d9
	ret			;54dc
L_54DD:
	ld hl,06b2ah		;54dd
	call L_4550		;54e0
	ld hl,066efh		;54e3
	ld de,0e06ch		;54e6
	ld bc,00010h		;54e9
	ldir			;54ec
	call L_668C		;54ee
	ld hl,05516h		;54f1
	call L_4525		;54f4
	ret			;54f7

; ----------------------------------------------------------------------
; DATOS bloque_base_a: Uno de los dos bloques que se van alternando para dibujar la base
;   0x54f8..0x550c  (20 bytes)
; DATOS bloque_base_b: El otro
;   0x550c..0x5516  (10 bytes)
; DATOS bloque_base_polo: El tercero, el del remate de 0x54DD
;   0x5516..0x552b  (21 bytes)
; ----------------------------------------------------------------------
	defb 0e1h,0efh,0b6h,0b7h,0eeh,0b8h,0b9h,0bah,0bbh,0eeh,0beh,0bfh,0c0h,0bch,0eeh,0c3h	; 54f8  ................
	defb 0c4h,0c5h,0c6h,000h,002h,0eeh,0c2h,0eeh,0bdh,0c1h,0eeh,0c7h,0c8h,000h,0e1h,0eeh	; 5508  ................
	defb 0d2h,0d5h,0d8h,0eeh,0d3h,0d6h,0d9h,0dbh,0eeh,0d4h,0d7h,0dah,0dch,0eeh,0ddh,0deh	; 5518  ................
	defb 0dfh,00fh,000h	; 5528  ...

; ======================================================================
; CODIGO 0x552b..0x5588  (93 bytes)
; ======================================================================


L_552B:
	ld hl,065f9h		;552b
	ld de,05100h		;552e
	call L_4554		;5531
	ld hl,05588h		;5534
	ld a,(0e0e1h)		;5537
	ld c,a			;553a
	add a,a			;553b
	call L_48D1		;553c
	ld e,(hl)		;553f
	inc hl			;5540
	ld d,(hl)		;5541
	ex de,hl		;5542
	ld de,03acch		;5543
	call L_4594		;5546
	ld hl,055f1h		;5549
	ld a,(0e0e0h)		;554c
	and 00fh		;554f
	add a,a			;5551
	call L_48D1		;5552
	ld e,(hl)		;5555
	inc hl			;5556
	ld d,(hl)		;5557
	ex de,hl		;5558
	ld de,05f40h		;5559
	call L_4554		;555c
	ld a,(hl)		;555f
	ld (0e063h),a		;5560
	inc hl			;5563
	ld a,(hl)		;5564
	ld (0e067h),a		;5565
	jr L_557B		;5568
L_556A:
	ld a,(0e060h)		;556a
	sub 002h		;556d
	cp 036h			;556f
	ret z			;5571
	ld (0e060h),a		;5572
	ld (0e064h),a		;5575
	ld (0e068h),a		;5578
L_557B:
	ld hl,0e060h		;557b
	ld de,03b10h		;557e
	ld bc,0000ch		;5581
	call L_44DE		;5584
	ret			;5587

; ----------------------------------------------------------------------
; DATOS punteros_de_las_bases: Diez punteros, uno por fase, a los nombres de las bases. Cierra clavada en 0x559C, que es la primera cadena; con ocho, nueve, once o doce entradas no cierra
;   0x5588..0x559c  (20 bytes)
; DATOS nombres_de_las_bases: OCHO cadenas para diez fases: JAPAN, AUSTRALIA, FRANCE, NEW ZEALAND, ARGENTINA, UNITED KINGDOM, THE SOUTH POLE y USA. El reparto que sale de la tabla de arriba es FRANCE, USA, THE SOUTH POLE, USA, USA, ARGENTINA, UNITED KINGDOM, JAPAN, AUSTRALIA y AUSTRALIA. NEW ZEALAND (0x55BF..0x55CE) NO LA VISITA NADIE: no esta en la tabla, ninguna instruccion la apunta, y ninguna de sus dieciseis direcciones aparece como palabra en los 16 KB. En la PRIMERA version japonesa del cartucho si se visita, y es la fase 4; ver la pagina de las versiones. Los dos primeros bytes de cada cadena son el destino en la tabla de nombres de la VRAM, o sea el centrado: 0x3AC8 para las dos de catorce letras y 0x3ACE para USA
;   0x559c..0x560b  (111 bytes)
; DATOS banderas_comprimidas: Siete banderas distintas para diez ranuras. Los diez flujos miden entre 11 y 59 bytes y TODOS descomprimen a 64 bytes exactos, que son dos sprites de 16x16; detras de cada uno van sus dos colores
;   0x5605..0x574c  (327 bytes)
; DATOS punteros_de_banderas: Diez punteros a los graficos de bandera. Cierra clavada en 0x5605
;   0x560b..0x5605  (-6 bytes)
; DATOS rotulos: Los rotulos de pantalla, en el formato de las cadenas: el panel (1P, HI, STAGE, TIME), (c)KONAMI 1984, PLAY SELECT con JOYSTICK y KEYBOARD, y TIME OUT
;   0x574c..0x57ce  (130 bytes)
; DATOS titulo_comprimido: La pantalla de titulo: relleno y el rotulo SOFTWARE en la fila 10. Pasado por el descompresor son veinte casillas en dos sitios (VRAM 0x394A y 0x396C) y el flujo se acaba en 0x57E3
;   0x57ce..0x57e3  (21 bytes)
; DATOS mandos_de_la_demo: LOS MANDOS GRABADOS DE LA DEMO. Sesenta y cuatro bytes, uno cada 32 fotogramas: 0x419F los apunta y 0x4103 los va leyendo. La demo dura 0x073C pasos, asi que gasta 58 de los 64. Cada byte lleva los mismos bits que el joystick, y se ve: 0x01 arriba, 0x09 arriba y derecha, 0x11 arriba y gatillo... La partida de demostracion no la juega ninguna inteligencia, va grabada. Cierra clavada en 0x5823, la primera instruccion de MONTA_LA_FUENTE
;   0x57e3..0x5823  (64 bytes)
; ----------------------------------------------------------------------
	defb 09ch,055h,0a4h,055h,0a4h,055h,0b0h,055h,0b9h,055h,0eah,055h,0c7h,055h,0c7h,055h	; 5588  .U.U.U.U.U.U.U.U
	defb 0cdh,055h,0d9h,055h,020h,02ah,021h,030h,021h,02eh,020h,0ffh,020h,021h,035h,033h	; 5598  .U.U *!0!. . !53
	defb 034h,032h,021h,02ch,029h,021h,020h,0ffh,020h,0c9h,032h,021h,02eh,023h,025h,020h	; 55a8  42!,)! . .2!.#% 
	defb 0ffh,020h,02eh,025h,0cah,00fh,0cbh,025h,021h,02ch,021h,02eh,024h,020h,0ffh,020h	; 55b8  . .%...%!,!.$ . 
	defb 035h,033h,021h,020h,0ffh,020h,021h,032h,027h,025h,02eh,034h,029h,02eh,021h,020h	; 55c8  53! . !2'%.4).! 
	defb 0ffh,020h,035h,02eh,029h,034h,025h,024h,00fh,02bh,029h,02eh,027h,024h,02fh,02dh	; 55d8  . 5.)4%$.+).'$/-
	defb 020h,0ffh,020h,0ceh,0cfh,0d0h,0d1h,020h,0ffh,0cdh,056h,005h,056h,01eh,056h,01eh	; 55e8   . .... ..V.V.V.
	defb 056h,04dh,056h,05ah,056h,00ah,057h,086h,056h,086h,056h,0aah,056h,002h,000h,082h	; 55f8  VMVZV.W.V.V.V...
	defb 003h,007h,003h,00fh,082h,007h,003h,009h,000h,082h,080h,0c0h,003h,0e0h,082h,0c0h	; 5608  ................
	defb 080h,027h,000h,000h,006h,00fh,087h,0cch,06dh,00ch,0ffh,00ch,06dh,0cch,009h,000h	; 5618  .'......m...m...
	defb 087h,0c0h,080h,000h,0c0h,000h,080h,0c0h,009h,000h,007h,000h,002h,0ffh,002h,0fbh	; 5628  ................
	defb 001h,0ffh,004h,000h,089h,03fh,03bh,03fh,03dh,02fh,03bh,03fh,0ffh,0f7h,003h,0ffh	; 5638  .....?;?=/;?....
	defb 004h,000h,000h,006h,00dh,010h,000h,00ch,03fh,004h,000h,00ch,0f8h,014h,000h,000h	; 5648  ........?.......
	defb 006h,004h,087h,0cch,06dh,00ch,0ffh,00ch,06dh,0cch,009h,000h,087h,0c0h,080h,000h	; 5658  ....m...m.......
	defb 0c0h,000h,080h,0c0h,009h,000h,007h,000h,005h,0ffh,004h,000h,08ch,03fh,03fh,037h	; 5668  .............??7
	defb 03fh,03bh,02fh,03fh,0ffh,0ffh,0f7h,0ffh,0ffh,004h,000h,000h,006h,00dh,007h,000h	; 5678  ?;/?............
	defb 085h,0ffh,000h,0ffh,000h,0ffh,005h,000h,08bh,0ffh,000h,0ffh,000h,0ffh,000h,0ffh	; 5688  ................
	defb 000h,0ffh,000h,0ffh,004h,000h,086h,055h,0aah,055h,0aah,055h,0aah,01ah,000h,000h	; 5698  .......U.U.U....
	defb 006h,004h,004h,000h,084h,001h,003h,003h,001h,00ch,000h,084h,080h,0c0h,0c0h,080h	; 56a8  ................
	defb 008h,000h,004h,0ffh,004h,000h,004h,0ffh,004h,000h,004h,0ffh,004h,000h,004h,0ffh	; 56b8  ................
	defb 004h,000h,000h,00ah,007h,08ch,061h,031h,019h,00dh,001h,0ffh,0ffh,001h,00dh,019h	; 56c8  ......a1........
	defb 031h,061h,004h,000h,08ch,086h,08ch,098h,0b0h,080h,0ffh,0ffh,080h,0b0h,098h,08ch	; 56d8  1a..............
	defb 086h,004h,000h,084h,00ch,084h,0c0h,0e0h,004h,000h,084h,0e0h,0c0h,084h,00ch,004h	; 56e8  ................
	defb 000h,084h,030h,021h,003h,007h,004h,000h,084h,007h,003h,021h,030h,004h,000h,000h	; 56f8  ..0!.......!0...
	defb 008h,005h,08bh,003h,004h,00ah,00ch,02ch,03eh,018h,008h,008h,00ch,007h,005h,000h	; 5708  .......,>.......
	defb 08bh,0c0h,020h,050h,010h,030h,078h,01ch,014h,010h,030h,0e0h,005h,000h,085h,000h	; 5718  .. P.0x...0.....
	defb 000h,002h,001h,003h,003h,000h,083h,000h,000h,018h,005h,000h,085h,000h,000h,040h	; 5728  ...............@
	defb 080h,0c0h,003h,000h,083h,000h,000h,018h,005h,000h,000h,001h,00ah,00ch,038h,028h	; 5738  ..............8(
	defb 029h,020h,0feh,016h,038h,033h,034h,021h,027h,025h,020h,0feh,022h,038h,034h,029h	; 5748  ) ..834!'% ."84)
	defb 02dh,025h,020h,0feh,02ch,038h,038h,03ah,03bh,000h,000h,000h,000h,040h,041h,0feh	; 5758  -% .,88:;....@A.
	defb 036h,038h,026h,031h,037h,0feh,002h,038h,011h,030h,020h,0ffh,00bh,039h,01ah,01bh	; 5768  68&17..8.0 ..9..
	defb 01ch,01dh,01eh,01fh,000h,011h,019h,018h,014h,0ffh,0abh,039h,030h,02ch,021h,039h	; 5778  ...........90,!9
	defb 000h,033h,025h,02ch,025h,023h,034h,0feh,006h,03ah,011h,020h,03ch,03dh,000h,000h	; 5788  .3%,%#4..:. <=..
	defb 030h,02ch,021h,039h,000h,03eh,03fh,000h,02ah,02fh,039h,033h,034h,029h,023h,02bh	; 5798  0,!9.>?.*/934)#+
	defb 0feh,046h,03ah,012h,020h,03ch,03dh,000h,000h,030h,02ch,021h,039h,000h,03eh,03fh	; 57a8  .F:. <=..0,!9.>?
	defb 000h,02bh,025h,039h,022h,02fh,021h,022h,024h,0ffh,0ech,038h,034h,029h,02dh,025h	; 57b8  .+%9"/!"$..84)-%
	defb 000h,02fh,035h,034h,0ffh,066h,039h,020h,000h,036h,029h,024h,025h,02fh,000h,023h	; 57c8  ./54.f9 .6)$%/.#
	defb 021h,032h,034h,032h,029h,024h,027h,025h,000h,020h,0ffh,000h,000h,000h,000h,000h	; 57d8  !242)$'%. ......
	defb 000h,000h,000h,000h,000h,000h,001h,009h,001h,001h,011h,005h,005h,009h,009h,001h	; 57e8  ................
	defb 006h,004h,010h,001h,001h,011h,010h,001h,001h,009h,009h,001h,005h,015h,009h,019h	; 57f8  ................
	defb 001h,001h,005h,011h,001h,001h,001h,011h,001h,001h,001h,011h,001h,000h,018h,019h	; 5808  ................
	defb 009h,001h,011h,001h,001h,001h,001h,001h,001h,001h,001h	; 5818  ...........

; ======================================================================
; CODIGO 0x5823..0x5874  (81 bytes)
; ======================================================================


L_5823:
	ld de,00000h		;5823
	call L_5835		;5826
	ld de,00800h		;5829
	call L_5835		;582c
	ld de,01000h		;582f
	jp L_5835		;5832
L_5835:
	push de			;5835
	xor a			;5836
	ld c,010h		;5837
L_5839:
	ld b,008h		;5839
L_583B:
	call L_48B3		;583b
	inc de			;583e
	djnz L_583B		;583f
	inc a			;5841
	dec c			;5842
	jr nz,L_5839		;5843
	ld bc,00270h		;5845
	ld a,0f0h		;5848
	call L_44F1		;584a
	ld hl,05d59h		;584d
	call L_455D		;5850
	ld b,016h		;5853
L_5855:
	ld hl,05d8fh		;5855
	push bc			;5858
	call L_455D		;5859
	pop bc			;585c
	djnz L_5855		;585d
	pop de			;585f
	ld hl,06000h		;5860
	add hl,de		;5863
	ex de,hl		;5864
	ld hl,05874h		;5865
	call L_4554		;5868
	ld hl,05c04h		;586b
	call L_455D		;586e
	jp L_455D		;5871

; ----------------------------------------------------------------------
; DATOS fuente_comprimida: La fuente y el logotipo de KONAMI, que van a los tres bancos
;   0x5874..0x5d9b  (1319 bytes)
; ----------------------------------------------------------------------
	defb 040h,000h,040h,000h,083h,000h,01ch,022h,003h,063h,085h,022h,01ch,000h,018h,038h	; 5874  @.@....".c."...8
	defb 004h,018h,0aeh,07eh,000h,03eh,063h,003h,00eh,03ch,070h,07fh,000h,03eh,063h,003h	; 5884  ...~.>c..<p..>c.
	defb 00eh,003h,063h,03eh,000h,00eh,01eh,036h,066h,066h,07fh,006h,000h,07fh,060h,07eh	; 5894  ..c>...6ff....`~
	defb 063h,003h,063h,03eh,000h,03eh,063h,060h,07eh,063h,063h,03eh,000h,07fh,063h,006h	; 58a4  c.c>.>c`~cc>..c.
	defb 00ch,003h,018h,09ah,000h,03eh,063h,063h,03eh,063h,063h,03eh,000h,03eh,063h,063h	; 58b4  .....>cc>cc>.>cc
	defb 03fh,003h,063h,03eh,00fh,010h,026h,028h,028h,026h,010h,00fh,003h,083h,004h,043h	; 58c4  ?.c>..&((&.....C
	defb 08ah,083h,003h,01ch,038h,070h,0e1h,0cdh,0cdh,0fdh,079h,003h,000h,081h,0eeh,003h	; 58d4  ....8p....y.....
	defb 06bh,081h,0ebh,003h,000h,089h,073h,01ah,07ah,05ah,07ah,000h,003h,000h,0f3h,004h	; 58e4  k.....s.zZz.....
	defb 05bh,004h,000h,081h,07eh,004h,000h,092h,01ch,036h,063h,063h,07fh,063h,063h,000h	; 58f4  [...~....6cc.cc.
	defb 07eh,063h,063h,07eh,063h,063h,07eh,000h,03eh,063h,003h,060h,085h,063h,03eh,000h	; 5904  ~cc~cc~.>c.`.c>.
	defb 07ch,066h,003h,063h,09bh,066h,07ch,000h,07fh,060h,060h,07eh,060h,060h,07fh,000h	; 5914  |f.c.f|..``~``..
	defb 0eeh,0aah,08ah,0eah,02eh,0a8h,0e8h,000h,03eh,063h,060h,067h,063h,063h,03fh,000h	; 5924  ........>c`gcc?.
	defb 003h,063h,081h,07fh,003h,063h,082h,000h,03ch,005h,018h,083h,03ch,000h,01fh,004h	; 5934  .c...c..<...<...
	defb 006h,08bh,066h,03ch,000h,063h,066h,06ch,078h,07ch,06eh,067h,000h,006h,060h,093h	; 5944  ..f<.cflx|ng..`.
	defb 07fh,000h,063h,077h,07fh,07fh,06bh,063h,063h,000h,063h,073h,07bh,07fh,06fh,067h	; 5954  ..cw..kcc.cs{.og
	defb 063h,000h,03eh,005h,063h,083h,03eh,000h,07eh,003h,063h,09dh,07eh,060h,060h,000h	; 5964  c.>.c.>.~.c.~``.
	defb 0eeh,088h,088h,0eeh,088h,088h,0eeh,000h,07eh,063h,063h,062h,07ch,066h,063h,000h	; 5974  ........~ccb|fc.
	defb 03eh,063h,060h,03eh,003h,063h,03eh,000h,07eh,006h,018h,081h,000h,006h,063h,082h	; 5984  >c`>.c>.~.....c.
	defb 03eh,000h,004h,063h,085h,036h,01ch,008h,000h,0c0h,005h,0a0h,083h,0c0h,000h,0f3h	; 5994  >..c.6..........
	defb 003h,0dbh,088h,0f3h,0d3h,0dbh,000h,066h,066h,07eh,03ch,003h,018h,08dh,000h,0dfh	; 59a4  .......ff~<.....
	defb 01ah,018h,0cch,006h,016h,0deh,000h,0f8h,060h,060h,067h,003h,060h,0a8h,000h,000h	; 59b4  ........``g.`...
	defb 040h,049h,05ah,073h,052h,059h,000h,000h,000h,092h,052h,0ceh,002h,0dch,000h,000h	; 59c4  @IZsRY....R.....
	defb 002h,000h,08ah,0aah,0aah,0dah,000h,000h,008h,048h,0eeh,04ah,04ah,06ah,000h,000h	; 59d4  .........H.JJj..
	defb 020h,024h,02dh,039h,029h,02dh,004h,000h,001h,0f0h,003h,050h,001h,000h,007h,0eeh	; 59e4   $-9)-.....P....
	defb 001h,000h,007h,0e0h,00eh,000h,082h,007h,00fh,006h,000h,082h,0f8h,0f0h,004h,03eh	; 59f4  ...............>
	defb 004h,03fh,08bh,01fh,03fh,07fh,0ffh,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h,003h,000h	; 5a04  .?..?...........
	defb 002h,03eh,005h,000h,083h,01fh,07fh,0fbh,005h,000h,083h,00fh,0cfh,0efh,005h,000h	; 5a14  .>..............
	defb 083h,078h,0fch,0bch,005h,000h,083h,03fh,07fh,0f3h,005h,000h,083h,087h,0c7h,0c7h	; 5a24  .x.....?........
	defb 005h,000h,083h,0bch,0feh,0dfh,005h,000h,088h,078h,0fch,0bch,060h,0f0h,0f0h,060h	; 5a34  .........x..`..`
	defb 000h,003h,0f0h,002h,03fh,006h,03eh,088h,0f8h,0fch,0feh,07fh,03fh,01fh,00fh,007h	; 5a44  ....?.>.....?...
	defb 003h,03eh,085h,07eh,0fch,0fch,0f8h,0e0h,005h,0f1h,083h,0fbh,07fh,01fh,006h,0efh	; 5a54  .>.~............
	defb 082h,0cfh,00fh,008h,01eh,088h,0e1h,003h,03fh,0f1h,0e1h,0f3h,07fh,01eh,007h,0e7h	; 5a64  ........?.......
	defb 081h,0f7h,008h,08fh,008h,01eh,082h,0f1h,0f2h,004h,0f5h,097h,0f2h,0f1h,0e0h,010h	; 5a74  ................
	defb 0c8h,068h,0c8h,028h,010h,0e0h,000h,000h,008h,02eh,06fh,07fh,03fh,07fh,000h,003h	; 5a84  .h.(......o.?...
	defb 007h,00fh,0dfh,003h,0ffh,083h,000h,0e0h,0fch,005h,0ffh,004h,000h,090h,0e0h,0f0h	; 5a94  ................
	defb 0fch,0ffh,000h,003h,003h,000h,001h,001h,003h,007h,0c0h,080h,087h,0e7h,004h,0ffh	; 5aa4  ................
	defb 003h,000h,085h,0c0h,0f0h,0fch,0ffh,0ffh,004h,000h,089h,0c0h,0e0h,0e0h,0f0h,010h	; 5ab4  ................
	defb 018h,018h,01dh,01dh,003h,00fh,002h,01fh,002h,03fh,002h,07fh,002h,0ffh,002h,0f8h	; 5ac4  .........?......
	defb 003h,0e0h,003h,0f0h,083h,007h,003h,001h,005h,000h,088h,080h,0ceh,0ffh,07fh,00fh	; 5ad4  ................
	defb 00fh,01fh,000h,003h,0f8h,003h,0fch,08eh,0ffh,0c0h,000h,03eh,03fh,003h,003h,007h	; 5ae4  ...........>?...
	defb 006h,006h,01fh,01fh,00fh,08fh,003h,0cfh,089h,00fh,000h,080h,0c0h,0c0h,0e0h,0e0h	; 5af4  ................
	defb 0f0h,0f0h,003h,07fh,085h,0ffh,07fh,07fh,05fh,04ch,006h,0f0h,002h,0f8h,002h,07fh	; 5b04  ........_L......
	defb 004h,03fh,084h,07fh,07fh,0f8h,0fch,003h,0f0h,003h,0e0h,003h,07fh,087h,03fh,03fh	; 5b14  .?............??
	defb 01fh,01fh,00fh,0c0h,080h,003h,000h,083h,080h,0c0h,0c0h,004h,0ffh,084h,01fh,007h	; 5b24  ................
	defb 000h,000h,003h,0ffh,097h,0feh,03eh,01ch,0c0h,000h,0ffh,0ffh,0feh,0feh,0fch,0fch	; 5b34  ......>.........
	defb 0f8h,0f0h,00fh,007h,007h,003h,003h,007h,01fh,01fh,0f0h,0f0h,004h,0e0h,082h,0c0h	; 5b44  ................
	defb 080h,003h,01fh,082h,00fh,007h,003h,000h,005h,0ffh,083h,0feh,0f0h,000h,005h,0ffh	; 5b54  ................
	defb 083h,038h,000h,000h,085h,0feh,0fch,0f8h,0e0h,080h,003h,000h,08ah,07fh,067h,001h	; 5b64  .8............g.
	defb 003h,007h,007h,00fh,00fh,080h,0c0h,003h,0e0h,084h,0c0h,0c0h,080h,00fh,005h,01fh	; 5b74  ................
	defb 08fh,00fh,00fh,080h,0fch,0f8h,0f1h,0f3h,0f3h,0ffh,0ffh,001h,00fh,01fh,03fh,03fh	; 5b84  ..............??
	defb 007h,0ffh,084h,0fdh,0fch,0fch,0f8h,005h,0ffh,084h,03fh,01fh,003h,0f8h,004h,0f0h	; 5b94  ..........?.....
	defb 089h,030h,010h,000h,0ffh,0ffh,07fh,03fh,01fh,00fh,003h,003h,084h,007h,00fh,01fh	; 5ba4  .0.....?........
	defb 00fh,003h,007h,005h,000h,088h,001h,00fh,0ffh,000h,000h,001h,003h,03fh,006h,0ffh	; 5bb4  .............?..
	defb 085h,07fh,03fh,001h,000h,000h,006h,0ffh,082h,01fh,000h,083h,040h,0e0h,040h,005h	; 5bc4  ..?.........@.@.
	defb 000h,0a0h,001h,00fh,001h,00fh,00ah,00dh,00fh,009h,005h,0eeh,004h,0eeh,0adh,065h	; 5bd4  ...............e
	defb 0e5h,025h,0f1h,081h,041h,0f7h,0d4h,067h,050h,0f5h,000h,0e0h,000h,0e0h,020h,0e0h	; 5be4  .%..A..gP..... .
	defb 000h,050h,005h,000h,006h,00fh,00ah,000h,006h,0f0h,00ah,000h,006h,0ffh,005h,000h	; 5bf4  .P..............
	defb 006h,0c0h,004h,0ffh,010h,0c0h,00ch,000h,004h,0ffh,006h,000h,008h,003h,003h,007h	; 5c04  ................
	defb 005h,000h,002h,0ffh,004h,0e0h,084h,0c0h,000h,0ffh,0ffh,013h,0c0h,006h,0e0h,005h	; 5c14  ................
	defb 0c0h,000h,001h,003h,007h,001h,002h,003h,002h,007h,003h,00fh,083h,01fh,01eh,01eh	; 5c24  ................
	defb 003h,03fh,08dh,07ch,078h,0f8h,0e0h,0e0h,0f0h,0f0h,0f8h,0f8h,078h,07ch,03ch,03ch	; 5c34  .?.|x.......x|<<
	defb 003h,0feh,083h,01fh,00fh,00fh,006h,000h,084h,03bh,03fh,03fh,03bh,005h,039h,001h	; 5c44  .........;??;.9.
	defb 0b9h,003h,000h,086h,003h,007h,007h,01fh,09fh,0dfh,005h,0c7h,082h,0c3h,0c1h,006h	; 5c54  ................
	defb 000h,08ah,0c7h,0cfh,0cfh,000h,00fh,01fh,09ch,0dfh,0cfh,0c7h,006h,000h,083h,0c3h	; 5c64  ................
	defb 0e3h,0e3h,003h,0f3h,084h,073h,0f3h,0f3h,0bbh,006h,000h,08ah,018h,0b9h,0fbh,0f3h	; 5c74  .....s..........
	defb 0c3h,083h,083h,081h,081h,080h,006h,000h,003h,0fbh,084h,0c0h,080h,080h,0c0h,003h	; 5c84  ................
	defb 0f8h,086h,000h,001h,003h,063h,0e1h,0e0h,003h,0fbh,003h,0e3h,094h,0f3h,0fbh,07bh	; 5c94  .....c.........{
	defb 03bh,000h,000h,080h,080h,000h,000h,08fh,09fh,0bfh,0bch,0b8h,0b8h,0bch,0bfh,09fh	; 5ca4  ;...............
	defb 08fh,006h,000h,003h,080h,004h,000h,003h,080h,002h,003h,002h,007h,003h,00fh,083h	; 5cb4  ................
	defb 01fh,01eh,01eh,003h,03fh,08dh,07ch,078h,0f8h,0e0h,0e0h,0f0h,0f0h,0f8h,0f8h,078h	; 5cc4  ....?.|x.......x
	defb 07ch,03ch,03ch,003h,0feh,083h,01fh,00fh,00fh,006h,000h,08bh,01eh,03fh,07fh,079h	; 5cd4  |<<..........?.y
	defb 070h,070h,078h,07fh,03fh,09eh,000h,005h,0e0h,001h,0efh,003h,0e7h,003h,0e3h,083h	; 5ce4  ppx.?...........
	defb 0e1h,0e1h,0e0h,006h,000h,08ah,01eh,01ch,0bch,0bdh,0b9h,0f9h,0f9h,0f0h,0f0h,0e0h	; 5cf4  ................
	defb 006h,000h,08ah,03ch,0feh,0eeh,0c7h,0ffh,0ffh,0c0h,0e7h,0ffh,03eh,006h,000h,084h	; 5d04  ...<........>...
	defb 076h,07fh,07fh,07bh,006h,073h,003h,000h,086h,006h,00eh,00eh,03fh,03fh,0bfh,003h	; 5d14  v..{.s......??..
	defb 08eh,084h,08fh,08fh,087h,083h,006h,000h,003h,0b9h,004h,039h,083h,0bdh,09fh,08eh	; 5d24  ...........9....
	defb 006h,000h,085h,0dch,0ddh,0dfh,0dfh,0deh,005h,0dch,006h,000h,08ah,0c3h,0cfh,0ceh	; 5d34  ................
	defb 0dch,01fh,01fh,01ch,00eh,00fh,003h,006h,000h,08ah,0c0h,0e0h,0e0h,070h,0f0h,0f0h	; 5d44  .............p..
	defb 000h,070h,0f0h,0e0h,000h,018h,0f4h,078h,0f4h,070h,0f4h,050h,0f7h,020h,074h,028h	; 5d54  .p.....x.p.P. t(
	defb 01fh,020h,060h,010h,06ah,038h,0efh,002h,01eh,006h,01fh,002h,0efh,006h,07fh,00ah	; 5d64  . `.j8..........
	defb 0e7h,00bh,0efh,006h,01fh,005h,0efh,038h,06fh,002h,016h,006h,01fh,002h,06fh,006h	; 5d74  .......8o.....o.
	defb 07fh,00ah,067h,00bh,06fh,006h,01fh,005h,06fh,008h,017h,00ah,0f1h,003h,071h,002h	; 5d84  ..g.o...o.....q.
	defb 051h,001h,041h,000h,008h,019h,000h	; 5d94  Q.A....

; ======================================================================
; CODIGO 0x5d9b..0x5dcb  (48 bytes)
; ======================================================================


L_5D9B:
	ld hl,05dcbh		;5d9b
	call L_4550		;5d9e
	ld hl,05dcdh		;5da1
	ld de,06a88h		;5da4
	call L_4558		;5da7
	call L_4550		;5daa
	ld hl,06153h		;5dad
	call L_4550		;5db0
	ld hl,0615ah		;5db3
	ld de,04a88h		;5db6
	call L_4554		;5db9
	call L_4550		;5dbc
	ld hl,06158h		;5dbf
	call L_4550		;5dc2
	ld hl,06229h		;5dc5
	jp L_4550		;5dc8

; ----------------------------------------------------------------------
; DATOS dibujos_banco1: Dibujos y colores del banco 1, comprimidos
;   0x5dcb..0x620c  (1089 bytes)
; DATOS colores_de_pista_b: LOS COLORES DE LA PISTA DEL SEGUNDO TIPO DE FASE: 29 bytes que descomprimen a 112 en la VRAM 0x0F78. Van EN PAREJA con los otros 29 de 0x61EF-0x620B -que son los del primer tipo y caen dentro del rango de arriba-, y 0x5015 elige entre las dos parejas mirando el bit 0 de la tabla de 0x5195 con la fase: o 0x5D7D y 0x61EF, o 0x5D88 y 0x620C. EL PUNTERO NO SE VE MIRANDO LAS INSTRUCCIONES DE AL LADO, y por eso el reconstructor se saltaba estos bytes: 0x5036 hace `ld de,06263h`, 0x5039 lo GUARDA EN LA PILA y quien lo usa es el `pop hl` de 0x5040, dos descompresiones despues. Es el mismo truco que la fuente en 0x5868. Cierra clavado en 0x6229, donde empieza el remate del banco 1
;   0x620c..0x6229  (29 bytes)
; DATOS dibujos_banco1_resto: El remate del banco 1
;   0x6229..0x6238  (15 bytes)
; ----------------------------------------------------------------------
	defb 080h,068h,082h,000h,0ffh,007h,000h,084h,0ffh,000h,007h,0ffh,004h,000h,0a5h,0ffh	; 5dcb  .h..............
	defb 000h,0ffh,0ffh,000h,000h,0ffh,000h,0ffh,000h,000h,0ffh,000h,0ffh,0ffh,000h,0ffh	; 5ddb  ................
	defb 000h,0ffh,0ffh,000h,0ffh,0ffh,000h,0ffh,000h,000h,0ffh,000h,000h,0ffh,000h,003h	; 5deb  ................
	defb 01fh,0ffh,015h,002h,003h,000h,003h,0ffh,082h,055h,0aah,003h,000h,003h,0ffh,089h	; 5dfb  .........U......
	defb 005h,083h,01fh,0ffh,000h,000h,0ffh,0ffh,000h,003h,0ffh,08ch,000h,000h,0ffh,0ffh	; 5e0b  ................
	defb 000h,0e0h,0ffh,0ffh,000h,000h,0ffh,0ffh,003h,000h,001h,0ffh,003h,000h,087h,0ffh	; 5e1b  ................
	defb 000h,000h,0ffh,0ffh,02ah,005h,006h,000h,089h,0aah,054h,003h,01fh,0ffh,02ah,005h	; 5e2b  ....*.....T...*.
	defb 000h,000h,004h,0ffh,085h,0aah,055h,022h,000h,000h,003h,0ffh,08bh,0aah,050h,007h	; 5e3b  ......U"......P.
	defb 000h,000h,0ffh,0ffh,0e0h,01fh,0ffh,0ffh,003h,000h,082h,0ffh,000h,003h,0ffh,003h	; 5e4b  ................
	defb 000h,089h,0ffh,0ffh,000h,0ffh,0ffh,000h,000h,00fh,001h,004h,000h,088h,017h,0ffh	; 5e5b  ................
	defb 0ffh,055h,02ah,005h,000h,000h,003h,0ffh,083h,055h,0aah,011h,005h,000h,082h,00fh	; 5e6b  .U*......U......
	defb 002h,004h,000h,088h,01fh,0ffh,0ffh,0aah,054h,003h,01fh,000h,003h,0ffh,001h,000h	; 5e7b  ........T.......
	defb 003h,0ffh,001h,000h,003h,0ffh,086h,000h,000h,0ffh,0ffh,0aah,055h,007h,000h,004h	; 5e8b  ............U...
	defb 0ffh,085h,0a8h,047h,03fh,000h,000h,003h,0ffh,088h,000h,0ffh,0ffh,000h,00fh,0ffh	; 5e9b  ...G?...........
	defb 015h,002h,004h,000h,003h,0ffh,089h,000h,0e0h,0ffh,0ffh,000h,0ffh,000h,0ffh,0ffh	; 5eab  ................
	defb 004h,000h,084h,0ffh,000h,000h,0ffh,00ah,000h,001h,0ffh,004h,000h,084h,03fh,000h	; 5ebb  ..............?.
	defb 0ffh,0ffh,003h,000h,08ah,080h,0ffh,000h,000h,0ffh,07fh,01fh,00fh,003h,001h,003h	; 5ecb  ................
	defb 000h,005h,0ffh,085h,07fh,03fh,00fh,007h,001h,006h,000h,003h,0ffh,08dh,03fh,01fh	; 5edb  .....?........?.
	defb 007h,003h,000h,0ffh,07fh,01fh,00fh,007h,001h,000h,000h,007h,0ffh,085h,07fh,01fh	; 5eeb  ................
	defb 00fh,007h,001h,004h,000h,006h,0ffh,082h,07fh,03fh,004h,0ffh,091h,01fh,007h,003h	; 5efb  .........?......
	defb 000h,007h,00fh,01fh,01fh,01fh,00fh,007h,003h,0ffh,03fh,00fh,003h,001h,003h,000h	; 5f0b  ..........?.....
	defb 084h,0ffh,07fh,01fh,00fh,004h,000h,006h,000h,002h,01fh,005h,0ffh,003h,000h,003h	; 5f1b  ................
	defb 0ffh,082h,07fh,01fh,003h,000h,003h,0ffh,005h,000h,090h,07fh,01fh,00fh,01fh,03fh	; 5f2b  ...............?
	defb 00fh,007h,001h,007h,00fh,01fh,03fh,007h,003h,000h,000h,004h,000h,002h,001h,005h	; 5f3b  ......?.........
	defb 0ffh,087h,03fh,01fh,03fh,07fh,0ffh,000h,003h,009h,000h,082h,001h,003h,003h,000h	; 5f4b  ..?.?...........
	defb 083h,001h,003h,007h,005h,000h,001h,07fh,005h,03fh,082h,01fh,00fh,006h,0ffh,006h	; 5f5b  .........?......
	defb 07fh,08ch,01fh,00fh,007h,001h,07fh,01fh,00fh,003h,001h,000h,003h,007h,003h,0ffh	; 5f6b  ................
	defb 005h,03fh,000h,090h,06ch,00bh,000h,001h,0ffh,00bh,000h,001h,003h,007h,000h,001h	; 5f7b  .?..l...........
	defb 0ffh,007h,000h,001h,0f0h,004h,000h,001h,01fh,007h,000h,001h,0ffh,004h,000h,082h	; 5f8b  ................
	defb 03fh,0ffh,006h,000h,002h,0ffh,006h,000h,082h,0fch,0ffh,005h,000h,082h,001h,00fh	; 5f9b  ?...............
	defb 006h,000h,002h,0ffh,006h,000h,082h,0f0h,0feh,006h,000h,004h,0ffh,013h,000h,001h	; 5fab  ................
	defb 00fh,007h,000h,001h,0c0h,004h,000h,001h,0f8h,003h,000h,082h,00fh,07fh,006h,000h	; 5fbb  ................
	defb 082h,080h,0f0h,009h,000h,001h,003h,007h,000h,001h,0e0h,007h,000h,001h,00fh,007h	; 5fcb  ................
	defb 000h,001h,0c0h,004h,000h,001h,07fh,003h,00fh,004h,000h,001h,0feh,003h,0f0h,01fh	; 5fdb  ................
	defb 000h,001h,001h,007h,000h,001h,080h,007h,000h,001h,007h,007h,000h,001h,0e0h,00bh	; 5feb  ................
	defb 000h,001h,0f8h,007h,000h,001h,01fh,004h,000h,001h,07fh,007h,000h,001h,0feh,009h	; 5ffb  ................
	defb 000h,002h,007h,006h,000h,085h,0e0h,0e0h,000h,01fh,01fh,006h,000h,002h,0ffh,006h	; 600b  ................
	defb 000h,002h,0f8h,005h,000h,002h,01fh,006h,000h,002h,0f8h,006h,000h,002h,0ffh,00ah	; 601b  ................
	defb 000h,001h,003h,007h,000h,001h,0c0h,003h,000h,084h,07fh,07fh,0ffh,07fh,004h,000h	; 602b  ................
	defb 084h,0feh,0feh,0ffh,0feh,004h,000h,004h,0ffh,016h,000h,002h,004h,00ah,000h,002h	; 603b  ................
	defb 030h,006h,000h,002h,003h,003h,000h,002h,0c0h,009h,000h,004h,0f0h,00ch,000h,006h	; 604b  0...............
	defb 0ffh,003h,080h,001h,0c0h,003h,00eh,002h,008h,003h,000h,002h,003h,004h,002h,002h	; 605b  ................
	defb 000h,001h,000h,003h,00fh,001h,009h,004h,000h,003h,0e0h,001h,020h,004h,000h,093h	; 606b  ............ ...
	defb 07bh,0e0h,0e4h,0e4h,0e0h,0e0h,098h,000h,0f6h,0ffh,0bfh,0bfh,0ffh,0ffh,053h,000h	; 607b  {.............S.
	defb 030h,070h,077h,00bh,0f8h,087h,0e0h,000h,026h,0eeh,0efh,0ffh,0ffh,004h,09fh,004h	; 608b  0pw.....&.......
	defb 0ffh,088h,0feh,0cch,000h,024h,0eeh,0efh,0ffh,087h,00fh,07fh,09bh,06fh,003h,001h	; 609b  .....$.......o..
	defb 000h,000h,022h,063h,063h,0f3h,0f7h,0f7h,0ffh,0ffh,0ddh,088h,000h,0dbh,0ffh,0ffh	; 60ab  .."cc...........
	defb 000h,000h,002h,063h,063h,0f3h,0f7h,0f7h,003h,0ffh,007h,0feh,009h,0ffh,082h,0c3h	; 60bb  ...cc...........
	defb 081h,003h,000h,002h,0ffh,001h,00fh,00ch,0ffh,001h,000h,003h,0ffh,085h,0f7h,0c7h	; 60cb  ................
	defb 082h,000h,000h,003h,0ffh,007h,01fh,009h,0ffh,007h,0c3h,008h,0ffh,001h,0f8h,00dh	; 60db  ................
	defb 0f7h,00bh,0fch,001h,000h,008h,0ffh,084h,07fh,022h,000h,000h,004h,0f7h,084h,077h	; 60eb  .........".....w
	defb 022h,000h,000h,002h,04fh,006h,07fh,001h,003h,015h,001h,082h,003h,00fh,004h,000h	; 60fb  "...O...........
	defb 084h,080h,0c0h,0e0h,0ffh,005h,000h,082h,00fh,0ffh,005h,000h,093h,0f8h,0e7h,04dh	; 610b  ...............M
	defb 018h,000h,000h,00fh,01fh,0fah,0ebh,0c5h,080h,000h,000h,0f0h,0fch,03fh,0dch,068h	; 611b  .............?.h
	defb 003h,000h,085h,003h,0ffh,0ffh,0b5h,016h,005h,000h,003h,01fh,001h,03fh,004h,000h	; 612b  .............?..
	defb 004h,0ffh,004h,000h,084h,0c0h,0fch,0fch,0ffh,004h,000h,084h,0ffh,0efh,0ffh,0f7h	; 613b  ................
	defb 004h,000h,084h,0ffh,0d3h,0fdh,0ceh,000h,098h,06ah,010h,000h,000h,080h,048h,078h	; 614b  .........j....Hx
	defb 0efh,078h,0efh,038h,0efh,060h,04fh,006h,04fh,082h,01fh,041h,02ch,04fh,082h,01fh	; 615b  .x.8.`O.O..A,O..
	defb 041h,00ah,04fh,018h,01fh,002h,04fh,003h,041h,00ah,04fh,001h,041h,003h,041h,00bh	; 616b  A.O...O.A.O.A.A.
	defb 04fh,002h,01fh,005h,04fh,003h,041h,000h,090h,04ch,070h,04fh,030h,04fh,020h,01fh	; 617b  O...O.A..LpO0O .
	defb 002h,04fh,002h,041h,006h,04fh,002h,041h,004h,04fh,078h,05fh,030h,05fh,001h,0efh	; 618b  .O.A.O.A.Ox_0_..
	defb 007h,05fh,001h,0efh,007h,05fh,001h,0efh,007h,05fh,04ch,03fh,004h,0efh,003h,03fh	; 619b  ._..._..._L?...?
	defb 005h,0efh,002h,03fh,006h,0efh,010h,09fh,002h,08fh,006h,089h,008h,09fh,004h,08fh	; 61ab  ...?............
	defb 00bh,089h,004h,06fh,003h,09fh,004h,097h,006h,09fh,003h,06fh,003h,09fh,00fh,096h	; 61bb  ...o.......o....
	defb 003h,09fh,007h,06fh,001h,09fh,005h,0f6h,003h,096h,007h,06eh,001h,08eh,009h,097h	; 61cb  ...o.......n....
	defb 01fh,09fh,008h,08fh,020h,097h,003h,09fh,00dh,096h,00bh,076h,00dh,09fh,003h,096h	; 61db  .... ......v....
	defb 005h,09fh,008h,096h,017h,017h,001h,01fh,008h,0f7h,007h,0f7h,001h,0f4h,005h,0f7h	; 61eb  ................
	defb 003h,0f4h,004h,0f7h,004h,0f4h,004h,0f7h,004h,0f4h,003h,0f7h,005h,0f4h,028h,0f7h	; 61fb  ..............(.
	defb 000h,017h,019h,001h,01fh,008h,0f9h,007h,0f9h,001h,0f4h,005h,0f9h,003h,0f4h,004h	; 620b  ................
	defb 0f9h,004h,0f4h,004h,0f9h,004h,0f4h,003h,0f9h,005h,0f4h,028h,0f9h,000h,098h,04ah	; 621b  ...........(...J
	defb 004h,04fh,001h,041h,003h,044h,003h,04fh,001h,041h,004h,044h,000h	; 622b  .O.A.D.O.A.D.

; ======================================================================
; CODIGO 0x6238..0x626e  (54 bytes)
; ======================================================================


L_6238:
	ld hl,0626eh		;6238
	call L_4550		;623b
	call L_4550		;623e
	ld hl,05bcfh		;6241
	call L_455D		;6244
	ld hl,06270h		;6247
	ld de,072b0h		;624a
	call L_4558		;624d
	ld hl,065feh		;6250
	call L_4550		;6253
	ld hl,06522h		;6256
	call L_4550		;6259
	call L_4550		;625c
	ld hl,06524h		;625f
	ld de,052b0h		;6262
	call L_4554		;6265
	ld hl,0665ch		;6268
	jp L_4550		;626b

; ----------------------------------------------------------------------
; DATOS dibujos_banco2: Dibujos y colores del banco 2, comprimidos
;   0x626e..0x666b  (1021 bytes)
; ----------------------------------------------------------------------
	defb 000h,072h,085h,07fh,01fh,00fh,003h,001h,003h,000h,005h,0ffh,085h,07fh,03fh,00fh	; 626e  .r............?.
	defb 007h,001h,006h,000h,003h,0ffh,08dh,03fh,01fh,007h,003h,000h,0ffh,07fh,01fh,00fh	; 627e  .......?........
	defb 007h,001h,000h,000h,007h,0ffh,085h,07fh,01fh,00fh,007h,001h,004h,000h,005h,0ffh	; 628e  ................
	defb 083h,07fh,01fh,00fh,003h,0ffh,085h,07fh,01fh,00fh,007h,001h,004h,0ffh,086h,01fh	; 629e  ................
	defb 007h,003h,000h,0ffh,07fh,006h,000h,085h,0ffh,0ffh,00fh,003h,001h,003h,000h,004h	; 62ae  ................
	defb 0ffh,004h,000h,005h,0ffh,08dh,07fh,000h,000h,001h,003h,007h,00fh,00fh,01fh,000h	; 62be  ................
	defb 000h,001h,003h,006h,000h,084h,007h,007h,00fh,01fh,005h,000h,087h,001h,003h,007h	; 62ce  ................
	defb 00fh,00fh,01fh,03fh,003h,0ffh,001h,07fh,00ah,03fh,092h,01fh,00fh,07fh,01fh,00fh	; 62de  ...?.....?......
	defb 003h,001h,000h,003h,007h,03fh,03fh,01fh,00fh,007h,001h,000h,000h,000h,060h,073h	; 62ee  .....??.......`s
	defb 003h,000h,005h,0ffh,001h,000h,007h,0ffh,002h,000h,00dh,0ffh,004h,000h,085h,003h	; 62fe  ................
	defb 000h,000h,00fh,07fh,003h,000h,086h,0f8h,000h,000h,0f0h,0ffh,001h,004h,000h,096h	; 630e  ................
	defb 001h,00fh,000h,0ffh,03fh,000h,000h,00fh,0ffh,0ffh,03fh,0ffh,0fch,0f8h,0c0h,000h	; 631e  ....?.....?.....
	defb 0f0h,0ffh,0ffh,0f0h,0c0h,080h,003h,000h,084h,0f8h,0ffh,01fh,003h,003h,000h,083h	; 632e  ................
	defb 01fh,0ffh,003h,003h,000h,085h,0e0h,000h,000h,0e0h,0feh,006h,000h,082h,080h,0f0h	; 633e  ................
	defb 003h,000h,001h,00fh,006h,000h,086h,007h,0ffh,0ffh,007h,000h,000h,003h,0ffh,087h	; 634e  ................
	defb 0fch,0f0h,0ffh,00fh,000h,0c0h,080h,003h,000h,083h,0c0h,0f0h,07fh,007h,000h,089h	; 635e  ................
	defb 0f0h,0fch,0f8h,0f0h,0c0h,000h,0fch,0ffh,007h,007h,000h,001h,0ffh,003h,000h,082h	; 636e  ................
	defb 0ffh,00fh,004h,000h,086h,00fh,07fh,0ffh,0ffh,07fh,00ch,004h,000h,002h,0ffh,003h	; 637e  ................
	defb 03fh,003h,000h,002h,0ffh,003h,0f8h,002h,0ffh,00dh,00fh,001h,000h,003h,0ffh,001h	; 638e  ?...............
	defb 0fch,00bh,0f0h,001h,0ffh,008h,007h,003h,000h,001h,00fh,004h,0ffh,001h,00fh,004h	; 639e  ................
	defb 0f7h,084h,0f0h,0c0h,000h,000h,007h,01fh,007h,00fh,001h,000h,007h,0f0h,002h,000h	; 63ae  ................
	defb 007h,0f8h,002h,0f0h,006h,0f0h,082h,000h,0c0h,006h,00fh,082h,000h,003h,006h,0f0h	; 63be  ................
	defb 082h,00fh,03fh,006h,00fh,001h,0ffh,004h,07fh,001h,00fh,005h,000h,085h,003h,003h	; 63ce  ..?.............
	defb 00fh,00fh,003h,00bh,000h,08eh,0c0h,0c0h,0f0h,0f0h,0c0h,000h,000h,001h,007h,007h	; 63de  ................
	defb 01fh,01fh,001h,0ffh,009h,000h,08ch,080h,0e0h,0e0h,0f8h,0f8h,080h,000h,000h,007h	; 63ee  ................
	defb 01fh,0f0h,0e0h,004h,000h,084h,0e0h,0f8h,01fh,007h,006h,000h,004h,00fh,085h,000h	; 63fe  ................
	defb 007h,03fh,0f8h,0c0h,004h,000h,084h,0e0h,0fch,01fh,003h,007h,000h,004h,0f0h,084h	; 640e  .?..............
	defb 0ffh,0ffh,03fh,001h,004h,000h,004h,0ffh,004h,000h,084h,0ffh,0ffh,0fch,080h,004h	; 641e  ..?.............
	defb 000h,083h,00fh,00fh,003h,005h,000h,003h,0ffh,001h,01fh,004h,000h,003h,0ffh,001h	; 642e  ................
	defb 0f8h,004h,000h,083h,0f0h,0f0h,0c0h,009h,000h,083h,00fh,07fh,0f8h,006h,0ffh,003h	; 643e  ................
	defb 000h,006h,0ffh,002h,000h,003h,0ffh,005h,000h,083h,0ffh,0ffh,03fh,005h,000h,083h	; 644e  ............?...
	defb 0ffh,0ffh,0fch,005h,000h,008h,0f0h,004h,000h,004h,0ffh,008h,00fh,006h,080h,082h	; 645e  ................
	defb 0c0h,0e0h,005h,080h,083h,0c0h,000h,000h,006h,008h,082h,00ch,00fh,005h,008h,001h	; 646e  ................
	defb 00fh,00fh,000h,09bh,00fh,000h,000h,007h,01fh,03fh,07ch,078h,0f2h,0f2h,0f0h,0e0h	; 647e  .........?|x....
	defb 0f8h,0fch,03eh,01eh,04fh,04fh,00fh,000h,000h,001h,007h,00fh,01fh,03ch,030h,005h	; 648e  ..>.OO.......<0.
	defb 0f8h,083h,0fch,0f0h,0c0h,005h,01fh,083h,03fh,00fh,003h,087h,000h,080h,0e0h,0f0h	; 649e  ........?.......
	defb 0f8h,01ch,00ch,006h,080h,00ah,000h,007h,001h,002h,000h,005h,080h,083h,0c0h,0c0h	; 64ae  ................
	defb 0e0h,005h,001h,083h,003h,003h,007h,003h,080h,098h,0c0h,040h,060h,0a0h,0e0h,030h	; 64be  ...........@`..0
	defb 03ch,01fh,00fh,007h,003h,001h,000h,000h,001h,001h,003h,007h,003h,000h,000h,070h	; 64ce  <..............p
	defb 0ffh,0e3h,003h,0ffh,085h,000h,000h,006h,0ffh,0e7h,003h,0ffh,003h,000h,088h,080h	; 64de  ................
	defb 080h,0c0h,0e0h,0c0h,000h,000h,001h,003h,000h,001h,001h,003h,000h,088h,0f0h,07fh	; 64ee  ................
	defb 033h,07fh,0ffh,0ffh,000h,000h,098h,000h,07fh,060h,060h,07eh,060h,060h,060h,000h	; 64fe  3........``~```.
	defb 063h,063h,06bh,06bh,07fh,077h,022h,000h,07fh,007h,00eh,01ch,038h,070h,07fh,006h	; 650e  cckk.w".....8p..
	defb 000h,002h,060h,000h,000h,052h,070h,04fh,020h,01fh,006h,04fh,008h,041h,008h,04fh	; 651e  ..`..RpO ..O.A.O
	defb 002h,01fh,002h,041h,006h,04fh,000h,060h,053h,026h,04fh,002h,01fh,006h,04fh,002h	; 652e  ...A.O.`S&O...O.
	defb 01fh,005h,04fh,003h,01fh,004h,04fh,004h,01fh,004h,04fh,004h,01fh,004h,04fh,004h	; 653e  ..O...O...O...O.
	defb 01fh,004h,04fh,004h,01fh,004h,04fh,054h,01fh,006h,04fh,002h,041h,006h,04fh,002h	; 654e  ..O...OT..O.A.O.
	defb 041h,003h,04fh,005h,041h,006h,041h,002h,04fh,005h,04fh,003h,041h,007h,041h,002h	; 655e  A.O.A.A.O.O.A.A.
	defb 0f4h,009h,054h,007h,01fh,004h,01dh,004h,01fh,00eh,045h,001h,04fh,007h,045h,002h	; 656e  ..T.......E.O.E.
	defb 04fh,007h,045h,002h,04fh,006h,045h,002h,05fh,006h,045h,002h,05fh,006h,045h,002h	; 657e  O.E.O.E._.E._.E.
	defb 04fh,006h,045h,005h,01dh,003h,01fh,004h,0efh,006h,05fh,002h,0feh,004h,0f5h,004h	; 658e  O.E......._.....
	defb 0efh,004h,05fh,004h,0efh,004h,05fh,003h,0feh,005h,0f5h,004h,0efh,004h,05fh,004h	; 659e  .._..._......._.
	defb 0efh,002h,0e5h,002h,0f5h,004h,0efh,002h,0e5h,002h,0f5h,006h,0efh,002h,05fh,003h	; 65ae  .............._.
	defb 0efh,002h,0e5h,003h,0f5h,003h,0efh,002h,0e5h,003h,0f5h,006h,0efh,06ah,05fh,018h	; 65be  .............j_.
	defb 03fh,017h,0efh,001h,0e1h,005h,0efh,001h,0e1h,012h,01fh,01ah,01fh,002h,016h,006h	; 65ce  ?...............
	defb 01fh,002h,016h,047h,01fh,005h,04fh,003h,01fh,005h,04fh,003h,01fh,005h,04fh,003h	; 65de  ...G..O...O...O.
	defb 01fh,005h,04fh,003h,01fh,005h,04fh,003h,01fh,005h,04fh,078h,04fh,078h,04fh,000h	; 65ee  ..O...O...OxOxO.
	defb 090h,076h,082h,002h,005h,002h,000h,006h,007h,002h,001h,006h,002h,003h,001h,003h	; 65fe  .v..............
	defb 000h,084h,027h,057h,007h,007h,006h,0ffh,082h,007h,001h,009h,000h,083h,080h,040h	; 660e  ..'W...........@
	defb 020h,004h,0ffh,002h,0feh,083h,0fch,0feh,0feh,004h,0ffh,08bh,07fh,03fh,01fh,01fh	; 661e   ............?..
	defb 00fh,007h,001h,000h,002h,004h,008h,003h,000h,003h,080h,002h,0c0h,084h,0e0h,0f0h	; 662e  ................
	defb 0f8h,0c0h,004h,000h,098h,000h,001h,001h,001h,000h,000h,000h,000h,0f8h,0f0h,0e0h	; 663e  ................
	defb 0ffh,000h,000h,000h,000h,000h,0f0h,0fch,0f8h,000h,000h,000h,000h,000h,090h,056h	; 664e  ...............V
	defb 058h,01fh,003h,0afh,001h,04fh,005h,0afh,002h,0a4h,00dh,04fh,000h	; 665e  X....O.....O.

; ======================================================================
; CODIGO 0x666b..0x6698  (45 bytes)
; ======================================================================


L_666B:
	ld hl,06698h		;666b
	jr L_6673		;666e
L_6670:
	ld hl,066d5h		;6670
L_6673:
	push hl			;6673
	ld hl,0e050h		;6674
	push hl			;6677
	ld b,080h		;6678
L_667A:
	ld (hl),000h		;667a
	inc hl			;667c
	djnz L_667A		;667d
	pop de			;667f
	pop hl			;6680
L_6681:
	ld a,(hl)		;6681
	inc hl			;6682
	or a			;6683
	jr z,L_668C		;6684
	ld c,a			;6686
	call L_45A2		;6687
	jr L_6681		;668a
L_668C:
	ld hl,0e050h		;668c
	ld de,03b00h		;668f
	ld bc,00080h		;6692
	jp L_44DE		;6695

; ----------------------------------------------------------------------
; DATOS atributos_de_partida: La lista con la que se monta la tabla de atributos durante la partida: pares (cuantos, cuatro bytes) y un cero al final. De aqui sale el color de cada sprite, que NO va en su dibujo: el pinguino negro, la foca negra y roja, el pez rojo, la sombra azul. Y AQUI ESTA EL ATRIBUTO 14, con patron 0xD4 -que dibujado es un SOL de puntas- y color amarillo, que no se ve nunca. COMPROBADO QUE ES UN SOL Y QUE SE VERIA: parcheando en una COPIA del cartucho los dos bytes de su posicion (0x66B2 y 0x66B3, la Y y la X) para sacarlo al cielo, aparece un sol amarillo de puntas sobre el azul, sin tocarle ni el dibujo ni el color. La captura y el cartucho parcheado estan fuera del repositorio, en work/, porque esto NO es una modificacion del juego sino la forma de ver lo que el juego tiene y no ensena: se monta con Y=0xE0 -fuera de la pantalla- y nadie se la cambia. MEDIDO sobre los diez minutos de partida grabada con un punto de observacion de escritura en 0xE088-0xE08B (tools/omsx_atributo14.tcl): las UNICAS cuatro cosas que lo tocan son barridos de la tabla entera -el ldir de 0x4456, el copiador de cuatro bytes de 0x45A6, BORRA_SPRITES en 0x45EE y el borrado previo de 0x667A-, y ninguna va a por el. Al acabar la partida su entrada en la VRAM sigue siendo Y=0xE0, patron 0xD4, color 0x0A: cargado, coloreado y aparcado fuera del encuadre. El control -los mismos puntos en el atributo 13- recibe ademas 4426 y 41740 escrituras de las rutinas del pinguino, asi que los ceros del 14 son datos y no instrumentacion rota. Y de propina el control mide una cosa que estaba deducida: el 13 recibe 12 escrituras MAS que el 14 desde 0x45A6, que son las tres salidas del agua por cuatro bytes, o sea la cadena que rehace los sprites parandose justo antes del 14
;   0x6698..0x66d5  (61 bytes)
; DATOS atributos_de_base: La misma lista para la escena de la base, pero de OCHO entradas en vez de treinta: 0x6674 pone los 128 bytes a cero antes de aplicarla, asi que del atributo 8 en adelante no queda nada. Cierra clavada en 0x66FF, donde vuelve a haber codigo. Sus bytes de 0x66EF los copia ademas 0x54E3. Y AQUI ESTA EL UNICO SPRITE DEL PINGUINO QUE SE GIRA Y SONRIE: el atributo 7, con el patron 0xD0 en amarillo, que es el PICO. Todo lo demas de ese pinguino -la cara, los ojos, la boca roja y hasta la sombra azul de debajo- son CASILLAS, no sprites. Comprobado a t=126,6 de la partida grabada de dos maneras: la tabla de atributos solo tiene ocho entradas puestas, y comparando el fotograma real con la pantalla pintada SOLO con casillas quedan 224 pixeles sin explicar, que son 96+72+24 de la bandera y 32 del pico. Y 32 son exactamente los bits encendidos del patron 0xD0
;   0x66d5..0x66ff  (42 bytes)
; ----------------------------------------------------------------------
	defb 00ah,0e0h,000h,07ch,000h,001h,090h,070h,000h,001h,001h,090h,080h,004h,001h,001h	; 6698  ...|...p........
	defb 0a0h,070h,008h,001h,001h,0a0h,080h,00ch,001h,001h,0e0h,000h,0d4h,00ah,001h,0e0h	; 66a8  .p..............
	defb 000h,000h,008h,001h,0e0h,000h,07ch,001h,003h,0e0h,000h,07ch,006h,001h,0aeh,070h	; 66b8  ......|....|...p
	defb 0a0h,004h,001h,0aeh,080h,0a4h,004h,008h,008h,000h,070h,000h,000h,004h,04fh,080h	; 66c8  ..........p...O.
	defb 07ch,000h,001h,052h,080h,0e8h,000h,001h,052h,080h,0ech,000h,001h,052h,080h,0e4h	; 66d8  |..R....R....R..
	defb 00fh,001h,07fh,078h,0d0h,00ah,000h,07fh,070h,0f0h,00ah,087h,078h,0f4h,00ah,077h	; 66e8  ...x....p...x..w
	defb 070h,0f8h,001h,077h,080h,0fch,001h	; 66f8  p..w...

; ======================================================================
; CODIGO 0x66ff..0x6705  (6 bytes)
; ======================================================================


L_66FF:
	ld hl,06705h		;66ff
	jp L_4550		;6702

; ----------------------------------------------------------------------
; DATOS sprites_comprimidos: Los patrones de sprite: los pinguinos, los peces y las focas
;   0x6705..0x6b92  (1165 bytes)
; DATOS trozos_de_pista: Los 92 trozos incrementales de la pista, en el mismo formato que los decorados: cada uno pone entre una y seis casillas, o sea que son INCREMENTOS y no pantallas enteras. Se consumen en cadena, uno por paso, y asi va creciendo lo que se acerca. Los siete obstaculos de 0x5277 empiezan cada uno en uno de estos trozos
;   0x6b92..0x71ea  (1624 bytes)
; DATOS arbol_de_decorados: Cuatro punteros en 0x71EA llevan a cuatro grupos, cada uno con otros cuatro, y los dieciseis bloques de abajo embaldosan 0x72D6-0x74C1 sin dejar hueco. Pasados por el interprete de 0x4525 dibujan los bordes de la pista
;   0x71ea..0x74c2  (728 bytes)
; ----------------------------------------------------------------------
	defb 000h,058h,00dh,000h,083h,003h,00fh,01fh,003h,000h,08ah,003h,00fh,01bh,037h,06fh	; 6705  .X............7o
	defb 05fh,0ffh,0ffh,0bfh,0bfh,003h,0ffh,003h,000h,086h,0c0h,0f0h,0f8h,0fch,0feh,0feh	; 6715  _...............
	defb 007h,0ffh,00dh,000h,086h,0c0h,0e0h,0f0h,03fh,070h,060h,007h,001h,003h,000h,083h	; 6725  ........?p`.....
	defb 003h,003h,000h,00ch,0ffh,084h,07fh,0ffh,0e3h,001h,00ch,0ffh,087h,0feh,0ffh,0c7h	; 6735  ................
	defb 080h,0f8h,018h,008h,006h,080h,004h,000h,082h,0c0h,0c0h,00bh,000h,005h,001h,001h	; 6745  ................
	defb 003h,003h,000h,08ah,007h,01fh,037h,06fh,0dfh,0bfh,0ffh,0ffh,0bfh,0bfh,003h,0ffh	; 6755  ......7o........
	defb 003h,000h,085h,0c0h,0f0h,0f8h,0fch,0fch,003h,0feh,005h,0ffh,00ch,000h,08bh,0e0h	; 6765  ................
	defb 0f0h,0f8h,0f8h,007h,00fh,01fh,03eh,038h,030h,020h,009h,000h,008h,0ffh,088h,07fh	; 6775  ......>80 ......
	defb 07fh,03fh,01fh,07fh,077h,000h,000h,00dh,0ffh,086h,0fdh,039h,008h,00ch,000h,000h	; 6785  .?..w......9....
	defb 007h,080h,086h,000h,0c0h,0e0h,0a0h,0e0h,0e0h,00ch,000h,084h,007h,01fh,03fh,07fh	; 6795  ..............?.
	defb 003h,000h,08ah,003h,00fh,01bh,037h,02fh,06fh,07fh,07fh,0dfh,0bfh,003h,0ffh,003h	; 67a5  ......7/o.......
	defb 000h,084h,0e0h,0f8h,0fch,0feh,009h,0ffh,00ah,000h,006h,080h,083h,060h,000h,000h	; 67b5  .............`..
	defb 007h,001h,086h,000h,003h,007h,005h,007h,007h,00dh,0ffh,083h,0bfh,09ch,010h,008h	; 67c5  ................
	defb 0ffh,08fh,0feh,0feh,0fch,0f8h,0feh,0eeh,000h,000h,0e0h,0f0h,0f8h,038h,01ch,00ch	; 67d5  .............8..
	defb 004h,009h,000h,083h,03fh,070h,060h,005h,001h,085h,002h,006h,007h,007h,003h,003h	; 67e5  ....?p`.........
	defb 000h,00ch,0ffh,084h,03fh,00fh,001h,000h,00ch,0ffh,087h,0feh,0f8h,0e0h,080h,0f8h	; 67f5  ....?...........
	defb 018h,008h,005h,080h,085h,040h,060h,0e0h,0e0h,0c0h,00dh,000h,086h,020h,030h,018h	; 6805  .....@`...... 0.
	defb 01fh,00fh,007h,003h,000h,08ah,003h,00fh,01bh,037h,06fh,05fh,0ffh,0ffh,0bfh,0bfh	; 6815  .........7o_....
	defb 003h,0ffh,003h,000h,086h,0c0h,0f0h,0f8h,0fch,0feh,0feh,007h,0ffh,00ah,000h,089h	; 6825  ................
	defb 004h,00ch,01ch,0f8h,0f0h,0e0h,003h,000h,000h,005h,001h,085h,002h,006h,007h,007h	; 6835  ................
	defb 003h,003h,000h,00ch,0ffh,084h,07fh,01fh,007h,001h,00ch,0ffh,087h,0fch,0f0h,080h	; 6845  ................
	defb 000h,0c0h,000h,000h,005h,080h,085h,040h,060h,0e0h,0e0h,0c0h,006h,000h,084h,0e0h	; 6855  .......@`.......
	defb 0f8h,0fch,0feh,009h,0ffh,009h,000h,005h,080h,083h,0e0h,0f0h,060h,003h,001h,00ch	; 6865  ............`...
	defb 000h,006h,0ffh,08ah,07fh,07fh,03fh,03fh,01fh,01fh,00eh,00ch,008h,000h,007h,0ffh	; 6875  ......??........
	defb 084h,0feh,0feh,0fch,0b8h,005h,000h,083h,0f8h,0fch,00ch,016h,000h,005h,001h,082h	; 6885  ................
	defb 007h,00fh,003h,000h,08ah,007h,01fh,037h,06fh,0dfh,0bfh,0ffh,0ffh,0bfh,0bfh,003h	; 6895  .......7o.......
	defb 0ffh,083h,01fh,03fh,030h,00dh,000h,007h,0ffh,085h,07fh,07fh,03fh,01bh,001h,004h	; 68a5  ...?0.......?...
	defb 000h,006h,0ffh,08bh,0feh,0feh,0fch,0fch,0f8h,0f8h,0f0h,030h,010h,000h,00ch,003h	; 68b5  ...........0....
	defb 080h,018h,000h,084h,01eh,03fh,03fh,003h,003h,000h,089h,003h,00fh,01bh,037h,06fh	; 68c5  .....??.......7o
	defb 05fh,0ffh,0dfh,0dfh,004h,0ffh,003h,000h,086h,0c0h,0f0h,0f8h,0fch,0feh,0feh,007h	; 68d5  _...............
	defb 0ffh,00ch,000h,085h,078h,0fch,0fch,0c0h,001h,00fh,000h,008h,0ffh,082h,05fh,00fh	; 68e5  ....x........._.
	defb 003h,007h,083h,003h,001h,001h,008h,0ffh,082h,0fah,0f0h,003h,0e0h,084h,080h,000h	; 68f5  ................
	defb 000h,080h,017h,000h,086h,020h,070h,0d8h,0f8h,0f8h,070h,00ah,000h,086h,004h,00eh	; 6905  ..... p...p.....
	defb 01bh,01fh,01fh,00eh,005h,000h,004h,078h,001h,038h,012h,000h,086h,004h,00eh,01bh	; 6915  .......x.8......
	defb 01fh,01fh,00eh,00ah,000h,086h,020h,070h,0d8h,0f8h,0f8h,070h,003h,000h,004h,00fh	; 6925  ...... p...p....
	defb 001h,00eh,02dh,000h,083h,003h,001h,001h,00eh,000h,085h,080h,080h,0a0h,0c0h,020h	; 6935  ..-............ 
	defb 009h,000h,088h,003h,007h,001h,000h,000h,001h,000h,001h,008h,000h,087h,080h,0c0h	; 6945  ................
	defb 0e0h,0e0h,060h,060h,0c0h,008h,000h,086h,007h,01fh,037h,07fh,03fh,00ch,00ah,000h	; 6955  ..``......7.?...
	defb 001h,080h,003h,0e0h,087h,0f0h,070h,030h,018h,01ch,010h,010h,004h,000h,089h,030h	; 6965  ......p0.......0
	defb 038h,03ch,03fh,01fh,03fh,02fh,027h,003h,00ah,000h,086h,080h,008h,088h,0feh,0f0h	; 6975  8<?.?/'.........
	defb 080h,00bh,000h,085h,001h,001h,005h,003h,004h,00ah,000h,083h,0c0h,080h,080h,00ch	; 6985  ................
	defb 000h,087h,001h,003h,007h,007h,006h,006h,003h,009h,000h,088h,0c0h,0e0h,080h,000h	; 6995  ................
	defb 000h,080h,000h,080h,007h,000h,001h,001h,003h,007h,087h,00fh,00eh,00ch,018h,038h	; 69a5  ...............8
	defb 008h,008h,005h,000h,086h,0e0h,0f8h,0ech,0feh,0fch,030h,00ch,000h,086h,001h,080h	; 69b5  ..........0.....
	defb 081h,07fh,00fh,001h,007h,000h,089h,00ch,01ch,03ch,0fch,0f8h,0fch,0f4h,0e4h,0c0h	; 69c5  .........<......
	defb 006h,000h,082h,007h,007h,00dh,000h,001h,07fh,003h,0ffh,00ch,000h,001h,0feh,003h	; 69d5  ................
	defb 0ffh,00dh,000h,082h,0e0h,0e0h,010h,000h,087h,0c0h,0f0h,0f8h,0fch,0fch,0feh,0feh	; 69e5  ................
	defb 006h,0ffh,007h,000h,089h,00ch,01ch,03ch,0f8h,0f8h,0f0h,0c0h,000h,080h,00bh,0ffh	; 69f5  .......<........
	defb 085h,0feh,0fch,0fch,038h,008h,006h,080h,084h,0b8h,0f8h,0f0h,0e0h,00dh,000h,089h	; 6a05  ....8...........
	defb 030h,038h,03ch,01fh,01fh,00fh,003h,000h,001h,003h,000h,088h,003h,00fh,01bh,037h	; 6a15  08<............7
	defb 02fh,07fh,05fh,0dfh,005h,0ffh,006h,001h,084h,01dh,01fh,00fh,007h,006h,000h,00bh	; 6a25  /._.............
	defb 0ffh,085h,07fh,03fh,03fh,01ch,010h,006h,000h,088h,006h,000h,020h,013h,029h,001h	; 6a35  ...??....... .).
	defb 009h,006h,008h,000h,088h,060h,000h,004h,0c8h,094h,080h,090h,060h,004h,000h,085h	; 6a45  .....`......`...
	defb 003h,00fh,01fh,03fh,03fh,009h,07fh,087h,000h,000h,0c0h,0f0h,0f8h,0fch,0fch,009h	; 6a55  ...??...........
	defb 0feh,008h,000h,088h,006h,00ch,020h,013h,029h,011h,029h,006h,008h,000h,08fh,060h	; 6a65  ...... .).)....`
	defb 030h,004h,0c8h,094h,088h,094h,060h,001h,001h,003h,00dh,01eh,03fh,03fh,003h,07fh	; 6a75  0.....`.....??..
	defb 003h,0feh,084h,0fch,0f0h,060h,07fh,00bh,0ffh,081h,03fh,006h,000h,085h,003h,00fh	; 6a85  .....`....?.....
	defb 03fh,07fh,07fh,008h,0ffh,003h,000h,085h,0c0h,0f0h,0fch,0feh,0feh,008h,0ffh,081h	; 6a95  ?...............
	defb 0feh,00bh,0ffh,081h,0fch,003h,000h,087h,080h,080h,0c0h,0b0h,078h,0fch,0fch,003h	; 6aa5  ............x...
	defb 0feh,003h,07fh,083h,03fh,00fh,006h,008h,000h,086h,003h,00fh,038h,00ch,007h,003h	; 6ab5  ....?.......8...
	defb 00ah,000h,086h,0c0h,0f0h,01ch,030h,0e0h,0c0h,007h,000h,08bh,004h,004h,0cch,0dfh	; 6ac5  ......0.........
	defb 07fh,03fh,07fh,0ffh,03fh,00dh,010h,007h,000h,089h,040h,0c0h,080h,080h,0c0h,0e0h	; 6ad5  .?..?.....@.....
	defb 0f0h,080h,080h,00bh,000h,085h,01fh,0ffh,07fh,03fh,003h,00bh,000h,085h,0c0h,0f0h	; 6ae5  .........?......
	defb 0ffh,0feh,0f0h,00ch,000h,084h,00fh,03fh,01fh,007h,00dh,000h,083h,0f0h,0fch,0c0h	; 6af5  .......?........
	defb 00dh,000h,083h,007h,00fh,007h,00dh,000h,083h,080h,0f0h,000h,00ch,0ffh,004h,000h	; 6b05  ................
	defb 00ch,0ffh,004h,000h,006h,000h,084h,003h,00fh,01fh,01fh,00ch,000h,084h,0c0h,0f0h	; 6b15  ................
	defb 0f8h,0f8h,006h,000h,000h,080h,05fh,004h,000h,086h,00fh,01fh,01bh,01dh,01ch,00fh	; 6b25  ......_.........
	defb 00ah,000h,086h,0f0h,0f8h,0dch,0beh,07ch,0f0h,006h,000h,00bh,000h,084h,003h,007h	; 6b35  .......|........
	defb 007h,003h,00ch,000h,085h,0c0h,0c0h,0c0h,080h,000h,0a0h,000h,038h,03ch,00fh,00fh	; 6b45  ............8<..
	defb 006h,004h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0feh,0ffh,0ffh	; 6b55  ................
	defb 01fh,00fh,007h,000h,000h,000h,000h,000h,000h,000h,000h,0a0h,000h,000h,000h,080h	; 6b65  ................
	defb 0c1h,0c3h,0e7h,0efh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,080h	; 6b75  ................
	defb 080h,080h,080h,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,041h,0efh	; 6b85  ..............A.
	defb 093h,000h,041h,0eeh,0a1h,095h,0a2h,000h,041h,0eeh,00fh,00fh,00fh,0eeh,098h,098h	; 6b95  ..A.....A.......
	defb 0a3h,000h,061h,0eeh,00fh,00fh,00fh,0edh,099h,09ah,09ah,09bh,000h,081h,0edh,00fh	; 6ba5  ..a.............
	defb 00fh,00fh,00fh,0ech,0a4h,09dh,09dh,09dh,09dh,0a5h,000h,0a1h,0ech,00fh,00fh,00fh	; 6bb5  ................
	defb 00fh,00fh,00fh,0eah,0a8h,0aah,09fh,09fh,09fh,09fh,09fh,0abh,0a7h,000h,0c1h,0eah	; 6bc5  ................
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e9h,070h,082h,06ch,06ch,06ch,06ch	; 6bd5  ..........p.llll
	defb 06ch,06ch,083h,071h,000h,0e1h,0e9h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6be5  ll.q............
	defb 00fh,0e8h,0e7h,072h,073h,084h,08bh,06dh,06dh,06dh,06dh,06dh,06dh,08eh,086h,075h	; 6bf5  ...rs..mmmmmm..u
	defb 000h,022h,0e7h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6c05  ."..............
	defb 0e6h,072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h	; 6c15  .rs..nnnnnnn..tx
	defb 0e5h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh	; 6c25  .yz...ooooooo.o{
	defb 07ch,07dh,000h,042h,0e6h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6c35  |}.B............
	defb 00fh,00fh,00fh,00fh,0e5h,072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh	; 6c45  .....rs..nnnnnnn
	defb 06eh,06eh,092h,086h,075h,00fh,0e4h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh	; 6c55  nn..u..yz...oooo
	defb 06fh,06fh,06fh,06fh,06fh,08ch,087h,07eh,07fh,000h,062h,0e5h,00fh,00fh,00fh,00fh	; 6c65  ooooo..~..b.....
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e4h,072h,073h,084h	; 6c75  .............rs.
	defb 090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h,0e3h	; 6c85  .nnnnnnnnnn..tx.
	defb 079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh	; 6c95  yz...oooooooooo.
	defb 06fh,07bh,07ch,07dh,000h,082h,0e4h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6ca5  o{|}............
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e3h,072h,073h,084h,090h,06eh,06eh	; 6cb5  ..........rs..nn
	defb 06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,092h,086h,075h,00fh,0e2h,079h	; 6cc5  nnnnnnnnnn..u..y
	defb 07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh	; 6cd5  z...oooooooooooo
	defb 08ch,087h,07eh,07fh,000h,0a2h,0e3h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6ce5  ..~.............
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e2h,072h,073h,084h,090h,06eh	; 6cf5  ...........rs..n
	defb 06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h	; 6d05  nnnnnnnnnnnn..tx
	defb 000h,0c2h,0e2h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6d15  ................
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0f0h,093h,000h,041h,0efh	; 6d25  ..........A...A.
	defb 094h,095h,096h,000h,041h,0efh,00fh,00fh,00fh,0efh,097h,098h,098h,000h,061h,0efh	; 6d35  ....A.........a.
	defb 00fh,00fh,00fh,0efh,099h,09ah,09ah,09bh,000h,081h,0efh,00fh,00fh,00fh,00fh,0eeh	; 6d45  ................
	defb 09ch,09dh,09dh,09dh,09dh,09eh,000h,0a1h,0eeh,00fh,00fh,00fh,00fh,00fh,00fh,0edh	; 6d55  ................
	defb 0a6h,0aah,09fh,09fh,09fh,09fh,09fh,0abh,0a7h,000h,0c1h,0edh,00fh,00fh,00fh,00fh	; 6d65  ................
	defb 00fh,00fh,00fh,00fh,00fh,0edh,070h,082h,06ch,06ch,06ch,06ch,06ch,06ch,083h,077h	; 6d75  ......p.llllll.w
	defb 000h,0e1h,0edh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0edh,0ech,076h	; 6d85  ...............v
	defb 089h,088h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,08eh,086h,075h,000h,022h,0ech,00fh	; 6d95  ..mmmmmmm..u."..
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0ech,076h,089h,08fh	; 6da5  .............v..
	defb 06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h,0ebh,080h,081h,093h,085h	; 6db5  nnnnnnn..tx.....
	defb 06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,042h,0ech,00fh	; 6dc5  ooooooo.o{|}.B..
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0ebh,072h,073h	; 6dd5  ..............rs
	defb 084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h,0eah,079h	; 6de5  ..nnnnnnnn..tx.y
	defb 07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch	; 6df5  z...oooooooo.o{|
	defb 07dh,000h,062h,0ebh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6e05  }.b.............
	defb 00fh,00fh,00fh,00fh,0eah,00fh,076h,089h,08fh,06eh,06eh,06eh,06eh,06eh,06eh,06eh	; 6e15  ......v..nnnnnnn
	defb 06eh,06eh,06eh,091h,004h,074h,078h,0eah,080h,081h,093h,08dh,06fh,06fh,06fh,06fh	; 6e25  nnn..tx.....oooo
	defb 06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,082h,0ebh,00fh,00fh	; 6e35  oooooo.o{|}.....
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0eah	; 6e45  ................
	defb 072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h	; 6e55  rs..nnnnnnnnnnn.
	defb 004h,074h,078h,0e9h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh	; 6e65  .tx.yz...ooooooo
	defb 06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,0a2h,0eah,00fh,00fh,00fh,00fh	; 6e75  oooo.o{|}.......
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e9h	; 6e85  ................
	defb 00fh,076h,089h,08fh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh	; 6e95  .v..nnnnnnnnnnnn
	defb 06eh,091h,004h,077h,078h,000h,0c2h,0eah,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6ea5  n..wx...........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0efh	; 6eb5  ..............A.
	defb 0afh,0b0h,000h,041h,0efh,094h,0a2h,000h,041h,0efh,00fh,00fh,0efh,0bfh,0c0h,000h	; 6ec5  ...A....A.......
	defb 061h,0efh,00fh,00fh,0efh,0b7h,0b8h,000h,081h,0efh,00fh,00fh,0efh,0bch,0bdh,000h	; 6ed5  a...............
	defb 0a1h,0efh,00fh,00fh,0efh,0c1h,0c2h,000h,0c1h,0efh,00fh,00fh,0eeh,094h,095h,095h	; 6ee5  ................
	defb 096h,000h,0e1h,0eeh,00fh,00fh,00fh,00fh,0ffh,0eeh,097h,098h,098h,099h,000h,022h	; 6ef5  ..............."
	defb 0eeh,00fh,00fh,00fh,00fh,0eeh,09ah,098h,098h,09bh,0eeh,0abh,0aah,0aah,0ach,000h	; 6f05  ................
	defb 042h,0eeh,00fh,00fh,00fh,00fh,0edh,09ch,09dh,098h,098h,09eh,09fh,0edh,0a3h,0a4h	; 6f15  B...............
	defb 0a1h,0a1h,0a5h,0a6h,000h,062h,0edh,00fh,00fh,00fh,00fh,00fh,00fh,0edh,09ah,098h	; 6f25  .....b..........
	defb 098h,098h,098h,09bh,0edh,0abh,0a1h,0a8h,0a8h,0a1h,0ach,000h,082h,0edh,00fh,00fh	; 6f35  ................
	defb 00fh,00fh,00fh,00fh,0ech,09ch,09dh,098h,098h,098h,098h,09eh,09fh,0ech,0a3h,0a4h	; 6f45  ................
	defb 0a8h,0a9h,0a9h,0a9h,0a5h,0a6h,000h,0a2h,0ech,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6f55  ................
	defb 00fh,0ech,09ah,098h,098h,098h,098h,098h,098h,09bh,000h,0c2h,0ech,00fh,00fh,00fh	; 6f65  ................
	defb 00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0efh,0b2h,000h,041h,0eeh,0b4h,00fh,000h	; 6f75  .......A...A....
	defb 041h,0eeh,00fh,0edh,0bfh,0b6h,000h,061h,0edh,00fh,00fh,0edh,0bah,0bbh,000h,081h	; 6f85  A......a........
	defb 0edh,00fh,00fh,0ech,0beh,0beh,000h,0a1h,0ech,00fh,00fh,0ebh,0c1h,0c3h,0c2h,000h	; 6f95  ................
	defb 0c1h,0ebh,00fh,00fh,00fh,0e9h,094h,095h,095h,095h,096h,000h,0e1h,0e9h,00fh,00fh	; 6fa5  ................
	defb 00fh,00fh,00fh,0ffh,0e8h,097h,098h,098h,098h,099h,000h,022h,0e8h,00fh,00fh,00fh	; 6fb5  ..........."....
	defb 00fh,00fh,0e7h,09ah,098h,098h,098h,09bh,0e7h,0abh,0aah,0aah,0aah,0ach,000h,042h	; 6fc5  ...............B
	defb 0e7h,00fh,00fh,00fh,00fh,00fh,0e6h,09ah,098h,098h,098h,09eh,09fh,0e6h,0a0h,0a1h	; 6fd5  ................
	defb 0a1h,0a1h,0a5h,0a6h,000h,062h,0e6h,00fh,00fh,00fh,00fh,00fh,00fh,0e5h,09ah,098h	; 6fe5  .....b..........
	defb 098h,098h,098h,09bh,00fh,0e5h,0a0h,0a1h,0a8h,0a8h,0a1h,0a2h,000h,082h,0e5h,00fh	; 6ff5  ................
	defb 00fh,00fh,00fh,00fh,00fh,0e4h,09ah,098h,098h,098h,098h,09eh,09fh,0e4h,0a0h,0a1h	; 7005  ................
	defb 0a8h,0a8h,0a1h,0a2h,0a6h,000h,0a2h,0e4h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e3h	; 7015  ................
	defb 09ah,098h,098h,098h,098h,098h,098h,09bh,00fh,000h,0c2h,0e3h,00fh,00fh,00fh,00fh	; 7025  ................
	defb 00fh,00fh,00fh,00fh,000h,000h,041h,0f0h,0b1h,000h,041h,0f0h,00fh,0b3h,000h,041h	; 7035  ......A...A....A
	defb 0f1h,00fh,0f1h,0b5h,0c0h,000h,061h,0f1h,00fh,00fh,0f1h,0b9h,0bah,000h,081h,0f1h	; 7045  ......a.........
	defb 00fh,00fh,0f2h,0beh,0beh,000h,0a1h,0f2h,00fh,00fh,0f2h,0c1h,0c3h,0c2h,000h,0c1h	; 7055  ................
	defb 0f2h,00fh,00fh,00fh,0f2h,094h,095h,095h,095h,096h,000h,0e1h,0f2h,00fh,00fh,00fh	; 7065  ................
	defb 00fh,00fh,0ffh,0f3h,097h,098h,098h,098h,099h,000h,022h,0f3h,00fh,00fh,00fh,00fh	; 7075  ..........".....
	defb 00fh,0f4h,09ah,098h,098h,098h,09bh,0f4h,0abh,0aah,0aah,0aah,0ach,000h,042h,0f4h	; 7085  ..............B.
	defb 00fh,00fh,00fh,00fh,00fh,0f4h,09ch,09dh,098h,098h,098h,09eh,0f4h,0a3h,0a4h,0a1h	; 7095  ................
	defb 0a1h,0a1h,0a2h,000h,062h,0f4h,00fh,00fh,00fh,00fh,00fh,00fh,0f4h,00fh,09ah,098h	; 70a5  ....b...........
	defb 098h,098h,098h,09bh,0f5h,0a0h,0a1h,0a8h,0a8h,0a1h,0a2h,000h,082h,0f5h,00fh,00fh	; 70b5  ................
	defb 00fh,00fh,00fh,00fh,0f5h,09ch,09dh,098h,098h,098h,098h,09eh,0f5h,0a3h,0a4h,0a8h	; 70c5  ................
	defb 0a9h,0a8h,0a1h,0a2h,000h,0a2h,0f5h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0f5h,00fh	; 70d5  ................
	defb 09ah,098h,098h,098h,098h,098h,098h,09bh,000h,0c2h,0f6h,00fh,00fh,00fh,00fh,00fh	; 70e5  ................
	defb 00fh,00fh,00fh,000h,000h,000h,041h,0efh,0c6h,000h,041h,0efh,0c7h,000h,041h,0efh	; 70f5  ......A...A...A.
	defb 00fh,0efh,0c9h,000h,061h,0efh,00fh,0eeh,0ceh,000h,081h,0edh,0c8h,0cah,0edh,0cfh	; 7105  ....a...........
	defb 0cbh,000h,081h,0edh,00fh,00fh,0edh,0cch,00fh,0ech,0a1h,0cdh,000h,0a1h,0edh,00fh	; 7115  ................
	defb 0ech,00fh,00fh,0ech,003h,0adh,0ebh,0b5h,0b1h,000h,0e1h,0ech,00fh,00fh,0ebh,0aeh	; 7125  ................
	defb 0aeh,0ebh,003h,003h,0eah,07fh,0b0h,000h,000h,002h,0ebh,00fh,00fh,0ebh,00fh,00fh	; 7135  ................
	defb 0e9h,0afh,003h,003h,0e9h,0afh,003h,003h,0e8h,07fh,0b2h,000h,000h,042h,0e9h,00fh	; 7145  .............B..
	defb 00fh,00fh,0e9h,00fh,00fh,00fh,0e8h,00fh,00fh,0e5h,003h,003h,003h,0e5h,003h,003h	; 7155  ................
	defb 003h,000h,0a2h,0e5h,00fh,00fh,00fh,0e5h,00fh,00fh,00fh,000h,000h,000h,041h,0f0h	; 7165  ..............A.
	defb 0c6h,000h,041h,0f0h,0c8h,000h,041h,0f0h,00fh,0f1h,0c9h,000h,061h,0f1h,00fh,0f1h	; 7175  ..A...A.....a...
	defb 0ceh,000h,081h,0f1h,0c8h,0cah,0f1h,0cfh,0cbh,000h,081h,0f1h,00fh,00fh,0f1h,00fh	; 7185  ................
	defb 0cch,0f1h,0a1h,0cdh,000h,0a1h,0f2h,00fh,0f1h,00fh,00fh,0f2h,0afh,003h,0f2h,0b2h	; 7195  ................
	defb 000h,0e1h,0f2h,00fh,00fh,0f2h,00fh,0aeh,0aeh,0f3h,003h,003h,0f2h,07fh,0b0h,000h	; 71a5  ................
	defb 000h,002h,0f3h,00fh,00fh,0f3h,00fh,00fh,0f2h,00fh,0afh,003h,003h,0f3h,0afh,003h	; 71b5  ................
	defb 003h,0f2h,07fh,0b2h,000h,000h,042h,0f3h,00fh,00fh,00fh,0f3h,00fh,00fh,00fh,0f2h	; 71c5  ......B.........
	defb 00fh,00fh,0f8h,003h,003h,003h,0f8h,003h,003h,003h,000h,0a2h,0f8h,00fh,00fh,00fh	; 71d5  ................
	defb 0f8h,00fh,00fh,00fh,000h,0f2h,071h,02fh,072h,06ch,072h,0a1h,072h,0d6h,072h,0feh	; 71e5  ......q/rlr.r.r.
	defb 072h,016h,073h,037h,073h,00fh,00fh,051h,00eh,072h,00dh,093h,00bh,0b5h,00ah,0d6h	; 71f5  r.s7s..Q.r......
	defb 009h,0f7h,008h,018h,006h,03ah,005h,05bh,003h,07dh,002h,09eh,001h,0bfh,000h,051h	; 7205  .....:.[.}.....Q
	defb 039h,00fh,010h,011h,012h,013h,014h,015h,0ffh,060h,000h,000h,000h,0f3h,0f4h,0f3h	; 7215  9........`......
	defb 0f7h,0f5h,0f6h,0f4h,0f3h,0f7h,0f5h,0f6h,000h,000h,04fh,073h,077h,073h,08fh,073h	; 7225  ..........Osws.s
	defb 0b0h,073h,00fh,00fh,040h,00eh,060h,00dh,080h,00bh,0a0h,00ah,0c0h,009h,0e0h,008h	; 7235  .s..@.`.........
	defb 000h,006h,020h,005h,040h,003h,060h,002h,080h,001h,0a0h,000h,048h,039h,015h,014h	; 7245  .. .@.`.....H9..
	defb 013h,012h,052h,010h,00fh,0ffh,050h,0f3h,0f5h,0f6h,0f4h,0f5h,0f7h,0f6h,0f4h,0f4h	; 7255  ..R...P.........
	defb 0f3h,0f5h,0f6h,0f4h,0f5h,0f6h,000h,0c8h,073h,0e9h,073h,00ah,074h,028h,074h,004h	; 7265  ........s.s.t(t.
	defb 00dh,053h,00ch,074h,00ah,096h,009h,0b7h,007h,0d9h,006h,0fah,005h,01bh,003h,03dh	; 7275  .S.t...........=
	defb 000h,051h,039h,039h,03ch,0feh,072h,039h,037h,038h,0ffh,060h,000h,000h,000h,000h	; 7285  .Q99<.r978.`....
	defb 0f8h,0fch,0f9h,0fbh,0fch,0f9h,0f9h,0f9h,0fbh,0fah,000h,000h,045h,074h,066h,074h	; 7295  ............Etft
	defb 087h,074h,0a5h,074h,004h,00dh,040h,00ch,060h,00ah,080h,009h,0a0h,007h,0c0h,006h	; 72a5  .t.t..@.`.......
	defb 0e0h,005h,000h,003h,020h,000h,04dh,039h,07dh,07ah,0feh,06ch,039h,079h,078h,0ffh	; 72b5  .... .M9}z.l9yx.
	defb 050h,000h,000h,000h,0f8h,0fbh,0f9h,0fch,0fbh,0f9h,0fbh,0fch,0fah,000h,000h,000h	; 72c5  P...............
	defb 000h,021h,0f8h,013h,015h,012h,012h,012h,014h,014h,014h,0f5h,016h,017h,018h,019h	; 72d5  .!..............
	defb 019h,01ah,01bh,01ch,01ch,01ch,01ch,0f7h,01dh,01eh,01fh,01fh,01fh,020h,021h,022h	; 72e5  ............. !"
	defb 023h,0fah,00fh,024h,025h,026h,026h,026h,000h,021h,0fah,015h,0f5h,027h,028h,029h	; 72f5  #..$%&&&.!...'()
	defb 029h,019h,02ah,0f7h,02bh,02bh,01eh,01fh,028h,029h,019h,02dh,0fah,02eh,026h,026h	; 7305  ).*.++..().-..&&
	defb 000h,021h,0f8h,015h,015h,015h,012h,012h,012h,0f5h,016h,017h,018h,019h,019h,02fh	; 7315  .!............./
	defb 01bh,01ch,022h,022h,0f7h,01dh,01eh,01fh,01fh,01fh,020h,021h,022h,0fah,00fh,024h	; 7325  ..""...... !"..$
	defb 025h,000h,021h,0fah,012h,0f5h,027h,028h,029h,029h,019h,02dh,0f7h,02bh,02bh,01eh	; 7335  %.!...'()).-.++.
	defb 01fh,02ch,029h,019h,02dh,0fah,02eh,026h,026h,000h,021h,0e0h,014h,014h,014h,012h	; 7345  .,).-..&&.!.....
	defb 012h,012h,015h,013h,0e0h,05dh,05dh,05dh,05dh,05ch,05bh,05ah,05ah,059h,058h,057h	; 7355  .....]]]]\[ZZYXW
	defb 0e0h,064h,063h,062h,061h,060h,060h,060h,05fh,05eh,0e0h,067h,067h,067h,066h,065h	; 7365  .dcba```_^.gggfe
	defb 00fh,000h,021h,0e5h,014h,0e5h,06bh,05ah,06ah,06ah,069h,068h,0e1h,06eh,05ah,06ah	; 7375  ..!...kZjjih.nZj
	defb 069h,060h,05fh,06ch,06ch,0e3h,067h,067h,06fh,000h,021h,0e2h,012h,012h,012h,015h	; 7385  i`_ll.ggo.!.....
	defb 015h,015h,0e1h,063h,063h,05dh,05ch,070h,05ah,05ah,059h,058h,057h,0e1h,063h,062h	; 7395  ...cc]\pZZYXW.cb
	defb 061h,060h,060h,060h,05fh,05eh,0e3h,066h,065h,00fh,000h,021h,0e5h,012h,0e5h,06eh	; 73a5  a```_^.fe..!...n
	defb 05ah,06ah,06ah,069h,068h,0e1h,06eh,05ah,06ah,06dh,060h,05fh,06ch,06ch,0e3h,067h	; 73b5  Zjjih.nZjm`_ll.g
	defb 067h,06fh,000h,061h,0f3h,049h,043h,036h,0f5h,037h,048h,0f6h,03bh,042h,036h,0f8h	; 73c5  go.a.IC6.7H.;B6.
	defb 037h,038h,0f8h,00fh,00fh,054h,0fah,050h,047h,004h,0fbh,042h,048h,004h,004h,004h	; 73d5  78...T.PG..BH...
	defb 0feh,042h,043h,000h,061h,0f3h,00fh,045h,004h,0f6h,038h,0f6h,04ah,04ch,004h,0f7h	; 73e5  .BC.a..E..8.JL..
	defb 037h,044h,038h,0fah,040h,041h,0fah,00fh,042h,043h,0fbh,00fh,051h,0fdh,044h,045h	; 73f5  7D8.@A..BC..Q.DE
	defb 004h,0feh,046h,04dh,000h,061h,0f4h,04fh,0f5h,040h,03dh,0f6h,00fh,035h,04dh,0f7h	; 7405  ..FM.a.O.@=..5M.
	defb 04bh,04eh,004h,0f9h,04ah,04bh,0ffh,0fch,00fh,040h,041h,0fdh,00fh,042h,052h,0feh	; 7415  KN..JK...@A..BR.
	defb 04eh,053h,000h,061h,0f4h,03fh,036h,0f5h,046h,03ah,0f8h,036h,0f7h,00fh,037h,050h	; 7425  NS.a.?6.F:.6..7P
	defb 0f8h,04fh,055h,045h,004h,0fah,046h,04ch,049h,0ffh,0ffh,043h,0feh,00fh,00fh,000h	; 7435  .OUE..FLI..C....
	defb 061h,0eah,077h,084h,08ah,0e9h,089h,078h,0e7h,077h,083h,07ch,0e6h,079h,078h,0e5h	; 7445  a.w....x.w.|.yx.
	defb 06ah,00fh,00fh,0e3h,004h,05dh,066h,0e0h,004h,004h,004h,05eh,058h,0e0h,059h,058h	; 7455  j....]f....^X.YX
	defb 000h,061h,0eah,004h,086h,00fh,0e9h,079h,0e7h,004h,08dh,08bh,0e6h,079h,085h,078h	; 7465  .a.....y.....y.x
	defb 0e4h,057h,056h,0e3h,059h,058h,00fh,0e3h,067h,00fh,0e0h,004h,05bh,05ah,0e0h,063h	; 7475  .WV.YX..g...[Z.c
	defb 05ch,000h,061h,0ebh,090h,0e9h,07eh,081h,0e7h,08eh,076h,00fh,0e6h,004h,08fh,08ch	; 7485  \.a...~...v.....
	defb 0e5h,061h,060h,0ffh,0e1h,057h,056h,00fh,0e0h,068h,058h,00fh,0e0h,069h,064h,000h	; 7495  .a`..WV..hX..id.
	defb 061h,0eah,077h,080h,0e9h,07bh,087h,0e7h,077h,0e6h,091h,078h,00fh,0e4h,004h,05bh	; 74a5  a.w..{..w..x...[
	defb 06bh,065h,0e3h,05fh,062h,05ch,0ffh,0e0h,059h,0e0h,00fh,00fh,000h	; 74b5  ke._b\..Y....

; ======================================================================
; CODIGO 0x74c2..0x7506  (68 bytes)
; ======================================================================


L_74C2:
	ld hl,(0e0e5h)		;74c2
	ld a,h			;74c5
	or a			;74c6
	ret nz			;74c7
	ld a,l			;74c8
	and 01fh		;74c9
	ret nz			;74cb
	ld a,l			;74cc
	rlca			;74cd
	rlca			;74ce
	rlca			;74cf
	add a,a			;74d0
	ld hl,07506h		;74d1
	call L_48D1		;74d4
	ld e,(hl)		;74d7
	inc hl			;74d8
	ld d,(hl)		;74d9
	ex de,hl		;74da
	ld a,(hl)		;74db
	and 0f0h		;74dc
	ld c,a			;74de
	ld a,(hl)		;74df
	inc hl			;74e0
	and 003h		;74e1
	add a,078h		;74e3
	ld d,a			;74e5
	ld a,c			;74e6
L_74E7:
	ld b,(hl)		;74e7
	inc hl			;74e8
	ld a,020h		;74e9
	add a,c			;74eb
	ld c,a			;74ec
	jr nc,L_74F0		;74ed
	inc d			;74ef
L_74F0:
	ld a,c			;74f0
	add a,b			;74f1
	sub 0e0h		;74f2
	ld e,a			;74f4
	call L_48C9		;74f5
L_74F8:
	ld a,(hl)		;74f8
	or a			;74f9
	ret z			;74fa
	cp 0e0h			;74fb
	jr nc,L_74E7		;74fd
	inc hl			;74ff
	add a,040h		;7500
	out (098h),a		;7502
	jr L_74F8		;7504

; ----------------------------------------------------------------------
; DATOS punteros_de_la_meta: Cinco punteros, uno por cada tramo de 32 metros del final. Cierra clavada en 0x7510, que es el primero de ellos
;   0x7506..0x7510  (10 bytes)
; DATOS bloques_de_la_meta: Los cinco bloques que va dibujando 0x74C2
;   0x7510..0x7596  (134 bytes)
; ----------------------------------------------------------------------
	defb 04bh,075h,028h,075h,01ah,075h,015h,075h,010h,075h,021h,0efh,090h,091h,000h,021h	; 7506  Ku(u.u.u.u!....!
	defb 0efh,092h,093h,000h,001h,0efh,0afh,0eeh,094h,096h,096h,098h,0eeh,095h,097h,097h	; 7516  ................
	defb 09ah,000h,0e0h,0efh,0afh,0efh,0b1h,0b2h,0edh,09dh,09bh,09ch,09ch,09ch,09bh,0edh	; 7526  ................
	defb 0c8h,09eh,0a4h,0a6h,0a8h,0a1h,0edh,0c8h,09fh,0a5h,0a7h,0a9h,0c9h,0edh,0a3h,0a0h	; 7536  ................
	defb 0a0h,0a0h,0adh,0a0h,000h,0c0h,0efh,071h,0efh,0b0h,0efh,0b1h,0b2h,0ebh,09dh,09dh	; 7546  .......q........
	defb 09bh,09bh,09bh,09ch,09ch,09ch,09ch,09bh,0ebh,0c8h,0c8h,0c9h,0c9h,0c9h,0c9h,0c9h	; 7556  ................
	defb 0a2h,0a2h,0c9h,0ebh,0c8h,0c8h,0c9h,0aah,0c9h,0aah,0c9h,099h,0c9h,0c9h,0ebh,0c8h	; 7566  ................
	defb 0c8h,0c9h,0abh,0c9h,0abh,0c9h,099h,0c9h,0c9h,0ebh,0c8h,0c8h,0c9h,0c9h,0c9h,0c9h	; 7576  ................
	defb 0c9h,0aeh,0c9h,0c9h,0ebh,0a3h,0a3h,0ach,0a0h,0a0h,0ach,0ach,09ah,0a0h,0ach,000h	; 7586  ................

; ======================================================================
; CODIGO 0x7596..0x76da  (324 bytes)
; ======================================================================


L_7596:
	ld hl,0e183h		;7596
	ld a,(hl)		;7599
	and 0e3h		;759a
	ret nz			;759c
	ld de,0e113h		;759d
	ld b,003h		;75a0
L_75A2:
	ld a,(de)		;75a2
	cp 003h			;75a3
	jr nc,L_75AE		;75a5
	dec de			;75a7
	ld a,(de)		;75a8
	cp 007h			;75a9
	jr z,L_75B6		;75ab
	inc de			;75ad
L_75AE:
	ld a,006h		;75ae
	call L_48D6		;75b0
	djnz L_75A2		;75b3
	ret			;75b5
L_75B6:
	ld (0e181h),de		;75b6
	inc de			;75ba
	ld a,(0e18ah)		;75bb
	ld c,a			;75be
	ld a,(0e003h)		;75bf
	cp c			;75c2
	jr nc,L_75FE		;75c3
	ld a,(0e009h)		;75c5
	and 00ch		;75c8
	jr z,L_75D0		;75ca
	bit 2,a			;75cc
	jr L_75D9		;75ce
L_75D0:
	ld a,(0e185h)		;75d0
	inc a			;75d3
	ld (0e185h),a		;75d4
	bit 0,a			;75d7
L_75D9:
	ld a,090h		;75d9
	set 0,(hl)		;75db
	jr z,L_75E3		;75dd
	ld a,080h		;75df
	rlc (hl)		;75e1
L_75E3:
	ld c,a			;75e3
	ld hl,0e08ch		;75e4
	ld a,(de)		;75e7
	ld d,c			;75e8
	cp 001h			;75e9
	ld bc,07a66h		;75eb
	jr c,L_75F4		;75ee
	jr z,L_75F6		;75f0
	ld b,092h		;75f2
L_75F4:
	jr L_75F8		;75f4
L_75F6:
	ld b,064h		;75f6
L_75F8:
	ld (hl),c		;75f8
	inc hl			;75f9
	ld (hl),b		;75fa
	inc hl			;75fb
	ld (hl),d		;75fc
	ret			;75fd
L_75FE:
	xor a			;75fe
	ld (0e192h),a		;75ff
	ld a,(de)		;7602
	cp 001h			;7603
	jr c,L_760C		;7605
	jr z,L_760F		;7607
	set 5,(hl)		;7609
	ret			;760b
L_760C:
	set 6,(hl)		;760c
	ret			;760e
L_760F:
	set 7,(hl)		;760f
	ret			;7611
L_7612:
	ld a,(0e003h)		;7612
	rra			;7615
	ret c			;7616
L_7617:
	ld hl,(0e08ch)		;7617
	ld (0e188h),hl		;761a
	ld hl,0e08ch		;761d
	ld de,03b3ch		;7620
	ld bc,00004h		;7623
	call L_44DE		;7626
	ld de,0e183h		;7629
	ld a,(de)		;762c
	and 003h		;762d
	ret z			;762f
	ld hl,0e08eh		;7630
	call L_7674		;7633
	ld a,(de)		;7636
	dec hl			;7637
	rra			;7638
	jr c,L_763F		;7639
	dec (hl)		;763b
	dec (hl)		;763c
	jr L_7641		;763d
L_763F:
	inc (hl)		;763f
	inc (hl)		;7640
L_7641:
	push hl			;7641
	ld hl,0e184h		;7642
	inc (hl)		;7645
	ld a,(hl)		;7646
	pop hl			;7647
	dec hl			;7648
	cp 008h			;7649
	jr c,L_7662		;764b
	cp 010h			;764d
	ret c			;764f
	jr z,L_7665		;7650
	cp 022h			;7652
	jr nc,L_766C		;7654
	ld c,005h		;7656
	cp 01ah			;7658
	jr c,L_765E		;765a
	inc c			;765c
	inc c			;765d
L_765E:
	ld a,(hl)		;765e
	add a,c			;765f
	ld (hl),a		;7660
	ret			;7661
L_7662:
	dec (hl)		;7662
	dec (hl)		;7663
	ret			;7664
L_7665:
	inc hl			;7665
	inc hl			;7666
	ld a,(hl)		;7667
	add a,008h		;7668
	ld (hl),a		;766a
	ret			;766b
L_766C:
	ld (hl),0e0h		;766c
	xor a			;766e
	ld (de),a		;766f
	inc de			;7670
	ld (de),a		;7671
	jr L_7617		;7672
L_7674:
	ld a,(0e003h)		;7674
	and 00fh		;7677
	ret nz			;7679
	ld a,(hl)		;767a
	srl a			;767b
	srl a			;767d
	srl a			;767f
	ccf			;7681
	rla			;7682
	rla			;7683
	rla			;7684
	ld (hl),a		;7685
	ret			;7686
L_7687:
	call L_76D2		;7687
	ld a,(0e100h)		;768a
	or a			;768d
	rra			;768e
	ld (0e148h),a		;768f
	ld a,(0e0e6h)		;7692
	and 00ch		;7695
	ld a,02ch		;7697
	jr nz,L_769D		;7699
	add a,004h		;769b
L_769D:
	ld c,a			;769d
	ld a,(0e0e0h)		;769e
	and 0f0h		;76a1
	jr z,L_76B1		;76a3
	and 0e0h		;76a5
	jr z,L_76AD		;76a7
	ld a,c			;76a9
	sub 004h		;76aa
	ld c,a			;76ac
L_76AD:
	ld a,c			;76ad
	sub 004h		;76ae
	ld c,a			;76b0
L_76B1:
	ld a,(0e100h)		;76b1
	cp 00ch			;76b4
	jr c,L_76C5		;76b6
	and 00ch		;76b8
	jr z,L_76CD		;76ba
	cp 00ch			;76bc
	jr z,L_76C9		;76be
	ld a,c			;76c0
L_76C1:
	ld (0e10eh),a		;76c1
	ret			;76c4
L_76C5:
	ld a,c			;76c5
	sub 004h		;76c6
	ld c,a			;76c8
L_76C9:
	ld a,c			;76c9
	sub 004h		;76ca
	ld c,a			;76cc
L_76CD:
	ld a,c			;76cd
	sub 004h		;76ce
	jr L_76C1		;76d0
L_76D2:
	ld a,(0e009h)		;76d2
	and 003h		;76d5
	call L_4098		;76d7

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_76DA: Los 4 destinos del CALL de 0x76D7. Cierra clavada contra su primer destino
;   0x76da..0x76e2  (8 bytes)
; ----------------------------------------------------------------------
	defb 010h,077h,0e2h,076h,0fah,076h,010h,077h	; 76da  .w.v.v.w

; ======================================================================
; CODIGO 0x76e2..0x77dd  (251 bytes)
; ======================================================================


L_76E2:
	ld hl,0e0fdh		;76e2
	xor a			;76e5
	ld (hl),a		;76e6
	inc hl			;76e7
	inc hl			;76e8
	ld (hl),a		;76e9
	dec hl			;76ea
	inc (hl)		;76eb
	ld a,(hl)		;76ec
	sub 00ch		;76ed
	ret nz			;76ef
	ld (hl),a		;76f0
	ld hl,0e100h		;76f1
	ld a,(hl)		;76f4
	cp 009h			;76f5
	ret c			;76f7
	dec (hl)		;76f8
	ret			;76f9
L_76FA:
	ld hl,0e0fdh		;76fa
	xor a			;76fd
	ld (hl),a		;76fe
	inc hl			;76ff
	ld (hl),a		;7700
	inc hl			;7701
	inc (hl)		;7702
	ld a,(hl)		;7703
	sub 004h		;7704
	ret nz			;7706
	ld (hl),a		;7707
	ld hl,0e100h		;7708
	ld a,(hl)		;770b
	cp 013h			;770c
	ret nc			;770e
	inc (hl)		;770f
L_7710:
	ret			;7710
L_7711:
	ld a,(0e140h)		;7711
	ld hl,0e142h		;7714
	add a,(hl)		;7717
	ld hl,0e171h		;7718
	jr nz,L_773C		;771b
	ld a,(0e100h)		;771d
	ld b,a			;7720
	and 001h		;7721
	add a,042h		;7723
	ld c,a			;7725
	ld a,b			;7726
	rra			;7727
	cpl			;7728
	and 00fh		;7729
	sub 006h		;772b
	jr z,L_7735		;772d
	ld b,a			;772f
L_7730:
	ld (hl),042h		;7730
	inc hl			;7732
	djnz L_7730		;7733
L_7735:
	ld (hl),c		;7735
	inc hl			;7736
	ld a,l			;7737
	cp 078h			;7738
	jr z,L_7740		;773a
L_773C:
	ld c,000h		;773c
	jr L_7735		;773e
L_7740:
	ld hl,0e171h		;7740
	ld de,03839h		;7743
	ld bc,00006h		;7746
	jp L_44DE		;7749
L_774C:
	ld a,(0e002h)		;774c
	bit 6,a			;774f
	ret z			;7751
	ld b,004h		;7752
	ld de,0e0b8h		;7754
	ld hl,0e14ah		;7757
L_775A:
	ld a,(hl)		;775a
	or a			;775b
	ld a,004h		;775c
	jr nz,L_777B		;775e
	push hl			;7760
	inc (hl)		;7761
	ld hl,077dfh		;7762
	ld a,b			;7765
	add a,a			;7766
	call L_48D1		;7767
	ld a,(hl)		;776a
	ld (de),a		;776b
	inc hl			;776c
	inc de			;776d
	ld a,(hl)		;776e
	ld (de),a		;776f
	inc de			;7770
	ld a,0e0h		;7771
	ld (de),a		;7773
	inc de			;7774
	ld a,00fh		;7775
	ld (de),a		;7777
	ld a,001h		;7778
	pop hl			;777a
L_777B:
	call L_48D6		;777b
	inc hl			;777e
	djnz L_775A		;777f
	ld hl,0e149h		;7781
	dec (hl)		;7784
	ret nz			;7785
	ld a,(0e148h)		;7786
	ld (hl),a		;7789
	ld b,000h		;778a
	ld hl,0e14ah		;778c
	ld de,0e0b8h		;778f
L_7792:
	ld a,(hl)		;7792
	or a			;7793
	jr z,L_77C5		;7794
	ld a,(de)		;7796
	cp 008h			;7797
	jr nz,L_77A2		;7799
	ld a,0d1h		;779b
	ld (de),a		;779d
	ld (hl),000h		;779e
	jr L_77C5		;77a0
L_77A2:
	push de			;77a2
	inc (hl)		;77a3
	ex de,hl		;77a4
	dec (hl)		;77a5
	push de			;77a6
	ld de,077ddh		;77a7
	ld a,b			;77aa
	call L_48D6		;77ab
	ld a,(de)		;77ae
	inc hl			;77af
	add a,(hl)		;77b0
	ld (hl),a		;77b1
	ex de,hl		;77b2
	pop hl			;77b3
	ld a,(hl)		;77b4
	cp 00ch			;77b5
	ld a,0dch		;77b7
	jr z,L_77C2		;77b9
	ld a,(hl)		;77bb
	cp 018h			;77bc
	ld a,0d8h		;77be
	jr nz,L_77C4		;77c0
L_77C2:
	inc de			;77c2
	ld (de),a		;77c3
L_77C4:
	pop de			;77c4
L_77C5:
	ld a,004h		;77c5
	call L_48D6		;77c7
	inc hl			;77ca
	ld a,004h		;77cb
	inc b			;77cd
	cp b			;77ce
	jr nz,L_7792		;77cf
	ld hl,0e0b8h		;77d1
	ld de,03b68h		;77d4
	ld bc,00010h		;77d7
	jp L_44DE		;77da

; ----------------------------------------------------------------------
; DATOS nubes_desplazamientos: Cuanto se corre de lado cada nube en cada paso: -1, +1, -2 y +2. Con la Y subiendo y la X abriendose, las cuatro se separan del centro segun se acercan
;   0x77dd..0x77e1  (4 bytes)
; DATOS nubes_posiciones: Por donde asoma cada nube: cuatro parejas (Y, X), las cuatro en la misma columna y a alturas distintas
;   0x77e1..0x77e9  (8 bytes)
; ----------------------------------------------------------------------
	defb 0ffh,001h,0feh,002h,038h,098h,037h,058h,03ch,07ch,03ah,074h	; 77dd  ....8.7X<|:t

; ======================================================================
; CODIGO 0x77e9..0x7868  (127 bytes)
; ======================================================================


L_77E9:
	ld a,(0e183h)		;77e9
	and 0e0h		;77ec
	ret z			;77ee
	ld hl,(0e181h)		;77ef
	ld a,(hl)		;77f2
	ld hl,0e183h		;77f3
	sub 00fh		;77f6
	jr nz,L_7802		;77f8
	ld (hl),a		;77fa
	ld hl,07964h		;77fb
	ld b,004h		;77fe
	jr L_783E		;7800
L_7802:
	ld hl,07868h		;7802
	add a,008h		;7805
	ld b,a			;7807
	add a,a			;7808
	call L_48D1		;7809
	ld e,(hl)		;780c
	inc hl			;780d
	ld d,(hl)		;780e
	ld a,b			;780f
	ld b,004h		;7810
	cp 006h			;7812
	jr c,L_7822		;7814
	ld hl,0e137h		;7816
	bit 0,(hl)		;7819
	jr nz,L_7822		;781b
	ld hl,0e192h		;781d
	ld (hl),001h		;7820
L_7822:
	cp 003h			;7822
	ex de,hl		;7824
	ld d,00ch		;7825
	jr nc,L_782D		;7827
	ld d,006h		;7829
	ld b,002h		;782b
L_782D:
	ld a,(0e183h)		;782d
	cp 040h			;7830
	jr z,L_783E		;7832
	jr c,L_783A		;7834
	ld a,d			;7836
	call L_48D1		;7837
L_783A:
	ld a,d			;783a
	call L_48D1		;783b
L_783E:
	ld de,0e090h		;783e
	push de			;7841
L_7842:
	ld c,003h		;7842
L_7844:
	ld a,(hl)		;7844
	ld (de),a		;7845
	inc hl			;7846
	inc de			;7847
	dec c			;7848
	jr nz,L_7844		;7849
	inc de			;784b
	djnz L_7842		;784c
	pop hl			;784e
	ld c,010h		;784f
	ld a,(0e192h)		;7851
	rra			;7854
	ld de,03b00h		;7855
	jr nc,L_7860		;7858
	call L_44DE		;785a
	ld hl,0e050h		;785d
L_7860:
	ld de,03b40h		;7860
	ld c,010h		;7863
	jp L_44DE		;7865

; ----------------------------------------------------------------------
; DATOS punteros_de_la_foca: Ocho punteros, uno por cada paso del 7 al 14. 0x7802 los indexa con paso-7, no con el tipo de obstaculo: leido de la otra manera salen punteros que se van fuera del cartucho. Cierra clavada en 0x787A, que es el primero de ellos
;   0x7868..0x7878  (16 bytes)
; DATOS fotogramas_de_la_foca: Los ocho fotogramas, cada uno con TRES variantes que elige 0x782D con el bit que 0x75FE encendio en 0xE183. Los tres primeros pasos llevan dos sprites (18 bytes = 3 x 2 x 3) y los cinco siguientes cuatro (36 bytes); de cada sprite van tres bytes: Y, X y patron. LAS TRES VARIANTES LLEVAN EL MISMO DIBUJO y solo cambian la X: una sale por el centro (0x78), otra se va a la derecha y otra a la izquierda, separandose mas en cada paso. Y del paso 10 al 14 los cuatro patrones son siempre C0, C4, C8 y CC: lo unico que cambia es la Y, que baja de 0x7B a 0xA1. La foca no se deforma, se acerca
;   0x7878..0x7964  (236 bytes)
; DATOS foca_escondida: El fotograma del paso 15, con las cuatro Y a 0xE0 para sacarla de la pantalla. Cierra clavado en 0x7970, donde vuelve a haber codigo
;   0x7964..0x7970  (12 bytes)
; ----------------------------------------------------------------------
	defb 07ah,078h,08ch,078h,09eh,078h,0b0h,078h,0d4h,078h,0f8h,078h,01ch,079h,040h,079h	; 7868  zx.x.x.x.x.x.y@y
	defb 064h,079h,067h,078h,07ch,067h,078h,0e8h,067h,090h,07ch,067h,090h,0e8h,067h,060h	; 7878  dygx|gx.g.|g..g`
	defb 07ch,067h,060h,0e8h,06ch,078h,0b8h,06ch,078h,0bch,06ch,094h,0b8h,06ch,094h,0bch	; 7888  |g`.lx.lx.l..l..
	defb 06ch,05bh,0b8h,06ch,05bh,0bch,078h,078h,0b8h,078h,078h,0bch,078h,09dh,0b8h,078h	; 7898  l[.l[.xx.xx.x..x
	defb 09dh,0bch,078h,053h,0b8h,078h,053h,0bch,07bh,078h,0c0h,08bh,070h,0c4h,07bh,078h	; 78a8  ..xS.xS.{x..p.{x
	defb 0c8h,08bh,080h,0cch,07bh,0a4h,0c0h,08bh,09ch,0c4h,07bh,0a4h,0c8h,08bh,0ach,0cch	; 78b8  ....{.....{.....
	defb 07bh,04ch,0c0h,08bh,044h,0c4h,07bh,04ch,0c8h,08bh,054h,0cch,086h,078h,0c0h,096h	; 78c8  {L..D.{L..T..x..
	defb 070h,0c4h,086h,078h,0c8h,096h,080h,0cch,086h,0ach,0c0h,096h,0a4h,0c4h,086h,0ach	; 78d8  p..x............
	defb 0c8h,096h,0b4h,0cch,086h,044h,0c0h,096h,03ch,0c4h,086h,044h,0c8h,096h,04ch,0cch	; 78e8  .....D..<..D..L.
	defb 08fh,078h,0c0h,09fh,070h,0c4h,08fh,078h,0c8h,09fh,080h,0cch,08fh,0b2h,0c0h,09fh	; 78f8  .x..p..x........
	defb 0aah,0c4h,08fh,0b2h,0c8h,09fh,0bah,0cch,08fh,03eh,0c0h,09fh,036h,0c4h,08fh,03eh	; 7908  .........>..6..>
	defb 0c8h,09fh,046h,0cch,098h,078h,0c0h,0a8h,070h,0c4h,098h,078h,0c8h,0a8h,080h,0cch	; 7918  ..F..x..p..x....
	defb 098h,0b8h,0c0h,0a8h,0b0h,0c4h,098h,0b8h,0c8h,0a8h,0c0h,0cch,098h,038h,0c0h,0a8h	; 7928  .............8..
	defb 030h,0c4h,098h,038h,0c8h,0a8h,040h,0cch,0a1h,078h,0c0h,0b1h,070h,0c4h,0a1h,078h	; 7938  0..8..@..x..p..x
	defb 0c8h,0b1h,080h,0cch,0a1h,0beh,0c0h,0b1h,0b6h,0c4h,0a1h,0beh,0c8h,0b1h,0c6h,0cch	; 7948  ................
	defb 0a1h,032h,0c0h,0b1h,02ah,0c4h,0a1h,032h,0c8h,0b1h,03ah,0cch,0e0h,000h,000h,0e0h	; 7958  .2..*..2..:.....
	defb 000h,000h,0e0h,000h,000h,0e0h,000h,000h	; 7968  ........

; ======================================================================
; CODIGO 0x7970..0x7ad7  (359 bytes)
; ======================================================================


L_7970:
	di			;7970
	push hl			;7971
	push de			;7972
	push bc			;7973
	push af			;7974
	call L_797E		;7975
	pop af			;7978
	pop bc			;7979
	pop de			;797a
	pop hl			;797b
	ei			;797c
	ret			;797d
L_797E:
	ld b,002h		;797e
	ld hl,0e012h		;7980
	cp 08ah			;7983
	jr c,L_798E		;7985
	cp 08ch			;7987
	jr c,L_7992		;7989
	inc b			;798b
	jr L_7992		;798c
L_798E:
	dec b			;798e
	ld hl,0e026h		;798f
L_7992:
	cp (hl)			;7992
	jr c,L_79B8		;7993
	ld c,a			;7995
	and 03fh		;7996
	add a,a			;7998
	ld de,07af2h		;7999
	call L_48D6		;799c
L_799F:
	dec hl			;799f
	dec hl			;79a0
	ld (hl),001h		;79a1
	inc hl			;79a3
	ld (hl),001h		;79a4
	inc hl			;79a6
	ld a,c			;79a7
	ld (hl),a		;79a8
	inc hl			;79a9
	ld a,(de)		;79aa
	ld (hl),a		;79ab
	inc hl			;79ac
	inc de			;79ad
	ld a,(de)		;79ae
	ld (hl),a		;79af
	ld a,008h		;79b0
	call L_48D1		;79b2
	inc de			;79b5
	djnz L_799F		;79b6
L_79B8:
	ret			;79b8
L_79B9:
	inc hl			;79b9
	ld a,(hl)		;79ba
	inc a			;79bb
	jr z,L_79CE		;79bc
	inc (ix+009h)		;79be
	dec a			;79c1
	cp (ix+009h)		;79c2
	jr nz,L_79CE		;79c5
	xor a			;79c7
	ld (ix+009h),a		;79c8
	jp L_7A44		;79cb
L_79CE:
	ld a,(ix+002h)		;79ce
	push bc			;79d1
	call L_797E		;79d2
	pop bc			;79d5
	ret			;79d6
L_79D7:
	ld c,001h		;79d7
	ld ix,0e010h		;79d9
	exx			;79dd
	ld b,003h		;79de
	ld de,0000ah		;79e0
L_79E3:
	exx			;79e3
	ld a,(ix+002h)		;79e4
	or a			;79e7
	call nz,L_79F4	;79e8
	inc c			;79eb
	inc c			;79ec
	exx			;79ed
	add ix,de		;79ee
	djnz L_79E3		;79f0
	exx			;79f2
	ret			;79f3
L_79F4:
	jp m,L_7A4B		;79f4
	dec (ix+000h)		;79f7
	ret nz			;79fa
L_79FB:
	ld l,(ix+003h)		;79fb
	ld h,(ix+004h)		;79fe
	ld a,(hl)		;7a01
	cp 0feh			;7a02
	jr z,L_79B9		;7a04
	jr nc,L_7A44		;7a06
	bit 7,(ix+002h)		;7a08
	jp nz,L_7A76		;7a0c
	and 0f0h		;7a0f
	cp 020h			;7a11
	jr nz,L_7A1C		;7a13
	ld a,(hl)		;7a15
	and 00fh		;7a16
	ld (ix+001h),a		;7a18
	inc hl			;7a1b
L_7A1C:
	ld a,(hl)		;7a1c
	and 0f0h		;7a1d
	ld b,a			;7a1f
	xor (hl)		;7a20
	ld d,a			;7a21
	inc hl			;7a22
	ld e,(hl)		;7a23
	inc hl			;7a24
	ld (ix+003h),l		;7a25
	ld (ix+004h),h		;7a28
	ex de,hl		;7a2b
	call L_7AC8		;7a2c
	ld a,b			;7a2f
	rrca			;7a30
	rrca			;7a31
	rrca			;7a32
	rrca			;7a33
	and 00fh		;7a34
L_7A36:
	ld h,a			;7a36
	ld a,(ix+001h)		;7a37
	ld (ix+000h),a		;7a3a
	add a,003h		;7a3d
	ld (ix+008h),a		;7a3f
	jr L_7A6C		;7a42
L_7A44:
	xor a			;7a44
	ld (ix+002h),a		;7a45
	ld h,a			;7a48
	jr L_7A6C		;7a49
L_7A4B:
	dec (ix+000h)		;7a4b
	jr z,L_79FB		;7a4e
	dec (ix+008h)		;7a50
	ld a,(ix+008h)		;7a53
	cp (ix+000h)		;7a56
	jr nz,L_7A60		;7a59
	cp 001h			;7a5b
	jr c,L_7A63		;7a5d
	ret			;7a5f
L_7A60:
	dec (ix+008h)		;7a60
L_7A63:
	ld a,(ix+007h)		;7a63
	dec a			;7a66
	ret m			;7a67
	ld (ix+007h),a		;7a68
	ld h,a			;7a6b
L_7A6C:
	ld a,c			;7a6c
	rrca			;7a6d
	add a,088h		;7a6e
	out (0a0h),a		;7a70
	ld a,h			;7a72
	out (0a1h),a		;7a73
	ret			;7a75
L_7A76:
	cp 0fdh			;7a76
	jr nz,L_7A8A		;7a78
	inc hl			;7a7a
	ld a,(hl)		;7a7b
	and 007h		;7a7c
	ld (ix+005h),a		;7a7e
	xor (hl)		;7a81
	rrca			;7a82
	rrca			;7a83
	rrca			;7a84
	ld (ix+006h),a		;7a85
	inc hl			;7a88
	ld a,(hl)		;7a89
L_7A8A:
	and 00fh		;7a8a
	ld b,a			;7a8c
	xor (hl)		;7a8d
	inc hl			;7a8e
	ld (ix+003h),l		;7a8f
	ld (ix+004h),h		;7a92
	rrca			;7a95
	rrca			;7a96
	rrca			;7a97
	rrca			;7a98
	ld hl,07ae4h		;7a99
	call L_48D1		;7a9c
	ld a,(hl)		;7a9f
	ld (ix+001h),a		;7aa0
	ld a,b			;7aa3
	sub 00ch		;7aa4
	ld (ix+007h),a		;7aa6
	jr z,L_7AB1		;7aa9
	ld a,(ix+006h)		;7aab
	ld (ix+007h),a		;7aae
L_7AB1:
	call L_7A36		;7ab1
	ld a,b			;7ab4
	ld hl,07ad8h		;7ab5
	call L_48D1		;7ab8
	ld l,(hl)		;7abb
	ld h,000h		;7abc
	ld a,(ix+005h)		;7abe
	or a			;7ac1
	jr z,L_7AC8		;7ac2
	ld b,a			;7ac4
L_7AC5:
	add hl,hl		;7ac5
	djnz L_7AC5		;7ac6
L_7AC8:
	ld a,c			;7ac8
	out (0a0h),a		;7ac9
	ld a,h			;7acb
	out (0a1h),a		;7acc
	dec c			;7ace
	ld a,c			;7acf
	out (0a0h),a		;7ad0
	ld a,l			;7ad2
	out (0a1h),a		;7ad3
	inc c			;7ad5
	ret			;7ad6

; ----------------------------------------------------------------------
; DATOS byte_suelto: Un 0xFF que no apunta nadie, justo delante de la tabla de notas
;   0x7ad7..0x7ad8  (1 bytes)
; DATOS tabla_de_notas: Doce periodos, una octava cromatica: la desviacion respecto al temperamento igual es de 0,090 semitonos, y los doce bytes de al lado dan 15,8
;   0x7ad8..0x7ae4  (12 bytes)
; DATOS tabla_de_duraciones: Las doce duraciones, indexadas por el nibble alto de cada nota. Van de 5 a 100 fotogramas y NO son una escala, aunque esten pegadas a la que si lo es
;   0x7ae4..0x7af2  (14 bytes)
; DATOS punteros_de_sonido: Veinticuatro punteros a los flujos. Cierra clavada en 0x7B22, que es el primero. El del sonido 0 apunta fuera de la ROM porque no se pide nunca, y los tres ultimos apuntan al 0xFF de 0x7B22: el sonido 0x95, el que llama 0x44BD al arrancar, es un flujo que se acaba en el primer byte, o sea el silencio
;   0x7af2..0x7b22  (48 bytes)
; DATOS flujos_de_sonido: Los veintiun flujos de musica y efectos
;   0x7b22..0x7e57  (821 bytes)
; DATOS relleno_final: Lo que sobra del cartucho hasta los 16 KB
;   0x7e57..0x8000  (425 bytes)
; ----------------------------------------------------------------------
	defb 0ffh,06ah,064h,05fh,059h,054h,050h,04bh,047h,043h,03fh,03ch,038h,008h,010h,020h	; 7ad7  .jd_YTPKGC?<8.. 
	defb 030h,040h,060h,005h,00ah,00fh,014h,064h,01eh,018h,03ch,050h,028h,0e6h,07ch,0c0h	; 7ae7  0@`....d..<P(.|.
	defb 07ch,01eh,07dh,026h,07dh,00ah,07dh,0feh,07ch,0ech,07ch,015h,07eh,0ceh,07ch,023h	; 7af7  |.}&}.}.|.|.~.|#
	defb 07bh,0a3h,07bh,0c2h,07dh,0dfh,07dh,002h,07eh,079h,07ch,097h,07ch,0aeh,07ch,02eh	; 7b07  {.{.}.}.~y|.|.|.
	defb 07dh,060h,07dh,093h,07dh,022h,07bh,022h,07bh,022h,07bh,0ffh,0fdh,05ah,03bh,0fdh	; 7b17  }`}.}"{"{"{..Z;.
	defb 059h,022h,014h,054h,030h,024h,016h,056h,039h,027h,0fdh,05ah,01bh,0fdh,059h,032h	; 7b27  Y".T0$.V9'.Z..Y2
	defb 020h,0fdh,05ah,01bh,03bh,039h,047h,0fdh,059h,002h,007h,004h,007h,002h,007h,004h	; 7b37   .Z.;9G.Y.......
	defb 007h,002h,007h,004h,007h,002h,007h,004h,007h,012h,006h,00ch,006h,00ch,012h,006h	; 7b47  ................
	defb 00ch,006h,00ch,002h,009h,004h,009h,002h,009h,004h,009h,002h,009h,004h,009h,012h	; 7b57  ................
	defb 007h,00ch,007h,00ch,012h,007h,00ch,007h,00ch,002h,007h,006h,007h,002h,007h,002h	; 7b67  ................
	defb 007h,005h,007h,002h,007h,000h,007h,004h,007h,000h,007h,000h,007h,003h,007h,000h	; 7b77  ................
	defb 007h,0fdh,05ah,00bh,0fdh,059h,007h,002h,007h,0fdh,05ah,00bh,0fdh,059h,007h,000h	; 7b87  ..Z..Y....Z..Y..
	defb 006h,002h,006h,000h,006h,017h,01ch,016h,017h,02ch,0feh,0ffh,0fdh,05bh,017h,0fdh	; 7b97  .........,...[..
	defb 05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,010h	; 7ba7  Z...[..Z...[..Z.
	defb 010h,0fdh,05bh,017h,0fdh,05ah,010h,010h,0fdh,05bh,017h,0fdh,05ah,014h,014h,0fdh	; 7bb7  ..[..Z...[..Z...
	defb 05bh,017h,0fdh,05ah,014h,014h,0fdh,05bh,016h,0fdh,05ah,012h,012h,0fdh,05bh,016h	; 7bc7  [..Z...[..Z...[.
	defb 0fdh,05ah,012h,012h,0fdh,05bh,010h,019h,019h,017h,0fdh,05ah,012h,012h,0fdh,05bh	; 7bd7  .Z...[.....Z...[
	defb 017h,0fdh,05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh	; 7be7  ..Z...[..Z...[..
	defb 05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h	; 7bf7  Z...[..Z...[..Z.
	defb 0fdh,05bh,01bh,027h,01ch,01bh,0fdh,05ah,012h,012h,0fdh,05bh,01bh,0fdh,05ah,012h	; 7c07  .[.'...Z...[..Z.
	defb 012h,0fdh,05bh,016h,0fdh,05ah,012h,012h,0fdh,05bh,016h,0fdh,05ah,012h,012h,0fdh	; 7c17  ..[..Z...[..Z...
	defb 05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,017h	; 7c27  [..Z...[..Z...[.
	defb 0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h,012h,0fdh,05bh,012h,017h,01bh	; 7c37  .Z...[..Z...[...
	defb 017h,01bh,0fdh,05ah,012h,0fdh,05bh,017h,0fdh,05ah,010h,014h,0fdh,05bh,017h,0fdh	; 7c47  ...Z..[..Z...[..
	defb 05ah,010h,014h,0fdh,05bh,017h,0fdh,05ah,012h,01ch,0fdh,05bh,019h,0fdh,05ah,012h	; 7c57  Z...[..Z...[..Z.
	defb 01ch,012h,01ch,0fdh,05bh,01bh,0fdh,05ah,002h,000h,0fdh,05bh,00bh,009h,007h,00ch	; 7c67  ....[..Z...[....
	defb 0feh,0ffh,0fdh,059h,090h,080h,060h,090h,0fdh,05ah,08bh,069h,097h,094h,097h,094h	; 7c77  ...Y..`..Z.i....
	defb 072h,074h,075h,077h,079h,077h,079h,07bh,0fdh,061h,090h,080h,060h,090h,0ffh,0ffh	; 7c87  rtuwywy{.a..`...
	defb 0fdh,05bh,097h,097h,097h,09ch,097h,097h,097h,09ch,095h,092h,097h,0fdh,05ch,097h	; 7c97  .[............\.
	defb 0fdh,063h,090h,097h,097h,0ffh,0ffh,0fdh,05bh,090h,090h,090h,09ch,090h,090h,090h	; 7ca7  .c......[.......
	defb 09ch,0ach,0fdh,05ah,084h,064h,094h,0ffh,0ffh,022h,0d0h,07fh,0b0h,070h,0b0h,077h	; 7cb7  ...Z.d..."...p.w
	defb 0a0h,062h,090h,050h,080h,043h,0ffh,023h,090h,060h,090h,040h,090h,060h,090h,040h	; 7cc7  .b.P.C.#.`.@.`.@
	defb 090h,060h,090h,040h,090h,060h,090h,040h,090h,060h,090h,040h,090h,060h,0ffh,021h	; 7cd7  .`.@.`.@.`.@.`.!
	defb 0a0h,025h,0a0h,027h,0ffh,021h,0c0h,0ddh,0c0h,0bbh,0b0h,0aah,0b0h,099h,0a0h,088h	; 7ce7  .%.'.!..........
	defb 0a0h,077h,090h,066h,090h,055h,0ffh,022h,0c0h,055h,0c0h,066h,0c0h,055h,0b0h,044h	; 7cf7  .w.f.U.".U.f.U.D
	defb 0a0h,033h,0ffh,022h,0e0h,0a5h,0c0h,0b5h,0a0h,0c5h,090h,0d5h,080h,0e5h,070h,0f5h	; 7d07  .3."..........p.
	defb 061h,005h,051h,025h,051h,045h,0ffh,021h,0c1h,003h,0c1h,00dh,0c1h,006h,0ffh,021h	; 7d17  a.Q%QE.!.......!
	defb 0c1h,043h,0c1h,04dh,0c1h,046h,0ffh,0fdh,05ah,07bh,0fdh,059h,072h,074h,072h,097h	; 7d27  .C.M.F..Z{.Yrtr.
	defb 076h,074h,0b2h,0fdh,05ah,07bh,097h,067h,069h,06bh,0fdh,059h,060h,0fdh,05ah,07bh	; 7d37  vt..Z{.gik.Y`.Z{
	defb 0fdh,059h,072h,074h,072h,097h,076h,074h,062h,064h,062h,060h,0fdh,05ah,06bh,0fdh	; 7d47  .Yrtr.vtbdb`.Zk.
	defb 059h,060h,0fdh,05ah,06bh,069h,097h,09ch,0ffh,0fdh,05ah,077h,07bh,0fdh,059h,070h	; 7d57  Y`.Zki....Zw{.Yp
	defb 0fdh,05ah,07bh,0fdh,059h,092h,070h,070h,0fdh,05ah,0bbh,077h,092h,09ch,077h,07bh	; 7d67  .Z{.Y.pp.Z.w..w{
	defb 0fdh,059h,070h,0fdh,05ah,07bh,0fdh,059h,092h,070h,070h,0fdh,05ah,06bh,0fdh,059h	; 7d77  .Yp.Z{.Y.pp.Zk.Y
	defb 060h,0fdh,05ah,06bh,069h,067h,069h,067h,066h,092h,09ch,0ffh,0fdh,05bh,077h,076h	; 7d87  `.Zkigigf....[wv
	defb 074h,072h,070h,0fdh,05ch,07bh,079h,077h,0fdh,05bh,077h,076h,074h,072h,070h,0fdh	; 7d97  trp.\{yw.[wvtrp.
	defb 05ch,07bh,079h,077h,0fdh,05bh,077h,076h,074h,072h,070h,0fdh,05ch,07bh,079h,077h	; 7da7  \{yw.[wvtrp.\{yw
	defb 0fdh,05bh,072h,0fdh,05ch,072h,074h,076h,077h,09ch,0ffh,0fdh,059h,094h,074h,074h	; 7db7  .[r.\rtvw...Y.tt
	defb 094h,072h,070h,0b5h,0fdh,05ah,075h,0b5h,0fdh,059h,075h,094h,070h,074h,092h,0fdh	; 7dc7  .rp..Zu..Yu.pt..
	defb 05ah,079h,07bh,0fdh,059h,0d0h,01ch,0ffh,0fdh,05bh,090h,070h,070h,090h,0fdh,05ah	; 7dd7  Zy{.Y....[.pp..Z
	defb 07bh,077h,0fdh,059h,0b0h,0fdh,05ah,070h,0b0h,0fdh,059h,070h,090h,0fdh,05ah,077h	; 7de7  {w.Y..Zp..Yp..Zw
	defb 0fdh,059h,070h,0fdh,05ah,09bh,075h,077h,0d7h,01ch,0ffh,0fdh,05bh,097h,094h,097h	; 7df7  .Yp.Z.uw....[...
	defb 094h,099h,095h,099h,095h,097h,094h,097h,095h,097h,097h,097h,09ch,0ffh,022h,0d1h	; 7e07  ..............".
	defb 0eeh,0d1h,0cch,0c1h,0eeh,0b1h,0ffh,0a1h,099h,091h,088h,081h,077h,071h,066h,061h	; 7e17  ............wqfa
	defb 077h,051h,088h,041h,099h,0ffh,021h,000h,0e0h,001h,000h,008h,0f3h,0cdh,0c9h,048h	; 7e27  wQ.A..!........H
	defb 0dbh,098h,077h,023h,00bh,078h,0b1h,020h,0f7h,0fbh,018h,0feh,0ffh,0ffh,0ffh,0ffh	; 7e37  ..w#.x. ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7e47  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7e57  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7e67  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7e77  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7e87  ................
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
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fe7  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7ff7  .........
