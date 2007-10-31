#!/bin/sh

# $Id$

dev="$1"
rev=`perl -pi -e 'BEGIN{ $rev = qx(svnversion); print $rev; chomp $rev} s/^(local rev = \\x27\\$Rev: ).*?\\$/$1$rev \\$/' localization.lua`
date=`perl '-MPOSIX qw(strftime)' -pi -e 'BEGIN { $now = time(); $timestr = strftime("%Y-%m-%d %H:%M:%S %z (%a, %d %b %Y)", localtime($now)); print strftime("%Y%m%d\n",localtime($now));} s/^(local date = \\x27\\$Date: ).*?\\$/$1$timestr \\$/' localization.lua`
perl -pi -e "s/^(local dev = \\x27).*?\\x27/\$1$dev\\x27/" localization.lua
zipfile="TBag-Shefki-$date-r$rev$dev.zip"

if [ -e ~/Desktop/$zipfile ]; then
  rm -f ~/Desktop/$zipfile
fi

(cd ..; zip -r ~/Desktop/$zipfile TBag -x TBag/\*~ TBag/\*.swp TBag/.DS_Store TBag/dev \
                                  TBag/dev/\* TBag/dist.sh TBag/scrape-wowhead.perl \
				  TBag/.svn TBag/.svn/* TBag/skin/.svn TBag/skin/.svn/* )
