
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

		Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'DADOS.TXT',0
        HandleFich      dw      0
        car_fich        db      ?

		Car			db	32	; Guarda um caracter do Ecra
		Cor			db	7	; Guarda os atributos de cor do caracter
		POSy		db	1	; a linha pode ir de [1 .. 25]
		POSx		db	2	; POSx pode ir [1..80]
dseg	ends ; end of code segment D

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

DisplayFile	proc
	mov     ah,3dh
	mov     al,0
	lea     dx,Fich
	int     21h
	jc      erro_abrir
	mov     HandleFich,ax
	jmp     ler_ciclo
	erro_abrir:
			mov     ah,09h
			lea     dx,Erro_Open
			int     21h
			jmp     sai

	ler_ciclo:
			mov     ah,3fh
			mov     bx,HandleFich
			mov     cx,1
			lea     dx,car_fich
			int     21h
			jc		erro_ler
			cmp		ax,0		;EOF?
			je		fecha_ficheiro
			mov     ah,02h
			mov		dl,car_fich
			int		21h
			jmp		ler_ciclo

	erro_ler:
			mov     ah,09h
			lea     dx,Erro_Ler_Msg
			int     21h

	fecha_ficheiro:
			mov     ah,3eh
			mov     bx,HandleFich
			int     21h
			jnc     sai

			mov     ah,09h
			lea     dx,Erro_Close
			Int     21h
	sai:
		ret
DisplayFile	endp

;todo generate a new board with random letters
GenerateNewGameBoard proc
GenerateNewGameBoard endp

;set a game word or words based on the file and word position
SetBoardGameWord proc
SetBoardGameWord endp

;displays the game words on the board
DisplayGameWords proc
DisplayGameWords endp

HandleWordSelection	PROC
	CICLO:	
			; goto_xy	POSxa,POSya	; Vai para a posição anterior do cursor
			; mov		ah, 02h
			; mov		dl, Car	; Repoe Caracter guardado 
			; int		21H		

			goto_xy	POSx,POSy	; Vai para nova posição
			mov 	ah, 08h
			mov		bh,0		; numero da página
			int		10h		
			mov		Car, al		; Guarda o Caracter que está na posição do Cursor
			mov		Cor, ah		; Guarda a cor que está na posição do Cursor
			
			goto_xy	78,0		; Mostra o caractereque estava na posição do AVATAR
			mov		ah, 02h		; IMPRIME caracter da posição no canto
			mov		dl, Car	
			int		21H			
		
			goto_xy	POSx,POSy	; Vai para posição do cursor
	IMPRIME:	
			; mov		ah, 02h
			; mov		dl, 190		; Coloca AVATAR
			; int		21H	
			; goto_xy	POSx,POSy	; Vai para posição do cursor
			
			; mov		al, POSx	; Guarda a posição do cursor	
			; mov		POSxa, al
			; mov		al, POSy	; Guarda a posição do cursor
			; mov 	POSya, al
			
	LER_SETA:	
			call 	ReadKeyboardInput
			cmp		ah, 1
			je		ESTEND
			
			CMP 	AL, 27	; ESCAPE
			JE		FIM
			CMP		AL, 13
			je		ASSINALA
			jmp		LER_SETA
			
	ESTEND:	cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima
			jmp		CICLO

	BAIXO:	cmp		al,50h
			jne		ESQUERDA
			inc 	POSy		;Baixo
			jmp		CICLO

	ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			dec		POSx		;Esquerda
			dec		POSx		;Esquerda
			jmp		CICLO

	DIREITA:
			cmp		al,4Dh
			jne		LER_SETA 
			inc		POSx		;Direita
			inc		POSx		;Direita
			jmp		CICLO

					; INT 10,9 - Write Character and Attribute at Cursor Position
					; AH = 09
					; AL = ASCII character to write
					; BH = display page  (or mode 13h, background pixel value)
					; BL = character attribute (text) foreground color (graphics)
					; CX = count of characters to write (CX >= 1)
	ASSINALA:
			mov		bl, cor
			not		bl
			mov		cor, bl
			mov 	ah, 09h
			mov		al, car
			mov		bh, 0
			mov		cx, 1
			int		10h
			jmp		CICLO
	fim:	
			RET
HandleWordSelection	endp

HandleGame proc
		call 	CleanScreen
		goto_xy	0,0
		call	DisplayFile
		call	HandleWordSelection
		goto_xy	0,22
HandleGame	endp

GameMenu proc
	loopMenu:
		call ReadKeyboardInput; reads the user keyboard inputs
		call CleanScreen; clean the game screen
		call DisplayMenu; imprime o menu no ecra

		mov ah, 1h
		int 21h

		; based on the user key input call the respective procedure

		cmp 	al, 49 ; 1
		je		OPCSTARTGAME
		cmp		al, 50 ; 2
		je		OPCLEAVE
		cmp		al, 51 ; 3
		je		OPCLEAVE
		cmp		al, 52 ; 4
		je		OPCLEAVE
		cmp		al, 27 ; ESC
		je		OPCLEAVE
		jmp     loopMenu ; try again

		OPCSTARTGAME:
			call HandleGame
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
	call GameMenu ; start the game

Main	endp 					; fim do main

cseg	ends 				; end of code segment C

end		Main 					; fim do programa


; ------------------------------------------------------------------
; ..------------------------ END OF MAIN ---------------------------
; ------------------------------------------------------------------
