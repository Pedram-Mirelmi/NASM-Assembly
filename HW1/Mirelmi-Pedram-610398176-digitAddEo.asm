%include "in_out.asm"

section .text
    global  _start


blankSpace:     ;(void) -> void
    push    rax
    mov     rax,    ' '
    call    putc
    pop     rax
    ret


isDivisible:    ;(int64 num,    int64 divisor) -> boolean
    ;   stack:  [int64 num, int64 divisor,  retAddr]
    mov         rax,    [rsp + 2*8]
    xor         rdx,    rdx
    div qword   [rsp + 8]
    cmp         rdx,    0
    jne         isDivisible_setFlagToFalse
    isDivisible_setFlagToTrue:

        mov qword   [rsp + 2*8],  qword 1

        ret
    isDivisible_setFlagToFalse:
        mov qword   [rsp + 2*8],  qword 0
        ret

addDigitsEo:
    ;stack: [int64 num,     retAddr]
    push qword  [rsp] ; shift the retAddr 8 bit to save space to return 2 values later
    mov         r8,     10; store divisor in a register

    ;int sum = 0;
    push    qword   0;  odd_sum,    stack:[int64 num,   retAddr,  retAddr,    int64 odd_sum=0]
    push    qword   0;  even_sum,   stack:[int64 num,   retAddr,  retAddr,    int64 odd_sum=0, int64 even_sum=0, ]
    

    addDigitsEo_mainWhile:  ; while(num != 0)
        mov         rax,    [rsp + 4*8]; num
        cmp         rax,    0
        je          addDigitsEo_endMainWhile

        xor         rdx,    rdx
        div         r8
        mov         [rsp + 4*8],    rax; overwrite num with quotient
        push        rdx; remaining 

        ; stack:[int64 num,   retAddr,  retAddr,    int64 odd_sum=0, int64 even_sum=0, int64 remaining]
        ; if (isDivisible(remaining, 2))
        push qword  rdx
        push qword  2
        call        isDivisible
        pop         r9; pop function arg
        pop         r9; pop function return value
        pop         rdx ; remaining
        cmp         r9,     1; true?
        je          addDigitsEo_mainWhile_ifDigitIsEven


        addDigitsEo_mainWhile_ifDigitIsOdd:
            ; odd_sum += remaining
            add     [rsp + 8],      rdx
            jmp     addDigitsEo_mainWhile

        addDigitsEo_mainWhile_ifDigitIsEven:
            ; even_sum += remaining
            add     [rsp],          rdx
            jmp     addDigitsEo_mainWhile

    addDigitsEo_endMainWhile: 
        ; stack:[int64 num,   retAddr,  retAddr,   int64 odd_sum=0, int64 even_sum=0]
        mov     rax,            [rsp + 8]
        mov     [rsp + 4*8],    rax
        ; stack [int64 odd_sum,   retAddr,  retAddr,   int64 odd_sum=0, int64 even_sum=0]

        mov     rax,            [rsp]
        mov     [rsp + 3*8],    rax
        ; stack [int64 odd_sum,   int64 even_sum,  retAddr,   int64 odd_sum=0, int64 even_sum=0]


        pop     rax;    pop even_sum
        pop     rax;    pop odd_sum;
        ; stack [int64 odd_sum,   even_sum,  retAddr]
        ret


_start:
    xor     rax,    rax
    call    readNum
    push    rax
    call    addDigitsEo
    pop     rdx;    even_sum
    pop     rbx;    odd_sum

    mov     rax,    rbx
    call    writeNum
    call    blankSpace
    mov     rax,    rdx
    call    writeNum

exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80


