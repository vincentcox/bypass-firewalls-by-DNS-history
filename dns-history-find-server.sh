#!/usr/bin/env bash
# For the TL;DR people:
if [[ $# -eq 0 ]] ; then
    echo 'The script needs obviously a website name.'
	  echo 'usage: ./dns-history-find-server.sh example.com'
    echo 'or ./dns-history-find-server.sh example.com folder/output.txt'
    exit 0
fi

# Color's

GREEN='\033[1;32m'
NC='\033[0m' # No Color
RED='\033[1;31m'

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

# Actual script
domain="$1"
outfile="$2"
# Remove current IP's via nslookup
currentips=$(nslookup $domain | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')

if [ -z "$2" ]; then
  outfile="$PWD/output.txt"
	if [ -f "$outfile" ]; then
	  rm "$outfile"
	fi
fi
list_ips=$list_ips" "$( curl -s "https://securitytrails.com/domain/$domain/history/a" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' )
list_ips=$list_ips" "$( curl -s 'http://www.crimeflare.com:82/cgi-bin/cfsearch.cgi' -H 'Connection: keep-alive' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Origin: http://www.crimeflare.com:82' -H 'Upgrade-Insecure-Requests: 1' -H 'DNT: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.67 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: http://www.crimeflare.com:82/cfs.html' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,nl;q=0.8' --data "cfS=$domain" --compressed  | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' )
list_ips=$(echo $list_ips | uniq )
for ip in $list_ips;do
protocol="https"
(if (curl --fail --max-time 10 --silent -k -H "Host: $domain" "$protocol"://"$ip"/ | grep "html" | grep -q -v "was rejected" );then if [[ $currentips != *"$ip"* ]]; then echo -e "$ip" >> "$outfile"; fi;  fi) & pid=$!;
PID_LIST+=" $pid";
protocol="http"
(if (curl --fail --max-time 10 --silent -k -H "Host: $domain" "$protocol"://"$ip"/ | grep "html" | grep -q -v "was rejected" ); then if [[ $currentips != *"$ip"* ]]; then echo -e "$ip" >> "$outfile"; fi; fi) & pid=$!;
PID_LIST+=" $pid";
done
trap "kill $PID_LIST" SIGINT
wait $PID_LIST
if [ ! -f "$outfile" ]; then
  echo -e "${RED}No Bypass found!${NC}"
else
	echo "Found IP's replying to the domain: "
	sort -u -o "$outfile" "$outfile"
  content=$(cat "$outfile")
	echo -e "${GREEN}$content${NC}"
fi
echo -e "${GREEN}Finished!${NC}"
