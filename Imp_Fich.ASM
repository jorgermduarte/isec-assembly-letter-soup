.8086
.model small
.stack 2048h

dseg    segment para public 'data'
        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'DADOS.TXT',0
        HandleFich      dw      0
        car_fich        db      ?
dseg    ends



cseg    segment para public 'code'
		assume  cs:cseg, ds:dseg

Main    Proc

        mov     ax,dseg
        mov     ds,ax
		
;abre ficheiro
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
        mov     ah,4ch
        int     21h
Main    endp
cseg	ends
end     Main           

