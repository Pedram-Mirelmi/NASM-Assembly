%ifndef P_IO
%define P_IO
%include "./p_array_tools.asm"
readln: ;(void) -> rax(address of the string)
    enter   8,  0
    %define local_arr   qword[rbp-8]
    push    rsi
    push    rdi
    push    rcx
    ;;;;;;;;;;;;;;;;;;
    xor     rax,    rax
    xor     rcx,    rcx
    readln_firstWhile:
        call    getc
        cmp     rax,    10
        je      readln_doMalloc
        inc     rcx; count
        dec     rsp
        mov     byte[rsp],  al
        jmp     readln_firstWhile

    readln_doMalloc:
        push    rcx
        call    Pmalloc
        mov     local_arr,  rax
    
    
    mov     rdi,    local_arr
    add     rdi,    rcx
    dec     rdi
    readln_secondWhile:
        mov     al,     [rsp]
        mov     [rdi],  al
        dec     rdi 
        inc     rsp
        loop    readln_secondWhile

    mov     rax,    local_arr
    ;;;;;;;;;;;;;;;;;;
    pop    rcx
    pop    rdi
    pop    rsi
    %undef local_arr
    leave
    ret 

%endif