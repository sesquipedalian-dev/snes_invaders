.include "header.inc"
.include "initsnes.asm"

.bank 0 slot 0
.org 0
.section "Vblank"
;--------------------------------------
VBlank:
rti		; F|NisH3D!
;--------------------------------------
.ends

.bank 0 slot 0
.org 0
.section "Main"
;--------------------------------------
Start:
 InitSNES
rep #%00010000	;16 bit xy
sep #%00100000	;8 bit ab

; load up palettes
;ldx #$0000
;- 
;lda InvadersPalettes.l,x
;sta $2122
;inx
;cpx #512
;bne -

; load up palettes on DMA 0
ldx #InvadersPalettes
lda #:InvadersPalettes
ldy #(2 * 256) ; all the colors
stx $4302
sta $4304
sty $4305
lda #%00000000 ; transferring bytes mode
sta $4300
lda #$22; store to $2122 - CGRAM palette data
sta $4301
stz $2121 ; start writing palette data at first color in CGRAM

; load up tile character data on DMA 1
ldx #InvadersTiles	; Address
lda #:InvadersTiles	; of UntitledData
ldy #(16*16*2)	; length of data
stx $4312	; write
sta $4314	; address
sty $4315	; and length
lda #%00000001	; set this mode (transferring words)
sta $4310
lda #$18	; $211[89]: VRAM data write
sta $4311	; set destination
ldy #$0000	; Write to VRAM from $0000
sty $2116


lda #%00000011	; start DMA, channels 0 + 1
sta $420B
lda #%10000000	; VRAM writing mode
sta $2115

; initialize all the BG1 tiles to the blank tile
ldx #$4000	; write to vram
stx $2116	; from $4000
.rept 32
	.rept 32
	ldx #28
	stx $2118
	.endr
.endr

; initialize all the BG2 tiles to the blank tile
ldx #$6000	; BG2 will start here
stx $2116
.rept 32
	.rept 32
	ldx #28
	stx $2118
	.endr
.endr

; initialize all the BG3 tiles to the blank tile
ldx #$7000	; BG3 will start here
stx $2116
.rept 32
	.rept 32
	ldx #28
	stx $2118
	.endr
.endr

;set up the screen
lda #%00000000	; 8x8 tiles, mode 0
sta $2105	; screen mode register
lda #%01000000	; data starts from $4000
sta $2107	; for BG1
lda #%01100000	; and $6000
sta $2108	; for BG2
lda #%01110000 ; and $7000 
sta $2109   ; for BG 3

stz $210B	; BG1 and BG2 use the $0000 tiles
;stz $210C ; so do BG 3 and 4

lda #%00000011	; enable bg1&2&3
sta $212C ; main screen
lda #0
sta $212D ; enabe nothing for sub screen?

;The PPU doesn't process the top line, so we scroll down 1 line.
rep #$20        ; 16bit a
lda #$07FF      ; this is -1 for BG1
sep #$20        ; 8bit a
sta $210E       ; BG1 vert scroll
xba
sta $210E

rep #$20        ; 16bit a
lda #$FFFF      ; this is -1 for BG2
sep #$20        ; 8bit a
sta $2110       ; BG2 vert scroll
xba
sta $2110
; done scrolling

; set up sprite table data
lda #0 ; 8x8 and 16x16 sprites, sprite chr data at $0 in VRAM
sta $2102

lda #%00001111	; enable screen, set brightness to 15
sta $2100

lda #%10000001	; enable NMI and joypads
sta $4200



forever:
wai

; implement game here lol

; testing - put player sprite in middleish
lda #128
sta $0017

; rep #%00010000	;16 bit xy
sep #%00110000	;8 bit ab xy

; position player sprite
lda $0017 ; x position of player sprite, ram
stz $2102 ; player sprite is 0 is OAM
stz $2103 ; OAM low table 
sta $2104 ; store x pos in OAM

lda #1 ; OAM addr y position
sta $2102
sta $2103
lda #200;
sta $2104;

lda #2 ; OAM addr player sprite info
sta $2102
stz $2103 
lda #4 ; first player sprite tile
sta $2104

lda #3 ; OAM 4th byte player sprite info
sta $2102
stz $2103
lda #%00000100 ; set sprite's priority above BG 1/2
sta $2104;

; player sprite high table - set 16x16 sprite
stz $2102;
lda #1
sta $2103;
lda #2 ; 16x16 size for sprite 0
sta $2104;

jmp forever

;--------------------------------------
.ends

.bank 1 slot 0		; We'll use bank 1
.org 0
.section "Tiledata"
.include "Invaders.inc"	
.ends
