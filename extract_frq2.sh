#!/bin/bash

# Check if the input file was provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_vcf> <output_csv>"
    exit 1
fi

input_vcf="$1"
output_csv="$2"

# Extract the desired information and save it into the output CSV file
awk -F '\t' 'BEGIN {OFS=","; print "Chromosome","Position", "REF", "ALT", "AFR","AMR","EAS","EUR","SAS"}
    !/^#/ {
        split($8, infoFields, ";");
        for (i in infoFields) {
            split(infoFields[i], af, "=");
            if (af[1] == "AFR") afr = af[2];
            if (af[1] == "AMR") amr = af[2];
            if (af[1] == "EAS") eas = af[2];
            if (af[1] == "EUR") eur = af[2];
            if (af[1] == "SAS") sas = af[2];
        }
        print $1, $2, $4, $5, afr, amr, eas, eur, sas;
        afr = amr = eas = eur = sas = ""; # Reset for the next line
    }
' "$input_vcf" > "$output_csv"

