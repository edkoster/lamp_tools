#!/bin/bash
 
if [ `id -u` -ne 0 ]
    then
        echo 'Run the script as root'
        exit 1
fi
 
APACHE='/etc/apache2/sites-available/'
 
echo 'Enter domain name (e.g. mysite.com):'
read NAME

echo 'Creating "/var/www/vhosts/'$NAME'/httpdocs'
mkdir -p /var/www/vhosts/$NAME/httpdocs
#chown -R dev:users /var/www/vhosts/$NAME

echo 'Creating "'$APACHE$NAME'"'
cat > $APACHE$NAME'.conf' << EOF
<VirtualHost *:80>
        ServerAdmin webmaster@ekoster.nl
        ServerName $NAME
 
        DocumentRoot /var/www/vhosts/$NAME/httpdocs
        <Directory /var/www/vhosts/$NAME/httpdocs>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>
 
        ErrorLog /var/www/vhosts/$NAME/error.log
 
        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
 
        CustomLog /var/www/vhosts/$NAME/access.log combined
</VirtualHost>
 
<IfModule mod_ssl.c>
<VirtualHost *:443>
        ServerAdmin webmaster@ekoster.nl
        ServerName $NAME
 
        DocumentRoot /var/www/vhosts/$NAME/httpdocs
        <Directory />
                Options FollowSymLinks
                AllowOverride None
        </Directory>
        <Directory /var/www/vhosts/$NAME/httpdocs/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>
 
        ErrorLog /var/www/vhosts/$NAME/error.log
 
        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
 
        CustomLog /var/www/vhosts/$NAME/ssl_access.log combined
 
        #   SSL Engine Switch:
        #   Enable/Disable SSL for this virtual host.
        SSLEngine on
 
        #   A self-signed (snakeoil) certificate can be created by installing
        #   the ssl-cert package. See
        #   /usr/share/doc/apache2.2-common/README.Debian.gz for more info.
        #   If both key and certificate are stored in the same file, only the
        #   SSLCertificateFile directive is needed.
        SSLCertificateFile    /etc/ssl/certs/$NAME.crt
        SSLCertificateKeyFile /etc/ssl/certs/$NAME.crt
 
</VirtualHost>
</IfModule>
EOF
 
if [ ! -f $APACHE$NAME'.conf' ]
then
        echo 'E: There was an error creating the domain'
        exit 1
fi
echo 'Success'
 
echo 'Creating "/etc/ssl/certs/'$NAME'.crt"'
make-ssl-cert /usr/share/ssl-cert/ssleay.cnf /etc/ssl/certs/$NAME.crt --force-overwrite
if [ ! -f /etc/ssl/certs/$NAME.crt ]
then
        echo 'E: There was an error creating the certificate'
    exit 1
fi
echo 'Success'
a2ensite $NAME
if [ ! -f /etc/apache2/sites-enabled/$NAME'.conf' ]
then
        echo 'E: There was an error activating the site'
        exit 0
fi
echo 'Success'
/etc/init.d/apache2 reload
 
echo 'done'
exit 0
