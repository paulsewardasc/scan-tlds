#!/usr/bin/bash
set -x
{
. ~/.bashrc
### This program getnexttld.py looks for a file called tlds.txt with Top Level Domains in and saves it's place in a file called tlds.ind ###

### You can the run this using a cron to scan a TLD every hour or day depending on the number of TLDs you have

### Change the line below to point to the folder with the files in or add the environmental variable TLDSCANDIR to .bashrc
### e.g. export TLDSCANDIR="/opt/scantlds"

cd ${TLDSCANDIR}

python3 getnexttld.py | subfinder | nuclei -es info -t http -rl 50 -c 10  -H "X-Forwarded-For: 98.97.96.95" | notify -bulk
} > /tmp/scantld.log 2>&1
