#!/bin/bash


path_log='/var/log/nginx'
log_access='*access*'
log=$path_log/$log_access

user_agent='Hydra|sqlmap|Nmap|"Python-urllib"|Shiretoko|"python-requests"|Riddler|DirBuster|owasp|OWASP' #|'Windows\ NT' libwww-perl
NT="|Windows NT"

my_ip='1.2.3.4'

 
 work=/var/run/ip_access_ban
  
  if [ -f $work ]; then

	echo 
	echo "Script is running! "
	echo "Or if not process please delete $work file"
	
	exit 6
  fi

   touch $work
	
	sort=`echo grep -P "$user_agent"`

	for i in $log ;do
	
        ip_t_ban=`tail -1000 $i | $sort"$NT" | awk '{ print $1 }' | sort | uniq | grep -E '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}' `
	
	   for ip_ban in $ip_t_ban ; do
	
	   if [[ $ip_ban != $my_ip ]] ; then

		ip_find=`iptables -nvL | grep 'DROP' | grep $ip_ban | awk {'print $8; '} `

	        if [[ $ip_ban == $ip_find ]] ; then
	
        	   echo "This ip $ip_ban from banned "
           	   echo "Enter to another ip"
             	
	  	  else

     		  echo 
		  echo "This not my ip address"
		
		  iptables -A INPUT -s $ip_ban -j DROP
 	          iptables -nvL | grep 'DROP' | grep $ip_ban

		fi
	      
	      else 

	       echo
	       echo "This my ip $ip_ban not banned"

	  fi
	   
	   done

	done

   rm -vf $work




