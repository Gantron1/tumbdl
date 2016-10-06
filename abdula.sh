#!/bin/bash
#
# abdula.sh: Download videos from AbdulaPorn.com
#
# Usage: abdula.sh [URL] [DIR]
#
# URL: URL to gallery of videos
# DIR: directory to put videos in
#
# Example: ./abdula.sh abdulaporn.com/most-popular most-popular
#
# Requirements: nothing fancy. Just bash (v.4), wget, grep, egrep, coreutils
#
# TO DO:
#
# * Do something better than hardcoding what page numbers.
#
# * Sometimes youtube-dl freezes, and I think it's because abdulaporn.com sometimes goes to an ad.
#
# * Sometimes I saw // instead of / in urls, but it still seemed to work.

# Set pages to d/l
firstArchivePage=7
# lastArchivePage=186
lastArchivePage=7

# Show commands
#set -x

url=$1
targetdir=$2
# wgetOptions='-nv' Not verbose. I prefer verbosity.
wgetOptions='-v'
userAgent='--user-agent="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1"'

# Set text effects
bold=$(tput bold)
normal=$(tput sgr0)
underline=$(tput smul)

# Template for text effects
# printf "${bold}${normal}\n"

# check usage
if [ $# -ne 2 ]; then
  echo "Usage: abdula [URL] [DIR]"
  echo ""
  echo "URL: URL to rip"
  echo "DIR: directory to put images in, e.g. prostbote"
  exit
fi

# sanitize input url
url=$(echo "$url" | sed 's/http[s]*:\/\///g')
# Should remove trailing / here

# create target dir
mkdir "$targetdir"

# Make cookieFile
cookieFile="$(mktemp 2>/dev/null || mktemp -t 'mytmpdir')"

# Function: ripVids - Download all videos on url supplied by $1
function ripVids {
	# Create temp file named $indexName and output status
   indexName="$(mktemp 2>/dev/null || mktemp -t 'mytmpdir')"
   printf "${bold}Processing page: $1${normal}\n"

   # Wget url supplied by the $1 parameter and put it in the temp file
   wget "$1" -O "$indexName" --load-cookies "$cookieFile" "$wgetOptions" "$userAgent"

   # Find all video urls on the page and call youtube-dl on them
   while read -r; do
      article=("$REPLY")
      printf "${bold}Getting video: $article${normal}\n"
	  youtube-dl "$article" -o "${targetdir}/%(title)s.%(ext)s" -ciw   # c = force continue, i = ignore errors, w = no-overwrites
	  printf "${bold}Waiting 4 seconds (hit ctrl-c to break)...${normal}\n"
	  sleep 4
   done < <(grep -o 'http[s]*://[^ ]*/videos/[^" ]*' "$indexName")
}

# MAIN: iterate over archive pages, collect article urls and download images
for cur in `seq $firstArchivePage $lastArchivePage`;
do
	ripVids $url/$cur/
done

