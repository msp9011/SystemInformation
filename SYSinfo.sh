#!/bin/bash

SYSINFO=`head -n 1 /etc/issue`
IFS=$'\n'
DATE=`date`
KERNEL=`uname -a`
CPU=`arch`

echo -e "<=== SYSTEM SUMMARY ===>"
echo "  Distro infoi  , "$SYSINFO""
echo -e "  Kernel\t, "$KERNEL""
free -hot | awk '
/Mem/{print "  Memory\t, "$2 ""}
/Swap/{print "  Swap\t\t, "$2 ""}'
echo -e "  Architecture\t, "$CPU""
echo -e " `cat /proc/cpuinfo | grep "model name" | uniq -c | sed 's/model name/Processor/;s/:/,/' | awk '{ $2=$2 "("$1")";$1=""; print }'`"
echo -e "  Date\t\t, "$DATE""


echo -e "\n\n<=== MEMORY DETAILS===>"
DMEMOUT=$(dmidecode --type memory)
PHYMEM=$(echo "$DMEMOUT"|sed -n -e '/Memory Device/,$p')

echo -e "Total RAM (/proc/meminfo)\t\t, " $(grep MemTotal /proc/meminfo | awk '{print $2/1024/1024}') "GiB"
echo -e "No. Of Memory Module(s) Found\t\t, `echo "$DMEMOUT"|grep -w "Size"|grep -vc "No Module Installed"`/`echo "$DMEMOUT"|grep -wc "Size"`"
echo -e "\n\nSize,Form Factor,Locator,Bank Locator,Type,Type Detail,Speed,Manufacturer,Serial Number,Part Number"
echo -e "`echo "$PHYMEM" | grep -E '[[:blank:]]Size: [0-9]+' -A11|egrep -v "Set|Tag"|awk -F: '{print $2}'|sed  -e 's/^\s*//' | tr '\n' ',' | sed 's/,,/\n/g'`"

echo -e "\n\n<=== PROCESSOR DETAILS ===>"
LPROC=$(dmidecode --type processor)

echo -e "Manufacturer\t\t\t\t," $(echo "$LPROC"|grep Manufacturer|uniq|awk '{print $2}') 
echo -e "Model Name\t\t\t\t," $(echo "$LPROC"|grep Version|uniq|sed -e 's/Version://' -e 's/^[ \t]*//') 
echo -e "CPU Family\t\t\t\t," $(grep "family" /proc/cpuinfo|uniq|awk -F: '{print $2}') 
echo -e "CPU Stepping\t\t\t\t," $(grep "stepping" /proc/cpuinfo|awk -F: '{print $2}'|uniq)

if [ -e /usr/bin/lscpu ]
then
 echo -e "No. Of Processor(s)\t\t\t," $(lscpu|grep -w ^"CPU(s)"|awk '{print $2}') 
 echo -e "No. of Core(s) per processor\t\t," $(lscpu|grep -w "Core(s) per socket:"|awk -F: '{print $2}') 
else
 echo -e "No. Of Processor(s) Found\t\t," $(grep -c processor /proc/cpuinfo) 
 echo -e "No. of Core(s) per processor\t\t," $(grep "cpu cores" /proc/cpuinfo|uniq|wc -l) 
fi
echo -e "\nSocket Number,Type,Family,Max Speed,Serial Number,Asset Tag,Part Number,Thread Count"
dmidecode --type processor | egrep -w -m40 "Socket Designation:|Type:|Family:|Max Speed:|Serial Number:|Asset Tag:|Part Number:|Thread Count:| | " | sed 's/Socket/\nSocket/g' | awk -F ':' '{print $2}' | tr '\n' ',' | sed 's/,,/\n/g;s/^,//g;s/,$//g'


echo -e "\n\n<=== MOTHERBOARD DETAILS ===>"
echo -e "\nManufacturer,Product Name,Version,Serial Number,"
dmidecode -t 2 | egrep -w 'Manufacturer:|Product Name:|Version:|Serial Number:' | sed 's/:/,/g;s/^\t//g'

echo -e "\n\n<=== DISK DETAILS ===>"
LDISK=(`/sbin/fdisk -l 2> /dev/null|grep Disk|grep bytes|egrep -v "loop|mapper|md|ram" | awk -F '[ :,]' '{print $2}'`)
echo -e "Disk,Vendor,Product,Serial,Size"
 for L in ${LDISK[@]};do
  DISKinfo=`/usr/sbin/smartctl -i /dev/sda | egrep -w 'Vendor:|Product:|Serial number:|User Capacity:'  | awk -F '[:[]' '{print $NF}' | sed 's/  //g;s/]//g;'| tr '\n' ','`
  echo -e "$LDISK,$DISKinfo"
 done
 
 echo -e "\n\n<=== CHASSIS DETAILS ===>"
  dmidecode --type chassis | egrep -w 'Manufacturer:|Serial Number:' | tr ':' ','
 

 
 
 dmidecode --type 9 | egrep 'Designation:|Current Usage:|Bus Address:' | sed 's/Designation:/\nDesignation:/g' | awk -F ':' '{$1="";print}' | tr '\n' ',' | sed 's/,,/\n/g;s/^,//g'
 
 