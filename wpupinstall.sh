#!/bin/bash

#########################################################
#                                                     	#
#	 This script must be executed from your WordPress     #
#	 website root directory. In most cases that will be   #
#	 /home/$USERNAME/public_html directory, or            #
#	 /home/$USERNAME/public_html/$WEBSITE directory       #
#	                                                      #
#   Installation                                        #
#   1.    wget                                          #
#   2.    chmod +x wpupinstall.sh					            	#
#   3.    ./wpupinstall.sh						              		#
#   4.    rm wpupinstall.sh			              					#
#				                        							    			#
#########################################################

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
wp core update
wp core language update --all
wp theme update --all
wp plugin update --all
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
crontab -l > wpupdatecron
echo "32 20 * * * "$pwd"/wpupdate.sh > "$pwd"/wpupdate.log" >> wpupdatecron
crontab wpupdatecron
rm wpupdatecron

exit
