#!/bin/bash

local_pop_file=$1
genomes_file=$2
output_name=$3

echo -e "CHROM\tPOS\tLOCAL_REF_AF\t1000G_LOWEST_REF_AF\t1000G_HIGHEST_REF_AF" > "$output_name"

# Processing files
awk -v OFS='\t' '
FNR==1 {next} 
NR==FNR && FNR > 1 { 
    if ($1 !~ /^#/) {
        chrom[$2] = $1
        pos[$2] = $2
        split($6, allele_freqs, " ")
        split(allele_freqs[1], ref_freq, ":")
        ref_af[$2] = ref_freq[2]
    }
    next
}
FNR > 1 && $2 in chrom { 
    split($8, info, ";")
    lowest = 1
    highest = 0
    for (i in info) {
        if (info[i] ~ /^(AFR|AMR|EAS|EUR|SAS)=/) {
            split(info[i], af_info, "=")
            split(af_info[2], af_values, ",")
            sum_alt_af = 0
            for (j=1; j<=length(af_values); j++) {
                sum_alt_af += af_values[j]
            }
            ref_af_val = 1 - sum_alt_af # Calculate REF AF
            if (ref_af_val < lowest) lowest = ref_af_val
            if (ref_af_val > highest) highest = ref_af_val
        }
    }
    local_ref_af = ref_af[$2] + 0
    if (local_ref_af < lowest || local_ref_af > highest) {
        print chrom[$2], pos[$2], local_ref_af, lowest, highest >> "'$output_name'"
    }
}' "$local_pop_file" "$genomes_file"