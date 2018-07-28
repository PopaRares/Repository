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

;EAX = 7*EAX - 2*EBX - EBX/8
.code
start:
	mov EAX, 10
	mov EBX, 5
	mov CL, 7
	mov EDX, EAX
	mov EAX, EBX
	mov CL, 2
	mul CL
	sub EDX, EAX
	mov EAX, EBX
	mov CL, 8
	div CL
	sub DL, AL
	mov EAX, EDX
	push 0
	call exit
end start
