#!/usr/bin/sh

### https://kodekloud.com/blog/run-docker-in-docker-container/

docker run -v /var/run/docker.sock:/var/run/docker.sock -ti docker:18.06

