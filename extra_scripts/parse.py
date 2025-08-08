import re
import sys

def average_extents_from_ext4_log(filename):
    pattern = re.compile(r':\s+(\d+)\s+extents\s+found')
    total_extents = 0
    file_count = 0

    with open(filename, 'r') as f:
        for line in f:
            match = pattern.search(line)
            if match:
                extents = int(match.group(1))
                total_extents += extents
                file_count += 1

    if file_count == 0:
        return 0

    return total_extents / file_count

def compute_avg_extents(log_file):
    with open(log_file, 'r') as f:
        content = f.read()

    # Find all nextents values using regex
    extents = [int(match) for match in re.findall(r'fsxattr\.nextents\s*=\s*(\d+)', content)]

    if not extents:
        print("No 'fsxattr.nextents' entries found in the log, ",log_file)
        return

    avg_extents = sum(extents) / len(extents)
#    print(f"Total files: {len(extents)}")
    return avg_extents

def parse_fio_output(file_path):
    try:
        with open(file_path, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        sys.exit(1)

    result = {}

    # Extract Bandwidth (MiB/s)
    bw_match = re.search(r'WRITE: bw=([\d.]+)MiB/s', content)
    if bw_match:
        result['bw_mib_per_s'] = float(bw_match.group(1))

    # Extract IOPS
    iops_match = re.search(r'write: IOPS=([\d.kM]+)', content)
    if iops_match:
        iops_str = iops_match.group(1)
        if 'k' in iops_str:
            result['iops'] = float(iops_str.replace('k', '')) * 1e3
        elif 'M' in iops_str:
            result['iops'] = float(iops_str.replace('M', '')) * 1e6
        else:
            result['iops'] = float(iops_str)

    # Extract average latency (convert from nsec to usec)
    lat_avg_match = re.search(r' lat \(nsec\):.*?avg=([\d.]+)', content)
#    print("lat_avg_match: ",lat_avg_match," for log file ",file_path)

    if lat_avg_match:
        result['latency_avg_usec'] = float(lat_avg_match.group(1)) / 1000.0
    else:
        lat_avg_match = re.search(r' lat \(usec\):.*?avg=([\d.]+)', content)
        if lat_avg_match:
            result['latency_avg_usec'] = float(lat_avg_match.group(1)) / 1.0
            pass
        pass

    

#   else:
  #      lat_avg_match = re.search(r' lat \(usec\):.*?avg=([\d.]+)', content
#        if lat_avg_match:
 #           result['latency_avg_usec'] = float(lat_avg_match.group(1)) / 1.0
#    print("lat_avg_match: ",lat_avg_match," for log file ",file_path)
    return result


if __name__ == "__main__":
    if len(sys.argv) != 11:
        print("Usage: python parse_fio_output.py <fio_output_file>")
        sys.exit(1)

    filename = sys.argv[1]
    metrics = parse_fio_output(filename)

    print("Extracted FIO Metrics:")
    vals=[]
    vals.append(sys.argv[5])
    vals.append(sys.argv[6])
    vals.append(sys.argv[7])
    vals.append(str(metrics['bw_mib_per_s']))
    vals.append(sys.argv[9])
    vals.append(sys.argv[10])


    for key, value in metrics.items():
#        print(f"{value:.2f} ")
#        vals.append(str(f"{value:.2f}"))
        pass

    if(sys.argv[7]=="xfs"):
        #one = compute_avg_extents(sys.argv[2])
    #    two = compute_avg_extents(sys.argv[3])
     #   three = compute_avg_extents(sys.argv[4])
      #  vals.append(one)
       # vals.append(two)
#        vals.append(three)
        pass

#        print(one," ",two," ",three)

 #       for term in vals:
  #          print(term," ",)

            
#        print(" ".join(str(v) for v in vals))
        filename_log= "./"+sys.argv[8]+"/summary"
        line = " ".join(str(v) for v in vals) + "\r\n"
        with open(filename_log, "a") as f: 
            f.write(line)

    if(sys.argv[7]=="ext4"):
        one = average_extents_from_ext4_log(sys.argv[2])
        two = average_extents_from_ext4_log(sys.argv[3])
        three = average_extents_from_ext4_log(sys.argv[4])
        vals.append(one)
        vals.append(two)
        vals.append(three)

  #      print(one," ",two," ",three)

#        for term in vals:
 #           print(term," ",)

            
#        print(" ".join(str(v) for v in vals))
#        line = " ".join(str(v) for v in vals) + " "+ + "\r\n" 
        filename_log= "./"+sys.argv[8]+"/summary"
        line = " ".join(str(v) for v in vals) + "\r\n"
        with open(filename_log, "a") as f:
            f.write(line)



#average_extents_from_ext4_log
        print("***********************")
