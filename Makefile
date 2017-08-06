Invaders.smc: Invaders.obj Invaders.link
	wlalink -r Invaders.link Invaders.smc

Invaders.obj: Invaders.asm InitSNES.asm header.inc Invaders.inc
	wla-65816.exe -o Invaders.obj Invaders.asm