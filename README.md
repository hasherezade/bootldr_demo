# bootldr_demo
--
compile
-
<pre>
nasm [filename].asm -f bin -o [filename].bin
</pre>
run
-
1) With <b>bochs</b></br>
Install: bochs, bochs-x </br>
Make file bochsrc.txt in a folder with a compiled binary. Sample file content:</br>
<pre>
megs: 32
romimage: file=/usr/share/bochs/BIOS-bochs-latest, address=0xfffe0000
vgaromimage: file=/usr/share/bochs/VGABIOS-lgpl-latest
floppya: 1_44=[filename].bin, status=inserted
boot: a
log: bochsout.txt
mouse: enabled=0
display_library: x, options="gui_debug"
</pre>
Run bochs:</br>
<pre>
bochs
</pre>
2) With <b>qemu</b></br>
<pre>
qemu-system-i386 -drive if=floppy,index=0,format=raw,file=[filename].bin
</pre>
3) <b>From a flash disk</b></br>
Copy to flash disk (as root)
example if the flash disk is /dev/sdb:
<pre>
dd if=[filename].bin of=/dev/sdb bs=512 count=1
</pre>
4) <b>From ISO</b></br>
- make a folder where you want to store the ISO content, i.e. 'cdcontent'
- make inside a folder 'boot'
- copy your bootloader as: cdcontent/boot/loader.sys
- make the ISO image by given commands:

<pre>
# this example requires: xorriso
# alternatives:
# prog="mkisofs"
# prog="genisoimage"

prog="xorriso -as mkisofs"
$prog -R -J -c boot/bootcat \
      -b boot/loader.sys -no-emul-boot -boot-load-size 1 \
      -o ./bootable.iso ./cdcontent
</pre>
