#!/bin/ash
#

FOLDER_LOGS="/opt/plantuml/logs"
if [ ! -d $FOLDER_LOGS ] ; then
 mkdir -p $FOLDER_LOGS
fi

FOLDER_TEMP="/opt/plantuml/temp"
if [ ! -d $FOLDER_TEMP ] ; then
 mkdir -p $FOLDER_TEMP
fi

FOLDER_WORK="/opt/plantuml/work"
if [ ! -d $FOLDER_WORK ] ; then
 mkdir -p $FOLDER_WORK
fi

if [ -z "$ENTRYPOINT_PARAMS" ] ; then # Run as container app
 TEST="$(/usr/bin/pgrep java)"
 if [ $? -eq 1 ] ; then
  unset TEST
  echo "---------- [ WEB APPLICATION(plantuml) ] ----------"
  /opt/tomcat10/bin/catalina.sh run
 fi
fi







