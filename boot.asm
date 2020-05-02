; 操作系统启动区引导扇区代码，512个字节
; author: lixie
; date: 2020年05月02日14:18:20

BOOTSTART           EQU 0x7c00                      ; 引导启动区地址
SYSLOADADDR         EQU 0x1000                      ; 操作系统内核段地址,实际地址0x10000
VRAMADDR            EQU 0Xb800                      ; 显卡内存地址
CYLS                EQU     10                      ; 声明CYLS=10

section .boot  vstart=BOOTSTART              ; 0x7c00是BIOS加载引导扇区后的地址0x0000:0x7c00
    JMP     entry
    DB      0x90
    DB      "peaOSini"      ; 启动扇区名称（8字节）
    DW      512             ; 每个扇区（sector）大小（必须512字节）
    DB      1               ; 簇（cluster）大小（必须为1个扇区）
    DW      1               ; FAT起始位置（一般为第一个扇区）
    DB      2               ; FAT个数（必须为2）
    DW      224             ; 根目录大小（一般为224项）
    DW      2880            ; 该磁盘大小（必须为2880扇区1440*1024/512）
    DB      0xf0            ; 磁盘类型（必须为0xf0）
    DW      9               ; FAT的长度（必??9扇区）
    DW      18              ; 一个磁道（track）有几个扇区（必须为18）
    DW      2               ; 磁头数（必??2）
    DD      0               ; 不使用分区，必须是0
    DD      2880            ; 重写一次磁盘大小
    DB      0,0,0x29        ; 意义不明（固定）
    DD      0xffffffff      ; （可能是）卷标号码
    DB      "peaOS img  "   ; 磁盘的名称（必须为11字?，不足填空格）
    DB      "FAT12   "      ; 磁盘格式名称（必??8字?，不足填空格）
    RESB    18              ; 先空出18字节
; 1、初始化段寄存器
entry:
    mov ax, cs
    mov ds, ax
    mov ax, 0
    mov ss, ax
    mov sp, BOOTSTART                        ; 规定0x0000~0x7c00 为引导扇区使用的栈空间

; 2、显示引导文字
    mov ax, welcome
    mov cl, 2
    call printfMsg

; 3、加载操作系统内核代码
    mov ax, SYSLOADADDR                        ; 操作系统内核地址
    mov es, ax
    mov ch, 0; 柱面0
    mov dh, 0; 磁头0
    mov cl, 2; 扇区2

readloop:
    mov si, 0; 记录失败次数
retry:
    mov ah, 0x02; ah=0x02,读取磁盘
    mov al, 50; 50个扇区
    mov bx, 0
    mov dl, 0x00; a驱动器
    int 0x13; 调用磁盘BIOS
    jnc next
    add si, 1
    cmp si, 10 ; 失败重试次数
    mov ah, 0x00
    mov dl, 0x00
    int 0x13 ; 重置磁盘
    jbe retry
    mov ax, loadErr
    mov cl, 3
    call printfMsg
    jmp deadLoop
next:
; 显示内核加载完成文字
    mov ax, loadKernel
    mov cl, 3
    call printfMsg
    mov ax, es
    mov ds, ax
    mov ax, 0
    mov cl, 4
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
    mov al, 160                            ; 默认显示模式是20*80,每个字符使用两个字节展示，因此一行为160个字节
    mul cl,
    mov di, ax
    mov bx, VRAMADDR                         ; 0xb800为现存其实地址
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
loadKernel:
    db 'load kernel done', 0x0
loadErr:
    db 'load kernel Err', 0x0

bootEnd:
    resb 510-($-$$)
    db 0x55, 0xaa
sysMsg:
    db 'This is PeaOS kernel, Hello! 50', 0x0
    times 2*80*18*512-($-sysMsg) db 0