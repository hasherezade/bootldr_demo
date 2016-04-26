# this example requires: xorriso
# alternatives:
# prog="mkisofs"
# prog="genisoimage"

if [ -z $1 ]; then
    echo "Give a name of bootloader file"
    exit 1
fi

isoname="bootable.iso"
outfolder="cdcontent"
boot="boot"
bootfolder=$outfolder/$boot
bootloader=$boot/loader.sys

mkdir $outfolder
mkdir $bootfolder

cp $1 $outfolder/$bootloader
echo $bootloader

prog="xorriso -as mkisofs"
$prog -R -J -c $boot/bootcat \
      -b $bootloader -no-emul-boot -boot-load-size 1 \
      -o ./$isoname ./$outfolder
res=$?
rm -rf $outfolder
if (( $res == 0 )); then
    echo "[SUCCESS] $isoname created!"
    exit 0
fi
echo "[FAILURE] Error: $res"
exit -1
