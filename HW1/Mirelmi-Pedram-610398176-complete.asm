%include "in_out.asm"

section .data
    perfect_msg     db  "Perfect"
    perfect_msg_len equ $ - perfect_msg
    nope_msg        db  "Nope"
    nope_msg_len    equ  $ - nope_msg    

section .text
    global _start


blankSpace:     ;(void) -> void
    push    rax
    mov     rax,    ' '
    call    putc
    pop     rax
    ret

isDivisible:    ;(int64 num,    int64 divisor) -> boolean64(in num's place)
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

isComplete: ; (int64 num, bool64 print_flag) -> boolean (in num's place)
    ; stack:    [int64 num,     bool64 print_flag,     retAddr]

    ;int sum = 0;
    push qword      1;      stack: [int64 num, bool64 print_flag,  retAddr,    int64 sum=1]
    
    ;int i = 1;     
    push qword      2;     ;stack: [int64 num, bool64 print_flag   retAddr,    int64 sum=0,  int64 i=2]

    isComplete_mainWhile:
    
        ; while(i < num)
        mov     rax,    [rsp]
        cmp     rax,    qword[rsp + 4*8]
        jae     isComplete_outMainWhile


        ; if (isDivisable(num, i))
        push    qword[rsp + 4*8] ; num 
        push    qword[rsp + 8]       ; i
        call    isDivisible
        pop     rax;    pop the "i" arg
        pop     rax;    pop function return value
        cmp     rax,    1
        je      isComplete_iIsDivisible
        jmp     isComplete_mainWhile_loop

        isComplete_iIsDivisible:
            ; sum += i;
            mov     rax,        [rsp]
            add     qword[rsp + 8],     rax
        
        ;if (print_flag)
            cmp     byte[rsp + 3*8],    1
            jne      isComplete_mainWhile_loop
        
        isComplete_printI:
            ; out put i
            call    blankSpace
            mov     rax,    [rsp]
            call    writeNum

        isComplete_mainWhile_loop:
            inc     qword[rsp]
            jmp     isComplete_mainWhile
    isComplete_outMainWhile:
        mov     rax,        [rsp + 8]
        cmp     [rsp + 4*8],    rax  
        mov     qword[rsp + 4*8],    1   ;initialy set return flag = 1;
        je      isComplete_return
        mov     qword[rsp + 4*8],    0
    isComplete_return:
        pop         rax;    pop "i"
        pop         rax;    pop sum
        ret


_start:
    xor         rax,    rax
    call        readNum
    push        rax;    just to save num   
    push        rax;    function arg        
    push        0 ;     function arg        
    call        isComplete
    pop         rax;    function arg
    pop         rax;    function return value

    cmp         rax,    1
    je          ifNumIsComplete
    jmp         ifIumIsNotComplete

    ifNumIsComplete:
        mov     rax,    4
        mov     rbx,    1
        mov     rcx,    perfect_msg
        mov     rdx,    perfect_msg_len
        jmp     endIfNum
                
    ifIumIsNotComplete:
        mov     rax,    4
        mov     rbx,    1
        mov     rcx,    nope_msg
        mov     rdx,    nope_msg_len
        jmp     endIfNum

    endIfNum:
        int     80h
        call    newLine
        


    printDivisors:
        mov         rax,        1
        call        writeNum
        
        push        qword[rsp]
        push        1
        call        isComplete
        pop         rax  ; function arg
        pop         rax ; function arg



exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80