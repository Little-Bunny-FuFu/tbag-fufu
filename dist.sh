#!/bin/sh

# $Id$

version=`grep -E '^TBAG_VERSION = ' localization.lua | cut -d '"' -f 2`
year=`echo ${version} | cut -d '-' -f 1`
month=`echo $version | cut -d '-' -f 2`
day=`echo $version | cut -d '-' -f 3`
rev=`svnversion`
zipfile="TBag-Shefki-$year$month$day-r$rev.zip"

if [ -e ~/Desktop/$zipfile ]; then
  rm -f ~/Desktop/$zipfile
fi

(cd ..; zip -r ~/Desktop/$zipfile TBag -x TBag/\*~ TBag/\*.swp TBag/.DS_Store TBag/dev \
                                  TBag/dev/\* TBag/dist.sh TBag/scrape-wowhead.perl )
