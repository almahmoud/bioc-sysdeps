#!/bin/bash
# Eg run bash scripts/get_unique_deps.sh 2023-02-09-17-09 bioconductor_docker linux/amd64
# Will output 
set -xe
runtime=$1
containername=$2
arch=$3
rundir="$runtime/sysdeps/$containername/$arch"
allfile="$rundir-all"

ls $rundir > /tmp/syspkgs
echo "{}" > "$allfile"

cat << EOF > /tmp/unique.py
import json
import sys
inputfile = sys.argv[1]
allfile = sys.argv[2]
with open(inputfile, 'r') as f:
    deps = json.load(f)
with open(allfile, 'r') as f:
    alldeps = json.load(f)
alldepnames = list(alldeps.keys())
for d in deps:
    pkg = inputfile.split("/")[-1].split("-sysdeps")[0]
    name = d["shlib"]
    if name not in alldepnames:
        d["packages"] = [pkg]
        alldeps[name] = d
    else:
        alldeps[name]["packages"].append(pkg)

with open(allfile, 'w') as f:
    f.write(json.dumps(alldeps, indent=4))
EOF

cat /tmp/syspkgs | xargs -i python3 /tmp/unique.py $rundir/{} $allfile
