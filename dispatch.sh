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

dnf install golang -y &>>$log_file
VALID $? "Installing Go Language"

id roboshop
if [ $? -ne 0 ]
then 
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
else 
echo "User already exists"
fi
VALID $? "Adding User" 

mkdir -p /app &>>$log_file
VALID $? "Creating app directory"

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>$log_file
VALID $? "Downloading zip files" 

rm -rf /app/*
cd /app 
unzip /tmp/dispatch.zip &>>$log_file
VALID $? "Unzipping the files in app directory"

go mod init dispatch &>>$log_file
go get  &>>$log_file
go build &>>$log_file
VALID $? "Loading Dependencies"

cp $pwd/dispatch.service /etc/systemd/system/dispatch.service &>>$log_file
VALID $? "Copying service files"

systemctl daemon-reload &>>$log_file
VALID $? "Reloading"

systemctl enable dispatch  &>>$log_file
systemctl start dispatch &>>$log_file
VALID $? "Enabling and Starting Dispatch Service"