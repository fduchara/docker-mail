#Dockerfile for a Postfix email relay service
FROM centos:latest

RUN yum install -y epel-release && yum update -y && \
    yum install -y supervisor postfix rsyslog dovecot \
    && rm -rf /var/cache/yum/* \
    && yum clean all

RUN postconf -e "inet_interfaces = all" \
"mydestination = localhost.$mydomain localhost" \
"smtp_use_tls = yes" \
"smtp_tls_note_starttls_offer = yes" \
"smtp_tls_security_level = may" \
"smtpd_use_tls = yes" \
"smtpd_tls_security_level = may" \
"smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache" \
"smtpd_banner = $myhostname ESMTP" \
"smtpd_helo_required = yes" \
"smtpd_recipient_restrictions = reject_unknown_recipient_domain, reject_non_fqdn_recipient, reject_unauth_destination, reject_unverified_recipient, permit" \
"smtpd_sasl_path = private/auth" \
"smtpd_sasl_type = dovecot" \
"strict_rfc821_envelopes = yes" \
"unknown_local_recipient_reject_code = 550" \
"virtual_transport = lmtp:unix:private/dovecot-lmtp"

RUN echo "submission inet n       -       n       -       -       smtpd" >> /etc/postfix/master.cf && \
    echo "  -o smtpd_tls_security_level=encrypt" >> /etc/postfix/master.cf && \
    echo "  -o smtpd_sasl_auth_enable=yes" >> /etc/postfix/master.cf && \
    echo "  -o smtpd_recipient_restrictions=reject_non_fqdn_recipient,reject_unknown_recipient_domain,permit_sasl_authenticated,reject" >> /etc/postfix/master.cf

COPY etc/* /etc/
COPY run.sh /

EXPOSE 25 143
CMD ["/run.sh"]
