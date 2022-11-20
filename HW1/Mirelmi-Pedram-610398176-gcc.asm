%include "in_out.asm"

section .text
    global _start

println:
    call    writeNum
    call    newLine
    ret

gcc:    ;(int64, int64) -> rax
    xor     rdx,    rdx
    mov     r8,     [rsp + 8 + 8]
    mov     r9,     [rsp + 8]
    cmp     r8,     r9
    ja      gcc_firstIsGreater
    jb      gcc_secondIsGreater
    ;   equal
    mov     rax,    r8
    ret
    gcc_firstIsGreater:
        mov     r10,    r9
        inc     r10
        jmp     gcc_mainWhile
    gcc_secondIsGreater:
        mov     r10,    r8
        inc     r10
        jmp     gcc_mainWhile
    gcc_mainWhile:
        dec     r10
        mov     rax,    r8
        xor     rdx,    rdx
        div     r10
        cmp     rdx,    0
        je      gcc_mainWhile_firstIsOk
        jmp     gcc_mainWhile
        gcc_mainWhile_firstIsOk:
            mov     rax,    r9
            xor     rdx,    rdx
            div     r10
            cmp     rdx,    0
            jne     gcc_mainWhile
            mov     rax,    r10
            ret


_start:

    call    readNum
    mov     rcx,    rax
    call    readNum
    mov     rbx,    rax
    mov     rax,    rcx
    ; just to store the first number in rax, and second in rbx
    push    rax
    push    rbx
    call    gcc
    call    writeNum

    ; a better alternative:
    
    ; call    readNum
    ; push    rax
    ; call    readNum
    ; push    rax
    ; call    lfc
    ; call    println


exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80