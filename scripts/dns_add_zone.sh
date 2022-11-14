#!/bin/bash

DOMAIN="viktor-vansteenweghen.sb.uclllabs.be"
SUBZONE=$1
IPAD="193.191.177.230"
DIRECTORY=/etc/bind
CONFIGFILE=named.conf.mrt-zones
DIRCONF=/etc/bind
DIRZONE=/etc/bind

if [[ ! -f "${DIRZONE}/${CONFIGFILE}" ]]
        then
                echo "Creating conffile."
                cd $DIRZONE && vi $CONFIGFILE
                echo 'include "${DIRZONE}/${CONFIGFILE}";' >> named.conf.local
        else
                echo "Entering path ${DIRZONE}/${CONFIGFILE}"
                cd $DIRZONE
        fi

#User is root check
if [ "$EUID" -ne 0 ];then
    echo "Please run this script as root user"
    exit 1
fi

#Check if subzone is empty
if [ -z "$SUBZONE" ]; then
	echo "Subzone cannot be empty"
	exit 1
fi


#Create DNS-ZONE
echo "Adding DNS-ZONE ${SUBZONE}.${DOMAIN}"
cat >> /etc/bind/named.conf.mrt-zones << EOL
zone "${SUBZONE}.${DOMAIN}" {
	type master;
	file "/etc/bind/db.${SUBZONE}.${DOMAIN}";
}; 
EOL


#Create zonefile 

echo "Creating new zonefile for ${SUBZONE}.${DOMAIN}"
cat << EOF >>/etc/bind/db.$SUBZONE.$DOMAIN



\$TTL 250
@	IN	SOA	ns.$SUBZONE.$DOMAIN. root.$SUBZONE.$DOMAIN. (
				1	; Serial
				250	; Refresh
				250	; Retry
				250	; Expire
				250 	; Negative Cache TTL
				)
;
@	IN	NS	ns.$SUBZONE.$DOMAIN.
@	IN	NS	ns.$DOMAIN.
ns	IN	A	$IPAD
@	IN	A	$IPAD



EOF

echo "Zonefile created"
echo "${SUBZONE}	IN	NS	ns.${DOMAIN}." >> /etc/bind/db.${DOMAIN}

rndc reload
systemctl restart bind9

