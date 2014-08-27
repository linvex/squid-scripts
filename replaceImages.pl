#!/usr/bin/perl
########################################################################
# replaceImages.pl              --- Squid Script (Replace every image) #
# g0tmi1k 2011-03-25                                                   #
########################################################################
use IO::Handle;
use POSIX strftime;

$debug = 0;                      # Debug mode - create log file
$imageURL = "http://icanhascheezburger.files.wordpress.com/2009/04/funny-pictures-cat-is-on-your-computer.jpg";

$|=1;
$pid = $$;

if ($debug == 1) { open (DEBUG, '>>/tmp/replaceImages_debug.log'); }
autoflush DEBUG 1;

print DEBUG "########################################################################\n";
print DEBUG strftime ("%d%b%Y-%H:%M:%S\n",localtime(time()));
print DEBUG "########################################################################\n";
while (<>) {
   chomp $_;
   if ($debug == 1) { print DEBUG "Input: $_\n"; }
   if ($_ =~ m/.*$imageURL/) {
      print "$imageURL\n";
   }
   elsif ($_ =~ /(.*\.(gif|png|bmp|tiff|ico|jpg|jpeg))/i) {   # Image format(s)
      print "$imageURL\n";
      if ($debug == 1) { print DEBUG "Image Replaced: $_ \n"; }
   }
   else {
      print "$_\n";
      if ($debug == 1) { print DEBUG "Output: $_\n"; }
   }
}

close (DEBUG);