#!/usr/bin/perl
########################################################################
# touretteImages.pl       --- Squid Script (Add words to images)       #
# g0tmi1k 2011-03-25      --- Original Idea: http://prank-o-matic.com  #
########################################################################
# Note ~ Requires ImageMagick and Ghostscript                          #
#    sudo apt-get -y install imagemagick ghostscript                   #
########################################################################
# *Could go "crazy"-do more than one word? "Flash" it? Limited images?*#
########################################################################
use IO::Handle;
use LWP::Simple;
use POSIX strftime;

$debug = 0;                               # Debug mode - create log file
@words = ('happy','love','sunshine','hello','hug','flower power','smiles');   # Use theses words at random...
$ourIP = "192.168.0.33";                  # Our IP address
$baseDir = "/var/www/tmp";                # Needs be writable by 'nobody'
$baseURL = "http://".$ourIP."/tmp";       # Location on websever
$convert = "/usr/bin/convert";            # Path to convert
$identify = "/usr/bin/identify";          # Path to identify

$|=1;
$animate = 0;
$count = 0;
$pid = $$;
$word = $words[int rand($#words + 1)];

if ($debug == 1) { open (DEBUG, '>>/tmp/touretteImages_debug.log'); }
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
      system("chmod", "a+r", "$file");                                           # Allow access to the file
      if ($debug == 1) { print DEBUG "Fetched image: $file\n"; }                 # Let the user know

      $animate = 1;                                                              # We need to do something with the image
   }
   else {                                                                        # Everything not a image
      print "$_\n";                                                              # Just let it go
      if ($debug == 1) { print DEBUG "Pass: $_\n"; }                             # Let the user know
   }

   if ($animate == 1) {
      if ($_ !=~ /(.*\.gif)/i) {                                                 # Select everything other image type to jpg
         system("$convert", "$file", "$file.gif");                               # Convert images so they are all jpgs for jp2a
         #system("rm", "$file");                                                 # Remove originals
         if ($debug == 1) { print DEBUG "Converted to gif: $file.gif\n"; }       # Let the user know
      }
      else {
         system("mv", "$file", "$file.gif");                                     # No need to convert!
      }
      system("chmod", "a+r", "$file.gif");                                       # Allow access to the file

      $size = `$identify $file.gif | cut -d" " -f 3`;
      chomp $size;
      if ($debug == 1) { print DEBUG "Image size: $size ($file)\n";}

      system("$convert -background black -fill white -gravity center -size $size label:'$word' $file-text.gif");
      system("chmod", "a+r", "$file-text.gif");
      if ($debug == 1) { print DEBUG "Turette image: $file-text.gif\n"; }

      system("$convert -delay 100 -size $size -page +0+0 $file.gif -page +0+0 $file-text.gif -loop 0 $file-animation.gif");
      system("chmod", "a+r", "$file-animation.gif");
      #system("rm $file.gif $file-text.gif");
      if ($debug == 1) { print DEBUG "Animated gif: $url\n"; }

      print "$baseURL/$filename-animation.gif\n";
      if ($debug == 1) { print DEBUG "Output: $baseURL/$filename-animation.gif, From: $url\n"; }
   }
   $animate = 0;
   $count++;
}