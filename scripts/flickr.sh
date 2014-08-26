#!/bin/sh
# that are Publicly available.
#
# So, here it is, my first attempt
# If you have any questions shoot me an email yaxzone@yaxmail.com
# If you are going to be running this script on Linux, make sure to
# uncomment out line 28 and comment out line 29

## Set to download 

# ***** Replace this url with the SET you would like to download *****
Set="http://www.flickr.com/photos/crustydolphin/sets/72157618053451592/detail/"

# Size of files 
SizeImage="_z.jpg" # This is the medium size
SizeImage1="_b.jpg" # Large size if available

# Creates directory with the name of the user
Dir=`echo $Set | cut -d'/' -f5` 


function ComponentsDownload { # This function gets all the pages number
mkdir -p $Dir
PagesCalc=`lynx -dump $Set | grep 'page' | awk '{print $2}' | sort -d | uniq | cut -d'=' -f2 | sort -n | tail -1`
PagesCalcPlus1=$(expr $PagesCalc + 1)

for PageNumb in `seq 1 $PagesCalcPlus1` # For Linux usage
#for PageNumb in `jot - 1 $PagesCalcPlus1` # For Mac OS X usage

	do

		echo $Set"?page="$PageNumb >> Pages.txt

		done

# This pices gets all the links to the pictures on the pages
for ImagesUrl in `cat Pages.txt | awk '{print $1}' | sort -d | uniq` 

	do 
		lynx -dump $ImagesUrl | grep 'in/set-' | awk '{print $2}' | sort -d | uniq >> ImagesUrl.txt

		done
		echo "First part of job done."
		echo "Hold on tight ..."
}

function DownloadImages { # This funcion starts the actual download of the images
for ImageUrl in `cat ImagesUrl.txt | sort -d | uniq`

	do

		curl $ImageUrl | grep "url: 'http://" | grep "$SizeImage\|$SizeImage1" | cut -d"'" -f2  > Image2Download 2>&1

		WhichFile=`grep '_b.jpg' Image2Download`

		if [ ! -z "$WhichFile" ]; # This piece determines which file to download
			then 

			File2Download=`cat Image2Download | tail -1`
			echo $File2Download

			else 

				File2Download=`cat Image2Download | head -1`
				echo $File2Download

				fi

				wget $File2Download > /dev/null 2>&1
				File2Move=`echo $File2Download | cut -d'/' -f5`
				mv $File2Move $Dir"/"
				rm Image2Download
				sleep 1 # Waits 1 second before it downloads the second image

				done
}

function CleanUp { # Removes the pages where the urls get stored
rm ImagesUrl.txt
rm Pages.txt

# this piece renames the files for the ones that have extra characters
cd $Dir
ls -1 | grep '.jpg?' | while read File; do mv $File `echo $File | cut -d'?' -f1`; done
cd ..
}

# This executes the above functions
ComponentsDownload
DownloadImages
CleanUp

echo "Job done."

