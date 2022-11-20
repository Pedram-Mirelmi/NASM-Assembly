%include "in_out.asm"

section .text
    global _start

readFromBinary:;(void) -> int64
    xor     rax,    rax
    push    qword[rsp];      stack :[retAddr,    retAddr]
    mov     qword[rsp + 8],     0;  stack: [int64 num=0; retAddr]

    readFromBinary_mainWhile: 
        call    getc
        cmp     al,     '0'
        jae     readFromBinary_mainWhile_aeCheck
        jmp     readFromBinary_endMainWhile
        readFromBinary_mainWhile_aeCheck:
            cmp     al,     '1'
            jbe     readFromBinary_mainWhile_ifDigitOk
            jmp     readFromBinary_endMainWhile
            readFromBinary_mainWhile_ifDigitOk:
                shl     qword[rsp + 8],     1
                sub     rax,    '0'
                add     qword[rsp + 8],     rax
                jmp     readFromBinary_mainWhile

    readFromBinary_endMainWhile:
        ret

printbinary: ;(int64 num) -> void
    ; stack: [int64 num, retAddr]
    mov     rbx,    [rsp+8]
    xor     r8,     r8
    printbinary_pushDigitsWhile:
        cmp     rbx,    0
        je      printbinary_printStackWhile
        mov     rax,        rbx
        and     rax,    1
        push    rax
        inc     r8
        shr     rbx,   1
        jmp     printbinary_pushDigitsWhile



    printbinary_printStackWhile:
        cmp     r8,     0
        je      printbinary_printStackEndWhile
        pop     rax
        call    writeNum
        dec     r8
        jmp     printbinary_printStackWhile


    printbinary_printStackEndWhile:
        ret

get1Z:  ;(int64 XYZ) -> int64 Z
    ; stack:    [int64 num, retAddr]
    and     qword[rsp+8],    0x00f
    ret

get16Y: ;(int64 XYZ) -> int64 16*
    and     qword[rsp+8],   0x0f0
    ret     


get10Y: ;(int64 XYZ) -> int64 10*Y
    ; stack: [int64 XYZ, retAddr]
    mov     rax,    [rsp+8]
    push    rax    
    call    get16Y
    pop     rax; rax=16Y

    push    0
    ; int the10Y = 0;   stack: [int64 num,  retAddr,  int64 the10Y=0]


    shr     rax,    1       ; rax = 8Y
    add     [rsp],  rax
    shr     rax,    2;        rax = 2Y
    add     [rsp],  rax

    mov     rax,    [rsp]
    mov     [rsp + 2*8],    rax
    
    pop     rax;    pop local variable (the10Y)
    ret

    
get256X:  ;(int64 XYZ) -> 256*X
    and     qword[rsp+8],   0xf00
    ret

get100X: ;(int64 XYZ) -> 100*X
    ; stack:    [int64 XYZ,     retAddr]
    mov     rax,    [rsp+8]
    push    rax
    call    get256X
    pop     rax; rax = 256X

    ; int the100X = 0;
    push    0
    ; stack: [int64 XYZ, retAddr, int64 the100X=0]

    shr     rax,    2; rax = 64X
    add     [rsp],  rax;    the100X = 64*X

    shr     rax,    1; rax = 32X
    add     [rsp],  rax;    the100X = 96*X

    shr     rax,    3; rax = 4X
    add     [rsp],  rax;    the100X = 100*X
    
    mov     rax,    [rsp]
    mov     [rsp+2*8],  rax

    pop     rax;    pop local variable(the100X)
    ret 


main:   ;(void) -> void
    call    readFromBinary
    pop     rax;    function return value
    push    rax;    store oroginal stack:  [BCDInBinary]   : xyz

    ; int binary = 0;
    push    0;      stack:  [int64 BCD,    binary=0]


    mov     rax,    [rsp+8]
    push    rax
    call    get1Z
    pop     rax
    add     [rsp],      rax


    mov     rax,    [rsp+8]
    push    rax
    call    get10Y
    pop     rax
    add     [rsp],      rax


    mov     rax,    [rsp+8]
    push    rax
    call    get100X
    pop     rax
    add     [rsp],      rax


    mov     rax,      [rsp]
    push    rax
    call    printbinary
    ret


_start:
    call    main
   
exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80


    


