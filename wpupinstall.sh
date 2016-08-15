#!/bin/bash

##
#   This script must be executed from your WordPress website root directory. In most cases that will be
#   /home/$USERNAME/public_html directory, or
#   /home/$USERNAME/public_html/$WORDPRESS directory
#
#   XXXXX Installation Commands XXXXX
#   wget https://raw.githubusercontent.com/charter-hosting/wp-cli-wp-auto-updater/master/wpupinstall.sh --no-check-certificate
#   chmod +x wpupinstall.sh
#   ./wpupinstall.sh
#   rm wpupinstall.sh
##

# Change the values below prior to executing the script.
domain=example.com
emailto=you@example.com

# Download and configure WP-CLI from github.com
echo Downloading WP-CLI from github.com
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar --no-check-certificate

echo Giving WP-CLI premission to execute
chmod +x wp-cli.phar

echo Moving WP-CLI to /usr/bin/wp
mv wp-cli.phar /usr/bin/wp

echo Creating WordPress update log file
touch wpupdate.log

echo Writing update script to file
cat <<EOF >wpupdate.sh
#!/bin/bash
timestamp() {
  date "+DATE: %D TIME: %r %Z"
}

tail wpupdate.log -n 100 > wpupdatetmp.log
rm wpupdate.log && mv wpupdatetmp.log wpupdate.log

timestamp
wp theme update --all
wp plugin update --all
wp core language update
wp core update

mail="subject:Update Notification for $domain\nfrom:wpupdate@$domain\nTime to Celebrate!\n\nYour WordPress website $domain is up to date."
echo -e $mail | /usr/sbin/sendmail "$emailto"

exit
EOF

echo Setting .htaccess rule to block direct access to update log and script file
cat <<EOF >.htaccess
<FilesMatch "wpupdate\.log|wpupdate\.sh">
    Order Allow,Deny
    Allow from 127.0.0.1
    Deny from all
</FilesMatch>
EOF

echo Setting cron to execute daily
pwd=$(pwd)
crontab -l > wpupdatecronsetup
echo "32 20 * * * "$pwd"/wpupdate.sh > "$pwd"/wpupdate.log" >> wpupdatecronsetup
crontab wpupdatecronsetup
rm wpupdatecronsetup

exit 0
