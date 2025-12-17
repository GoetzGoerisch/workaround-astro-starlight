#!/bin/bash -e
#
# Installer for ISPmail servers
# Copyright © 2025 Christoph Haas <ispmail@christoph-haas.de>
#
# License: Creative Commons BY-NC-SA license
#
# Version 0.1
# 2025-12-14
#

usage() {
  echo "Usage: $0 -f fqdn"
  exit 1
}

FQDN=""

while getopts "f:h" opt; do
  case "$opt" in
    f) FQDN="$OPTARG" ;;
      h) usage ;;
      *) usage ;;
  esac
done



############ pre flight check ############

pre_flight() {
  # Check for root
  if [[ $EUIA -ne 0 ]]; then
    echo "❌ You must run this script as root."
    exit 1
  fi

  # Check for Trixie
  DEBIAN_VERSION=$(cut -d'.' -f1 /etc/debian_version)
  if [[ "$DEBIAN_VERSION" -ne 13 ]]; then
      echo "❌ Sorry, this installer only works on Debian 13/Trixie."
      exit 10
  fi

  # FQDN needs to be given as an option
  if [[ $FQDN = "" ]]; then
    echo "❌ You must specify your FQDN using the '-f' option."
    exit 1
  fi
}


############## Intro ##############

intro() {
cat <<EOF

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⢶⢞⣞⢟⢽⢫⢏⠗⡗⢖⠦⡢⡠⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣮⢾⡷⣯⣿⣽⣗⢷⡹⣮⢦⣣⡢⣅⢓⣕⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⡿⣟⣯⢿⢯⢷⡻⡽⢽⢾⢽⣳⠓⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣺⡽⡾⣽⣽⣵⣇⣯⡺⣸⡹⣌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡟⢔⢕⡇⣏⢿⡿⡏⢀⡉⡉⠈⢳⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣟⠌⡜⢜⣿⡳⣏⢊⠘⠪⡿⡕⠀⠈⢷⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢼⣷⡱⡨⡪⡮⡮⣎⠆⡐⡐⠄⠂⠀⣀⣟⡧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣾⣮⣯⣞⡇⣆⣪⣬⣼⢷⣿⡽⣯⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣟⡿⠾⠟⠿⠻⠿⠿⠿⠿⠿⠞⠯⠿⠷⠟⢿⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⢿⣽⡇⠂⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠄⢐⣿⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣽⣿⢿⢅⠁⠄⠑⢄⠄⠀⠀⠄⠀⠐⠈⢀⠀⡀⠠⣿⣯⣷⣤⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⣿⣾⢫⢂⠂⡐⠠⠀⠑⢔⢀⠀⠂⠁⡈⢀⠠⠀⠀⢳⣿⣻⣿⣿⣦⣄⠀⠀⠀⠀
⠀⠀⠀⠀⣴⣿⣿⢿⡿⣟⣿⢯⣪⡢⡁⠄⠂⢈⠀⠄⠱⣔⡈⡀⠄⠠⠀⠠⣀⡨⣾⢿⣻⢿⢿⡿⣷⡀⠀⠀
⠀⠀⠀⠨⣿⣷⡿⣿⣻⣿⣾⢿⣽⢯⡿⣶⡡⠀⡐⠨⢈⠠⠑⠦⣐⠰⣵⣟⢗⢽⢝⡽⣝⣟⣯⣿⣯⡧⠀⠀
⠀⠀⠀⠈⢻⢾⣿⣿⢿⣿⣟⣿⣟⣿⣟⡿⡪⠐⡀⠡⢀⠐⠠⠁⠕⢝⢿⣽⡿⣮⡷⣽⢵⣻⣽⡷⣟⠊⠀⠀
⠀⠀⠀⠀⠀⠙⠿⣾⡿⣷⣟⣷⣟⡷⣟⣷⡂⠡⠀⡂⠄⡈⠄⠡⢡⢱⣟⡷⣝⣵⢽⣺⣽⢷⡻⠝⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⡐⣿⣿⣯⢳⢹⢛⢛⠓⠅⠅⢂⠐⡀⡂⠌⠌⡂⠕⡛⠟⢛⢺⣿⢿⠕⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢐⠵⣿⣯⠪⡊⢆⢂⢌⢄⢅⣐⢐⢠⢂⢡⢐⡀⡂⡄⡂⡀⠈⣾⡻⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢭⢻⣯⢣⠱⡡⡃⣊⠢⡑⢄⢃⢑⠌⡐⡐⢈⠠⠐⠀⠀⠂⡸⠀⢀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⢎⢽⢪⢊⢆⢪⢐⡑⢌⠢⡂⢅⢂⠢⠐⠠⠀⠂⡀⢁⠀⢂⢈⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠣⢣⡪⡢⡣⡪⡪⢌⢆⢕⢢⡑⡅⡅⡅⡅⡔⡠⠂⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⡀⢀⠀⡀⡀⡀⡀⣄⣦⡶⣟⣿⣻⣾⣾⡇⡃⠍⡊⡊⣾⢾⣷⣻⣞⠎⣔⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢁⠐⠠⢁⢂⢂⠂⢗⢽⢿⢍⢇⢭⣻⢯⡗⡍⡦⣣⢲⢜⣎⢣⡻⡯⡮⡨⢸⢷⢱⠀⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠂⠈⠈⠄⠁⠌⠈⠨⠈⠐⠈⠈⠐⠀⠡⠈⠨⠈⠈⠐⠐⠀⠂⠀⠁⠈⠀⠀⠀⠀

This installer does all the steps described in the ISPmail tutorial from
https://workaround.org to turn your bare Debian 13/Trixie installation into a
mail server.

It will install software packages and alter your system configuration. Do not
run it on a server that is currently used in production. This installer is
meant to help you set up multiple servers without going through the ISPmail
guide time and again.  It will not read the ISPmail guide for you.

Enter to continue. CTRL-C to abort.
EOF
}

############# Packages ###############

apt_install() {
DEBIAN_FRONTEND=noninteractive apt-get install -qq \
  postfix-mysql dovecot-mysql \
  dovecot-imapd dovecot-lmtpd dovecot-managesieved \
  apache2 python3-certbot-apache libapache2-mod-php \
  php-intl php-mbstring php-xml unzip certbot \
  roundcube-mysql roundcube roundcube-plugins swaks libnet-ssleay-perl \
  mutt unattended-upgrades mariadb-server \
  rspamd redis-server opendkim-tools bind9-dnsutils pwgen curl
}

############# MariaDB ###############

init_mariadb_schema() {
mariadb <<'EOT'
  create database if not exists mailserver;
  grant all privileges on mailserver.* to 'mailadmin'@'localhost' identified by 'MAILADMIN-PASSWORD-HERE';
  grant select on mailserver.* to 'mailserver'@'127.0.0.1' identified by 'MAILSERVER-PASSWORD-HERE';

  USE mailserver;

  CREATE TABLE IF NOT EXISTS `virtual_domains` (
    `id` int(11) NOT NULL auto_increment,
    `name` varchar(50) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY (`name`)
  );

  CREATE TABLE IF NOT EXISTS `virtual_aliases` (
    `id` int(11) NOT NULL auto_increment,
    `domain_id` int(11) NOT NULL,
    `source` varchar(100) NOT NULL,
    `destination` varchar(100) NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
  );

  CREATE TABLE IF NOT EXISTS `virtual_users` (
    `id` int(11) NOT NULL auto_increment,
    `domain_id` int(11) NOT NULL,
    `email` varchar(100) NOT NULL,
    `password` varchar(150) NOT NULL,
    `quota` bigint(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `email` (`email`),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
  );

	REPLACE INTO virtual_domains
	  (id, name)
	  VALUES (10,'example.org');

	REPLACE INTO virtual_users
	  (id, domain_id, password, email)
	  VALUES (
	    1,
	    10,
	  '{BLF-CRYPT}$2y$05$.WedBCNZiwxY1CG3aleIleu6lYjup2CIg0BP4M4YCZsO204Czz07W',
	  'john@example.org');

	REPLACE INTO virtual_aliases
	  (id, domain_id, source, destination)
	  VALUES (
	    1,
	    10,
	    'jack@example.org',
	    'john@example.org');
EOT

  echo "✅ Database ready. Schema is set up."
}

############# Certbot ###############

certbot_config() {
# Certbot renewal
cat > /etc/letsencrypt/cli.ini << 'EOF'
# Restart services after renewing a certificate
post-hook = systemctl reload postfix dovecot apache2

# Because we are using logrotate for greater flexibility, disable the
# internal certbot logrotation.
max-log-backups = 0

# Adjust interactive output regarding automated renewal
preconfigured-renewal = True
EOF
}

############# Postfix ###############

postfix_config() {
  cat > /etc/postfix/mariadb-virtual-mailbox-domains.cf << EOF
user = mailserver
password = MAILSERVER-PASSWORD-HERE
hosts = 127.0.0.1
dbname = mailserver
query = SELECT 1 FROM virtual_domains WHERE name='%s'
EOF

  cat > /etc/postfix/mariadb-virtual-alias-maps.cf << EOF
user = mailserver
password = MAILSERVER-PASSWORD-HERE
hosts = 127.0.0.1
dbname = mailserver
query = SELECT destination FROM virtual_aliases WHERE source='%s'
EOF

  cat > /etc/postfix/mariadb-virtual-mailbox-maps.cf << EOF
user = mailserver
password = MAILSERVER-PASSWORD-HERE
hosts = 127.0.0.1
dbname = mailserver
query = SELECT 1 FROM virtual_users WHERE email='%s'
EOF

  postconf virtual_mailbox_domains=mysql:/etc/postfix/mariadb-virtual-mailbox-domains.cf
  postconf virtual_mailbox_maps=mysql:/etc/postfix/mariadb-virtual-mailbox-maps.cf
  postconf virtual_alias_maps=mysql:/etc/postfix/mariadb-virtual-alias-maps.cf

  chown root:postfix /etc/postfix/mariadb-*.cf
  chmod o= /etc/postfix/mariadb-*.cf

  # Postfix check
  RES=$(postmap -q example.org mysql:/etc/postfix/mariadb-virtual-mailbox-domains.cf)
  if [[ $RES -ne 1 ]]; then
    echo "❌ The mariadb-virtual-mailbox-domains.cf mapping failed."
    exit 10
  fi

  RES=$(postmap -q jack@example.org mysql:/etc/postfix/mariadb-virtual-alias-maps.cf)
  if [[ $RES != 'john@example.org' ]]; then
    echo "❌ The mariadb-virtual-alias-maps.cf mapping failed."
    exit 10
  fi

  RES=$(postmap -q john@example.org mysql:/etc/postfix/mariadb-virtual-mailbox-maps.cf)
  if [[ $RES -ne 1 ]]; then
    echo "❌ The mariadb-virtual-mailbox-maps.cf mapping failed."
    exit 10
  fi

  echo "✅ Mappings work."
}

############# Dovecot ###############

dovecot_config() {
  groupadd -f --system vmail
  id -a vmail 2>/dev/null >/dev/null || useradd --system --gid vmail vmail
  mkdir -p /var/vmail
  chown -R vmail:vmail /var/vmail
  chmod u=rwx,g=rx,o= /var/vmail

  sed -i '/!include/s/^/#/' /etc/dovecot/conf.d/10-auth.conf

  cat > /etc/dovecot/conf.d/99-ispmail-mail.conf << EOF
mail_driver = maildir
mail_home = /var/vmail/%{user | domain}/%{user | username}
mail_path = ~/Maildir
mail_uid = vmail
mail_gid = vmail
mail_inbox_path = ~/Maildir/
EOF

  cat > /etc/dovecot/conf.d/99-ispmail-master.conf << EOF
service auth {
  unix_listener /var/spool/postfix/private/dovecot-auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
EOF

  cat > /etc/dovecot/conf.d/99-ispmail-ssl.conf << EOF
ssl = required
ssl_server_cert_file = /etc/letsencrypt/live/$FQDN/fullchain.pem
ssl_server_key_file = /etc/letsencrypt/live/$FQDN/privkey.pem
EOF

  cat > /etc/dovecot/conf.d/99-ispmail-lmtp-username-format.conf << EOF
protocol lmtp {
  auth_username_format =
}
EOF

  cat > /etc/dovecot/conf.d/99-ispmail-sql.conf << EOF
sql_driver = mysql

mysql /var/run/mysqld/mysqld.sock {
  user = mailserver
  password = 'MAILSERVER-PASSWORD-HERE'
  dbname = mailserver
  host = 127.0.0.1
}

userdb sql {
  query = SELECT email as user FROM virtual_users WHERE email='%{user}'
  iterate_query = SELECT email as user FROM virtual_users
}

passdb sql {
  query = SELECT password FROM virtual_users where email='%{user}'
}
EOF

  # fix permissions
  chown root:root /etc/dovecot/conf.d/99-ispmail-sql.conf
  chmod go= /etc/dovecot/conf.d/99-ispmail-sql.conf

  cat > /etc/dovecot/conf.d/99-ispmail-managesieve.conf << EOF
service managesieve-login {
  # Listen only on localhost
  inet_listener sieve {
    listen= 127.0.0.1
    port = 4190
  }

  # Disable the deprecated listener
  inet_listener sieve_deprecated {
    port = 0
  }
}
EOF

  systemctl restart dovecot

  # Check if running
  systemctl is-active --quiet dovecot.service
  if [[ $? -ne 0 ]]; then
    echo "❌ Dovecot failed to start properly."
    exit 10
  fi
  echo "✅ Dovecot is running fine."

  # Check query
  JOHNS_MAILDIR=$(doveadm user john@example.org | grep ^mail_path | cut -f2)
  if [[ $JOHNS_MAILDIR != '/var/vmail/example.org/john/Maildir' ]]; then
    echo "❌ Could not find John's mail_path."
    exit 10
  fi
  echo "✅ Lookup works."
}

############# LMTP ###############

lmtp_config() {
# Add an LMTP listening socket in Dovecot
  cat > /etc/dovecot/conf.d/99-ispmail-lmtp-listener.conf << EOF
service lmtp {
  # Used internally by Dovecot
  unix_listener lmtp {
  }

  # Listen to LMTP connections from Postfix
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
    mode = 0600
    user = postfix
    group = postfix
  }
}
EOF

  # Restart Dovecot
  systemctl restart dovecot

  postconf virtual_transport=lmtp:unix:private/dovecot-lmtp

  # Testing delivery
  echo Testing email delivery internally.
  if [[ -d /var/vmail/example.org/john/Maildir/new/ ]]; then
    rm -f /var/vmail/example.org/john/Maildir/new/*
  fi
  swaks --server localhost --to john@example.org --tls --silent

  DELIVERY=0
  for i in $(seq 1 50); do
    NUM_FILES=$(ls -1 /var/vmail/example.org/john/Maildir/new/ | wc -l)
    if [[ $NUM_FILES -eq 1 ]]; then
      DELIVERY=1
      break
    fi

    sleep 0.2
  done

  if [[ $DELIVERY -eq 0 ]]; then
    echo "❌ Mail delivery to john@example.org failed."
    exit 10
  fi
  echo "✅ Test successful."
}

############ APACHE #############

apache_config() {
  cat > /etc/apache2/sites-available/000-default-le-ssl.conf << EOF
<VirtualHost *:443>
	ServerAdmin postmaster@$FQDN
	ServerName $FQDN
	DocumentRoot /var/lib/roundcube/public_html

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined

	SSLCertificateFile /etc/letsencrypt/live/$FQDN/fullchain.pem
	SSLCertificateKeyFile /etc/letsencrypt/live/$FQDN/privkey.pem
	Include /etc/letsencrypt/options-ssl-apache.conf
	Include /etc/roundcube/apache.conf

  <Location /rspamd>
    Require all granted
  </Location>

  RewriteEngine On
  RewriteRule ^/rspamd$ /rspamd/ [R,L]
  RewriteRule ^/rspamd/(.*) http://localhost:11334/\$1 [P,L]
</VirtualHost>
EOF

  # Enable the required Apache modules
  a2enmod proxy_http -q
  a2enmod rewrite -q

  # Restart Apache
  systemctl restart apache2
  # Check if running
  systemctl is-active --quiet apache2.service
  if [[ $? -ne 0 ]]; then
    echo "❌ Apache has not started properly."
    exit 10
  fi
  echo "✅ Apache is running fine."

  # Set imap_host and smtp_host in /etc/roundcube/config.inc.php
  sed -i "s|^\s*\$config\['imap_host'\]\s*=.*|\$config['imap_host'] = 'tls://$FQDN:143';|" /etc/roundcube/config.inc.php
  sed -i "s|^\s*\$config\['smtp_host'\]\s*=.*|\$config['smtp_host'] = 'tls://$FQDN:587';|" /etc/roundcube/config.inc.php

  # Check if web interface is loading
  curl -s https://$FQDN | grep title | grep -q "Roundcube Webmail"
  if [[ $? -ne 0 ]]; then
    echo "❌ Webmail interface is not reachable at https://$FQDN"
    exit 10
  fi
}

############ Relaying #############

relaying_setup() {
  postconf -M submission/inet="submission inet n - y - - smtpd"
  postconf -P "submission/inet/syslog_name=postfix/submission"
  postconf -P "submission/inet/smtpd_tls_security_level=encrypt"
  postconf -P "submission/inet/smtpd_sasl_auth_enable=yes"
  postconf -P "submission/inet/smtpd_sasl_type=dovecot"
  postconf -P "submission/inet/smtpd_sasl_path=private/dovecot-auth"
  postconf -P "submission/inet/smtpd_recipient_restrictions=permit_sasl_authenticated,reject"
  postconf -P "submission/inet/smtpd_sender_restrictions=reject_sender_login_mismatch,permit_sasl_authenticated,reject"

  postconf -M submissions/inet="submissions inet n - y - - smtpd"
  postconf -P "submissions/inet/syslog_name=postfix/submissions"
  postconf -P "submissions/inet/smtpd_tls_wrappermode=yes"
  postconf -P "submissions/inet/smtpd_sasl_auth_enable=yes"
  postconf -P "submissions/inet/smtpd_sasl_type=dovecot"
  postconf -P "submissions/inet/smtpd_sasl_path=private/dovecot-auth"
  postconf -P "submissions/inet/smtpd_recipient_restrictions=permit_sasl_authenticated,reject"
  postconf -P "submissions/inet/smtpd_sender_restrictions=reject_sender_login_mismatch,permit_sasl_authenticated,reject"

  postfix reload 2>/dev/null

  postconf smtp_tls_security_level=encrypt
  postconf smtpd_tls_security_level=encrypt
  postconf smtp_tls_mandatory_protocols=">=TLSv1.2"
  postconf smtpd_tls_mandatory_protocols=">=TLSv1.2"
  postconf smtp_tls_mandatory_ciphers=high
  postconf smtpd_tls_mandatory_ciphers=high
  postconf smtpd_tls_cert_file=/etc/letsencrypt/live/$FQDN/fullchain.pem
  postconf smtpd_tls_key_file=/etc/letsencrypt/live/$FQDN/privkey.pem

  # Create a mapping configuration from the user to themself
  cat > /etc/postfix/mariadb-email2email.cf << EOF
user = mailserver
password = MAILSERVER-PASSWORD-HERE
hosts = 127.0.0.1
dbname = mailserver
query = SELECT email FROM virtual_users WHERE email='%s'
EOF

  # Fix permissions
  chown root:postfix /etc/postfix/mariadb-email2email.cf
  chmod u=rw,g=r,o= /etc/postfix/mariadb-email2email.cf

  # Tell Postfix to use this mapping
  postconf smtpd_sender_login_maps=mysql:/etc/postfix/mariadb-email2email.cf

  # Test spoofing
  set +e
  swaks --server localhost:587 \
     --from brunhilde@example.org \
     --to list@example.com \
     --tls \
     --auth-user john@example.org \
     --auth-password summersun \
     --silent 3

  if [[ $? -ne 24 ]]; then
    echo "❌ Forged sender spoofing test failed."
    exit 10
  fi
  set -e
  echo "✅ Forged sender spoofing successfully rejected."

  # Test with proper email
  set +e
  swaks --server localhost:587 \
     --from john@example.org \
     --to list@example.com \
     --tls \
     --auth-user john@example.org \
     --auth-password summersun \
     --silent 3

  if [[ $? -ne 0 ]]; then
    echo "❌ Relaying of proper email failed."
    exit 10
  fi
  set -e
  echo "✅ Relay test okay."

  # Submission plaintext test
  set +e
  swaks --server localhost:587 \
        --from john@example.org \
        --to lisa@example.com \
        --silent 3
  if [[ $? -ne 23 ]]; then
    echo "❌ Relaying over submission without STARTTLS was accepted."
    exit 10
  fi
  set -e
  echo "✅ Plaintext auth refused via submission port."
  
  # Submission encryption but no auth test
  set +e
  swaks --server localhost:587 \
        --from john@example.org \
        --to lisa@example.com \
        -tls \
        --silent 3
  if [[ $? -ne 24 ]]; then
    echo "❌ Relaying over submission with STARTTLS but without auth was accepted."
    exit 10
  fi
  set -e
  echo "✅ Encrypted non-auth refused via submission port."

  # Test encryption and auth over submission
  set +e
  swaks --server localhost:587 \
    --from john@example.org \
    --to lisa@example.com \
    -tls \
    --auth-user john@example.org \
    --auth-password summersun \
    --silent 3
  if [[ $? -ne 0 ]]; then
    echo "❌ Relaying over submission with STARTTLS and auth failed."
    exit 10
  fi
  set -e
  echo "✅ Encrypted and authenticated relaying over submission works."

  # Test encryption and auth over submissions
  set +e
  swaks --server localhost:465 \
    --from john@example.org \
    --to lisa@example.com \
    --tls-on-connect \
    --auth-user john@example.org \
    --auth-password summersun \
    --silent 3
  if [[ $? -ne 0 ]]; then
    echo "❌ Relaying over submissions with STARTTLS and auth failed."
    exit 10
  fi
  set -e
  echo "✅ Encrypted and authenticated relaying over submissions works."
}

############ IMAP ##############

imap_test() {
  # Test IMAP access
  apt-get -qq install fetchmail
  cat > ~/.fetchmailrc <<EOF
poll "$FQDN" proto IMAP
    user "john@example.org" there with password "summersun"
EOF
  set +e
  fetchmail --check -s 2>/dev/null
  rm ~/.fetchmailrc
  if [[ $? -ne 0 ]]; then
    echo "❌ IMAP connection failed"
    exit 10
  fi
  set -e
  echo "✅ IMAP connection test successful."
}

############ rspamd #############

rspamd_config() {
  postconf smtpd_milters=inet:127.0.0.1:11332
  postconf non_smtpd_milters=inet:127.0.0.1:11332
  postconf inet_protocols=all
  systemctl restart postfix

  cat > /tmp/gtube.txt <<EOF
This is the GTUBE, the
	Generic
	Test for
	Unsolicited
	Bulk
	Email

If your spam filter supports it, the GTUBE provides a test by which you
can verify that the filter is installed correctly and is detecting incoming
spam. You can send yourself a test mail containing the following string of
characters (in upper case and with no white spaces and line breaks):

XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X
EOF

  set +e
  swaks --server $FQDN:25 \
    --from lisa@example.com \
    --to john@example.org \
    -tls \
    --body @/tmp/gtube.txt \
    --silent 3
  if [[ $? -ne 26 ]]; then
    echo "❌ GTUBE spam test pattern was not rejected"
    exit 10
  fi
  set -e
  echo "✅ GTUBE spam test was rejected successfully."

  # Add learning scripts
  cat > /etc/dovecot/conf.d/99-ispmail-sieve-movetojunk.conf << 'EOF'
sieve_script spam-to-junk-folder {
  driver = file
  type = after
  path = /etc/dovecot/sieve/spam-to-junk-folder.sieve
}

# Enable the execution of Sieve rules when Postfix sends an email to Dovecot over LMTP
protocol lmtp {
  mail_plugins {
    sieve = yes
  }
}

# Make sure that every user has a Junk folder and is subscribed to it
namespace inbox {
  mailbox Junk {
    special_use = \Junk
    auto = subscribe
  }
}
EOF

  # Restart Dovecot
  systemctl reload dovecot

  # Create the directory for Sieve files
  mkdir -p /etc/dovecot/sieve

  # Create the Sieve script to move Spam mails to the user's Junk folder
  cat > /etc/dovecot/sieve/spam-to-junk-folder.sieve << 'EOF'
require ["fileinto"];

if header :contains "X-Spam" "Yes" {
 fileinto "Junk";
 stop;
}
EOF

  # Make the sieve script machine-readable
  sievec /etc/dovecot/sieve/spam-to-junk-folder.sieve 2>/dev/null

  # Create a config file to enable automatic spam training
  cat > /etc/rspamd/local.d/classifier-bayes.conf << 'EOF'
# Store training data in the Redis database
servers = "127.0.0.1:6379";
backend = "redis";

# Enable automatic training
autolearn = true;   # if rspamd is sure that an email is spam, it will be learned
min_learns = 200;   # do not trust the data before at least 200 mails have been learned
EOF

  # Restart rspamd
  #systemctl restart rspamd

  cat > /etc/dovecot/conf.d/99-ispmail-imapsieve.conf << 'EOF'
# Enable the imap_sieve plugin
protocol imap {
  mail_plugins {
    imap_sieve = yes
  }
}

# Allow the use of the pipe plugin to send mails to shell scripts
sieve_plugins {
  sieve_extprograms = yes
  sieve_imapsieve = yes
}

sieve_global_extensions {
  vnd.dovecot.pipe = yes
}

# Where to look for Sieve scripts that use the Pipe functionality
sieve_pipe_bin_dir = /etc/dovecot/sieve

# Moved into Junk? -> Learn as spam.
mailbox Junk {
  sieve_script spam {
    type = before
    cause = copy
    path = /etc/dovecot/sieve/learn-spam.sieve
  }
}

# Moved out of Junk? -> Learn as ham.
imapsieve_from Junk {
  sieve_script ham {
    type = before
    cause = copy
    path = /etc/dovecot/sieve/learn-ham.sieve
  }
}
EOF

  # Create spam learning script
  cat > /etc/dovecot/sieve/learn-spam.sieve << 'EOF'
require ["vnd.dovecot.pipe", "copy", "imapsieve"];
pipe :copy "rspamd-learn-spam.sh";
EOF

  # Create ham learning script
  cat > /etc/dovecot/sieve/learn-ham.sieve << 'EOF'
require ["vnd.dovecot.pipe", "copy", "imapsieve", "variables"];
pipe :copy "rspamd-learn-ham.sh";
EOF

  # Compile the Sieve scripts
  systemctl reload dovecot
  sievec /etc/dovecot/sieve/learn-spam.sieve 2>/dev/null
  sievec /etc/dovecot/sieve/learn-ham.sieve 2>/dev/null

  # Fix permissions
  chmod u=rw,go= /etc/dovecot/sieve/learn-{spam,ham}.{sieve,svbin}
  chown vmail:vmail /etc/dovecot/sieve/learn-{spam,ham}.{sieve,svbin}

  # Create the shell script for learning spam
  cat > /etc/dovecot/sieve/rspamd-learn-spam.sh << 'EOF'
#!/bin/sh
# Receives an email from Dovecot's Sieve script and pipe it into rspamc
exec /usr/bin/rspamc learn_spam
EOF

  # Create the shell script for learning ham
  cat > /etc/dovecot/sieve/rspamd-learn-ham.sh << 'EOF'
#!/bin/sh
# Receives an email from Dovecot's Sieve script and pipe it into rspamc
exec /usr/bin/rspamc learn_ham
EOF

  # Fix permissions of the shell scripts
  chmod u=rwx,go= /etc/dovecot/sieve/rspamd-learn-{spam,ham}.sh
  chown vmail:vmail /etc/dovecot/sieve/rspamd-learn-{spam,ham}.sh

  cat > /etc/dovecot/conf.d/99-ispmail-sieve-debug.conf << 'EOF'
# Enable detailed logging of Sieve scripts
log_debug=category=sieve
EOF

  cat > /etc/dovecot/conf.d/99-ispmail-autoexpunge.conf << 'EOF'
# Remove mails from the Junk and Trash folders after 30 days
mailbox Junk {
  special_use = \Junk
  auto = subscribe
  mailbox_autoexpunge = 30d
}
mailbox Trash {
  special_use = \Trash
  auto = subscribe
  mailbox_autoexpunge = 30d
}

# Make expunging more efficient
mailbox_list_index = yes
mail_always_cache_fields = date.save
EOF

  # Restart Dovecot
  systemctl restart dovecot

  # Generate a random password that is 15 characters long
  RSPAMD_PW=$(pwgen 15 1)

  # Create a hash of that password
  HASH=$(rspamadm pw -p $RSPAMD_PW)

  # Add the hashed password to rspamd's configuration
  echo "password = \"$HASH\"" > /etc/rspamd/local.d/worker-controller.inc

  # Restart rspamd
  systemctl reload rspamd

  echo "✅ rspamd set up"
}

############ Show summary at the end #############

dkim_config() {
  postconf smtpd_milters=inet:127.0.0.1:11332
  postconf non_smtpd_milters=inet:127.0.0.1:11332

  # Create the directory
  mkdir -p /var/lib/rspamd/dkim

  # Fix permissions
  chown _rspamd:_rspamd /var/lib/rspamd/dkim

  # Tell rspamd to look up selectors in our mapping file
  cat > /etc/rspamd/local.d/dkim_signing.conf << 'EOF'
path = "/var/lib/rspamd/dkim/$domain.$selector.key";
selector_map = "/etc/rspamd/dkim_selectors.map";
EOF

  # TODO: create a key for $FQDN and test it

  # Restart rspamd
  systemctl restart rspamd

  echo "✅ DKIM signing ready to use"
}

############ Catch-all aliases #############

catchall_config() {
  # Create the john-to-himself mapping
  cat > /etc/postfix/mariadb-email2email.cf << EOF
user = mailserver
password = MAILSERVER-PASSWORD-HERE
hosts = 127.0.0.1
dbname = mailserver
query = SELECT email FROM virtual_users WHERE email='%s'
EOF

  # Fix the permissions of that file
  chgrp postfix /etc/postfix/mariadb-*.cf
  chmod u=rw,g=r,o= /etc/postfix/mariadb-*.cf

  # Add the new mapping to the virtual_alias_maps
  # (The order is not important. Postfix will check all mapping files.)
  postconf virtual_alias_maps=mysql:/etc/postfix/mariadb-virtual-alias-maps.cf,mysql:/etc/postfix/mariadb-email2email.cf

  result=$(postmap -q john@example.org mysql:/etc/postfix/mariadb-email2email.cf)

  if [[ $result != "john@example.org" ]]; then
    echo "❌ email2email mapping for catch-all aliases do not work properly"
    exit 10
  fi
  set -e
  echo "✅ Catch-all aliases ready to use."
}

############ Going-live #############

going_live() {
  # Create two random passwords
  PW_MAILADMIN=$(pwgen -s 32 1)
  PW_MAILSERVER=$(pwgen -s 32 1)

  # Replace the dummy passwords
  sed -i "s|MAILADMIN-PASSWORD-HERE|$PW_MAILADMIN|g" /etc/roundcube/plugins/password/config.inc.php

  sed -i "s|MAILSERVER-PASSWORD-HERE|$PW_MAILSERVER|g" \
      /etc/dovecot/conf.d/99-ispmail-sql.conf \
      /etc/postfix/mariadb-virtual-mailbox-maps.cf \
      /etc/postfix/mariadb-virtual-mailbox-domains.cf \
      /etc/postfix/mariadb-virtual-alias-maps.cf \
      /etc/postfix/mariadb-email2email.cf

  # Restart the services
  systemctl restart postfix dovecot

  # Update MariaDB user passwords
  mariadb <<EOF
ALTER USER 'mailadmin'@'localhost' IDENTIFIED BY '${PW_MAILADMIN}';
ALTER USER 'mailserver'@'127.0.0.1' IDENTIFIED BY '${PW_MAILSERVER}';
FLUSH PRIVILEGES;
EOF

  echo "✅ Dummy passwords changed."
  # TODO: remove example.org
}

############ Show summary at the end #############

show_passwords() {
  echo "============================================================="
  echo " PLEASE NOTE:"
  echo "============================================================="
  echo
  echo "Web mail URL:                  https://$FQDN"
  echo
  echo "rspamd web interface URL:      https://$FQDN/rspamd"
  echo "rspamd web interface password: $RSPAMD_PW"
  echo "Database passwords:"
  echo "mailadmin password:            $PW_MAILADMIN"
  echo "mailserver password:           $PW_MAILSERVER"
  echo
  echo "============================================================="
  echo "Your mail server is now ready to be used. Now it is time to"
  echo "add your domains, users and aliases to the database."
  echo "Set up DNS records and DKIM keys."
  echo "Details are found in the ISPmail guide at https://workaround.org"
  echo
  echo "Please report bugs at https://github.com/Signum/ispmail-workaround-org/issues"
}

############ Banner helper #############

banner() {
  echo ---------------------------------------------
  echo --- $1
  echo ---------------------------------------------
}

############ MAIN #############

pre_flight
intro
read

banner "Installing packages"
apt_install

banner "Preparing database schema"
init_mariadb_schema

if [[ ! -d "/etc/letsencrypt/live/$FQDN" ]]; then
  banner "Getting certificate from Let's Encrypt"
	certbot --apache --register-unsafely-without-email --agree-tos -d $FQDN
fi

certbot_config

banner "Configuring Postfix"
postfix_config

banner "Configuring Dovecot"
dovecot_config

banner "Testing IMAP"
imap_test

banner "Configuring LMTP"
lmtp_config

banner "Configuring Apache and Roundcube"
apache_config

banner "Configuring relaying"
relaying_setup

banner "Configuring rspamd"
rspamd_config

banner "Preparing DKIM signing"
dkim_config

banner "Setting up catch-all aliases"
catchall_config

banner "Final steps – changing dummy passwords"
going_live

show_passwords

