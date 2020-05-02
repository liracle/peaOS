# peaOS自制操作系统

## day01
1、能进入引导界面和显示引导文字
新增boot.asm, README.md, .gitignore文件， 启动引导源码文件boot.asm
编译和执行命令：
`nasm -dimg boot.asm -o boot.im`

`qemu-system-i386  boot.img`

2、加载系统内核程序
实模式下寻址1MB，即0x00000 ~ 0xfffff
参照实模式下内存布局图：
![参照实模式下内存布局图](http://tech.ipeapea.cn/archives/44)

使用0x10000 ~ 0x9ffff 一共 512KB空间用于加载内核

内核程序在img镜像文件中的第2扇区中
完成50个扇区的加载
3、


