; %include "./common/p_array_tools.asm"
%ifndef P_ARRAY_TOOLS
%define P_ARRAY_TOOLS
; %include "./p_memory_tools.asm"
%ifndef P_MEMORY_TOOLS
%define P_MEMORY_TOOLS
; %include "./sys_equal.asm"
; %include "./p_generals.asm"
%ifndef P_GENERALS
%define P_GENERALS

%include "./in_out.asm"
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
; P_GENERALS
Pmalloc: ;(int64 size) -> int64 address
    enter   0,  0
    push    rsi
    push    r10

    mov     rax,    sys_mmap
    mov     rsi,    [P_FUNC_PARAM_INDEX]
    mov     rdx,    PROT_READ | PROT_WRITE
    mov     r10,    MAP_ANONYMOUS | MAP_PRIVATE
    syscall

    

    PmallocEnd:
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
; P_MEMORY_TOOLS


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
; P_ARRAY_TOOLS

section .data
    NaN_string  db  "NaN"

section .text
    global _start


printNaN:
    mov     rax,    4
    mov     rbx,    stdout
    mov     rcx,    NaN_string
    mov     rdx,    3
    int     80h
    ret

findMinIndex: ;(8B arr, 8B index)
    enter 8,    0
    %define param_arr   qword[P_FUNC_PARAM_INDEX+8]
    %define param_index qword[P_FUNC_PARAM_INDEX]
    %define local_value qword[rbp-8]
    push    rsi
    push    rdi
    push    rcx
    push    r8
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    std
    mov     rsi,    param_index
    shl     rsi,    3; *8
    add     rsi,    param_arr
    lodsq
    mov     local_value,    rax
    mov     rdi,    rsi
    findMinIndex_mainWhile:
        cmp     rdi,    param_arr
        jl      findMinIndex_mainEndWhile
        cmp     rax,    [rdi]
        jne     findMinIndex_mainEndWhile
        sub     rdi,    8
        jmp     findMinIndex_mainWhile
    findMinIndex_mainEndWhile:
        sub     rdi,    param_arr
        sar     rdi,    3
        mov     rax,    rdi
        inc     rax

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     r8
    pop     rcx
    pop     rdi
    pop     rsi
    %undef  param_arr   
    %undef  param_index
    %undef  local_value
    leave
    ret     16  

binarySearch: ;(8B arr, 8B low, 8B high, 8B value)
    enter   8,  0; [mid]
    %define param_arr   qword[P_FUNC_PARAM_INDEX+24]
    %define param_low   qword[P_FUNC_PARAM_INDEX+16]
    %define param_high  qword[P_FUNC_PARAM_INDEX+8]
    %define param_value qword[P_FUNC_PARAM_INDEX]
    %define local_mid   qword[rbp-8]
    push    rsi
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ; high = size -1
    ; mov     rax,    param_size
    ; dec     rax
    ; mov     param_high, rax
    ; low = 0
    ; mov     param_low,  0
    binarySearch_mainIf:
        mov     rax,    param_low
        cmp     rax,    param_high
        jg      binarySearch_mainEndIf
        ; mid = low + (high - low) / 2
        mov     rax,    param_high
        sub     rax,    param_low
        shr     rax,    1
        add     rax,    param_low
        mov     local_mid,  rax
        ; if(arr[mid] = value)
        mov     rsi,    local_mid
        shl     rsi,    3; *8
        add     rsi,    param_arr
        mov     rax,    [rsi]
        ; push    param_arr
        ; push    local_mid
        ; call    get64bitArrayItem
        cmp     param_value,    rax
        je      binarySearch_mainIf_found
        jl      binarySearch_mainIf_less
        jg      binarySearch_mainIf_greater

        binarySearch_mainIf_found:
            mov     rax,    local_mid
            pop     rsi
            leave
            ret     32

        binarySearch_mainIf_less:
            push    param_arr
            push    param_low
            push    local_mid
            dec     qword[rsp]
            push    param_value
            call    binarySearch
            ; return:
            pop     rsi
            leave
            ret     32
        binarySearch_mainIf_greater:
            push    param_arr
            push    local_mid
            inc     qword[rsp]
            push    param_high
            push    param_value
            call    binarySearch
            ; return:
            pop     rsi
            leave
            ret     32


    binarySearch_mainEndIf: ; not found
    mov     rax,    -1
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rsi
    %undef  param_arr
    %undef  param_low
    %undef  param_high
    %undef  param_value
    %undef  local_mid

    leave
    ret     32




startResponsing: ;(8B arr, 8B size, 8B q)
    enter   0,  0
    %define param_arr   qword[P_FUNC_PARAM_INDEX+16]
    %define param_size  qword[P_FUNC_PARAM_INDEX+8]
    %define param_q     qword[P_FUNC_PARAM_INDEX]
    push    rsi

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; for(int i = 0; i < q; i++)
    xor     rsi,    rsi
    startResponsing_mainFor:
        cmp     rsi,    param_q
        jge     startResponsing_mainEndFor
        call    readNum
        push    param_arr
        push    qword 0
        push    param_size
        dec     qword[rsp]
        push    rax
        call    binarySearch
        cmp     rax,    -1
        je      startResponsing_mainFor_notFound
        jmp     startResponsing_mainFor_found

        startResponsing_mainFor_found:
            push    param_arr
            push    rax
            call    findMinIndex
            call    writeNum
            inc     rsi
            cmp     rsi,    param_q
            je      startResponsing_mainEndFor
            call    newLine
            jmp     startResponsing_mainFor

        startResponsing_mainFor_notFound:
            call    printNaN
            inc     rsi
            cmp     rsi,    param_q
            je      startResponsing_mainEndFor
            call    newLine
            jmp     startResponsing_mainFor


    startResponsing_mainEndFor:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rsi
    %undef  param_arr
    %undef  param_size
    %undef  param_q
    leave
    ret     24

Pmain:
    enter   24,  0
    %define local_arr   qword[rbp-8]
    %define local_size  qword[rbp-16]
    %define local_q     qword[rbp-24]

    ; input size
    call    readNum; size
    mov     local_size, rax

    push    rax; size
    call    read64bitArray
    mov     local_arr,  rax
    ; input q
    call    readNum
    mov     local_q,    rax

    push    local_arr
    push    local_size
    push    local_q
    call    startResponsing


    push    local_arr
    push    local_size
    call    Pfree
    %undef  local_arr
    %undef  local_size
    %undef  local_q

    leave   
    ret     
    
_start:
    call    Pmain
   
exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80
