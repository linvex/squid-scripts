#!/bin/bash
########################################################################
# allPornInternet.sh  --- bash script (Setup & configure dansguardian) #
# g0tmi1k 2011-04-05  --- Original Idea: http://prank-o-matic.com      #
########################################################################
# Note ~ ONLY tested with BackTrack 4-RC2                              #
#    Very quick & very dirty coding                                    #
########################################################################
#       *** Do NOT use this for illegal or malicious use ***           #
#     By running this, YOU are using this program at YOUR OWN RISK     #
# This software is provided "as is", WITHOUT ANY guarantees OR warranty#
########################################################################

if [ "$(id -u)" != "0" ]; then echo "Run as root!" 1>&2; exit; fi
current="$(pwd)"

echo -e "------------------------------------------------------------------------\nDownloading..."
apt-get -y install libpcre3 libpcre3-dev
wget -P /tmp "http://dansguardian.org/downloads/2/Stable/dansguardian-2.10.1.1.tar.gz"


echo -e "------------------------------------------------------------------------\nExtacting..."
cd "/tmp" && tar zxvf dansguardian-2.10.1.1.tar.gz; rm "/tmp/dansguardian-2.10.1.1.tar.gz"; cd "/tmp/dansguardian-2.10.1.1/src/"


echo -e "------------------------------------------------------------------------\nPatching..."
sed -i "s/#include <math.h>/#include <math.h>\n#include <stdio.h>/g" "/tmp/dansguardian-2.10.1.1/src/downloadmanagers/fancy.cpp"
echo "--- NaughtyFilter.cpp.orig 2009-07-23 23:03:13.000000000 -0400
+++ NaughtyFilter.cpp 2009-07-24 19:13:43.000000000 -0400
@@ -85,6 +85,18 @@
 // check the given document body for banned, weighted, and exception phrases (and PICS, and regexes, &c.)
 void NaughtyFilter::checkme(DataBuffer *body, String &url, String &domain)
 {
+  // skip content scan on JavaScript and style sheets
+  url.hexDecode(); /* superfluous? */
+  String urll;
+  urll = url;
+  urll.toLower();
+  if (urll.contains(\"?\"))
+     urll = urll.before(\"?\");
+
+  if (urll.length() >= 4)
+     if (urll.endsWith(\".js\") || urll.endsWith(\".css\"))
+        return;
+
   // original data
   off_t rawbodylen = (*body).buffer_length;
   char *rawbody = (*body).data;
@@ -827,7 +839,7 @@
      return;
   }

-  if (weighting > (*o.fg[filtergroup]).naughtyness_limit) {
+  if (weighting < (*o.fg[filtergroup]).naughtyness_limit) {
      isItNaughty = true;
      whatIsNaughtyLog = o.language_list.getTranslation(402);
      // Weighted phrase limit of" > "/tmp/dansguardian-2.10.1.1/src/NaughtyFilter.cpp.patch"
patch -p0 < NaughtyFilter.cpp.patch   # patch -R -p0 < NaughtyFilter.cpp.patch


echo -e "------------------------------------------------------------------------\nCompiling..."
cd "/tmp/dansguardian-2.10.1.1" && ./configure --prefix=/usr/local --with-proxyuser=nobody --with-proxygroup=nogroup --localstatedir=/var --sysconfdir=/etc --with-piddir=/var/run --with-logdir=/var/log/dansguardian --mandir=/usr/man --bindir=/usr/sbin && make

while getopts "ur" OPTIONS; do
   case ${OPTIONS} in
      u | r ) make uninstall; exit;;
   esac
done

make install && make clean


echo -e "------------------------------------------------------------------------\nConfiguring..."
sed -i "s/UNCONFIGURED/#UNCONFIGURED/g" /etc/dansguardian/dansguardian.conf
sed -i "s/#daemonuser = 'nobody'/daemonuser = 'nobody'/g" /etc/dansguardian/dansguardian.conf
sed -i "s/#daemongroup = 'nogroup'/daemongroup = 'nogroup'/g" /etc/dansguardian/dansguardian.conf
chown -R nobody:nogroup /var/log/dansguardian/

iptables -F; iptables -X
for table in filter nat mangle; do    # delete the table's rules # delete the table's chains # zero the table's counters
   iptables -t $table -F; iptables -t $table -X; iptables -t $table -Z
done

iptables --table nat --append PREROUTING --proto tcp --destination-port 80 --jump REDIRECT --to-port 8080


echo -e "------------------------------------------------------------------------\nCopying..."
cp /usr/local/share/dansguardian/languages/ukenglish/template.html /usr/local/share/dansguardian/languages/ukenglish/template.html.orig
cp -f "$current"/www/porn.html /usr/local/share/dansguardian/languages/ukenglish/template.html


echo -e "------------------------------------------------------------------------\nRunning..."
dansguardian -Q


echo -e "------------------------------------------------------------------------\nDone!"
cd "$current"
