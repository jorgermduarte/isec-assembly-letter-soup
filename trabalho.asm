
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
				db "                    *   3. Sobre                         *",13,10
				db "                    *   4. Gere Palavras                 *",13,10
				db "                    *   5. Sair                          *",13,10
				db "                    **************************************",13,10
				db "                                                          ",13,10,'$'

	; top 10 classification
	MenuTop10 db "                                                              ",13,10
				db "                    ****************************************",13,10
				db "                          Para voltar clique no ESC         ",13,10
				db "                    ****************************************",13,10
				db " 					 CLASSIFICAO TOP 10:   				",13,10,'$'

	; about the game
	MenuAbout db "                                                              ",13,10
				db "                    ****************************************",13,10
				db "                    *                                      *",13,10
				db "                    *  Neste jogo vais puder encontrar e   *",13,10
                db "                    *  assinalar as palavras escondidas no *",13,10
                db "                    *  tabuleiro com recurso as 'setas' e  *",13,10
				db "                    *  ao 'ENTER'                          *",13,10
				db "                    *                                      *",13,10
				db "                    *              **AVISO**               *",13,10
				db "                    *  !!COMECA SEMPRE PELA PRIMEIRA LETRA *",13,10
				db "                    *           DA  PALAVRA!!              *",13,10
				db "                    ****************************************",13,10
				db "                          Para voltar clique no ESC         ",13,10
				db "                    ****************************************",13,10
				db "                                                            ",13,10,'$'

	MenuGerePalavras db "                                                          ",13,10
				db "                    **************************************",13,10
				db "                    *   Gerir palavras:                  *",13,10
				db "                    *                                    *",13,10
				db "                    *   1. Adicionar nova palavra        *",13,10
				db "                    *   2. Listar palavras               *",13,10
				db "                    *   3. Cancelar                      *",13,10
				db "                    **************************************",13,10
				db "                                                          ",13,10,'$'

	MenuIntroduzaNovaPalavra db "                                             ",13,10
				db "                    **************************************",13,10
				db "                    *   Introduza a nova palavra:        *",13,10
				db "                    *                                    *",13,10
				db "                    *   ->                               *",13,10
				db "                    *                                    *",13,10
				db "                    **************************************",13,10
				db "                                                          ",13,10,'$'

	MenuListaPalavras 		db "                                             ",13,10
				db "                    **************************************",13,10
				db "                    *   Lista de todas as palavras:      *",13,10
				db "                    **************************************",13,10
				db "                                                          ",13,10,'$'

	Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
	Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
	Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
	File_Board      db      'nivel2.txt',0; dados.txt file name
	File_Top10		db 		'top10.txt',0 ; top10.txt file name
	File_WordsList  db 		'palavras.txt',0; palavras.txt file name
	HandleFich      dw      0
	car_fich        db      ?
	; end of the variables used to display the dados.txt

	; variables used by the HandleUserInput procedure
	Car			db	32	; Guarda um caracter do Ecra
	Cor			db	7	; Guarda os atributos de cor do caracter
	; end of the variables used by the HandleUserInput procedure

	; variables used by the goto_xy macro
	POSy		db	1	; a linha pode ir de [1 .. 25]
	POSx		db	2	; POSx pode ir [1..80]
	; end of the variables used by the goto_xy macro

	; Time Variables
	hours		dw			0
	minutes		dw			0
	seconds		dw			0
	actualSeconds 		dw 		0 ;Variable NEEDED for time read from the system
	timeStart	dw			0	  ; Inital start time
	timeGame	dw			?     ;? value for it?
	timeLimit	dw			90	  ; Time limit for the user
	stringLimit db     "/ 90$"
	
	; Problemas com o contador.
	; Podemos apresentar o tempo em que acabou o jogo.
	hoursEnd				dw		?
	secondsEnd			dw		?
	minutesEnd			dw		?
	STR12		db			"     " ; string para 12 digitos


	; variables used by the random procedure
	ultimo_num_aleat dw 0
	str_num db 5 dup(?),'$'

	x word ?
	y word ?
	
	xint db 0

	gameWordsList  dw 75 dup('.'); list of the words to be found
	gameWordsReaded dw 0 ; total words readed from the file

	totalWordsError db 5 dup(0); total failed tries
	totalWordsFound db 5 dup(0); total words found

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

; MOSTRA - Faz o display de uma string terminada em $

MOSTRA MACRO STR 
MOV AH,09H
LEA DX,STR 
INT 21H
ENDM

; ======== END OF MACROS ===========


RandomNumber proc near

	sub	sp,2
	push	bp
	mov	bp,sp
	push	ax
	push	cx
	push	dx	
	mov	ax,[bp+4]
	mov	[bp+2],ax

	mov	ah,00h
	int	1ah

	add	dx,ultimo_num_aleat
	add	cx,dx	
	mov	ax,0
	push	dx
	mul	cx
	pop	dx
	xchg	dl,dh
	add	dx,0
	add	dx,ax

	mov	ultimo_num_aleat,dx

	mov	[BP+4],dx

	pop	dx
	pop	cx
	pop	ax
	pop	bp
	ret
RandomNumber endp

PrintNumber proc near
	push	bp
	mov		bp,sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	mov		ax,[bp+4] ;param3
	lea		di,[str_num+5]
	mov		cx,5
	prox_dig:
		xor		dx,dx
		mov		bx,10
		div		bx
		add		dl,'0' ; dh e' sempre 0
		dec		di
		mov		[di],dl
		loop	prox_dig

		mov		ah,02h
		mov		bh,00h
		mov		dl,[bp+7] ;param1
		mov		dh,[bp+6] ;param2
		int		10h
		mov		dx,di
		mov		ah,09h
		int		21h
		pop		di
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		pop		bp
		ret		4 ;limpa parametros (4 bytes) colocados na pilha
PrintNumber endp

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


AdicionaNovaPalavraRepo PROC
	call CleanScreen
	goto_xy   0,3
	lea  dx,  MenuIntroduzaNovaPalavra
	mov  ah,  9
	int  21h
	RET
AdicionaNovaPalavraRepo ENDP


ListaTodasPalavrasExistentes PROC
	call CleanScreen
	goto_xy   0,3
	lea  dx,  MenuListaPalavras
	mov  ah,  9
	int  21h

	MOV POSx, 20
	MOV POSy, 10
	goto_xy POSx,POSy
	mov     ah,3dh
	mov     al,0
	lea     dx,File_WordsList
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
			cmp dl, 00AH
			JE prox_linha
			JMP	ler_ciclo
	prox_linha:
		ADD POSy, 1
		goto_xy POSx,POSy
		jmp ler_ciclo
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
		call GameMenu
		goto_xy   0,3
		ret
ListaTodasPalavrasExistentes ENDP


HandleMenuGerePalavras PROC
	loopmenu:
		call ReadKeyboardInput; reads the user keyboard inputs
		mov ah, 1h
		int 21h

		cmp 	al, 49 ; 1
		je		OPCNOVAPALAVRA
		cmp		al, 50 ; 2
		je		OPCLISTAPALAVRAS
		cmp		al, 51 ; 3
		je		SAIR
		cmp		al, 27 ; ESC
		je		SAIR
		jmp loopmenu
		SAIR:
			RET
		OPCNOVAPALAVRA:
			call AdicionaNovaPalavraRepo
			jmp SAIR
		OPCLISTAPALAVRAS:
			call ListaTodasPalavrasExistentes
			jmp SAIR
HandleMenuGerePalavras ENDP

DisplayMenuGerePalavras PROC
	call CleanScreen
	goto_xy   0,3
	lea  dx,  MenuGerePalavras
	mov  ah,  9
	int  21h
	call HandleMenuGerePalavras
	call GameMenu
	ret
DisplayMenuGerePalavras ENDP

DisplayWordsErrors proc
	MOV POSx, 52
	MOV POSy, 8
	goto_xy POSx,POSy
	PUSH AX
	PUSH CX

		mov	dl,POSY
		mov	dh,POSx
		MOV AH,0
		MOV AL, totalWordsError

		push	dx
		push	ax
		XOR AX,AX
		CALL PrintNumber
	POP CX
	POP AX

	RET
DisplayWordsErrors endp


DisplayFoundWords proc
	MOV POSx, 52
	MOV POSy, 5
	goto_xy POSx,POSy
	PUSH AX
	PUSH CX

		mov	dl,POSY
		mov	dh,POSx
		MOV AH,0
		MOV AL, totalWordsFound

		push	dx
		push	ax
		XOR AX,AX
		CALL PrintNumber
	POP CX
	POP AX

	RET
DisplayFoundWords endp



DisplayAbout	proc
	goto_xy   0,3
	lea  dx,  MenuAbout
	mov  ah,  9
	int  21h
	call GameMenu
	ret

DisplayAbout	endp

DisplayWordsList proc
	MOV POSx, 32
	MOV POSy, 3
	MOV x, 0
	goto_xy POSx,POSy
	mov     ah,3dh
	mov     al,0
	lea     dx,File_WordsList
	int     21h
	jc      erro_abrir
	mov     HandleFich,ax
	jmp     ler_ciclo
	erro_abrir:
			mov     ah,09h
			lea     dx,Erro_Open
			int     21h
			jmp     sai
	prox_character:
		cmp dl, 00AH
		JE prox_linha
		JMP	ler_ciclo
	guarda_caracter:
		PUSH AX
		PUSH BX
			XOR BX,BX
			MOV BX, x
			MOV [gamewordslist + BX], DX
		POP BX
		POP AX
		INC x; increments x +1
		jmp prox_character
	logica_escrita:
		cmp dl, 65
		JAE guarda_caracter

		JMP prox_character
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

			CMP DL,90
			JBE guarda_caracter
			JMP prox_character
	prox_linha:
		ADD POSy, 1
		goto_xy POSx,POSy
		jmp ler_ciclo
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
DisplayWordsList endp



DisplayWordsFromVariable proc
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	mov x, 0 ; incremento total palavras
	mov y, 0 ; incremento total letras renderizadas de uma palavra
	mov POSx, 32 ; pos no ecra x
	MOV POSy, 10 ; pos no ecra y
	MOV CX, 0
	displayString:
		CMP x, 5 ; If we printed all the words
		JAE returnEnd

		goto_xy POSx,POSy
		MOV BX, CX ; posicao atual na string
		MOV DX, [gamewordslist + BX]
		int 21h

		INC CX
		INC POSx; INDEX memoria na variavel
		INC y; total letras renderizadas


		cmp dl, 00AH
		JE nextstring

		JMP displaystring
		;CMP y, 15; na palavra ( lista de strings )
		;JB displayString


	returnEnd:
		POP DX
		POP CX
		POP BX
		POP AX
		RET
	nextString:
		INC x
		INC POSy
		MOV y, 0
		MOV POSx, 32
		JMP displayString

DisplayWordsFromVariable endp


DisplayTop10 proc
	call CleanScreen
	goto_xy   0,3
	lea  dx,  MenuTop10
	mov  ah,  9
	int  21h

	MOV POSx, 20
	MOV POSy, 10
	goto_xy POSx,POSy
	mov     ah,3dh
	mov     al,0
	lea     dx,File_Top10
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
			cmp dl, 00AH
			JE prox_linha
			JMP	ler_ciclo
	prox_linha:
		ADD POSy, 1
		goto_xy POSx,POSy
		jmp ler_ciclo
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
		call GameMenu
		goto_xy   0,3
		ret
DisplayTop10 endp

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
	lea     dx,File_Board
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


GenerateNewGameBoard proc
	MOV x, 2
	MOV y, 1

	BEGIN:
		MOV AX, x
		MOV BX, y
		goto_xy AL, BL; col, line
		; generate random number between 65-90
		JMP GENERATERNUMBER

		RET
	DISPLAYLETTER:
		

		INC x
		INC x ; incrmenet 2 times the col because of the space between

		PUSH AX

		MOV AH,08h
		int 10h                 ; read a character
		MOV DL,AL

		POP AX

		CMP DL,'*'
		JNE PRINTLETTER
		CMP DL,'*'
		JMP NEXTLINE
	PRINTLETTER:
		PUSH AX

		MOV AH,08h
		int 10h                 ; read a character
		MOV DL,AL

		POP AX

		CMP DL,'+'
		JNE BEGIN

		PUSH BX
		PUSH AX
		PUSH DX

		MOV BX, 0 ; custom variable to hold the number
		MOV BL, AL
		MOV DL, BL

		MOV AH, 2 ; set output function
		INT 21H ; print ASCII character

		POP DX
		POP AX
		POP BX

		JMP BEGIN
	GENERATERNUMBER:
		call RandomNumber
		POP AX

		mov DX, 0
		mov CX,100
		DIV CX

		CMP AL,65
		JB GENERATERNUMBER
		CMP AL,90
		JA GENERATERNUMBER
		JMP DISPLAYLETTER
	NEXTLINE:
		MOV x,2
		INC y
		CMP y,12
		JNE BEGIN
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
		call DisplayFile
		call DisplayWordsErrors
		call DisplayFoundWords
		call DisplayWordsList
		;call DisplayWordsFromVariable
		call GenerateNewGameBoard
		call HandleWordSelection
		
		


HandleGame	endp

GameMenu proc
	loopMenu:
		call ReadKeyboardInput; reads the user keyboard inputs
		call CleanScreen; clean the game screen
		call DisplayMenu; imprime o menu no ecra
		call GameTime
		;call DisplayCountdown

		mov ah, 1h
		int 21h

		; based on the user key input call the respective procedure

		cmp 	al, 49 ; 1
		je		OPCSTARTGAME
		cmp		al, 50 ; 2
		je		OPCTOP10
		cmp		al, 51 ; 3
		je		OPCABOUT
		cmp		al, 52 ; 4
		je		OPCGEREREPOPALAVRAS
		cmp		al, 53 ; 5
		je		OPCLEAVE
		cmp		al, 27 ; ESC
		je		OPCLEAVE
		jmp     loopMenu ; try again

		OPCTOP10:
			call DisplayTop10

		OPCSTARTGAME:
			call HandleGame

		OPCGEREREPOPALAVRAS:
			call DisplayMenuGerePalavras

		OPCABOUT:
			call DisplayAbout

		OPCLEAVE:
			mov	ah,4CH
			INT	21H
GameMenu endp

Time proc   ;proc for time reading from the system
	; CH - hours  | CL - minutes | DH - seconds
	PUSH AX ;returns the first 16bits
	PUSH BX ;BX process depends  on the less significant bit of the address branch
	PUSH CX ;used as a counter
	PUSH DX ;is used  with AX register for multiply and divide operations

	PUSHF	;flag

	mov AH, 2CH			;hours
	int 21h

	xor AX, AX			;set AX register to zero
	mov AL, DH			;mov seconds to AL
	mov seconds, AX 	;store seconds

	xor AX, AX
	mov AL, CL			;mov minutes to AL
	mov minutes, AX		;store minutes

	xor AX, AX
	mov AL, CH			;mov hours to AL
	mov hours, AX		;stores hours

	POPF 				;pops a double word
	POP DX				;load DX
	POP CX				;load CX
	POP BX				;load BX
	POP AX				;load AX
	ret

Time endp

GameTime proc
PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		

		CALL 	Time			; Horas MINUTOS e segundos do Sistema
		
		MOV		AX, seconds
		cmp		AX, actualSeconds		; VErifica se os segundos mudaram desde a ultima leitura
		je		fim_horas			; Se a hora não mudou desde a última leitura sai.
		mov		actualSeconds, AX			; Se segundos são diferentes actualiza informação do tempo 
		
		;inc timeGame
		;mov AX, timeGame
		;mov CX, timeGame
		
		mov 	ax,hours
		MOV		bl, 10     
		div 	bl					;The quotient is stored in the AL, AX,
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'h'		
		MOV 	STR12[3],'$'
		GOTO_XY 52,2
		MOSTRA STR12 		
        
		;minutes

		mov 	ax,minutes
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'m'		
		MOV 	STR12[3],'$'
		GOTO_XY 56,2
		MOSTRA	STR12 		
		
		mov 	ax,seconds
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'s'		
		MOV 	STR12[3],'$'
		GOTO_XY 60, 2
		MOSTRA STR12 		
		
		mov ax,time
		dec AX
		mov bl, 10
		div bl
		add al, 30h
		add ah, 30h
	 	
		MOV stringLimit[0], '0'
		MOV stringLimit[1], al
		MOV stringLimit[2], ah

		;GOTO_XY 65,4
		;MOSTRA stringLimit

fim_horas:		
		goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
		
		POPF
		POP DX		
		POP CX
		POP BX
		POP AX
		RET		

	;PROC don't show the date	
GameTime endp


Ler_tempo_fim PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov secondsEnd, AX		; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov minutesEnd, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov hoursEnd,AX			; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_tempo_fim   ENDP 



DisplayCountdown proc
contagem:
	MOV POSx, 52
	MOV POSy, 3
	
	
	mov ah,09h
	inc DX
	lea DX, stringlimit	
	
    sub stringLimit[3], 1
	cmp stringLimit[3] , 47
	jb volta_ao_9
	int 21h
	
	volta_ao_9:
	mov stringLimit[3],0
	mov stringLimit[3],57
	je contagem
DisplayCountdown endp

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
