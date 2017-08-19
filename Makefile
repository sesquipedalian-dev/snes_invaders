Invaders.smc: Invaders.obj Invaders.link
	wlalink -r Invaders.link Invaders.smc

Invaders.obj: Invaders.asm InitSNES.asm header.inc Invaders_16_color.inc memmap.asm
	wla-65816.exe -o Invaders.obj Invaders.asm