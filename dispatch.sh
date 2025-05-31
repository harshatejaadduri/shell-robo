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

dnf install golang -y
VALID "$?" "Installing Go Language"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALID "$?" "Installing Go Language"

mkdir /app 
VALID "$?" "Creating app directory"

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip 
VALID "$?" "Downloading zip files"

cd /app 
unzip /tmp/dispatch.zip
VALID "$?" "Unzipping the files in app directory"

go mod init dispatch
go get 
go build
VALID "$?" "Loading Dependencies"

cp dispatch.service /etc/systemd/system/dispatch.service
VALID "$?" "Copying service files"

systemctl daemon-reload
VALID "$?" "Reloading"

systemctl enable dispatch 
systemctl start dispatch
VALID "$?" "Enabling and Starting Dispatch Service"