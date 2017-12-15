#!/usr/bin/env bash
#Fucked together by Vincent Cox
GREEN='\033[1;32m'
NC='\033[0m' # No Color
RED='\033[1;31m'

domain="$1"
list_ips=$( sources/dnshistory.org.sh "$domain" )
list_ips=$list_ips" "$( sources/securitytrails.com.sh "$domain" )
list_ips=$(echo $list_ips | uniq )
echo "Found IP's replying to the domain: "
for ip in $list_ips;do
protocol="https"
(if (curl --fail --silent -k -H "Host: $domain" "$protocol"://"$ip"/ | grep "html" | grep -q -v "was rejected" );then echo -e "${GREEN}$ip${NC}"; fi) & pid=$!;
PID_LIST+=" $pid";
protocol="http"
(if (curl --fail --silent -k -H "Host: $domain" "$protocol"://"$ip"/ | grep "html" | grep -q -v "was rejected" ); then echo -e "${GREEN}$ip${NC}"; fi) & pid=$!;
PID_LIST+=" $pid";
done
trap "kill $PID_LIST" SIGINT
wait $PID_LIST
echo "All found IP's:"
echo -e "${RED}$list_ips${NC}"
