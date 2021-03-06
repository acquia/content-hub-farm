#!/bin/bash

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CONTENT_HUB_FARM_DIRECTORY=` basename "$( dirname "$( dirname "${SCRIPT_DIRECTORY}")")"`
SETUP_FILE="${SCRIPT_DIRECTORY}/../../setup_options.sh"
CONTENT_HUB_FARM=`echo ${CONTENT_HUB_FARM_DIRECTORY} | tr - _`;

# Setting up initial definitions.
COUNT=$1
NUM_PUBLISHERS=$2
CONFIG_BUILD_PROFILE=$3
CONFIG_SUB_BINDING_PORT[${COUNT}]=$((8080+${NUM_PUBLISHERS}+${COUNT}))
IP=$((10+${NUM_PUBLISHERS}+${COUNT}))
CONFIG_SUB_IP_ADDRESS[${COUNT}]="192.168.1.${IP}"

# Subscriber Questionaire Setup.
echo "Subscriber${COUNT} Configuration."
while : ; do
  echo "Your hostname will be used as your public ngrok domain."
  read -p "Insert your Hostname (subscriber${COUNT}.ngrok.io): " CONFIG_SUB_HOSTNAME[$COUNT]
  CONFIG_SUB_HOSTNAME_DEFAULT="subscriber${COUNT}.ngrok.io"
  CONFIG_SUB_HOSTNAME[$COUNT]="${CONFIG_SUB_HOSTNAME[$COUNT]:-${CONFIG_SUB_HOSTNAME_DEFAULT}}"
  read -p "Insert your Acquia Content Client Name: " CONFIG_SUB_ACH_CLIENT_NAME[$COUNT]
  if [ ${CONFIG_BUILD_PROFILE} == 'customer-environment' ]; then
    read -p "DATABASE_BACKUP (filename inside 'backups' directory): " CONFIG_SUB_DATABASE_BACKUP[$COUNT]
  fi
  echo "The following are Environmental variables used for PHP Debugging."
  echo "If you are unsure about the values, just leave them blank and we will do our best guess to set defaults."
  echo "You can always change them later."
  read -p "PHP_IDE_CONFIG: " CONFIG_SUB_PHP_IDE_CONFIG[$COUNT]
  PHP_IDE_CONFIG_DEFAULT="serverName=${CONTENT_HUB_FARM}_subscriber${COUNT}_1"
  CONFIG_SUB_PHP_IDE_CONFIG[$COUNT]="${CONFIG_SUB_PHP_IDE_CONFIG[$COUNT]:-${PHP_IDE_CONFIG_DEFAULT}}"
  read -p "XDEBUG_CONFIG: " CONFIG_SUB_XDEBUG_CONFIG[$COUNT]
  XDEBUG_CONFIG_DEFAULT="remote_port=9003 remote_autostart=1"
  CONFIG_SUB_XDEBUG_CONFIG[$COUNT]="${CONFIG_SUB_XDEBUG_CONFIG[$COUNT]:-${XDEBUG_CONFIG_DEFAULT}}"

  # Asking for verification.
  echo "Are the following values correct:"
  echo "  - Subscriber$COUNT Hostname: ${CONFIG_SUB_HOSTNAME[$COUNT]}"
  echo "  - Acquia Content Client Name: ${CONFIG_SUB_ACH_CLIENT_NAME[$COUNT]}"
  if [ ${CONFIG_BUILD_PROFILE} == 'customer-environment' ]; then
    echo "  - DATABASE_BACKUP: \"${CONFIG_SUB_DATABASE_BACKUP[$COUNT]}\""
  fi
  echo "  - PHP_IDE_CONFIG: ${CONFIG_SUB_PHP_IDE_CONFIG[$COUNT]}"
  echo "  - XDEBUG_CONFIG: \"${CONFIG_SUB_XDEBUG_CONFIG[$COUNT]}\""
  read -p "(y/n)? " line
    [[ ! $line =~ ^[Yy]$ ]] || break
done

echo "Saving Subscriber$COUNT configuration..."
echo "# Subscriber$COUNT." >> ${SETUP_FILE}
echo "CONFIG_SUB_HOSTNAME[${COUNT}]=\"${CONFIG_SUB_HOSTNAME[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_SUB_ACH_CLIENT_NAME[${COUNT}]=\"${CONFIG_SUB_ACH_CLIENT_NAME[${COUNT}]}\";" >> ${SETUP_FILE}
if [ ${CONFIG_BUILD_PROFILE} == 'customer-environment' ]; then
  echo "CONFIG_SUB_DATABASE_BACKUP[${COUNT}]=\"${CONFIG_SUB_DATABASE_BACKUP[${COUNT}]}\";" >> ${SETUP_FILE}
fi
echo "CONFIG_SUB_PHP_IDE_CONFIG[${COUNT}]=\"${CONFIG_SUB_PHP_IDE_CONFIG[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_SUB_XDEBUG_CONFIG[${COUNT}]=\"${CONFIG_SUB_XDEBUG_CONFIG[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_SUB_BINDING_PORT[${COUNT}]=\"${CONFIG_SUB_BINDING_PORT[${COUNT}]}\";" >> ${SETUP_FILE}
echo "CONFIG_SUB_IP_ADDRESS[${COUNT}]=\"${CONFIG_SUB_IP_ADDRESS[${COUNT}]}\";" >> ${SETUP_FILE}
echo "" >> ${SETUP_FILE}
