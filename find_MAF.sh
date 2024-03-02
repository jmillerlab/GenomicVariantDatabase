#!/bin/bash

local_pop_file=$1
genomes_file=$2
output_name=$3

echo -e "CHROM\tPOS\t1000G_RARITY\tHIGHEST_MAF" > "$output_name"

# Intersecting variants on CHROM and POS
awk -v OFS=',' 'NR==FNR { local[$1 OFS $2]; next } ($1 OFS $2) in local' "$local_pop_file" "$genomes_file" > intersecting_variants.csv

# Process only intersecting variants to find rare and ultra-rare 
awk -v OFS=',' '
BEGIN { FS="\t"; OFS="," }
{
    # Initialize/reset arrays 
    delete af; af_count = 0; split("", max_afs);  

    # Extract allele frequencies for each population
    n = split($8, info, ";");
    for (i = 1; i <= n; ++i) {
        if (info[i] ~ /^(AFR|AMR|EAS|EUR|SAS)=/) {
            split(info[i], tmp, "=");
            split(tmp[2], afs, ",");
            for (j in afs) {
                af_val = afs[j] + 0;  # Convert to number
                if (af_val > 0) {  # Consider only positive AFs
                    af[++af_count] = af_val;
                }
            }
        }
    }

    # Sort and analyze the three highest AFs
    asort(af);
    top1 = (af_count >= 1) ? af[af_count] : 0;  # Safeguard against empty array
    top2 = (af_count >= 2) ? af[af_count-1] : 0;
    top3 = (af_count >= 3) ? af[af_count-2] : 0;

        highest_maf = top1;

    if (top1 < 0.01 && top2 < 0.01 && top3 < 0.01) {
        status = (top1 < 0.001 && top2 < 0.001 && top3 < 0.001) ? "ultra_rare" : "rare";
        print $1, $2, status, highest_maf;
    }
}' intersecting_variants.csv > tmp_rare_variants.csv

# Match rare and ultra-rare variants with local 
awk -F'\t' -v OFS=',' '
NR==FNR {
    # Store the rarity status of variants from the filtered 1000G data
    rarity[$1 OFS $2] = $3 " " $(NF);
    next;
}
FNR > 1 && ($1 OFS $2) in rarity {
    split($6, allele_freqs, " ");
    split(allele_freqs[2], alt_freq, ":");
    print $1, $2, alt_freq[2], rarity[$1 OFS $2];
}
' tmp_rare_variants.csv "$local_pop_file" >> "$output_name"

rm intersecting_variants.csv  tmp_rare_variants.csv

echo "Analysis completed. Results saved to $output_name."