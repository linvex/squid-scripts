#!/usr/bin/perl
########################################################################
# googleSearch.pl     --- Squid Script (Modifies Google search queries)#
# g0tmi1k 2011-03-25  --- Original Idea: http://prank-o-matic.com      #
########################################################################
use IO::Handle;
use POSIX strftime;

$debug = 0;                               # Debug mode - create log file
$extraText = "in+my+pants";

$|=1;

if ($debug == 1) { open (DEBUG, '>>/tmp/googleSearch_debug.log'); }
autoflush DEBUG 1;

print DEBUG "########################################################################\n";
print DEBUG strftime ("%d%b%Y-%H:%M:%S\n",localtime(time()));
print DEBUG "########################################################################\n";
while (<>) {
   chomp $_;
   if ($debug == 1) { print DEBUG "Input: $_\n"; }
      if ($_ =~ m/.google\.*/) {
         $url = $_;
         $url =~ s/(q=.+?)&/$1+$extraText&/;
         print "$url\n";
         if ($debug == 1) { print DEBUG "Output: $url\n"; }
      }
   else {
      print "$_\n";
      if ($debug == 1) { print DEBUG "Pass: $_\n"; }
   }
}

close (DEBUG);