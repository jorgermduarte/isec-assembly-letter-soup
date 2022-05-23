;--------------------------------------------------------------
; Imprime valor da tecla numa posição do ecran na posição linha,coluna
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'
	string	db	"Teste prático de T.I",0
	POSy	db	5	; a linha pode ir de [1 .. 25]
	POSx	db	10	; POSx pode ir [1..80]	
	p_POSxy dw	40	; ponteiro para posicao de escrita
dseg	ends

cseg	segment para public 'code'
assume	cs:cseg, ds:dseg



;########################################################################
goto_xy		macro	POSx,POSy
		mov	ah,02h
		mov	bh,0
		mov	dl,POSx
		mov	dh,POSy
		int	10h
endm

;########################################################################
;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
		xor	bx,bx
		mov	cx,25*80
		
apaga:		mov	byte ptr es:[bx],' '
		mov	byte ptr es:[bx+1],7
		inc	bx
		inc 	bx
		loop	apaga
		ret
apaga_ecran	endp


;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC

		mov	ah,08h
		int	21h
		mov	ah,0
		cmp	al,0
		jne	SAI_TECLA
		mov	ah, 08h
		int	21h
		mov	ah,1
SAI_TECLA:	RET
LE_TECLA	endp
;########################################################################

	Main  proc
		mov	ax, dseg
		mov	ds,ax
		mov	ax,0B800h
		mov	es,ax

		call	apaga_ecran

		;Obter a posição
		dec	POSy		; linha = linha -1
		dec	POSx		; POSx = POSx -1

	CICLO:	mov	al,POSy
		mov	ah,160
		mul	ah
		mov	bx,ax
		mov	al,POSx
		mov	ah,2
		mul	ah
		add	bx,ax		; bx vai conter o endereço correspondetente (l,c)
		mov	p_POSxy,bx

		
		goto_xy	POSx,POSy
		call 	LE_TECLA
		cmp	ah,1
		je	ESTEND
		CMP 	AL,27		; ESCAPE
		JE	FIM

		mov	bx,p_POSxy
		mov 	es:[bx],al
		mov 	byte ptr es:[bx+1],15

		jmp	CICLO

	ESTEND:	cmp 	al,48h
		jne	BAIXO
		dec	POSy		;cima
		jmp	CICLO

	BAIXO:	cmp	al,50h
		jne	ESQUERDA
		inc POSy		;Baixo
		jmp	CICLO

	ESQUERDA:
		cmp	al,4Bh
		jne	DIREITA
		dec	POSx		;Esquerda
		jmp	CICLO

	DIREITA:
		cmp	al,4Dh
		jne	CICLO 
		inc	POSx		;Direita
		jmp	CICLO

	fim:	
		mov	ah,4CH
		INT	21H
Main	endp
Cseg	ends
end	Main
