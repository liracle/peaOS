; 操作系统启动区引导扇区代码，512个字节
; author: lixie
; date: 2020年05月02日14:18:20

section .boot  vstart=0x7c00              ; 0x7c00是BIOS加载引导扇区后的地址0x0000:0x7c00
    ; 1、初始化段寄存器
    mov ax, cs
    mov ds, ax
    mov ax, 0
    mov ss, ax
    mov sp, 0x7c00                        ; 规定0x0000~0x7c00 为引导扇区使用的栈空间

    mov ax, welcome
    mov cl, 10
    call printfMsg

deadLoop:
    hlt
    jmp deadLoop
; ------------函数：printfMsg，打印字符串，ax为字符串偏移地址，cl表示行号---------------------
printfMsg:
    ; ax 作为字符串的偏移地址 cl作为行号
    push bx
    push dx
    push si
    push di
    push es

    mov si, ax
    mov al, 160
    mul cl,
    mov di, ax
    mov bx, 0xb800
    mov es, bx
_show:
    mov al, [si]
    cmp al, 0x00
    je _show_end
    inc si
    mov [es:di], al
    inc di
    mov byte [es:di], 0x07
    inc di
    jmp _show
_show_end:
    pop es
    pop di
    pop si
    pop dx
    pop bx
    ret
; ------------函数：printfMsg end---------------------------------------------------------

welcome:
    db 'Welcome to PeaOS, This is version 0.00!', 0x0
welcomeLen:
    dw $-welcome

bootEnd:
    resb 510-($-$$)
    db 0x55, 0xaa