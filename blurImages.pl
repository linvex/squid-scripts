#!/usr/bin/perl
########################################################################
# blurImages.pl        --- Squid Script (Makes images harder to see)   #
# g0tmi1k 2011-03-25   --- Original Idea: http://www.ex-parrot.com/pete#
########################################################################
# Note ~ Requires ImageMagick                                          #
#    sudo apt-get -y install imagemagick                               #
########################################################################
use IO::Handle;
use LWP::Simple;
use POSIX strftime;

$debug = 0;                               # Debug mode - create log file
$ourIP = "192.168.0.33";                  # Our IP address
$baseDir = "/var/www/tmp";                # Needs be writable by 'nobody'
$baseURL = "http://".$ourIP."/tmp";       # Location on websever
$mogrify = "/usr/bin/mogrify";            # Path to mogrify

$|=1;
$blur = 0;
$count = 0;
$pid = $$;

if ($debug == 1) { open (DEBUG, '>>/tmp/blurImages_debug.log'); }
autoflush DEBUG 1;

print DEBUG "########################################################################\n";
print DEBUG strftime ("%d%b%Y-%H:%M:%S\t Server: $baseURL/\n",localtime(time()));
print DEBUG "########################################################################\n";
while (<>) {
   chomp $_;
   if ($_ =~ /(.*\.(gif|png|bmp|tiff|ico|jpg|jpeg))/i) {                         # Image format(s)
      $url = $1;                                                                 # Get URL
      if ($debug == 1) { print DEBUG "Input: $url\n"; }                          # Let the user know

      $ext = ($url =~ m/([^.]+)$/)[0];                                           # Get the file extension
      $file = "$baseDir/$pid-$count.$ext";                                       # Set filename + path (Local)
      $filename = "$pid-$count.$ext";                                            # Set filename        (Remote)

      getstore($url,$file);                                                      # Save image
      system("chmod", "a+r", "$file");                                           # Allow access to the file
      if ($debug == 1) { print DEBUG "Fetched image: $file\n"; }                 # Let the user know

      $blur = 1;                                                                 # We need to do something with the image
   }
   else {                                                                        # Everything not a image
      print "$_\n";                                                              # Just let it go
      if ($debug == 1) { print DEBUG "Pass: $_\n"; }                             # Let the user know
   }

   if ($blur == 1) {                                                             # Do we need to do something?
      for ($count=1; $count<11; $count++){
         system("$mogrify -blur 4 $file");
      }
      system("chmod", "a+r", "$file");                                           # Allow access to the file
      if ($debug == 1) { print DEBUG "Blurred: $file\n"; }

      print "$baseURL/$filename\n";
      if ($debug == 1) { print DEBUG "Output: $baseURL/$filename, From: $url\n"; }
   }
   $blur = 0;
   $count++;
}

close (DEBUG);