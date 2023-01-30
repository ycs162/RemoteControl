#!/bin/bash

# This script is Done by:
# Name: Yap Ching Siong
# Student code: S14
# Class: CFC2407
# Lecturer: James

#This script is created to allow local machine to access remote server(SSH in this script), then perform nmap, masscan, and whois scan from the remote server.
# The scanned results will be copy back to local machine, and remove from the remote server.
# The assumption for this script is that both local machine and remote server does not have the tools/updates installed for all tasks.
# Prior to the scanning, necssary tools installation for all tasks will run on both local machine and remote server.
# Tools update and installation that will be perfomed on local machine: 
# 1. Update package list of repositories
# 2. Nipe   
# 3. sshpass

# Tools update and installation that will be perfomed on remote server:
# 1. Update package list of repositories
# 2. nmap
# 3. masscan
# 4. Whois 

# inst function will perform Tools update and installation on local machine.
# anon function will activate Nipe, check identity of local machine to ensure it is anonymous(not from SG),
#  perform Tools update and installation on remote server, request user intput of target and other info,
#  perform scan(nmap, masscan, whois) from remote server to target, copy scan results to local machine and delete scan results from remote server.

# NOTE: User inputs are required throughout the execution of this script.


#Credits:
#NIPE -- Fully Anonymize Total Kali Linux System
#https://www.kalilinux.in/2022/02/total-anonymous-kali-linux.html

# How to put sshpass command inside a bash script?
# https://exchangetuts.com/how-to-put-sshpass-command-inside-a-bash-script-1640250664982761

# sudo over ssh: no tty present and no askpass program specified
# https://unix.stackexchange.com/questions/48554/sudo-over-ssh-no-tty-present-and-no-askpass- program-specified

# Bash Scripting – If Statement
# https://www.geeksforgeeks.org/bash-scripting-if-statement/

# How to Install Nipe tool in Kali Linux?
# https://www.geeksforgeeks.org/how-to-install-nipe-tool-in-kali-linux/


function createDir()
{
wDir=$(pwd)
if [ ! -d "$wDir/RemoteControl" ]
then
	mkdir $wDir/RemoteControl
fi
}

createDir

function inst()
{
	echo "*********************************************"
	echo "Starting Tools Installation On Local Machine." 
	echo "User Inputs Are Required During Installation."
	echo "*********************************************"
	sleep 5
	sudo apt-get -q update
	git clone -q https://github.com/htrgouvea/nipe
	cd $wDir/nipe
	sudo cpan install Try::Tiny Config::Simple JSON
	sudo perl nipe.pl install
	sudo apt-get -qq install sshpass -y 
	echo "*****************************"	
	echo "Tools Installation Completed."
	echo "*****************************"
}

inst



function anon()
{
echo
echo
echo "*******************************************************"
echo "Activating Nipe And Checking Identity Of Local Machine."
echo "*******************************************************"
cd $wDir/nipe
sudo perl nipe.pl start
sleep 10
if [ $(sudo curl -s ifconfig.io/country_code | tr -d [:space:] | wc -c ) -ne 2 ] || [ $(sudo curl -s ifconfig.io/country_code | tr -d [:space:] | wc -c) == SG ]
then	
		while [ $(sudo curl -s ifconfig.io/country_code | tr -d [:space:] | wc -c ) -ne 2 ]  || [ $(sudo curl -s ifconfig.io/country_code | tr -d [:space:] | wc -c) == SG ]
		do	
			sudo perl nipe.pl restart
			sleep 10
		done
	echo
	echo
	echo "*******************************************"	
	echo "Identity Of Local Machine Is Anonymous.    "
	echo "Please Enter Prerequsites To Perform Scans."
	echo "*******************************************"
else
	echo
	echo
	echo "*******************************************"	
	echo "Identity Of Local Machine Is Anonymous.    "
	echo "Please Enter Prerequsites To Perform Scans."
	echo "*******************************************"
fi
sleep 5

read -p "Enter the IP address of remote server: " ip
read -p "Enter the username of remote server: " username
read -p "Enter password of remote server: " password
read -p "Enter the Ip address that you want to scan: " targetip
read -p "Enter the port that to scan (eg. 50 or 1-50 or 1,20,30): " port
read -p "Enter the name of file you want to save as: " filename

sshdir=$(sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip "pwd")
echo
echo
echo "*************************************************************"
echo "Installing Tools Required For Scanning.                      " 
echo "Remote Server Password Input Is Required During Installation."
echo "*************************************************************"
sleep 5
sshpass -p $password ssh -t $username@$ip "sudo apt-get update -y"
sshpass -p $password ssh -t $username@$ip "sudo apt-get install nmap -y"
sshpass -p $password ssh -t $username@$ip "sudo apt-get install masscan -y"
sshpass -p $password ssh -t $username@$ip "sudo apt-get install whois -y"
echo 
echo
echo "***************"
echo "Tools Installed"
echo "***************"
sleep 5
echo
echo
echo "*********************************************************"
echo "Starting Scans.                                          "
echo "Remote Server Password Input Is Required During Scanning."
echo "*********************************************************"
sleep 5
sshpass -p $password ssh -t $username@$ip "sudo masscan $targetip -p$port --open -oG masscan$filename.grep"
sshpass -p $password ssh -t $username@$ip "sudo nmap $targetip -p$port -sV -O -vv -oA $filename" 
sleep 5
sshpass -p $password ssh $username@$ip "whois $targetip > whois$filename"
echo
echo
echo "*****************************"
echo "Scanning On Target Completed."
cd $wDir/RemoteControl
mkdir $filename
sshpass -p $password scp $username@$ip:$sshdir/*$filename* ./$filename
echo "Scan Results Copied To Local Machine."
sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip "rm -r $sshdir/*$filename*" 
echo "Scan Results Deleted From Remote Server."
echo "All Files On Local Computer Can Be Found In $wDir/RemoteControl folder"
echo "****************************************************************************"
}

anon
