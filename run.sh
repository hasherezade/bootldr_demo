if [ -z $1 ]; then
    echo "Give a name of input file"
    exit 1
fi

nasm -f bin $1.asm -o $1.bin
echo $?
if (( $? == 0 )); then
    qemu-system-i386 -drive index=0,format=raw,file=$1.bin
else
    echo "Compilation failed"
fi
