#!/bin/bash

#-----1-----
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

logs_folder="/var/log/roboshop"
script_name=$(echo $0 | cut -d "." -f1) 
log_file="$logs_folder/$script_name.log"

mkdir -p $logs_folder

pwd=$PWD


#checks user id
if [ $USERID -eq 0 ]

then 
   echo -e "$G User has root access " | tee -a &log_file
else
   echo -e "$R User doesn't have root access " | tee -a &log_file
   exit 1
fi


VALID() {
if [ $1 -eq 0 ]
then
    echo -e "$N $2 is ....$G Successful" | tee -a &log_file
else
    echo -e "$N $2 is ....$R Failure" | tee -a &log_file
    exit 1
fi 
}

dnf install maven -y &>>$log_file &>>$log_file
VALID $? "Installing maven"

id roboshop
if [$? -ne 0]
then 
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
else 
echo "User already exists"
fi
VALID $? "Adding User" 

mkdir --p /app  &>>$log_file
VALID $? "Creating Directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip
VALID $? "Downloading Zipfile"

cd /app 
unzip /tmp/shipping.zip
VALID $? "Unzipping Zipfile"

mvn clean package 
mv target/shipping-1.0.jar shipping.jar
VALID $? "Downloading dependencies"

cp shipping.service /etc/systemd/system/shipping.service
VALID $? "Coping service"

systemctl daemon-reload
VALID $? "Service reloading"

systemctl enable shipping 
systemctl start shipping
VALID $? "Enabling and starting shipping"


dnf install mysql -y 
VALID $? "Installing mysql"


mysql -h mysql.84dev.store -uroot -pRoboShop@1 < /app/db/schema.sql
VALID $? "Loading schema to IP"

mysql -h mysql.84dev.store -uroot -pRoboShop@1 < /app/db/app-user.sql 
VALID $? "Loading userdata to IP"

mysql -h mysql.84dev.store -uroot -pRoboShop@1 < /app/db/master-data.sql
VALID $? "Loading MasterData to IP"

systemctl restart shipping
VALID $? "Restarting Shipping"