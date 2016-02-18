format MZ

entry main:start
stack 100h
use16

segment main
	song dw 301h

start:
	mov	ax,main
	mov	ds,ax

	;----- display tex
	mov	dx, strCommands
	mov	ah, 09
	int	21h




	;----------- Install interupt
	push	ds

	mov	ax, code1
	mov	ds, ax
	mov	dx, adlib

	mov	al, 61h
	mov	ah, 25h
	int	21h

	pop ds

	;--------------
	;- init adlib
	mov	ax, 100h
	int	61h
	;---------------

	call	loadSong

go:

	mov    ax,0h
	int    61h

	nop

	;----- Wait microseconds
	mov    cx, 0h	 ;- high order
	mov    dx, 15000 ;- low order
	mov    ah, 86h
	int    15h

	;----- read keyboard
	mov    ax, 0100h
	int    16h ;- check keybuffer

	jz     go

	;- key is presses
	mov    ax, 0000h
	int    16h  ;- read keybuffer

	cmp    al, 27
	je     endApp

	cmp    al, '+'
	je     nextSong

	cmp    al, '-'
	je     prevSong

	cmp    al, ' '
	je     replaySong

	cmp    al, 'm'
	je     switchToMusic

	cmp    al, 's'
	je     switchToSound

	jmp    go

switchToMusic:
	call   stopSong

	mov    ax,0301h
	mov    [song],ax
	call   loadSong

	jmp go

switchToSound:
	call   stopSong

	mov    [song],0401h
	call   loadSong
	jmp go

replaySong:
	call   stopSong
	call   loadSong
	jmp go

prevSong:
	call   stopSong

	dec    [song]
	call   loadSong
	jmp go

nextSong:
	call   stopSong

	inc    [song]
	call   loadSong
	jmp    go

stopSong:
	mov    ax,0200h
	int    61h
	ret

loadSong:
	;- load Song
	mov	ax,[song]
	int	61h

	;- display "song number: " text
	mov	dx, strSongNumber
	mov	ah, 09h
	int	21h

	;- write out songnumber
	mov	ax, [song]
	call	printNumAL

	ret


endApp:
	;---- ende
	call	stopSong

	mov	ax,4C00h
	int	21h


printNumAL:
	;- Print a deciamal number
	cmp	al, 0
	jne	PRINT_AX

	;- print zero
	push	ax
	mov	al, '0'

	mov	ah, 0Eh
	int	10h

	pop	ax
	ret

PRINT_AX:
	pusha
	mov	ah, 0
	cmp	ax, 0
	je	PN_DONE

	mov	dl, 10
	div	dl
	call	PRINT_AX

	mov	al, ah
	add	al, '0'
	mov	ah, 0Eh
	int	10h
PN_DONE:
	popa
	ret



strCommands    db '-- Lemmings Adlib Player --',10,'use:',10,'  [ESC]   : exit',10,'  + / -   : next/prev Song',10,'  [space] : replay' ,10,'  m       : play music',10,'  s       : play sound',10, '$'
strSongNumber  db 13,'Song Number:      ',8,8,8,8,8, '$'



segment code1
align 4
adlib file "adlib.dat"
