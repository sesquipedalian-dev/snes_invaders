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
 
; set up a clone of OAM for direct manipulation, 
; then we'll just DMA it over every frame
rep #%00110000 ; 16 bit abxy
ldx #0 ; loop index
lda #$01 ; gonna set every sprite's X position to 1
_offscreen;
sta $1000, x ; mem addr for OAM copy starts at $1000 
.rept 4 ; get to the next OAM entry
inx 
.endr
cpx #$0200 ; size of low table of OAM
bne _offscreen;

lda #$5555  ; high table value - set all X values to negative
_xmsb:
sta $1000, X
inx
inx
cpx #$0220 ; end of high table of OAM
bne _xmsb
 
rep #%00010000	;16 bit xy
sep #%00100000	;8 bit ab

; load up palettes on DMA 0
ldx #Invaders_16_colorPalettes
lda #:Invaders_16_colorPalettes
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
ldx #Invaders_16_colorTiles	; Address
lda #:Invaders_16_colorTiles	; of UntitledData
ldy #(16*16*4)	; length of data
stx $4312	; write
sta $4314	; address
sty $4315	; and length
lda #%00000001	; set this mode (transferring words)
sta $4310
lda #$18	; $211[89]: VRAM data write
sta $4311	; set destination
ldy #$0000	; Write to VRAM from $0000
sty $2116

; start the DMA processes
lda #%00000011	; start DMA, channels 0 + 1
sta $420B

lda #%10000000	; VRAM writing mode
sta $2115

; initialize all the BG1 tiles to the blank tile
ldx #$4000	; write to vram
stx $2116	; from $4000
.rept 32
	.rept 32
	ldx #3
	stx $2118
	.endr
.endr

; initialize all the BG2 tiles to the blank tile
ldx #$6000	; BG2 will start here
stx $2116
.rept 32
	.rept 32
	ldx #3
	stx $2118
	.endr
.endr

; initialize all the BG3 tiles to the blank tile
ldx #$7000	; BG3 will start here
stx $2116
.rept 32
	.rept 32
	ldx #3
	stx $2118
	.endr
.endr

;set up the screen
lda #%00000001	; 8x8 tiles, mode 1
sta $2105	; screen mode register
lda #%01000000	; data starts from $4000
sta $2107	; for BG1
lda #%01100000	; and $6000
sta $2108	; for BG2
lda #%01110000 ; and $7000 
sta $2109   ; for BG 3

stz $210B	; BG1 and BG2 use the $0000 tiles
;stz $210C ; so do BG 3 and 4

lda #%00010011	; enable bg1&2 AND SPRITES ZOMG
sta $212C ; main screen
lda #0
sta $212D ; enable nothing for sub screen?

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

; GAME INIT - initialize game RAM to sane values
rep #%00100000 ; 16 bit A
lda #$0000 ; clear A
sep #%00100000 ; 8 bit A

; put player sprite in middleish
lda #128
sta $0017

; put invaders x / y 
lda #40
sta $0015 ; X coord
lda #50
sta $0016 ; Y coord

; put invaders on/off flag in mem
lda #$FF ; gonna put FF in every byte - struct is 2 bytes per row, 10 rows, 
         ; each word high / low byte is a bit array of whether a given 
		 ; invader is dead.  E.g.:
		 ; #%00000011 11110000 - dead invaders in positions 0,1,2,3.  
ldx #$0000 ; loop through the 20 bytes
-
sta $0000,x ; invaders status table stored at beginning of mem
inx
cpx #$14
bne -

; initialize player sprite
lda #200  ; y position in sprite 1
sta $1001  
lda #4    ; set tile # for player sprite
sta $1002
lda #%00100000 ; sprite priority
sta $1003
lda #%01010110 ; set 16x16 sprite, no X MSB
sta $1200

; set up sprite table data
lda #0 ; 8x8 and 16x16 sprites, sprite chr data at $0 in VRAM
sta $2102

; all done set up!
lda #%00001111	; enable screen, set brightness to 15
sta $2100

lda #%10000001	; enable NMI and joypads
sta $4200

forever:
wai
; start main loop

; implement game here lol
rep #%00110000	; 16 bit a
lda #$0000 ; clear a
sep #%00100000	;8 bit ab 16 bit xy

; position player sprite
lda $0017 ; x position in sprite 1
sta $1000 

; DMA over the OAM table on channel 0
; copy entire OAM - start OAM addr at 0
stz $2102
stz $2103  

lda #$00 
sta $4300 ; DMA write mode - 1 register, write once
lda #$04
sta $4301 ; DMA destination address 2104 - VRAM data write

ldx #$1000 ; source address
stx $4302
lda #$7E ; bank address
sta $4304 

ldx #$0220 ; size of OAM table
stx $4305

lda #$01 ; do the DMA 
sta $420B

; set up invaders BG
rep #%00110000 ; 16 bit abxy

lda #%10000000	; VRAM writing mode; increment address each write
sta $2115
ldx #$6000	; write to vram
stx $2116	; from $6000

ldx #0;
LoopX:
ldy #0;

; calc offset in BG 2 VRAM 
txa ; load up x into accumulator
.rept 6  ; multiply row by the 32 tiles on that row * 2 for a spacer row
asl 
.endr
sta $0018 ; tmp

LoopY:
; calculate the bitmask for this index
lda #1;
phy ; store col index
LoopBitmask:
	cpy #0 ; loop - shift left Y times
	beq DoneCalcBitmask
	asl
	dey
	bra LoopBitmask
DoneCalcBitmask
ply ; restore current col index
pha ; store a for use as bitmask cmp later

tya ; load up y into accumulator
adc #2 ; add 3 to y - starting column offset

; multiple by 2
sta $0020 ; tmp 2
adc $0020

adc $0018 ; add back the x row offset we determined
adc #$6000 ; offset from $6000
sta $2116 ; set VRAM writing address

pla ; a now has our bitmask
and $0000, x ; mask accumulator with the row we're doing in memory
cmp #0

beq InvaderDead ; check if invader alive; 1 alive 0 dead

; Invader alive
lda #16
sta $2118 ; write this invader
lda #3    ; write the spacer bits
sta $2118 
bra DoneInvader

InvaderDead:
; Invader dead
lda #3    ; write the spacer bits
sta $2118 
sta $2118

DoneInvader:
iny
cpy #10 ; loop column index while not done
bne LoopY

inx
cpx #10 ; loop row index while not done
bne LoopX

; set the horizontal / vertical scroll for bg 2


; end main loop
jmp forever

;--------------------------------------
.ends

.bank 1 slot 0		; We'll use bank 1
.org 0
.section "Tiledata"
.include "Invaders_16_color.inc"	
.ends
