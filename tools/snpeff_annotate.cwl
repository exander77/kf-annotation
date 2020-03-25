cwlVersion: v1.0
class: CommandLineTool
id: snpeff_annotate
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 16000
    coresMin: 8
  - class: DockerRequirement
    dockerPull: 'kfdrc/snpeff:4_3t'
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      set -eo pipefail

      tar -xzvf $(inputs.ref_tar_gz.path) -C /snpEff/
      && java -jar /snpEff/snpEff.jar
      -nodownload
      -t
      $(inputs.reference_name)
      $(inputs.input_vcf.path)
      | bgzip -c > $(inputs.output_basename).$(inputs.tool_name).snpEff.vcf.gz
      && tabix $(inputs.output_basename).$(inputs.tool_name).snpEff.vcf.gz
inputs:
  ref_tar_gz: { type: File, label: tar gzipped snpEff reference}
  input_vcf: { type: File,  secondaryFiles: [.tbi] }
  reference_name:
    type:
      type: enum
      symbols:
        - hg38
        - GRCh38.86
  output_basename: string
  tool_name: string
outputs:
  output_vcf:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
  output_tbi:
    type: File
    outputBinding:
      glob: '*.vcf.gz.tbi'
