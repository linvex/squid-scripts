#!/usr/bin/perl
########################################################################
# rickrollYoutube.pl    --- Squid Script (Redirect to a youtube video) #
# g0tmi1k 2011-03-25    --- Original Idea: http://prank-o-matic.com    #
########################################################################
use IO::Handle;
use POSIX strftime;

$debug = 0;                               # Debug mode - create log file
$videoURL = "http://www.youtube.com/watch?v=oHg5SJYRHA0";

$|=1;

if ($debug == 1) { open (DEBUG, '>>/tmp/rickrollYoutube_debug.log'); }
autoflush DEBUG 1;

print DEBUG "########################################################################\n";
print DEBUG strftime ("%d%b%Y-%H:%M:%S\n",localtime(time()));
print DEBUG "########################################################################\n";
while (<>) {
   chomp $_;
   if ($debug == 1) { print DEBUG "Input: $_\n"; }
   if ($_ =~ m/.*$videoURL|.*youtube.com\/videoplayback|.*ytimg\.com/) {
      print "$_\n";
      if ($debug == 1) { print DEBUG "Output: $_\n"; }
   }
   else {
      print "$videoURL\n";
      if ($debug == 1) { print DEBUG "Output: Rick Roll'd ($_)\n"; }
   }
}

close (DEBUG);