#!/bin/bash

source /etc/zs_env

ZENDSERVER_IP=$(getent hosts $ZENDSERVER_HOST | awk '{ print $1 }')

zsclient \
  --zskey="$WEB_API_KEY" \
  --zssecret="$WEB_API_SECRET" \
  --zsurl="http://$ZENDSERVER_HOST:10081"\
  \
  configurationStoreDirectives \
    --directives="zray.zendserver_ui_url=http://$ZENDSERVER_IP:10081/ZendServer" \
    --output-format=json \
    | jq '.'
