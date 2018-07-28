.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern printf: proc
extern malloc: proc
extern calloc: proc
extern memset: proc


includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Bomberman",0
;game area 17x13 tiles
map_width EQU 17
map_height EQU 13
map_size EQU map_width * map_height
map DD 0;memoreaza pozitia tile-urilor

explode DD 0

playerX DD 1
playerY DD 2

clickX DD 0
clickY DD 0

percent_box EQU 50

nr_bombs DD 1	
nr_lives DD 3
nr_power DD 3

;tile size 50x50px
tile_size EQU 50

area_width EQU (map_width + 5) * tile_size
area_height EQU map_height * tile_size
area DD 0
counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

format db "%d ",0
text db "Hello World!",0
temp dd 0

test_bombX dd 2
test_bombY dd 2
test_bombTime dd 0

exp_end_up dd 0
exp_end_right dd 0
exp_end_down dd 0
exp_end_left dd 0

letter_width EQU 10
letter_height EQU 20 ;litere

include digits.inc
include letters.inc;letters
include symbols.inc;game tiles
;50x50px (2 rows of 25 make a row of 50)
		;11 icons
		;solid
		;box
		;bomb
		;exp center
		;exp corridor left-right
		;exp clorridor up-down
		;exp end up
		;exp end right
		;exp end down
		;exp end left
		;player
		
		
		;9 colors:
		;0 GREEN (background): #009000
		;1 BLACK: #000000
		;2 WHITE: #FFFFFF
		;3 GRAY: #ACACAC
		;4 BROWN: #804000
		;5 YELLOW: #FFFF00
		;6 ORANGE: #FF8000
		;7 BLUE: #0077C0
		;8 PINK: #EC008C

include map_load.inc
	;0 empty
	;1 solid
	;2 (potential) box
		
.code

make_tile proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	lea esi, symbols
	
	mov ebx, tile_size
	mul ebx
	mul ebx;50*50
	add esi, eax
	mov ecx, tile_size
	
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, tile_size
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, tile_size
bucla_simbol_coloane:
	cmp byte ptr [esi], 0;verde = transparent
	je transparent
	cmp byte ptr [esi], 1
	je black
	cmp byte ptr [esi], 2
	je white
	cmp byte ptr [esi], 3
	je gray
	cmp byte ptr [esi], 4
	je brown
	cmp byte ptr [esi], 5
	je yellow
	cmp byte ptr [esi], 6
	je orange
	cmp byte ptr [esi], 7
	je blue
	cmp byte ptr [esi], 8
	je pink
done:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	jmp over
	transparent:
		mov dword ptr [edi], 0009000h
		jmp done
		black:
		mov dword ptr [edi], 0000000h
		jmp done
	white:
		mov dword ptr [edi], 0FFFFFFh
		jmp done
	gray:
		mov dword ptr [edi], 0ACACACh
		jmp done
	brown:
		mov dword ptr [edi], 0804000h
		jmp done
	yellow:
		mov dword ptr [edi], 0FFFF00h
		jmp done
	orange:
		mov dword ptr [edi], 0FF8000h
		jmp done
	blue:
		mov dword ptr [edi], 00077C0h
		jmp done
	pink:
		mov dword ptr [edi], 0EC008Ch
		jmp done
	
	over:
	popa
	mov esp, ebp
	pop ebp
	ret
make_tile endp

make_tile_macro macro tile, drawArea, x, y 
	push eax
	push edx
	
	mov eax, y
	mov edx, tile_size
	mul edx	
	push eax
	mov eax, x
	mov edx, tile_size
	mul edx
	push eax
	push drawArea
	mov eax, 0
	mov al, tile
	push eax
	call make_tile
	add esp, 16
	pop edx
	pop eax
endm

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat (de ce e prima la 8?!??)
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, 0
	jl make_space
	cmp eax, 9
	jg make_space
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, letter_width
	mul ebx
	mov ebx, letter_height
	mul ebx
	add esi, eax
	mov ecx, letter_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, letter_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, letter_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0000000h
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

redshift proc
	push ebp
	mov ebp, esp
	pusha
	
	mov ebx, tile_size
	mul ebx
	mul ebx;50*50
	add esi, eax
	mov ecx, tile_size
	
bucla_simbol_linii:
	mov edi, area ; pointer la matricea de pixeli
	
	mov eax, [ebp+arg2] ; pointer la coord y
	add eax, tile_size
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg1] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, tile_size
bucla_simbol_coloane:
	cmp word ptr [edi], 0
	jne black_pixel
		add edi, 2
		mov al, [edi]
		mov al, 255
		mov [edi], al
		add edi, 2
	black_pixel:
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	
	popa
	mov esp, ebp
	pop ebp
	ret
redshift endp

redshift_macro macro x, y
	push y
	push x
	call redshift
	add esp, 12
endm

explode_bomb proc
	push ebp
	mov ebp, esp
	pusha
	mov esi, map
	;mov ebx, [ebp+arg1]; x
	
	mov ecx, 3
	;;; up
	mov eax, [ebp+arg2]; y 
	dec eax
	mov ebx, map_width
	mul ebx
	add eax, [ebp+arg1] 
	cmp byte ptr [esi+eax], 0
	jne exp_up
		mov ecx, 4
	exp_up:
	
	;;; down
	mov eax, [ebp+arg2]; y
	inc eax
	mov ebx, map_width
	mul ebx
	add eax, [ebp+arg1]
	cmp byte ptr [esi+eax], 0
	jne exp_down
		cmp ecx, 4
		jne exp_down_up
			mov ecx, 13
			jmp exp_down
		exp_down_up:
		mov ecx, 6
	exp_down:
	
	;;; right
	mov eax, [ebp+arg2]; y
	mov ebx, map_width
	mul ebx
	add eax, [ebp+arg1];x
	inc eax
	cmp byte ptr [esi+eax], 0
	jne exp_right
		cmp ecx, 4
		jne exp_up_right
			mov ecx, 8
			jmp exp_right
		exp_up_right:
		cmp ecx, 6
		jne exp_down_right
			mov ecx, 9
			jmp exp_right
		exp_down_right:
		mov ecx, 5
	exp_right:
	
	;;; left
	mov eax, [ebp+arg2]; y
	mov ebx, map_width
	mul ebx
	add eax, [ebp+arg1];x
	dec eax
	cmp byte ptr [esi+eax], 0
	jne exp_left
		cmp ecx, 4
		jne exp_up_left
			mov ecx, 11
			jmp exp_left
		exp_up_left:
		cmp ecx, 6
		jne exp_down_left
			mov ecx, 10
			jmp exp_left
		exp_down_left:
		cmp ecx, 5
		jne exp_right_left
			mov ecx, 12
			jmp exp_left
		exp_right_left:
		mov ecx, 7
	exp_left:
	
	make_tile_macro cl, area, [ebp+arg1], [ebp+arg2]
	
	;;; up loop
	mov eax, [ebp+arg2]; y
	dec eax
	mov ebx, map_width
	mul ebx
	add eax, [ebp+arg1]; x
	cmp byte ptr [esi+eax], 0
	je no_up
	
		mov edx, eax ;;; edx = current, eax = next
		sub eax, map_width

		mov ebx, [ebp+arg2]
		dec ebx
		mov ecx, nr_power
		up_loop:
			
			cmp byte ptr [esi+eax], 0;am zid in fata?
			je up_end
			sub eax, map_width
			
			cmp byte ptr [esi+edx], 1
			je up_end
			sub edx, map_width
			
			make_tile_macro 12, area, [ebp+arg1], ebx
			
			dec ebx
			dec ecx
		cmp ecx, 1
		jne up_loop
			up_end:
			make_tile_macro 14, area, [ebp+arg1], ebx
			mov exp_end_up, edx
	no_up:
	
	;;; down loop
	mov eax, [ebp+arg2]; y
	inc eax
	mov ebx, map_width
	mul ebx
	add eax, [ebp+arg1]; x
	cmp byte ptr [esi+eax], 0
	je no_down
		mov edx, eax ;;; edx = current, eax = next
		add eax, map_width

		mov ebx, [ebp+arg2]
		inc ebx
		mov ecx, nr_power
		down_loop:
			cmp byte ptr [esi+eax], 0;am zid in fata?
			je down_end
			add eax, map_width
			
			cmp byte ptr [esi+edx], 1
			je down_end
			add edx, map_width
			
			make_tile_macro 12, area, [ebp+arg1], ebx
			
			inc ebx
			dec ecx
		cmp ecx, 1
		jne down_loop
			down_end:
			make_tile_macro 16, area, [ebp+arg1], ebx
			mov exp_end_down, edx
	no_down:
	
	;;; right loop
	mov eax, [ebp+arg2]; y
	mov ebx, map_width
	mul ebx
	add eax, [ebp+arg1]; x
	inc eax
	cmp byte ptr [esi+eax], 0
	je no_right
		mov edx, eax ;;; edx = current, eax = next
		inc eax

		mov ebx, [ebp+arg1]
		inc ebx
		mov ecx, nr_power
		right_loop:
			cmp byte ptr [esi+eax], 0;am zid in fata?
			je right_end
			inc eax
			
			cmp byte ptr [esi+edx], 1
			je right_end
			inc edx
			
			make_tile_macro 13, area, ebx, [ebp+arg2]
			
			inc ebx
			dec ecx
		cmp ecx, 1
		jne right_loop
			right_end:
			make_tile_macro 15, area, ebx, [ebp+arg2]
			mov exp_end_right, edx
	no_right:
	
	;;; left loop
	mov eax, [ebp+arg2]; y
	mov ebx, map_width
	mul ebx
	add eax, [ebp+arg1]; x
	dec eax
	cmp byte ptr [esi+eax], 0
	je no_left
		mov edx, eax ;;; edx = current, eax = next
		dec eax

		mov ebx, [ebp+arg1]
		dec ebx
		mov ecx, nr_power
		left_loop:
			cmp byte ptr [esi+eax], 0;am zid in fata?
			je left_end
			dec eax
			
			cmp byte ptr [esi+edx], 1
			je left_end
			dec edx
			
			make_tile_macro 13, area, ebx, [ebp+arg2]
			
			dec ebx
			dec ecx
		cmp ecx, 1
		jne left_loop
			left_end:
			make_tile_macro 17, area, ebx, [ebp+arg2]
			mov exp_end_left, edx
	no_left:
	
	popa
	mov esp, ebp
	pop ebp
	ret
explode_bomb endp

explode_macro macro x, y
	push y
	push x
	call explode_bomb
	add esp, 12
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz click
	cmp eax, 2
	jz time
	
	mov eax, [ebp+arg1]
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0;facem pixeli negri
	push area
	call memset	
	add esp, 12
	
	make_text_macro 'B', area, 920, 50
	make_text_macro 'O', area, 930, 50
	make_text_macro 'M', area, 940, 50
	make_text_macro 'B', area, 950, 50
	make_text_macro 'E', area, 960, 50
	make_text_macro 'R', area, 970, 50
	make_text_macro 'M', area, 980, 50
	make_text_macro 'A', area, 990, 50
	make_text_macro 'N', area, 1000, 50
	
	make_tile_macro 23, area, 19, 4;;;up
	make_tile_macro 24, area, 20, 5;;;right
	make_tile_macro 25, area, 19, 6;;;down
	make_tile_macro 26, area, 18, 5;;;left
	make_tile_macro 27, area, 19, 5;;;bomb
	
	make_text_macro 'B', area, 900, 400
	make_text_macro 'O', area, 910, 400
	make_text_macro 'M', area, 920, 400
	make_text_macro 'B', area, 930, 400
	make_text_macro 'S', area, 940, 400
	make_text_macro 'X', area, 960, 400
	
	make_text_macro 'L', area, 900, 430
	make_text_macro 'I', area, 910, 430
	make_text_macro 'V', area, 920, 430
	make_text_macro 'E', area, 930, 430
	make_text_macro 'S', area, 940, 430
	make_text_macro 'X', area, 960, 430
	
	make_text_macro 'P', area, 900, 460
	make_text_macro 'O', area, 910, 460
	make_text_macro 'W', area, 920, 460
	make_text_macro 'E', area, 930, 460
	make_text_macro 'R', area, 940, 460
	make_text_macro 'X', area, 960, 460
	click:
	
	mov esi, map
	xor edx, edx
	mov ebx, tile_size
	
	mov eax, [ebp+arg2];x
	div ebx
	mov clickX, eax
	
	xor edx, edx
	mov eax, [ebp+arg3];y
	div ebx
	mov clickY, eax
	
	cmp clickX, 19
	jne up_arrow
	cmp clickY, 4
	jne up_arrow
	mov eax, playerY
	dec eax
	mov ebx, map_width
	mul ebx
	add eax, playerX
	cmp byte ptr [esi+eax], 15
	jl up_arrow
		dec playerY
	up_arrow:
	
	cmp clickX, 20
	jne right_arrow
	cmp clickY, 5
	jne right_arrow
	mov eax, playerY
	mov ebx, map_width
	mul ebx
	add eax, playerX
	inc eax
	cmp byte ptr [esi+eax], 15
	jl right_arrow
		inc playerX
	right_arrow:
	
	cmp clickX, 19
	jne down_arrow
	cmp clickY, 6
	jne down_arrow
	mov eax, playerY
	inc eax
	mov ebx, map_width
	mul ebx
	add eax, playerX
	cmp byte ptr [esi+eax], 15
	jl down_arrow
		inc playerY
	down_arrow:
	
	cmp clickX, 18
	jne left_arrow
	cmp clickY, 5
	jne left_arrow
	mov eax, playerY
	mov ebx, map_width
	mul ebx
	add eax, playerX
	dec eax
	cmp byte ptr [esi+eax], 15
	jl left_arrow
		dec playerX
	left_arrow:
	
	cmp clickX, 19
	jne plant_bomb
	cmp clickY, 5
	jne plant_bomb
	cmp nr_bombs, 0
	je plant_bomb
	mov eax, playerY
	mov ebx, map_width
	mul ebx
	add eax, playerX
	mov byte ptr [esi+eax], 2
	mov eax, counter
	mov test_bombTime, eax
	mov eax, playerX
	mov test_bombX, eax
	mov eax, playerY
	mov test_bombY, eax
	dec nr_bombs
	plant_bomb:
	
	;;;;;;;;;;;;;;power-ups;;;;;;;;;;;;;;;;
	mov eax, playerY
	mov ebx, map_width
	mul ebx
	add eax, playerX
	cmp byte ptr [esi+eax], 15
	jne pickup_power
		inc nr_power
		mov byte ptr [esi+eax], 18
	pickup_power:
	cmp byte ptr [esi+eax], 16
	jne pickup_bomb
		inc nr_bombs
		mov byte ptr [esi+eax], 18
	pickup_bomb:
	cmp byte ptr [esi+eax], 17
	jne pickup_life
		inc nr_lives
		mov byte ptr [esi+eax], 18
	pickup_life:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	time:
	make_text_macro nr_bombs, area, 970, 400
	make_text_macro nr_lives, area, 970, 430
	make_text_macro nr_power, area, 970, 460
	inc counter

	mov esi, map
	mov ecx, 0
	draw_tile_line:
		mov ebx, 0
		draw_tile_column:
		make_tile_macro [esi], area, ebx, ecx
		inc esi
		inc ebx
		cmp ebx, map_width
		jnz draw_tile_column
	inc ecx
	cmp ecx, map_height
	jne draw_tile_line
	 	;;;;;;;;;;;;;;;;player;;;;;;;;;;;;;;;;;
	make_tile_macro 18, area, playerX, playerY
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov eax, counter
	sub eax, test_bombTime
	cmp eax, 15
	jg redshift_bomb
		;redshift_macro test_bombX, test_bombY <--- work in progress
		jmp kaboom
	redshift_bomb:
	cmp eax, 20
	jge kaboom_end
	cmp test_bombTime, 0
	je kaboom
		explode_macro test_bombX, test_bombY
		jmp kaboom
	kaboom_end:
		cmp exp_end_up, 0; sa nu fie initializate
		je kaboom
		mov test_bombTime, 0
		mov nr_bombs, 1
		mov eax, test_bombY
		mov ebx, map_width
		mul ebx
		add eax, test_bombX
		mov esi, map
		mov byte ptr [esi+eax], 22
		mov eax, exp_end_up
		mov byte ptr [esi+eax], 22
		mov eax, exp_end_right
		mov byte ptr [esi+eax], 22
		mov eax, exp_end_down
		mov byte ptr [esi+eax], 22
		mov eax, exp_end_left
		mov byte ptr [esi+eax], 22
	kaboom:
	
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp


init_map proc 
push esi
push edi

mov edi, map	  ;matrice harta
lea esi, map_load ;fisier harta

mov eax, map_height
mov ebx, map_width
mul ebx
mov ecx, eax
mov ebx, 0  

write:
	mov al, [esi + ebx]
	cmp al, 1
	jne box_over 
		push ebx
		rdtsc
		mov edx, 0;;;;;I should not need this
		mov ebx, 100
		div ebx
		cmp dl, percent_box
		jle not_box
			mov al, 22
			jmp box_jump
		not_box:
		mov al, 1
		box_jump:
		pop ebx
	box_over:
	mov byte ptr [edi + ebx], al
	inc ebx	
loop write

pop edi
pop esi
ret
init_map endp

start:
	
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	mov area, eax     ;initializare matrice pixeli
	add esp, 4
	
	
	mov eax, map_width
	mov ebx, map_height
	mul ebx
	push eax
	call malloc
	mov map, eax  ;initializare matrice tile-uri
	add esp, 4
	
	call init_map
	
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	push 0
	call exit
end start
