#!/bin/bash

set -x

adduser vmail -m
chown vmail:vmail /home/vmail -Rf

postconf -e "mydomain = $POSTFIX_DOMAINNAME"
postconf -e "myhostname = $POSTFIX_HOSTNAME"
postconf -e "myorigin = $POSTFIX_DOMAINNAME"
postconf -e "virtual_mailbox_domains = $POSTFIX_DOMAINNAME"
postconf -e "smtpd_tls_cert_file = /etc/pki/dovecot/certs/dovecot.pem"
postconf -e "smtpd_tls_key_file = /etc/pki/dovecot/private/dovecot.pem"

function adduser {
  echo $1:$(doveadm pw -s ssha512 -p $2):::::: >> /etc/imap.passwd
}

echo > /etc/imap.passwd
adduser test@$POSTFIX_DOMAINNAME 1234
chown dovecot:dovecot /etc/imap.passwd

#Start services
supervisord
