#!/usr/bin/env bash
#Fucked together by Vincent Cox
domain="$1"
list_ips=$( sources/dnshistory.org.sh "$domain" )
list_ips=$list_ips$( sources/securitytrails.com.sh "$domain" )
list_ips=$(echo $list_ips | uniq )
result_ips=""
for ip in $list_ips;do
protocol="https"
if (curl --fail --silent -k -H "Host: $domain" "$protocol"://"$ip"/ | grep "html" | grep -q -v "was rejected" ); then result_ips=$result_ips"$ip"; fi &
protocol="http"
if (curl --fail --silent -k -H "Host: $domain" "$protocol"://"$ip"/ | grep "html" | grep -q -v "was rejected" ); then echo "$ip"; result_ips=$result_ips"$ip"; fi &
done
echo $result_ips | uniq
echo "Script done, press enter or CTRL+C to exit"
echo "Found IP's replying to the domain: "
