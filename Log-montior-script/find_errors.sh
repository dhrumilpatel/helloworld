#!/bin/sh

#*******************************************************************************
# Variables
#*******************************************************************************

logfile_dir=/home/ec2-user/helloworld/Log-montior-script
#file=$( ls -At log.log $dir )
logfile=useractivity_logfile.log
logmonitor_dir=/home/ec2-user/helloworld/Log-montior-script

var=$(date +"%FORMAT_STRING")
now=$(date +"%m_%d_%Y")
today=$(date +"%Y-%m-%d")


#*******************************************************************************
# Functions
#*******************************************************************************
usage()
{
  echo "#############################"
  echo "USAGE :  sh find_errors.sh  "
  echo "This script does not accept any arguments, log directory are hardcoded, change it before running the script"
  echo "#############################"
  echo "############# Description ################"
  echo "This script looks into useractivity_logfile.log and monitors ERROR enteries; save them in an output file for further analysis."
  echo "#############################"
  echo "Extra Scope  --> 1. For a dynamically growing/lotating logfile, add this script to crontab jobs for every minute, and uncomment the tail command provided in the script. "
  echo "                 2. Create a suitable crontab Job"
  echo "##########################################"
  echo
  echo
  exit 1
}

if [ "$1"  == "--help" ];then
  usage
  exit 0
#else
#echo $dir
#echo $file
fi

#tail -f -n +0 ${logfile_dir}/${logfile}| grep -B2 "ERROR" | grep -v "\-\-"|awk '/ERROR/ {$0=$0" -------"} 1'>$logmonitor_dir/${logfile}_stauts_${today}.log


grep -B2 "ERROR" ${logfile_dir}/${logfile}| grep -v "\-\-"|awk '/ERROR/ {$0=$0"-------"} 1'>$logmonitor_dir/${logfile}_status_${today}.log

