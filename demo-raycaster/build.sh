#!/bin/sh

# defaults
project="DixVeauxMongoles.asm_player_framework"
tools="tools-macosx"
dasm="${tools}/dasm"

# optional parameter: alternative project name
if [ -n "${1}" ]; then
   project="${1}"
fi

# strip off eventual .asm extension
project="${project%.asm}"

# run assembler
echo "assemble: ${project}.asm -> ${project}.bin"
"${dasm}" ${project}.asm -f3 -o${project}.bin -s${project}.sym -l${project}.lst -p99  2>/dev/null

grep -n error ${project}.lst

# run emulator
#echo "run: ${project}.bin"
#"${stella}" ${project}.bin
