#!/bin/bash

local_pop_file="$1"
genomes_file="$2"
output_name="$3"

echo -e "CHROM\tPOS" > "$output_name"

awk -v OFS=',' '{print $1, $2}' "$local_pop_file" | sort -u > tmp_local_chrom_pos.csv
awk -v OFS=',' '{if (NR>1) print $1, $2}' "$genomes_file" | sort -u > tmp_1000g_chrom_pos.csv

# Find variants in local file but not in 1000G file
comm -23 tmp_local_chrom_pos.csv tmp_1000g_chrom_pos.csv >> "$output_name"

rm -f tmp_local_chrom_pos.csv tmp_1000g_chrom_pos.csv

echo "Analysis completed. Variants in $local_pop_file but not in $genomes_file are saved to $output_name."
