#!bin/bash
#myname="Angelin"
#s3_bucket="upgrad-angelinmariya"

#Getting all Updates
apt-get update -y

#Checking if Apache is installed
dpkg -s apache2 &> /dev/null
stateApache=$?
#echo "$stateApache"

if [ $stateApache -ne 0 ]

        then
            echo "not installed"
            apt-get install apache2 -y
fi

status=$(service apache2 status | grep active | awk '{print $3}')
#echo "$status"

#checking if apache2 is installed/running/stopped
running="(running)"
dead="(dead)"

if [[ "$status" = "$running"  ]]
then
        echo "Running "

elif [[ "$status" = "$dead" ]]
then
        echo "Apache is stopped"
        service apache2 start
        sleep 5
        echo "Apache is restarted"
else
        echo "Apache not installed"
        apt-get install apache2 -y
        sleep 5
        echo "Apache installed"
fi

#Checking if Apache service is enabled
serviceStatus=$(service apache2 status | grep Loaded | awk '{print $4}')
#echo "$serviceStatus"

if [[ "$serviceStatus" = "enabled;" ]]
then
        echo "Service Enabled"
else
        echo "Enabling service on Reboot"
        update-rc.d apache2 defaults
fi

#creating Tar file
myname="Angelin"
timestamp=$(date '+%d%m%Y-%H%M%S')
fileName=$myname-httpd-logs-$timestamp
#echo "$fileName"

mkdir -p  /var/log/apache2/tmp
tar -cf /var/log/apache2/tmp/$fileName.tar  /var/log/apache2/*.log

#copying to S3 bucket
s3_bucket="upgrad-angelinmariya"

aws s3 \
cp /var/log/apache2/tmp/${fileName}.tar \
s3://${s3_bucket}


