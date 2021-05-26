.arm.big

.open "patches/sections/0xE0000000.bin","patches/patched_sections/0xE0000000.bin",0xE0000000

; allow custom bootLogoTex and bootMovie.h264
.org 0xE0030D68
	mov r0, #0
.org 0xE0030D34
	mov r0, #0

; allow any region title launch
.org 0xE0030498
	mov r0, #0

.Close

.open "patches/sections/0x5100000.bin","patches/patched_sections/0x5100000.bin",0x05100000

; append wupserver code
.org 0x5116000
	wupserver_entrypoint:
		.incbin "wupserver/wupserver.bin"
	.align 0x100

.Close
