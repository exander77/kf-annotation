cwlVersion: v1.0
class: CommandLineTool
id: bcftools_strip_info
doc: "Quick tool to strip info from vcf file before re-annotation"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 8000
    coresMin: 4
  - class: DockerRequirement
    dockerPull: 'kfdrc/vcfutils:latest'

baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eo pipefail

      if [ -z $(inputs.strip_info) ]
      then
        echo "No strip value given, returning input";
        ln -s $(inputs.input_vcf.path) .;
        ln -s $(inputs.input_vcf.secondaryFiles[0].path) .;
      else
        bcftools annotate -x $(inputs.strip_info) $(inputs.input_vcf.path) -O z 
        -o $(inputs.output_basename).$(inputs.tool_name).INFO_stripped.vcf.gz;
        tabix $(inputs.output_basename).$(inputs.tool_name).INFO_stripped.vcf.gz
      fi

inputs:
    input_vcf: {type: File, secondaryFiles: ['.tbi']}
    output_basename: string
    tool_name: string
    strip_info: {type: ['null', string], doc: "If given, remove previous annotation information based on INFO file, i.e. to strip VEP info, use INFO/ANN"}

outputs:
  stripped_vcf:
    type: File
    outputBinding:
      glob: '*.INFO_stripped.vcf.gz'
    secondaryFiles: ['.tbi']
