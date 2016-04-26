if [ -z $1 ]; then
    echo "Give a name of input file"
    exit 1
fi

nasm -f bin $1.asm -o $1.bin

