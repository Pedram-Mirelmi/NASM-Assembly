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
    min_diff    dq  999999999999999999999.99999999999999999
    msg         db  "Hello World!", 0
	fmts	    db	"%lf", 0
	fmtp	    db	"%lf %lf", 0xA, 0
    zero        dq  0


section .bss
    temp    resq    1
    i       resq    1
    j       resq    1
    res1	resq    1
    res2    resq    1
    len     resq    1
    arr     resq    10000

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

    
printHello:
    mov     rsi,    msg
    call    printString
    ret


checkDifference:
    ; call    printHello

    mov     rax,    [i] 
    fld     qword[arr+rax*8] ; [arr[i]]


    mov     rax,    [j]
    fld     qword[arr+rax*8] ; [arr[j], arr[i]]

    fsubp                    ; [diff]
    fabs                     ; [[diff]]

    fld     qword[min_diff]

    fcomi   st0,    st1
    ja      shouldUpdate
    fstp    qword[temp]; pop old
    fstp    qword[temp]; pop new
    ret

    shouldUpdate:
        fstp    qword[min_diff]; pop old
        fstp    qword[min_diff]; pop new

        mov     rax,    [i]
        mov     rax,    [arr+rax*8]
        mov     [res1], rax

        mov     rax,    [j]
        mov     rax,    [arr+rax*8]
        mov     [res2], rax
        ret

main:
    enter   0,  0
    %define i       qword[i]
    %define j       qword[j]
    %define len     qword[len]
    %define res1    qword[res1]
    %define res2    qword[res2]

    call    readNum
    mov     len,  rax

    mov     rcx,    len
    xor     rbx,    rbx
    dec     rbx
    readArrayLoop:
        inc     rbx
        mov     rdi,  fmts
        mov     rsi,  temp     ; address of temp
        push    rbx
        push    rcx
        call    scanf 
        pop     rcx
        pop     rbx
        mov     rax,    [temp]   
        mov     qword[arr+rbx*8],  rax
        loop    readArrayLoop


    mov     i,    0
    mov     j,    0
    outerWhile:
        mov     rax,    i
        cmp     rax,    len
        je      outerEndWhile

        mov     rax,    i 
        mov     j,      rax
        inc     j
        innerWhile:
            mov     rax,    j
            cmp     rax,    len
            je      innerEndWhile

            call    checkDifference

            inc     j 
            jmp     innerWhile     
        
        innerEndWhile:

        inc     i 
        jmp     outerWhile

    outerEndWhile:
        movq    xmm0,   res1
        movq    xmm1,   res2
        mov     rdi,    fmtp
        mov     rax,    2
        call    printf



    

    %undef i   
    %undef j   
    %undef len 
    %undef y   
    %undef res1
    %undef res2
    leave

Exit:
	mov     rax,    60
    mov     rdi,    0
    call fflush
    syscall

