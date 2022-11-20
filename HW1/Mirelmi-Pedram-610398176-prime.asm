%include "in_out.asm"

section .data
    no_msg          db      "No"
    no_msg_len      equ     $ - no_msg
    yes_msg         db      "Yes"
    yes_msg_len     equ     $ - yes_msg    

section .text
    global _start

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



;   we used isComplete function for this problem
isPrime: ; (int64 num) -> boolean (in num's place)
    ; stack:    [int64 num,    retAddr]

    ;int i = 2;     
    push qword      2;     ;stack: [int64 num, retAddr,   int64 i=2]

    isPrime_mainWhile:
    
        ; while(i < num)
        mov     rax,    [rsp]
        cmp     rax,    [rsp + 2*8]
        je      isPrime_outMainWhile


        ; if (isDivisable(num, i))
        push    qword[rsp + 2*8] ; num 
        push    qword[rsp + 8]       ; i
        call    isDivisible
        pop     rax;    pop the "i" arg
        pop     rax;    pop function return value
        cmp     rax,    1
        je      isPrime_iIsDivisible
        jmp     isPrime_mainWhile_loop

        isPrime_iIsDivisible:
            ; return false
            pop     rax ;   pop i
            mov     qword[rsp + 8],    0
            ret

        isPrime_mainWhile_loop:
            inc     qword[rsp]
            jmp     isPrime_mainWhile
    isPrime_outMainWhile:
        pop     rax ;pop i
        mov     qword[rsp + 8],      1
        ret


_start:
    xor         rax,    rax
    call        readNum
    cmp         rax,    1
    je          ifNumIsNotPrime
    
    push        rax;    just to save num   
    push        rax;    function arg        
    call        isPrime
    pop         rax;    function return value
    cmp         rax,    1
    je          ifNumIsPrime
    jmp         ifNumIsNotPrime

    ifNumIsPrime:
        mov     rax,    4
        mov     rbx,    1
        mov     rcx,    yes_msg
        mov     rdx,    yes_msg_len
        jmp     endIfNum
    ifNumIsNotPrime:
        mov     rax,    4
        mov     rbx,    1
        mov     rcx,    no_msg
        mov     rdx,    no_msg_len
        jmp     endIfNum
    endIfNum: 
        int     80h


exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80