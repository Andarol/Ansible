
# user-data.sh

#!/bin/bash
apt update
apt install -y apache2 mysql-server php php-mysql libapache2-mod-php wget unzip

# Install WordPress
wget https://wordpress.org/latest.tar.gz -P /tmp
tar -xzf /tmp/latest.tar.gz -C /var/www/html --strip-components=1

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
rm -f /var/www/html/index.html
# Restart Apache
systemctl restart apache2

