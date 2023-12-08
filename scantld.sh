#!/usr/bin/bash
RUNNING="/tmp/scantld.pid"
if [ -f "$RUNNING" ]
then
  exit
fi
set -x
{
date > $RUNNING
. ~/.bashrc > /dev/null

# Get ARGS CUSTOMTLD, FINDSUBS, TEMPLATE

for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done



### This program getnexttld.py looks for a file called tlds.txt with Top Level Domains in and saves it's place in a file called tlds.ind ###

### You can the run this using a cron to scan a TLD every hour or day depending on the number of TLDs you have

### Change the line below to point to the folder with the files in or add the environmental variable TLDSCANDIR to .bashrc
### e.g. export TLDSCANDIR="/opt/scantlds"

cd ${TLDSCANDIR}

if ! test -f excludes.txt; then touch excludes.txt; fi

OUTPUT=$(mktemp output-XXXXXX)
SUBS=$(mktemp subs-XXXXXX)
# Check if the CUSTOMTLD exists, if not go to the next TLD in the file list
if [[ -z $CUSTOMTLD ]]; then
  TLD=$(python3 getnexttld.py)
  echo "[+] Normal run"
  echo $TLD | subfinder -o $SUBS
else
  TLD=$CUSTOMTLD
  if [[ -z $FINDSUBS ]]; then
    echo $TLD > $SUBS
  else
    echo $TLD | subfinder -o $SUBS
  fi
fi

# If $TEMPLATE has something in run that template only
if [[ -z $TEMPLATE ]]; then
  echo "custom-nuclei-templates/${SUBS}.txt"
  if [[ -f "custom-nuclei-templates/${SUBS}.txt" ]]; then
    cat $SUBS | grep -v -x -f excludes.txt | nuclei -o $OUTPUT
  else
    cat $SUBS | grep -v -x -f excludes.txt | nuclei -o $OUTPUT
  fi
else
  cat $SUBS | grep -v -x -f excludes.txt | nuclei -t $TEMPLATE -o $OUTPUT
fi

if [[ $(wc -l < $OUTPUT) -ge 1 ]]; then
  SLACK_API_TOKEN=$(cat $HOME/.config/notify/provider-config.yaml | grep "slack_webhook_url" | head --lines=1 | awk '{print $2}' | perl -pe "s{\"}{}g;s{.*services/(.*)}{\1}")
  export SLACK_API_TOKEN
  ./send_to_slack $OUTPUT "SCAN Summary for $TLD"
  cat $OUTPUT | awk -v tld=$TLD 'BEGIN {print "SCAN Summary for " tld "\r"} {print $0}' | perl -pe 's{\n}{\r}gsx' | notify -p discord -bulk -cl 10000
  cat $OUTPUT | grep "^\[20" | perl -pe "s{.*?\] (.*)}{\1}" | grep -vE "https?://[0-9]" | anew ../new.txt | notify -p discord -bulk -cl 10000
  DTE=$(date +%Y%m%d%H%M%S)
  cat $OUTPUT > results/$DTE.txt
  
  SITES=$(cat $OUTPUT | perl -pe "s{.*?https?://(.*?)/.*}{\1}" | sort -u)
fi
rm $OUTPUT
rm $SUBS
rm $RUNNING
} > /tmp/scantld.log 2>&1
