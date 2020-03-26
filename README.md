# kf-annotation
Variant caller annotation repository. Outputs from variant getmline and somatic callers need annotation to add context to calls

### Tools
1) [Annovar](http://annovar.openbioinformatics.org/en/latest/) 2019Oct24
2) [SnpEff](http://snpeff.sourceforge.net/) v4.3t
3) [Variant Effect Predictor](https://useast.ensembl.org/info/docs/tools/vep/index.html) v99
4) [WGS Annotator (WGSA)](https://sites.google.com/site/jpopgen/wgsa) v0.8

### Running [Annovar](https://github.com/kids-first/kf-annotation/blob/master/tools/annovar.cwl)
#### Without DBs
The Annovar tool will run without DBs if provided with a `false` value for `run_dbs`. 
#### With DBs
The Annovar tool will run the additional databases if provided with a `true` value for `run_dbs`.
The databases that will be run are the following:
- `dbnsfp35c`
- `clinvar_20190305`
- `dbscsnv11`
- `cosmic90_coding`
- `1000g2015aug_all`
- `esp6500siv2_all`
- `exac03`
- `gnomad30_genome`

Each of these databases must be provided in the `additional_dbs` file list input.

### Running SnpEff
#### [Without DBs](https://github.com/kids-first/kf-annotation/blob/master/tools/snpeff_annotate.cwl)
The SnpEff tool itself does not run with any databases. Simply provide the tool with a `ref_tar_gz` and choose the `reference_name`, either `hg38` or `GRCh38.86`.
#### [With DBs](https://github.com/kids-first/kf-annotation/blob/master/workflows/snpeff_snpsift.cwl)
To run SnpEff with additional databases, use the workflow that post processses the output of SnpEff with SnpSift.
Running this tool requires the same `ref_tar_gz` that you would normally hand to SnpEff along with a desired `reference_name`.
Moreover, you need to provide the additional databases as three sets of inputs:
1) `gwas_cat_db_file` This tab separated text file will be run in using a `SnpSift gwasCat` command.
2) `dbnsfp_db_file` This text file and associated tabix will be run using a `SnpSift dbnsfp` command.
3) `vcf_db_files`, `vcf_db_names`, and `vcf_fields`: This file list and two string lists will be dotproduct scattered and run using a `SnpSift annotate` command. The `vcf_db_files` is a list of VCF or otherwise `SnpSift annotate`-compatible files; the `vcf_db_name` is the corresponding simplified name for the files, and `vcf_fields` defines which info fields from the VCF file you wish to use to annotate your input. Here's what an example group of lists would look like:

| vcf_db_files                                                   | vcf_db_names | vcf_fields                  |
|----------------------------------------------------------------|--------------|-----------------------------|
| 1kg-ALL.wgs.mergedSV.v8.20130502.svs.genotypes.vcf.gz          | 1000genomes  | AF_fin,AN_asj,AF_oth_female |
| COSMICv90-CosmicCodingMuts.vcf.gz                              | cosmic       | CDA,dbSNPBuildID,NSF        |
| ESP6500SI-V2-SSA137.GRCh38-liftover.all_chr.snps_indels.vcf.gz | esp          | AC_MALE,ESP_AC              |
| ExAC.r1.sites.vep.vcf.gz                                       | exac         | AF_AMR,AF_ALSPAC            |
| UK10K_COHORT.20160215.sites.vcf.gz                             | uk10k        | SNP,GENE,CDS                |
| clinvar-2020-03-17.vcf.gz                                      | clinvar      | CDS_SIZES,GRCh38_POSITION   |

### Running [Variant Effect Predictor](https://github.com/kids-first/kf-annotation/blob/master/tools/variant_effect_predictor99.cwl)
#### Without DBs
To run VEP without additional DBs, simply set `run_cache_dbs` to `false` and do not provide the following inputs:
- `cadd_indels`
- `cadd_snvs`
- `dbnsfp`
- `dbscsnv`
- `phylop`
#### With DBs
As many or as few extra databases you provide will be used in annotation; additionally, make sure to set `run_cache_dbs` to `true` as this will add the additional annotations from databases that come with the cache.. All extra databases but phylop are used as plugins. The creation of these files is detailed in the documentation for the plugins on the VEP github.
