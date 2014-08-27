#!/usr/bin/perl
########################################################################
# noInternet.pl            --- Squid Script (Replace every web site)   #
# g0tmi1k 2011-03-25       --- Original Idea: http://prank-o-matic.com #
########################################################################
# Note ~ Requires ./www/*                                              #
#    cp -rf www/* /var/www/tmp/                                        #
########################################################################
use IO::Handle;
use POSIX strftime;

$debug = 0;                               # Debug mode - create log file
$ourIP = "192.168.0.33";                  # Our IP address
$baseURL = "http://".$ourIP."/tmp";       # Location on websever

$|=1;

if ($debug == 1) { open (DEBUG, '>>/tmp/noInternet_debug.log'); }
autoflush DEBUG 1;

print DEBUG "########################################################################\n";
print DEBUG strftime ("%d%b%Y-%H:%M:%S\t Server: $baseURL/\n",localtime(time()));
print DEBUG "########################################################################\n";
while (<>) {
   chomp $_;
   if ($debug == 1) { print DEBUG "Input: $_\n"; }
   if ($_ =~ m/.*$ourIP/) {
      print "$_\n";
      if ($debug == 1) { print DEBUG "Output: $_\n"; }
   }
   else {
      print "$baseURL\n";
      if ($debug == 1) { print DEBUG "Output: Fail whale'd ($_)\n"; }
   }
}

close (DEBUG);