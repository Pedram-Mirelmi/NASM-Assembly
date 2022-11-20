%include "./in_out.asm"
%define P_FUNC_PARAM_INDEX rbp+16
section .data
    test_dest    db      0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 10
    test_src     db      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10

section .text
    global _start

main:; (8B num) -> reversed(rax)
    enter   16, 0
    %define param_num   qword[P_FUNC_PARAM_INDEX]
    %define local_one   qword[rbp-8]
    %define local_zero  qword[rbp-16]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     local_one,  1
    mov     local_zero, 0
    mov     r8,     param_num
    mov     rcx,    64
    main_While:
        shr     r8,     1
        cmovc   rax,    local_one
        cmovnc  rax,    local_zero
        call    writeNum
        loop    main_While 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    %undef  param_num
    %undef  local_one
    %undef  local_zero
    leave
    ret     8

_start:
    call    readNum
    push    rax
    call    main
    

exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80


    
