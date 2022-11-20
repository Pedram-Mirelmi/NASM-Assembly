%include "./in_out.asm"
%define P_FUNC_PARAM_INDEX rbp+16


section .bss
    buff resb   1000

section .text
    global _start

readString:
    push    rdi
    push    rsi
    push    rdx

    mov     rax,    sys_read
    mov     rdi,    stdin
    mov     rsi,    buff
    mov     rdx,    1000
    syscall
    
    pop     rdx
    pop     rsi
    pop     rdi
    ret

countOne:; (8B num) -> sum (rax)
    enter   24, 0
    %define param_num   qword[P_FUNC_PARAM_INDEX]
    %define local_one   qword[rbp-8]
    %define local_zero  qword[rbp-16]
    %define local_sum   qword[rbp-24]
    push    rcx
    push    r8
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     local_one,  1
    mov     local_zero, 0

    mov     local_sum,  0
    mov     r8,     param_num
    mov     rcx,    64
    countOne_While:
        shr     r8,     1
        cmovc   rax,    local_one
        cmovnc  rax,    local_zero
        add     local_sum,  rax
        loop    countOne_While 

    mov     rax,    local_sum
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     r8
    pop     rcx
    %undef  param_num
    %undef  local_sum
    %undef  local_one
    %undef  local_zero
    leave
    ret     8


countOneM: ;(8B str_ptr, 8B i, 8B j)
    enter   8,  0
    %define param_str   qword[P_FUNC_PARAM_INDEX+16]
    %define param_i     qword[P_FUNC_PARAM_INDEX+8]
    %define param_j     qword[P_FUNC_PARAM_INDEX]
    %define local_sum   qword[rbp-8]
    push    rcx
    push    rsi
    push    rdi
    cld
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rax,    param_i
    mov     rsi,    param_str
    add     rsi,    param_i

    mov     rdi,    param_str
    mov     rdi,    param_j

    mov     rcx,    param_j
    sub     rcx,    param_i
    inc     rcx
    countOneM_mainWhile:
        xor     rax,    rax
        lodsb   
        push    rax
        call    countOne
        add     local_sum,  rax
        loop    countOneM_mainWhile  
    
    mov     rax,    local_sum
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rdi
    pop     rsi
    pop     rcx
    %undef  local_sum
    %undef  param_i
    %undef  param_j
    %undef  param_str
    leave   
    ret     24

_start:
    call    readNum
    mov     rsi,    rax
    call    readNum
    mov     rdi,    rax
    call    readString
    push    buff
    push    rsi
    push    rdi
    call    countOneM
    call    writeNum

    

exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80


    
