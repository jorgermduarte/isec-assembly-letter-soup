.8086
.MODEL SMALL
.STACK 2048

DADOS SEGMENT
	FichD		db	'ABC_D.TXT',0
    FichO         	db      'ABC.TXT',0
	HandleFichD 	dw	0
	HandleFichO 	dw	0	
	car_fich        db      60 dup(?)
	Erro_Open		db	"Ocorreu um erro na Erro_Open!$"
	Erro_Close		db	"Ocorreu um erro na criacao do Erro_Close!$"
	msgErrorWrite	db	"Ocorreu um erro msgErrorWrite!$"
	msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
	Erro_Ler_Msg	db	"Ocorreu um erro na escrita para ficheiro!$"
DADOS ENDS


CODIGO	SEGMENT	para	public	'code'
	ASSUME	CS:CODIGO, DS:DADOS
Main proc
		MOV	AX, DADOS
		MOV	DS, AX
	

;abre ficheiro original
        xor     si,si
       
		mov     ah,3dh
        mov     al,0
        lea     dx,FichO
        int     21h
        jc      erro_abrir
        mov     HandleFichO,ax
        jmp     abre_FichD

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai

;Cria novo ficheiro
abre_FichD:
	mov	ah, 3ch
	mov	cx, 00H
	lea	dx, FichD
	int	21h
	jnc	ler_ciclo

	mov     cx,60
	
ler_ciclo:
        push	cx
		mov     ah,3fh
        mov     bx,HandleFichO
		lea     dx,car_fich
		mov		cx,1
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiroO
        mov     ah,02h
		mov		dl,car_fich
		int	21h
; escreve no outro ficheiro
escreve:
		mov	bx, ax
    	mov	ah, 40h
		lea	dx, car_fich
		int	21h
		jnc	fecha_ficheiroO
		pop	cx
		loop	ler_ciclo


		mov	ah, 09h
		lea	dx, msgErrorCreate
		int	21h
	
		jmp	sai


	
		mov	ah, 09h
		lea	dx, msgErrorWrite
		int	21h
		jmp	fecha_ficheiroO

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiroO:
        mov     ah,3eh
        mov     bx,HandleFichO
        int     21h
        jnc     sai

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h



fecha_ficheiroD:
        mov     ah,3eh
        mov     bx,HandleFichD
        int     21h
        jnc     sai

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai:
	MOV	AH,4CH
	INT	21H
main	endp
	CODIGO	ENDS
END	main


