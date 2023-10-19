#!/usr/bin/bash
RUNNING="/tmp/scanips.pid"
if [ -f "$RUNNING" ]
then
  exit
fi
date > $RUNNING
. ~/.bashrc

cd ${TLDSCANDIR}

OUTPUT=$(mktemp outputips-XXXXXX)
IPS=$(mktemp ips-XXXXXX)
if [[ -z $1 ]]; then
  python3 getnextip.py > $IPS
else
  ARG1=$1
  if [[ "$ARG1" == "NOINC" ]]; then
    python3 getnextip.py NOINC > $IPS
  else
    echo $ARG1 > $IPS
  fi
fi

cat $IPS
cat $IPS | nuclei -es info -rl 50 -c 10 -H "X-Forwarded-For: 10.255.255.254" -ts -silent -o $OUTPUT
if [[ $(wc -l < $OUTPUT) -ge 1 ]]; then
  SLACK_API_TOKEN=$(cat $HOME/.config/notify/provider-config.yaml | grep "slack_webhook_url" | head --lines=1 | awk '{print $2}' | perl -pe "s{\"}{}g;s{.*services/(.*)}{\1}")
  export SLACK_API_TOKEN
  ./send_to_slack $OUTPUT
  cat $OUTPUT | awk 'BEGIN {print "IP SCAN Summary\r"} {print $0}' | perl -pe 's{\n}{\r}gsx' | notify -p discord -bulk -cl 10000
  DTE=$(date +%Y%m%d%H%M%S)
  cat $OUTPUT > results/$DTE.txt

  SITES=$(cat $OUTPUT | perl -pe "s{.*?https?://(.*?)/.*}{\1}" | sort -u)
  #for i in $SITES; do
  #  echo $i | nuclei -rl 50 -c 10 -H "X-Forwarded-For: 10.255.255.255" | notify -bulk -cl 10000
  #done
fi
rm $OUTPUT
rm $IPS
rm $RUNNING

