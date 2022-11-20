%ifndef P_GENERALS
%define P_GENERALS

%include "./in_out.asm"
%define P_FUNC_PARAM_INDEX rbp+16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; debugging:
println: ;(64bit num)
    enter   0,  0
    push    rax

    mov     rax,    [P_FUNC_PARAM_INDEX]
    call    writeNum
    call    newLine

    pop     rax     
    leave
    ret     8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; other printings:
blankSpace:
    mov     rax,    ' '
    call    putc
    ret     

%endif