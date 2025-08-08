#!/bin/bash
# Huaicheng Li <huaicheng@cs.uchicago.edu>
# Run FEMU with no SSD emulation logic, (e.g., for SCM/Optane emulation)

# Image directory
IMGDIR=/home/shoaib.asif/images
# Virtual machine disk image
OSIMGF=$IMGDIR/u20s2.qcow2


if [[ ! -e "$OSIMGF" ]]; then
	echo ""
	echo "VM disk image couldn't be found ..."
	echo "Please prepare a usable VM image and place it as $OSIMGF"
	echo "Once VM disk image is ready, please rerun this script again"
	echo ""
	exit
fi
#cat /proc/sys/vm/dirty_ratio
#    -drive file=/mnt/ramdisk/nvme_backing_store.img,if=none,id=ramdisk \
 #   -device nvme,serial=deadbeef,id=nvme1,drive=ramdisk \

##

sudo ./qemu-system-x86_64 \
    -name "FEMU-NoSSD-VM" \
    -enable-kvm \
    -cpu host \
    -smp 50 \
    -m 50G \
    -device virtio-scsi-pci,id=scsi0 \
    -device scsi-hd,drive=hd0 \
    -device vfio-pci,host=bd:00.0 \
    -drive file=$OSIMGF,if=none,aio=native,cache=none,format=qcow2,id=hd0 \
    -device femu,devsz_mb=4096,id=nvme0 \
    -net user,hostfwd=tcp::8080-:22 \
    -net nic,model=virtio \
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no,vhost=on,queues=8 \
    -device virtio-net-pci,netdev=net0,mq=on,addr=07.0 \
    -nographic \
    -qmp unix:./qmp-sock,server,nowait
