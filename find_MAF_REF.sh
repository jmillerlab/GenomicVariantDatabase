#!/bin/bash

local_pop_file="$1"
genomes_file="$2"
output_name="$3"

echo -e "CHROM\tPOS\t1000G_RARITY\tHIGHEST_REF" > "$output_name"

awk 'NR==FNR { local[$1 OFS $2]; next } ($1 OFS $2) in local' "$local_pop_file" "$genomes_file" > intersecting_variants.txt

# Process only intersecting variants to find rare and ultra-rare 
awk -v OFS='\t' '
BEGIN { FS="\t" }
{
    highestRefAF = 0

    # Extract allele frequencies and calculate REF AF for each population
    split($8, info, ";")
    for (i in info) {
        if (info[i] ~ /^(AFR|AMR|EAS|EUR|SAS)=/) {
            split(info[i], af_info, "=")
            split(af_info[2], af_values, ",")

            # Calculate REF AF as 1 - sum of all ALT AFs
            sumAltAF = 0
            for (j = 1; j <= length(af_values); j++) {
                sumAltAF += af_values[j]
            }
            refAF = 1 - sumAltAF

            # Update the highest REF AF if the current one is higher
            if (refAF > highestRefAF) {
                highestRefAF = refAF
            }
        }
    }

    rarity = highestRefAF < 0.01 ? (highestRefAF < 0.001 ? "ultra_rare" : "rare") : "common"

    if (rarity != "common") {
        print $1, $2, rarity, highestRefAF
    }
}' intersecting_variants.txt >> "$output_name"

rm intersecting_variants.txt

echo "Analysis completed. Results saved to $output_name."