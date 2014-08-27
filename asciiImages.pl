#!/usr/bin/perl
########################################################################
# asciiImages.pl      --- Squid Script (Converts images into ascii art)#
# g0tmi1k 2011-03-25  --- Original Idea: http://prank-o-matic.com      #
########################################################################
# Note ~ Requires ImageMagick, Ghostscript and jp2a                    #
#    sudo apt-get -y install imagemagick ghostscript jp2a              #
########################################################################
use IO::Handle;
use LWP::Simple;
use POSIX strftime;

$debug = 0;                               # Debug mode - create log file
$ourIP = "192.168.0.33";                  # Our IP address
$baseDir = "/var/www/tmp";                # Needs be writable by 'nobody'
$baseURL = "http://".$ourIP."/tmp";       # Location on websever
$convert = "/usr/bin/convert";            # Path to convert
$identify = "/usr/bin/identify";          # Path to identify
$jp2a = "/usr/bin/jp2a";                  # Path to jp2a

$|=1;
$asciify = 0;
$count = 0;
$pid = $$;

if ($debug == 1) { open (DEBUG, '>>/tmp/asciiImages_debug.log'); }
autoflush DEBUG 1;

print DEBUG "########################################################################\n";
print DEBUG strftime ("%d%b%Y-%H:%M:%S\t Server: $baseURL/\n",localtime(time()));
print DEBUG "########################################################################\n";
system("killall convert");
while (<>) {
   chomp $_;
   if ($_ =~ /(.*\.(gif|png|bmp|tiff|ico|jpg|jpeg))/i) {                         # Image format(s)
      $url = $1;                                                                 # Get URL
      if ($debug == 1) { print DEBUG "Input: $url\n"; }                          # Let the user know

      $file = "$baseDir/$pid-$count";                                            # Set filename + path
      $filename = "$pid-$count";                                                 # Set filename

      getstore($url,$file);                                                      # Save image
      system("chmod", "a+r", "$file");                                        # Allow access to the file
      if ($debug == 1) { print DEBUG "Fetched image: $file\n"; }                 # Let the user know

      $asciify = 1;                                                              # We need to do something with the image
   }
   else {                                                                        # Everything not a image
      print "$_\n";                                                              # Just let it go
      if ($debug == 1) { print DEBUG "Pass: $_\n"; }                             # Let the user know
   }

   if ($asciify == 1) {                                                          # Do we need to do something?
      if ($_ !=~ /(.*\.(jpg|jpeg))/i) {                                          # Select everything other image type to jpg
         system("$convert", "$file", "$file.jpg");                               # Convert images so they are all jpgs for jp2a
         #system("rm", "$file");                                                 # Remove originals
         if ($debug == 1) { print DEBUG "Converted to jpg: $file.jpg\n"; }       # Let the user know
      }
      else {
         system("mv", "$file", "$file.jpg");
      }
      system("chmod", "a+r", "$file.jpg");                                       # Allow access to the file

      $size = `$identify $file.jpg | cut -d" " -f 3`;
      chomp $size;
      if ($debug == 1) { print DEBUG "Image size: $size ($file)\n"; }

      system("$jp2a $file.jpg --invert | $convert -font Courier-Bold label:\@- -size $size $file-ascii.png");   # PNGs are smaller than jpg
      #system("rm $file.jpg");
      system("chmod", "a+r", "$file-ascii.png");
      if ($debug == 1) { print DEBUG "Asciify: $file-ascii.png\n"; }

      print "$baseURL/$filename-ascii.png\n";
      if ($debug == 1) { print DEBUG "Output: $baseURL/$filename-ascii.png, From: $url\n"; }
   }
   $asciify = 0;
   $count++;
}

close (DEBUG);