# Run following command to create the graph

    - python3 bw.py --bandwidth-col 3 ./seq_4 ./seq_16 --output-prefix bw_graph 
    - seq_4 and seq_16 are the summary files that get generated when we run ../extra_scripts/run_fio.sh. 
    - 4th column of these summmary files is bandwidth. That is why "--bandwidth-col 3" flag is provided to python script
    - bw_graph.png in this directory is the graph that gets produced at the end


