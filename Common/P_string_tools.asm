%ifndef P_STRING_TOOLS
%define P_STRING_TOOLS
%include "./in_out.asm"
%include "./p_memory_tools.asm"

section .stringToolsConstants
    one         dq          1
    zero        dq          0

section .text

strEndsWith: ;(8B str, 8B ending_str)
    enter       0,  0
    %define     param_str       qword[P_FUNC_PARAM_INDEX+8]
    %define     param_end_str   qword[P_FUNC_PARAM_INDEX]
    push    r10
    push    r11 
    push    rsi
    push    rdi
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rdi,    param_str
    call    GetStrlen
    mov     r10,    rdx

    mov     rdi,    param_end_str
    call    GetStrlen
    mov     r11,    rdx 

    xor     rax,    rax
    cmp     r10,    r11 
    jb      strEndsWith_end
    
    mov     rcx,    r11 
    mov     rsi,    param_str    
    add     rsi,    r10
    dec     rsi

    mov     rdi,    param_end_str
    add     rdi,    r11 
    dec     rdi

    std 
    repe    cmpsb
    cmove   rax,    [one]
    cmovne   rax,    [zero]

  
    strEndsWith_end:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rdi
    pop     rsi
    pop     r11 
    pop     r10
    %undef      param_str
    %undef      param_end_str
    leave   
    ret     16


concatString: ;(8B first, 8B second)
    enter   24,  0
    %define param_first         qword[P_FUNC_PARAM_INDEX+8]
    %define param_second        qword[P_FUNC_PARAM_INDEX]
    %define local_first_size    qword[rbp-8]
    %define local_second_size   qword[rbp-16]
    %define local_result        qword[rbp-24]
    push    rdx
    push    rdi
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rdi,    param_first
    call    GetStrlen
    mov     local_first_size,   rdx
    mov     rdi,    param_second
    call    GetStrlen
    mov     local_second_size,  rdx
    add     rdx,    local_first_size
    push    rdx
    call    Pmalloc
    mov     local_result,       rax
    push    local_result
    push    param_first
    push    local_first_size
    call    PMemcpy

    push    local_result
    mov     rax,    local_first_size
    add     [rsp],  rax
    push    param_second
    push    local_second_size
    call    PMemcpy

    mov     rax,    local_result
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rdi
    pop     rdx
    %undef  local_second_size
    %undef  local_first_size
    %undef  param_first
    %undef  param_second
    leave
    ret     16


%endif