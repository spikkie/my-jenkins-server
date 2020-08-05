#!/usr/bin/env bash
set -x
export PROJECT="geneesplaats"
export CURL_RETRY=25
docker-compose build
