.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem msvcrt.lib, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
num dw 50
rez dw 0
num1 dw 0
num2 dw 0
;rez = AX*num1 + num2*(AX + BX)
.code
start:
	mov EAX, 10
	mov EBX, 30
	add EBX, EAX
	mov EDX, 0
	mov DX, AX
	mov EAX, EDX
	mul num1
	add rez, AX
	mov EAX, EBX
	mul num2
	add rez, AX
end start