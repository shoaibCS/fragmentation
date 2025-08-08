device="$1"
fstype="$2"

#sudo rm -rf "/mnt/$fstype/para*"
#sudo rm -rf "/mnt/$fstype/los*"
#sudo rm -rf "/mnt/$fstype/**" 
#sudo umount "/mnt/$fstype"
#sudo umount "$device"
sudo rm -rf /mnt/x1/**
sudo umount /mnt/x1

# Format based on filesystem type
if [ "$fstype" == "ext4" ]; then
    echo "Formatting $device as ext4..."
    sudo mkfs.ext4 -F "$device"
    sudo mount "$device" /mnt/ext4
    sudo chmod 777 /mnt/ext4
else
    echo "Formatting $device as xfs..."
    sudo umount "$device" 2>/dev/null
    sudo mkfs.xfs -f -b size=32k "$device"
    sudo mount "$device" /mnt/x1
    sudo chmod 777 /mnt/x1
fi


