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
 __          __     ______   _
 \ \        / /\   |  ____| | |
  \ \  /\  / /  \  | |__    | |__  _   _ _ __   __ _ ___ ___
   \ \/  \/ / /\ \ |  __|   | '_ \| | | | '_ \ / _` / __/ __|
    \  /\  / ____ \| |      | |_) | |_| | |_) | (_| \__ \__ \
     \/  \/_/    \_\_|      |_.__/ \__, | .__/ \__,_|___/___/
                                    __/ | |
                                   |___/|_|
EOF

# Actual script
domain="$1"
outfile="$2"
if [ -z "$2" ]; then
outfile="$PWD/output.txt"
fi
list_ips=$list_ips" "$( curl -s "https://securitytrails.com/domain/$domain/history/a" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' )
list_ips=$(echo $list_ips | uniq )
echo "Found IP's replying to the domain: "
for ip in $list_ips;do
protocol="https"
(if (curl --fail --max-time 10 --silent -k -H "Host: $domain" "$protocol"://"$ip"/ | grep "html" | grep -q -v "was rejected" );then echo -e "$ip" >> "$outfile";  fi) & pid=$!;
PID_LIST+=" $pid";
protocol="http"
(if (curl --fail --max-time 10 --silent -k -H "Host: $domain" "$protocol"://"$ip"/ | grep "html" | grep -q -v "was rejected" ); then echo -e "$ip" >> "$outfile"; fi) & pid=$!;
PID_LIST+=" $pid";
done
trap "kill $PID_LIST" SIGINT
wait $PID_LIST
sort -u -o "$outfile" "$outfile"
content=$(cat "$outfile")
echo -e "${GREEN}$content${NC}"
echo -e "${RED}Done!${NC}"
