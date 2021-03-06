#!/bin/bash
#
# A simple shell to install and configure LEMP & Wordpress
#
# Tested on : Ubuntu 14.04 (Trusty)
#
# ----------------------------------------------------------------------------
#
# Author: Shekhar Raut
#
# ----------------------------------------------------------------------------
#
# Date: June 15, 2014 | Last updated: July 15, 2014
#
# ----------------------------------------------------------------------------
#
# Tools: NGINX, PHP, MySql, WordPress-latest
#
# ----------------------------------------------------------------------------

#----- Color Code --------------------------------

txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
txtblk=$(tput setaf 0)          # Black
txtred=$(tput setaf 1)          # Red
txtgrn=$(tput setaf 2)          # Green
txtylw=$(tput setaf 3)          # Yellow
txtblu=$(tput setaf 4)          # Blue
txtmgn=$(tput setaf 5)          # Magneta
txtcyn=$(tput setaf 6)          # Cyan
txtwht=$(tput setaf 7)          # White
txtrst=$(tput sgr0)             # Reset
bgmgt=$(tput setab 5)
bgred=$(tput setab 1)

#----- Some Variables ----------------------------

DT=`date "+%b %d %T"`
IP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
VERSION=`cat /etc/issue | awk '{print $1,$2,$3}'|sed -n 1p`
LINUX_DISTRO=$(lsb_release -i |awk '{print $3}')

NGINX_HOME=/usr/share/nginx/html
NGINX_LOGS=/var/log/nginx
SCR_INS_LOG=/var/log/script-installation.log

#-------------------------------------------------

#----- Capture Errors ---------------------------
LOG_CAP()
{
	echo "$DT " | tee -ai $SCR_INS_LOG

}

#-------------------------------------------------

if [ "$LINUX_DISTRO" != "Ubuntu" ]
then
	echo -e "$txtbld$bgmgt$txtred This script is configured For Ubuntu $txtrst" || LOG_CAP
	exit 
fi

if [ `whoami` != root ]
then
	echo "$txtbld$bgmgt$txtred Please run this script as root user. $txtrst"
	exit 
fi

echo "`date`" | tee -ai $SCR_INS_LOG
echo -ne " OS Version is $txtbld$bgmgt$txtylw $VERSION $txtrst \n IP_Address is $txtbld$bgmgt$txtylw $IP $txtrst" >> $SCR_INS_LOG

clear

echo -ne "   We are using $txtbld$bgmgt$txtylw $VERSION $txtrst \n    Your IP_Address is $txtbld$bgmgt$txtylw $IP $txtrst" > /tmp/menu

MENU=" `cat /tmp/menu`
    We are going to install Wordpress.
    For efficiency, WE have devide the script into some part. Please find the details make your choise.

	1   Install LEMP Server
	2   Download Wordpress
	3   Install Wordpress with Domain name & other details
	4   quit"

clear

echo "$MENU"
echo -n "Please make your choice: "
read INPUT # Read user input and assign it to variable INPUT

case $INPUT in

   1) ## If User Press 1 Then Script Starts from here

	tput clear
	echo "$txtblu Packages are updating through apt-get, Please wait...... $txtrst"
	apt-get update >> $SCR_INS_LOG

	echo -ne "$txtmgn$txtbld LEMP-Server $txtrst is going to install. \n Please Wait ...................... "  | tee -ai $SCR_INS_LOG 

	#----- Installing Packages -----------------------

	if [ "`dpkg -l nginx | awk '/nginx/ {print $1}'`" = "ii" ]; then
	        echo " $txtylw$txtbld NGINX $txtrst$txtylw is installed. Checking another Package $txtrst " | tee -ai $SCR_INS_LOG 
	else
	        echo " $txtylw$txtbld NGINX $txtrst$txtylw is not install. Installing NGINX $txtrst " | tee -ai $SCR_INS_LOG 
	        apt-get install -y nginx >> $SCR_INS_LOG || LOG_CAP "Unable to install nginx"
	fi

	if [ "`dpkg -l php5-fpm | awk '/php5-fpm/ {print $1}'`" = "ii" ]; then
	        echo " $txtylw$txtbld PHP5-fpm $txtrst$txtylw is installed. Checking another Package $txtrst " | tee -ai $SCR_INS_LOG 
	else
	        echo " $txtylw$txtbld PHP5-fpm Connector $txtrst$txtylw is not install. Installing PHP5-fpm $txtrst " | tee -ai $SCR_INS_LOG 
	        apt-get install -y php5-fpm >> $SCR_INS_LOG || LOG_CAP "Unable to install php5-fpm"
	fi

	if [ "`dpkg -l php5-mysql | awk '/php5-mysql/ {print $1}'`" = "ii" ]; then
	        echo " $txtylw$txtbld PHP-MySql $txtrst$txtylw is installed. Checking another Package $txtrst " | tee -ai $SCR_INS_LOG 
	else
	        echo " $txtylw$txtbld PHP-MySql $txtrst$txtylw is not install. Installing PHP5-MySql $txtrst " | tee -ai $SCR_INS_LOG 
	        apt-get -y install php5-mysql >> $SCR_INS_LOG || LOG_CAP "Unable to install php-mysql"
	fi

	if [ "`dpkg -l mysql-server | awk '/mysql-server/ {print $1}'`" = "ii" ]; then 
	        echo " $txtylw$txtbld Mysql-Server $txtrst$txtylw is installed. Checking another Package $txtrst " | tee -ai $SCR_INS_LOG 
	else
	        echo " $txtylw$txtbld Mysql-Server $txtrst$txtylw is not install. Installing MySql-Server $txtrst " | tee -ai $SCR_INS_LOG 
		read -p "Please enter MySql ROOT Password: " -s MSPS
		echo mysql-server-5.1 mysql-server/root_password password $MSPS | debconf-set-selections
		echo mysql-server-5.1 mysql-server/root_password_again password $MSPS | debconf-set-selections
	        apt-get install -y mysql-server || LOG_CAP "Unable to install mysql-server"
	fi

	if [ "`dpkg -l mysql-client | awk '/mysql-client/ {print $1}'`" = "ii" ]; then 
	        echo " $txtylw$txtbld Mysql-Client $txtrst$txtylw is installed. Checking another Package $txtrst " | tee -ai $SCR_INS_LOG 
	else
	        echo " $txtylw$txtbld Mysql-Client $txtrst$txtylw is not install. Installing Mysql-Client $txtrst " | tee -ai $SCR_INS_LOG 
	        apt-get install -y mysql-client >> $SCR_INS_LOG || LOG_CAP "Unable to install mysql-client"
	fi

        echo " Installing other $txtylw$txtbld PHP Modules $txtrst$txtylw for using various purpose. $txtrst " | tee -ai $SCR_INS_LOG 
        apt-get -y install elinks php5-mysql php5-gd php5-intl php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-tidy php5-xmlrpc php5-xsl php5-xcache 

	/etc/init.d/mysql restart >> $SCR_INS_LOG  
	/etc/init.d/php5-fpm restart >> $SCR_INS_LOG 
	/etc/init.d/nginx restart >> $SCR_INS_LOG 

	echo "<?php" > $NGINX_HOME/info.php
	echo "phpinfo();" >> $NGINX_HOME/info.php
	echo "?>" >> $NGINX_HOME/info.php

	update-rc.d mysql defaults >> $SCR_INS_LOG 
	update-rc.d nginx defaults >> $SCR_INS_LOG 
	update-rc.d php5-fpm defaults >> $SCR_INS_LOG 
	
	clear
	echo "$txtblk$txtbld Please Run script again. And Select Next option $txtrst"
   ;;
	
   2)  ## If User Press 2 Then Script Starts from here

	tput clear
	
	if [ ! -f  latest.tar.gz ]; then
		echo " $txtbld$bgmgt$txtylw Wordpress $txtrst is going to download. Please wait" | tee -ai $SCR_INS_LOG

		wget http://wordpress.org/latest.tar.gz  >> $SCR_INS_LOG

		if [ "$?" = "0" ]; then
	        	echo " Your Wordpress Source has been downloaded successfully. " | tee -ai $SCR_INS_LOG
		else
		        echo -ne " $bgred Wordpress is not downloaded properly.$txtrst  \n $txtmgn Please download it and put it in `pwd` $txtrst " | tee -ai $SCR_INS_LOG 
	        	exit 2
		fi
	else
		echo " $txtred Your Wordpress Source already exist. $txtrst" | tee -ai $SCR_INS_LOG

	fi

	echo "Now $txtblk$txtbld Please Run script again. And Select Next option $txtrst"
   ;;

   3) ## If User Press 3 Then Script Starts from here

	#----- Asking for Domain Details -----------------

	tput clear
	
	echo -en "$txtbld$bgmgt$txtylw Please enter your domain name : $txtrst \n\t eg. google.com yahoo.com \n $txtrst" | tee -ai $SCR_INS_LOG 
	read domain # We get Domain variable
	if [ -n "$domain" ]; then
		echo "Domain name is not blank." >> $SCR_INS_LOG
		echo $domain | grep "\." > /dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo "$bgred Domain name Should have extension $txtrst"
			echo "$txtred Please rerun script again.... $txtrst"
			exit 2
		else
			echo "Domain name inserted" >>  $SCR_INS_LOG
		fi
	else
		echo "$txtred Blank Domain name inserted $txtrst" >> $SCR_INS_LOG
		echo "$bgred Domain name should not be blank. $txtrst"  | tee -ai $SCR_INS_LOG
		echo "$txtred Please rerun script again.... $txtrst"
		exit 2
	fi

	dbname=$domain\_db
	echo -ne "Domain name selected as $txtbld$txtblk $domain $txtrst \nDB_Name automatically Selected as $txtbld$txtblk $dbname  $txtrst" >> $SCR_INS_LOG
	

	echo "$txtbld$bgmgt$txtylw Please enter your Database UserName : $txtrst"
	read dbuser # We get DB-Username
		read -p "Please enter MySql ROOT Password: " -s MSPS
	if [ -n "$dbuser" ]; then
		echo "DB USER name is not blank." >> $SCR_INS_LOG
		mysql -h 127.0.0.1 -P 3306 --user=root --password=$MSPS -e "SELECT User FROM mysql.user;" | grep $dbuser
			if [ "$?" = "0" ]; then
				echo " $bgred DB Username $dbuser already exist, Please select another username $txtrst " | tee -ai $SCR_INS_LOG
			exit 2
			fi
	else
		echo "$txtred Blank DB User name inserted $txtrst" >> $SCR_INS_LOG
		echo "$bgred DB User name should not be blank. $txtrst"  | tee -ai $SCR_INS_LOG
		echo "$txtred Please rerun script again.... $txtrst"
		exit 2
	fi

	echo "DB_User name selected as $txtbld$txtblk $dbuser $txtrst" >> $SCR_INS_LOG

	echo -e "$txtbld$bgmgt$txtylw \n Please enter password for Database UserName: $txtrst"
	read dbpasswd # We get Password
	if [ -n "$dbpasswd" ]; then
		echo "DB Password is not blank." >> $SCR_INS_LOG
	else
		echo "$txtred Blank DB password inserted $txtrst" >> $SCR_INS_LOG
		echo "$bgred DB Password should not be blank. $txtrst"  | tee -ai $SCR_INS_LOG
		echo "$txtred Please rerun script again.... $txtrst"
		exit 2
	fi

	echo "DB_Password selected as $txtbld$txtblk $dbpasswd  $txtrst" >> $SCR_INS_LOG
	
	#----- Adding some entries and Creating needful directories
	
	if [ ! -d $NGINX_LOGS/$domain ]; then
		mkdir $NGINX_LOGS/$domain
	else
		echo "Log Folder/File already exist for the mentioned domain" >>  $SCR_INS_LOG
		exit 2
	fi

	if [ ! -f  /etc/nginx/sites-available/$domain ]; then

echo "
server {
        listen   80;


        root $NGINX_HOME/$domain;
        index index.php index.html index.htm;

        server_name $domain www.$domain;
        
        access_log $NGINX_LOGS/$domain/access.log;
        error_log $NGINX_LOGS/$domain/error.log;


        location / {
                try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
        }

        error_page 404 /404.html;

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
              root $NGINX_HOME;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        location ~ \.php$ {
                try_files \$uri =404;
                # With php5-fpm:
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params;
                 }
        

}" > /etc/nginx/sites-available/$domain

	else
		echo "$bgred NGINX Config File already exist. $txtrst"
		exit 2
	fi

	#----- Wordpress Process starts here -------------

	if [ -f latest.tar.gz ] ; then
		tar xvf latest.tar.gz > /dev/null 2>&1
		if [ "$?" = "0" ]; then
			if [ -d  $NGINX_HOME/$domain ]; then
				echo " $bgred Wordpress already exist.$txtrst "
				exit 101
			else
				cp -r wordpress  $NGINX_HOME/$domain
			fi
		else
	        	echo -ne " $bgred Wordpress is not downloaded properly.$txtrst  \n $txtmgn Please Run Script Again OR download it and put it in `pwd` $txtrst "  | tee -ai $SCR_INS_LOG 
			rm -rf latest.tar.gz
	        	exit 2
		fi
	else
	        echo "Please copy the Wordpress Source in `pwd`  Aborting." 1>&2
	        exit 1
	fi

	#----- Creating Database -------------------------

		echo "CREATE DATABASE \`$dbname\`; GRANT ALL PRIVILEGES ON \`$dbname\`.* TO '$dbuser'@'localhost' IDENTIFIED BY '$dbpasswd';FLUSH PRIVILEGES;" > /tmp/wordpress

		mysql -h 127.0.0.1 -P 3306 --user=root --password=$MSPS --default_character_set=utf8 < /tmp/wordpress
		if [ "$?" != "0" ]; then
			echo " $bgred Password not entered properly $txtrst " | tee -ai $SCR_INS_LOG
			exit 2
		fi

	#----- Wordpress Configuration -------------------

	cp $NGINX_HOME/$domain/wp-config-sample.php $NGINX_HOME/$domain/wp-config.php

	sed -i "/DB_NAME/ s/database_name_here/$dbname/" $NGINX_HOME/$domain/wp-config.php
	sed -i "/DB_USER/ s/username_here/$dbuser/" $NGINX_HOME/$domain/wp-config.php
	sed -i "/DB_PASSWORD/ s/password_here/$dbpasswd/" $NGINX_HOME/$domain/wp-config.php
	sed -i "/DB_HOST/ s/localhost/127.0.0.1/" $NGINX_HOME/$domain/wp-config.php

	#----- Adding Secrete Keys ------------------
	SALT=$(curl -sLS https://api.wordpress.org/secret-key/1.1/salt/ 2>&1) 
	STRING='put your unique phrase here'
	printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s $NGINX_HOME/$domain/wp-config.php

	#----- Sites Enabling and preparing for access -----

	ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/

	chown -R www-data:www-data $NGINX_HOME/$domain

	rm -rf /tmp/wordpress

	/etc/init.d/nginx reload >> $SCR_INS_LOG 

	echo -e "$IP \t\t $domain \t\t www.$domain \n"  >> /etc/hosts
		if [ "$?" = "0" ]; then
			echo "Host Entry Added to /etc/hosts" >>  $SCR_INS_LOG
		else
			echo "Host Entry not Added to /etc/hosts, Please add it manualy"  | tee -ai $SCR_INS_LOG 
			exit 2
		fi


	#----- Final Information -------------------------

	# ----- Service Check -----

	if [ "`service mysql status | awk '{print $2}' | awk -F "/" '{print $2}'`" = "running," ]; then
		echo " $txtbld$txtcyn Mysql Service $txtblu is Running $txtrst "  | tee -ai $SCR_INS_LOG 
		sleep 2
	else
		clear
		echo -ne " $bgred Mysql Service is not running.$txtrst  \n $txtmgn Please check error logs $txtrst "  | tee -ai $SCR_INS_LOG 
		exit
	fi

	if [ "`service nginx status | awk '{print $4}'`" = "running" ]; then
		echo " $txtbld$txtcyn NGINX Service $txtblu is Running $txtrst "  | tee -ai $SCR_INS_LOG 
		sleep 2
	else
		clear
		echo -ne " $bgred NGINX Service is not running.$txtrst  \n $txtmgn Please check error logs $txtrst "  | tee -ai $SCR_INS_LOG 
		exit
	fi

	if [ "`service php5-fpm status | awk '{print $2}' | awk -F "/" '{print $2}'`" = "running," ]; then
		echo " $txtbld$txtcyn PHP-FPM Service $txtblu is Running $txtrst "  | tee -ai $SCR_INS_LOG 
		sleep 2
	else
		clear
		echo -ne " $bgred PHP-FPM Service is not running.$txtrst  \n $txtmgn Please check error logs $txtrst " | tee -ai $SCR_INS_LOG 
		exit
	fi

	# ----- DB Check -----

	DB_EXIST=`mysqlshow -h 127.0.0.1 -P 3306 --user=root --password=$MSPS $dbname| grep -v Wildcard | grep -o $dbname`
	if [ "$DB_EXIST" = "$dbname" ]; then
		echo " $txtblu Databse for $txtbld$txtcyn $domain $txtrst$txtblu is fine $txtrst " | tee -ai $SCR_INS_LOG 
		sleep 2
	else
		clear
		echo -ne " $bgred Database for $domain is not exist.$txtrst  \n $txtmgn Please check error logs $txtrst " | tee -ai $SCR_INS_LOG 
		exit
	fi

	# ----- Directory Check -----

	if [ -d  $NGINX_HOME/$domain ]; then
		echo " $txtblu Setup Directory for $txtbld$txtcyn $domain $txtrst$txtblu exist.$txtrst " | tee -ai $SCR_INS_LOG 
		sleep 2
	else
		clear
		echo -ne " $bgred Setup Directory for $domain is not exist.$txtrst  \n $txtmgn Please check error logs $txtrst " | tee -ai $SCR_INS_LOG 
		exit 
	fi

	# ----- NGINX  Domain Conf Check -----

	if [  -f  /etc/nginx/sites-available/$domain ]; then
		echo " $txtblu NGINX Conf for $txtbld$txtcyn $domain $txtrst$txtblu is fine $txtrst " | tee -ai $SCR_INS_LOG 
		sleep 2
	else
		clear
		echo -ne " $bgred NGINX Setup for $domain is not done properly.$txtrst  \n $txtmgn Please check error logs $txtrst " | tee -ai $SCR_INS_LOG 
		exit
	fi

	# ----- NGINX Conf Check -----

	nginx -t >> $SCR_INS_LOG 
	if [ "$?" = "0" ]; then
		echo -ne "$txtbld$txtcyn NGINX Conf $txtrst$txtblu is tested okey $txtrst " | tee -ai $SCR_INS_LOG 
		sleep 2
		clear
		echo -ne " $txtblu All Configuration seems okey  \n  Please go through URL $txtmgn http://$domain \n $txtblu To setup Worpress for further configuration. \n$txtbld$txtblk Thank you for using script. \n $txtrst  " | tee -ai $SCR_INS_LOG 
	else
		clear
		echo -ne " $bgred Setup is not done properly. NGINX conf error$txtrst  \n $txtmgn Please check error logs $txtrst " | tee -ai $SCR_INS_LOG 
		exit
	fi

   ;;

   4|q|Q) # If user presses 4, q or Q we terminate

            tput clear
	    exit 0

   ;;

   *) # All other user input results in an usage message
	tput clear
	echo "$bgred Please choose alternatves 1, 2, 3, 4 $txtrst"
	
   ;;

esac
