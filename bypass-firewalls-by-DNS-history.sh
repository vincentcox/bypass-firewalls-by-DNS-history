#!/usr/bin/env bash
# Constants and Variables
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
## Color's
GREEN='\033[1;32m'
NC='\033[0m' # No Color
RED='\033[1;31m'
YELLOW='\033[0;33m'
## Input variables
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -d|--domain)
    domain="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--outputfile)
    outfile="$2"
    shift # past argument
    shift # past value
    ;;
    -l|--listsubdomains)
    listsubdomains="$2"
    shift # past argument
    shift # past value
    ;;
    # --default)
    # DEFAULT=YES
    # shift # past argument
    # ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Show Script Information
if [ -z "$domain" ] ; then
	  echo 'usage: ./bypass-firewalls-by-DNS-history.sh -d example.com'
    echo '-d --domain: domain to bypass'
    echo "-o --outputfile: output file with IP's"
    echo '-l --listsubdomains: list with subdomains for extra coverage'
    exit 0
fi

# Check if jq is installed
jq --help >/dev/null 2>&1 || { echo >&2 "'jq' is needed for extra subdomain lookups, but it's not installed. Consider installing it for better results (eg.: 'apt install jq'). Aborting."; exit 1; }

# Cleanup temp files when program was interrupted.
rm /tmp/waf-bypass-* &> /dev/null

# Add extra Subdomains
if [ -n "$listsubdomains" ] ; then
  cat $listsubdomains > /tmp/waf-bypass-domains.txt
fi

# Logo
cat << "EOF"
-------------------------------------------------------------
 __          __     ______   _
 \ \        / /\   |  ____| | |
  \ \  /\  / /  \  | |__    | |__  _   _ _ __   __ _ ___ ___
   \ \/  \/ / /\ \ |  __|   | '_ \| | | | '_ \ / _` / __/ __|
    \  /\  / ____ \| |      | |_) | |_| | |_) | (_| \__ \__ \
     \/  \/_/    \_\_|      |_.__/ \__, | .__/ \__,_|___/___/
                                    __/ | |
                                   |___/|_|
Via DNS history. ( @vincentcox_be | vincentcox.com )
-------------------------------------------------------------
EOF

# Matchmaking
## Get the original content of the website to compare this to during the matchmaking
curl --silent -o "/tmp/waf-bypass-https-$domain" "https://$domain"
curl --silent -o "/tmp/waf-bypass-http-$domain" "http://$domain"

## Most sites redirect HTTP to HTTPS, so the response body of http will be empty, causing false positives to appear.
{
if (curl --silent -v http://$domain 2>&1|tr '\n' ' '| grep -e "Moved Permanently.*https://$domain"); then
  cp "/tmp/waf-bypass-https-$domain" "/tmp/waf-bypass-http-$domain"
fi
} &> /dev/null # hide verbose output curl, somehow --silent is not enough when verbose is on.

echo -e "[IP] | [Confidence]" >>  /tmp/waf-bypass-output.txt

## This function is called to do the actual comparing
function matchmaking {
file1=$1
file2=$2
ip=$3
thread=$!
sizefile1=$(cat $file1 | wc -l )
sizefile2=$(cat $file2 | wc -l )
biggestsize=$(( $sizefile1 > $sizefile2 ? $sizefile1 : $sizefile2 ))
difference=$(( $(sdiff -B -b -s $file1 $file2 | wc -l) ))
confidence_percentage=$(( 100 * (( $biggestsize - ${difference#-} )) / $biggestsize ))
echo "$ip" >> "$outfile"
echo -e "$ip | $confidence_percentage %" >>  /tmp/waf-bypass-output.txt

### Debugging info
echo "$file1 $file2" >> /tmp/waf-bypass-thread-$thread.txt
echo "#Lines $file1: $(cat $file1 | wc -l)" >> /tmp/waf-bypass-thread-$thread.txt
echo "#Lines $file2: $(cat $file2 | wc -l)" >> /tmp/waf-bypass-thread-$thread.txt
echo "Different lines: $difference" >> /tmp/waf-bypass-thread-$thread.txt
echo -e "$ip | $confidence_percentage %" >> /tmp/waf-bypass-thread-$thread.txt
echo "----" >> /tmp/waf-bypass-thread-$thread.txt
# Uncomment the following line to output the debugging info.
# cat /tmp/waf-bypass-thread-$thread.txt
}

# Remove current IP's via nslookup
currentips=$(nslookup $domain | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')

# If no output file is specified
if [ -z "$outfile" ]; then
  outfile=/tmp/waf-bypass-log.txt # Get's removed anyway at the end of script.
	if [ -f "$outfile" ]; then
	  rm "$outfile"
	fi
fi
# Gather possible IP's of the origin server
## Subdomains: we will also get the ip's of subdomains. Sometimes this is hosted on the same server.
## This is a quick subdomain function. This oneliner doesn't get all subdomains, but it's something.
curl -s https://certspotter.com/api/v0/certs?domain=$domain | jq -c '.[].dns_names' | grep -o '"[^"]\+"' | grep "$domain" | sed 's/"//g' >> /tmp/waf-bypass-domains.txt
echo "$domain" >> /tmp/waf-bypass-domains.txt # Add own domain
cat  /tmp/waf-bypass-domains.txt | sort -u | grep -v -E '\*' >  /tmp/waf-bypass-domains-filtered.txt
readarray domainlist < /tmp/waf-bypass-domains-filtered.txt
# echo "Using the IP's of the following (sub)domains for max coverage:"
# echo $(echo ${domainlist[*]})
echo -e "${YELLOW}[-] $(echo ${#domainlist[@]}) Domains collected...${NC}"
for domainitem in "${domainlist[@]}"
do
   domainitem=$( echo $domainitem | tr -d '\n')
   ### Source: SecurityTrials
   list_ips=$list_ips" "$( curl -s "https://securitytrails.com/domain/$domainitem/history/a" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' )
   ### Source: http://crimeflare.com/
   list_ips=$list_ips" "$( curl -s 'http://www.crimeflare.com:82/cgi-bin/cfsearch.cgi' -H 'Connection: keep-alive' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Origin: http://www.crimeflare.com:82' -H 'Upgrade-Insecure-Requests: 1' -H 'DNT: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.67 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: http://www.crimeflare.com:82/cfs.html' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,nl;q=0.8' --data "cfS=$domainitem" --compressed  | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' )
done
list_ips=$(echo $list_ips | tr " " "\n" | sort -u )
echo -e "${YELLOW}[-] $( echo $list_ips | tr " " "\n" | wc -l) IP's gathered from DNS history...${NC}"
# For each IP test the bypass and calculate the match %
for ip in $list_ips;do
protocol="https"
(if (curl --fail --max-time 10 --silent -k "$protocol://$domain" --resolve "$domain:443:$ip" | grep "html" | grep -q -v "was rejected" );then if [[ $currentips != *"$ip"* ]];then curl --silent -o "/tmp/waf-bypass-$protocol-$ip" -k -H "Host: $domain" "$protocol"://"$ip"/ ; matchmaking "/tmp/waf-bypass-$protocol-$domain" "/tmp/waf-bypass-$protocol-$ip" "$ip";wait; fi; fi) & pid=$!;
PID_LIST+=" $pid";
protocol="http"
(if (curl --fail --max-time 10 --silent -k "$protocol://$domain" --resolve "$domain:80:$ip" | grep "html" | grep -q -v "was rejected" );then if [[ $currentips != *"$ip"* ]];then curl --silent -o "/tmp/waf-bypass-$protocol-$ip" -k -H "Host: $domain" "$protocol"://"$ip"/ ; matchmaking "/tmp/waf-bypass-$protocol-$domain" "/tmp/waf-bypass-$protocol-$ip" "$ip";wait; fi; fi) & pid=$!;
PID_LIST+=" $pid";
done
echo -e "${YELLOW}[-] Launched requests to origin servers...${NC}"
trap "kill $PID_LIST" SIGINT
wait $PID_LIST
if [ ! -f "$outfile" ]; then
  echo -e "${RED}[-] No Bypass found!${NC}"
else
  echo -e "${GREEN}[+] Bypass found!${NC}"
	sort -u -o "$outfile" "$outfile"
  content=$(cat "$outfile")
fi

# New Output
touch /tmp/waf-bypass-output.txt # If no IP's were found, the script will be empty.
# TAC is needed to give priority to higher percentages. Otherwise you will burn valid bypasses
cat "/tmp/waf-bypass-output.txt" | tac | sort -u -n | column -s"|" -t

# Cleanup temp files
rm /tmp/waf-bypass-*
