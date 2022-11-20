;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; all headers just copied and pasted;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

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

; %include "./common/p_generals.asm"
%define P_FUNC_PARAM_INDEX rbp+16

; %include "./common/p_io.asm"
%ifndef P_IO
%define P_IO
; %include "./common/p_memory_tools.asm"
%ifndef P_MEMORY_TOOLS
%define P_MEMORY_TOOLS
; %include "./sys_equal.asm"
; %include "./p_generals.asm"

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

; %include "./common/P_string_tools.asm"
%ifndef P_STRING_TOOLS
%define P_STRING_TOOLS
; %include "./in_out.asm"
; %include "./p_memory_tools.asm"

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

; %include "./common/file-in-out.asm"
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; main code is from now on!;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .intConstants
    max_byte    dd  0xff

section .stringConstants
    bmp_extention       db  ".bmp", 0
    edited_photo_dir    db  "edited_photo/", 0
    splitter            db  "/", 0

    
section .bss
    pixels                  resb    10000000

    pixels_64x_pointer      resq    1
    the_n                   resq    1
    n_array                 resb    16
    
    bfSize                  resb    4
    bfOffbits               resb    4
    biSize                  resb    4
    biWidth                 resb    4
    biHeigth                resb    4
    
    allPixelsSize           resq    1
    file_header             resb    14
    image_header            resb    100
    padding_count           resq    1
    widthSize               resq    1

    headers_pixels_gap      resb    1000000
    gap_size                resq    1
    file_tail               resb    100000
    tail_size               resq    1
    current_dir_info_buff   resb    100000000
    temp_bufff              resb    10000

section .text
    global  _start


setPixelPointer:
    mov     qword[pixels_64x_pointer],    pixels
    and     qword[pixels_64x_pointer],    63
    sub     qword[pixels_64x_pointer],    63
    neg     qword[pixels_64x_pointer]
    inc     qword[pixels_64x_pointer]
    add     qword[pixels_64x_pointer],    pixels
    ret

openDir: ;(8B dirname)
    enter   0,  0
    %define param_dirname   qword[P_FUNC_PARAM_INDEX]
    push    rdi
    push    rsi

    mov     rax,    sys_open
    mov     rdi,    param_dirname
    mov     rsi,    O_DIRECTORY
    syscall
    cmp     rax,    -1
    jle     openDir_error
    mov     rsi,    suces_open_dir
    call    printString
    jmp     openDir_end

    openDir_error:
        mov     rsi,    error_open_dir
        call    printString
        
    openDir_end:
        %undef  param_dirname
        pop     rsi
        pop     rdi
        leave
        ret     8

makeDir: ;(8B dirname)
    enter   0,  0
    %define param_dirname   qword[P_FUNC_PARAM_INDEX]
    
    push    rdi
    push    rsi 

    mov     rax,    sys_mkdir
    mov     rdi,    param_dirname
    mov     rsi,    sys_makenewdir
    xor     rdx,    rdx

    syscall
    cmp     rax,    -1
    jle     makeDir_Error
    mov     rsi,    suces_create_dir
    call    printString
    jmp     makeDir_end

    makeDir_Error:
        mov     rsi,   error_create_dir
        call    printString
    makeDir_end:
        %undef  param_dirname
        pop     rsi
        pop     rdi
        leave
        ret     8

    

adjustBrightness: ;(addr: rsi)
    xor     rax,    rax
    mov     al,     byte[rsi]
    add     rax,    [the_n]
    cmp     rax,     0
    jl      adjustBrightness_setZero
    cmp     rax,    0xff
    ja      adjustBrightness_setToMaxByte
    mov     byte[rsi],  al
    ret     
    adjustBrightness_setZero:
        mov     byte[rsi],  0
        ret 
    adjustBrightness_setToMaxByte:
        mov     byte[rsi],  0xff
        ret     
    

readFileHeader: ;(8B fd)
    enter       0,  0
    %define     param_fd    qword[P_FUNC_PARAM_INDEX]
    push    rdi
    push    rsi
    push    rdx
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rdi,    param_fd
    mov     rsi,    file_header
    mov     rdx,    14
    call    readFile
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rdx
    pop     rsi
    pop     rdi
    %undef      param_fd
    leave
    ret     8

readImageHeader: ;(8B fd)
    enter       0,  0
    %define     param_fd    qword[P_FUNC_PARAM_INDEX]
    push        rdi
    push        rsi
    push        rdx
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov         rdi,    param_fd
    mov         rsi,    image_header
    mov         rdx,    4
    call        readFile
    xor         rax,    rax
    mov         eax,    [image_header] ; header size ( 4 bytes)

    mov         rdi,    param_fd
    lea         rsi,    [image_header + 4]  ; buffer
    sub         rax,    4
    mov         rdx,    rax                 ; size to read
    call        readFile
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop         rdx
    pop         rsi
    pop         rdi
    %undef      param_fd
    leave
    ret     8

; readGap:    ;(8B fd)
;     enter   0,  0
;     %define param_fd    qword[P_FUNC_PARAM_INDEX]
;     mov     eax,    [bfOffbits]
;     sub     eax,    14   
;     sub     eax,    [biSize]
;     mov     [gap_size],     eax
;     cmp     dword[gap_size],    0
;     je      readGap_end
    
;     mov     rdi,    param_fd
;     mov     rsi,    headers_pixels_gap
;     xor     rdx,    rdx
;     mov     edx,    [gap_size]
;     call    readFile
;     readGap_end:
;     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;     %undef  param_fd
;     leave
;     ret     8


initHeaderParts:
    push    rbx
    ;   fbSize
    mov     eax,            [file_header+2]
    mov     [bfSize],       eax
    ;   bfOffbits
    mov     eax,            [file_header+10]
    mov     [bfOffbits],    eax
    ;   biSize
    mov     eax,            [image_header]
    mov     [biSize],       eax
    cmp     eax,            12 ; if format is os/2
    ;   biWidth
    mov     dword[biWidth], 0
    mov     rax,            0
    cmovne  eax,            [image_header+4]
    cmove   ax,             [image_header+4]
    mov     [biWidth],      eax
    
    ;   biHeigth
    mov         dword[biHeigth], 0
    mov         rax,            0
    cmovne      eax,            [image_header+8]
    cmove       ax,             [image_header+6]
    mov         [biHeigth],     eax
    ;   widthSize
    xor     rax,    rax
    mov     eax,    [biWidth]
    mov     rbx,    3
    mul     rbx
    mov     [widthSize],    rax
    ;   padding_count
    xor         rax,    rax
    mov         eax,    [biWidth]
    mul         rbx
    and         eax,    0b11
    sub         eax,    4
    neg         eax
    mov         [padding_count],  rax

    ;   allPixelsSize
    xor     rax,    rax
    mov     eax,    [biHeigth]

    mul     dword[biWidth]
    mov     rbx,    3
    mul     rbx
    mov     [allPixelsSize],    rax

    xor     rax,    rax
    mov     eax,    [biHeigth]
    mul     qword[padding_count]
    add     [allPixelsSize],    rax
    pop     rbx
    ret


readPixels: ;(8B fd)
    enter   0,  0
    %define param_fd    qword[P_FUNC_PARAM_INDEX]
    push    rsi 
    push    rdi
    push    rdx
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    mov     rdi,    param_fd
    mov     rsi,    [pixels_64x_pointer]
    mov     rdx,    [allPixelsSize]
    inc     rdx
    call    readFile
    call    writeNum
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    %undef  param_fd
    leave
    ret     8


lightenImage: ;(8B filepath, 8B target_filename)
    enter       8,  0
    %define     param_target    qword[P_FUNC_PARAM_INDEX]
    %define     param_filpath   qword[P_FUNC_PARAM_INDEX+8]
    %define     local_fd        qword[rbp-8]
    push    rdx
    push    rdi
    push    rsi
    push    rcx
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    param_filpath
    push    bmp_extention
    call    strEndsWith
    cmp     rax,    0
    je      lightenImage_end
    
    mov     rdi,    param_filpath
    call    openFile

    mov     local_fd,   rax
    push    local_fd
    call    readFileHeader

    cmp     word[file_header],  0x4d42 ; "BM"
    jne     lightenImage_end
    
    push    local_fd
    call    readImageHeader

    call    initHeaderParts

    ; push    local_fd
    ; call    readGap

    push    local_fd
    call    readPixels

    xor     rcx,    rcx
    mov     rcx,    [allPixelsSize]; (height*width*3) + padding*heigth
    shr     rcx,    5;  // 32
    mov     rsi,    [pixels_64x_pointer]
    lightenImage_mainLoop:
        vmovdqa     ymm0,   [rsi]
        cmp         qword[the_n],    0
        jle         lightenImage_mainLoop_ifIsNegetive
        jg          lightenImage_mainLoop_ifIsPositive
        lightenImage_mainLoop_ifIsNegetive:
            vpsubusb    ymm0,   ymm1
            jmp     lightenImage_mainLoop_endifPosNeg
        lightenImage_mainLoop_ifIsPositive:
            vpaddusb     ymm0,   ymm1
            jmp     lightenImage_mainLoop_endifPosNeg
        lightenImage_mainLoop_endifPosNeg:
        
        vmovdqa     [rsi],  ymm0
        add         rsi,    32
        loop        lightenImage_mainLoop

    mov     rcx,    [allPixelsSize]
    and     rcx,    255
    lightenImage_khoordehLoop:
        call    adjustBrightness
        inc     rsi
        loop    lightenImage_khoordehLoop
    
    mov     rdi,    local_fd
    call    closeFile

    mov     rdi,    param_target
    call    createFile
    mov     local_fd,   rax

    ; write file header
    mov     rdi,    local_fd
    mov     rsi,    file_header
    xor     rdx,    rdx
    mov     edx,    14
    call    writeFile
    ; write image header
    mov     rdi,    local_fd
    mov     rsi,    image_header
    xor     rdx,    rdx
    mov     edx,    [biSize]
    call    writeFile

    lightenImage_writePixels:
    mov     rdi,    local_fd
    mov     rsi,    [pixels_64x_pointer]
    xor     rdx,    rdx,
    mov     rdx,    [allPixelsSize]
    call    writeFile

    lightenImage_end:
        mov     rdi,    local_fd
        call    closeFile
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop         rcx
    pop         rsi
    pop         rdi
    pop         rdx
    %undef      param_filpath
    leave
    ret         16

considerFile: ;(8B filename, 8B dirname)
    enter   0,  0
    %define param_filename  qword[P_FUNC_PARAM_INDEX+8]
    %define param_dirname   qword[P_FUNC_PARAM_INDEX]
    push    rdx
    push    r15
    push    r11

    push    param_dirname
    push    splitter
    call    concatString ; dir/
    mov     r15,    rax

    push    r15 
    push    param_filename
    call    concatString; dir/filename

    push    rax; param source for lightenImage

    push    r15
    push    edited_photo_dir
    call    concatString ; dir/edited_photo/

    push    rax; 
    push    param_filename
    call    concatString; dir/edited_photo/filename
    push    rax; param target for lightenImage
    call    lightenImage    

    pop     r11
    pop     r15
    pop     rdx
    %undef  param_filename
    %undef  param_dirname
    leave
    ret     16

main:
    enter   40,  0
    %define     local_dirname           qword[rbp-8]    
    %define     local_n                 qword[rbp-16]
    %define     local_edited_dir_fd     qword[rbp-24]
    %define     local_dir_fd            qword[rbp-32]
    %define     local_dir_info_limit    qword[rbp-40]
    call    setPixelPointer

    call    readln
    mov     local_dirname,    rax
    call    readNum
    mov     [the_n],    rax
    cmp     rax,    0
    jg      main_ifIsPositive
    neg     qword[the_n]
    main_ifIsPositive:
    vpbroadcastb    ymm1,           byte[the_n]
    
    mov     qword[the_n],   rax
    push    local_dirname
    call    openDir
    mov     local_dir_fd,  rax
    

    push    local_dirname
    push    splitter
    call    concatString
    push    rax
    push    edited_photo_dir
    call    concatString

    push    temp_bufff
    push    rax
    push    qword 10000
    call    PMemcpy
    push    temp_bufff
    call    makeDir
    mov     local_edited_dir_fd,   rax

    mov     rax,    217
    mov     rdi,    local_dir_fd
    mov     rsi,    current_dir_info_buff
    mov     rdx,    100000000
    syscall
    add     rax,    current_dir_info_buff
    mov     local_dir_info_limit,   rax

    xor     rdx,    rdx
    mov     r11,    current_dir_info_buff
    main_walkDir:
        add     rdx,    r11
        cmp     rdx,    local_dir_info_limit
        jge     main_endWalkDir
        xor     r11,    r11
        mov     r11w,   [rdx+16]
        mov     r12,    rdx
        add     r12,    18
        xor     r13,    r13
        mov     r13b,   [r12]
        inc     r12 
        
        push    r12
        push    r13 
        push    r11
        push    rdx
        mov     rsi,    r12
        call    printString
        pop     rdx
        pop     r11
        pop     r13 
        pop     r12

        cmp     r13,    8
        jne      main_walkDir_isNotFile
        ; is file!
        push    r12 
        push    local_dirname
        call    considerFile
        
        main_walkDir_isNotFile:

        jmp     main_walkDir
    main_endWalkDir:
    
    %undef      local_dirname
    %undef      local_n
    leave   
    ret

_start:
    call    main


Exit:
	mov     rax,    60
    mov     rdi,    0
    syscall

