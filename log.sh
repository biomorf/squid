#!/usr/bin/env sh

vagrant docker-exec -it proxy.squid.host -- docker exec -it proxy.squid.container tail -f /var/log/squid/access.log

