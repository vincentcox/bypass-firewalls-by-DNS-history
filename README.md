# Bypass firewalls by abusing DNS history
![](https://img.shields.io/github/issues/vincentcox/bypass-firewalls-by-DNS-history.svg) ![](https://img.shields.io/github/license/vincentcox/bypass-firewalls-by-DNS-history.svg) ![](https://img.shields.io/badge/Mac%20%26%20Linux-Compatible-green.svg)
![Tool overview](https://i.imgur.com/RrPqt9w.png)

This script will try to find:
- the direct IP address of a server behind a firewall like Cloudflare, Incapsula, SUCURI ...
- an old server which still running the same (inactive and unmaintained) website, not receiving active traffic because the A DNS record is not pointing towards it. Because it's an outdated and unmaintained website version of the current active one, it is likely vulnerable for various exploits. It might be easier to find SQL injections and access the database of the old website and abuse this information to use on the current and active website.

This script (ab)uses DNS history records. This script will search for old DNS A records **and** check if the server replies for that domain.
__It also outputs a confidence level, based on the similarity in HTML response of the possible origin server and the firewall.__

The script also fetches the IP's of subdomains because my own experience learned me that subdomain IP's sometimes point to the origin of the main domain.

## Usage
Use the script like this:

`bash bypass-firewalls-by-DNS-history.sh -d example.com`

* `-d --domain`: domain to bypass
* `-o --outputfile`: output file with IP's
* `-l --listsubdomains`: list with subdomains for extra coverage
* `-a --checkall`: Check all subdomains for a WAF bypass

## Requirements (optional)
`jq` is needed to parse output to gather automatically subdomains.
Install with `apt install jq`.

## Background information
### WAF Bypass explanation
To illustrate what we define as WAF bypass, look at the scheme below.

![Scheme WAF Bypass](https://i.imgur.com/arl4zCk.png)

A normal visitor connects to a Website. The initial request is a DNS request to ask the IP of the website, so the browser of the client knows where to send the HTTP request to. For sites behind cloudflare or some other public WAF, the reply contains an IP address of the WAF itself. Your HTTP traffic flows basically through the WAF to the origin web server. The WAF blocks malicious requests and protects against (D)DoS attacks. However, if an attacker knows the IP of the origin webserver **and** the origin webserver accepts HTTP traffic from the entire internet, the attacker can perform a WAF bypass: let the HTTP traffic go directly to the origin webserver instead of passing through the WAF.

This script tries to find that origin IP, so you can connect directly to the origin webserver. Attacks like SQL injections or SSRF's are not filtered and can be successfully, in contrary when there is a WAF in between which stops these kind of attacks.

### Further exploitation
When you find a bypass, you have two options:
- Edit your host-file, which is a system-wide solution. You can find your host-file at `/etc/hosts`(Linux/Mac) or `c:\Windows\System32\Drivers\etc\hosts` (Windows). Add an entry like this: `80.40.10.22 vincentcox.com`.
- Burp Suite: ![Burp Suite Settings](https://i.imgur.com/TIyXXP2.png)

From this moment, your HTTP traffic goes directly to the origin webserver. You can perform a penetration test as usual, without your requests being blocked by the WAF.

### How to protect against this script?
- If you use a firewall, make sure to accept only traffic coming through the firewall. Deny all traffic coming directly from the internet. For example: Cloudflare has a [list of IP's](https://www.cloudflare.com/ips/) which you can whitelist with iptables or UFW. Deny all other traffic.
- Make sure that no old servers are still accepting connections and not accessible in the first place

### For who is this script?
This script is handy for:
- Security auditors
- Web administrators
- __Bug bounty hunters__
- Blackhatters I guess ¯\\\_(ツ)\_/¯


## Web services used in this script
The following services are used:
- [SecurityTrails](https://securitytrails.com)
- [CrimeFlare](http://crimeflare.org:82/)
- [certspotter](https://certspotter.com)
- [DNSDumpster](https://dnsdumpster.com/)
- [IPinfo](https://ipinfo.io/)
- [ViewDNS](https://viewdns.info)

## FAQ
> Why in Bash and not in Python?

It started out as a few CURL one-liners, became a bash script, extended the code more and more, and the regret of not using Python extended accordingly.

> I find more subdomains with my tools?

I know. I cannot expect everyone to install all these DNS brute-force and enumeration tools. In addition, I don't know beforehand in which folder these tools are placed or under which alias these tools are called. You can still provide your own list with `-l` so you can feed output of these subdomain tools into this tool. Expected input is a full subdomain on each line.
## Author

<table>
  <tr>
    <th><center>Project Creator</center></th>
  </tr>
  <tr>
    <td>
    <p align="center"><img src="https://github.com/vincentcox/StaCoAn/raw/master/resources/authors/vincentcox.jpg" alt="Vincent Cox" width="200px"/></p>
    </td>
  </tr>
  <tr>
    <td>
      <div align="center">
        <a href="https://www.linkedin.com/in/ivincentcox/">
          <img src="https://cdnjs.cloudflare.com/ajax/libs/foundicons/3.0.0/svgs/fi-social-linkedin.svg" alt="LinkedIn" width="40px"/>
        </a>
        <a href="https://twitter.com/vincentcox_be">
          <img src="https://cdnjs.cloudflare.com/ajax/libs/foundicons/3.0.0/svgs/fi-social-twitter.svg" alt="Twitter" width="40px"/>
        </a>
        <a href="https://vincentcox.com">
          <img src="https://cdnjs.cloudflare.com/ajax/libs/foundicons/3.0.0/svgs/fi-web.svg" alt="Website" width="40px"/>
        </a>
      </div>
    </td>
  </tr>
</table>

## Tags
WAF bypass<br>
Web Application Firewall bypass<br>
DNS History<br>
find direct/origin IP website
