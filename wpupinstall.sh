#!/bin/bash

##
#   This script must be executed from your WordPress website root directory. In most cases that will be
#   /home/$USERNAME/public_html directory, or
#   /home/$USERNAME/public_html/$WORDPRESS directory
#
#   XXXXX Installation XXXXX Run the commands below
#   wget https://raw.githubusercontent.com/charter-hosting/wp-cli-wp-auto-updater/master/wpupinstall.sh --no-check-certificate
#   chmod +x wpupinstall.sh
#   ./wpupinstall.sh
#   rm wpupinstall.sh
#
#   ---------------------------
#   NOTE: If your hosting account is chrooted/jailkit, and there is no Unix Socket connection for WP-CLI,
#   tell WP-CLI to use a TCP connection instead with the "if ( defined( 'WP_CLI' ) && WP_CLI )" statement.
#
#   Open the wp-config.php file and replace these lines:
#
#   /** MySQL hostname */
#   define('DB_HOST', 'localhost:3306');
#   
#   With these lines:
#
#   /** Tell WP-CLI to use TCP instead of socket connection */
#   if ( defined( 'WP_CLI' ) && WP_CLI ) {
#   /** MySQL hostname for WP-CLI */
#   define('DB_HOST', '127.0.0.1:3306');
#   } else {
#   /** MySQL hostname */
#   define('DB_HOST', 'localhost'); }
##

# Change the values below prior to executing the script.
domain=example.com
emailto=you@example.com

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar --no-check-certificate
chmod +x wp-cli.phar
mv wp-cli.phar /usr/bin/wp

touch wpupdate.log

cat <<EOF >wpupdate.sh
#!/bin/bash
timestamp() {
  date "+DATE: %D TIME: %r %Z"
}
timestamp
wp theme update --all
wp plugin update --all
wp core language update
wp core update
exit
EOF

cat <<EOF >.htaccess
<FilesMatch "wpupdate\.log|wpupdate\.sh">
    Order Allow,Deny
    Allow from 127.0.0.1
    Deny from all
</FilesMatch>
EOF

pwd=$(pwd)
crontab -l > wpupdatecronsetup
echo "32 20 * * * "$pwd"/wpupdate.sh > "$pwd"/wpupdate.log" >> wpupdatecronsetup
crontab wpupdatecronsetup
rm wpupdatecronsetup

mail="subject:"$domain"""Update Notification\nfrom:notify@charterhosting.com\nTime to Celebrate!\n\nYour WordPress website"""$domain"""is up to date."
echo -e $mail | /usr/sbin/sendmail "$emailto"

exit 0
