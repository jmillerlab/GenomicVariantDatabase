import vcfpy
import sys
def vcf_to_csv(input_vcf, output_csv):
    with vcfpy.Reader.from_path(input_vcf) as vcf_reader:
        with open(output_csv, 'w') as csv_file:
            csv_file.write("chromosome;position;end;reference;alternative;category;sub_category;description\n")  # output file headers

            #Extract information from vcf
            for record in vcf_reader:
                
                chrom = record.CHROM
                pos = record.POS
                ref = record.REF
                alt = record.ALT[0].value if record.ALT else '.'

                # Set end to pos for all variants
                end = pos

                # Determine category and sub-category based on the lengths of the reference and alternative alleles
                if len(ref) > 1 or len(alt) > 1:
                    category = 'snv'
                    sub_category = 'indel'
                else:
                    category = 'snv'
                    sub_category = 'snv'
 
                info = record.INFO
                description = info.get('set', 'N/A')
 
                csv_file.write(f"{chrom};{pos};{end};{ref};{alt};{category};{sub_category};{description}\n")

if __name__ == "__main__":
    
    vcf_to_csv(sys.argv[1], sys.argv[2])
