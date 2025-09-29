#!/bin/bash
buddy_pct_normal() {
  awk '
    # Pull in only "Normal" lines, sum pages per order
    $3=="zone" && $4=="Normal" {
      for (i = 5; i <= 15; i++) pages[i-5] += $i    # orders 0‑10
    }
    END {
      bytes_per_block = 4096                        # order‑0 = 4 KiB
      for (o = 0; o <= 10; o++) {
        order_bytes[o] = pages[o] * bytes_per_block
        total        += order_bytes[o]
        bytes_per_block *= 2                       # double each order
      }

      # 1) print percentage share for each order
      for (o = 0; o <= 10; o++) {
        pct = total ? order_bytes[o] * 100 / total : 0
        printf(o ? " %.2f" : "%.2f", pct)
      }

      # 2) total free GiB (÷1 placeholder)
      gib = total / (1024 * 1024 * 1024) / 1        # replace 1 → 50 later
      printf " %.2f\n", gib
    }' /proc/buddyinfo
}
# Script to benchmark ZNS based SSDs
analyze_fragments() {
    local fs_type="$1"
    local dir="/mnt/$fs_type"

    if [[ ! -d "$dir" ]]; then
        echo "Error: '$dir' is not a valid directory."
        return 1
    fi

    for file in "$dir"/*; do
        if [[ -f "$file" ]]; then
            if [[ "$fs_type" == "ext4" ]]; then
                filefrag "$file"
            elif [[ "$fs_type" == "xfs" ]]; then
                xfs_io -c "stat" "$file"
            else
                echo "Unsupported filesystem type: $fs_type"
                return 1
            fi
        fi
    done
}

psi_monitor() {
  while true; do
#    sudo rm -rf ./kpageflags  
 #   sudo cp /proc/kpageflags ./
  #  python3 free_mem_frag.py >> "$1-frag"
    buddy_pct_normal  >> "$1-frag"
   # sudo rm -rf ./kpageflags 
    echo " " >> "$1-frag" 
    sleep 1
    
    
    
  done
}

#psi_monitor() {
 # while true; do
  #  cat /proc/pressure/memory >> "$1-psi"
   # echo " " >> "$1-psi" 
    #sleep 10
    
    
    
 # done
#}



vmstat_monitor() {
  while true; do
	  grep -E '^(pgsteal_kswapd|pgsteal_direct|pgsteal_file)' /proc/vmstat | awk '{print $2}' | paste -sd '\t' - >> "$1-vmstat"
    echo " " >> "$1-vmstat" 
    sleep 1
    
    
    
  done
}







# Run only as root user
if [[ $EUID -ne 0 ]]; then
    echo "Please run the script with sudo!"
    exit
fi

CUR_TS=$(date '+%Y-%m-%d-%H-%M-%S')

# Change variables accordingly 
DEVICE=/dev/nvme0n1p1
EXP_NAME=parallel-wb-fragment-gptj-20-fiojobs_50_core-50G-20-DR_1_gptj_two_linux_direct_xfs_new_metric_32k
BS=64k

echo "Running benchmark on $DEVICE"
sleep 3

# Sequential Write params
NUM_JOBS=1
NUM_OPEN_ZONES=1
NUM_OPEN_ZONES_PER_JOB=1
W_RAMP_TIME=60
SIZE=100%

# Random read params
R_RAMP_TIME=30
READ_RUNTIME=120
MAX_IODEPTH=2
ZONE_OFFSET="1024k"
ZONE_SIZE="10z"
#BS_READ_LIST=(4k 16k 64k 256k 1024K)  # List of block sizes
BS_READ_LIST=(1024k 256k 128k 64k 32k 16k 8k 4k)
IO_DEPTH_LIST=(1 4 16 1024)
#IO_DEPTH_LIST=(6 12 24 50)
NUM_JOBS_READ=1
#BS_READ_LIST=(600k)
#BS_READ_LIST=(4k 16k 64k 256k 512k 1024K)

# Directory to store all the logs
CUR_DIR=$CUR_TS-$EXP_NAME
mkdir $CUR_DIR

startTime=$(date '+%s')
echo "Start time: $(date)"


REPS=5
FS="xfs"

# Example values (you can modify as needed)
#BS_READ_LIST=("4k" "8k")
#MAX_IODEPTH=4
#CUR_DIR="/home/femu/results"
#EXP_NAME="benchmark"
#startTime=$(date '+%s')

# Read benchmark for SSD
for ((rep = 1; rep <= REPS; rep++)); do
    for BS_READ in "${BS_READ_LIST[@]}"; do
        for i in "${IO_DEPTH_LIST[@]}"; do

            name="$CUR_DIR/${BS_READ}-${i}-qd-${rep}-rep-write.txt"

            # Format the device
            sudo bash format.sh "$DEVICE" "$FS"
#	    sudo rm -rf /mnt/x1/data
#	    mkdir /mnt/x1/data
	    sudo sh -c "echo 3 > /proc/sys/vm/drop_caches";
	    sudo swapoff /swap.img 

            # Fio command as one line
            cmd="taskset -c 29-49 /home/femu/fio/fio --name=$EXP_NAME --directory=/mnt/x1 --bs=$BS_READ --iodepth=$i --rw=randwrite --ioengine=io_uring --numjobs=20 --size=30G --direct=0 --group_reporting &> $name"
#tee $name"	
            echo "Executing command: $cmd"
	    echo "/mnt/x1" >> "$name-config"
	    xfs_info /mnt/x1 >> "$name-config" 
	    echo "-----------------------"  >> "$name-config" 
	    echo "/mnt/x2" >> "$name-config" 
	    xfs_info /mnt/x2 >> "$name-config" 
	    echo "-----------------------"  >> "$name-config"
	    echo "/mnt/x3" >> "$name-config" 

	    xfs_info /mnt/x3 >> "$name-config" 
	    echo "-----------------------"  >> "$name-config"
	    free -g >> "$name-config"
	    echo "-----------------------"  >> "$name-config"
	    nproc >> "$name-config"
	    echo "-----------------------"  >> "$name-config"
#	    sudo bpftrace aa.bt  &>> "$name-config"
	    echo "-----------------------"  >> "$name-config"
	    df -Th  >> "$name-config" 
	    echo "-----------------------"  >> "$name-config"
	    echo "DIRTY RATIO "  >> "$name-config" 
	    cat /proc/sys/vm/dirty_ratio  >> "$name-config" 
	    echo "-----------------------"  >> "$name-config" 
	    cat /proc/swaps >> "$name-config"
	    echo "-----------------------"  >> "$name-config" 
	    free -g >> "$name-config" 
	    echo "-----------------------"  >> "$name-config"




	    pkill -f bpftrace
#	    pkill -f fio
	    sudo bpftrace index.bt >> "$name-trace" 2>&1 &
	    trace_pid=$!
	    echo "Name: $name"
	    psi_monitor $name &
	    psi_pid=$!
	    vmstat_monitor $name &
	    vmstat_pid=$!
	    sleep 30
	    eval "$cmd"
	    echo "$name"
	    echo "$cmd" >> $name
	    echo "----------------------- parallel wb">> "$name-config" 
	    kill -9 $trace_pid
	    kill -9 $psi_pid
	    kill -9 $vmstat_pid
#	    sudo bpftrace aa.bt  &>> "$name-config"
	    pkill -f bpftrace

	   
	    #analyze_fragments $FS > "$name-0s"
	    ls > "$name-0s"
#	    sleep 30

#	    analyze_fragments $FS > "$name-30s"
#	    sudo umount "$DEVICE"  
	    ls  > "$name-30s" 
#	    sudo mount "$DEVICE" /mnt/$FS 
#	    sudo chmod 777 /mnt/$FS
#	    analyze_fragments $FS > "$name-post_mount" 
	    ls >  "$name-post_mount" 
	    frag_count=$(cat "$name-trace" | grep index | grep -v "index: -1000" | wc -l)
	    low_mem_count=$(cat "$name-trace" | grep index | grep "index: -1000" | wc -l)

#	    echo "/mnt/x1" >> "$name-config"
#	    xfs_info /mnt/x1 >> "$name-config" 
#	    echo "-----------------------"  >> "$name-config" 
#	    echo "/mnt/x2" >> "$name-config" 
#	    xfs_info /mnt/x2 >> "$name-config" 
#	    echo "-----------------------"  >> "$name-config"
#	    echo "/mnt/x3" >> "$name-config" 

#	    xfs_info /mnt/x3 >> "$name-config" 
#	    echo "-----------------------"  >> "$name-config"
#	    free -g >> "$name-config"
#	    echo "-----------------------"  >> "$name-config"
#	    nproc >> "$name-config"
#	    echo "-----------------------"  >> "$name-config"
#	    sudo bpftrace aa.bt  &>> "$name-config"
#	    echo "-----------------------"  >> "$name-config"
#	    df -Th  >> "$name-config" 
#	    echo "-----------------------"  >> "$name-config"
#	    echo "DIRTY RATIO "  >> "$name-config" 
#	    cat /proc/sys/vm/dirty_ratio  >> "$name-config" 
#	    echo "-----------------------"  >> "$name-config" 





            if [[ "$FS" == "ext4" ]]; then
                echo "----------------------------------------------------------------"
		python3 parse.py $name "$name-0s" "$name-30s" "$name-post_mount" ${BS_READ} ${i} ${FS} "$CUR_DIR"
            elif [[ "$FS" == "xfs" ]]; then
  #              python3 get_exfs_extents.py "$name-0s" "$name-30s" "$name-post_mount" >>abcde
	        python3 parse.py $name "$name-0s" "$name-30s" "$name-post_mount" ${BS_READ} ${i} ${FS} "$CUR_DIR" $frag_count $low_mem_count
			
            else
                echo "Unsupported filesystem type for parsing: $FS"
                
            fi


        done
    done
done

endTime=$(date '+%s')
diffSeconds=$((endTime - startTime))
diffTime=$(printf '%02d:%02d:%02d' $((diffSeconds/3600)) $(( (diffSeconds%3600)/60 )) $((diffSeconds%60)))

echo "End time: $(date)"
echo "Total time(H:M:S): $diffTime"
