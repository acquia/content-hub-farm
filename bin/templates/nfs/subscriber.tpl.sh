#!/bin/bash

# Loading Setup Configuration.
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $SCRIPT_DIRECTORY/../../../setup_options.sh

# Subscriber Template.
for (( COUNT=1; COUNT<=${CONFIG_NUM_SUBSCRIBERS}; COUNT++ )); do
cat  << EOF

  subscriber$COUNT:
    hostname: ${CONFIG_SUB_HOSTNAME[$COUNT]}
    build:
      context: .
    depends_on:
      - database
    environment:
      - SITE_ROLE=subscriber
      - PERSISTENT=true
      - ACH_CLIENT_NAME=${CONFIG_SUB_ACH_CLIENT_NAME[$COUNT]}
      - DATABASE_BACKUP=${CONFIG_SUB_DATABASE_BACKUP[$COUNT]}
      - PHP_IDE_CONFIG=${CONFIG_SUB_PHP_IDE_CONFIG[$COUNT]}
      - XDEBUG_CONFIG=${CONFIG_SUB_XDEBUG_CONFIG[$COUNT]}
    volumes:
      - type: volume
        source: nfsmount
        target: /var/www/html
        volume:
          nocopy: true
      - type: volume
        source: backups
        target: /var/www/backups
        volume:
          nocopy: true
    ports:
      - ${CONFIG_SUB_BINDING_PORT[${COUNT}]}:80
    networks:
      ch_farm:
        ipv4_address: ${CONFIG_SUB_IP_ADDRESS[${COUNT}]}
EOF
done