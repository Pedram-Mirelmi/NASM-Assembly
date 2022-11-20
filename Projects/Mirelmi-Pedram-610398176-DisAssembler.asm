;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; sys_equal.asm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%ifndef SYS_EQUAL
%define SYS_EQUAL

    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
      

    sys_mkdir       equ 83
    sys_makenewdir  equ 0q777


    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
    
     
    sys_exit     equ     60
    
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
	PROT_NONE	  equ   0x0
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
    
    ;access mode
    O_DIRECTORY equ     0q0200000
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000


    BEG_FILE_POS    equ     0
    CURR_POS        equ     1
    END_FILE_POS    equ     2
    
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    Space         equ   0x20

%endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; in_out.asm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Read a signed number from keybord and return in rax and write it to consol as a string
; using syscall
%ifndef NOWZARI_IN_OUT
%define NOWZARI_IN_OUT

; %include "./sys_equal.asm"
;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:	

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout 
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax 
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9	
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx 
   cmp    bl, 0
   je     sEnd
   neg    rax 
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
   push    rax
   push    rcx
   push    rsi
   push    rdx
   push    rdi

   mov     rdi, rsi
   call    GetStrlen
   mov     rax, sys_write  
   mov     rdi, stdout
   syscall 
   
   pop     rdi
   pop     rdx
   pop     rsi
   pop     rcx
   pop     rax
   ret
;-------------------------------------------
; rdi : zero terminated string start 
GetStrlen:
   push    rbx
   push    rcx
   push    rax  

   xor     rcx, rcx
   not     rcx
   xor     rax, rax
   cld
         repne   scasb
   not     rcx
   lea     rdx, [rcx -1]  ; length in rdx

   pop     rax
   pop     rcx
   pop     rbx
   ret
;-------------------------------------------

%endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; file-in-out.asm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%ifndef NOWZARI_FILE_IN_OUT
%define NOWZARI_FILE_IN_OUT
; %include "./in_out.asm"
;----------------------------------------------------
section     .fileIOMessages
    error_create        db      "error in creating file             ", NL, 0
    error_close         db      "error in closing file              ", NL, 0
    error_write         db      "error in writing file              ", NL, 0
    error_open          db      "error in opening file              ", NL, 0
    error_open_dir      db      "error in opening dir               ", NL, 0
    error_append        db      "error in appending file            ", NL, 0
    error_delete        db      "error in deleting file             ", NL, 0
    error_read          db      "error in reading file              ", NL, 0
    error_print         db      "error in printing file             ", NL, 0
    error_seek          db      "error in seeking file              ", NL, 0
    error_create_dir    db      "error in creating directory        ", NL, 0
    suces_create        db      "file created and opened for R/W    ", NL, 0
    suces_create_dir    db      "dir created and opened for R/W     ", NL, 0
    suces_close         db      "file closed                        ", NL, 0
    suces_write         db      "written to file                    ", NL, 0
    suces_open          db      "file opend for R/W                 ", NL, 0
    suces_open_dir      db      "dir opened for R/W                 ", NL, 0
    suces_append        db      "file opened for appending          ", NL, 0
    suces_delete        db      "file deleted                       ", NL, 0
    suces_read          db      "reading file                       ", NL, 0
    suces_seek          db      "seeking file                       ", NL, 0


section .text


;----------------------------------------------------
; rdi : file name; rsi : file permission
createFile:
    mov     rax, sys_create
    mov     rsi, sys_IRUSR | sys_IWUSR 
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     createerror
    mov     rsi, suces_create           
    call    printString
    ret
createerror:
    mov     rsi, error_create
    call    printString
    ret

;----------------------------------------------------
; rdi : file name; rsi : file access mode 
; rdx: file permission, do not need
openFile:
    mov     rax, sys_open
    mov     rsi, O_RDWR     
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     openerror
    mov     rsi, suces_open
    call    printString
    ret
openerror:
    mov     rsi, error_open
    call    printString
    ret
;----------------------------------------------------
; rdi point to file name
appendFile:
    mov     rax, sys_open
    mov     rsi, O_RDWR | O_APPEND
    syscall
    cmp     rax, -1     ; file descriptor in rax
    jle     appenderror
    mov     rsi, suces_append
    call    printString
    ret
appenderror:
    mov     rsi, error_append
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi : buffer ; rdx : length
writeFile:
    mov     rax, sys_write
    syscall
    cmp     rax, -1         ; number of written byte
    jle     writeerror
    mov     rsi, suces_write
    call    printString
    ret
writeerror:
    mov     rsi, error_write
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi : buffer ; rdx : length
readFile:
    mov     rax, sys_read
    syscall
    cmp     rax, -1           ; number of read byte
    jle     readerror
    ; mov     byte [rsi+rax], 0 ; add a  zero ??????????????
    mov     rsi, suces_read
    call    printString
    ret
readerror:
    mov     rsi, error_read
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor
closeFile:
    mov     rax, sys_close
    syscall
    cmp     rax, -1      ; 0 successful
    jle     closeerror
    mov     rsi, suces_close
    call    printString
    ret
closeerror:
    mov     rsi, error_close
    call    printString
    ret

;----------------------------------------------------
; rdi : file name
deleteFile:
    mov     rax, sys_unlink
    syscall
    cmp     rax, -1      ; 0 successful
    jle     deleterror
    mov     rsi, suces_delete
    call    printString
    ret
deleterror:
    mov     rsi, error_delete
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi: offset ; rdx : whence
seekFile:
    mov     rax, sys_lseek
    syscall
    cmp     rax, -1
    jle     seekerror
    mov     rsi, suces_seek
    call    printString
    ret
seekerror:
    mov     rsi, error_seek
    call    printString
    ret

;----------------------------------------------------

%endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; p_generals.asm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%ifndef P_GENERALS
%define P_GENERALS

; %include "./in_out.asm"
%define P_FUNC_PARAM_INDEX rbp+16


%macro printNum 1
    push    rax
    mov     rax,    %1
    call    writeNum
    call    newLine
    pop     rax
%endmacro


%macro push2 2
    push    %1
    push    %2
%endmacro

%macro push3 3
    push    %1
    push    %2
    push    %3
%endmacro

%macro  push4 4
    push    %1
    push    %2
    push    %3
    push    %4
%endmacro

%macro pushAll 0
    push    rbx
    push    rcx
    push    rdx 
    push    rsi 
    push    rdi 
    push    r8 
    push    r9 
    push    r10 
    push    r11 
    push    r12 
    push    r13 
    push    r14 
    push    r15
%endmacro

%macro popAll 0
    pop    r15
    pop    r14 
    pop    r13 
    pop    r12 
    pop    r11 
    pop    r10 
    pop    r9 
    pop    r8 
    pop    rdi 
    pop    rsi 
    pop    rdx 
    pop    rcx
    pop    rbx
%endmacro
    


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; p_memory_tools.asm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%ifndef P_MEMORY_TOOLS
%define P_MEMORY_TOOLS
; %include "./sys_equal.asm"
; %include "./p_generals.asm"

; Pmalloc: ;(int64 size) -> int64 address
%macro malloc 2
    ;1: size    2:result
    pushAll
    mov     r8,     %1

    mov     rax,    sys_mmap
    mov     rsi,    r8
    mov     rdx,    PROT_READ | PROT_WRITE
    mov     r10,    MAP_ANONYMOUS | MAP_PRIVATE
    xor     r8,     r8
    xor     r9,     r9
    syscall

    popAll
    mov     %2, rax
%endmacro

; Pfree: ;(int64 ptr, int64 size) -> void
%macro  memFree 2
;   1:addr     2:size
    pushAll
    mov     rax,    sys_mumap
    mov     rdi,    %1;  ptr
    mov     rsi,    %2;    size
    syscall
    popAll
%endmacro

; PMemcpy: ;(8B dest, 8B src, 8B bytes)
%macro memCpy 3
;   1:dest  2:src   3:bytes
    pushAll
    mov     r8,     %1
    mov     r9,     %2
    mov     r10,    %3
    cld
    mov     rsi,    r9
    mov     rdi,    r8
    mov     rcx,    r10
    shr     rcx,    3; /8
    rep     movsq
   
    mov     rcx,    r10
    and     rcx,    7;
    rep     movsb
    popAll
%endmacro

%macro arr64bitFind 4
    ;1:arr  2:size  3:target    4:result(index)
    pushAll
    mov     r8,     %1
    mov     r9,     %2
    mov     r10,    %3
    mov     r11,    -1
    xor     rbx,    rbx

    mov     rdi,    r8
    mov     rcx,    r9
    mov     rax,    r10
    repne   scasq

    cmovne  rbx,    r11
    sub     rdi,    8
    sub     rdi,    r8
    shr     rdi,    3
    cmp     rbx,    -1
    cmove   rdi,    r11  
    mov     rax,    rdi
    popAll
    mov     %4, rax
%endmacro

%endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; p_io.asm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%ifndef P_IO
%define P_IO
; %include "./p_memory_tools.asm"
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
        malloc  rcx,    rax
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; p_string_tools.asm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%ifndef P_STRING_TOOLS
%define P_STRING_TOOLS
; %include "./in_out.asm"
; %include "./p_memory_tools.asm"

section .stringToolsConstants
    one         dq          1
    zero        dq          0

section .text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro strlen 2 
    ; 1: c_str      2: target
    pushAll
    mov     rdi,    %1
    xor     rcx,    rcx
    not     rcx
    xor     rax,    rax
    cld
    repne   scasb
    not     rcx
    lea     rax,    [rcx-1]
    popAll
    mov     %2, rax
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro  strCmp  4
    ;1:first   2:second   3:len   4:result
    pushAll
    mov     r8,     %1
    mov     r9,     %2
    mov     r10,     %3


    mov     rsi,    r8
    mov     rdi,    r9
    mov     rcx,    r10
    repe    cmpsb
    mov     r8,     1
    mov     r9,     0

    cmove   rax,    r8
    cmovne  rax,    r9
    popAll
    mov     %4, rax
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
strCharFindFunc:
    
    mov     rbx,    -1
    mov     rdi,    r8
    strlen  rdi,    rcx
    cld
    mov     al,     r9b
    repne   scasb 
    cmovne  rax,    rbx
    jne     strCharFindFunc_end
    sub     rdi,    r8
    dec     rdi
    mov     rax,    rdi
    strCharFindFunc_end:
    ret
%macro strCharFind 3
    ;1: str     2:char(1B),     3:result
    pushAll
    mov     r8,     %1
    mov     r9b,     %2

    call    strCharFindFunc

  
    popAll
    mov     %3,     rax
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
strFineLoopFunc:
    mov     rsi,    -1
    cmp     r10,    r11
    cmovb   rax,    rsi
    jb      strFind_end  

    mov     rsi,    r8
    mov     rdi,    r9

    mov     rcx,    r10 
    sub     rcx,    r11
    inc     rcx
    dec     rsi 

    strFind_mainLoop:
        inc     rsi
        strCmp  rsi,    rdi,    r11,     rax
        cmp     rax,    1
        je      strFind_found
        loop    strFind_mainLoop

    mov     rsi,    -1
    strFind_found:
        mov     rax,    rsi 

    strFind_end:
        ret


%macro strFind 3
    ; 1:source     2:patt     3:result(addr)
    pushAll
    mov     r8,    %1
    mov     r9,    %2

    strlen  r8, r10 
    strlen  r9, r11

    call    strFineLoopFunc
    popAll
    mov     %3, rax
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
strCharCountLoop:
    strCharCountLoop_mainLoop:
        scasb
        lea     rbx,    [rdx+1]
        cmove   rdx,    rbx
        loop    strCharCountLoop_mainLoop
    ret
%macro  strCharCount 3
    ;1:str      2:char,     3:result
    pushAll    
    mov     r8,     %1
    mov     r9b,    %2

    mov     rsi,    r8

    xor     rdx,    rdx
    xor     rbx,    rbx
    strlen  rsi,     rcx
    mov     rdi,    r8
    cld     
    mov     al,     r9b
    call    strCharCountLoop

    mov     rax,    rdx
    popAll
    mov     %3, rax
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro substr 4
    ;1:str      2:start     3:end       4:result     
    pushAll
    mov     r8,     %1
    mov     r9,     %2
    mov     r10,    %3
    
    mov     rbx,    r10
    sub     rbx,    r9
    inc     rbx;    null at the end
    malloc  rbx,    rdi; dest in rdi
    dec     rbx

    mov     rsi,    r8
    add     rsi,    r9; src in rsi
    strCpy  rdi,    rsi,    rbx
    mov     rax,    rdi
    popAll
    mov     %4,     rax
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro  strCpy  3
    ;1:dest     2:source    3:size
    pushAll
    mov     r8,     %1
    mov     r9,     %2
    mov     r10,    %3
    mov     rdi,    r8
    mov     rsi,    r9
    mov     rcx,    r10
    memCpy  rdi,    rsi,    rcx
    mov     byte[rdi+rcx],  0
    popAll  
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
strStartsWith: ;(str, key)
    enter   0,  0
    %define param_str   qword[P_FUNC_PARAM_INDEX+8]
    %define param_key   qword[P_FUNC_PARAM_INDEX]

    pushAll

    strlen  param_str,     rax
    strlen  param_key,     rbx
    mov     r8,     0
    cmp     rax,    rbx
    cmovb   rax,    r8
    jb      strStartsWith_end
    strCmp  param_str,  param_key,  rbx,    rax
    strStartsWith_end:

    %undef  param_str
    %undef  param_key
    popAll
    leave
    ret     16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro  strCat  3
    %define param_first         r8
    %define param_second        r9
    %define local_first_size    r10
    %define local_second_size   r11
    %define local_result        r12
    pushAll

    mov     r8,     %1
    mov     r9,     %2

    mov     rsi,    param_first
    strlen  rsi,    local_first_size

    mov     rsi,    param_second
    strlen  rsi,    local_second_size
    mov     rax,    local_second_size
    add     rax,    local_first_size
    inc     rax
    malloc  rax,    rax
    mov     local_result,       rax
    
    mov     rdi,    local_result
    mov     rsi,    param_first
    mov     rbx,    local_first_size
    strCpy  rdi,    rsi,    rbx


    mov     rdi,    local_result
    add     rdi,    local_first_size
    mov     rsi,    param_second
    mov     rbx,    local_second_size
    strCpy  rdi,    rsi,    rbx
    mov     rax,    local_result
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    popAll
    mov     %3,    rax
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nextLineFunc:
    mov     rsi,    r8
    strlen  rsi,    rcx
    dec     rcx
    cmp     rcx,    -1
    cmove   rax,    rcx
    je      nextLineFunc_end

    strCharFind rsi,    10, rbx
    cmp     rbx,    -1
    je      nextLineFunc_grabTheRest
    substr  rsi,    0,  rbx,    rax
    jmp     nextLineFunc_end

    nextLineFunc_grabTheRest:
        strlen  rsi,    rcx
        substr  rsi,    0,  rcx,    rax
        jmp     nextLineFunc_end

    nextLineFunc_end:
        ret

%macro nextLine 2
    ;1:buffer   2:result
    pushAll
    mov     r8, %1
    call    nextLineFunc
    popAll
    mov     %2, rax
%endmacro

%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; main DisAssembler.asm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; %include "./common/p_generals.asm"
; %include "./common/P_string_tools.asm"
; %include "./common/file-in-out.asm"
; %include "./common/p_io.asm"

section .constants
    comma                   db      ",",                0
    colon                   db      ":",                0
    str66                   db      "66",               0
    str67                   db      "67",               0
    str4                    db      "4",                0
    str100                  db      "100",              0
    str10                   db      "10",               0
    str01                   db      "01",               0
    str00                   db      "00",               0
    str000                  db      "000",              0
    str101                  db      "101",              0
    str0                    db      "0",                0
    str1                    db      "1",                0
    str11                   db      "11",               0
    str1011                 db      "1011",             0
    str0x                   db      "0x",               0
    str_or_line             db      "|",                0
    long_opcode_pref        db      "0f",               0
    hex_nums                db      "0123456789abcdef", 0
    strsh                   db      "sh",               0
    strmov                  db      "mov",              0
    strPTR                  db      "PTR",              0
    strxadd                 db      "xadd",             0
    strbsf                  db      "bsf",              0
    strbsr                  db      "bsr",              0
    strxchg                 db      "xchg",             0
    strtest                 db      "test",             0
    strimul                 db      "imul",             0



section .other
    num_sizes               dq      8,  16, 32, 64
section .dictionaries
    
    alpha_sizes             db          ",|BYTE|WORD|DWORD|QWORD|", 0
    singleCommands          db          ",f9:stc,f8:clc,fd:std,fc:cld,0f05:syscall,c3:ret,", 0
    hexBin                  db          ",0:0000,1:0001,2:0010,3:0011,4:0100,5:0101,6:0110,7:0111,8:1000,9:1001,a:1010,b:1011,c:1100,d:1101,e:1110,f:1111,", 0
    BinHex                  db          ",0000:0,0001:1,0010:2,0011:3,0100:4,0101:5,0110:6,0111:7,1000:8,1001:9,1010:a,1011:b,1100:c,1101:d,1110:e,1111:f,", 0
    regCode                 db          ",0000:|al|ax|eax|rax|,0001:|cl|cx|ecx|rcx|,0010:|dl|dx|edx|rdx|,0011:|bl|bx|ebx|rbx|,0100:|ah|sp|esp|rsp|,0101:|ch|bp|ebp|rbp|,0110:|dh|si|esi|rsi|,0111:|bh|di|edi|rdi|,1000:|r8b|r8w|r8d|r8|,1001:|r9b|r9w|r9d|r9|,1010:|r10b|r10w|r10d|r10|,1011:|r11b|r11w|r11d|r11|,1100:|r12b|r12w|r12d|r12|,1101:|r13b|r13w|r13d|r13|,1110:|r14b|r14w|r14d|r14|,1111:|r15b|r15w|r15d|r15|,", 0
                                        ; "0000:|al|ax|eax|rax|,
                                        ;  0001:|cl|cx|ecx|rcx|,
                                        ;  0010:|dl|dx|edx|rdx|,
                                        ;  0011:|bl|bx|ebx|rbx|,
                                        ;  0100:|ah|sp|esp|rsp|,
                                        ;  0101:|ch|bp|ebp|rbp|,
                                        ;  0110:|dh|si|esi|rsi|,
                                        ;  0111:|bh|di|edi|rdi|,
                                        ;  1000:|r8b|r8w|r8d|r8|,
                                        ;  1001:|r9b|r9w|r9d|r9|,
                                        ;  1010:|r10b|r10w|r10d|r10|,
                                        ;  1011:|r11b|r11w|r11d|r11|,
                                        ;  1100:|r12b|r12w|r12d|r12|, 
                                        ;  1101:|r13b|r13w|r13d|r13|,
                                        ;  1110:|r14b|r14w|r14d|r14|,
                                        ;  1111:|r15b|r15w|r15d|r15|,", 0


    scales                  db          ",00:1,01:2,10:4,11:8,", 0

    two_op_with_imm         db          ",110001:|mov|,1011:|mov|,100000:|add|adc|sub|sbb|and|or|xor|cmp|,111101:|test|,110100:|shl|shr|,110000:|shl|shr|,", 0



    two_op_no_imm           db          ",100010:|mov|,000000:|add|,000100:|adc|,001010:|sub|,000110:|sbb|,001000:|and|,000010:|or|,001100:|xor|,001110:|cmp|,", 0
                      

    one_operands            db          ",111101:|neg|not|idiv|imul|,111111:|inc|dec|push|,100011:|pop|,", 0

    regOp_codes             db          ",000:|add|pop|inc|mov|test|,010:|adc|not|,101:|sub|shr|imul|,011:|sbb|neg|,100:|and|shl|,001:|or|dec|,110:|xor|push|,111:|cmp|idiv|,", 0

    exception_opcodes       db          ",110000:|xadd|,101111:|bsf|bsr|,101011:|imul|,100001:|test|xchg|,", 0


section .bss 
    has66                   resq        1
    has67                   resq        1

    rex_enabled             resq        1
    rex_w                   resb        2
    rex_r                   resb        2
    rex_x                   resb        2
    rex_b                   resb        2

    has_long_opcode         resq        1
    opcode_code             resb        100
    opcode_DS               resb        2
    opcode_w                resb        2

    modrm_mod               resb        3
    modrm_regop             resb        4
    modrm_rm                resb        4

    sib_enabled             resq        1
    sib_scale               resb        3
    sib_index               resb        4
    sib_base                resb        4


    displacement_size       resq        1
    displacement_hex        resb        100

    data_hex                resb        50

    operation_size          resq        1
    address_size            resq        1

    has_memory              resq        1
    memory_base             resb        5
    memory_index            resb        5
    memory_scale            resb        2
    memory_displacement     resb        100

    opcode_name             resb        100

    op1buff                 resq        1
    op1type                 resq        1
    op1                     resb        100

    op2buff                 resq        1
    op2type                 resq        1
    op2                     resq        100

    final_buffer            resb        100

    temp_buf                resb        10000
    movImmExceptionReg      resb        4

    bss_size                equ         $-has66

    file_in_buff            resb        100000
    file_out_buff           resb        400000
    %define                 REGISTER    0    
    %define                 MEMORY      1
    %define                 IMMIDIATE   2

section .data
    out_file_name           db          "out.asm",  0
section .text
    global _start

initEverything:
    mov     rcx,    bss_size
    mov     rsi,    has66;  starting point
    initEverything_mainLoop:
        mov     byte[rsi],  0
        inc     rsi
        loop    initEverything_mainLoop
    mov     byte[rex_b],    '0'
    mov     byte[rex_r],    '0'
    mov     byte[rex_w],    '0'
    mov     byte[rex_x],    '0'


    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro  intersection  3
    ;1:first    2:second    3:result
    pushAll
    push2   %1, %2
    call    intersectionFunc
    popAll
    mov     %3,     rax
%endmacro
%macro  getNthStrArray 3
    ;1:arrStr   2:index     3:result
    pushAll
    mov     r8,     %1
    mov     r9,     %2

    mov     rcx,    r9
    mov     rsi,    r8
    call    getNthStrArrayLoop

    sub     rdi,    rsi
    substr  rsi,    0,  rdi,    rax
    popAll
    mov     %3,     rax
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro getRegName 3 
    ;1:regCode  2:size  3:result
    pushAll
    mov     r8,     %1
    mov     r9,     %2
    push2   regCode,    r8
    call    getDicValue 
    mov     rsi,    rax
    mov     rdx,    r9
    arr64bitFind    num_sizes,  4,  rdx,    rcx 
    getNthStrArray rsi,     rcx,    rax
    ; call    getRegCodeLoop
    ; sub     rdi,    rsi
    ; substr  rsi,    0,  rdi,    rax
    popAll
    mov     %3,     rax
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro initRex 1
    ;1:str
    pushAll
    push2   hexBin,   %1
    call    getDicValue
    mov     r8b,    [rax]
    mov     byte[rex_w],    r8b
    mov     r8b,    [rax+1]
    mov     byte[rex_r],    r8b
    mov     r8b,    [rax+2]
    mov     byte[rex_x],    r8b
    mov     r8b,    [rax+3]
    mov     byte[rex_b],    r8b
    popAll
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro initOpcode 1
    ;1:str
    pushAll
    push    %1
    call    HexToBin
    mov     rsi,    rax
    strCpy  opcode_code,    rsi,   6
    mov     r8b,    [rsi+6]
    mov     [opcode_DS],    r8b
    mov     r8b,    [rsi+7]
    mov     [opcode_w],     r8b 
    popAll
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro  initModRm 1
    ;1:str
    pushAll
    push    %1
    call    HexToBin
    mov     rsi,    rax
    strCpy  modrm_mod,  rsi,    2
    add     rsi,    2
    strCpy  modrm_regop,    rsi,    3
    add     rsi,    3
    strCpy  modrm_rm,   rsi,    3
    popAll 
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro  initSib  1
    ;1: str
    pushAll
    push    %1
    call    HexToBin
    mov     rsi,    rax
    strCpy  sib_scale,  rsi,    2
    add     rsi,    2
    strCpy  sib_index,  rsi,    3
    add     rsi,    3
    strCpy  sib_base,   rsi,    3
    mov     qword[sib_enabled], 1
    popAll
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro  initDisplacement 1
    pushAll 
    mov     rsi, %1
    strlen  rsi, qword[displacement_size]
    ; strCpy  displacement_hex,    str0x,  2
    ; lea     rdi,    [displacement_hex+2]
    strCpy  displacement_hex,   rsi,    qword[displacement_size]
    push    displacement_hex
    call    reverseHex
    popAll
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro  initData 1
    ;1: hexData
    pushAll
    mov     r8,     %1
    mov     rsi,    r8

    ; strCpy  data_hex,   str0x,  2

    strlen  rsi,    rcx
    strCpy  data_hex,   rsi,    rcx
    push    data_hex
    call    reverseHex
    popAll
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro makeRegister 2
    ;1:opbuff   2:regStr
    pushAll
    mov     r8,     %1
    mov     r9,     %2
    
    mov     rdi,    r8
    mov     qword[rdi],     1;      has this op
    add     rdi,    8

    mov     qword[rdi],     REGISTER;   is register
    add     rdi,    8

    mov     rsi,    r9
    strlen  rsi,    rcx
    strCpy  rdi,    rsi,    rcx
    popAll
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
makeMemoryFunc:
    cmp     byte[memory_base],  0
    je      makeMemory_afterBase
    strlen  memory_base,    rcx
    strCpy  rdi,    memory_base,    rcx
    add     rdi,    rcx
    
    cmp     byte[memory_index], 0
    jne     makeMemory_putPlusAfterBase
    cmp     byte[memory_displacement],  0
    jne     makeMemory_putPlusAfterBase
    jmp     makeMemory_afterBase
    makeMemory_putPlusAfterBase:
        mov     byte[rdi],  '+'
        inc     rdi
    makeMemory_afterBase:

    cmp     byte[memory_index], 0
    je      makeMemory_afterIndexScale
    strlen  memory_index,   rcx
    strCpy  rdi,    memory_index,   rcx
    add     rdi,    rcx
    mov     byte[rdi],  '*'
    inc     rdi
    mov     al,     byte[memory_scale]
    mov     byte[rdi],  al
    inc     rdi
    cmp     byte[memory_displacement],  0
    je      makeMemory_afterIndexScale
    mov     byte[rdi],  '+'
    inc     rdi
    
    makeMemory_afterIndexScale:

    cmp     byte[memory_displacement],  0
    je      makeMemory_noDisplacement
    strlen  memory_displacement,    rcx
    strCpy  rdi,    memory_displacement,    rcx
    add     rdi,    rcx

    makeMemory_noDisplacement:
        mov     byte[rdi],  0
    ret
%macro  makeMemory 1
    ;1: opbuff
    pushAll
    mov     r8,     %1
    
    mov     rdi,    r8

    mov     qword[rdi],     1;  has this op
    add     rdi,    8
    mov     qword[rdi],     MEMORY
    add     rdi,    8

    arr64bitFind    num_sizes,  4,  qword[operation_size],  rsi
    getNthStrArray  alpha_sizes,    rsi,    rsi
    strlen  rsi,    rcx
    
    strCpy  rdi,    rsi,    rcx
    add     rdi,    rcx
    
    mov     byte[rdi],  ' '
    inc     rdi

    strCpy  rdi,    strPTR, 3
    add     rdi,    3

    mov     byte[rdi],  ' '
    inc     rdi

    mov     byte[rdi],  '['
    inc     rdi

    call    makeMemoryFunc

    mov     byte[rdi],  ']'
    inc     rdi

    mov     byte[rdi],  0
    popAll
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro makeImm 1
    ;1:opbuff
    pushAll
    mov     r8,     %1

    mov     rdi,    r8
    mov     qword[rdi],     1; has this op
    add     rdi,    8
    mov     qword[rdi],     IMMIDIATE
    add     rdi,    8
    strCpy  rdi,    str0x,  2
    add     rdi,    2
    strlen  data_hex,   rcx
    strCpy  rdi,    data_hex,   rcx
    popAll
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
intersectionFunc:
    enter   0,  0
    pushAll
    mov     rsi,    [P_FUNC_PARAM_INDEX+8]
    mov     rdi,    [P_FUNC_PARAM_INDEX]
    strCharCount    rsi,    '|',    rcx
    dec     rcx
    mov     rbx,    -1
    intersection_mainLoop:
        inc     rbx
        getNthStrArray  rsi,    rbx,    rdx
        strFind     rdi,    rdx,    rax
        cmp     rax,    -1
        jne     intersection_found
        dec     rcx
        cmp     rcx,    0
        jg      intersection_mainLoop

    mov     rax,    -1
    jmp     intersection_end

    intersection_found:
        mov     rax,    rdx
    intersection_end:
    popAll
    leave
    ret     16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getDicValue: ;(dic, key) 
    enter   0,  0
    pushAll

    mov     r8,     [P_FUNC_PARAM_INDEX+8]
    mov     r9,     [P_FUNC_PARAM_INDEX]

    mov     rdi,    r9

    strCat  comma,  rdi,    rdi
    strCat  rdi,    colon,  rdi

    mov     rsi,    r8

    
    strFind rsi,     rdi,     rax
    cmp     rax,    -1
    je      getDicValue_end

    strFind rax,    colon,  rsi
    inc     rsi
    strFind rsi,    comma,  rdi
    sub     rsi,    r8
    sub     rdi,    r8
    substr  r8,     rsi,    rdi,    rax


    getDicValue_end:
        popAll
        leave
        ret     16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HexToBin: ;(hexstr)
    enter   8,  0
    %define local_result    qword[rbp-8]
    pushAll
    mov     r8,     [P_FUNC_PARAM_INDEX]
    strlen  r8,     rcx
    shl     rcx,    2
    inc     rcx
    malloc  rcx,    rdi
    dec     rcx
    mov     local_result,   rdi
    mov     rbx,    -1
    shr     rcx,    2
    HexToBin_mainLoop:
        inc     rbx
        lea     rsi,    [r8+rbx]
        substr  rsi,    0,  1,  rsi
        push2   hexBin, rsi
        call    getDicValue
        strCpy  rdi,    rax,    4
        add     rdi,    4
        dec     rcx
        cmp     rcx,    0
        ja      HexToBin_mainLoop

    popAll
    mov     rax,    local_result     
    leave
    ret     8
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BinToHex: ;(binstr)
    enter   8,  0
    pushAll
    strlen  [P_FUNC_PARAM_INDEX],   rcx
    mov     rax,    rcx
    and     rax,    3
    cmp     rax,    0
    je      BinToHex_is4xNow
    
    mov     rdi,    str000
    cmp     rax,    1
    cmove   rsi,    rdi

    mov     rdi,    str00
    cmp     rax,    2
    cmove   rsi,    rdi

    mov     rdi,    str0
    cmp     rax,    3
    cmove   rsi,    rdi

    strCat  rsi,    qword[P_FUNC_PARAM_INDEX],   qword[P_FUNC_PARAM_INDEX]


    BinToHex_is4xNow:
    
    strlen      qword[P_FUNC_PARAM_INDEX],  rcx
    shr     rcx,    2
    inc     rcx
    malloc  rcx,    qword[rbp-8]    
    dec     rcx
    mov     rsi,    qword[P_FUNC_PARAM_INDEX]
    mov     rdi,    qword[rbp-8]
    BinToHex_mainLoop:
        substr  rsi,    0,  4,  rax
        push2   BinHex, rax
        call    getDicValue
        strCpy  rdi,    rax,    1
        add     rsi,    4
        inc     rdi
        dec     rcx
        cmp     rcx,    0
        jg      BinToHex_mainLoop
    
    mov     rax,    [rbp-8]
    popAll
    leave
    ret     8
fromHex: ;(hexstr)
    enter   0,  0
    pushAll
    mov     rsi,    [P_FUNC_PARAM_INDEX]
    strlen  rsi,    rcx
    mov     rbx,    -1
    xor     r8,    r8
    fromHex_mainLoop:
        inc     rbx
        mov     al,     [rsi+rbx]
        strCharFind hex_nums,   [rsi+rbx], rax
        shl     r8,     4
        or      r8,     rax
        dec     rcx
        cmp     rcx,    0
        jg      fromHex_mainLoop

    mov     rax,    r8
    popAll
    leave
    ret     8
;;;;;;;;;;;;;;;;;;;;;
reverseHex: ;(hexstr)
    enter   0,  0
    pushAll
    mov     rsi,    [P_FUNC_PARAM_INDEX]
    strlen  rsi,    rcx
    lea     rdi,    [rsi+rcx-2]
    shr     rcx,    2
    reverseHex_mainLoop:
        mov     ax,     word[rsi]
        xchg    ax,     word[rdi]
        mov     word[rsi],  ax
        add     rsi,    2
        sub     rdi,    2
        dec     rcx
        cmp     rcx,    0
        jg      reverseHex_mainLoop
    
    mov     rdi,    [P_FUNC_PARAM_INDEX]
    strlen  rdi,    rcx
    cld
    mov     al,     '0'
    repe    scasb
    dec     rdi
    strlen  rdi,    rcx
    strCpy  [P_FUNC_PARAM_INDEX],   rdi,    rcx
    popAll
    leave
    ret     8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getNthStrArrayLoop:
    inc     rcx
    getNthStrArray_mainLoop:
        strFind rsi,    str_or_line,    rsi
        inc     rsi
        dec     rcx
        cmp     rcx,    0
        jg      getNthStrArray_mainLoop
    strFind rsi,    str_or_line,    rdi
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
parseCode: ;(8B binary)
    enter   8,  0
    %define param_code      qword[P_FUNC_PARAM_INDEX]
    %define local_strlen    qword[rbp-8]

    pushAll
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    strlen  param_code,    local_strlen

    push2   singleCommands, param_code
    call    getDicValue    
    cmp     rax,    -1
    je      parseCode_notSingleCommand
    mov     rsi,    rax
    strlen  rsi,    rcx
    strCpy  opcode_name,    rsi,    rcx
    jmp     parseCode_end

    parseCode_notSingleCommand:
    
    push2   param_code, str67
    call    strStartsWith
    cmp     rax,    0
    je      parseCode_no67
    mov     qword[has67],   1
    add     param_code, 2

    parseCode_no67:
        
    push2   param_code, str66
    call    strStartsWith
    cmp     rax,    0
    je      parseCode_no66
    mov     qword[has66],   1
    add     param_code, 2

    
    parseCode_no66:
    
    push2   param_code, str4
    call    strStartsWith
    cmp     rax,    0
    je      parseCode_noRex
    mov     qword[rex_enabled],    1
    substr  param_code, 1,  2,  rsi
    initRex rsi
    add     param_code, 2

    parseCode_noRex:

    push2   param_code, long_opcode_pref
    call    strStartsWith
    cmp     rax,    0
    je      parseCode_noLongOpcode
    mov     qword[has_long_opcode],     1
    add     param_code, 2
    
    parseCode_noLongOpcode:
        
    cmp     qword[has_long_opcode], 1
    je      parseCode_noMovImm
    mov     rsi,    param_code
    cmp     byte[rsi],  'b'
    jne     parseCode_noMovImm
    strCpy  opcode_code,    str1011, 4
    add     param_code, 1
    
    substr  param_code, 0,  1,  rsi
    inc     param_code

    push2   hexBin,   rsi
    call    getDicValue
    mov     rsi,    rax

    strCpy  opcode_w,   rsi,    1
    inc     rsi

    strCpy  movImmExceptionReg, rsi, 3

    initData    param_code
    jmp     parseCode_end

    parseCode_noMovImm:

    substr  param_code, 0,  2,  rsi
    initOpcode  rsi
    add     param_code, 2

    

    strlen  param_code, rcx
    cmp     rcx,    0
    je      parseCode_end

    substr  param_code, 0,  2,  rsi
    initModRm   rsi
    add     param_code, 2

    strlen  param_code, rcx
    cmp     rcx,    0
    je      parseCode_end

    strCmp  str100, modrm_rm,   3,  rax
    cmp     rax,    0
    je      parseCode_noSib
    
    mov     qword[has_memory],      1
    substr  param_code, 0,  2,  rsi
    initSib rsi
    add     param_code, 2

    parseCode_noSib:
        strCmp  str10,  modrm_mod,  2,  rax
        cmp     rax,    1
        je      parseCode_displacement32b
        strCmp  str00,  modrm_mod,  2,  rax
        cmp     rax,    0
        je      parseCode_noDisplacement32b
        cmp     qword[sib_enabled], 0
        je      parseCode_noDisplacement32b
        strCmp  str101, sib_base,   3,  rax
        cmp     rax,    0
        je      parseCode_noDisplacement32b

    parseCode_displacement32b:
        substr  param_code, 0,  8,  rsi
        initDisplacement    rsi
        add     param_code, 8

    parseCode_noDisplacement32b:
        strCmp  modrm_mod, str01,  2,  rax
        cmp     rax,    0
        je      parseCode_noDisplacement8b
        substr  param_code, 0,  2,  rsi
        initDisplacement    rsi
        add     param_code, 2

    parseCode_noDisplacement8b:
        strlen  param_code, rax
        cmp     rax,    0
        je      parseCode_end
        mov     rsi,    param_code
        initData    param_code

    parseCode_end:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    popAll
    %undef  param_code
    %undef  local_strlen
    leave
    ret     8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
handleMemory:
    enter   0,  0
    pushAll
    mov     rbx,    32
    mov     rax,    64
    cmp     qword[has67],   1
    cmove   rax,    rbx
    mov     [address_size], rax

    cmp     byte[sib_enabled],      0
    je      handleMemory_noSib  
    handleMemory_sib:
        strCmp  str00,  modrm_mod,  2,  rax
        cmp     rax,    0
        je      handleMemory_sib_setBase
        strCmp  str101, sib_base,   3,  rax
        cmp     rax,    0
        je      handleMemory_sib_setBase
        jmp     handleMemory_sib_endSetBase
        handleMemory_sib_setBase:
            strCat  rex_b,  sib_base,   rsi
            getRegName  rsi,    qword[address_size],    rsi
            strlen  rsi,    rcx
            strCpy  memory_base,    rsi,    rcx
        
        handleMemory_sib_endSetBase:

        strCmp  sib_index,  str100, 3,  rax
        cmp     rax,    0
        je      handleMemory_sib_setIndexScale
        cmp     qword[rex_enabled], 0
        je      handleMemory_sib_endSetIndexScale
        cmp     byte[rex_x],    '1'
        jne     handleMemory_sib_endSetIndexScale
        
        handleMemory_sib_setIndexScale:
            strCat  rex_x,  sib_index,  rsi
            getRegName  rsi,    qword[address_size],    rsi
            strlen      rsi,    rcx
            strCpy      memory_index,   rsi,    rcx
            push2       scales, sib_scale
            call    getDicValue
            mov     rdi,    rax
            mov     al, [rdi]
            mov     [memory_scale],    al

        handleMemory_sib_endSetIndexScale:

        cmp     qword[displacement_size],   0
        je      handleMemory_sib_endSetDisplacement
        push    displacement_hex
        call    fromHex
        cmp     rax,    0
        jne     handleMemory_sib_setDisplacement
        strCmp  sib_base,   str101, 3,  rax
        cmp     rax,    1
        je      handleMemory_sib_setDisplacement
        jmp     handleMemory_sib_endSetDisplacement

        handleMemory_sib_setDisplacement:
            strlen  displacement_hex,    rcx
            strCpy  memory_displacement,    str0x,  2
            strCpy  memory_displacement+2, displacement_hex,   rcx

        handleMemory_sib_endSetDisplacement:
            jmp     handleMemory_end

    handleMemory_noSib:
        strCat  rex_b,  modrm_rm,   rsi
        getRegName  rsi,    qword[address_size],    rsi
        strlen  rsi,    rcx
        strCpy  memory_base,    rsi,    rcx
        cmp     qword[displacement_hex], 0
        je      handleMemory_end
        strlen  displacement_hex,    rcx
        strCpy  memory_displacement,    str0x,  2
        strCpy  memory_displacement+2, displacement_hex,   rcx

    handleMemory_end:

    popAll
    leave
    ret     0
;;;;;;;;;;;;;;;;;;;;;;;;;
handleExceptionOpcodes:
    enter   0,  0
    pushAll
    cmp     qword[has_memory],  0
    je      handleExceptionOpcodes_noMemory

    push2   exception_opcodes,  opcode_code
    call    getDicValue
    ; mov     rsi,    
    strFind rax,    strxadd,    rax
    cmp     rax,    -1
    je      handleExceptionOpcodes_memory_noXadd
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    makeMemory  op1buff
    call    getRegisterFromRegOp
    makeRegister    op2buff,    rax
    strCpy  opcode_name,    strxadd,    4
    jmp     handleExceptionOpcodes_end

    handleExceptionOpcodes_memory_noXadd:
        call    getRegisterFromRegOp
        makeRegister    op1buff,    rax
        makeMemory      op2buff
        push2   exception_opcodes,  opcode_code
        call    getDicValue
        mov     rsi,    rax
        strFind rsi,    strbsf, rax
        cmp     rax,    -1
        jne     handleExceptionOpcodes_memory_noXadd_bsfOrBsr
        strFind rsi,    strxchg,    rax
        cmp     rax,    -1
        jne      handleExceptionOpcodes_memory_noXadd_xchg
        jmp     handleExceptionOpcodes_memory_noXadd_imul
        handleExceptionOpcodes_memory_noXadd_bsfOrBsr:
            cmp     byte[opcode_w],   '0'
            je      handleExceptionOpcodes_memory_noXadd_bsfOrBsr_bsf
            strCpy  opcode_name,    strbsr, 3
            jmp     handleExceptionOpcodes_end

            handleExceptionOpcodes_memory_noXadd_bsfOrBsr_bsf:
                strCpy  opcode_name,    strbsf, 3
                jmp     handleExceptionOpcodes_end

        handleExceptionOpcodes_memory_noXadd_xchg:
            cmp     byte[opcode_DS],    '1'
            je      handleExceptionOpcodes_memory_noXadd_xchg_isXchg
            strCpy  opcode_name,    strtest,    4
            call    switchOperands
            jmp     handleExceptionOpcodes_end
            handleExceptionOpcodes_memory_noXadd_xchg_isXchg:
                strCpy  opcode_name,    strxchg,    4
                call    switchOperands
                jmp     handleExceptionOpcodes_end

        handleExceptionOpcodes_memory_noXadd_imul:
            strCpy  opcode_name,    strimul,    4
            jmp     handleExceptionOpcodes_end


    handleExceptionOpcodes_noMemory:
        call    getRegisterFromRegOp
        mov     rsi,    rax
        call    getRegisterFromRm
        mov     rdi,    rax
        push2   exception_opcodes,  opcode_code
        call    getDicValue
        strFind rax,    strxadd,    rax
        cmp     rax,    -1
        je      handleExceptionOpcodes_noMemory_noXadd
        makeRegister    op1buff,    rdi
        makeRegister    op2buff,    rsi
        strCpy  opcode_name,    strxadd,    4
        jmp     handleExceptionOpcodes_end

        handleExceptionOpcodes_noMemory_noXadd:
            makeRegister    op2buff,    rdi
            makeRegister    op1buff,    rsi
            push2   exception_opcodes,  opcode_code
            call    getDicValue
            strFind rax,    strbsf, rax
            cmp     rax,    -1
            jne     handleExceptionOpcodes_noMemory_noXadd_bsfOrBsr
            push2   exception_opcodes,  opcode_code
            call    getDicValue
            strFind rax,    strxchg,    rax
            cmp     rax,    -1
            jne     handleExceptionOpcodes_noMemory_noXadd_xchg
            jmp     handleExceptionOpcodes_noMemory_noXadd_imul

            handleExceptionOpcodes_noMemory_noXadd_bsfOrBsr:
                cmp     byte[opcode_w],   '0'
                je      handleExceptionOpcodes_noMemory_noXadd_bsfOrBsr_bsf
                strCpy  opcode_name,    strbsr, 3
                jmp     handleExceptionOpcodes_end

                handleExceptionOpcodes_noMemory_noXadd_bsfOrBsr_bsf:
                    strCpy  opcode_name,    strbsf, 3
                    jmp     handleExceptionOpcodes_end

            handleExceptionOpcodes_noMemory_noXadd_xchg:
                cmp     byte[opcode_DS],    '1'
                je      handleExceptionOpcodes_noMemory_noXadd_xchg_isXchg
                strCpy  opcode_name,    strtest,    4
                call    switchOperands
                jmp     handleExceptionOpcodes_end
                handleExceptionOpcodes_noMemory_noXadd_xchg_isXchg:
                    strCpy  opcode_name,    strxchg,    4
                    call    switchOperands
                    jmp     handleExceptionOpcodes_end
            handleExceptionOpcodes_noMemory_noXadd_imul:
                strCpy  opcode_name,    strimul,    4
                jmp     handleExceptionOpcodes_end

    handleExceptionOpcodes_end:

    popAll
    leave
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
thereIsShift:
    enter   0,  0
    pushAll
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rbx,    0
    push2   two_op_with_imm,    opcode_code
    call    getDicValue
    cmp     rax,    -1
    cmove   rax,    rbx
    je      thereIsShift_end
    mov     rsi,    rax

    push2   regOp_codes,    modrm_regop
    call    getDicValue
    cmp     rax,    -1
    cmove   rax,    rbx
    je      thereIsShift_end
    mov     rdi,    rax

    mov     rbx,    0
    mov     rcx,    1

    intersection    rsi,    rdi,    rsi
    cmp     rsi,    -1
    cmove   rsi,    rbx
    je      thereIsShift_end
    push2   rsi,    strsh
    call    strStartsWith
    thereIsShift_end:
    mov     rbx,    0
    cmp     rax,    -1
    cmove   rax,    rbx
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    popAll
    leave
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
handleMovImm:
    enter   0,  0
    pushAll
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rax,    32
    mov     rbx,    qword[operation_size]
    cmp     qword[operation_size],  8
    cmove   rbx,  rax
    mov     qword[operation_size],  rbx

    strCpy  opcode_name,    strmov,     3
    makeImm op2buff
    mov     rsi,    opcode_code+5

    strCat  rex_b,  rsi,    rsi
    strCat  rsi,    opcode_DS,  rsi
    strCat  rsi,    opcode_w,   rsi
    getRegName  rsi,    qword[operation_size],  rsi
    strlen  rsi,    rcx
    strCpy  op1,    rsi,    rcx
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    popAll
    leave
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getRegisterFromRegOp:
    enter   0,  0
    pushAll
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    strCat  rex_r,  modrm_regop,    rsi
    getRegName  rsi,    qword[operation_size],  rax
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    popAll
    leave
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getRegisterFromRm:
    enter   0,  0
    pushAll
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    strCat  rex_b,  modrm_rm,   rsi
    getRegName  rsi,    qword[operation_size],  rax
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    popAll
    leave
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
switchOperands:
    enter   0,  0
    pushAll
    strlen  op1,    rcx
    strCpy  temp_buf,   op1,    rcx

    strlen  op2,    rdx
    strCpy  op1,    op2,    rdx

    strCpy  op2,    temp_buf,   rcx

    mov     rax,    qword[op1type]
    xchg    rax,    qword[op2type]
    mov     qword[op1type], rax
    
    popAll
    leave
    ret 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setOperationSize:
    setOperationSize_if16bOperation:   ;if
        cmp     qword[has66],    0
        je      setOperationSize_elif64bOperation
        mov     qword[operation_size],  16
        jmp     setOperationSize_endifOperationSize     


    setOperationSize_elif64bOperation:
        cmp     qword[rex_enabled],     0
        je      setOperationSize_elif8bOperation
        strCmp  rex_w,  str1,   1,  rax
        cmp     rax,    0
        je      setOperationSize_elif8bOperation
        mov     qword[operation_size],  64
        jmp     setOperationSize_endifOperationSize     


    setOperationSize_elif8bOperation:
        strCmp  str0,   opcode_w,   1,  rax
        cmp     rax,    0
        je      setOperationSize_else32bOperation
        mov     qword[operation_size],  8
        jmp     setOperationSize_endifOperationSize

    setOperationSize_else32bOperation:
        mov     qword[operation_size],  32
    
    setOperationSize_endifOperationSize:
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
disAssemble: ;(8B binary)
    enter   0,  0
    %define     param_code   qword[P_FUNC_PARAM_INDEX]
    pushAll
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call    initEverything
    mov     rsi,    param_code
    push    param_code
    call    parseCode

    push2   singleCommands, param_code
    call    getDicValue
    cmp     rax,    -1
    je      disAssemble_noSingleCommand
    jmp     disAssemble_end

    disAssemble_noSingleCommand:
    call    setOperationSize


    cmp     qword[has_long_opcode], 1
    je      disAssemble_noMovImm
    push2   opcode_code,    str1011
    call    strStartsWith
    cmp     rax,    0
    je      disAssemble_noMovImm
    
    strCpy  opcode_name,    strmov, 3
    strCat  str0,   movImmExceptionReg, rsi
    getRegName  rsi,    qword[operation_size],  rsi
    makeRegister    op1buff,    rsi
    makeImm         op2buff
    jmp     disAssemble_end

    disAssemble_noMovImm:
    
    cmp     qword[has67],   1
    je      disAssemble_ifIhereIsMemory
    strCmp  modrm_mod,  str11,  2,  rax
    cmp     rax,    0
    je      disAssemble_ifIhereIsMemory
    jmp     disAssemble_endifThereIsMemory

    disAssemble_ifIhereIsMemory:
        mov     qword[has_memory],      1
        call    handleMemory

    disAssemble_endifThereIsMemory:

    cmp     qword[has_long_opcode], 0
    je      disAssemble_endifLongOpcode
    call    handleExceptionOpcodes
    jmp     disAssemble_end

    disAssemble_endifLongOpcode:
    
    ; if self.data or self.thereIsShift():
    cmp     byte[data_hex], 0
    jne     disAssemble_ifDataOrShifts
    call    thereIsShift
    cmp     rax,    0
    jne     disAssemble_ifDataOrShifts


    ; elif self.opcode.opCode in exception_opcodes:
    push2   exception_opcodes, opcode_code
    call    getDicValue
    cmp     rax,    -1
    jne     disAssemble_elifExceptionOpcode

    mov     rbx,    1
    mov     rax,    0
    cmp     qword[has_memory],   1
    cmove   rax,    rbx
    mov     rbx,    rax
    push2   two_op_no_imm,  opcode_code
    call    getDicValue
    inc     rax;    convert -1 to 0
    and     rax,    rbx
    cmp     rax,    0
    jne     disAssemble_elifMemoryAndTwoOperand


    mov     rbx,    1
    mov     rax,    0
    cmp     qword[has_memory],   1
    cmove   rax,    rbx
    mov     rbx,    rax
    push2   one_operands,   opcode_code
    call    getDicValue
    inc     rax;    convert -1 to 0
    and     rax,    rbx
    cmp     rax,    0
    jne     disAssemble_elifMemoryAndOneOperand

    push2   two_op_no_imm,  opcode_code
    call    getDicValue
    cmp     rax,    -1
    jne     disAssemble_elifJustTwoOperand

    push2   one_operands,   opcode_code
    call    getDicValue
    cmp     rax,    -1
    jne     disAssemble_elseJustOneOperand

    mov     rax,    99999999999
    printNum    rax
    jmp     disAssemble_end

    disAssemble_ifDataOrShifts:
        substr  opcode_code,    0,  4,  rsi
        push2   two_op_with_imm,    rsi
        call    getDicValue
        cmp     rax,    -1
        je      disAssemble_ifDataOrShifts_endIfMovImm
        call    handleMovImm
        jmp     disAssemble_end
        disAssemble_ifDataOrShifts_endIfMovImm:
            push2   two_op_with_imm,    opcode_code
            call    getDicValue
            mov     rsi,    rax
            push2   regOp_codes,    modrm_regop
            call    getDicValue
            mov     rdi,    rax
            intersection    rsi,    rdi,    rsi
            strlen  rsi,    rcx
            strCpy  opcode_name,    rsi,    rcx
            cmp     qword[has_memory],  0
            je      disAssemble_ifDataOrShifts_ifNoMemory
            disAssemble_ifDataOrShifts_ifMemory:
                makeMemory  op1buff 
                makeImm op2buff

                jmp     disAssemble_end
            disAssemble_ifDataOrShifts_ifNoMemory:
                cmp     byte[opcode_code+3],    '1'
                jne     disAssemble_ifDataOrShifts_ifNoMemory_ifNoShiftOne
                push2   opcode_name,    strsh
                call    strStartsWith
                cmp     rax,    0
                je      disAssemble_ifDataOrShifts_ifNoMemory_ifNoShiftOne

                strCpy  data_hex,   str1,   1
                disAssemble_ifDataOrShifts_ifNoMemory_ifNoShiftOne:
                    call    getRegisterFromRm
                    makeRegister    op1buff,    rax
                    makeImm op2buff
        jmp     disAssemble_end


    disAssemble_elifExceptionOpcode:
        call    handleExceptionOpcodes
        jmp     disAssemble_end

    disAssemble_elifMemoryAndTwoOperand:
        call    getRegisterFromRegOp
        makeRegister    op2buff,    rax

        makeMemory  op1buff

        push2   two_op_no_imm,  opcode_code
        call    getDicValue
        mov     rsi,    rax
        getNthStrArray  rsi,    0,  rsi
        strlen  rsi,    rcx
        strCpy  opcode_name,    rsi,    rcx
        
        cmp     byte[opcode_DS],    '1'
        jne     disAssemble_end
        call    switchOperands
        jmp     disAssemble_end

    disAssemble_elifMemoryAndOneOperand:
        push2   one_operands,   opcode_code
        call    getDicValue
        mov     rsi,    rax
        push2   regOp_codes,    modrm_regop
        call    getDicValue
        mov     rdi,    rax
        intersection    rsi,    rdi,    rsi
        strlen  rsi,    rcx
        strCpy  opcode_name,    rsi,    rcx
        makeMemory  op1buff
        ; mov     qword[op1type], MEMORY
        jmp     disAssemble_end
    
    disAssemble_elifJustTwoOperand:
        push2   two_op_no_imm,  opcode_code
        call    getDicValue
        getNthStrArray  rax,    0,  rsi
        strlen  rsi,    rcx
        strCpy  opcode_name,    rsi,    rcx
        call    getRegisterFromRegOp
        makeRegister    op2buff,    rax
        call    getRegisterFromRm
        makeRegister    op1buff,    rax
        jmp     disAssemble_end

    disAssemble_elseJustOneOperand:
        push2   one_operands,   opcode_code
        call    getDicValue
        mov     rsi,    rax
        push2   regOp_codes,    modrm_regop
        call    getDicValue
        mov     rdi,    rax
        intersection    rsi,    rdi,    rsi
        strlen  rsi,    rcx
        strCpy  opcode_name,    rsi,    rcx
        call    getRegisterFromRm
        makeRegister    op1buff,    rax


    disAssemble_end:
        call    assembleAllParts
        popAll
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    %undef      param_code
    leave
    ret     8
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
assembleAllParts:
    enter   0,  0
    pushAll
    push2   opcode_name, strsh
    call    strStartsWith    
    cmp     rax,    0
    je      assembleAllParts_endifShift
    strlen  op2+2,    rcx
    strCpy  op2,    op2+2,  rcx


    assembleAllParts_endifShift:

    mov     rdi,    final_buffer

    strlen  opcode_name,    rcx
    strCpy  rdi,    opcode_name,    rcx
    add     rdi,    rcx

    mov     byte[rdi],  ' '
    inc     rdi

    cmp     qword[op1buff],     0
    je      assembleAllParts_end
    
    strlen  op1,    rcx
    strCpy  rdi,    op1,    rcx
    add     rdi,    rcx

    cmp     qword[op2buff],     0
    je      assembleAllParts_afterOp1

    mov     byte[rdi],  ','
    inc     rdi


    assembleAllParts_afterOp1:

    cmp     qword[op2buff],     0
    je      assembleAllParts_end

    strlen  op2,    rcx
    strCpy  rdi,    op2,    rcx
    add     rdi,    rcx


    assembleAllParts_end:
        mov     byte[rdi],  0

    popAll
    leave
    ret     

;;;;;;;;;;;;;;;;;;;;;;;;;;;
main:
    enter   24,  0
    pushAll
    %define local_in_fd         qword[rbp-8]
    %define local_in_filename   qword[rbp-16]
    %define local_out_fd        qword[rbp-24]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; mov     rax,    input_filename
    call    readln
    mov     local_in_filename,  rax
    mov     rdi,    rax
    call    openFile
    mov     local_in_fd,    rax
    mov     rdi,    local_in_fd
    mov     rsi,    file_in_buff
    mov     rdx,    1000000
    call    readFile

    mov     rdi,    local_in_fd
    call    closeFile

    mov     rsi,    file_in_buff    
    mov     rdi,    file_out_buff
    main_readLoop:  
        nextLine    rsi,    rbx
        cmp         rbx,    -1
        je          main_afterReadLoop
        strlen      rbx,    rcx
        lea     rsi,    [rsi+rcx+1]

        push    rbx
        call    BinToHex

        ; push    rsi
        ; mov     rsi,    rax
        ; call    printString
        ; pop     rsi

        push    rax
        call    disAssemble

        push    rsi
        mov     rsi,    final_buffer
        call    printString
        call    newLine
        pop     rsi
        
        strlen  final_buffer,   rcx
        strCpy  rdi,    final_buffer,   rcx
        add     rdi,    rcx
        mov     byte[rdi],  10
        inc     rdi

        jmp     main_readLoop

    main_afterReadLoop:
    dec     rdi
    mov     byte[rdi],  0

    mov     rdi,    out_file_name
    call    createFile
    mov     local_out_fd,   rax
    
    strlen  file_out_buff,  rdx
    mov     rdi,    local_out_fd
    mov     rsi,    file_out_buff
    call    writeFile

    mov     rdi,    local_out_fd
    call    closeFile
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    popAll
    leave
    ret         
_start:
    call    main

Exit:
	mov     rax,    60
    mov     rdi,    0
    syscall

