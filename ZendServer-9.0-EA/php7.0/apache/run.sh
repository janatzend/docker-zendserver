#!/bin/bash

if [ -z $ZS_ADMIN_PASSWORD ]; then
    ZS_ADMIN_PASSWORD=`date +%s | sha256sum | base64 | head -c 8`
    echo $ZS_ADMIN_PASSWORD > /root/zend-password
fi
ZS_MANAGE=/usr/local/zend/bin/zs-manage
HOSTNAME=`hostname`
APP_UNIQUE_NAME=$HOSTNAME
APP_IP=`/sbin/ifconfig eth0| grep 'inet addr:' | awk {'print $2'}| cut -d ':' -f 2`

service zend-server start

if [[ -n $MYSQL_HOSTNAME && -n $MYSQL_PORT && -n $MYSQL_USERNAME && -n $MYSQL_PASSWORD && -n $MYSQL_DBNAME ]]; then
  echo "Joining cluster"
  $ZS_MANAGE server-add-to-cluster -T 120 -n $APP_UNIQUE_NAME -i $APP_IP -o $MYSQL_HOSTNAME:$MYSQL_PORT -u $MYSQL_USERNAME -p $MYSQL_PASSWORD -d $MYSQL_DBNAME -N $WEB_API_KEY -K $WEB_API_KEY_HASH -s| sed -e 's/ //g' > /root/zend_cluster.sh
  echo "MYSQL_HOSTNAME=$MYSQL_HOSTNAME
  MYSQL_PORT=$MYSQL_PORT
  MYSQL_USERNAME=$MYSQL_USERNAME
  MYSQL_PASSWORD=$MYSQL_PASSWORD
  MYSQL_DBNAME=$MYSQL_DBNAME" >> /root/zend_cluster.sh

  eval `cat /root/zend_cluster.sh`
  $ZS_MANAGE store-directive -d 'session.save_handler' -v 'cluster' -N $WEB_API_KEY -K $WEB_API_KEY_HASH
fi

echo "********************************************

Zend Server is ready for use
Your application is available at http://$APP_IP
To access Zend Server, navigate to http://$APP_IP:10081"

if [ "$amount_servers" -gt "1" ]; then
    echo "This is a clustered environment. Please use 
the admin password of the first node to 
login to the Zend Server GUI."

else
  echo "Your admin password is $ZS_ADMIN_PASSWORD" 
fi

echo "
********************************************"

exec supervisord -n > /dev/null 2>/dev/null
