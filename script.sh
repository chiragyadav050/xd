#!/bin/bash

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Postfix
echo "Installing Postfix..."
sudo debconf-set-selections <<< "postfix postfix/mailname string jacksolana.com"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt install -y postfix

# Basic Postfix configuration
echo "Configuring Postfix..."
sudo postconf -e "myhostname = mail.jacksolana.com"
sudo postconf -e "mydomain = jacksolana.com"
sudo postconf -e "myorigin = \$mydomain"
sudo postconf -e "inet_interfaces = all"
sudo postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain"

# Install Certbot for SSL
echo "Installing Certbot..."
sudo apt install -y certbot

# Get SSL Certificate
echo "Obtaining SSL Certificate..."
sudo certbot certonly --standalone -d mail.jacksolana.com

# Configure Postfix to use SSL
echo "Configuring Postfix to use SSL..."
sudo postconf -e "smtpd_tls_cert_file=/etc/letsencrypt/live/mail.jacksolana.com/fullchain.pem"
sudo postconf -e "smtpd_tls_key_file=/etc/letsencrypt/live/mail.jacksolana.com/privkey.pem"
sudo postconf -e "smtpd_use_tls=yes"

# Reload Postfix to apply changes
echo "Restarting Postfix..."
sudo systemctl restart postfix

echo "SMTP server installation and configuration completed!"
