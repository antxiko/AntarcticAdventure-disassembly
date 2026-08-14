; ==========================================================================
; ANTARCTIC ADVENTURE - Konami (1984) - MSX1 - cartucho de 16 KB - version europea
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
l4eb6h:	equ 0x04eb6

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
	call L_4480		;4033
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
	call L_7A06		;4051
L_4054:
	ld a,(0e000h)		;4054
	cp 00ch			;4057
	jr nc,L_4077		;4059
	ld a,(0e140h)		;405b
	ld hl,0e142h		;405e
	add a,(hl)		;4061
	jr nz,L_4067		;4062
	call L_4C8D		;4064
L_4067:
	call L_4658		;4067
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
	call L_48CF		;409a
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
	call L_4416		;4110
	ld a,(0e000h)		;4113
	call L_4098		;4116

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_4119: Los 16 destinos del CALL de 0x4116. Cierra clavada contra su primer destino
;   0x4119..0x4139  (32 bytes)
; ----------------------------------------------------------------------
	defb 039h,041h,03ah,041h,04bh,041h,05dh,041h,068h,041h,076h,041h,07fh,041h,086h,041h	; 4119  9A:AKA]AhAvA.A.A
	defb 0d5h,041h,041h,042h,083h,042h,09ch,042h,0c2h,042h,0e7h,042h,0f8h,042h,0d9h,048h	; 4129  .AAB.B.B.B.B.B.H

; ======================================================================
; CODIGO 0x4139..0x418c  (83 bytes)
; ======================================================================


L_4139:
	ret			;4139
L_413A:
	call L_5858		;413a
	ld a,011h		;413d
	ld (0e00ah),a		;413f
	ld hl,00000h		;4142
	ld (0e00eh),hl		;4145
	jp L_43F1		;4148
L_414B:
	ld a,(0e003h)		;414b
	rra			;414e
	ret nc			;414f
	call L_4877		;4150
	ret nz			;4153
	ld hl,05802h		;4154
	call L_458E		;4157
	jp L_43EC		;415a
L_415D:
	ld hl,0e004h		;415d
	dec (hl)		;4160
	ret nz			;4161
	call L_482A		;4162
	jp L_43EE		;4165
L_4168:
	call L_4845		;4168
	ret c			;416b
	ld hl,057b7h		;416c
	call L_458E		;416f
	xor a			;4172
	jp L_43EE		;4173
L_4176:
	ret			;4176
L_4177:
	ld hl,0e004h		;4177
	dec (hl)		;417a
	ret nz			;417b
	jp L_43EC		;417c
L_417F:
	call L_45B1		;417f
	ret p			;4182
	jp L_43F1		;4183
L_4186:
	ld a,(0e001h)		;4186
	call L_4098		;4189

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_418C: Los 3 destinos del CALL de 0x4189. Cierra clavada contra su primer destino
;   0x418c..0x4192  (6 bytes)
; ----------------------------------------------------------------------
	defb 092h,041h,0a9h,041h,0cah,041h	; 418c  .A.A.A

; ======================================================================
; CODIGO 0x4192..0x41db  (73 bytes)
; ======================================================================


L_4192:
	call L_4449		;4192
	ld hl,0e002h		;4195
	res 6,(hl)		;4198
	ld hl,0073ch		;419a
	ld (0e0eeh),hl		;419d
	ld hl,05818h		;41a0
	ld (0e0ech),hl		;41a3
	jp L_4241		;41a6
L_41A9:
	ld hl,057abh		;41a9
	ld de,038cbh		;41ac
	call L_4592		;41af
	ld a,001h		;41b2
	ld (0e133h),a		;41b4
	call L_4B14		;41b7
	ld hl,(0e0eeh)		;41ba
	dec hl			;41bd
	ld (0e0eeh),hl		;41be
	ld a,h			;41c1
	or l			;41c2
	ret nz			;41c3
	ld (0e133h),a		;41c4
	jp L_43FA		;41c7
L_41CA:
	call L_45B1		;41ca
	ret p			;41cd
	xor a			;41ce
	ld (0e000h),a		;41cf
	jp L_43F1		;41d2
L_41D5:
	ld a,(0e001h)		;41d5
	call L_4098		;41d8

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_41DB: Los 4 destinos del CALL de 0x41D8. Cierra clavada contra su primer destino
;   0x41db..0x41e3  (8 bytes)
; ----------------------------------------------------------------------
	defb 0e3h,041h,0f4h,041h,007h,042h,037h,042h	; 41db  .A.A.B7B

; ======================================================================
; CODIGO 0x41e3..0x42fe  (283 bytes)
; ======================================================================


L_41E3:
	call L_45E6		;41e3
	call L_449C		;41e6
	call L_482A		;41e9
	ld a,092h		;41ec
	call L_799F		;41ee
	jp L_43FF		;41f1
L_41F4:
	call L_4845		;41f4
	jr c,L_41F4		;41f7
	ld hl,057b7h		;41f9
	call L_458E		;41fc
	ld a,006h		;41ff
	ld (0e18dh),a		;4201
	jp L_43FF		;4204
L_4207:
	ld hl,0e003h		;4207
	ld a,(hl)		;420a
	and 007h		;420b
	ret nz			;420d
	ld a,(hl)		;420e
	bit 3,a			;420f
	jr nz,L_4229		;4211
	ld de,03a00h		;4213
	ld bc,00020h		;4216
	ld a,(0e002h)		;4219
	and 010h		;421c
	rlca			;421e
	rlca			;421f
	call L_48D4		;4220
	ld a,001h		;4223
	call L_44EF		;4225
	ret			;4228
L_4229:
	ld hl,057b7h		;4229
	call L_458E		;422c
	ld hl,0e18dh		;422f
	dec (hl)		;4232
	ret nz			;4233
	jp L_43FA		;4234
L_4237:
	call L_45B1		;4237
	ret p			;423a
	call L_4449		;423b
	jp L_43F1		;423e
L_4241:
	ld a,(0e0e8h)		;4241
	ld hl,04aa3h		;4244
	add a,a			;4247
	add a,a			;4248
	call L_48CF		;4249
	ld e,(hl)		;424c
	inc hl			;424d
	ld d,(hl)		;424e
	inc hl			;424f
	ld (0e0e6h),de		;4250
	ld e,(hl)		;4254
	inc hl			;4255
	ld d,(hl)		;4256
	ld a,(0e0e1h)		;4257
	ld hl,0e0d5h		;425a
	call L_48CF		;425d
	ld a,(hl)		;4260
	sub 010h		;4261
	jr c,L_4271		;4263
	daa			;4265
	ld c,a			;4266
	ld a,e			;4267
	sub c			;4268
	jr nc,L_426F		;4269
	daa			;426b
	dec d			;426c
	jr L_4270		;426d
L_426F:
	daa			;426f
L_4270:
	ld e,a			;4270
L_4271:
	ld (0e0e3h),de		;4271
	call L_46A1		;4275
	call L_5858		;4278
	ld a,00eh		;427b
	ld (0e000h),a		;427d
	jp L_43EC		;4280
L_4283:
	call L_45B1		;4283
	ret p			;4286
	call L_4ACB		;4287
	ld a,(0e002h)		;428a
	bit 6,a			;428d
	ld a,08ah		;428f
	call nz,L_799F		;4291
	ld a,001h		;4294
	ld (0e133h),a		;4296
	jp L_43F1		;4299
L_429C:
	ld a,(0e002h)		;429c
	bit 6,a			;429f
	jr z,L_42BD		;42a1
	call L_4B14		;42a3
	ld hl,(0e00ch)		;42a6
	ld a,l			;42a9
	add a,h			;42aa
	ret z			;42ab
	ld a,l			;42ac
	ld hl,0e133h		;42ad
	ld (hl),000h		;42b0
	or a			;42b2
	ld a,00ch		;42b3
	jr nz,L_42B9		;42b5
	ld a,00eh		;42b7
L_42B9:
	ld (0e000h),a		;42b9
	ret			;42bc
L_42BD:
	ld hl,00107h		;42bd
	jr L_42F4		;42c0
L_42C2:
	xor a			;42c2
	ld (0e00ch),a		;42c3
	ld hl,0e0b8h		;42c6
	ld de,00004h		;42c9
	ld b,004h		;42cc
L_42CE:
	ld (hl),0e0h		;42ce
	add hl,de		;42d0
	djnz L_42CE		;42d1
	call L_66BB		;42d3
	ld (0e0e2h),a		;42d6
	ld a,08ch		;42d9
	call L_799F		;42db
	ld hl,057f7h		;42de
	call L_458E		;42e1
	jp L_43EC		;42e4
L_42E7:
	ld a,(0e012h)		;42e7
	or a			;42ea
	ret nz			;42eb
	ld hl,0e002h		;42ec
	res 6,(hl)		;42ef
	ld hl,00207h		;42f1
L_42F4:
	ld (0e000h),hl		;42f4
	ret			;42f7
L_42F8:
	ld a,(0e001h)		;42f8
	call L_4098		;42fb

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_42FE: Los 8 destinos del CALL de 0x42FB. Cierra clavada contra su primer destino
;   0x42fe..0x430e  (16 bytes)
; ----------------------------------------------------------------------
	defb 00eh,043h,021h,043h,061h,043h,06fh,043h,08ch,043h,0b3h,043h,0bch,043h,0e3h,043h	; 42fe  .C!CaCoC.C.C.C.C

; ======================================================================
; CODIGO 0x430e..0x4477  (361 bytes)
; ======================================================================


L_430E:
	ld hl,0e0f9h		;430e
	ld a,(hl)		;4311
	or a			;4312
	jp z,L_43FF		;4313
	call L_4BE2		;4316
	ld a,(0e0f9h)		;4319
	or a			;431c
	ret nz			;431d
	jp L_43FF		;431e
L_4321:
	ld hl,0e0e0h		;4321
	ld a,(hl)		;4324
	add a,001h		;4325
	daa			;4327
	ld (hl),a		;4328
	inc hl			;4329
	ld a,(hl)		;432a
	ld c,a			;432b
	inc a			;432c
	cp 00ah			;432d
	jr c,L_4335		;432f
	xor a			;4331
	ld (0e0e2h),a		;4332
L_4335:
	ld (hl),a		;4335
	ld a,c			;4336
	ld hl,0e0d5h		;4337
	call L_48CF		;433a
	ld a,(0e0e3h)		;433d
	ld (hl),a		;4340
	xor a			;4341
	ld (0e00dh),a		;4342
	ld hl,0e0e8h		;4345
	inc (hl)		;4348
	ld a,(hl)		;4349
	cp 00ah			;434a
	jr nz,L_4350		;434c
	ld (hl),000h		;434e
L_4350:
	ld a,(0e079h)		;4350
	ld h,a			;4353
	ld l,001h		;4354
	ld (0e138h),hl		;4356
	ld a,013h		;4359
	ld (0e100h),a		;435b
	jp L_43FF		;435e
L_4361:
	ld c,0ffh		;4361
	call L_54A3		;4363
	ret nz			;4366
	ld a,00ch		;4367
	ld (0e138h),a		;4369
	jp L_43FF		;436c
L_436F:
	ld c,000h		;436f
	ld a,(0e079h)		;4371
	ld h,a			;4374
	call L_54A3		;4375
	ret nz			;4378
	call L_669F		;4379
	call L_54E5		;437c
	call L_5549		;437f
	ld a,08fh		;4382
	call L_799F		;4384
	ld a,004h		;4387
	ld (0e001h),a		;4389
L_438C:
	ld a,(0e01ah)		;438c
	dec a			;438f
	ret nz			;4390
	call L_5585		;4391
	ld a,(0e0e1h)		;4394
	cp 002h			;4397
	jr nz,L_43A8		;4399
	ld a,(0e13ah)		;439b
	cp 00fh			;439e
	jr nz,L_43A8		;43a0
	call L_54FB		;43a2
	jp L_43FF		;43a5
L_43A8:
	call L_54E9		;43a8
	ld a,(0e13ah)		;43ab
	cp 010h			;43ae
	ret nz			;43b0
	jr L_43FF		;43b1
L_43B3:
	ld a,(0e012h)		;43b3
	or a			;43b6
	ret nz			;43b7
	ld a,010h		;43b8
	jr L_43FC		;43ba
L_43BC:
	ld hl,0e004h		;43bc
	ld a,(hl)		;43bf
	or a			;43c0
	jr z,L_43C5		;43c1
	dec (hl)		;43c3
	ret			;43c4
L_43C5:
	ld a,(0e003h)		;43c5
	and 003h		;43c8
	ret nz			;43ca
	ld hl,(0e0e3h)		;43cb
	ld a,h			;43ce
	add a,l			;43cf
	jr z,L_43FA		;43d0
	ld c,000h		;43d2
	call L_4671		;43d4
	ld de,00100h		;43d7
	call L_4614		;43da
	ld a,001h		;43dd
	call L_799F		;43df
	ret			;43e2
L_43E3:
	call L_45B1		;43e3
	ret p			;43e6
	ld a,008h		;43e7
	ld (0e000h),a		;43e9
L_43EC:
	ld a,050h		;43ec
L_43EE:
	ld (0e004h),a		;43ee
L_43F1:
	ld hl,0e000h		;43f1
	inc (hl)		;43f4
	xor a			;43f5
	ld (0e001h),a		;43f6
	ret			;43f9
L_43FA:
	ld a,050h		;43fa
L_43FC:
	ld (0e004h),a		;43fc
L_43FF:
	ld hl,0e001h		;43ff
	inc (hl)		;4402
	ret			;4403
L_4404:
	call L_458E		;4404
	ld a,(0e002h)		;4407
	rlca			;440a
	and 001h		;440b
	add a,031h		;440d
	ld de,03933h		;440f
	call L_48B1		;4412
	ret			;4415
L_4416:
	ld a,(0e13bh)		;4416
	or a			;4419
	ret nz			;441a
	ld a,(0e002h)		;441b
	bit 6,a			;441e
	ret nz			;4420
	ld a,050h		;4421
	out (0aah),a		;4423
	out (0aah),a		;4425
	in a,(0a9h)		;4427
	cpl			;4429
	and 006h		;442a
	ld b,040h		;442c
	cp 002h			;442e
	jr z,L_4437		;4430
	ld b,050h		;4432
	cp 004h			;4434
	ret nz			;4436
L_4437:
	xor a			;4437
	ld (0e133h),a		;4438
	ld a,b			;443b
	ld (0e002h),a		;443c
	pop hl			;443f
	ld a,007h		;4440
	ld (0e000h),a		;4442
	jp L_43EC		;4445
L_4448:
	ret			;4448
L_4449:
	ld hl,0e043h		;4449
	ld de,0e044h		;444c
	ld bc,00100h		;444f
	ld (hl),000h		;4452
	ldir			;4454
	ld hl,04477h		;4456
	ld de,0e0e0h		;4459
	ld bc,00009h		;445c
	ldir			;445f
	ld de,00900h		;4461
	ld bc,00100h		;4464
	ld a,0f0h		;4467
	call L_44EF		;4469
	ld b,00ah		;446c
	ld hl,0e0d5h		;446e
L_4471:
	ld (hl),005h		;4471
	inc hl			;4473
	djnz L_4471		;4474
	ret			;4476

; ----------------------------------------------------------------------
; DATOS valores_iniciales: Los nueve bytes que 0x4470 copia a 0xE0E0: fase 1, indice 0, y el resto a cero salvo 0xE0E4=2 y 0xE0E6=0x17. Solo los cinco primeros se usan: 0x425B machaca la distancia y el tiempo en cuanto empieza la fase
;   0x4477..0x4480  (9 bytes)
; ----------------------------------------------------------------------
	defb 001h,000h,000h,000h,002h,000h,017h,000h,000h	; 4477  .........

; ======================================================================
; CODIGO 0x4480..0x44d4  (84 bytes)
; ======================================================================


L_4480:
	call L_44B7		;4480
	ld a,007h		;4483
	out (0a0h),a		;4485
	ld a,0b8h		;4487
	out (0a1h),a		;4489
	call L_45FB		;448b
	call L_44A4		;448e
	ld de,00000h		;4491
	ld bc,04000h		;4494
L_4497:
	xor a			;4497
	call L_44EF		;4498
	ret			;449b
L_449C:
	ld de,03800h		;449c
	ld bc,00300h		;449f
	jr L_4497		;44a2
L_44A4:
	xor a			;44a4
	ld bc,003a0h		;44a5
	ld d,008h		;44a8
L_44AA:
	out (c),d		;44aa
	inc d			;44ac
	out (0a1h),a		;44ad
	djnz L_44AA		;44af
	ld a,095h		;44b1
	call L_799F		;44b3
	ret			;44b6
L_44B7:
	ld hl,044d4h		;44b7
	ld de,0e038h		;44ba
	ld bc,00008h		;44bd
	ldir			;44c0
	ld hl,0e038h		;44c2
	ld b,008h		;44c5
	ld d,080h		;44c7
L_44C9:
	ld e,(hl)		;44c9
	di			;44ca
	call L_48C7		;44cb
	ei			;44ce
	inc hl			;44cf
	inc d			;44d0
	djnz L_44C9		;44d1
	ret			;44d3

; ----------------------------------------------------------------------
; DATOS registros_vdp: Los ocho registros del VDP: 02 E2 0E 7F 07 76 03 E4. Colores en 0x0000 y patrones en 0x2000, al reves de lo corriente; nombres en 0x3800, patrones de sprite en 0x1800 y atributos de sprite en 0x3B00. Sprites de 16x16 sin ampliar, y SCREEN 2
;   0x44d4..0x44dc  (8 bytes)
; ----------------------------------------------------------------------
	defb 002h,0e2h,00eh,07fh,007h,076h,003h,0e1h	; 44d4  .....v..

; ======================================================================
; CODIGO 0x44dc..0x476e  (658 bytes)
; ======================================================================


L_44DC:
	di			;44dc
	set 6,d			;44dd
	call L_48C7		;44df
	res 6,d			;44e2
L_44E4:
	ld a,(hl)		;44e4
	out (098h),a		;44e5
	inc hl			;44e7
	dec bc			;44e8
	ld a,b			;44e9
	or c			;44ea
	jr nz,L_44E4		;44eb
	ei			;44ed
	ret			;44ee
L_44EF:
	di			;44ef
	ld h,a			;44f0
	set 6,d			;44f1
	call L_48C7		;44f3
	res 6,d			;44f6
L_44F8:
	ld a,h			;44f8
	out (098h),a		;44f9
	dec bc			;44fb
	ld a,b			;44fc
	or c			;44fd
	jr nz,L_44F8		;44fe
	ei			;4500
	ret			;4501
L_4502:
	ld a,(hl)		;4502
	inc hl			;4503
	ld (0e0dfh),a		;4504
	ld d,039h		;4507
L_4509:
	ld c,(hl)		;4509
	inc hl			;450a
	xor a			;450b
	cp c			;450c
	ret z			;450d
	ld b,a			;450e
	ld e,(hl)		;450f
	inc hl			;4510
	ld a,e			;4511
	cp 020h			;4512
	jr nc,L_4517		;4514
	inc d			;4516
L_4517:
	ld a,(0e0dfh)		;4517
	push hl			;451a
	push de			;451b
	call L_44EF		;451c
	pop de			;451f
	pop hl			;4520
	jr L_4509		;4521
L_4523:
	ld a,(hl)		;4523
	or a			;4524
	ret z			;4525
	and 0f0h		;4526
	ld c,a			;4528
	ld a,(hl)		;4529
	inc hl			;452a
	and 003h		;452b
	add a,078h		;452d
	ld d,a			;452f
	ld a,c			;4530
L_4531:
	ld b,(hl)		;4531
	inc hl			;4532
	ld a,020h		;4533
	add a,c			;4535
	ld c,a			;4536
	jr nc,L_453A		;4537
	inc d			;4539
L_453A:
	ld a,c			;453a
	add a,b			;453b
	sub 0e0h		;453c
	ld e,a			;453e
	call L_48C7		;453f
L_4542:
	ld a,(hl)		;4542
	or a			;4543
	ret z			;4544
	cp 0e0h			;4545
	jr nc,L_4531		;4547
	inc hl			;4549
	out (098h),a		;454a
	jr L_4542		;454c
L_454E:
	ld e,(hl)		;454e
	inc hl			;454f
	ld d,(hl)		;4550
	inc hl			;4551
L_4552:
	ld c,000h		;4552
	jr L_4558		;4554
L_4556:
	ld c,001h		;4556
L_4558:
	call L_48C7		;4558
L_455B:
	ld a,(hl)		;455b
	inc hl			;455c
	or a			;455d
	jr z,L_457C		;455e
	bit 7,a			;4560
	jr nz,L_4570		;4562
	ld b,a			;4564
	call L_457E		;4565
L_4568:
	out (098h),a		;4568
	push hl			;456a
	pop hl			;456b
	djnz L_4568		;456c
	jr L_455B		;456e
L_4570:
	res 7,a			;4570
	ld b,a			;4572
L_4573:
	call L_457E		;4573
	out (098h),a		;4576
	djnz L_4573		;4578
	jr L_455B		;457a
L_457C:
	ei			;457c
	ret			;457d
L_457E:
	ld a,(hl)		;457e
	inc hl			;457f
	bit 0,c			;4580
	ret z			;4582
	push bc			;4583
	ld b,008h		;4584
	ld c,a			;4586
L_4587:
	rr c			;4587
	rla			;4589
	djnz L_4587		;458a
	pop bc			;458c
	ret			;458d
L_458E:
	ld e,(hl)		;458e
	inc hl			;458f
	ld d,(hl)		;4590
	inc hl			;4591
L_4592:
	ld a,(hl)		;4592
	inc hl			;4593
	ld b,a			;4594
	inc b			;4595
	ret z			;4596
	inc b			;4597
	jr z,L_458E		;4598
	call L_48B1		;459a
	inc de			;459d
	jr L_4592		;459e
L_45A0:
	push hl			;45a0
	ld b,004h		;45a1
L_45A3:
	ld a,(hl)		;45a3
	ld (de),a		;45a4
	inc hl			;45a5
	inc de			;45a6
	djnz L_45A3		;45a7
	dec c			;45a9
	jr z,L_45AF		;45aa
	pop hl			;45ac
	jr L_45A0		;45ad
L_45AF:
	pop bc			;45af
	ret			;45b0
L_45B1:
	call L_45E6		;45b1
	ld d,038h		;45b4
	ld hl,0e004h		;45b6
	ld b,018h		;45b9
	bit 6,(hl)		;45bb
	jr nz,L_45C7		;45bd
	ld a,01fh		;45bf
	sub (hl)		;45c1
	ld e,a			;45c2
	set 6,(hl)		;45c3
	jr L_45CC		;45c5
L_45C7:
	res 6,(hl)		;45c7
	dec (hl)		;45c9
	ret m			;45ca
	ld e,(hl)		;45cb
L_45CC:
	ld a,(0e000h)		;45cc
	cp 00ah			;45cf
	jr c,L_45D9		;45d1
	ld a,040h		;45d3
	add a,e			;45d5
	ld e,a			;45d6
	dec b			;45d7
	dec b			;45d8
L_45D9:
	xor a			;45d9
	call L_48B1		;45da
	ld a,020h		;45dd
	call L_48D4		;45df
	djnz L_45D9		;45e2
	xor a			;45e4
	ret			;45e5
L_45E6:
	ld hl,0e050h		;45e6
	push hl			;45e9
	ld b,080h		;45ea
L_45EC:
	ld (hl),000h		;45ec
	inc hl			;45ee
	djnz L_45EC		;45ef
	ld de,03b00h		;45f1
	pop hl			;45f4
	ld bc,00080h		;45f5
	jp L_44DC		;45f8
L_45FB:
	ld a,00fh		;45fb
	out (0a0h),a		;45fd
	ld a,08fh		;45ff
	out (0a1h),a		;4601
	ret			;4603
L_4604:
	ld a,(0e009h)		;4604
	ld b,a			;4607
	ld a,(0e008h)		;4608
	and 030h		;460b
	cpl			;460d
	ld c,a			;460e
	ld a,b			;460f
	and 030h		;4610
	and c			;4612
	ret			;4613
L_4614:
	ld a,(0e002h)		;4614
	add a,a			;4617
	ret p			;4618
	ld hl,0e043h		;4619
	ld a,(hl)		;461c
	add a,e			;461d
	daa			;461e
	ld (hl),a		;461f
	ld e,a			;4620
	inc hl			;4621
	ld a,(hl)		;4622
	adc a,d			;4623
	daa			;4624
	ld (hl),a		;4625
	ld d,a			;4626
	inc hl			;4627
	jr nc,L_463E		;4628
	ld a,(hl)		;462a
	adc a,000h		;462b
	daa			;462d
	ld (hl),a		;462e
	jr nc,L_463E		;462f
	ld bc,09999h		;4631
	ld (0e040h),bc		;4634
	ld (0e041h),bc		;4638
	jr L_46B0		;463c
L_463E:
	ld a,(0e042h)		;463e
	ld b,(hl)		;4641
	sub (hl)		;4642
	jr c,L_464E		;4643
	jr nz,L_46B9		;4645
	ld hl,(0e040h)		;4647
	sbc hl,de		;464a
	jr nc,L_46B9		;464c
L_464E:
	ld (0e040h),de		;464e
	ld a,b			;4652
	ld (0e042h),a		;4653
	jr L_46B0		;4656
L_4658:
	ld a,(0e133h)		;4658
	or a			;465b
	ret z			;465c
	ld hl,(0e0e3h)		;465d
	ld a,h			;4660
	add a,l			;4661
	jr nz,L_4669		;4662
	inc a			;4664
	ld (0e00ch),a		;4665
	ret			;4668
L_4669:
	ld a,(0e003h)		;4669
	and 03fh		;466c
	ret nz			;466e
	ld c,001h		;466f
L_4671:
	ld hl,0e0e3h		;4671
	ld a,(hl)		;4674
	sub 001h		;4675
	daa			;4677
	ld (hl),a		;4678
	inc hl			;4679
	ld a,(hl)		;467a
	jr nc,L_4681		;467b
	sub 001h		;467d
	daa			;467f
	ld (hl),a		;4680
L_4681:
	dec hl			;4681
	or a			;4682
	jr nz,L_4696		;4683
	ld a,(hl)		;4685
	cp 011h			;4686
	jr nc,L_4696		;4688
	dec c			;468a
	jr nz,L_4696		;468b
	push af			;468d
	push hl			;468e
	ld a,009h		;468f
	call L_799F		;4691
	pop hl			;4694
	pop af			;4695
L_4696:
	ld b,002h		;4696
	ld de,03827h		;4698
	ld hl,0e0e4h		;469b
	jp L_470F		;469e
L_46A1:
	ld hl,0577ah		;46a1
	call L_458E		;46a4
	call L_4696		;46a7
	call L_46FD		;46aa
	call L_4707		;46ad
L_46B0:
	ld hl,0e042h		;46b0
	ld de,0380fh		;46b3
	call L_46BF		;46b6
L_46B9:
	ld de,03805h		;46b9
	ld hl,0e045h		;46bc
L_46BF:
	ld b,003h		;46bf
	jr L_470F		;46c1
L_46C3:
	ld hl,0e0e9h		;46c3
	dec (hl)		;46c6
	ret nz			;46c7
	ld a,(0e100h)		;46c8
	srl a			;46cb
	dec a			;46cd
	ld (hl),a		;46ce
	ld hl,0e0e6h		;46cf
	ld a,(hl)		;46d2
	dec hl			;46d3
	or (hl)			;46d4
	jr nz,L_46DC		;46d5
	inc a			;46d7
	ld (0e00dh),a		;46d8
	ret			;46db
L_46DC:
	ld a,(hl)		;46dc
	sub 001h		;46dd
	daa			;46df
	ld (hl),a		;46e0
	ld c,a			;46e1
	inc hl			;46e2
	jr nc,L_46EA		;46e3
	ld a,(hl)		;46e5
	sub 001h		;46e6
	daa			;46e8
	ld (hl),a		;46e9
L_46EA:
	ld a,c			;46ea
	or a			;46eb
	jr nz,L_46FA		;46ec
	or (hl)			;46ee
	jr z,L_46FA		;46ef
	ld a,(hl)		;46f1
	and 003h		;46f2
	jr nz,L_46FA		;46f4
	inc a			;46f6
	ld (0e107h),a		;46f7
L_46FA:
	call L_52BF		;46fa
L_46FD:
	ld b,002h		;46fd
	ld de,0382fh		;46ff
	ld hl,0e0e6h		;4702
	jr L_470F		;4705
L_4707:
	ld de,0381ch		;4707
	ld hl,0e0e0h		;470a
	ld b,001h		;470d
L_470F:
	ld a,(hl)		;470f
	push af			;4710
	and 00fh		;4711
	or 010h			;4713
	ld c,a			;4715
	pop af			;4716
	and 0f0h		;4717
	rra			;4719
	rra			;471a
	rra			;471b
	rra			;471c
	or 010h			;471d
	call L_48B1		;471f
	inc de			;4722
	ld a,c			;4723
	call L_48B1		;4724
	dec hl			;4727
	inc de			;4728
	djnz L_470F		;4729
	ret			;472b
L_472C:
	ld a,(0e0e0h)		;472c
	and 00fh		;472f
	ld hl,0476eh		;4731
	add a,a			;4734
	call L_48CF		;4735
	ld a,(0e0e6h)		;4738
	and 010h		;473b
	jr z,L_4740		;473d
	inc hl			;473f
L_4740:
	ld a,(hl)		;4740
	ld (0e18ah),a		;4741
	ld a,(0e0e0h)		;4744
	and 00fh		;4747
	ld hl,047aah		;4749
	add a,a			;474c
	call L_48CF		;474d
	ld e,(hl)		;4750
	inc hl			;4751
	ld d,(hl)		;4752
	ex de,hl		;4753
	ld a,(0e0e6h)		;4754
	and 0fch		;4757
	rrca			;4759
	rrca			;475a
	res 3,a			;475b
	cp 004h			;475d
	jr c,L_4762		;475f
	dec a			;4761
L_4762:
	add a,a			;4762
	call L_48CF		;4763
	ld e,(hl)		;4766
	inc hl			;4767
	ld d,(hl)		;4768
	ex de,hl		;4769
	ld (0e18bh),hl		;476a
	ret			;476d

; ----------------------------------------------------------------------
; DATOS decorado_por_fase: Dos bytes por fase, diez fases: 0x474A los indexa y el bit 4 de la distancia elige cual de los dos. Acaba justo donde empiezan las listas
;   0x476e..0x4782  (20 bytes)
; DATOS listas_de_decorado: Cinco listas de ocho bytes. Es a donde apuntan los veinte punteros de 0x47D7, y acaban clavadas donde empieza la tabla de fases
;   0x4782..0x47aa  (40 bytes)
; DATOS decorado_puntero_por_fase: Diez punteros, uno por fase, que apuntan DENTRO de la tabla de al lado con ventanas que se solapan. 0x4762 lo indexa
;   0x47aa..0x47be  (20 bytes)
; DATOS decorado_punteros: Veinte punteros a las cinco listas. Cierra clavado en 0x47FF, donde vuelve a haber codigo
;   0x47be..0x47e6  (40 bytes)
; ----------------------------------------------------------------------
	defb 080h,000h,0a0h,0a0h,050h,050h,0e0h,0e0h,050h,050h,000h,020h,0e0h,0e0h,020h,020h	; 476e  ....PP..PP. ..  
	defb 000h,000h,0ffh,0ffh,001h,005h,0ffh,000h,012h,005h,0ffh,000h,011h,001h,000h,012h	; 477e  ................
	defb 000h,001h,012h,000h,000h,0ffh,003h,011h,001h,005h,0ffh,003h,000h,0ffh,003h,003h	; 478e  ................
	defb 000h,011h,001h,012h,005h,0ffh,005h,0ffh,003h,012h,005h,0ffh,0deh,047h,0cch,047h	; 479e  .............G.G
	defb 0d4h,047h,0deh,047h,0d6h,047h,0d8h,047h,0e0h,047h,0cch,047h,0d8h,047h,0beh,047h	; 47ae  .G.G.G.G.G.G.G.G
	defb 09ah,047h,082h,047h,09ah,047h,082h,047h,0a2h,047h,092h,047h,082h,047h,092h,047h	; 47be  .G.G.G.G.G.G.G.G
	defb 08ah,047h,09ah,047h,08ah,047h,082h,047h,09ah,047h,08ah,047h,092h,047h,08ah,047h	; 47ce  .G.G.G.G.G.G.G.G
	defb 0a2h,047h,08ah,047h,0a2h,047h,08ah,047h	; 47de  .G.G.G.G

; ======================================================================
; CODIGO 0x47e6..0x4820  (58 bytes)
; ======================================================================


L_47E6:
	ld a,(0e18eh)		;47e6
	rra			;47e9
	ret nc			;47ea
	ld hl,0e18fh		;47eb
	dec (hl)		;47ee
	jr nz,L_47F5		;47ef
	xor a			;47f1
	ld (0e18eh),a		;47f2
L_47F5:
	ld c,003h		;47f5
	ret			;47f7
L_47F8:
	ld a,(0e0e0h)		;47f8
	and 00fh		;47fb
	ld hl,04820h		;47fd
	call L_48CF		;4800
	ld de,(0e0e5h)		;4803
	ld a,d			;4807
	cp 004h			;4808
	ret c			;480a
	ld a,e			;480b
	or a			;480c
	ret nz			;480d
	ld a,(0e0e0h)		;480e
	add a,d			;4811
	and 003h		;4812
	cp 002h			;4814
	ret nz			;4816
	inc a			;4817
	ld (0e18eh),a		;4818
	ld a,(hl)		;481b
	ld (0e18fh),a		;481c
	ret			;481f

; ----------------------------------------------------------------------
; DATOS duracion_sorpresa: Diez bytes, uno por fase: cuanto dura lo que enciende 0x4811. La fase 1 lleva 7 y las demas entre 2 y 6
;   0x4820..0x482a  (10 bytes)
; ----------------------------------------------------------------------
	defb 007h,002h,002h,003h,003h,004h,004h,005h,006h,006h	; 4820  ..........

; ======================================================================
; CODIGO 0x482a..0x48df  (181 bytes)
; ======================================================================


L_482A:
	call L_5858		;482a
	ld de,01080h		;482d
	ld bc,00180h		;4830
	ld a,070h		;4833
	call L_44EF		;4835
	xor a			;4838
	ld (0e00ah),a		;4839
	ld de,03966h		;483c
	ld bc,00013h		;483f
	jp L_44EF		;4842
L_4845:
	ld hl,0e00ah		;4845
	ld a,(hl)		;4848
	inc (hl)		;4849
	cp 017h			;484a
	jr nc,L_486A		;484c
	ld de,03885h		;484e
	ld c,a			;4851
	add a,e			;4852
	ld e,a			;4853
	ld a,c			;4854
	add a,a			;4855
	add a,0b2h		;4856
	ld c,a			;4858
	ld b,003h		;4859
	xor a			;485b
L_485C:
	call L_48B1		;485c
	ld a,020h		;485f
	call L_48D4		;4861
	ld a,c			;4864
	inc c			;4865
	djnz L_485C		;4866
	scf			;4868
	ret			;4869
L_486A:
	push af			;486a
	ld hl,057a9h		;486b
	call L_458E		;486e
	pop af			;4871
	cp 034h			;4872
	ret c			;4874
	or a			;4875
	ret			;4876
L_4877:
	ld hl,(0e00eh)		;4877
	ld de,00020h		;487a
	add hl,de		;487d
	ld (0e00eh),hl		;487e
	ex de,hl		;4881
	or a			;4882
	ld hl,03aaah		;4883
	sbc hl,de		;4886
	ex de,hl		;4888
	ld a,044h		;4889
	ld bc,00303h		;488b
L_488E:
	push de			;488e
L_488F:
	call L_48B1		;488f
	inc de			;4892
	inc a			;4893
	djnz L_488F		;4894
	pop de			;4896
	ld hl,00020h		;4897
	add hl,de		;489a
	ex de,hl		;489b
	ld h,a			;489c
	ld a,00eh		;489d
	sub c			;489f
	ld b,a			;48a0
	ld a,h			;48a1
	dec c			;48a2
	jr nz,L_488E		;48a3
	ld bc,0000ch		;48a5
	xor a			;48a8
	call L_44EF		;48a9
	ld hl,0e00ah		;48ac
	dec (hl)		;48af
	ret			;48b0
L_48B1:
	push af			;48b1
	set 6,d			;48b2
	call L_48C7		;48b4
	res 6,d			;48b7
	pop af			;48b9
	out (098h),a		;48ba
	ei			;48bc
	ret			;48bd
L_48BE:
	call L_48C7		;48be
	nop			;48c1
	nop			;48c2
	in a,(098h)		;48c3
	ei			;48c5
	ret			;48c6
L_48C7:
	di			;48c7
	ld a,e			;48c8
	out (099h),a		;48c9
	ld a,d			;48cb
	out (099h),a		;48cc
	ret			;48ce
L_48CF:
	add a,l			;48cf
	ld l,a			;48d0
	ret nc			;48d1
	inc h			;48d2
	ret			;48d3
L_48D4:
	add a,e			;48d4
	ld e,a			;48d5
	ret nc			;48d6
	inc d			;48d7
	ret			;48d8
L_48D9:
	ld a,(0e001h)		;48d9
	call L_4098		;48dc

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_48DF: Los 7 destinos del CALL de 0x48DC. Cierra clavada contra su primer destino
;   0x48df..0x48ed  (14 bytes)
; ----------------------------------------------------------------------
	defb 0edh,048h,007h,049h,00eh,049h,045h,049h,05fh,049h,06ch,049h,0c3h,049h	; 48df  .H.I.IEI_IlI.I

; ======================================================================
; CODIGO 0x48ed..0x49d0  (227 bytes)
; ======================================================================


L_48ED:
	ld hl,049d0h		;48ed
	ld (0e0f2h),hl		;48f0
	ld hl,03884h		;48f3
	ld (0e0f0h),hl		;48f6
	ld de,01080h		;48f9
	ld bc,00180h		;48fc
	ld a,0f4h		;48ff
	call L_44EF		;4901
	jp L_43FF		;4904
L_4907:
	ld de,03883h		;4907
	ld a,092h		;490a
	jr L_494A		;490c
L_490E:
	ld a,(0e003h)		;490e
	rra			;4911
	ret c			;4912
	ld hl,(0e0f0h)		;4913
	ld a,020h		;4916
	call L_48CF		;4918
	ld (0e0f0h),hl		;491b
	ex de,hl		;491e
	push de			;491f
	ld a,00ah		;4920
	ld bc,00018h		;4922
	call L_44EF		;4925
	pop de			;4928
	inc de			;4929
	ld a,004h		;492a
	ld c,016h		;492c
	call L_44EF		;492e
	ld hl,(0e0f2h)		;4931
	ld a,(hl)		;4934
	inc hl			;4935
	or a			;4936
	jp z,L_43FF		;4937
	ld e,a			;493a
	inc a			;493b
	jr z,L_4941		;493c
	call L_4592		;493e
L_4941:
	ld (0e0f2h),hl		;4941
	ret			;4944
L_4945:
	ld de,03aa3h		;4945
	ld a,091h		;4948
L_494A:
	call L_48B1		;494a
	inc de			;494d
	ld bc,00018h		;494e
	add a,004h		;4951
	push af			;4953
	call L_44EF		;4954
	pop af			;4957
	sub 002h		;4958
	out (098h),a		;495a
	jp L_43FF		;495c
L_495F:
	ld hl,03a14h		;495f
	ld (0e0f4h),hl		;4962
	xor a			;4965
	ld (0e0f6h),a		;4966
	jp L_43FF		;4969
L_496C:
	ld a,(0e003h)		;496c
	rra			;496f
	ret c			;4970
	ld hl,0e0f6h		;4971
	ld a,(hl)		;4974
	ld de,04a7ah		;4975
	call L_48D4		;4978
	ld a,(de)		;497b
	ld (0e0d0h),a		;497c
	cp 020h			;497f
	jp z,L_43FF		;4981
	inc (hl)		;4984
	ld c,097h		;4985
	ld a,(0e0e7h)		;4987
	cp (hl)			;498a
	jr c,L_498F		;498b
	ld c,0a4h		;498d
L_498F:
	ld hl,0e0d0h		;498f
	xor a			;4992
	rrd			;4993
	ld b,a			;4995
	ld a,(hl)		;4996
	ld hl,L_49B0		;4997
	call L_48CF		;499a
	ld de,(0e0f4h)		;499d
	call L_49AF		;49a1
	ld (0e0f4h),de		;49a4
	ld a,b			;49a8
	add a,c			;49a9
	call L_48B1		;49aa
	scf			;49ad
	ret			;49ae
L_49AF:
	jp (hl)			;49af
L_49B0:
	ld a,0e0h		;49b0
	jr L_49BE		;49b2
L_49B4:
	ld a,001h		;49b4
	jr L_49BF		;49b6
L_49B8:
	ld a,020h		;49b8
	jr L_49BF		;49ba
L_49BC:
	ld a,0ffh		;49bc
L_49BE:
	dec d			;49be
L_49BF:
	call L_48D4		;49bf
	ret			;49c2
L_49C3:
	ld hl,0e004h		;49c3
	dec (hl)		;49c6
	ret nz			;49c7
	ld a,009h		;49c8
	ld (0e000h),a		;49ca
	jp L_43EC		;49cd

; ----------------------------------------------------------------------
; DATOS mapa_dibujo: Las filas del mapa, una detras de otra: un byte de columna y detras las casillas, o un 0xFF si la fila va vacia. El 0x00 de 0x4AAF lo cierra. Son dieciseis filas, y la ultima es el rotulo ANTARCTICA (c)KONAMI
;   0x49d0..0x4a7a  (170 bytes)
; DATOS mapa_recorrido: Los cuarenta pasos del camino: nibble alto la direccion (0 arriba, 4 derecha, 8 abajo, C izquierda) y nibble bajo la casilla que se dibuja. El 0x20 de 0x4AD8 lo cierra
;   0x4a7a..0x4aa3  (41 bytes)
; DATOS tabla_de_fases: Las DIEZ fases, cuatro bytes cada una: centenas de metros, casilla del mapa donde empieza, y el tiempo en BCD. Cierra clavada en 0x4B01, donde vuelve a haber codigo. Salen 1500 m/100 s, 1700/120, 1100/80, 1200/80, 1200/80, 500/40, 2600/165, 1200/90, 1500/100 y 1200/90
;   0x4aa3..0x4acb  (40 bytes)
; ----------------------------------------------------------------------
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
	defb 029h,023h,021h,004h,004h,004h,004h,0ffh,0ffh,000h,0c4h,0c4h,0c0h,00bh,002h,002h	; 4a70  )#!.............
	defb 0c5h,00ch,0c5h,0c5h,0c6h,086h,087h,0c5h,002h,00ch,00ah,009h,048h,043h,00ch,00ch	; 4a80  ............HC..
	defb 001h,045h,045h,045h,042h,085h,047h,042h,082h,082h,085h,04bh,082h,082h,08bh,0c4h	; 4a90  .EEEB.GB...K....
	defb 082h,08bh,020h,015h,000h,000h,001h,017h,003h,020h,001h,011h,008h,080h,000h,012h	; 4aa0  .. ...... ......
	defb 00ch,080h,000h,012h,010h,080h,000h,005h,015h,040h,000h,026h,016h,065h,001h,012h	; 4ab0  .........@.&.e..
	defb 01dh,090h,000h,015h,022h,000h,001h,012h,025h,090h,000h	; 4ac0  ...."...%..

; ======================================================================
; CODIGO 0x4acb..0x4b4e  (131 bytes)
; ======================================================================


L_4ACB:
	ld hl,0e0f0h		;4acb
	ld de,0e0f1h		;4ace
	ld bc,00130h		;4ad1
	ld (hl),000h		;4ad4
	ldir			;4ad6
	ld a,010h		;4ad8
	ld h,a			;4ada
	ld l,a			;4adb
	ld (0e100h),hl		;4adc
	ld (0e110h),a		;4adf
	ld a,008h		;4ae2
	ld (0e149h),a		;4ae4
	ld a,005h		;4ae7
	ld (0e0e9h),a		;4ae9
	ld hl,03030h		;4aec
	ld a,(0e0e0h)		;4aef
	rra			;4af2
	jr nc,L_4AF8		;4af3
	ld hl,03434h		;4af5
L_4AF8:
	ld (0e10eh),hl		;4af8
	ld a,001h		;4afb
	ld (0e13bh),a		;4afd
	call L_5DCA		;4b00
	call L_6267		;4b03
	call L_672E		;4b06
	call L_669A		;4b09
	call L_500E		;4b0c
	xor a			;4b0f
	ld (0e13bh),a		;4b10
	ret			;4b13
L_4B14:
	call L_7740		;4b14
	call L_7641		;4b17
	ld a,(0e140h)		;4b1a
	or a			;4b1d
	jp nz,L_4F5E		;4b1e
	ld a,(0e142h)		;4b21
	or a			;4b24
	jp nz,L_4E33		;4b25
	call L_76B6		;4b28
	call L_4B76		;4b2b
	call L_5380		;4b2e
	call L_4D9C		;4b31
	call L_4DD9		;4b34
	ld a,(0e140h)		;4b37
	or a			;4b3a
	ret nz			;4b3b
	call L_5169		;4b3c
	call L_74F1		;4b3f
	call L_46C3		;4b42
	call L_472C		;4b45
	call L_51F1		;4b48
	jp L_777B		;4b4b

; ----------------------------------------------------------------------
; DATOS poses_del_pinguino: Diez poses de cuatro bytes: los cuatro patrones de sprite que forman el pinguino en cada postura. 0x4BD5 las reparte de cuatro en cuatro por los atributos
;   0x4b4e..0x4b76  (40 bytes)
; ----------------------------------------------------------------------
	defb 000h,004h,008h,00ch,010h,014h,018h,01ch,020h,024h,028h,02ch,000h,004h,030h,034h	; 4b4e  ........ $(,..04
	defb 038h,03ch,040h,044h,060h,064h,068h,06ch,020h,048h,04ch,050h,054h,014h,058h,05ch	; 4b5e  8<@D`dhl HLPT.X\
	defb 010h,0a8h,018h,0ach,0b0h,024h,0b4h,02ch	; 4b6e  .....$.,

; ======================================================================
; CODIGO 0x4b76..0x4c4a  (212 bytes)
; ======================================================================


L_4B76:
	ld hl,0e0f9h		;4b76
	ld a,(hl)		;4b79
	or a			;4b7a
	jp nz,L_4BE2		;4b7b
	call L_4604		;4b7e
	jp nz,L_4BCE		;4b81
	ld a,b			;4b84
	ld de,(0e078h)		;4b85
	call L_4C56		;4b89
L_4B8C:
	ex de,hl		;4b8c
L_4B8D:
	call L_4BB6		;4b8d
L_4B90:
	ld hl,0e078h		;4b90
	ld de,03b28h		;4b93
	ld bc,00010h		;4b96
	call L_44DC		;4b99
	jp L_4CB3		;4b9c
L_4B9F:
	exx			;4b9f
	ld hl,04b4eh		;4ba0
	call L_48CF		;4ba3
	ld de,0e07ah		;4ba6
	ld b,004h		;4ba9
L_4BAB:
	ld a,(hl)		;4bab
	ld (de),a		;4bac
	ld a,004h		;4bad
	add a,e			;4baf
	ld e,a			;4bb0
	inc hl			;4bb1
	djnz L_4BAB		;4bb2
	exx			;4bb4
	ret			;4bb5
L_4BB6:
	ld d,h			;4bb6
	ld (0e078h),hl		;4bb7
	ld a,h			;4bba
	add a,010h		;4bbb
	ld h,a			;4bbd
	ld (0e07ch),hl		;4bbe
	ld a,l			;4bc1
	add a,010h		;4bc2
	ld l,a			;4bc4
	ld e,a			;4bc5
	ld (0e080h),de		;4bc6
	ld (0e084h),hl		;4bca
	ret			;4bcd
L_4BCE:
	ld a,002h		;4bce
	call L_799F		;4bd0
	ld a,b			;4bd3
	and 00ch		;4bd4
	jr z,L_4BDD		;4bd6
	ld a,(0e0fah)		;4bd8
	and 003h		;4bdb
L_4BDD:
	ld (0e0fbh),a		;4bdd
	jr L_4BE8		;4be0
L_4BE2:
	ld a,(0e003h)		;4be2
	and 003h		;4be5
	ret nz			;4be7
L_4BE8:
	ld a,(hl)		;4be8
	inc (hl)		;4be9
	cp 00bh			;4bea
	jr nz,L_4BF0		;4bec
	ld (hl),000h		;4bee
L_4BF0:
	push af			;4bf0
	ld c,000h		;4bf1
	cp 00bh			;4bf3
	jr z,L_4BFE		;4bf5
	ld c,010h		;4bf7
	rra			;4bf9
	jr c,L_4BFE		;4bfa
	ld c,00ch		;4bfc
L_4BFE:
	ld a,c			;4bfe
	call L_4B9F		;4bff
	pop af			;4c02
	ld hl,04c4ah		;4c03
	call L_48CF		;4c06
	ld a,(hl)		;4c09
	ld de,(0e078h)		;4c0a
	add a,e			;4c0e
	ld e,a			;4c0f
	ld hl,0e0fbh		;4c10
	ld a,(hl)		;4c13
	dec a			;4c14
	jr z,L_4C3A		;4c15
	dec a			;4c17
	jr z,L_4C42		;4c18
L_4C1A:
	ex de,hl		;4c1a
	call L_4B8D		;4c1b
	ld a,(0e0f9h)		;4c1e
	or a			;4c21
	ret nz			;4c22
	call L_4D13		;4c23
	ld a,(0e140h)		;4c26
	ld hl,0e142h		;4c29
	add a,(hl)		;4c2c
	ret nz			;4c2d
	ld hl,0e132h		;4c2e
	cp (hl)			;4c31
	ret z			;4c32
	ld (hl),a		;4c33
	ld de,00030h		;4c34
	jp L_4614		;4c37
L_4C3A:
	call L_4C66		;4c3a
	call L_4C66		;4c3d
	jr L_4C1A		;4c40
L_4C42:
	call L_4C83		;4c42
	call L_4C83		;4c45
	jr L_4C1A		;4c48

; ----------------------------------------------------------------------
; DATOS curva_del_salto: Doce correcciones con signo para la Y del pinguino: -4,-3,-3,-2,-1,-1,+1,+1,+2,+3,+3,+4. Es el arco del salto, y tambien el balanceo de andar
;   0x4c4a..0x4c56  (12 bytes)
; ----------------------------------------------------------------------
	defb 0fch,0fdh,0fdh,0feh,0ffh,0ffh,001h,001h,002h,003h,003h,004h	; 4c4a  ............

; ======================================================================
; CODIGO 0x4c56..0x4cf4  (158 bytes)
; ======================================================================


L_4C56:
	and 00ch		;4c56
	ret z			;4c58
	ld hl,0e0fah		;4c59
	cp 00ch			;4c5c
	jr z,L_4C70		;4c5e
	res 7,(hl)		;4c60
	cp 004h			;4c62
	jr nz,L_4C83		;4c64
L_4C66:
	ld a,d			;4c66
	cp 014h			;4c67
	ret c			;4c69
	dec d			;4c6a
	set 0,(hl)		;4c6b
	res 1,(hl)		;4c6d
	ret			;4c6f
L_4C70:
	ld a,(hl)		;4c70
	or a			;4c71
	ret z			;4c72
	bit 7,a			;4c73
	jr z,L_4C7D		;4c75
	bit 0,a			;4c77
	jr nz,L_4C66		;4c79
	jr L_4C83		;4c7b
L_4C7D:
	set 7,(hl)		;4c7d
	bit 1,a			;4c7f
	jr nz,L_4C66		;4c81
L_4C83:
	ld a,d			;4c83
	cp 0cch			;4c84
	ret nc			;4c86
	set 1,(hl)		;4c87
	res 0,(hl)		;4c89
	inc d			;4c8b
	ret			;4c8c
L_4C8D:
	ld hl,0e0f9h		;4c8d
	ld a,(0e130h)		;4c90
	or (hl)			;4c93
	ret nz			;4c94
	ld a,(0e003h)		;4c95
	and 007h		;4c98
	ret nz			;4c9a
L_4C9B:
	ld hl,0e0f8h		;4c9b
	inc (hl)		;4c9e
	ld a,(hl)		;4c9f
	ld c,000h		;4ca0
	rra			;4ca2
	jr nc,L_4CAC		;4ca3
	ld c,004h		;4ca5
	rra			;4ca7
	jr nc,L_4CAC		;4ca8
	ld c,008h		;4caa
L_4CAC:
	ld a,c			;4cac
	call L_4B9F		;4cad
	jp L_4B90		;4cb0
L_4CB3:
	ld hl,(0e078h)		;4cb3
	ld a,l			;4cb6
	add a,01eh		;4cb7
	ld l,a			;4cb9
	ld c,a			;4cba
	ld a,h			;4cbb
	add a,010h		;4cbc
	ld b,a			;4cbe
	ld de,04cf3h		;4cbf
	ld a,(0e0f9h)		;4cc2
	or a			;4cc5
	jr nz,L_4CD1		;4cc6
	ld de,04cfdh		;4cc8
	ld a,(0e143h)		;4ccb
	or a			;4cce
	jr z,L_4CE1		;4ccf
L_4CD1:
	ex de,hl		;4cd1
	call L_48CF		;4cd2
	ld l,(hl)		;4cd5
	ld a,d			;4cd6
	add a,l			;4cd7
	ld d,a			;4cd8
	ld a,b			;4cd9
	sub l			;4cda
	ld b,a			;4cdb
	ld e,0aeh		;4cdc
	ld c,0aeh		;4cde
	ex de,hl		;4ce0
L_4CE1:
	ld (0e0a0h),hl		;4ce1
	ld (0e0a4h),bc		;4ce4
L_4CE8:
	ld hl,0e0a0h		;4ce8
	ld de,03b50h		;4ceb
	ld bc,00008h		;4cee
	jp L_44DC		;4cf1

; ----------------------------------------------------------------------
; DATOS arco_del_salto: Diez alturas, indexadas de 1 a 10 desde 0x4D29: lo que se separa la sombra en cada paso del salto
;   0x4cf4..0x4cfe  (10 bytes)
; DATOS arco_de_la_caida: Veintiuna alturas, indexadas de 1 a 21 desde 0x4D33 con 0xE143, que es el contador de la caida. Cierra clavada en 0x4D49
;   0x4cfe..0x4d13  (21 bytes)
; ----------------------------------------------------------------------
	defb 001h,002h,002h,003h,003h,003h,003h,003h,002h,002h,001h,001h,002h,002h,003h,002h	; 4cf4  ................
	defb 002h,001h,000h,001h,002h,002h,002h,001h,000h,001h,002h,002h,002h,001h,000h	; 4d04  ...............

; ======================================================================
; CODIGO 0x4d13..0x4d92  (127 bytes)
; ======================================================================


L_4D13:
	ld a,(0e0f9h)		;4d13
	or a			;4d16
	ret nz			;4d17
	ld b,004h		;4d18
	ld a,(0e0e0h)		;4d1a
	cp 005h			;4d1d
	jr c,L_4D22		;4d1f
	inc b			;4d21
L_4D22:
	ld hl,0e112h		;4d22
L_4D25:
	ld a,(hl)		;4d25
	cp 00dh			;4d26
	ld a,005h		;4d28
	jr nz,L_4D59		;4d2a
	inc hl			;4d2c
	ld c,(hl)		;4d2d
	inc hl			;4d2e
	inc hl			;4d2f
	inc hl			;4d30
	ld e,(hl)		;4d31
	inc hl			;4d32
	ld d,(hl)		;4d33
	ex de,hl		;4d34
	dec a			;4d35
	cp c			;4d36
	ld a,(0e079h)		;4d37
	jr nc,L_4D44		;4d3a
	sub (hl)		;4d3c
	inc hl			;4d3d
	cp (hl)			;4d3e
	jp c,L_4FE6		;4d3f
	jr L_4D57		;4d42
L_4D44:
	ld c,(hl)		;4d44
	dec c			;4d45
	jr z,L_4D50		;4d46
	ld c,a			;4d48
	sub (hl)		;4d49
	inc hl			;4d4a
	cp (hl)			;4d4b
	jp c,L_4F15		;4d4c
	ld a,c			;4d4f
L_4D50:
	inc hl			;4d50
	sub (hl)		;4d51
	inc hl			;4d52
	cp (hl)			;4d53
	jp c,L_4DF0		;4d54
L_4D57:
	ex de,hl		;4d57
	xor a			;4d58
L_4D59:
	inc a			;4d59
	call L_48CF		;4d5a
	djnz L_4D25		;4d5d
	ret			;4d5f
L_4D60:
	ld a,(0e0f9h)		;4d60
	or a			;4d63
	ret z			;4d64
	ld b,005h		;4d65
	ld hl,0e112h		;4d67
L_4D6A:
	ld a,(hl)		;4d6a
	inc hl			;4d6b
	cp 00dh			;4d6c
	ld a,005h		;4d6e
	jr nz,L_4D86		;4d70
	ex de,hl		;4d72
	ld a,(de)		;4d73
	cp 005h			;4d74
	add a,a			;4d76
	ld hl,04d92h		;4d77
	call L_48CF		;4d7a
	ld a,(0e079h)		;4d7d
	sub (hl)		;4d80
	inc hl			;4d81
	cp (hl)			;4d82
	jr c,L_4D8C		;4d83
	ex de,hl		;4d85
L_4D86:
	call L_48CF		;4d86
	djnz L_4D6A		;4d89
	ret			;4d8b
L_4D8C:
	ld a,001h		;4d8c
	ld (0e132h),a		;4d8e
	ret			;4d91

; ----------------------------------------------------------------------
; DATOS choque_en_el_aire: Cinco pares (posicion, ancho) para los choques con el pinguino saltando: 0x58/0x30, 0x18/0x30, 0x98/0x30, 0x2C/0x58 y 0x64/0x58
;   0x4d92..0x4d9c  (10 bytes)
; ----------------------------------------------------------------------
	defb 058h,030h,018h,030h,098h,030h,02ch,058h,064h,058h	; 4d92  X0.0.0,XdX

; ======================================================================
; CODIGO 0x4d9c..0x4eb7  (283 bytes)
; ======================================================================


L_4D9C:
	ld a,(0e142h)		;4d9c
	ld hl,0e140h		;4d9f
	add a,(hl)		;4da2
	ret nz			;4da3
	ld de,(0e188h)		;4da4
	ld a,e			;4da8
	cp 0e0h			;4da9
	ret z			;4dab
	ld hl,(0e078h)		;4dac
	sub l			;4daf
	ld e,a			;4db0
	sub 00ah		;4db1
	ret nc			;4db3
	ld a,013h		;4db4
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
	call L_799F		;4dc4
	ld hl,0e08ch		;4dc7
	ld de,0e183h		;4dca
	call L_769B		;4dcd
	call L_7646		;4dd0
	ld de,00300h		;4dd3
	jp L_4614		;4dd6
L_4DD9:
	ld hl,(0e090h)		;4dd9
	ld a,l			;4ddc
	cp 08fh			;4ddd
	ret nz			;4ddf
	ld a,(0e079h)		;4de0
	ld l,a			;4de3
	ld a,h			;4de4
	sub l			;4de5
	push af			;4de6
	sub 018h		;4de7
	add a,023h		;4de9
	jp c,L_4E04		;4deb
	pop af			;4dee
	ret			;4def
L_4DF0:
	ld a,(0e135h)		;4df0
	or a			;4df3
	ret nz			;4df4
	ld a,003h		;4df5
	call L_799F		;4df7
	ld hl,00101h		;4dfa
	ld a,(0e0fah)		;4dfd
	cpl			;4e00
	rra			;4e01
	jr L_4E1A		;4e02
L_4E04:
	ld hl,00101h		;4e04
	ld (0e136h),hl		;4e07
	ld a,008h		;4e0a
	call L_799F		;4e0c
	ld hl,00102h		;4e0f
	ld a,(0e0f9h)		;4e12
	or a			;4e15
	jr z,L_4E19		;4e16
	inc l			;4e18
L_4E19:
	pop af			;4e19
L_4E1A:
	ld (0e142h),hl		;4e1a
	ld a,020h		;4e1d
	jr nc,L_4E23		;4e1f
	ld a,024h		;4e21
L_4E23:
	ld (0e144h),a		;4e23
	call L_4B9F		;4e26
	call L_4B90		;4e29
	ld hl,01313h		;4e2c
	ld (0e100h),hl		;4e2f
	ret			;4e32
L_4E33:
	ld a,(0e003h)		;4e33
	and 003h		;4e36
	ret nz			;4e38
	ld hl,0e142h		;4e39
	ld a,(hl)		;4e3c
	cp 003h			;4e3d
	jp z,L_4ECB		;4e3f
	inc hl			;4e42
	ld a,(hl)		;4e43
	inc (hl)		;4e44
	ld hl,l4eb6h		;4e45
	call L_48CF		;4e48
	ld c,(hl)		;4e4b
	ld de,(0e078h)		;4e4c
L_4E50:
	ld hl,0e0d0h		;4e50
	ld a,(0e144h)		;4e53
	bit 2,a			;4e56
	call z,L_4EAC	;4e58
	call nz,L_4EA3	;4e5b
	ld hl,0e142h		;4e5e
	ld a,(hl)		;4e61
	dec a			;4e62
	jr z,L_4E68		;4e63
	dec (hl)		;4e65
	jr L_4E50		;4e66
L_4E68:
	ex de,hl		;4e68
	ld a,l			;4e69
	add a,c			;4e6a
	ld l,a			;4e6b
	call L_4B8D		;4e6c
	ld a,(0e078h)		;4e6f
	cp 090h			;4e72
	jr nz,L_4E95		;4e74
L_4E76:
	ld a,004h		;4e76
	call L_799F		;4e78
	call L_517A		;4e7b
	call L_5183		;4e7e
	xor a			;4e81
	ld b,a			;4e82
	ld hl,0e136h		;4e83
	cp (hl)			;4e86
	jr z,L_4E8E		;4e87
	ld (hl),a		;4e89
	inc a			;4e8a
	ld (0e135h),a		;4e8b
L_4E8E:
	call L_51A4		;4e8e
	xor a			;4e91
	ld (0e135h),a		;4e92
L_4E95:
	ld hl,0e143h		;4e95
	ld a,(hl)		;4e98
	sub 015h		;4e99
	ret nz			;4e9b
	ld (hl),a		;4e9c
	dec hl			;4e9d
	ld (hl),a		;4e9e
	ld (0e137h),a		;4e9f
	ret			;4ea2
L_4EA3:
	call L_4C83		;4ea3
	call L_4C83		;4ea6
	jp L_4C83		;4ea9
L_4EAC:
	call L_4C66		;4eac
	call L_4C66		;4eaf
	call L_4C66		;4eb2
	xor a			;4eb5
L_4EB6:
	ret			;4eb6

; ----------------------------------------------------------------------
; DATOS rodada_de_la_caida: Veinte desplazamientos con signo, indexados de 1 a 20 desde 0x4EEC con 0xE143. Son tres tramos casi iguales: cada vuelta el pinguino rueda un poco menos
;   0x4eb7..0x4ecb  (20 bytes)
; ----------------------------------------------------------------------
	defb 0fdh,0feh,0feh,0ffh,001h,002h,002h,003h,0feh,0feh,0ffh,001h,002h,002h,0feh,0feh	; 4eb7  ................
	defb 0ffh,001h,002h,002h	; 4ec7  ....

; ======================================================================
; CODIGO 0x4ecb..0x510f  (580 bytes)
; ======================================================================


L_4ECB:
	ld hl,0e0f9h		;4ecb
	ld a,(hl)		;4ece
	inc (hl)		;4ecf
	cp 00bh			;4ed0
	jr nz,L_4ED6		;4ed2
	ld (hl),000h		;4ed4
L_4ED6:
	push af			;4ed6
	ld a,(0e144h)		;4ed7
	ld c,a			;4eda
	call L_4B9F		;4edb
	pop af			;4ede
	ld hl,04c4ah		;4edf
	call L_48CF		;4ee2
	ld a,(hl)		;4ee5
	ld de,(0e078h)		;4ee6
	add a,e			;4eea
	ld e,a			;4eeb
	bit 2,c			;4eec
	ld hl,0e0d0h		;4eee
	call z,L_4EAC		;4ef1
	call nz,L_4EA3		;4ef4
	ex de,hl		;4ef7
	call L_4B8D		;4ef8
	ld a,(0e0f9h)		;4efb
	or a			;4efe
	ret nz			;4eff
	ld a,001h		;4f00
	ld (0e135h),a		;4f02
	call L_4E76		;4f05
	xor a			;4f08
	ld (0e135h),a		;4f09
	dec hl			;4f0c
	inc a			;4f0d
	ld (hl),a		;4f0e
	ld a,004h		;4f0f
	call L_799F		;4f11
	ret			;4f14
L_4F15:
	ld hl,00001h		;4f15
	ld (0e140h),hl		;4f18
	xor a			;4f1b
	ld (0e142h),a		;4f1c
	ld a,0ffh		;4f1f
	ld (0e0f8h),a		;4f21
	ld a,005h		;4f24
	call L_799F		;4f26
	ld hl,0e068h		;4f29
	ld bc,004b6h		;4f2c
L_4F2F:
	ld (hl),c		;4f2f
	ld a,004h		;4f30
	call L_48CF		;4f32
	djnz L_4F2F		;4f35
L_4F37:
	ld hl,(0e078h)		;4f37
	ld l,09fh		;4f3a
	call L_4BB6		;4f3c
	ld a,010h		;4f3f
	call L_4B9F		;4f41
	ld a,0e0h		;4f44
	ld (0e0a0h),a		;4f46
	ld hl,0e00ah		;4f49
	ld (0e0a3h),hl		;4f4c
L_4F4F:
	ld hl,0e068h		;4f4f
	ld de,03b18h		;4f52
	ld bc,00020h		;4f55
	call L_44DC		;4f58
	jp L_4CE8		;4f5b
L_4F5E:
	ld hl,0e141h		;4f5e
	inc (hl)		;4f61
	res 7,(hl)		;4f62
	ld a,(hl)		;4f64
	cp 020h			;4f65
	jr c,L_4F37		;4f67
	call L_4604		;4f69
	jr nz,L_4FAC		;4f6c
	ld a,(0e003h)		;4f6e
	ld c,a			;4f71
	and 007h		;4f72
	ret nz			;4f74
	ld a,008h		;4f75
	ld b,099h		;4f77
	ld de,01470h		;4f79
	bit 3,c			;4f7c
	jr z,L_4F90		;4f7e
	ld a,004h		;4f80
	ld b,096h		;4f82
	ld de,01874h		;4f84
	bit 4,c			;4f87
	jr z,L_4F90		;4f89
	ld a,00bh		;4f8b
	ld de,01c78h		;4f8d
L_4F90:
	ld hl,(0e078h)		;4f90
	ld l,b			;4f93
	add a,h			;4f94
	ld c,a			;4f95
	ld a,b			;4f96
	ld b,e			;4f97
	ld (0e0a1h),bc		;4f98
	add a,010h		;4f9c
	ld (0e0a0h),a		;4f9e
	push de			;4fa1
	call L_4BB6		;4fa2
	pop af			;4fa5
	call L_4B9F		;4fa6
	jp L_4F4F		;4fa9
L_4FAC:
	xor a			;4fac
	ld (0e140h),a		;4fad
	ld (0e0f8h),a		;4fb0
	ld hl,00313h		;4fb3
	ld (0e100h),hl		;4fb6
	ld a,(0e079h)		;4fb9
	push af			;4fbc
	ld hl,066c8h		;4fbd
	ld de,0e068h		;4fc0
	ld c,004h		;4fc3
	call L_45A0		;4fc5
	ld b,004h		;4fc8
L_4FCA:
	ld c,(hl)		;4fca
	inc hl			;4fcb
	push bc			;4fcc
	call L_45A0		;4fcd
	pop bc			;4fd0
	djnz L_4FCA		;4fd1
	pop hl			;4fd3
	ld l,090h		;4fd4
	call L_4BB6		;4fd6
	ld hl,004a0h		;4fd9
	ld (0e0a2h),hl		;4fdc
	call L_4B90		;4fdf
	call L_66BB		;4fe2
	ret			;4fe5
L_4FE6:
	ex de,hl		;4fe6
	dec hl			;4fe7
	dec hl			;4fe8
	ld d,(hl)		;4fe9
	dec hl			;4fea
	ld e,(hl)		;4feb
	dec hl			;4fec
	dec hl			;4fed
	ld (hl),000h		;4fee
	ex de,hl		;4ff0
	inc hl			;4ff1
	ld de,0e1a0h		;4ff2
	ld bc,0000dh		;4ff5
	ldir			;4ff8
	xor a			;4ffa
	ld (de),a		;4ffb
	ld a,006h		;4ffc
	call L_799F		;4ffe
	ld hl,0e1a0h		;5001
	call L_4523		;5004
	ld de,00500h		;5007
	call L_4614		;500a
	ret			;500d
L_500E:
	ld a,(0e0e1h)		;500e
	ld hl,0515fh		;5011
	call L_48CF		;5014
	ld a,007h		;5017
	bit 0,(hl)		;5019
	jr z,L_501F		;501b
	ld a,009h		;501d
L_501F:
	ld (0e10ch),a		;501f
	ld a,(hl)		;5022
	ld hl,05dbch		;5023
	ld de,0621eh		;5026
	or a			;5029
	jr z,L_5032		;502a
	ld hl,05dc7h		;502c
	ld de,0623bh		;502f
L_5032:
	push de			;5032
	ld de,04588h		;5033
	call L_4552		;5036
	pop hl			;5039
	ld de,04f78h		;503a
	call L_4552		;503d
	ld de,03860h		;5040
	ld bc,000e0h		;5043
	ld a,(0e10ch)		;5046
	call L_44EF		;5049
	ld de,03940h		;504c
	ld bc,001c0h		;504f
	ld a,00fh		;5052
	call L_44EF		;5054
	ld hl,07229h		;5057
	call L_50BC		;505a
	ld hl,07266h		;505d
	call L_50BC		;5060
	ld hl,0510fh		;5063
	ld a,(0e0e1h)		;5066
	add a,a			;5069
	add a,a			;506a
	add a,a			;506b
	call L_48CF		;506c
	ld (0e10ah),hl		;506f
	xor a			;5072
	ld (0e102h),a		;5073
	ld (0e108h),a		;5076
	ld hl,07221h		;5079
	ld (0e103h),hl		;507c
	ld hl,0725eh		;507f
	ld (0e105h),hl		;5082
	call L_517A		;5085
	call L_518A		;5088
	ret			;508b
L_508C:
	ld hl,0e108h		;508c
	ld a,(hl)		;508f
	inc (hl)		;5090
	ld hl,(0e10ah)		;5091
	call L_48CF		;5094
	ld a,(hl)		;5097
	cp 0ffh			;5098
	ret z			;509a
	ld (0e109h),a		;509b
	ld bc,0e103h		;509e
	bit 0,a			;50a1
	jr z,L_50A7		;50a3
	inc bc			;50a5
	inc bc			;50a6
L_50A7:
	add a,a			;50a7
	ld hl,07219h		;50a8
	call L_48CF		;50ab
	ld a,(hl)		;50ae
	ld e,a			;50af
	ld (bc),a		;50b0
	inc hl			;50b1
	inc bc			;50b2
	ld a,(hl)		;50b3
	ld d,a			;50b4
	ld (bc),a		;50b5
	ex de,hl		;50b6
	ld a,008h		;50b7
	call L_48CF		;50b9
L_50BC:
	call L_4502		;50bc
	call L_458E		;50bf
	ld e,(hl)		;50c2
L_50C3:
	ld a,(0e10ch)		;50c3
	ld c,a			;50c6
	ld b,010h		;50c7
	ld d,0e1h		;50c9
L_50CB:
	inc hl			;50cb
	ld a,(hl)		;50cc
	or a			;50cd
	jr nz,L_50D1		;50ce
	ld a,c			;50d0
L_50D1:
	ld (de),a		;50d1
	inc de			;50d2
	djnz L_50CB		;50d3
L_50D5:
	ld de,03920h		;50d5
	ld (0e14eh),de		;50d8
	ld a,0ffh		;50dc
	ld (0e170h),a		;50de
	ld hl,0e14eh		;50e1
	call L_458E		;50e4
	xor a			;50e7
	ret			;50e8
L_50E9:
	call L_531B		;50e9
	ld hl,0e107h		;50ec
	ld a,(hl)		;50ef
	dec a			;50f0
	ret nz			;50f1
	ld a,(0e102h)		;50f2
	dec a			;50f5
	ret nz			;50f6
	ld (hl),a		;50f7
	call L_508C		;50f8
	or a			;50fb
	ret nz			;50fc
	ld hl,(0e103h)		;50fd
	ld a,(0e109h)		;5100
	bit 0,a			;5103
	jr z,L_510A		;5105
	ld hl,(0e105h)		;5107
L_510A:
	xor a			;510a
	call L_518D		;510b
	ret			;510e

; ----------------------------------------------------------------------
; DATOS decorados_por_fase: Ocho bytes por fase, diez fases: la lista de decorados que van saliendo. Un 0xFF acaba la lista y los 0x77 son relleno
;   0x510f..0x515f  (80 bytes)
; DATOS color_por_fase: Un byte por fase: con 0 el cielo es la casilla 7 y con 1 la 9. Cierra clavada en 0x519F, donde vuelve a haber codigo
;   0x515f..0x5169  (10 bytes)
; ----------------------------------------------------------------------
	defb 002h,003h,000h,001h,077h,077h,077h,077h,003h,002h,001h,000h,077h,077h,077h,077h	; 510f  ....wwww....wwww
	defb 003h,0ffh,001h,077h,077h,077h,077h,077h,0ffh,002h,000h,077h,077h,077h,077h,077h	; 511f  ...wwwww...wwwww
	defb 003h,0ffh,001h,077h,077h,077h,077h,077h,0ffh,077h,077h,077h,077h,077h,077h,077h	; 512f  ...wwwww.wwwwwww
	defb 002h,003h,000h,002h,001h,000h,0ffh,077h,002h,0ffh,000h,077h,077h,077h,077h,077h	; 513f  .......w...wwwww
	defb 002h,000h,003h,001h,077h,077h,077h,077h,0ffh,003h,001h,077h,077h,077h,077h,077h	; 514f  ....wwww...wwwww
	defb 000h,000h,001h,000h,001h,001h,000h,000h,001h,000h	; 515f  ..........

; ======================================================================
; CODIGO 0x5169..0x5295  (300 bytes)
; ======================================================================


L_5169:
	ld hl,0e100h		;5169
	ld c,(hl)		;516c
	inc hl			;516d
	dec (hl)		;516e
	jr z,L_5182		;516f
	ld a,(hl)		;5171
	cp 003h			;5172
	jp z,L_50E9		;5174
	dec a			;5177
	jr nz,L_5199		;5178
L_517A:
	ld hl,(0e105h)		;517a
	ld a,(0e102h)		;517d
	jr L_518D		;5180
L_5182:
	ld (hl),c		;5182
L_5183:
	ld hl,0e102h		;5183
	ld a,(hl)		;5186
	inc (hl)		;5187
	res 2,(hl)		;5188
L_518A:
	ld hl,(0e103h)		;518a
L_518D:
	add a,a			;518d
	call L_48CF		;518e
	ld e,(hl)		;5191
	inc hl			;5192
	ld d,(hl)		;5193
	ex de,hl		;5194
	call L_4523		;5195
	ret			;5198
L_5199:
	ld b,000h		;5199
	dec a			;519b
	jr z,L_51A4		;519c
	inc b			;519e
	srl c			;519f
	ld a,(hl)		;51a1
	cp c			;51a2
	ret nz			;51a3
L_51A4:
	ld hl,0e112h		;51a4
	ld c,b			;51a7
	ld b,004h		;51a8
	ld a,(0e0e0h)		;51aa
	cp 005h			;51ad
	jr c,L_51B2		;51af
	inc b			;51b1
L_51B2:
	ld a,c			;51b2
	or a			;51b3
	jr z,L_51BD		;51b4
	ld a,(hl)		;51b6
	cp 00bh			;51b7
	ld a,006h		;51b9
	jr c,L_51DF		;51bb
L_51BD:
	ld a,(hl)		;51bd
	or a			;51be
	ld a,006h		;51bf
	jr z,L_51DF		;51c1
	inc (hl)		;51c3
	ld a,(hl)		;51c4
	cp 010h			;51c5
	jr c,L_51CB		;51c7
	ld (hl),000h		;51c9
L_51CB:
	inc hl			;51cb
	inc hl			;51cc
	ld e,(hl)		;51cd
	inc hl			;51ce
	ld d,(hl)		;51cf
	ex de,hl		;51d0
	push de			;51d1
	push bc			;51d2
	call L_4523		;51d3
	pop bc			;51d6
	pop de			;51d7
	inc hl			;51d8
	ex de,hl		;51d9
	ld (hl),d		;51da
	dec hl			;51db
	ld (hl),e		;51dc
	ld a,004h		;51dd
L_51DF:
	call L_48CF		;51df
	djnz L_51B2		;51e2
	call L_75C5		;51e4
	call L_7818		;51e7
	call L_4D13		;51ea
	call L_4D60		;51ed
	ret			;51f0
L_51F1:
	call L_47F8		;51f1
	ld hl,(0e0e5h)		;51f4
	ld a,h			;51f7
	and a			;51f8
	jr nz,L_51FF		;51f9
	ld a,l			;51fb
	cp 086h			;51fc
	ret c			;51fe
L_51FF:
	ld hl,0e10eh		;51ff
	ld a,(hl)		;5202
	inc hl			;5203
	dec (hl)		;5204
	ret nz			;5205
	ld (hl),a		;5206
	ld hl,0e112h		;5207
	ld b,003h		;520a
	ld a,(0e0e0h)		;520c
	cp 005h			;520f
	jr c,L_5214		;5211
	inc b			;5213
L_5214:
	ld a,(hl)		;5214
	or a			;5215
	jr z,L_5220		;5216
	ld a,006h		;5218
	call L_48CF		;521a
	djnz L_5214		;521d
	ret			;521f
L_5220:
	inc (hl)		;5220
	inc hl			;5221
	ex de,hl		;5222
	ld hl,0e111h		;5223
	inc (hl)		;5226
	res 3,(hl)		;5227
	ld a,(hl)		;5229
	ld hl,(0e18bh)		;522a
	call L_48CF		;522d
	ld c,(hl)		;5230
	push de			;5231
	call L_47E6		;5232
	pop de			;5235
	ld a,c			;5236
	inc a			;5237
	jr z,L_5278		;5238
	dec a			;523a
	bit 4,a			;523b
	jr z,L_524B		;523d
	ld hl,0e190h		;523f
	ld (hl),001h		;5242
	inc hl			;5244
	and 003h		;5245
	ld c,a			;5247
	ld (hl),a		;5248
	jr L_5256		;5249
L_524B:
	ld a,c			;524b
	or a			;524c
	jr z,L_5256		;524d
	ld a,(0e0fch)		;524f
	or a			;5252
	jr z,L_5256		;5253
	inc c			;5255
L_5256:
	ex de,hl		;5256
	call L_527C		;5257
	ld a,(0e190h)		;525a
	rra			;525d
	ret nc			;525e
	ld a,(0e191h)		;525f
	cpl			;5262
	and 003h		;5263
	ld c,a			;5265
	ld hl,0e12ah		;5266
	ld a,(hl)		;5269
	or a			;526a
	jr nz,L_5272		;526b
	inc (hl)		;526d
	inc hl			;526e
	call L_527C		;526f
L_5272:
	ld hl,0e190h		;5272
	ld (hl),000h		;5275
	ret			;5277
L_5278:
	ex de,hl		;5278
	dec hl			;5279
	ld (hl),a		;527a
	ret			;527b
L_527C:
	ld (hl),c		;527c
	inc hl			;527d
	ld de,05295h		;527e
	ld a,c			;5281
	add a,a			;5282
	ld c,a			;5283
	add a,a			;5284
	add a,c			;5285
	call L_48D4		;5286
	ld a,(de)		;5289
	ld (hl),a		;528a
	inc de			;528b
	inc hl			;528c
	ld a,(de)		;528d
	ld (hl),a		;528e
	inc de			;528f
	inc hl			;5290
	ld (hl),e		;5291
	inc hl			;5292
	ld (hl),d		;5293
	ret			;5294

; ----------------------------------------------------------------------
; DATOS tabla_de_obstaculos: Los SIETE obstaculos: los tipos 0, 1 y 2 son los agujeros -de los que salen la foca y el pez-, el 3 y el 4 los dos monticulos con los que se choca, y el 5 y el 6 LAS DOS BANDERAS que se recogen por 500 puntos. Seis bytes cada uno: los dos primeros son el puntero al primer trozo de dibujo, y los cuatro siguientes los pares (posicion, ancho) con los que se mira el choque. Los siete dibujos caen dentro de los 92 trozos de 0x6BE9-0x7241, que es lo que confirma para que son. Cierra clavada en 0x52F5
;   0x5295..0x52bf  (42 bytes)
; ----------------------------------------------------------------------
	defb 0f1h,06eh,001h,053h,03ah,000h,0aah,06fh,001h,013h,03bh,000h,069h,070h,001h,092h	; 5295  .n.S:..o..;.ip..
	defb 03bh,000h,0c1h,06bh,02bh,05bh,010h,090h,05dh,06dh,064h,053h,048h,088h,0a0h,071h	; 52a5  ;..k+[..]mdSH..q
	defb 080h,02ch,000h,000h,028h,071h,02eh,02ch,000h,000h	; 52b5  .,..(q.,..

; ======================================================================
; CODIGO 0x52bf..0x53ab  (236 bytes)
; ======================================================================


L_52BF:
	ld hl,(0e0e5h)		;52bf
	ld a,h			;52c2
	and 001h		;52c3
	ret z			;52c5
	ld a,l			;52c6
	cp 082h			;52c7
	ret nz			;52c9
	ld hl,0e0e2h		;52ca
	ld a,(hl)		;52cd
	inc (hl)		;52ce
	srl a			;52cf
	push af			;52d1
	ld hl,053abh		;52d2
	call L_48CF		;52d5
	pop af			;52d8
	ld a,(hl)		;52d9
	jr c,L_52E0		;52da
	rra			;52dc
	rra			;52dd
	rra			;52de
	rra			;52df
L_52E0:
	ld c,a			;52e0
	and 003h		;52e1
	cp 003h			;52e3
	ret z			;52e5
	bit 3,c			;52e6
	jr z,L_52EC		;52e8
	set 1,a			;52ea
L_52EC:
	ld hl,0e194h		;52ec
	ld (hl),a		;52ef
	inc hl			;52f0
	bit 2,c			;52f1
	jr z,L_52F7		;52f3
	ld (hl),002h		;52f5
L_52F7:
	inc hl			;52f7
	ld (hl),001h		;52f8
	inc hl			;52fa
	ld (hl),000h		;52fb
	inc hl			;52fd
	ld a,(0e100h)		;52fe
	srl a			;5301
	srl a			;5303
	ld (hl),a		;5305
	call L_5490		;5306
L_5309:
	ld hl,053cch		;5309
L_530C:
	ld a,(0e194h)		;530c
	add a,a			;530f
	call L_48CF		;5310
	ld e,(hl)		;5313
	inc hl			;5314
	ld d,(hl)		;5315
	ex de,hl		;5316
	call L_458E		;5317
	ret			;531a
L_531B:
	ld a,(0e196h)		;531b
	or a			;531e
	ret z			;531f
	ld bc,0001fh		;5320
	ld a,(0e194h)		;5323
	rra			;5326
	jr c,L_5339		;5327
	ld a,(0e150h)		;5329
	ld hl,0e151h		;532c
	ld de,0e150h		;532f
	ldir			;5332
	ld (0e16fh),a		;5334
	jr L_5347		;5337
L_5339:
	ld a,(0e16fh)		;5339
	ld hl,0e16eh		;533c
	ld de,0e16fh		;533f
	lddr			;5342
	ld (0e150h),a		;5344
L_5347:
	call L_50D5		;5347
	ld hl,0e197h		;534a
	inc (hl)		;534d
	ld a,(hl)		;534e
	and 00fh		;534f
	jr nz,L_5363		;5351
	dec hl			;5353
	dec hl			;5354
	cp (hl)			;5355
	jr z,L_5363		;5356
	dec (hl)		;5358
	jr nz,L_5363		;5359
	dec hl			;535b
	ld a,(hl)		;535c
	xor 001h		;535d
	ld (hl),a		;535f
	call L_5309		;5360
L_5363:
	ld hl,(0e0e5h)		;5363
	ld a,h			;5366
	and 001h		;5367
	ret nz			;5369
	ld a,l			;536a
	cp 045h			;536b
	ret nc			;536d
	ld hl,0e197h		;536e
	ld a,(hl)		;5371
	and 00fh		;5372
	ret nz			;5374
	dec hl			;5375
	ld (hl),a		;5376
	ld hl,053d4h		;5377
	call L_530C		;537a
	call L_548B		;537d
L_5380:
	ld hl,0e196h		;5380
	ld a,(hl)		;5383
	or a			;5384
	ret z			;5385
	inc hl			;5386
	inc hl			;5387
	dec (hl)		;5388
	ret nz			;5389
	ld a,(0e100h)		;538a
	srl a			;538d
	srl a			;538f
	ld (hl),a		;5391
	ld hl,0e0d1h		;5392
	ld de,(0e078h)		;5395
	ld a,(0e194h)		;5399
	rra			;539c
	jr c,L_53A5		;539d
	call L_4C66		;539f
	jp L_4B8C		;53a2
L_53A5:
	call L_4C83		;53a5
	jp L_4B8C		;53a8

; ----------------------------------------------------------------------
; DATOS curvas_por_fase: Sesenta y seis curvas en treinta y tres bytes, a nibble por curva: 0x5305 elige la mitad alta o la baja. Cierra con el 0xFF de 0x5401, justo delante de los punteros
;   0x53ab..0x53cc  (33 bytes)
; DATOS punteros_del_horizonte: Ocho punteros a los siete dibujos de horizonte (dos apuntan al mismo). Cierra clavada en 0x5412, que es el primero de ellos
;   0x53cc..0x53dc  (16 bytes)
; DATOS dibujos_del_horizonte: Los siete horizontes, en el formato de las cadenas: recto, curva a un lado, curva al otro, y los cuatro de la llegada a la base. Todos escriben en las filas 10 y 11. Acaba clavado en 0x54C1
;   0x53dc..0x548b  (175 bytes)
; ----------------------------------------------------------------------
	defb 0f8h,0ffh,0ffh,0ffh,099h,0f8h,08fh,0f9h,0f9h,0ffh,0ffh,088h,01fh,0f9h,0f9h,00fh	; 53ab  ................
	defb 01fh,0ffh,08fh,099h,0ffh,081h,00fh,0ffh,0f8h,08fh,0ffh,08fh,099h,0ffh,0f0h,099h	; 53bb  ................
	defb 0ffh,0dch,053h,0edh,053h,00fh,054h,02eh,054h,0feh,053h,0feh,053h,06ch,054h,04dh	; 53cb  ..S.S.T.T.S.SlTM
	defb 054h,049h,039h,014h,014h,013h,013h,015h,030h,030h,031h,010h,010h,010h,032h,033h	; 53db  TI9.....001...23
	defb 023h,0ffh,049h,039h,023h,074h,032h,010h,010h,010h,031h,030h,030h,015h,013h,013h	; 53eb  #.I9#t2...100...
	defb 014h,014h,0ffh,049h,039h,015h,014h,013h,012h,052h,010h,00fh,00fh,010h,011h,012h	; 53fb  ...I9....R......
	defb 013h,014h,015h,0ffh,049h,039h,014h,014h,013h,013h,015h,030h,030h,031h,010h,010h	; 540b  ....I9.....001..
	defb 010h,041h,047h,053h,053h,054h,054h,054h,054h,054h,054h,054h,054h,0feh,072h,039h	; 541b  .AGSSTTTTTTTT.r9
	defb 00fh,03eh,0ffh,040h,039h,054h,054h,054h,054h,054h,054h,054h,054h,053h,053h,088h	; 542b  .>.@9TTTTTTTTSS.
	defb 082h,010h,010h,010h,031h,030h,030h,015h,013h,013h,014h,014h,0feh,06ch,039h,07fh	; 543b  ....100......l9.
	defb 00fh,0ffh,040h,039h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h	; 544b  ..@9............
	defb 004h,07dh,07ah,00fh,00fh,010h,011h,012h,013h,014h,015h,0feh,06ch,039h,079h,078h	; 545b  .}z.........l9yx
	defb 0ffh,049h,039h,015h,014h,013h,012h,052h,010h,00fh,00fh,039h,03ch,004h,004h,004h	; 546b  .I9....R...9<...
	defb 004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,0feh,072h,039h,037h,038h,0ffh	; 547b  ...........r978.

; ======================================================================
; CODIGO 0x548b..0x5516  (139 bytes)
; ======================================================================


L_548B:
	ld hl,072bfh		;548b
	jr L_5493		;548e
L_5490:
	ld hl,0724dh		;5490
L_5493:
	ld a,(0e194h)		;5493
	bit 1,a			;5496
	ret z			;5498
	rra			;5499
	ld a,(hl)		;549a
	jr nc,L_549F		;549b
	sub 010h		;549d
L_549F:
	ld e,a			;549f
	jp L_50C3		;54a0
L_54A3:
	ld a,(0e003h)		;54a3
	and 003h		;54a6
	ret nz			;54a8
	inc c			;54a9
	jr nz,L_54D2		;54aa
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
L_54BD:
	add hl,de		;54bd
	djnz L_54BD		;54be
	ld a,h			;54c0
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
	add a,c			;54d0
	ld h,a			;54d1
L_54D2:
	ld a,(0e078h)		;54d2
	dec a			;54d5
	ld l,a			;54d6
	call L_4BB6		;54d7
	call L_4C9B		;54da
	ld hl,0e138h		;54dd
	inc (hl)		;54e0
	ld a,010h		;54e1
	cp (hl)			;54e3
	ret			;54e4
L_54E5:
	xor a			;54e5
	ld (0e13ah),a		;54e6
L_54E9:
	ld hl,0e13ah		;54e9
	ld a,(hl)		;54ec
	inc (hl)		;54ed
	ld hl,05516h		;54ee
	rra			;54f1
	jr nc,L_54F7		;54f2
	ld hl,0552ah		;54f4
L_54F7:
	call L_4523		;54f7
	ret			;54fa
L_54FB:
	ld hl,06b59h		;54fb
	call L_454E		;54fe
	ld hl,0671eh		;5501
	ld de,0e06ch		;5504
	ld bc,00010h		;5507
	ldir			;550a
	call L_66BB		;550c
	ld hl,05534h		;550f
	call L_4523		;5512
	ret			;5515

; ----------------------------------------------------------------------
; DATOS bloque_base_a: Uno de los dos bloques que se van alternando para dibujar la base
;   0x5516..0x552a  (20 bytes)
; DATOS bloque_base_b: El otro
;   0x552a..0x5534  (10 bytes)
; DATOS bloque_base_polo: El tercero, el del remate de 0x5531
;   0x5534..0x5549  (21 bytes)
; ----------------------------------------------------------------------
	defb 0e1h,0efh,0b6h,0b7h,0eeh,0b8h,0b9h,0bah,0bbh,0eeh,0beh,0bfh,0c0h,0bch,0eeh,0c3h	; 5516  ................
	defb 0c4h,0c5h,0c6h,000h,002h,0eeh,0c2h,0eeh,0bdh,0c1h,0eeh,0c7h,0c8h,000h,0e1h,0eeh	; 5526  ................
	defb 0d2h,0d5h,0d8h,0eeh,0d3h,0d6h,0d9h,0dbh,0eeh,0d4h,0d7h,0dah,0dch,0eeh,0ddh,0deh	; 5536  ................
	defb 0dfh,00fh,000h	; 5546  ...

; ======================================================================
; CODIGO 0x5549..0x55a3  (90 bytes)
; ======================================================================


L_5549:
	ld hl,06628h		;5549
	ld de,05100h		;554c
	call L_4552		;554f
	ld hl,055a3h		;5552
	ld a,(0e0e1h)		;5555
	ld c,a			;5558
	add a,a			;5559
	call L_48CF		;555a
	ld e,(hl)		;555d
	inc hl			;555e
	ld d,(hl)		;555f
	ex de,hl		;5560
	call L_458E		;5561
	ld hl,05626h		;5564
	ld a,(0e0e0h)		;5567
	and 00fh		;556a
	add a,a			;556c
	call L_48CF		;556d
	ld e,(hl)		;5570
	inc hl			;5571
	ld d,(hl)		;5572
	ex de,hl		;5573
	ld de,05f40h		;5574
	call L_4552		;5577
	ld a,(hl)		;557a
	ld (0e063h),a		;557b
	inc hl			;557e
	ld a,(hl)		;557f
	ld (0e067h),a		;5580
	jr L_5596		;5583
L_5585:
	ld a,(0e060h)		;5585
	sub 002h		;5588
	cp 036h			;558a
	ret z			;558c
	ld (0e060h),a		;558d
	ld (0e064h),a		;5590
	ld (0e068h),a		;5593
L_5596:
	ld hl,0e060h		;5596
	ld de,03b10h		;5599
	ld bc,0000ch		;559c
	call L_44DC		;559f
	ret			;55a2

; ----------------------------------------------------------------------
; DATOS punteros_de_las_bases: Diez punteros, uno por fase, a los nombres de las bases. Cierra clavada en 0x55ED, que es la primera cadena; con ocho, nueve, once o doce entradas no cierra
;   0x55a3..0x55b7  (20 bytes)
; DATOS nombres_de_las_bases: OCHO cadenas para diez fases: JAPAN, AUSTRALIA, FRANCE, NEW ZEALAND, ARGENTINA, UNITED KINGDOM, THE SOUTH POLE y USA. El reparto que sale de la tabla de arriba es FRANCE, USA, THE SOUTH POLE, USA, USA, ARGENTINA, UNITED KINGDOM, JAPAN, AUSTRALIA y AUSTRALIA. NEW ZEALAND (0x5610..0x561F) NO LA VISITA NADIE: no esta en la tabla, ninguna instruccion la apunta, y ninguna de sus dieciseis direcciones aparece como palabra en los 16 KB. En la PRIMERA version japonesa del cartucho si se visita, y es la fase 4; ver la pagina de las versiones. Los dos primeros bytes de cada cadena son el destino en la tabla de nombres de la VRAM, o sea el centrado: 0x3AC8 para las dos de catorce letras y 0x3ACE para USA
;   0x55b7..0x5626  (111 bytes)
; DATOS punteros_de_banderas: Diez punteros a los graficos de bandera. Cierra clavada en 0x5670
;   0x5626..0x563a  (20 bytes)
; DATOS banderas_comprimidas: Siete banderas distintas para diez ranuras. Los diez flujos miden entre 11 y 59 bytes y TODOS descomprimen a 64 bytes exactos, que son dos sprites de 16x16; detras de cada uno van sus dos colores
;   0x563a..0x5781  (327 bytes)
; DATOS rotulos: Los rotulos de pantalla, en el formato de las cadenas: el panel (1P, HI, STAGE, TIME), (c)KONAMI 1984, PLAY SELECT con JOYSTICK y KEYBOARD, y TIME OUT
;   0x5781..0x5803  (130 bytes)
; DATOS titulo_comprimido: La pantalla de titulo: relleno y el rotulo SOFTWARE en la fila 10. Pasado por el descompresor son veinte casillas en dos sitios (VRAM 0x394A y 0x396C) y el flujo se acaba en 0x584A
;   0x5803..0x5818  (21 bytes)
; DATOS mandos_de_la_demo: LOS MANDOS GRABADOS DE LA DEMO. Sesenta y cuatro bytes, uno cada 32 fotogramas: 0x41BA los apunta y 0x4103 los va leyendo. La demo dura 0x073C pasos, asi que gasta 58 de los 64. Cada byte lleva los mismos bits que el joystick, y se ve: 0x01 arriba, 0x09 arriba y derecha, 0x11 arriba y gatillo... La partida de demostracion no la juega ninguna inteligencia, va grabada. Cierra clavada en 0x588A, la primera instruccion de MONTA_LA_FUENTE
;   0x5818..0x5858  (64 bytes)
; ----------------------------------------------------------------------
	defb 0cfh,055h,0eah,055h,013h,056h,0eah,055h,0eah,055h,0f2h,055h,000h,056h,0b7h,055h	; 55a3  .U.U.V.U.U.U.V.U
	defb 0c1h,055h,0c1h,055h,0cdh,03ah,020h,02ah,021h,030h,021h,02eh,020h,0ffh,0cbh,03ah	; 55b3  .U.U.: *!0!. ..:
	defb 020h,021h,035h,033h,034h,032h,021h,02ch,029h,021h,020h,0ffh,0cch,03ah,020h,0c9h	; 55c3   !5342!,)! ..: .
	defb 032h,021h,02eh,023h,025h,020h,0ffh,0cah,03ah,020h,02eh,025h,0cah,00fh,0cbh,025h	; 55d3  2!.#% ..: .%...%
	defb 021h,02ch,021h,02eh,024h,020h,0ffh,0ceh,03ah,020h,035h,033h,021h,020h,0ffh,0cbh	; 55e3  !,!.$ ..: 53! ..
	defb 03ah,020h,021h,032h,027h,025h,02eh,034h,029h,02eh,021h,020h,0ffh,0c8h,03ah,020h	; 55f3  : !2'%.4).! ..: 
	defb 035h,02eh,029h,034h,025h,024h,00fh,02bh,029h,02eh,027h,024h,02fh,02dh,020h,0ffh	; 5603  5.)4%$.+).'$/- .
	defb 0c8h,03ah,020h,034h,028h,025h,00fh,033h,02fh,035h,034h,028h,00fh,030h,02fh,02ch	; 5613  .: 4(%.3/54(.0/,
	defb 025h,020h,0ffh,053h,056h,082h,056h,0bbh,056h,03fh,057h,0bbh,056h,0bbh,056h,0dfh	; 5623  % .SV.V.V?W.V.V.
	defb 056h,002h,057h,03ah,056h,053h,056h,002h,000h,082h,003h,007h,003h,00fh,082h,007h	; 5633  V.W:VSV.........
	defb 003h,009h,000h,082h,080h,0c0h,003h,0e0h,082h,0c0h,080h,027h,000h,000h,006h,00fh	; 5643  ...........'....
	defb 087h,0cch,06dh,00ch,0ffh,00ch,06dh,0cch,009h,000h,087h,0c0h,080h,000h,0c0h,000h	; 5653  ..m...m.........
	defb 080h,0c0h,009h,000h,007h,000h,002h,0ffh,002h,0fbh,001h,0ffh,004h,000h,089h,03fh	; 5663  ...............?
	defb 03bh,03fh,03dh,02fh,03bh,03fh,0ffh,0f7h,003h,0ffh,004h,000h,000h,006h,00dh,010h	; 5673  ;?=/;?..........
	defb 000h,00ch,03fh,004h,000h,00ch,0f8h,014h,000h,000h,006h,004h,087h,0cch,06dh,00ch	; 5683  ..?...........m.
	defb 0ffh,00ch,06dh,0cch,009h,000h,087h,0c0h,080h,000h,0c0h,000h,080h,0c0h,009h,000h	; 5693  ..m.............
	defb 007h,000h,005h,0ffh,004h,000h,08ch,03fh,03fh,037h,03fh,03bh,02fh,03fh,0ffh,0ffh	; 56a3  .......??7?;/?..
	defb 0f7h,0ffh,0ffh,004h,000h,000h,006h,00dh,007h,000h,085h,0ffh,000h,0ffh,000h,0ffh	; 56b3  ................
	defb 005h,000h,08bh,0ffh,000h,0ffh,000h,0ffh,000h,0ffh,000h,0ffh,000h,0ffh,004h,000h	; 56c3  ................
	defb 086h,055h,0aah,055h,0aah,055h,0aah,01ah,000h,000h,006h,004h,004h,000h,084h,001h	; 56d3  .U.U.U..........
	defb 003h,003h,001h,00ch,000h,084h,080h,0c0h,0c0h,080h,008h,000h,004h,0ffh,004h,000h	; 56e3  ................
	defb 004h,0ffh,004h,000h,004h,0ffh,004h,000h,004h,0ffh,004h,000h,000h,00ah,007h,08ch	; 56f3  ................
	defb 061h,031h,019h,00dh,001h,0ffh,0ffh,001h,00dh,019h,031h,061h,004h,000h,08ch,086h	; 5703  a1........1a....
	defb 08ch,098h,0b0h,080h,0ffh,0ffh,080h,0b0h,098h,08ch,086h,004h,000h,084h,00ch,084h	; 5713  ................
	defb 0c0h,0e0h,004h,000h,084h,0e0h,0c0h,084h,00ch,004h,000h,084h,030h,021h,003h,007h	; 5723  ............0!..
	defb 004h,000h,084h,007h,003h,021h,030h,004h,000h,000h,008h,005h,08bh,003h,004h,00ah	; 5733  .....!0.........
	defb 00ch,02ch,03eh,018h,008h,008h,00ch,007h,005h,000h,08bh,0c0h,020h,050h,010h,030h	; 5743  .,>......... P.0
	defb 078h,01ch,014h,010h,030h,0e0h,005h,000h,085h,000h,000h,002h,001h,003h,003h,000h	; 5753  x...0...........
	defb 083h,000h,000h,018h,005h,000h,085h,000h,000h,040h,080h,0c0h,003h,000h,083h,000h	; 5763  .........@......
	defb 000h,018h,005h,000h,000h,001h,00ah,00ch,038h,028h,029h,020h,0feh,016h,038h,033h	; 5773  ........8() ..83
	defb 034h,021h,027h,025h,020h,0feh,022h,038h,034h,029h,02dh,025h,020h,0feh,02ch,038h	; 5783  4!'% ."84)-% .,8
	defb 038h,03ah,03bh,000h,000h,000h,000h,040h,041h,0feh,036h,038h,026h,031h,037h,0feh	; 5793  8:;....@A.68&17.
	defb 002h,038h,011h,030h,020h,0ffh,00bh,039h,01ah,01bh,01ch,01dh,01eh,01fh,000h,011h	; 57a3  .8.0 ..9........
	defb 019h,018h,014h,0ffh,0abh,039h,030h,02ch,021h,039h,000h,033h,025h,02ch,025h,023h	; 57b3  .....90,!9.3%,%#
	defb 034h,0feh,006h,03ah,011h,020h,03ch,03dh,000h,000h,030h,02ch,021h,039h,000h,03eh	; 57c3  4..:. <=..0,!9.>
	defb 03fh,000h,02ah,02fh,039h,033h,034h,029h,023h,02bh,0feh,046h,03ah,012h,020h,03ch	; 57d3  ?.*/934)#+.F:. <
	defb 03dh,000h,000h,030h,02ch,021h,039h,000h,03eh,03fh,000h,02bh,025h,039h,022h,02fh	; 57e3  =..0,!9.>?.+%9"/
	defb 021h,032h,024h,0ffh,0ech,038h,034h,029h,02dh,025h,000h,02fh,035h,034h,0ffh,066h	; 57f3  !2$..84)-%./54.f
	defb 039h,020h,000h,036h,029h,024h,025h,02fh,000h,023h,021h,032h,034h,032h,029h,024h	; 5803  9 .6)$%/.#!242)$
	defb 027h,025h,000h,020h,0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 5813  '%. ............
	defb 001h,009h,001h,001h,011h,005h,005h,009h,009h,001h,006h,004h,010h,001h,001h,011h	; 5823  ................
	defb 010h,001h,001h,009h,009h,001h,005h,015h,009h,019h,001h,001h,005h,011h,001h,001h	; 5833  ................
	defb 001h,011h,001h,001h,001h,011h,001h,000h,018h,019h,009h,001h,011h,001h,001h,001h	; 5843  ................
	defb 001h,001h,001h,001h,001h	; 5853  .....

; ======================================================================
; CODIGO 0x5858..0x58a9  (81 bytes)
; ======================================================================


L_5858:
	ld de,00000h		;5858
	call L_586A		;585b
	ld de,00800h		;585e
	call L_586A		;5861
	ld de,01000h		;5864
	jp L_586A		;5867
L_586A:
	push de			;586a
	xor a			;586b
	ld c,010h		;586c
L_586E:
	ld b,008h		;586e
L_5870:
	call L_48B1		;5870
	inc de			;5873
	djnz L_5870		;5874
	inc a			;5876
	dec c			;5877
	jr nz,L_586E		;5878
	ld bc,00270h		;587a
	ld a,0f0h		;587d
	call L_44EF		;587f
	ld hl,05d88h		;5882
	call L_455B		;5885
	ld b,016h		;5888
L_588A:
	ld hl,05dbeh		;588a
	push bc			;588d
	call L_455B		;588e
	pop bc			;5891
	djnz L_588A		;5892
	pop de			;5894
	ld hl,06000h		;5895
	add hl,de		;5898
	ex de,hl		;5899
	ld hl,058a9h		;589a
	call L_4552		;589d
	ld hl,05c33h		;58a0
	call L_455B		;58a3
	jp L_455B		;58a6

; ----------------------------------------------------------------------
; DATOS fuente_comprimida: La fuente y el logotipo de KONAMI, que van a los tres bancos
;   0x58a9..0x5dca  (1313 bytes)
; ----------------------------------------------------------------------
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
	defb 000h	; 5dc9  .

; ======================================================================
; CODIGO 0x5dca..0x5dfa  (48 bytes)
; ======================================================================


L_5DCA:
	ld hl,05dfah		;5dca
	call L_454E		;5dcd
	ld hl,05dfch		;5dd0
	ld de,06a88h		;5dd3
	call L_4556		;5dd6
	call L_454E		;5dd9
	ld hl,06182h		;5ddc
	call L_454E		;5ddf
	ld hl,06189h		;5de2
	ld de,04a88h		;5de5
	call L_4552		;5de8
	call L_454E		;5deb
	ld hl,06187h		;5dee
	call L_454E		;5df1
	ld hl,06258h		;5df4
	jp L_454E		;5df7

; ----------------------------------------------------------------------
; DATOS dibujos_banco1: Dibujos y colores del banco 1, comprimidos
;   0x5dfa..0x623b  (1089 bytes)
; DATOS colores_de_pista_b: LOS COLORES DE LA PISTA DEL SEGUNDO TIPO DE FASE: 29 bytes que descomprimen a 112 en la VRAM 0x0F78. Van EN PAREJA con los otros 29 de 0x6246-0x6262 -que son los del primer tipo y caen dentro del rango de arriba-, y 0x5044 elige entre las dos parejas mirando el bit 0 de la tabla de 0x5195 con la fase: o 0x5DE4 y 0x6246, o 0x5DEF y 0x6263. EL PUNTERO NO SE VE MIRANDO LAS INSTRUCCIONES DE AL LADO, y por eso el reconstructor se saltaba estos bytes: 0x5065 hace `ld de,06263h`, 0x5068 lo GUARDA EN LA PILA y quien lo usa es el `pop hl` de 0x506F, dos descompresiones despues. Es el mismo truco que la fuente en 0x58CF. Cierra clavado en 0x6280, donde empieza el remate del banco 1
;   0x623b..0x6258  (29 bytes)
; DATOS dibujos_banco1_resto: El remate del banco 1
;   0x6258..0x6267  (15 bytes)
; ----------------------------------------------------------------------
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
	defb 000h,017h,019h,001h,01fh,008h,0f9h,007h,0f9h,001h,0f4h,005h,0f9h,003h,0f4h,004h	; 623a  ................
	defb 0f9h,004h,0f4h,004h,0f9h,004h,0f4h,003h,0f9h,005h,0f4h,028h,0f9h,000h,098h,04ah	; 624a  ...........(...J
	defb 004h,04fh,001h,041h,003h,044h,003h,04fh,001h,041h,004h,044h,000h	; 625a  .O.A.D.O.A.D.

; ======================================================================
; CODIGO 0x6267..0x629d  (54 bytes)
; ======================================================================


L_6267:
	ld hl,0629dh		;6267
	call L_454E		;626a
	call L_454E		;626d
	ld hl,05c04h		;6270
	call L_455B		;6273
	ld hl,0629fh		;6276
	ld de,072b0h		;6279
	call L_4556		;627c
	ld hl,0662dh		;627f
	call L_454E		;6282
	ld hl,06551h		;6285
	call L_454E		;6288
	call L_454E		;628b
	ld hl,06553h		;628e
	ld de,052b0h		;6291
	call L_4552		;6294
	ld hl,0668bh		;6297
	jp L_454E		;629a

; ----------------------------------------------------------------------
; DATOS dibujos_banco2: Dibujos y colores del banco 2, comprimidos
;   0x629d..0x669a  (1021 bytes)
; ----------------------------------------------------------------------
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


L_669A:
	ld hl,066c7h		;669a
	jr L_66A2		;669d
L_669F:
	ld hl,06704h		;669f
L_66A2:
	push hl			;66a2
	ld hl,0e050h		;66a3
	push hl			;66a6
	ld b,080h		;66a7
L_66A9:
	ld (hl),000h		;66a9
	inc hl			;66ab
	djnz L_66A9		;66ac
	pop de			;66ae
	pop hl			;66af
L_66B0:
	ld a,(hl)		;66b0
	inc hl			;66b1
	or a			;66b2
	jr z,L_66BB		;66b3
	ld c,a			;66b5
	call L_45A0		;66b6
	jr L_66B0		;66b9
L_66BB:
	ld hl,0e050h		;66bb
	ld de,03b00h		;66be
	ld bc,00080h		;66c1
	jp L_44DC		;66c4

; ----------------------------------------------------------------------
; DATOS atributos_de_partida: La lista con la que se monta la tabla de atributos durante la partida: pares (cuantos, cuatro bytes) y un cero al final. De aqui sale el color de cada sprite, que NO va en su dibujo: el pinguino negro, la foca negra y roja, el pez rojo, la sombra azul. Y AQUI ESTA EL ATRIBUTO 14, con patron 0xD4 -que dibujado es un SOL de puntas- y color amarillo, que no se ve nunca. COMPROBADO QUE ES UN SOL Y QUE SE VERIA: parcheando en una COPIA del cartucho los dos bytes de su posicion (0x6709 y 0x670A, la Y y la X) para sacarlo al cielo, aparece un sol amarillo de puntas sobre el azul, sin tocarle ni el dibujo ni el color. La captura y el cartucho parcheado estan fuera del repositorio, en work/, porque esto NO es una modificacion del juego sino la forma de ver lo que el juego tiene y no ensena: se monta con Y=0xE0 -fuera de la pantalla- y nadie se la cambia. MEDIDO sobre los diez minutos de partida grabada con un punto de observacion de escritura en 0xE088-0xE08B (tools/omsx_atributo14.tcl): las UNICAS cuatro cosas que lo tocan son barridos de la tabla entera -el ldir de 0x446E, el copiador de cuatro bytes de 0x45BE, BORRA_SPRITES en 0x4606 y el borrado previo de 0x66D1-, y ninguna va a por el. Al acabar la partida su entrada en la VRAM sigue siendo Y=0xE0, patron 0xD4, color 0x0A: cargado, coloreado y aparcado fuera del encuadre. El control -los mismos puntos en el atributo 13- recibe ademas 4426 y 41740 escrituras de las rutinas del pinguino, asi que los ceros del 14 son datos y no instrumentacion rota. Y de propina el control mide una cosa que estaba deducida: el 13 recibe 12 escrituras MAS que el 14 desde 0x45BE, que son las tres salidas del agua por cuatro bytes, o sea la cadena que rehace los sprites parandose justo antes del 14
;   0x66c7..0x6704  (61 bytes)
; DATOS atributos_de_base: La misma lista para la escena de la base, pero de OCHO entradas en vez de treinta: 0x66CB pone los 128 bytes a cero antes de aplicarla, asi que del atributo 8 en adelante no queda nada. Cierra clavada en 0x6756, donde vuelve a haber codigo. Sus bytes de 0x6746 los copia ademas 0x5537. Y AQUI ESTA EL UNICO SPRITE DEL PINGUINO QUE SE GIRA Y SONRIE: el atributo 7, con el patron 0xD0 en amarillo, que es el PICO. Todo lo demas de ese pinguino -la cara, los ojos, la boca roja y hasta la sombra azul de debajo- son CASILLAS, no sprites. Comprobado a t=126,6 de la partida grabada de dos maneras: la tabla de atributos solo tiene ocho entradas puestas, y comparando el fotograma real con la pantalla pintada SOLO con casillas quedan 224 pixeles sin explicar, que son 96+72+24 de la bandera y 32 del pico. Y 32 son exactamente los bits encendidos del patron 0xD0
;   0x6704..0x672e  (42 bytes)
; ----------------------------------------------------------------------
	defb 00ah,0e0h,000h,07ch,000h,001h,090h,070h,000h,001h,001h,090h,080h,004h,001h,001h	; 66c7  ...|...p........
	defb 0a0h,070h,008h,001h,001h,0a0h,080h,00ch,001h,001h,0e0h,000h,0d4h,00ah,001h,0e0h	; 66d7  .p..............
	defb 000h,000h,008h,001h,0e0h,000h,07ch,001h,003h,0e0h,000h,07ch,006h,001h,0aeh,070h	; 66e7  ......|....|...p
	defb 0a0h,004h,001h,0aeh,080h,0a4h,004h,008h,008h,000h,070h,000h,000h,004h,04fh,080h	; 66f7  ..........p...O.
	defb 07ch,000h,001h,052h,080h,0e8h,000h,001h,052h,080h,0ech,000h,001h,052h,080h,0e4h	; 6707  |..R....R....R..
	defb 00fh,001h,07fh,078h,0d0h,00ah,000h,07fh,070h,0f0h,00ah,087h,078h,0f4h,00ah,077h	; 6717  ...x....p...x..w
	defb 070h,0f8h,001h,077h,080h,0fch,001h	; 6727  p..w...

; ======================================================================
; CODIGO 0x672e..0x6734  (6 bytes)
; ======================================================================


L_672E:
	ld hl,06734h		;672e
	jp L_454E		;6731

; ----------------------------------------------------------------------
; DATOS sprites_comprimidos: Los patrones de sprite: los pinguinos, los peces y las focas
;   0x6734..0x6bc1  (1165 bytes)
; DATOS trozos_de_pista: Los 92 trozos incrementales de la pista, en el mismo formato que los decorados: cada uno pone entre una y seis casillas, o sea que son INCREMENTOS y no pantallas enteras. Se consumen en cadena, uno por paso, y asi va creciendo lo que se acerca. Los siete obstaculos de 0x52CB empiezan cada uno en uno de estos trozos
;   0x6bc1..0x7219  (1624 bytes)
; DATOS arbol_de_decorados: Cuatro punteros en 0x7241 llevan a cuatro grupos, cada uno con otros cuatro, y los dieciseis bloques de abajo embaldosan 0x732D-0x7518 sin dejar hueco. Pasados por el interprete de 0x4533 dibujan los bordes de la pista
;   0x7219..0x74f1  (728 bytes)
; ----------------------------------------------------------------------
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
	defb 080h,080h,080h,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,041h,0efh	; 6bb4  ..............A.
	defb 093h,000h,041h,0eeh,0a1h,095h,0a2h,000h,041h,0eeh,00fh,00fh,00fh,0eeh,098h,098h	; 6bc4  ..A.....A.......
	defb 0a3h,000h,061h,0eeh,00fh,00fh,00fh,0edh,099h,09ah,09ah,09bh,000h,081h,0edh,00fh	; 6bd4  ..a.............
	defb 00fh,00fh,00fh,0ech,0a4h,09dh,09dh,09dh,09dh,0a5h,000h,0a1h,0ech,00fh,00fh,00fh	; 6be4  ................
	defb 00fh,00fh,00fh,0eah,0a8h,0aah,09fh,09fh,09fh,09fh,09fh,0abh,0a7h,000h,0c1h,0eah	; 6bf4  ................
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e9h,070h,082h,06ch,06ch,06ch,06ch	; 6c04  ..........p.llll
	defb 06ch,06ch,083h,071h,000h,0e1h,0e9h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6c14  ll.q............
	defb 00fh,0e8h,0e7h,072h,073h,084h,08bh,06dh,06dh,06dh,06dh,06dh,06dh,08eh,086h,075h	; 6c24  ...rs..mmmmmm..u
	defb 000h,022h,0e7h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6c34  ."..............
	defb 0e6h,072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h	; 6c44  .rs..nnnnnnn..tx
	defb 0e5h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh	; 6c54  .yz...ooooooo.o{
	defb 07ch,07dh,000h,042h,0e6h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6c64  |}.B............
	defb 00fh,00fh,00fh,00fh,0e5h,072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh	; 6c74  .....rs..nnnnnnn
	defb 06eh,06eh,092h,086h,075h,00fh,0e4h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh	; 6c84  nn..u..yz...oooo
	defb 06fh,06fh,06fh,06fh,06fh,08ch,087h,07eh,07fh,000h,062h,0e5h,00fh,00fh,00fh,00fh	; 6c94  ooooo..~..b.....
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e4h,072h,073h,084h	; 6ca4  .............rs.
	defb 090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h,0e3h	; 6cb4  .nnnnnnnnnn..tx.
	defb 079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh	; 6cc4  yz...oooooooooo.
	defb 06fh,07bh,07ch,07dh,000h,082h,0e4h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6cd4  o{|}............
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e3h,072h,073h,084h,090h,06eh,06eh	; 6ce4  ..........rs..nn
	defb 06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,092h,086h,075h,00fh,0e2h,079h	; 6cf4  nnnnnnnnnn..u..y
	defb 07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh	; 6d04  z...oooooooooooo
	defb 08ch,087h,07eh,07fh,000h,0a2h,0e3h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6d14  ..~.............
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e2h,072h,073h,084h,090h,06eh	; 6d24  ...........rs..n
	defb 06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h	; 6d34  nnnnnnnnnnnn..tx
	defb 000h,0c2h,0e2h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6d44  ................
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0f0h,093h,000h,041h,0efh	; 6d54  ..........A...A.
	defb 094h,095h,096h,000h,041h,0efh,00fh,00fh,00fh,0efh,097h,098h,098h,000h,061h,0efh	; 6d64  ....A.........a.
	defb 00fh,00fh,00fh,0efh,099h,09ah,09ah,09bh,000h,081h,0efh,00fh,00fh,00fh,00fh,0eeh	; 6d74  ................
	defb 09ch,09dh,09dh,09dh,09dh,09eh,000h,0a1h,0eeh,00fh,00fh,00fh,00fh,00fh,00fh,0edh	; 6d84  ................
	defb 0a6h,0aah,09fh,09fh,09fh,09fh,09fh,0abh,0a7h,000h,0c1h,0edh,00fh,00fh,00fh,00fh	; 6d94  ................
	defb 00fh,00fh,00fh,00fh,00fh,0edh,070h,082h,06ch,06ch,06ch,06ch,06ch,06ch,083h,077h	; 6da4  ......p.llllll.w
	defb 000h,0e1h,0edh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0edh,0ech,076h	; 6db4  ...............v
	defb 089h,088h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,08eh,086h,075h,000h,022h,0ech,00fh	; 6dc4  ..mmmmmmm..u."..
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0ech,076h,089h,08fh	; 6dd4  .............v..
	defb 06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h,0ebh,080h,081h,093h,085h	; 6de4  nnnnnnn..tx.....
	defb 06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,042h,0ech,00fh	; 6df4  ooooooo.o{|}.B..
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0ebh,072h,073h	; 6e04  ..............rs
	defb 084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h,004h,074h,078h,0eah,079h	; 6e14  ..nnnnnnnn..tx.y
	defb 07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch	; 6e24  z...oooooooo.o{|
	defb 07dh,000h,062h,0ebh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6e34  }.b.............
	defb 00fh,00fh,00fh,00fh,0eah,00fh,076h,089h,08fh,06eh,06eh,06eh,06eh,06eh,06eh,06eh	; 6e44  ......v..nnnnnnn
	defb 06eh,06eh,06eh,091h,004h,074h,078h,0eah,080h,081h,093h,08dh,06fh,06fh,06fh,06fh	; 6e54  nnn..tx.....oooo
	defb 06fh,06fh,06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,082h,0ebh,00fh,00fh	; 6e64  oooooo.o{|}.....
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0eah	; 6e74  ................
	defb 072h,073h,084h,090h,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,091h	; 6e84  rs..nnnnnnnnnnn.
	defb 004h,074h,078h,0e9h,079h,07ah,08ah,085h,08ch,06fh,06fh,06fh,06fh,06fh,06fh,06fh	; 6e94  .tx.yz...ooooooo
	defb 06fh,06fh,06fh,06fh,08dh,06fh,07bh,07ch,07dh,000h,0a2h,0eah,00fh,00fh,00fh,00fh	; 6ea4  oooo.o{|}.......
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e9h	; 6eb4  ................
	defb 00fh,076h,089h,08fh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh,06eh	; 6ec4  .v..nnnnnnnnnnnn
	defb 06eh,091h,004h,077h,078h,000h,0c2h,0eah,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6ed4  n..wx...........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0efh	; 6ee4  ..............A.
	defb 0afh,0b0h,000h,041h,0efh,094h,0a2h,000h,041h,0efh,00fh,00fh,0efh,0bfh,0c0h,000h	; 6ef4  ...A....A.......
	defb 061h,0efh,00fh,00fh,0efh,0b7h,0b8h,000h,081h,0efh,00fh,00fh,0efh,0bch,0bdh,000h	; 6f04  a...............
	defb 0a1h,0efh,00fh,00fh,0efh,0c1h,0c2h,000h,0c1h,0efh,00fh,00fh,0eeh,094h,095h,095h	; 6f14  ................
	defb 096h,000h,0e1h,0eeh,00fh,00fh,00fh,00fh,0ffh,0eeh,097h,098h,098h,099h,000h,022h	; 6f24  ..............."
	defb 0eeh,00fh,00fh,00fh,00fh,0eeh,09ah,098h,098h,09bh,0eeh,0abh,0aah,0aah,0ach,000h	; 6f34  ................
	defb 042h,0eeh,00fh,00fh,00fh,00fh,0edh,09ch,09dh,098h,098h,09eh,09fh,0edh,0a3h,0a4h	; 6f44  B...............
	defb 0a1h,0a1h,0a5h,0a6h,000h,062h,0edh,00fh,00fh,00fh,00fh,00fh,00fh,0edh,09ah,098h	; 6f54  .....b..........
	defb 098h,098h,098h,09bh,0edh,0abh,0a1h,0a8h,0a8h,0a1h,0ach,000h,082h,0edh,00fh,00fh	; 6f64  ................
	defb 00fh,00fh,00fh,00fh,0ech,09ch,09dh,098h,098h,098h,098h,09eh,09fh,0ech,0a3h,0a4h	; 6f74  ................
	defb 0a8h,0a9h,0a9h,0a9h,0a5h,0a6h,000h,0a2h,0ech,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 6f84  ................
	defb 00fh,0ech,09ah,098h,098h,098h,098h,098h,098h,09bh,000h,0c2h,0ech,00fh,00fh,00fh	; 6f94  ................
	defb 00fh,00fh,00fh,00fh,00fh,000h,000h,041h,0efh,0b2h,000h,041h,0eeh,0b4h,00fh,000h	; 6fa4  .......A...A....
	defb 041h,0eeh,00fh,0edh,0bfh,0b6h,000h,061h,0edh,00fh,00fh,0edh,0bah,0bbh,000h,081h	; 6fb4  A......a........
	defb 0edh,00fh,00fh,0ech,0beh,0beh,000h,0a1h,0ech,00fh,00fh,0ebh,0c1h,0c3h,0c2h,000h	; 6fc4  ................
	defb 0c1h,0ebh,00fh,00fh,00fh,0e9h,094h,095h,095h,095h,096h,000h,0e1h,0e9h,00fh,00fh	; 6fd4  ................
	defb 00fh,00fh,00fh,0ffh,0e8h,097h,098h,098h,098h,099h,000h,022h,0e8h,00fh,00fh,00fh	; 6fe4  ..........."....
	defb 00fh,00fh,0e7h,09ah,098h,098h,098h,09bh,0e7h,0abh,0aah,0aah,0aah,0ach,000h,042h	; 6ff4  ...............B
	defb 0e7h,00fh,00fh,00fh,00fh,00fh,0e6h,09ah,098h,098h,098h,09eh,09fh,0e6h,0a0h,0a1h	; 7004  ................
	defb 0a1h,0a1h,0a5h,0a6h,000h,062h,0e6h,00fh,00fh,00fh,00fh,00fh,00fh,0e5h,09ah,098h	; 7014  .....b..........
	defb 098h,098h,098h,09bh,00fh,0e5h,0a0h,0a1h,0a8h,0a8h,0a1h,0a2h,000h,082h,0e5h,00fh	; 7024  ................
	defb 00fh,00fh,00fh,00fh,00fh,0e4h,09ah,098h,098h,098h,098h,09eh,09fh,0e4h,0a0h,0a1h	; 7034  ................
	defb 0a8h,0a8h,0a1h,0a2h,0a6h,000h,0a2h,0e4h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0e3h	; 7044  ................
	defb 09ah,098h,098h,098h,098h,098h,098h,09bh,00fh,000h,0c2h,0e3h,00fh,00fh,00fh,00fh	; 7054  ................
	defb 00fh,00fh,00fh,00fh,000h,000h,041h,0f0h,0b1h,000h,041h,0f0h,00fh,0b3h,000h,041h	; 7064  ......A...A....A
	defb 0f1h,00fh,0f1h,0b5h,0c0h,000h,061h,0f1h,00fh,00fh,0f1h,0b9h,0bah,000h,081h,0f1h	; 7074  ......a.........
	defb 00fh,00fh,0f2h,0beh,0beh,000h,0a1h,0f2h,00fh,00fh,0f2h,0c1h,0c3h,0c2h,000h,0c1h	; 7084  ................
	defb 0f2h,00fh,00fh,00fh,0f2h,094h,095h,095h,095h,096h,000h,0e1h,0f2h,00fh,00fh,00fh	; 7094  ................
	defb 00fh,00fh,0ffh,0f3h,097h,098h,098h,098h,099h,000h,022h,0f3h,00fh,00fh,00fh,00fh	; 70a4  ..........".....
	defb 00fh,0f4h,09ah,098h,098h,098h,09bh,0f4h,0abh,0aah,0aah,0aah,0ach,000h,042h,0f4h	; 70b4  ..............B.
	defb 00fh,00fh,00fh,00fh,00fh,0f4h,09ch,09dh,098h,098h,098h,09eh,0f4h,0a3h,0a4h,0a1h	; 70c4  ................
	defb 0a1h,0a1h,0a2h,000h,062h,0f4h,00fh,00fh,00fh,00fh,00fh,00fh,0f4h,00fh,09ah,098h	; 70d4  ....b...........
	defb 098h,098h,098h,09bh,0f5h,0a0h,0a1h,0a8h,0a8h,0a1h,0a2h,000h,082h,0f5h,00fh,00fh	; 70e4  ................
	defb 00fh,00fh,00fh,00fh,0f5h,09ch,09dh,098h,098h,098h,098h,09eh,0f5h,0a3h,0a4h,0a8h	; 70f4  ................
	defb 0a9h,0a8h,0a1h,0a2h,000h,0a2h,0f5h,00fh,00fh,00fh,00fh,00fh,00fh,00fh,0f5h,00fh	; 7104  ................
	defb 09ah,098h,098h,098h,098h,098h,098h,09bh,000h,0c2h,0f6h,00fh,00fh,00fh,00fh,00fh	; 7114  ................
	defb 00fh,00fh,00fh,000h,000h,000h,041h,0efh,0c6h,000h,041h,0efh,0c7h,000h,041h,0efh	; 7124  ......A...A...A.
	defb 00fh,0efh,0c9h,000h,061h,0efh,00fh,0eeh,0ceh,000h,081h,0edh,0c8h,0cah,0edh,0cfh	; 7134  ....a...........
	defb 0cbh,000h,081h,0edh,00fh,00fh,0edh,0cch,00fh,0ech,0a1h,0cdh,000h,0a1h,0edh,00fh	; 7144  ................
	defb 0ech,00fh,00fh,0ech,003h,0adh,0ebh,0b5h,0b1h,000h,0e1h,0ech,00fh,00fh,0ebh,0aeh	; 7154  ................
	defb 0aeh,0ebh,003h,003h,0eah,07fh,0b0h,000h,000h,002h,0ebh,00fh,00fh,0ebh,00fh,00fh	; 7164  ................
	defb 0e9h,0afh,003h,003h,0e9h,0afh,003h,003h,0e8h,07fh,0b2h,000h,000h,042h,0e9h,00fh	; 7174  .............B..
	defb 00fh,00fh,0e9h,00fh,00fh,00fh,0e8h,00fh,00fh,0e5h,003h,003h,003h,0e5h,003h,003h	; 7184  ................
	defb 003h,000h,0a2h,0e5h,00fh,00fh,00fh,0e5h,00fh,00fh,00fh,000h,000h,000h,041h,0f0h	; 7194  ..............A.
	defb 0c6h,000h,041h,0f0h,0c8h,000h,041h,0f0h,00fh,0f1h,0c9h,000h,061h,0f1h,00fh,0f1h	; 71a4  ..A...A.....a...
	defb 0ceh,000h,081h,0f1h,0c8h,0cah,0f1h,0cfh,0cbh,000h,081h,0f1h,00fh,00fh,0f1h,00fh	; 71b4  ................
	defb 0cch,0f1h,0a1h,0cdh,000h,0a1h,0f2h,00fh,0f1h,00fh,00fh,0f2h,0afh,003h,0f2h,0b2h	; 71c4  ................
	defb 000h,0e1h,0f2h,00fh,00fh,0f2h,00fh,0aeh,0aeh,0f3h,003h,003h,0f2h,07fh,0b0h,000h	; 71d4  ................
	defb 000h,002h,0f3h,00fh,00fh,0f3h,00fh,00fh,0f2h,00fh,0afh,003h,003h,0f3h,0afh,003h	; 71e4  ................
	defb 003h,0f2h,07fh,0b2h,000h,000h,042h,0f3h,00fh,00fh,00fh,0f3h,00fh,00fh,00fh,0f2h	; 71f4  ......B.........
	defb 00fh,00fh,0f8h,003h,003h,003h,0f8h,003h,003h,003h,000h,0a2h,0f8h,00fh,00fh,00fh	; 7204  ................
	defb 0f8h,00fh,00fh,00fh,000h,021h,072h,05eh,072h,09bh,072h,0d0h,072h,005h,073h,02dh	; 7214  .....!r^r.r.r.s-
	defb 073h,045h,073h,066h,073h,00fh,00fh,051h,00eh,072h,00dh,093h,00bh,0b5h,00ah,0d6h	; 7224  sEsfs..Q.r......
	defb 009h,0f7h,008h,018h,006h,03ah,005h,05bh,003h,07dh,002h,09eh,001h,0bfh,000h,051h	; 7234  .....:.[.}.....Q
	defb 039h,00fh,010h,011h,012h,013h,014h,015h,0ffh,060h,000h,000h,000h,0f3h,0f4h,0f3h	; 7244  9........`......
	defb 0f7h,0f5h,0f6h,0f4h,0f3h,0f7h,0f5h,0f6h,000h,000h,07eh,073h,0a6h,073h,0beh,073h	; 7254  ..........~s.s.s
	defb 0dfh,073h,00fh,00fh,040h,00eh,060h,00dh,080h,00bh,0a0h,00ah,0c0h,009h,0e0h,008h	; 7264  .s..@.`.........
	defb 000h,006h,020h,005h,040h,003h,060h,002h,080h,001h,0a0h,000h,048h,039h,015h,014h	; 7274  .. .@.`.....H9..
	defb 013h,012h,052h,010h,00fh,0ffh,050h,0f3h,0f5h,0f6h,0f4h,0f5h,0f7h,0f6h,0f4h,0f4h	; 7284  ..R...P.........
	defb 0f3h,0f5h,0f6h,0f4h,0f5h,0f6h,000h,0f7h,073h,018h,074h,039h,074h,057h,074h,004h	; 7294  ........s.t9tWt.
	defb 00dh,053h,00ch,074h,00ah,096h,009h,0b7h,007h,0d9h,006h,0fah,005h,01bh,003h,03dh	; 72a4  .S.t...........=
	defb 000h,051h,039h,039h,03ch,0feh,072h,039h,037h,038h,0ffh,060h,000h,000h,000h,000h	; 72b4  .Q99<.r978.`....
	defb 0f8h,0fch,0f9h,0fbh,0fch,0f9h,0f9h,0f9h,0fbh,0fah,000h,000h,074h,074h,095h,074h	; 72c4  ............tt.t
	defb 0b6h,074h,0d4h,074h,004h,00dh,040h,00ch,060h,00ah,080h,009h,0a0h,007h,0c0h,006h	; 72d4  .t.t..@.`.......
	defb 0e0h,005h,000h,003h,020h,000h,04dh,039h,07dh,07ah,0feh,06ch,039h,079h,078h,0ffh	; 72e4  .... .M9}z.l9yx.
	defb 050h,000h,000h,000h,0f8h,0fbh,0f9h,0fch,0fbh,0f9h,0fbh,0fch,0fah,000h,000h,000h	; 72f4  P...............
	defb 000h,021h,0f8h,013h,015h,012h,012h,012h,014h,014h,014h,0f5h,016h,017h,018h,019h	; 7304  .!..............
	defb 019h,01ah,01bh,01ch,01ch,01ch,01ch,0f7h,01dh,01eh,01fh,01fh,01fh,020h,021h,022h	; 7314  ............. !"
	defb 023h,0fah,00fh,024h,025h,026h,026h,026h,000h,021h,0fah,015h,0f5h,027h,028h,029h	; 7324  #..$%&&&.!...'()
	defb 029h,019h,02ah,0f7h,02bh,02bh,01eh,01fh,028h,029h,019h,02dh,0fah,02eh,026h,026h	; 7334  ).*.++..().-..&&
	defb 000h,021h,0f8h,015h,015h,015h,012h,012h,012h,0f5h,016h,017h,018h,019h,019h,02fh	; 7344  .!............./
	defb 01bh,01ch,022h,022h,0f7h,01dh,01eh,01fh,01fh,01fh,020h,021h,022h,0fah,00fh,024h	; 7354  ..""...... !"..$
	defb 025h,000h,021h,0fah,012h,0f5h,027h,028h,029h,029h,019h,02dh,0f7h,02bh,02bh,01eh	; 7364  %.!...'()).-.++.
	defb 01fh,02ch,029h,019h,02dh,0fah,02eh,026h,026h,000h,021h,0e0h,014h,014h,014h,012h	; 7374  .,).-..&&.!.....
	defb 012h,012h,015h,013h,0e0h,05dh,05dh,05dh,05dh,05ch,05bh,05ah,05ah,059h,058h,057h	; 7384  .....]]]]\[ZZYXW
	defb 0e0h,064h,063h,062h,061h,060h,060h,060h,05fh,05eh,0e0h,067h,067h,067h,066h,065h	; 7394  .dcba```_^.gggfe
	defb 00fh,000h,021h,0e5h,014h,0e5h,06bh,05ah,06ah,06ah,069h,068h,0e1h,06eh,05ah,06ah	; 73a4  ..!...kZjjih.nZj
	defb 069h,060h,05fh,06ch,06ch,0e3h,067h,067h,06fh,000h,021h,0e2h,012h,012h,012h,015h	; 73b4  i`_ll.ggo.!.....
	defb 015h,015h,0e1h,063h,063h,05dh,05ch,070h,05ah,05ah,059h,058h,057h,0e1h,063h,062h	; 73c4  ...cc]\pZZYXW.cb
	defb 061h,060h,060h,060h,05fh,05eh,0e3h,066h,065h,00fh,000h,021h,0e5h,012h,0e5h,06eh	; 73d4  a```_^.fe..!...n
	defb 05ah,06ah,06ah,069h,068h,0e1h,06eh,05ah,06ah,06dh,060h,05fh,06ch,06ch,0e3h,067h	; 73e4  Zjjih.nZjm`_ll.g
	defb 067h,06fh,000h,061h,0f3h,049h,043h,036h,0f5h,037h,048h,0f6h,03bh,042h,036h,0f8h	; 73f4  go.a.IC6.7H.;B6.
	defb 037h,038h,0f8h,00fh,00fh,054h,0fah,050h,047h,004h,0fbh,042h,048h,004h,004h,004h	; 7404  78...T.PG..BH...
	defb 0feh,042h,043h,000h,061h,0f3h,00fh,045h,004h,0f6h,038h,0f6h,04ah,04ch,004h,0f7h	; 7414  .BC.a..E..8.JL..
	defb 037h,044h,038h,0fah,040h,041h,0fah,00fh,042h,043h,0fbh,00fh,051h,0fdh,044h,045h	; 7424  7D8.@A..BC..Q.DE
	defb 004h,0feh,046h,04dh,000h,061h,0f4h,04fh,0f5h,040h,03dh,0f6h,00fh,035h,04dh,0f7h	; 7434  ..FM.a.O.@=..5M.
	defb 04bh,04eh,004h,0f9h,04ah,04bh,0ffh,0fch,00fh,040h,041h,0fdh,00fh,042h,052h,0feh	; 7444  KN..JK...@A..BR.
	defb 04eh,053h,000h,061h,0f4h,03fh,036h,0f5h,046h,03ah,0f8h,036h,0f7h,00fh,037h,050h	; 7454  NS.a.?6.F:.6..7P
	defb 0f8h,04fh,055h,045h,004h,0fah,046h,04ch,049h,0ffh,0ffh,043h,0feh,00fh,00fh,000h	; 7464  .OUE..FLI..C....
	defb 061h,0eah,077h,084h,08ah,0e9h,089h,078h,0e7h,077h,083h,07ch,0e6h,079h,078h,0e5h	; 7474  a.w....x.w.|.yx.
	defb 06ah,00fh,00fh,0e3h,004h,05dh,066h,0e0h,004h,004h,004h,05eh,058h,0e0h,059h,058h	; 7484  j....]f....^X.YX
	defb 000h,061h,0eah,004h,086h,00fh,0e9h,079h,0e7h,004h,08dh,08bh,0e6h,079h,085h,078h	; 7494  .a.....y.....y.x
	defb 0e4h,057h,056h,0e3h,059h,058h,00fh,0e3h,067h,00fh,0e0h,004h,05bh,05ah,0e0h,063h	; 74a4  .WV.YX..g...[Z.c
	defb 05ch,000h,061h,0ebh,090h,0e9h,07eh,081h,0e7h,08eh,076h,00fh,0e6h,004h,08fh,08ch	; 74b4  \.a...~...v.....
	defb 0e5h,061h,060h,0ffh,0e1h,057h,056h,00fh,0e0h,068h,058h,00fh,0e0h,069h,064h,000h	; 74c4  .a`..WV..hX..id.
	defb 061h,0eah,077h,080h,0e9h,07bh,087h,0e7h,077h,0e6h,091h,078h,00fh,0e4h,004h,05bh	; 74d4  a.w..{..w..x...[
	defb 06bh,065h,0e3h,05fh,062h,05ch,0ffh,0e0h,059h,0e0h,00fh,00fh,000h	; 74e4  ke._b\..Y....

; ======================================================================
; CODIGO 0x74f1..0x7535  (68 bytes)
; ======================================================================


L_74F1:
	ld hl,(0e0e5h)		;74f1
	ld a,h			;74f4
	or a			;74f5
	ret nz			;74f6
	ld a,l			;74f7
	and 01fh		;74f8
	ret nz			;74fa
	ld a,l			;74fb
	rlca			;74fc
	rlca			;74fd
	rlca			;74fe
	add a,a			;74ff
	ld hl,07535h		;7500
	call L_48CF		;7503
	ld e,(hl)		;7506
	inc hl			;7507
	ld d,(hl)		;7508
	ex de,hl		;7509
	ld a,(hl)		;750a
	and 0f0h		;750b
	ld c,a			;750d
	ld a,(hl)		;750e
	inc hl			;750f
	and 003h		;7510
	add a,078h		;7512
	ld d,a			;7514
	ld a,c			;7515
L_7516:
	ld b,(hl)		;7516
	inc hl			;7517
	ld a,020h		;7518
	add a,c			;751a
	ld c,a			;751b
	jr nc,L_751F		;751c
	inc d			;751e
L_751F:
	ld a,c			;751f
	add a,b			;7520
	sub 0e0h		;7521
	ld e,a			;7523
	call L_48C7		;7524
L_7527:
	ld a,(hl)		;7527
	or a			;7528
	ret z			;7529
	cp 0e0h			;752a
	jr nc,L_7516		;752c
	inc hl			;752e
	add a,040h		;752f
	out (098h),a		;7531
	jr L_7527		;7533

; ----------------------------------------------------------------------
; DATOS punteros_de_la_meta: Cinco punteros, uno por cada tramo de 32 metros del final. Cierra clavada en 0x7569, que es el primero de ellos
;   0x7535..0x753f  (10 bytes)
; DATOS bloques_de_la_meta: Los cinco bloques que va dibujando 0x7519
;   0x753f..0x75c5  (134 bytes)
; ----------------------------------------------------------------------
	defb 07ah,075h,057h,075h,049h,075h,044h,075h,03fh,075h,021h,0efh,090h,091h,000h,021h	; 7535  zuWuIuDu?u!....!
	defb 0efh,092h,093h,000h,001h,0efh,0afh,0eeh,094h,096h,096h,098h,0eeh,095h,097h,097h	; 7545  ................
	defb 09ah,000h,0e0h,0efh,0afh,0efh,0b1h,0b2h,0edh,09dh,09bh,09ch,09ch,09ch,09bh,0edh	; 7555  ................
	defb 0c8h,09eh,0a4h,0a6h,0a8h,0a1h,0edh,0c8h,09fh,0a5h,0a7h,0a9h,0c9h,0edh,0a3h,0a0h	; 7565  ................
	defb 0a0h,0a0h,0adh,0a0h,000h,0c0h,0efh,071h,0efh,0b0h,0efh,0b1h,0b2h,0ebh,09dh,09dh	; 7575  .......q........
	defb 09bh,09bh,09bh,09ch,09ch,09ch,09ch,09bh,0ebh,0c8h,0c8h,0c9h,0c9h,0c9h,0c9h,0c9h	; 7585  ................
	defb 0a2h,0a2h,0c9h,0ebh,0c8h,0c8h,0c9h,0aah,0c9h,0aah,0c9h,099h,0c9h,0c9h,0ebh,0c8h	; 7595  ................
	defb 0c8h,0c9h,0abh,0c9h,0abh,0c9h,099h,0c9h,0c9h,0ebh,0c8h,0c8h,0c9h,0c9h,0c9h,0c9h	; 75a5  ................
	defb 0c9h,0aeh,0c9h,0c9h,0ebh,0a3h,0a3h,0ach,0a0h,0a0h,0ach,0ach,09ah,0a0h,0ach,000h	; 75b5  ................

; ======================================================================
; CODIGO 0x75c5..0x7709  (324 bytes)
; ======================================================================


L_75C5:
	ld hl,0e183h		;75c5
	ld a,(hl)		;75c8
	and 0e3h		;75c9
	ret nz			;75cb
	ld de,0e113h		;75cc
	ld b,003h		;75cf
L_75D1:
	ld a,(de)		;75d1
	cp 003h			;75d2
	jr nc,L_75DD		;75d4
	dec de			;75d6
	ld a,(de)		;75d7
	cp 007h			;75d8
	jr z,L_75E5		;75da
	inc de			;75dc
L_75DD:
	ld a,006h		;75dd
	call L_48D4		;75df
	djnz L_75D1		;75e2
	ret			;75e4
L_75E5:
	ld (0e181h),de		;75e5
	inc de			;75e9
	ld a,(0e18ah)		;75ea
	ld c,a			;75ed
	ld a,(0e003h)		;75ee
	cp c			;75f1
	jr nc,L_762D		;75f2
	ld a,(0e009h)		;75f4
	and 00ch		;75f7
	jr z,L_75FF		;75f9
	bit 2,a			;75fb
	jr L_7608		;75fd
L_75FF:
	ld a,(0e185h)		;75ff
	inc a			;7602
	ld (0e185h),a		;7603
	bit 0,a			;7606
L_7608:
	ld a,090h		;7608
	set 0,(hl)		;760a
	jr z,L_7612		;760c
	ld a,080h		;760e
	rlc (hl)		;7610
L_7612:
	ld c,a			;7612
	ld hl,0e08ch		;7613
	ld a,(de)		;7616
	ld d,c			;7617
	cp 001h			;7618
	ld bc,07a66h		;761a
	jr c,L_7623		;761d
	jr z,L_7625		;761f
	ld b,092h		;7621
L_7623:
	jr L_7627		;7623
L_7625:
	ld b,064h		;7625
L_7627:
	ld (hl),c		;7627
	inc hl			;7628
	ld (hl),b		;7629
	inc hl			;762a
	ld (hl),d		;762b
	ret			;762c
L_762D:
	xor a			;762d
	ld (0e192h),a		;762e
	ld a,(de)		;7631
	cp 001h			;7632
	jr c,L_763B		;7634
	jr z,L_763E		;7636
	set 5,(hl)		;7638
	ret			;763a
L_763B:
	set 6,(hl)		;763b
	ret			;763d
L_763E:
	set 7,(hl)		;763e
	ret			;7640
L_7641:
	ld a,(0e003h)		;7641
	rra			;7644
	ret c			;7645
L_7646:
	ld hl,(0e08ch)		;7646
	ld (0e188h),hl		;7649
	ld hl,0e08ch		;764c
	ld de,03b3ch		;764f
	ld bc,00004h		;7652
	call L_44DC		;7655
	ld de,0e183h		;7658
	ld a,(de)		;765b
	and 003h		;765c
	ret z			;765e
	ld hl,0e08eh		;765f
	call L_76A3		;7662
	ld a,(de)		;7665
	dec hl			;7666
	rra			;7667
	jr c,L_766E		;7668
	dec (hl)		;766a
	dec (hl)		;766b
	jr L_7670		;766c
L_766E:
	inc (hl)		;766e
	inc (hl)		;766f
L_7670:
	push hl			;7670
	ld hl,0e184h		;7671
	inc (hl)		;7674
	ld a,(hl)		;7675
	pop hl			;7676
	dec hl			;7677
	cp 008h			;7678
	jr c,L_7691		;767a
	cp 010h			;767c
	ret c			;767e
	jr z,L_7694		;767f
	cp 022h			;7681
	jr nc,L_769B		;7683
	ld c,005h		;7685
	cp 01ah			;7687
	jr c,L_768D		;7689
	inc c			;768b
	inc c			;768c
L_768D:
	ld a,(hl)		;768d
	add a,c			;768e
	ld (hl),a		;768f
	ret			;7690
L_7691:
	dec (hl)		;7691
	dec (hl)		;7692
	ret			;7693
L_7694:
	inc hl			;7694
	inc hl			;7695
	ld a,(hl)		;7696
	add a,008h		;7697
	ld (hl),a		;7699
	ret			;769a
L_769B:
	ld (hl),0e0h		;769b
	xor a			;769d
	ld (de),a		;769e
	inc de			;769f
	ld (de),a		;76a0
	jr L_7646		;76a1
L_76A3:
	ld a,(0e003h)		;76a3
	and 00fh		;76a6
	ret nz			;76a8
	ld a,(hl)		;76a9
	srl a			;76aa
	srl a			;76ac
	srl a			;76ae
	ccf			;76b0
	rla			;76b1
	rla			;76b2
	rla			;76b3
	ld (hl),a		;76b4
	ret			;76b5
L_76B6:
	call L_7701		;76b6
	ld a,(0e100h)		;76b9
	or a			;76bc
	rra			;76bd
	ld (0e148h),a		;76be
	ld a,(0e0e6h)		;76c1
	and 00ch		;76c4
	ld a,02ch		;76c6
	jr nz,L_76CC		;76c8
	add a,004h		;76ca
L_76CC:
	ld c,a			;76cc
	ld a,(0e0e0h)		;76cd
	and 0f0h		;76d0
	jr z,L_76E0		;76d2
	and 0e0h		;76d4
	jr z,L_76DC		;76d6
	ld a,c			;76d8
	sub 004h		;76d9
	ld c,a			;76db
L_76DC:
	ld a,c			;76dc
	sub 004h		;76dd
	ld c,a			;76df
L_76E0:
	ld a,(0e100h)		;76e0
	cp 00ch			;76e3
	jr c,L_76F4		;76e5
	and 00ch		;76e7
	jr z,L_76FC		;76e9
	cp 00ch			;76eb
	jr z,L_76F8		;76ed
	ld a,c			;76ef
L_76F0:
	ld (0e10eh),a		;76f0
	ret			;76f3
L_76F4:
	ld a,c			;76f4
	sub 004h		;76f5
	ld c,a			;76f7
L_76F8:
	ld a,c			;76f8
	sub 004h		;76f9
	ld c,a			;76fb
L_76FC:
	ld a,c			;76fc
	sub 004h		;76fd
	jr L_76F0		;76ff
L_7701:
	ld a,(0e009h)		;7701
	and 003h		;7704
	call L_4098		;7706

; ----------------------------------------------------------------------
; DATOS tabla_de_saltos_7709: Los 4 destinos del CALL de 0x7706. Cierra clavada contra su primer destino
;   0x7709..0x7711  (8 bytes)
; ----------------------------------------------------------------------
	defb 03fh,077h,011h,077h,029h,077h,03fh,077h	; 7709  ?w.w)w?w

; ======================================================================
; CODIGO 0x7711..0x780c  (251 bytes)
; ======================================================================


L_7711:
	ld hl,0e0fdh		;7711
	xor a			;7714
	ld (hl),a		;7715
	inc hl			;7716
	inc hl			;7717
	ld (hl),a		;7718
	dec hl			;7719
	inc (hl)		;771a
	ld a,(hl)		;771b
	sub 00ch		;771c
	ret nz			;771e
	ld (hl),a		;771f
	ld hl,0e100h		;7720
	ld a,(hl)		;7723
	cp 009h			;7724
	ret c			;7726
	dec (hl)		;7727
	ret			;7728
L_7729:
	ld hl,0e0fdh		;7729
	xor a			;772c
	ld (hl),a		;772d
	inc hl			;772e
	ld (hl),a		;772f
	inc hl			;7730
	inc (hl)		;7731
	ld a,(hl)		;7732
	sub 004h		;7733
	ret nz			;7735
	ld (hl),a		;7736
	ld hl,0e100h		;7737
	ld a,(hl)		;773a
	cp 013h			;773b
	ret nc			;773d
	inc (hl)		;773e
L_773F:
	ret			;773f
L_7740:
	ld a,(0e140h)		;7740
	ld hl,0e142h		;7743
	add a,(hl)		;7746
	ld hl,0e171h		;7747
	jr nz,L_776B		;774a
	ld a,(0e100h)		;774c
	ld b,a			;774f
	and 001h		;7750
	add a,042h		;7752
	ld c,a			;7754
	ld a,b			;7755
	rra			;7756
	cpl			;7757
	and 00fh		;7758
	sub 006h		;775a
	jr z,L_7764		;775c
	ld b,a			;775e
L_775F:
	ld (hl),042h		;775f
	inc hl			;7761
	djnz L_775F		;7762
L_7764:
	ld (hl),c		;7764
	inc hl			;7765
	ld a,l			;7766
	cp 078h			;7767
	jr z,L_776F		;7769
L_776B:
	ld c,000h		;776b
	jr L_7764		;776d
L_776F:
	ld hl,0e171h		;776f
	ld de,03839h		;7772
	ld bc,00006h		;7775
	jp L_44DC		;7778
L_777B:
	ld a,(0e002h)		;777b
	bit 6,a			;777e
	ret z			;7780
	ld b,004h		;7781
	ld de,0e0b8h		;7783
	ld hl,0e14ah		;7786
L_7789:
	ld a,(hl)		;7789
	or a			;778a
	ld a,004h		;778b
	jr nz,L_77AA		;778d
	push hl			;778f
	inc (hl)		;7790
	ld hl,0780eh		;7791
	ld a,b			;7794
	add a,a			;7795
	call L_48CF		;7796
	ld a,(hl)		;7799
	ld (de),a		;779a
	inc hl			;779b
	inc de			;779c
	ld a,(hl)		;779d
	ld (de),a		;779e
	inc de			;779f
	ld a,0e0h		;77a0
	ld (de),a		;77a2
	inc de			;77a3
	ld a,00fh		;77a4
	ld (de),a		;77a6
	ld a,001h		;77a7
	pop hl			;77a9
L_77AA:
	call L_48D4		;77aa
	inc hl			;77ad
	djnz L_7789		;77ae
	ld hl,0e149h		;77b0
	dec (hl)		;77b3
	ret nz			;77b4
	ld a,(0e148h)		;77b5
	ld (hl),a		;77b8
	ld b,000h		;77b9
	ld hl,0e14ah		;77bb
	ld de,0e0b8h		;77be
L_77C1:
	ld a,(hl)		;77c1
	or a			;77c2
	jr z,L_77F4		;77c3
	ld a,(de)		;77c5
	cp 008h			;77c6
	jr nz,L_77D1		;77c8
	ld a,0d1h		;77ca
	ld (de),a		;77cc
	ld (hl),000h		;77cd
	jr L_77F4		;77cf
L_77D1:
	push de			;77d1
	inc (hl)		;77d2
	ex de,hl		;77d3
	dec (hl)		;77d4
	push de			;77d5
	ld de,0780ch		;77d6
	ld a,b			;77d9
	call L_48D4		;77da
	ld a,(de)		;77dd
	inc hl			;77de
	add a,(hl)		;77df
	ld (hl),a		;77e0
	ex de,hl		;77e1
	pop hl			;77e2
	ld a,(hl)		;77e3
	cp 00ch			;77e4
	ld a,0dch		;77e6
	jr z,L_77F1		;77e8
	ld a,(hl)		;77ea
	cp 018h			;77eb
	ld a,0d8h		;77ed
	jr nz,L_77F3		;77ef
L_77F1:
	inc de			;77f1
	ld (de),a		;77f2
L_77F3:
	pop de			;77f3
L_77F4:
	ld a,004h		;77f4
	call L_48D4		;77f6
	inc hl			;77f9
	ld a,004h		;77fa
	inc b			;77fc
	cp b			;77fd
	jr nz,L_77C1		;77fe
	ld hl,0e0b8h		;7800
	ld de,03b68h		;7803
	ld bc,00010h		;7806
	jp L_44DC		;7809

; ----------------------------------------------------------------------
; DATOS nubes_desplazamientos: Cuanto se corre de lado cada nube en cada paso: -1, +1, -2 y +2. Con la Y subiendo y la X abriendose, las cuatro se separan del centro segun se acercan
;   0x780c..0x7810  (4 bytes)
; DATOS nubes_posiciones: Por donde asoma cada nube: cuatro parejas (Y, X), las cuatro en la misma columna y a alturas distintas
;   0x7810..0x7818  (8 bytes)
; ----------------------------------------------------------------------
	defb 0ffh,001h,0feh,002h,038h,098h,037h,058h,03ch,07ch,03ah,074h	; 780c  ....8.7X<|:t

; ======================================================================
; CODIGO 0x7818..0x7897  (127 bytes)
; ======================================================================


L_7818:
	ld a,(0e183h)		;7818
	and 0e0h		;781b
	ret z			;781d
	ld hl,(0e181h)		;781e
	ld a,(hl)		;7821
	ld hl,0e183h		;7822
	sub 00fh		;7825
	jr nz,L_7831		;7827
	ld (hl),a		;7829
	ld hl,07993h		;782a
	ld b,004h		;782d
	jr L_786D		;782f
L_7831:
	ld hl,07897h		;7831
	add a,008h		;7834
	ld b,a			;7836
	add a,a			;7837
	call L_48CF		;7838
	ld e,(hl)		;783b
	inc hl			;783c
	ld d,(hl)		;783d
	ld a,b			;783e
	ld b,004h		;783f
	cp 006h			;7841
	jr c,L_7851		;7843
	ld hl,0e137h		;7845
	bit 0,(hl)		;7848
	jr nz,L_7851		;784a
	ld hl,0e192h		;784c
	ld (hl),001h		;784f
L_7851:
	cp 003h			;7851
	ex de,hl		;7853
	ld d,00ch		;7854
	jr nc,L_785C		;7856
	ld d,006h		;7858
	ld b,002h		;785a
L_785C:
	ld a,(0e183h)		;785c
	cp 040h			;785f
	jr z,L_786D		;7861
	jr c,L_7869		;7863
	ld a,d			;7865
	call L_48CF		;7866
L_7869:
	ld a,d			;7869
	call L_48CF		;786a
L_786D:
	ld de,0e090h		;786d
	push de			;7870
L_7871:
	ld c,003h		;7871
L_7873:
	ld a,(hl)		;7873
	ld (de),a		;7874
	inc hl			;7875
	inc de			;7876
	dec c			;7877
	jr nz,L_7873		;7878
	inc de			;787a
	djnz L_7871		;787b
	pop hl			;787d
	ld c,010h		;787e
	ld a,(0e192h)		;7880
	rra			;7883
	ld de,03b00h		;7884
	jr nc,L_788F		;7887
	call L_44DC		;7889
	ld hl,0e050h		;788c
L_788F:
	ld de,03b40h		;788f
	ld c,010h		;7892
	jp L_44DC		;7894

; ----------------------------------------------------------------------
; DATOS punteros_de_la_foca: Ocho punteros, uno por cada paso del 7 al 14. 0x785B los indexa con paso-7, no con el tipo de obstaculo: leido de la otra manera salen punteros que se van fuera del cartucho. Cierra clavada en 0x78D3, que es el primero de ellos
;   0x7897..0x78a7  (16 bytes)
; DATOS fotogramas_de_la_foca: Los ocho fotogramas, cada uno con TRES variantes que elige 0x7886 con el bit que 0x7657 encendio en 0xE183. Los tres primeros pasos llevan dos sprites (18 bytes = 3 x 2 x 3) y los cinco siguientes cuatro (36 bytes); de cada sprite van tres bytes: Y, X y patron. LAS TRES VARIANTES LLEVAN EL MISMO DIBUJO y solo cambian la X: una sale por el centro (0x78), otra se va a la derecha y otra a la izquierda, separandose mas en cada paso. Y del paso 10 al 14 los cuatro patrones son siempre C0, C4, C8 y CC: lo unico que cambia es la Y, que baja de 0x7B a 0xA1. La foca no se deforma, se acerca
;   0x78a7..0x7993  (236 bytes)
; DATOS foca_escondida: El fotograma del paso 15, con las cuatro Y a 0xE0 para sacarla de la pantalla. Cierra clavado en 0x79C9, donde vuelve a haber codigo
;   0x7993..0x799f  (12 bytes)
; ----------------------------------------------------------------------
	defb 0a9h,078h,0bbh,078h,0cdh,078h,0dfh,078h,003h,079h,027h,079h,04bh,079h,06fh,079h	; 7897  .x.x.x.x.y'yKyoy
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
	defb 0a1h,032h,0c0h,0b1h,02ah,0c4h,0a1h,032h,0c8h,0b1h,03ah,0cch,0e0h,000h,000h,0e0h	; 7987  .2..*..2..:.....
	defb 000h,000h,0e0h,000h,000h,0e0h,000h,000h	; 7997  ........

; ======================================================================
; CODIGO 0x799f..0x7b06  (359 bytes)
; ======================================================================


L_799F:
	di			;799f
	push hl			;79a0
	push de			;79a1
	push bc			;79a2
	push af			;79a3
	call L_79AD		;79a4
	pop af			;79a7
	pop bc			;79a8
	pop de			;79a9
	pop hl			;79aa
	ei			;79ab
	ret			;79ac
L_79AD:
	ld b,002h		;79ad
	ld hl,0e012h		;79af
	cp 08ah			;79b2
	jr c,L_79BD		;79b4
	cp 08ch			;79b6
	jr c,L_79C1		;79b8
	inc b			;79ba
	jr L_79C1		;79bb
L_79BD:
	dec b			;79bd
	ld hl,0e026h		;79be
L_79C1:
	cp (hl)			;79c1
	jr c,L_79E7		;79c2
	ld c,a			;79c4
	and 03fh		;79c5
	add a,a			;79c7
	ld de,07b21h		;79c8
	call L_48D4		;79cb
L_79CE:
	dec hl			;79ce
	dec hl			;79cf
	ld (hl),001h		;79d0
	inc hl			;79d2
	ld (hl),001h		;79d3
	inc hl			;79d5
	ld a,c			;79d6
	ld (hl),a		;79d7
	inc hl			;79d8
	ld a,(de)		;79d9
	ld (hl),a		;79da
	inc hl			;79db
	inc de			;79dc
	ld a,(de)		;79dd
	ld (hl),a		;79de
	ld a,008h		;79df
	call L_48CF		;79e1
	inc de			;79e4
	djnz L_79CE		;79e5
L_79E7:
	ret			;79e7
L_79E8:
	inc hl			;79e8
	ld a,(hl)		;79e9
	inc a			;79ea
	jr z,L_79FD		;79eb
	inc (ix+009h)		;79ed
	dec a			;79f0
	cp (ix+009h)		;79f1
	jr nz,L_79FD		;79f4
	xor a			;79f6
	ld (ix+009h),a		;79f7
	jp L_7A73		;79fa
L_79FD:
	ld a,(ix+002h)		;79fd
	push bc			;7a00
	call L_79AD		;7a01
	pop bc			;7a04
	ret			;7a05
L_7A06:
	ld c,001h		;7a06
	ld ix,0e010h		;7a08
	exx			;7a0c
	ld b,003h		;7a0d
	ld de,0000ah		;7a0f
L_7A12:
	exx			;7a12
	ld a,(ix+002h)		;7a13
	or a			;7a16
	call nz,L_7A23	;7a17
	inc c			;7a1a
	inc c			;7a1b
	exx			;7a1c
	add ix,de		;7a1d
	djnz L_7A12		;7a1f
	exx			;7a21
	ret			;7a22
L_7A23:
	jp m,L_7A7A		;7a23
	dec (ix+000h)		;7a26
	ret nz			;7a29
L_7A2A:
	ld l,(ix+003h)		;7a2a
	ld h,(ix+004h)		;7a2d
	ld a,(hl)		;7a30
	cp 0feh			;7a31
	jr z,L_79E8		;7a33
	jr nc,L_7A73		;7a35
	bit 7,(ix+002h)		;7a37
	jp nz,L_7AA5		;7a3b
	and 0f0h		;7a3e
	cp 020h			;7a40
	jr nz,L_7A4B		;7a42
	ld a,(hl)		;7a44
	and 00fh		;7a45
	ld (ix+001h),a		;7a47
	inc hl			;7a4a
L_7A4B:
	ld a,(hl)		;7a4b
	and 0f0h		;7a4c
	ld b,a			;7a4e
	xor (hl)		;7a4f
	ld d,a			;7a50
	inc hl			;7a51
	ld e,(hl)		;7a52
	inc hl			;7a53
	ld (ix+003h),l		;7a54
	ld (ix+004h),h		;7a57
	ex de,hl		;7a5a
	call L_7AF7		;7a5b
	ld a,b			;7a5e
	rrca			;7a5f
	rrca			;7a60
	rrca			;7a61
	rrca			;7a62
	and 00fh		;7a63
L_7A65:
	ld h,a			;7a65
	ld a,(ix+001h)		;7a66
	ld (ix+000h),a		;7a69
	add a,003h		;7a6c
	ld (ix+008h),a		;7a6e
	jr L_7A9B		;7a71
L_7A73:
	xor a			;7a73
	ld (ix+002h),a		;7a74
	ld h,a			;7a77
	jr L_7A9B		;7a78
L_7A7A:
	dec (ix+000h)		;7a7a
	jr z,L_7A2A		;7a7d
	dec (ix+008h)		;7a7f
	ld a,(ix+008h)		;7a82
	cp (ix+000h)		;7a85
	jr nz,L_7A8F		;7a88
	cp 001h			;7a8a
	jr c,L_7A92		;7a8c
	ret			;7a8e
L_7A8F:
	dec (ix+008h)		;7a8f
L_7A92:
	ld a,(ix+007h)		;7a92
	dec a			;7a95
	ret m			;7a96
	ld (ix+007h),a		;7a97
	ld h,a			;7a9a
L_7A9B:
	ld a,c			;7a9b
	rrca			;7a9c
	add a,088h		;7a9d
	out (0a0h),a		;7a9f
	ld a,h			;7aa1
	out (0a1h),a		;7aa2
	ret			;7aa4
L_7AA5:
	cp 0fdh			;7aa5
	jr nz,L_7AB9		;7aa7
	inc hl			;7aa9
	ld a,(hl)		;7aaa
	and 007h		;7aab
	ld (ix+005h),a		;7aad
	xor (hl)		;7ab0
	rrca			;7ab1
	rrca			;7ab2
	rrca			;7ab3
	ld (ix+006h),a		;7ab4
	inc hl			;7ab7
	ld a,(hl)		;7ab8
L_7AB9:
	and 00fh		;7ab9
	ld b,a			;7abb
	xor (hl)		;7abc
	inc hl			;7abd
	ld (ix+003h),l		;7abe
	ld (ix+004h),h		;7ac1
	rrca			;7ac4
	rrca			;7ac5
	rrca			;7ac6
	rrca			;7ac7
	ld hl,07b13h		;7ac8
	call L_48CF		;7acb
	ld a,(hl)		;7ace
	ld (ix+001h),a		;7acf
	ld a,b			;7ad2
	sub 00ch		;7ad3
	ld (ix+007h),a		;7ad5
	jr z,L_7AE0		;7ad8
	ld a,(ix+006h)		;7ada
	ld (ix+007h),a		;7add
L_7AE0:
	call L_7A65		;7ae0
	ld a,b			;7ae3
	ld hl,07b07h		;7ae4
	call L_48CF		;7ae7
	ld l,(hl)		;7aea
	ld h,000h		;7aeb
	ld a,(ix+005h)		;7aed
	or a			;7af0
	jr z,L_7AF7		;7af1
	ld b,a			;7af3
L_7AF4:
	add hl,hl		;7af4
	djnz L_7AF4		;7af5
L_7AF7:
	ld a,c			;7af7
	out (0a0h),a		;7af8
	ld a,h			;7afa
	out (0a1h),a		;7afb
	dec c			;7afd
	ld a,c			;7afe
	out (0a0h),a		;7aff
	ld a,l			;7b01
	out (0a1h),a		;7b02
	inc c			;7b04
	ret			;7b05

; ----------------------------------------------------------------------
; DATOS byte_suelto: Un 0xFF que no apunta nadie, justo delante de la tabla de notas
;   0x7b06..0x7b07  (1 bytes)
; DATOS tabla_de_notas: Doce periodos, una octava cromatica: la desviacion respecto al temperamento igual es de 0,090 semitonos, y los doce bytes de al lado dan 15,8
;   0x7b07..0x7b13  (12 bytes)
; DATOS tabla_de_duraciones: Las doce duraciones, indexadas por el nibble alto de cada nota. Van de 5 a 100 fotogramas y NO son una escala, aunque esten pegadas a la que si lo es
;   0x7b13..0x7b21  (14 bytes)
; DATOS punteros_de_sonido: Veinticuatro punteros a los flujos. Cierra clavada en 0x7B82, que es el primero. El del sonido 0 apunta fuera de la ROM porque no se pide nunca, y los tres ultimos apuntan al 0xFF de 0x7B82: el sonido 0x95, el que llama 0x44BD al arrancar, es un flujo que se acaba en el primer byte, o sea el silencio
;   0x7b21..0x7b51  (48 bytes)
; DATOS flujos_de_sonido: Los veintiun flujos de musica y efectos
;   0x7b51..0x7e86  (821 bytes)
; DATOS relleno_final: Lo que sobra del cartucho hasta los 16 KB
;   0x7e86..0x8000  (378 bytes)
; ----------------------------------------------------------------------
	defb 0ffh,06ah,064h,05fh,059h,054h,050h,04bh,047h,043h,03fh,03ch,038h,008h,010h,020h	; 7b06  .jd_YTPKGC?<8.. 
	defb 030h,040h,060h,005h,00ah,00fh,014h,064h,01eh,018h,03ch,050h,028h,015h,07dh,0efh	; 7b16  0@`....d..<P(.}.
	defb 07ch,04dh,07dh,055h,07dh,039h,07dh,02dh,07dh,01bh,07dh,044h,07eh,0fdh,07ch,052h	; 7b26  |M}U}9}-}.}D~.|R
	defb 07bh,0d2h,07bh,0f1h,07dh,00eh,07eh,031h,07eh,0a8h,07ch,0c6h,07ch,0ddh,07ch,05dh	; 7b36  {.{.}.~1~.|.|.|]
	defb 07dh,08fh,07dh,0c2h,07dh,051h,07bh,051h,07bh,051h,07bh,0ffh,0fdh,05ah,03bh,0fdh	; 7b46  }.}.}Q{Q{Q{..Z;.
	defb 059h,022h,014h,054h,030h,024h,016h,056h,039h,027h,0fdh,05ah,01bh,0fdh,059h,032h	; 7b56  Y".T0$.V9'.Z..Y2
	defb 020h,0fdh,05ah,01bh,03bh,039h,047h,0fdh,059h,002h,007h,004h,007h,002h,007h,004h	; 7b66   .Z.;9G.Y.......
	defb 007h,002h,007h,004h,007h,002h,007h,004h,007h,012h,006h,00ch,006h,00ch,012h,006h	; 7b76  ................
	defb 00ch,006h,00ch,002h,009h,004h,009h,002h,009h,004h,009h,002h,009h,004h,009h,012h	; 7b86  ................
	defb 007h,00ch,007h,00ch,012h,007h,00ch,007h,00ch,002h,007h,006h,007h,002h,007h,002h	; 7b96  ................
	defb 007h,005h,007h,002h,007h,000h,007h,004h,007h,000h,007h,000h,007h,003h,007h,000h	; 7ba6  ................
	defb 007h,0fdh,05ah,00bh,0fdh,059h,007h,002h,007h,0fdh,05ah,00bh,0fdh,059h,007h,000h	; 7bb6  ..Z..Y....Z..Y..
	defb 006h,002h,006h,000h,006h,017h,01ch,016h,017h,02ch,0feh,0ffh,0fdh,05bh,017h,0fdh	; 7bc6  .........,...[..
	defb 05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,010h	; 7bd6  Z...[..Z...[..Z.
	defb 010h,0fdh,05bh,017h,0fdh,05ah,010h,010h,0fdh,05bh,017h,0fdh,05ah,014h,014h,0fdh	; 7be6  ..[..Z...[..Z...
	defb 05bh,017h,0fdh,05ah,014h,014h,0fdh,05bh,016h,0fdh,05ah,012h,012h,0fdh,05bh,016h	; 7bf6  [..Z...[..Z...[.
	defb 0fdh,05ah,012h,012h,0fdh,05bh,010h,019h,019h,017h,0fdh,05ah,012h,012h,0fdh,05bh	; 7c06  .Z...[.....Z...[
	defb 017h,0fdh,05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh	; 7c16  ..Z...[..Z...[..
	defb 05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h	; 7c26  Z...[..Z...[..Z.
	defb 0fdh,05bh,01bh,027h,01ch,01bh,0fdh,05ah,012h,012h,0fdh,05bh,01bh,0fdh,05ah,012h	; 7c36  .[.'...Z...[..Z.
	defb 012h,0fdh,05bh,016h,0fdh,05ah,012h,012h,0fdh,05bh,016h,0fdh,05ah,012h,012h,0fdh	; 7c46  ..[..Z...[..Z...
	defb 05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,019h,0fdh,05ah,012h,012h,0fdh,05bh,017h	; 7c56  [..Z...[..Z...[.
	defb 0fdh,05ah,012h,012h,0fdh,05bh,017h,0fdh,05ah,012h,012h,0fdh,05bh,012h,017h,01bh	; 7c66  .Z...[..Z...[...
	defb 017h,01bh,0fdh,05ah,012h,0fdh,05bh,017h,0fdh,05ah,010h,014h,0fdh,05bh,017h,0fdh	; 7c76  ...Z..[..Z...[..
	defb 05ah,010h,014h,0fdh,05bh,017h,0fdh,05ah,012h,01ch,0fdh,05bh,019h,0fdh,05ah,012h	; 7c86  Z...[..Z...[..Z.
	defb 01ch,012h,01ch,0fdh,05bh,01bh,0fdh,05ah,002h,000h,0fdh,05bh,00bh,009h,007h,00ch	; 7c96  ....[..Z...[....
	defb 0feh,0ffh,0fdh,059h,090h,080h,060h,090h,0fdh,05ah,08bh,069h,097h,094h,097h,094h	; 7ca6  ...Y..`..Z.i....
	defb 072h,074h,075h,077h,079h,077h,079h,07bh,0fdh,061h,090h,080h,060h,090h,0ffh,0ffh	; 7cb6  rtuwywy{.a..`...
	defb 0fdh,05bh,097h,097h,097h,09ch,097h,097h,097h,09ch,095h,092h,097h,0fdh,05ch,097h	; 7cc6  .[............\.
	defb 0fdh,063h,090h,097h,097h,0ffh,0ffh,0fdh,05bh,090h,090h,090h,09ch,090h,090h,090h	; 7cd6  .c......[.......
	defb 09ch,0ach,0fdh,05ah,084h,064h,094h,0ffh,0ffh,022h,0d0h,07fh,0b0h,070h,0b0h,077h	; 7ce6  ...Z.d..."...p.w
	defb 0a0h,062h,090h,050h,080h,043h,0ffh,023h,090h,060h,090h,040h,090h,060h,090h,040h	; 7cf6  .b.P.C.#.`.@.`.@
	defb 090h,060h,090h,040h,090h,060h,090h,040h,090h,060h,090h,040h,090h,060h,0ffh,021h	; 7d06  .`.@.`.@.`.@.`.!
	defb 0a0h,025h,0a0h,027h,0ffh,021h,0c0h,0ddh,0c0h,0bbh,0b0h,0aah,0b0h,099h,0a0h,088h	; 7d16  .%.'.!..........
	defb 0a0h,077h,090h,066h,090h,055h,0ffh,022h,0c0h,055h,0c0h,066h,0c0h,055h,0b0h,044h	; 7d26  .w.f.U.".U.f.U.D
	defb 0a0h,033h,0ffh,022h,0e0h,0a5h,0c0h,0b5h,0a0h,0c5h,090h,0d5h,080h,0e5h,070h,0f5h	; 7d36  .3."..........p.
	defb 061h,005h,051h,025h,051h,045h,0ffh,021h,0c1h,003h,0c1h,00dh,0c1h,006h,0ffh,021h	; 7d46  a.Q%QE.!.......!
	defb 0c1h,043h,0c1h,04dh,0c1h,046h,0ffh,0fdh,05ah,07bh,0fdh,059h,072h,074h,072h,097h	; 7d56  .C.M.F..Z{.Yrtr.
	defb 076h,074h,0b2h,0fdh,05ah,07bh,097h,067h,069h,06bh,0fdh,059h,060h,0fdh,05ah,07bh	; 7d66  vt..Z{.gik.Y`.Z{
	defb 0fdh,059h,072h,074h,072h,097h,076h,074h,062h,064h,062h,060h,0fdh,05ah,06bh,0fdh	; 7d76  .Yrtr.vtbdb`.Zk.
	defb 059h,060h,0fdh,05ah,06bh,069h,097h,09ch,0ffh,0fdh,05ah,077h,07bh,0fdh,059h,070h	; 7d86  Y`.Zki....Zw{.Yp
	defb 0fdh,05ah,07bh,0fdh,059h,092h,070h,070h,0fdh,05ah,0bbh,077h,092h,09ch,077h,07bh	; 7d96  .Z{.Y.pp.Z.w..w{
	defb 0fdh,059h,070h,0fdh,05ah,07bh,0fdh,059h,092h,070h,070h,0fdh,05ah,06bh,0fdh,059h	; 7da6  .Yp.Z{.Y.pp.Zk.Y
	defb 060h,0fdh,05ah,06bh,069h,067h,069h,067h,066h,092h,09ch,0ffh,0fdh,05bh,077h,076h	; 7db6  `.Zkigigf....[wv
	defb 074h,072h,070h,0fdh,05ch,07bh,079h,077h,0fdh,05bh,077h,076h,074h,072h,070h,0fdh	; 7dc6  trp.\{yw.[wvtrp.
	defb 05ch,07bh,079h,077h,0fdh,05bh,077h,076h,074h,072h,070h,0fdh,05ch,07bh,079h,077h	; 7dd6  \{yw.[wvtrp.\{yw
	defb 0fdh,05bh,072h,0fdh,05ch,072h,074h,076h,077h,09ch,0ffh,0fdh,059h,094h,074h,074h	; 7de6  .[r.\rtvw...Y.tt
	defb 094h,072h,070h,0b5h,0fdh,05ah,075h,0b5h,0fdh,059h,075h,094h,070h,074h,092h,0fdh	; 7df6  .rp..Zu..Yu.pt..
	defb 05ah,079h,07bh,0fdh,059h,0d0h,01ch,0ffh,0fdh,05bh,090h,070h,070h,090h,0fdh,05ah	; 7e06  Zy{.Y....[.pp..Z
	defb 07bh,077h,0fdh,059h,0b0h,0fdh,05ah,070h,0b0h,0fdh,059h,070h,090h,0fdh,05ah,077h	; 7e16  {w.Y..Zp..Yp..Zw
	defb 0fdh,059h,070h,0fdh,05ah,09bh,075h,077h,0d7h,01ch,0ffh,0fdh,05bh,097h,094h,097h	; 7e26  .Yp.Z.uw....[...
	defb 094h,099h,095h,099h,095h,097h,094h,097h,095h,097h,097h,097h,09ch,0ffh,022h,0d1h	; 7e36  ..............".
	defb 0eeh,0d1h,0cch,0c1h,0eeh,0b1h,0ffh,0a1h,099h,091h,088h,081h,077h,071h,066h,061h	; 7e46  ............wqfa
	defb 077h,051h,088h,041h,099h,0ffh,021h,000h,0e0h,001h,000h,008h,0f3h,0cdh,0c7h,048h	; 7e56  wQ.A..!........H
	defb 0dbh,098h,077h,023h,00bh,078h,0b1h,020h,0f7h,0fbh,018h,0feh,0ffh,0ffh,0ffh,0ffh	; 7e66  ..w#.x. ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7e76  ................
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
