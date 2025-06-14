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

dnf module disable redis -y
VALID $? "Disabling older redis"

dnf module enable redis:7 -y
VALID $? "Enabling redis version 7"

dnf install redis -y  &>>$log_file
VALID $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode yes/ c protected-mode no' /etc/redis/redis.conf
VALID $? "Substitiuting localhost for remote connections"

systemctl enable redis &>>$log_file
VALID $? "Enabling redis"

systemctl start redis &>>$log_file
VALID $? "Starting redis"
