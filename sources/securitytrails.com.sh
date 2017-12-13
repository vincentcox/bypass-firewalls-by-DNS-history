#!/usr/bin/env bash
domain=$1
curl -s "https://app.securitytrails.com/api/domain/history/$domain/a" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
