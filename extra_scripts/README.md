## extra information about fio script

### Before each experiment, 
	
		- we format the device through the script format.sh
		- old data in caches is flushed out
		- we disable swap 

### fragmentation

	- we use index.bt for tracking how often fragmentation_index gets invoked under high memory pressure
