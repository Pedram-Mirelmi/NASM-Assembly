; %include "./common/p_generals.asm"
%ifndef P_GENERALS
%define P_GENERALS

%include "in_out.asm"
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

extern scanf
extern printf
extern fflush
extern malloc

section .c_tools_str_consts
    f6fmt    db      "%lf", 0
    

section .data
    msg         db  "Hello World!", 0
	fmts	    db	"%lf", 0
	fmtp	    db	"%lf", 0xA, 0
    term        dq  1.0
    one         dq  1.0


section .bss
    temp    resq    1
    n       resq    1
    x       resq    1
    k       resq    1
    result  resq    1

section .text
	global main
    global _start


printTopOfStack:
    fst     qword[temp]
    movq    xmm0,   qword[temp]
    movq    xmm1,   qword[temp]
    mov     rdi,    fmtp
    mov     rax,    1
    call    printf
    ret

doPrintStack:
    call    printTopOfStack
    ret
    
printHello:
    mov     rsi,    msg
    call    printString
    ret



main:
    enter   0,  0
    %define k       qword[k]
    %define n       qword[n]
    %define term    qword[term]
    %define temp    qword[temp]
    %define result  qword[result]


    call    readNum
    mov     n,  rax

    mov     rdi,  fmts
    mov     rsi,  x     ; address of x
    call    scanf 


    mov     k,  1

    mainWhile:
        mov     rax,    k 
        cmp     rax,    n
        jg      mainEndWhile
        mov     rax,    k
        ; call    writeNum
        ; call    readNum
        ; call    printHello
        fld     term
        ; call    doPrintStack
        mov     rcx,    k
        kWhile:
            ; call    printHello
            ; mov     rax,    rcx
            ; call    writeNum
            ; call    readNum
            mov     temp,   rcx
            fild    temp
            fdivp   
            
            fld     qword[x]
            fmulp
    
            loop kWhile

        fld     result
        faddp
        fstp    result

        mov     rax,    [one]
        mov     term,   rax

        inc     k
        mov     rax,    k
        ; call    writeNum
        ; call    newLine
        jmp     mainWhile

    mainEndWhile:   

    fld     result
    fld     qword[one]
    faddp   
    fstp    result

    movq    xmm0,   result
    mov     rdi,    fmtp
    mov     rax,    1
    call    printf

    %undef k   
    %undef n 
    %undef temp
    %undef term
    leave

Exit:
	mov     rax,    60
    mov     rdi,    0
    call    fflush
    syscall

