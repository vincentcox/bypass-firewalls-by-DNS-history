# Bypass firewalls by abusing DNS history
This script will try to find:
- the direct IP address of a server behind a firewall like Cloudflare, Incapsula, SUCURI ...
- an old server which still running the same (inactive and unmaintained) website, not receiving active traffic because the A DNS record is not pointing towards it. Because it's an outdated and unmaintained website version of the current active one, it is likely vulnerable for various exploits. It might be easier to find SQL injections and access the database of the old website and abuse this information to use on the current and active website. 


This script (ab)uses DNS history records. This script will search for old DNS A records **and** check if the server replies for that domain. 

_Keep in mind that this script is smashed together. Therefore, it's not the most efficient and beautiful script. But it works. Feel free to improve the script._

More updates and features for this script are planned, so feel free to star this repo for improvements and additional functionality.

## Usage
Make sure you made the script and the files in the sources folder executable:

`sudo chmod +x dns-history-find-server.sh && sudo chmod +x sources/*`

Use the script like this: 

`./dns-history-find-server.sh example.com`

## For who is this script?
This script is handy for:
- Security auditors
- Web administrators
- Bug bounty hunters
- Blackhatters I guess ¯\\\_(ツ)\_/¯

## How to protect against this script?
- If you use a firewall, make sure to accept only traffic coming through the firewall. Deny all traffic coming directly from the internet. For example: Cloudflare has a [list of IP's](https://www.cloudflare.com/ips/) which you can whitelist with iptables or UFW. Deny all other traffic. 
- Make sure that no old servers are still accepting connections and not accessible in the first place

## Used services in this script
The following services were used:
- dnshistory.org
- securitytrails.com

## Author
Vincent Cox

Bug Bounty account: https://www.intigriti.com/public/profile/vincentcox

Website: https://vincentcox.com
