%ifndef P_ARRAY_TOOLS
%define P_ARRAY_TOOLS
%include "./p_memory_tools.asm"


swap64bitArrayItems: ;(8B arr, 8B i, 8B j)
    enter   0,  0
    %define param_arr   qword[P_FUNC_PARAM_INDEX+16]
    %define param_i     qword[P_FUNC_PARAM_INDEX+8]
    %define param_j     qword[P_FUNC_PARAM_INDEX]
    push    r8  ; temp
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rax,    param_arr
    mov     rsi,    param_i
    mov     rdi,    param_j
    mov     r8,     [rax+8*rdi]
    xchg    [rax+8*rsi],   r8
    xchg    [rax+8*rdi],   r8   
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     r8
    %undef param_arr
    %undef param_i
    %undef param_j
    leave
    ret     24


read64bitArray: ;(8B size)
    enter   8,  0; [arr, i]
    %define param_size  qword[P_FUNC_PARAM_INDEX]
    %define local_arr   qword[rbp-8]
    push    rdi
    push    rcx
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    cld
    ; arr = malloc(8*size)
    push    param_size
    shl     qword[rsp], 3; *8
    call    Pmalloc
    mov     local_arr,  rax
    mov     rdi,    rax
    mov     rcx,    param_size
    read64bitArray_mainFor:
        ; input arr[i]
        call    readNum
        stosq 
        loop    read64bitArray_mainFor

    mov     rax,    local_arr; return arr
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rcx
    pop     rdi
    %undef  local_arr
    %undef  param_size
    leave 
    ret 8


print64bitArray: ;(8B arr, 8B size)
    enter 0,    0   ;[i]
    %define param_arr   qword[P_FUNC_PARAM_INDEX+8]
    %define param_size  qword[P_FUNC_PARAM_INDEX]
    push    rsi
    push    rcx
    ;;;;;;;;;;;;;;;;;;;;
    mov     rsi,    param_arr
    mov     rcx,    param_size
    dec     rcx
    print64bitArray_mainFor:
        lodsq   
        call    writeNum
        call    blankSpace
        loop    print64bitArray_mainFor

    ; last element without blank space after it
    lodsq
    call    writeNum
    ;;;;;;;;;;;;;;;;;;;;
    pop     rcx
    pop     rsi
    %undef  param_arr
    %undef  param_size
    leave
    ret     16


print8bitArray: ;(8B arr, 8B size)
    enter 0,    0   ;[i]
    %define param_arr   qword[P_FUNC_PARAM_INDEX+8]
    %define param_size  qword[P_FUNC_PARAM_INDEX]
    push    rsi
    push    rcx
    ;;;;;;;;;;;;;;;;;;;;
    mov     rsi,    param_arr
    mov     rcx,    param_size
    dec     rcx
    print8bitArray_mainFor:
        lodsb
        call    writeNum
        call    blankSpace
        loop    print8bitArray_mainFor

    ; last element without blank space after it
    lodsb   
    call    writeNum
    ;;;;;;;;;;;;;;;;;;;;
    pop     rcx
    pop     rsi
    %undef  param_arr
    %undef  param_size
    leave
    ret     16



get64bitMatrixItem: ;(8B matrix, 8B i, 8B j); mat must be the form int**
    enter   0,  0
    %define param_mat   qword[P_FUNC_PARAM_INDEX+16]
    %define param_i     qword[P_FUNC_PARAM_INDEX+8]
    %define param_j     qword[P_FUNC_PARAM_INDEX]
    push    rsi
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rsi,    param_i
    shl     rsi,    3; *8
    add     rsi,    param_mat
    lodsq   

    mov     rsi,    param_j
    shl     rsi,    3; *8
    add     rsi,    rax
    lodsq
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rsi
    %undef  param_mat
    %undef  param_i
    %undef  param_j
    leave
    ret 24

set64bitMatrixItem: ;(8B matrix, 8B i, 8B j, 8B value)
    enter   0,  0
    %define param_mat   qword[P_FUNC_PARAM_INDEX+24]
    %define param_i     qword[P_FUNC_PARAM_INDEX+16]
    %define param_j     qword[P_FUNC_PARAM_INDEX+8]
    %define param_value qword[P_FUNC_PARAM_INDEX]
    ;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rsi,    param_i
    shl     rsi,    3; *8
    add     rsi,    param_mat
    lodsq

    mov     rdi,    param_j
    shl     rdi,    3; *8
    add     rdi,    rax
    mov     rax,    param_value
    stosq
    ;;;;;;;;;;;;;;;;;;;;;;;;;
    %undef  param_mat
    %undef  param_i
    %undef  param_j
    %undef  param_value
    leave
    ret     32


print64bitMatrix: ;(8B matrix, 8B rows, 8B cols)
    enter 0,    0; [matrix]
    %define param_mat   qword[P_FUNC_PARAM_INDEX+16]
    %define param_rows  qword[P_FUNC_PARAM_INDEX+8]
    %define param_cols  qword[P_FUNC_PARAM_INDEX]
    push    rsi
    push    rcx
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rsi,    param_mat
    mov     rcx,    param_rows
    dec     rcx
    print64bitMatrix_IFor:
        lodsq
        push    rax
        push    param_cols
        call    print64bitArray

        call    newLine
        loop    print64bitMatrix_IFor

    lodsq
    push    rax
    push    param_cols
    call    print64bitArray
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rcx
    pop     rsi
    %undef  param_rows
    %undef  param_cols
    %undef  param_mat
    leave
    ret 24

%endif