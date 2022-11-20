%include "in_out.asm"
section .text
    global  _start


addDigits:  ;(int64 num)
    ;stack: [int64 num,     retAddr]
    
    mov         r8,     10

    ;int sum = 0;
    push    qword   0;  sum,    stack:[int64 num,   retAddr,    int64 sum=0]
    
    mov         rax,    [rsp + 2*8]; num
    addDigits_mainWhile:
    ; while (num != 0)
        cmp         rax,    0
        je          addDigits_endMainWhile

        xor         rdx,    rdx
        
        ; sum += num % 10
        ; num = num / num   (in register)
        div         r8
        
        add         [rsp],  rdx
        
        jmp         addDigits_mainWhile         

    addDigits_endMainWhile:
        mov         rax,    [rsp]
        mov qword   [rsp + 2*8],    rax; store return value
        pop         rax;    pop sum
        ret 



_start:
    xor     rax,    rax
    call    readNum
    push    rax
    call    addDigits
    pop     rax; get the fucntion return value
    call    writeNum




exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80