# scan-tlds
Scans TLDs for new domains and then scans those domains

## Perequisites

* [Nuclei] (https://github.com/projectdiscovery/nuclei)
* [Notify] (https://github.com/projectdiscovery/notify)
* [Subfinder] (https://github.com/projectdiscovery/subfinder)
* [HTTPX] (https://github.com/projectdiscovery/httpx)
* [Anew] (https://github.com/tomnomnom/anew)

Note. The script assumes the go files are in $HOME/go/bin

## Running

1. Create a file called tlds.txt with your top level domains in (e.g. example.com)
2. Run the script
3. The script will find all (many) subdomians using subfinder and logs those to the CURRENTDOMAINS file and notify you on the channels you have setup in notify
4. The script will then find all http and https sites for the above domains and will test to see if then are S3 buckets
5. Once the script has fully run you can add nuclei back in on line 17 which will the test any new sites found, we do not do this on the 1st run due to the amount of requests made.

