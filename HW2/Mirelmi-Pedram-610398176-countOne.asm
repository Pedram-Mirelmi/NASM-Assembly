%include "./in_out.asm"

%define P_FUNC_PARAM_INDEX rbp+16
section .text
    global _start

countOne:; (8B num) -> sum (rax)
    enter   24, 0
    %define param_num   qword[P_FUNC_PARAM_INDEX]
    %define local_one   qword[rbp-8]
    %define local_zero  qword[rbp-16]
    %define local_sum   qword[rbp-24]
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
    %undef  param_num
    %undef  local_sum
    %undef  local_one
    %undef  local_zero
    leave
    ret     8

_start:
    call    readNum
    push    rax
    call    countOne
    call    writeNum
    

exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80


    
