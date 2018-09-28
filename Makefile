seg_clus: seg_clus.c
	# gcc -pg seg_clus.c -lm -o seg_clus # for profiling
	gcc seg_clus.c -lm -o seg_clus
