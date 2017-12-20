;
; File generated by cc65 v 2.16 - Git 18b0aaf
;
	.fopt		compiler,"cc65 v 2.16 - Git 18b0aaf"
	.setcpu		"6502"
	.smart		on
	.autoimport	on
	.case		on
	.debuginfo	off
	.importzp	sp, sreg, regsave, regbank
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
	.macpack	longbranch
	.export		_splitXY

; ---------------------------------------------------------------
; void splitXY (unsigned int x, unsigned int y)
;
; A two-directional split in 4-screen mirroring
;
; ---------------------------------------------------------------

.segment	"CODE"

; aliases
xval = tmp1
yval = tmp2
xnt = tmp3
magic = tmp4

highy = ptr2
highx = ptr3

PPU_STATUS = $2002

.proc	_splitXY: near

.segment	"CODE"

	sta	yval
	stx	highy
	jsr	popax
	sta	xval
	stx	highx

	; if (y < 240)
	lda	highy
	bne	@bottomrow
	lda	yval
	cmp	#240
	bcs	@bottomrow

@toprow:
	; if (x < 256)
	lda	highx
	bne	@topright
	lda	#0
	sta	xnt
	jmp	@ntdone

@topright:
	lda	#4
	sta	xnt
	jmp	@ntdone

@bottomrow:
	; Y was over 240. Subtract 240 from it.
	lda	yval
	sec
	sbc	#240
	sta	yval

	; if (x < 256)
	lda	highx
	bne	@bottomright
	lda	#8
	sta	xnt
	jmp	@ntdone

@bottomright:
	lda	#$c
	sta	xnt

@ntdone:

; precalculate the magic byte
; ((Y & $F8) << 2) | (X >> 3)

	lda	yval
	and	#$f8
	asl	a
	asl	a
	sta	magic

	lda	xval
	lsr	a
	lsr	a
	lsr	a
	ora	magic
	sta	magic

@3:
	bit	PPU_STATUS
	bvs	@3
@4:
	bit	PPU_STATUS
	bvc	@4

; nops here if needed

; action
	lda	xnt
	sta	$2006

	lda	yval
	sta	$2005

	lda	xval
	sta	$2005

	lda	magic
	sta	$2006

	rts
.endproc

