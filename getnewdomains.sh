#!/bin/bash
FOLDER=scantlds
NEWDOMAINS=newdomains.txt
NEWFILE=newhttpxscan.txt
CURRENTDOMAINS=currentdomains.txt
CURRENTHTTP=currenthttpxscan.txt
TLDS=tlds.txt
if [ ! -f $TLDS ]
then
    echo "Please create a tlds.txt file containing your top level domains"
    exit
fi
if [[ $1 != *"skip"* ]];then
	(
	cd $HOME/$FOLDER
  # Clear out new domains file
	> $NEWDOMAINS
	for i in $(cat $TLDS); do $HOME/go/bin/subfinder -d $i >> $NEWDOMAINS; done
	#cat $NEWDOMAINS | $HOME/go/bin/anew $CURRENTDOMAINS | $HOME/go/bin/notify -bulk  | $HOME/go/bin/nuclei -rl 10 -c 3 -etags dns -exclude-severity info -severity high --stats -t http/cves | $HOME/go/bin/notify -bulk
	cat $NEWDOMAINS | $HOME/go/bin/anew $CURRENTDOMAINS | $HOME/go/bin/notify -bulk 
	) 2>&1 | tee /tmp/output.log
fi
# Find new http(s) sites - excelure CloudFlare
cat $CURRENTDOMAINS | httpx -fr -sc -ct -title -fs Cloudflare -o $NEWFILE
# Add them to the existing list and notify
cat $NEWFILE | $HOME/go/bin/anew $CURRENTHTTP | $HOME/go/bin/notify -bulk
# Scan the new sites with nuclei to check for open S3 bucket
cat $NEWFILE | awk '{print $1}'  | nuclei -dr -t $HOME/custom-nuclei-templates/aws-s3-open-bucket-2.yaml | $HOME/go/bin/notify -bulk

