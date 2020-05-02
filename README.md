# peaOS自制操作系统

## day01
1、能进入引导界面和显示引导文字
新增boot.asm, README.md, .gitignore文件， 启动引导源码文件boot.asm
编译和执行命令：
`nasm -dimg boot.asm -o boot.im`

`qemu-system-i386  boot.img`