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
   echo -e "$G User has root access " | tee -a $log_file
else
   echo -e "$R User doesn't have root access " | tee -a $log_file
   exit 1
fi


VALID() {
if [ $1 -eq 0 ]
then
    echo -e "$N $2 is ....$G Successful" | tee -a $log_file
else
    echo -e "$N $2 is ....$R Failure" | tee -a $log_file
    exit 1
fi 
}

dnf install python3 gcc python3-devel -y &>>$log_file
VALID $? "Installing python"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
VALID $? "Installing python"

mkdir /app  &>>$log_file
VALID $? "Creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$log_file
VALID $? "Downloading Zipfile "

cd /app 
unzip /tmp/payment.zip &>>$log_file
VALID $? "Unzipping"
 
pip3 install -r requirements.txt &>>$log_file

cp payment.service /etc/systemd/system/payment.service &>>$log_file
VALID $? "Copying payment.service"

systemctl daemon-reload
VALID $? "Reloading"

systemctl enable payment &>>$log_file
systemctl start payment &>>$log_file
VALID $? "Enabling and Starting Payment service"

