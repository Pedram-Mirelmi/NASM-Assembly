; %include "./common/p_array_tools.asm"
%ifndef P_ARRAY_TOOLS
%define P_ARRAY_TOOLS
; %include "./p_memory_tools.asm"
%ifndef P_MEMORY_TOOLS
%define P_MEMORY_TOOLS
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
    enter 0,    0   
    %define param_arr   qword[P_FUNC_PARAM_INDEX+8]
    %define param_size  qword[P_FUNC_PARAM_INDEX]
    push    rsi
    push    rcx
    ;;;;;;;;;;;;;;;;;;;;
    mov     rsi,    param_arr
    mov     rcx,    param_size
    dec     rcx
    print64bitArray_mainFor:
        cmp     rcx,    0
        je      print64bitArray_mainEndFor
        lodsq   
        call    writeNum
        call    blankSpace
        loop    print64bitArray_mainFor

    print64bitArray_mainEndFor:
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

section .text
    global _start


quickSortPartition: ;(8B arr, 8B low, 8B high)
    enter   24,  0 ;[i, j, pivot]
    %define local_i       qword[rbp-8]
    %define local_j       qword[rbp-16]
    %define local_pivot   qword[rbp-24]
    %define param_arr     qword[P_FUNC_PARAM_INDEX+16]
    %define param_low     qword[P_FUNC_PARAM_INDEX+8]
    %define param_high    qword[P_FUNC_PARAM_INDEX]
    push    rsi
    push    rdi
    ;;;;;;;;;;;;;;;;;;;;;;;;;
    ; int i = low - 1;
    mov     rax,    param_low
    dec     rax
    mov     local_i,    rax


    ; int pivot = arr[high];
    mov     rsi,    param_high
    shl     rsi,    3; *8
    add     rsi,    param_arr
    lodsq
    mov     local_pivot,    rax

    ; int j = low
    mov     rax,    local_i
    inc     rax
    mov     local_j,    rax

    quickSortPartition_mainFor:
        ; for(j; j < high; j++)
        mov     rax,    local_j
        cmp     rax,    param_high
        jge     quickSortPartition_mainFor_end

        quickSortPartition_mainFor_if:
            ; if(arr[j] < pivot)
            mov     rsi,    local_j
            shl     rsi,    3; *8
            add     rsi,    param_arr
            lodsq
            ; push    param_arr
            ; push    local_j
            ; call    get64bitArrayItem
            cmp     rax,    local_pivot
            jge     quickSortPartition_mainFor_endif  
            ; i++
            inc     local_i
            ; swap arr[i], arr[j]
            push    param_arr
            push    local_i
            push    local_j
            call    swap64bitArrayItems


        quickSortPartition_mainFor_endif:
            inc     local_j
            jmp     quickSortPartition_mainFor

    quickSortPartition_mainFor_end:
    push    param_arr
    push    local_i
    inc     qword[rsp]
    push    param_high
    call    swap64bitArrayItems

    mov     rax,    local_i
    inc     rax;    return i + 1
    ;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rdi
    pop     rsi
    %undef  local_i
    %undef  local_j
    %undef  local_pivot
    %undef  param_arr 
    %undef  param_low
    %undef  param_high
    leave
    ret      24




quickSort: ; (8B arr, 8B low, 8B high)
    enter   8,  0; [pivot]
    %define param_arr   qword[P_FUNC_PARAM_INDEX+16]
    %define param_low   qword[P_FUNC_PARAM_INDEX+8]
    %define param_high  qword[P_FUNC_PARAM_INDEX]
    %define local_pivot qword[rbp-8]
    ;;;;;;;;;;;;;;;;;;;;;;
    mov     rax,    param_low
    cmp     rax,    param_high
    jge     quickSort_Endif
    
    ; pivot = partition(arr, low, high)
    push    param_arr
    push    param_low
    push    param_high
    call    quickSortPartition
    mov     local_pivot,    rax

    ; quickSort(arr, low, pivot-1)
    push    param_arr
    push    param_low
    push    rax
    dec     qword[rsp]; pivot - 1
    call    quickSort

    ; quickSort(arr, pivot+1, high)
    push    param_arr
    push    local_pivot
    inc     qword[rsp];  pivot + 1
    push    param_high
    call    quickSort

    quickSort_Endif:
    
    ;;;;;;;;;;;;;;;;;;;;;;
    %undef  param_arr
    %undef  param_low
    %undef  param_high
    %undef  local_pivot 
    leave
    ret     16


main:
    enter   16,     0;  [arr, size]
    %define local_arr   qword[rbp-16]
    %define local_size  qword[rbp-8]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; input size
    call    readNum 
    mov     local_size, rax
    push    local_size
    call    read64bitArray
    
    mov     local_arr,  rax

    push    local_arr
    push    qword 0
    push    local_size
    dec     qword[rsp]
    call    quickSort

    push    local_arr
    push    local_size
    call    print64bitArray
    
    push    local_arr
    push    local_size
    call    Pfree

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    %undef  local_arr
    %undef  local_size
    leave
    ret

   
_start:
    call main
  
exit:
    mov     ebx,     0
    mov     eax,     1
    int     0x80

    
    
