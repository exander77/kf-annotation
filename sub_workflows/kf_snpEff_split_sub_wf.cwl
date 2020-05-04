cwlVersion: v1.0
class: Workflow
id: kf_snpEff_split_sub_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_vcf: {type: File, secondaryFiles: [.tbi]}
  header_file: {type: File, doc: "File with header of VCFs. Basically a hack to avoid guessing/parsing the file"}
  reference_dict: File
  snpeff_ref_name: {type: 'string[]', doc: "List of snpEff refs to run. Loaded cache must have all that you plan to run."}
  snpeff_merge_ext: {type: 'string[]', doc: "For file naming purposes, tool name + ref names, in same order as input ref names"}
  scatter_bed: File
  scatter_ct: {type: int?, default: 50, doc: "Number of files to split scatter bed into"}
  bands: {type: int?, default: 80000000, doc: "Max bases to put in an interval. Set high for WGS, can set lower if snps only"}
  output_basename: string
  wf_tool_name: string
  snpEff_ref_tar_gz: {type: File, doc: "Pre-built snpeff cache with all refs that are to be run in wf"}
  cores: {type: int?, default: 16, doc: "Number of cores to use. May need to increase for really large inputs"}
  ram: {type: int?, default: 32, doc: "In GB. May need to increase this value depending on the size/complexity of input"}

outputs:
  snpEff_results: 
    type: 'File[]'
    outputSource: merge_snpeff_vcf/zcat_merged_vcf

steps:
  gatk_intervallisttools:
    run: ../tools/gatk_intervallisttool.cwl
    in:
      interval_list: scatter_bed
      reference_dict: reference_dict
      scatter_ct: scatter_ct
      bands: bands
    out: [output]
  bedtools_split_vcf:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.4xlarge
    run: ../tools/bedtools_split_vcf.cwl
    in:
      input_vcf: input_vcf
      input_bed_file: gatk_intervallisttools/output
    scatter: [input_bed_file]
    out: [intersected_vcf]
  run_snpeff: 
    run: ../tools/snpeff_annotate.cwl
    in:
      ref_tar_gz: snpEff_ref_tar_gz
      reference_name: snpeff_ref_name
      cores: cores
      ram: ram
      input_vcf: bedtools_split_vcf/intersected_vcf
      output_basename: output_basename
      tool_name: wf_tool_name
    scatter: [reference_name, input_vcf]
    scatterMethod: nested_crossproduct
    out: [output_vcf]
  merge_snpeff_vcf:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.2xlarge;ebs-gp2;2048
    run: ../tools/zcat_vcf.cwl
    in:
      input_vcfs: run_snpeff/output_vcf
      output_basename: output_basename
      header_file: header_file
      tool_name: snpeff_merge_ext
    scatter: [input_vcfs, tool_name]
    scatterMethod: dotproduct
    out: [zcat_merged_vcf]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 10
