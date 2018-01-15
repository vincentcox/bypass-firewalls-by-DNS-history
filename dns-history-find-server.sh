#!/usr/bin/env bash

# Check if files in sources folder are also executable
i=0
for file in sources/*
do
	if [[ $i -ne 0 ]]; then continue; fi
	if ! [[ -x "$file" ]]; then
		echo 'The files in the sources folder are not executable. '
		echo 'Execute: chmod +x sources/*'
		exit 0
	fi
	i=$(($i+1))
done

# For the TL;DR people:

if [[ $# -eq 0 ]] ; then
    echo 'The script needs obviously a website name.'
	echo 'usage: ./dns-history-find-server.sh example.com'
    exit 0
fi

# Color's

GREEN='\033[1;32m'
NC='\033[0m' # No Color
RED='\033[1;31m'

# Actual script

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
