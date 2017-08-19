; WRAM map - $0000-$2000

; invader table - 2 byte bit array for each row - lowest bit y for column
; e.g. row 1, column 5 = $0002 & $05 cmp 0
; 10 rows, so last row is at $014
constant INVADER_TABLE($0000)

; x position of invaders (1 byte)
constant INVADER_X_POS($0015)

; y position of invaders (1 byte)
constant INVADER_Y_POS($0016)

; x position of player avatar's center (1 byte)
constant PLAYER_X_POS($0017)

; temp value
$0020

; clone of OAM for manipulating sprites
; runs to $1220
constant OAM_CLONE($1000)

; clone of BG 2 tile set info - for manipulating the invaders
; 32 x 32 bg * 2 bytes / tileset = 2048 bytes - ending address = $1300 + $800 = $1B00
constant BG2_CLONE($1300)


; VRAM address map

; CHR data - tile / sprite character data shared by sprites and BGs 1 & 2 
$0000

; BG1 tileset data - word address
$4000 

; BG2 tileset data - word address
$6000

; BG3 tileset data - word address
$7000
