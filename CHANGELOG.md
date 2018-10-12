# Changelog

## Issues Addressed
### Name of executable
I renamed the executable from `cafe.out` to `seg_clus` to match the code that generates it and match the function of the script.
### Slow execution time
I attempted to speed up the execution time by profiling the seg_cus.c code with gmon and the `-g` flag when making.  This showed that much of the time was spent during the `for(k=newparentstart;k<newparentend;k+=inter){` loop.  It appeared to be recalculating the trinucleotide frequencies each execution, even though the regions it was calculating for overlapped for the majority.  I changed it to calculate all the trinucleotide frequencies the first time, but subsequent times would just update the frequency array by incrementing the counts for the new region and decrementing the counts for the lost region.  This sped up execution time on the test data from 37 minutes to less than 5 minues.

#### TODO
The indexing through the trinucleotide counts apprears to have some off-by-one and off-by-two errors.  I don't know why some of the arrays in the code appear to be 0-indexed and others appear to be 1-indexed, but learning this should allow me to correct the issues.
### Mishandling genomes with more than 1 contig
The master code would only consider the final contig due to a bug in the `gbk{}` subroutine in `cafe`.  I made the following changes:

1) Write out a `_CAFE.coords` file containing the length and names of each sequence in the genome (as well as the relative location in the combined `$dna` string.
2) Combine all sequences into single `$dna` string, separated by 1000 N's to prevent spurious detection of genomic islands.
3) After execution, the script now writes out a file that join the `.coords` file to the genomic islands file.  This rejects any GIs extending into the region of N's

#### TODO
There shoudld be a better heuristic (and code) for joining the coords file to the GIs.  Perhaps rejecting GIs that extend more than 50% into the Ns, rather than rejecting them all outright. The merging currently happens in a system call to a bash oneliner -- this should be made more robust by writing it in Perl

### Memory leak
I noticed the number 134217729.000000000 popping up when calculating the segment entropy distance.  This is from an undefined variable, which I traced with valgrind down to instances where `maxi` was not being set because the distance never exceeded the default of -999999.  This turned out to be because when continuing to segment, often the `newparentend` was _less_ than the `newparentstart`, so that the loop above could not execute, as the condition `k<newparentend` was not true. To fix, I stopped the segmentation if the `newparentend` would be  less than `newparentstart` by changing line:
```
if(smax>thres)
```
to
```
if(smax>thres && (s1_end - mmk - s1_start - mmk) > 0)
```
Valgrind confirmed that this fixed the issue.

#### TODO
Previous results shoudl be checked to see if this changes any GIs detected.

### Platform specific execution
The previous compiled code would not work on some versions of linux and MacOS.  I added a `Makefile` to aid compilation and installation.

## Issues to be Addressed
### Perl variable declaration and scope
The Perl code in `cafe` utilizes many undeclared variables.  Adding `use strict; use warnings;` to the header reveals the many issues.
