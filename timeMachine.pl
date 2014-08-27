#!/usr/bin/perl
########################################################################
# timeMachine.pl           --- Squid Script (Uses archive.org archives)#
# g0tmi1k 2011-03-25       --- Original Idea: http://prank-o-matic.com #
########################################################################
# Note                                                                 #
#   If archive.org doesn't have the date specified,                    #
#   it returns a 302 with the nearest date.                            #
#   This script takes the Location header from the 302 response and    #
#   returns it to Squid                                                #
########################################################################
use IO::Handle;
use LWP::UserAgent;
use POSIX strftime;   # Second time function... Ops!

$debug = 0;           # Debug mode - create log file

$|=1;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
$mon = sprintf "%02d",($mon + 1);
$mday = sprintf "%02d",$mday;
$year = $year + 1900;
$year = $year - 4;
$datestring = $year . $mon . $mday . "000000";

if ($debug == 1) { open (DEBUG, '>>/tmp/timeMachine_debug.log'); }
autoflush DEBUG 1;

print DEBUG "########################################################################\n";
print DEBUG strftime ("%d%b%Y-%H:%M:%S\n",localtime(time()));
print DEBUG "########################################################################\n";
while (<>) {
   chomp $_;
   if ($debug == 1) { print DEBUG "Input: $_\n"; }

   if ($_ =~ m/.*archive\.org/) {
      print "$_\n";
      if ($debug == 1) { print DEBUG "Output: $_\n"; }
   }
   else {
      @input = split(" ", $_);
      $url = $input[0];
      @split_url = split("//", $url);
      $archive_url = "http://web.archive.org/web/$datestring/$split_url[1]";
      if ($debug == 1) { print DEBUG "archive_url: $archive_url\n"; }

      my $ua = LWP::UserAgent->new;
      $ua->timeout(10);

      my $response = $ua->get($archive_url);

      if ($response->is_success) {
         $newurl = $response->previous->header('Location');
      }
      else {
         $newurl = $_;
      }

      chomp $newurl;
      print "$newurl\n";
      if ($debug == 1) { print DEBUG "Output: $newurl\n"; }
   }
}

close (DEBUG);