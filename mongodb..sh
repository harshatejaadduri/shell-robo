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



#checks user id
if [ $USERID -eq 0 ]

then 
   echo -e "$G User has root access "
else
   echo -e "$R User doesn't have root access "
   exit 1
fi


VALID() {
if [ $1 -eq 0 ]
then
    echo -e "$2 is ....$G Successful"
else
    echo -e " $2 is ....$R Failure"
    exit 1
fi 
}

cp mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y  &>>$log_file
VALID $? "Installing mongodb"

systemctl enable mongod 
VALID $? "Enabling mongodb"

systemctl start mongod 
VALID $? "Starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALID $? "Substitiuting localhost for remote connections"

systemctl restart mongod
VALID $? "Restarting mongodb"
