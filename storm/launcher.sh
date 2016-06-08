#!/bin/bash
#
# Configures a minimal storm cluster from environment variables
# Expects one or more of the following:
#     STORM_CFG - file to alter
#     KZK_PORT_2181_TCP_ADDR - IP of zookeeper host(s)
#     NIMBUS_PORT_6627_TCP_ADDR - IP of nimbus host
#     UI_PORT_8081_TCP_ADDR - IP of ui host
#     WORK_DIR - used for storm-local-dir

CFG=$STORM_CFG
ZK_HOST=$KZK_PORT_2181_TCP_ADDR
MY_ID=$(uname -n)
MY_HOST=$(grep $MY_ID /etc/hosts | awk '{print $1, "\t"}')

case $1 in
"nimbus") 
    NB_HOST=${MY_HOST} 
    ;;
"ui") 
    UI_HOST=${MY_HOST}
    NB_HOST=$NIMBUS_PORT_6627_TCP_ADDR
    ;;
"supervisor")
    NB_HOST=$NIMBUS_PORT_6627_TCP_ADDR    
    ;;
esac

echo "# $1 config-script created at $(date -Iseconds)" > $CFG
echo "ui.port: 8081" >> $CFG
if [ -v UI_HOST ] ; then 
    echo "ui.host: $UI_HOST" >> $CFG
fi
echo "storm.zookeeper.servers:" >> $CFG
echo "   - $ZK_HOST" >> $CFG
echo "storm.local.dir: $WORK_DIR" >> $CFG
if [ -v NB_HOST ] ; then 
    echo "nimbus.seeds: [${NB_HOST}]" >> $CFG
    echo "nimbus.host: ${NB_HOST}" >> $CFG
fi
echo "--- dumping $CFG ---"
cat $CFG
echo "--- $CFG end ---"

case $1 in
"nimbus")
  cp -r ${STORM_DIR}/* ${STORM_VOL} 
esac

./storm $1