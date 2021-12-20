BITS 64

section .data
;Definicion de constantes
LF			    equ	10
NULL			equ	0
SPACE			equ	32
TRUE			equ	1
FALSE			equ	0
EXIT_SUCCESS	equ	0
STDOUT			equ	1
SYS_write		equ	1
SYS_exit		equ	60
TOTAL_ROWS		equ	14

;Definicion de variables
newLine			    db	LF, NULL
space		    	db	"   ", NULL
coefficientFormat	db	"%6d", NULL
x 					db 0
i 					db 0
j 					db 0	

;Reserva de memoria
section .bss
pascalValues	resw	TOTAL_ROWS

;Codigo
section .text
;Incluimos el printf
extern printf

global main
main:
    ;EL protocolo
	push rbp
	mov	rbp, rsp

	mov byte[x], 0	;x = 0
	mov byte[i], 0	;i = 1

;Imprimir N lineas
mainLoop:
	mov al, byte[x]
	mov byte[j], al 	;j = x
	call facLoop
	inc byte[x]
	call printNewline
	call printTriangle
	inc byte[i]
	cmp byte[i], TOTAL_ROWS
	jle mainLoop
	jmp done
	
facLoop:
	;j == x
	mov al, byte[x]
	cmp byte[j], al
	je coefficientOne
	;j == 0
	cmp byte[j], 0
	je coefficientOne

	call coefficient
	continueFacLoop:
	dec byte[j]
	;j >= 0
	cmp byte[j], 0
	jge facLoop
	ret

coefficient:
	;pascal [j]
	mov rax, [j]
	lea rdi, [rel pascalValues + (rax*2)]
	;pascal [j-1]
	xor rdx, rdx
	mov dx, [rdi - 2]
	add word[rdi], dx
	ret

coefficientOne:
	mov rax, [j]
	mov word[pascalValues + (rax*2)], 1
	jmp continueFacLoop
	
printNewline:
	mov rdi, newLine
	xor rax, rax
	call printf
	ret

printTriangle:
	;El protocolo
	push rbp
	mov rbp, rsp

	mov byte[j], 1 ;j = 1
	spaceLoop:
	mov rdi, space
	xor rax, rax
	call printf
	inc byte[j]
	xor rcx, rcx
	mov rcx, TOTAL_ROWS
	sub cl, byte[i]
	cmp byte[j], cl
	jbe spaceLoop
	mov byte[j], 0	;j = 0
	lea rdx, [rel pascalValues]
	printValues:
	push rdx
	mov ax, word[rdx]
	mov rdi, coefficientFormat
	mov rsi, rax
	xor rax, rax
	call printf
	pop rdx
	inc byte[j]
	add rdx, 2
	mov al, byte[x]
	cmp byte[j], al
	jb printValues
	;Fin protocolo
	mov rsp, rbp
	pop rbp  
	ret

done:
    ;Fin protocolo
	mov	rsp, rbp
	pop	rbp

	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall