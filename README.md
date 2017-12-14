# bypass-firewalls-like-cloudflare-by-dns-history
This script will try to find:
- the direct IP adress of a server behind a firewall like Cloudflare, Incapsula, ...
- an old server still running the same website: this might be interesting to find an outdated and vulnerable version of the website you are trying to attack. For example, it might be easier to find SQL injections and find old credentials. 


This script works with DNS history records. This script will search for old DNS A records **and** check if the server replies for that domain. 

_Keep in mind that this script is hacked together, so it's not the most efficient and beautiful script. But it works. Feel free to improve the script._

More updates and features for this script are planned. 

## For who is this script?
This script is handy for:
- Security auditors
- Bugbounty hunters
- Blackhatters I guess ¯\\\_(ツ)\_/¯

## How to protect against this script?
- If you use a firewall, make sure to accept only traffic coming trough the firewall. Deny all traffic coming directly from the internet. For example: cloudflare has a [list of IP's](https://www.cloudflare.com/ips/) which you can whitelist with iptables or UFW.  
- Make sure that no old servers are still accepting connections

## Used services in this script
The following services were used:
- dnshistory.org
- securitytrails.com

## Author
Vincent Cox
Bug Bounty account: https://www.intigriti.com/public/profile/vincentcox
Website: https://vincentcox.com
