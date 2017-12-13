#!/usr/bin/env bash
#Fucked together by Vincent Cox
domain="$1"
list_ips=$( sources/dnshistory.org.sh "$1" )
list_ips=$list_ips$( sources/securitytrails.com.sh "$1" )
#---- Config ----
protocol="https"
#----------------
for ip in $list_ips;do
if (curl --fail --silent -k -H "Host: $domain" "$protocol"://"$ip"/ | grep "html" | grep -v "was rejected" ); then echo "$ip"; echo -e "------------\n"; fi &
done
