%include "in_out.asm"

section .text
    global  _start

println:
    call writeNum
    call newLine
    ret

lfc:   ; lfc(int64, int64) -> rax

    ; store function arguments on stack!
    mov     r8,     [rsp + 8]
    mov     r9,     [rsp + 8 + 8]
    lfc_MainWhileStart: 
    cmp     r8,     r9
    ja      lcf_MainWhile_ifFirstIsGreater     
    jb      lcf_MainWhile_ifSecondIsGreater

    mov     rax,    r8
    ret
        lcf_MainWhile_ifFirstIsGreater:
            add     r9,     [rsp + 8 + 8]
            jmp     lfc_MainWhileStart


        lcf_MainWhile_ifSecondIsGreater:
            add     r8,     [rsp + 8]
            jmp     lfc_MainWhileStart


_start:
    call    readNum
    mov     rcx,    rax
    call    readNum
    mov     rbx,    rax
    mov     rax,    rcx
    ; just to store the first number in rax, and second in rbx
    push    rax
    push    rbx
    call    lfc
    call    writeNum
    ; call    println

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