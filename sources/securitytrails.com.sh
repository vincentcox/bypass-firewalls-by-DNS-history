#!/usr/bin/env bash
domain=$1
curl -s "https://securitytrails.com/domain/$domain/history/a" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
