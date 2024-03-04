section .data
    a dw 0
    b dw 0   
    aa db 0
    bb db 0   
    res dd 0
    
    tt dd 0
    rr dd 0   
  ; nol dd 0  
    fres dd 0
    i db 0  
    
    msg db '1 = int (-32768 to 32767), 2 = uint (0 to 65535), a, b: '
    lenmsg equ $-msg
    dbz db 'delenie na nol', 0xa
    lendbz equ $-dbz
    errmsg db 'ERROR', 0xa
    lenerrmsg equ $-errmsg
    resl db 'result: '
    lenresl equ $-resl
    temp db 8 dup(0)
    
section .text
    global _start
    global input_int
    global input_uint
    global int16_asm
    global uint16_asm
    global exit
    global err_exit

_start:
    mov rbp, rsp
    call clear
    
    mov edx, lenmsg 
    mov ecx, msg 
    mov ebx, 1 
    mov eax, 4 
    int 0x80 

    mov eax, 3 
    mov ebx, 0 
    mov ecx, temp
    mov edx, 128
    int 0x80

    @chto:
    cmp byte[ecx], '1'
    je input_int
    cmp byte[ecx], '2'
    je input_uint
    call err_exit

clear:
    xor eax, eax
    xor ecx, ecx
    xor ebx, ebx
    xor edx, edx
    ret

input_uint:
    inc ecx
    cmp byte[ecx], 0x20
    jne input_uint
    inc ecx
    jmp @string_to_uintA
    
    @string_to_uintA:

    mov ax, 10
    mov bx, word[a]
    mul bx
    cwd
    mov word[a], ax
    movzx eax, byte[ecx]
    sub eax, '0'

    cmp eax, 0
    jb err_exit
    cmp eax, 9
    ja err_exit
    
    add word[a], ax

    inc ecx
    cmp byte[ecx], 0x20
    
    jne @string_to_uintA
    inc ecx
    
    je @string_to_uintB
    
    @string_to_uintB:

    mov ax, 10
    mov bx, word[b]
    mul bx
    cwd
    mov word[b], ax
    movzx eax, byte[ecx]
    sub eax, '0'

    cmp eax, 0
    jb err_exit
    cmp eax, 9
    ja err_exit
    
    add word[b], ax

    inc ecx
    cmp byte[ecx], 0x20
    je err_exit
    cmp byte[ecx], 0xa
    jne @string_to_uintB
    call prover_uinta
    call delenie_na_nol
    call uint16_asm
    
    call printres

input_int:
    inc ecx
    cmp byte[ecx], 0x20
    jne input_int
    inc ecx
    cmp byte[ecx], 0x2D
    je @minus_A
    jmp @string_to_intA
    
    @minus_A:
    mov ax, 1
    mov [aa], ax
    inc ecx
    cmp byte[ecx], 0x2D
    je @minus_A
    jmp @string_to_intA
    
    @string_to_intA:

    mov ax, 10
    mov bx, word[a]
    mul bx
    cwd
    mov word[a], ax
    movzx eax, byte[ecx]
    sub eax, '0'

    cmp eax, 0
    jb err_exit
    cmp eax, 9
    ja err_exit
    
    add word[a], ax
	call prover_inta
    inc ecx
    cmp byte[ecx], 0x20
    jne @string_to_intA
    inc ecx
    mov ax, [aa]
    cmp ax, 1
    je @minus_A_true
    cmp byte[ecx], 0x2D
    je @minus_B
    jmp @string_to_intB
    
    @minus_A_true:
    mov ax, word[a]
    neg ax
    mov word[a], ax
    call prover_intmina
    cmp byte[ecx], 0x2D
    je @minus_B
    jmp @string_to_intB
    
    @minus_B:
    mov ax, 1
    mov [bb], ax
    inc ecx
    cmp byte[ecx], 0x2D
    je @minus_B
    jmp @string_to_intB
    
    @string_to_intB:

    mov ax, 10
    mov bx, word[b]
    mul bx
    cwd
    mov word[b], ax
    movzx eax, byte[ecx]
    sub eax, '0'

    cmp eax, 0
    jb err_exit
    cmp eax, 9
    ja err_exit
    
    add word[b], ax
	;call prover_intb			
    inc ecx
    cmp byte[ecx], 0x20
    je err_exit
    cmp byte[ecx], 0xa
    jne @string_to_intB
    mov ax, [bb]
    cmp ax, 1
    je @minus_B_true
    
    call delenie_na_nol
    call int16_asm  
    call printres 
    @minus_B_true:
    
    mov ax, word[b]
    neg ax
    mov word[b], ax
    
    call prover_intminb   
    call delenie_na_nol
    call int16_asm
    call printres

prover_intminb:
	xor eax, eax
	xor ebx, ebx
	mov eax, [b]
	mov ebx, -32768	
	cmp eax, ebx
	jl @perebormin
	
prover_uinta:
	xor eax, eax
	xor ebx, ebx
	mov eax, [a]
	mov ebx, 65535
	cmp eax, ebx
	jg @pereboru
		
    ret
	@pereboru:
	call err_exit

prover_inta:
	xor eax, eax
	xor ebx, ebx
	mov eax, [a]
	mov ebx, 32767	
	cmp eax, ebx
	jg @perebor
	
    ret
	@perebor:
	call err_exit
	
prover_intmina:
	xor eax, eax
	xor ebx, ebx
	mov eax, [a]
	mov ebx, -32768	
	cmp eax, ebx
	jl @perebormin
	ret
	@perebormin:
	call err_exit
		
	
delenie_na_nol:
    
    xor ax, ax
    movsx ax, [b]
    add ax, 8
    cmp ax, 0
    je @realnol
    
    ret
    
    @realnol:
    mov edx, lendbz 
    mov ecx, dbz 
    mov ebx, 1 
    mov eax, 4 
    int 0x80  
    call exit

err_exit:
    mov edx, lenerrmsg 
    mov ecx, errmsg 
    mov ebx, 1 
    mov eax, 4 
    int 0x80 
    call exit

exit:
    mov eax, 1 
    int 0x80   

printres:
    call clear
    
    mov edx, lenresl 
    mov ecx, resl 
    mov ebx, 1 
    mov eax, 4 
    int 0x80  
    
    call clear
    mov eax, dword[res]
    mov dword[fres], eax
    cmp eax, 0
    jl @print_minus
    mov ax, [temp]
    mov ax, 0
    mov [temp], ax
    jmp @print_else
    
    @print_minus:
    mov eax, dword[fres]
    neg eax
    mov dword[fres], eax
    
    mov ecx, '-'
    mov [temp], ecx
    mov edx, 1 
    mov ecx, temp
    mov ebx, 1 
    mov eax, 4 
    int 0x80 
    mov ax, [temp]
    mov ax, 0
    mov [temp], ax
    jmp @print_else
    
    @print_else:
    call clear
    mov eax, dword[fres]
    mov ebx, 10
    cdq
    div ebx
    mov dword[fres], eax
    
    movzx ecx, byte[i]
    add edx, '0'
    mov [temp + ecx], edx
    
    movzx edx, byte[i]
    inc edx
    mov [i], edx
    
    mov ecx, dword[fres]
    cmp ecx, 0
    jne @print_else
    jmp @final_print
    
    @final_print:
    call clear
    movzx eax, byte[i]
    dec eax
    mov [i], eax
    mov ebx, temp
    add ebx, eax
    
    mov edx, 1
    mov ecx, ebx 
    mov ebx, 1
    mov eax, 4 
    int 0x80   
    movzx eax, byte[i]
    cmp eax, 0
    jne @final_print
    
    mov eax, 0xa
    mov [temp], eax
    mov edx, 1
    mov ecx, temp
    mov ebx, 1
    mov eax, 4 
    int 0x80 
    
    call exit

int16_asm:
    xor eax, eax
    xor ecx, ecx
    xor ebx, ebx
    xor edx, edx
    
    mov ax, [a]
    mov cx, [b]
    
    cmp ax, cx
	jg @a_b_b
	je @a__b
	jl @a_m_b
	
@a_b_b:
	mov ax, [b]
	cwde
	add eax, 8
	mov ecx, eax
	xor eax, eax
	mov ax, [a]
	cwd
	imul eax, 32
	cdq
	idiv ecx
	mov [res], eax
	jmp @end
    
@a__b: 
	mov ax, 48
	cwde
	mov [res], eax
	jmp @end
	
@a_m_b:
	mov ax, [a]
	cwde
	dec eax
	mov [rr], eax
	xor eax, eax
	
	mov ax, [b]
	cwde
	imul eax, 3
	mov [tt], eax
	xor eax, eax
	
	mov eax, [rr]
	mov ecx, [tt]
	
	cdq
	idiv ecx
	mov [res], eax
	jmp @end

@end:
    ret

uint16_asm:
    xor eax, eax
    xor ecx, ecx
    xor ebx, ebx
    xor edx, edx
    
    mov ax, [a]
    mov cx, [b]
    
    cmp ax, cx
	ja @a_b_bu
	je @a__bu
	jb @a_m_bu
	
@a_b_bu:
	xor eax, eax
    xor ecx, ecx
	mov ax, [b]
	cwd
	add eax, 8
	mov ecx, eax
	xor eax, eax
	mov ax, [a]
	cwd
	mov ebx, 32
	mul ebx
	cdq 
	div ecx
	mov [res], eax
	xor ebx, ebx
	jmp @endu
    
@a__bu: 
	xor eax, eax
    xor ecx, ecx
	mov ax, 48
	cwd
	mov [res], eax
	jmp @endu
	
@a_m_bu:
	xor eax, eax
    xor ecx, ecx
	mov ax, [a]
	cwd
	dec eax
	mov [rr], eax
	xor eax, eax
	
	mov ax, [b]
	cwd
	imul eax, 3
	mov [tt], eax
	xor eax, eax

	mov eax, [rr]
	mov ecx, [tt]
	
	cdq
	idiv ecx	
	mov [res], eax
	jmp @endu

@endu:
    ret
