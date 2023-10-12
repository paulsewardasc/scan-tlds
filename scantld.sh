#!/usr/bin/bash
set -x
{
. ~/.bashrc
### This program getnexttld.py looks for a file called tlds.txt with Top Level Domains in and saves it's place in a file called tlds.ind ###

### You can the run this using a cron to scan a TLD every hour or day depending on the number of TLDs you have

### Change the line below to point to the folder with the files in or add the environmental variable TLDSCANDIR to .bashrc
### e.g. export TLDSCANDIR="/opt/scantlds"

cd ${TLDSCANDIR}

OUTPUT=$(mktemp output-XXXXXX)
SUBS=$(mktemp subs-XXXXXX)
python3 getnexttld.py | subfinder -o $SUBS
cat $SUBS | nuclei -es info -t http -rl 50 -c 10  -H "X-Forwarded-For: 10.255.255.254" -silent -o $OUTPUT
echo $i | nuclei -es info -t http -rl 50 -c 10  -H "X-Forwarded-For: 10.255.255.254" -silent -o $OUTPUT
cat $OUTPUT
if [[ $(wc -l < output.txt) -ge 1 ]]; then
  echo "Full scan"
  #nuclei -rl 50 -c 10 -H "X-Forwarded-For: 10.255.255.255" | notify -bulk
fi
done
rm $OUTPUT
rm $SUBS
} > /tmp/scantld.log 2>&1
