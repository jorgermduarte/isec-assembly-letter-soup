
.8086
.model small
.stack 2048


PILHA	SEGMENT PARA STACK 'STACK'
		db 2048 dup(?)
PILHA	ENDS

dseg  segment para public 'data' ; start of code segment D

	MenuOptions db "                                                          ",13,10
				db "                    **************************************",13,10
				db "                    *   ISEC - 2021/22 TAC               *",13,10
				db "                    *                                    *",13,10
                db "                    *   Jorge Duarte - a2021110042       *",13,10
                db "                    *   Joao Marques - a2021146383       *",13,10
				db "                    *                                    *",13,10
				db "                    *   1. Jogar                         *",13,10
				db "                    *   2. Top 10                        *",13,10
				db "                    *   3. Sair                          *",13,10
				db "                    *                                    *",13,10
				db "                    **************************************",13,10
				db "                                                          ",13,10
				db "                                                          ",13,10,'$'

dseg	ends ; end of code segment D

; ================ MAIN PROCEDURES =================
cseg	segment para public 'code' ; start of code segment C

assume cs:cseg, ds:dseg, ss:pilha

; ======== MACROS ===========
goto_xy	macro	POSx,POSy
	mov		ah,02h
	mov		bh,0		; numero da pagina
	mov		dl,POSx
	mov		dh,POSy
	int		10h
endm

; ======== END OF MACROS ===========

CleanScreen	proc
	mov		ax,0B800h
	mov		es,ax
	xor		bx,bx
	mov		cx,25*80

	clean:		mov		byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 	bx
		loop	clean
		ret
CleanScreen	endp

DisplayMenu	proc
	goto_xy   0,3
	lea  dx,  MenuOptions ; menu inic
	mov  ah,  9
	int  21h
	ret

DisplayMenu	endp

ReadKeyboardInput	PROC
		mov	ah,08h
		int	21h
		mov	ah,0
		cmp	al,0
		jne	leavekey
		mov	ah, 08h
		int	21h
		mov	ah,1
leavekey:
	ret
ReadKeyboardInput	endp

GameMenu proc
	loopMenu:
		call ReadKeyboardInput; reads the user keyboard inputs
		call CleanScreen; clean the game screen
		call DisplayMenu; imprime o menu no ecra

		mov ah, 1h
		int 21h

		; based on the user key input call the respective procedure

		cmp 	al, 49 ; 1
		je		OPCLEAVE
		cmp		al, 50 ; 2
		je		OPCLEAVE
		cmp		al, 51 ; 3
		je		OPCLEAVE
		cmp		al, 52 ; 4
		je		OPCLEAVE
		cmp		al, 27 ; ESC
		je		OPCLEAVE
		jmp     loopMenu ; try again

		OPCLEAVE:
			mov	ah,4CH
			INT	21H
GameMenu endp

; ------------------------------------------------------------------
; ---------------------------- MAIN --------------------------------
; ------------------------------------------------------------------
Main	proc
	mov			ax, dseg
	mov			ds,ax
	mov			ax,0B800h
	mov			es,ax

	;call CleanScreen		; clean the game screen
	;call		DisplayMenu     ; display the game menu
	call GameMenu ; start the game

Main	endp 					; fim do main

cseg	ends 				; end of code segment C

end		Main 					; fim do programa


; ------------------------------------------------------------------
; ..------------------------ END OF MAIN ---------------------------
; ------------------------------------------------------------------


; ============= END OF MAIN PROCEDURES =============

