%ifndef P_MEMORY_TOOLS
%define P_MEMORY_TOOLS
%include "./sys_equal.asm"
%include "./p_generals.asm"
%include "./p_array_tools.asm"

Pmalloc: ;(int64 size) -> int64 address
    enter   0,  0
    push    rsi
    push    r10
    push    rcx

    mov     rax,    sys_mmap
    mov     rsi,    [P_FUNC_PARAM_INDEX]
    mov     rdx,    PROT_READ | PROT_WRITE
    mov     r10,    MAP_ANONYMOUS | MAP_PRIVATE
    syscall

    
    PmallocEnd:
        pop     rcx
        pop     r10
        pop     rsi
        leave
        ret 8
    

Pfree: ;(int64 ptr, int64 size) -> void
    enter   0, 0
    push    rsi
    mov     rax,    sys_mumap
    mov     rdi,    [P_FUNC_PARAM_INDEX+8];  ptr
    mov     rsi,    [P_FUNC_PARAM_INDEX];    size
    syscall
    pop     rsi
    leave
    ret     16

PMemcpy: ;(8B dest, 8B src, 8B bytes)
    enter   0,  0
    %define param_dest  qword[P_FUNC_PARAM_INDEX+16]
    %define param_src   qword[P_FUNC_PARAM_INDEX+8]
    %define param_bytes qword[P_FUNC_PARAM_INDEX]
    push    rsi
    push    rdi
    push    rcx
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cld
    mov     rsi,    param_src
    mov     rdi,    param_dest
    mov     rcx,    param_bytes
    shr     rcx,    3; /8
    rep     movsq
   
    mov     rcx,    param_bytes
    and     rcx,    7;
    rep     movsb
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rcx
    pop     rdi
    pop     rsi
    %undef  param_dest
    %undef  param_src
    %undef  param_bytes
    leave
    ret     24


%endif