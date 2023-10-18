#!/usr/bin/bash
RUNNING="/tmp/scantld.pid"
if [ -f "$RUNNING" ]
then
  exit
fi
set -x
{
date > $RUNNING
. ~/.bashrc
### This program getnexttld.py looks for a file called tlds.txt with Top Level Domains in and saves it's place in a file called tlds.ind ###

### You can the run this using a cron to scan a TLD every hour or day depending on the number of TLDs you have

### Change the line below to point to the folder with the files in or add the environmental variable TLDSCANDIR to .bashrc
### e.g. export TLDSCANDIR="/opt/scantlds"

cd ${TLDSCANDIR}

OUTPUT=$(mktemp output-XXXXXX)
SUBS=$(mktemp subs-XXXXXX)
# Check if the argument is empty.
if [[ -z $1 ]]; then
  python3 getnexttld.py | subfinder -o $SUBS
else
  ARG1=$1
fi
if [[ "$ARG1" == "NOINC" ]]; then
  python3 getnexttld.py NOINC | subfinder -o $SUBS
else
  echo $ARG1 | subfinder -o $SUBS
fi

cat $SUBS | nuclei -es info -rl 50 -c 10 -H "X-Forwarded-For: 10.255.255.254" -ts -silent -o $OUTPUT
if [[ $(wc -l < $OUTPUT) -ge 1 ]]; then
  SLACK_API_TOKEN=$(cat /home/paul/.config/notify/provider-config.yaml | grep "slack_webhook_url" | awk '{print $2}' | perl -pe "s{\"}{}g;s{.*services/(.*)}{\1}")
  export SLACK_API_TOKEN
  ./send_to_slack
  cat $OUTPUT | awk 'BEGIN {print "SCAN Summary\r"} {print $0}' | perl -pe 's{\n}{\r}gsx' | notify -p discord -bulk -cl 10000
  DTE=$(date +%Y%m%d%H%M%S)
  cat $OUTPUT > results/$DTE.txt
  
  SITES=$(cat $OUTPUT | perl -pe "s{.*?https?://(.*?)/.*}{\1}" | sort -u)
  #for i in $SITES; do
  #  echo $i | nuclei -rl 50 -c 10 -H "X-Forwarded-For: 10.255.255.255" | notify -bulk -cl 10000
  #done
fi
rm $OUTPUT
rm $SUBS
rm $RUNNING
} > /tmp/scantld.log 2>&1
