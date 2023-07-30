#!/bin/bash
#
# This script downloads Telegram English and Catalan language files (android, ios, tdesktop, and macos).
#
# usage: ./check_telegram
#
# needed:
#  * read&write permissions at script directory.
#  * cookies.txt mandatory file. Nestcape format. It must contain translations.telegram.org cookies.
#    You can export it from your browser after logging into translations.telegram.org.
#  * wget
#  * a human
#
# version: 1.0
# date: 2019-12-22
#
# author: Joan Montané (jmontane aaattt softcatala dddooottt org)
# license: GPLv3 or later (https://www.gnu.org/licenses/gpl-3.0.ca.html)

mkdir -p ./translations/android/res/values
mkdir -p ./translations/android/res/values-ca
mkdir -p ./translations/ios/en.lproj
mkdir -p ./translations/ios/ca.lproj
mkdir -p ./translations/macos/en.lproj
mkdir -p ./translations/macos/ca.lproj
mkdir -p ./translations/tdesktop/en.lproj
mkdir -p ./translations/tdesktop/ca.lproj
mkdir -p ./translations/androidx/res/values
mkdir -p ./translations/androidx/res/values-ca
mkdir -p ./translations/webk/en
mkdir -p ./translations/webk/ca
mkdir -p ./translations/weba/en
mkdir -p ./translations/weba/ca
mkdir -p ./translations/unigram/en
mkdir -p ./translations/unigram/ca




# Cookies mandatory file. Nestcape format. It must contain translations.telegram.org cookies
# See: https://github.com/rotemdan/ExportCookies
cookies="./cookies.txt"

# Loggin directory
logging="./log"
mkdir -p ${logging}

# Backup directory
backupdir="./backups"
mkdir -p ${backupdir}

# Data from Telegram translations site
projects=(
   android
   ios
   tdesktop
   macos
   android_x
   webk
   weba
   unigram
)

files=(
   android/res/values/strings.xml
   ios/en.lproj/Localizable.strings
   tdesktop/en.lproj/Localizable.strings
   macos/en.lproj/Localizable.strings
   androidx/res/values/strings.xml
   webk/en/webk.strings
   weba/en/weba.strings
   unigram/en/unigram.xml
)

filesca=(
   android/res/values-ca/strings.xml
   ios/ca.lproj/Localizable.strings
   tdesktop/ca.lproj/Localizable.strings
   macos/ca.lproj/Localizable.strings
   androidx/res/values-ca/strings.xml
   webk/ca/webk.strings
   weba/ca/weba.strings
   unigram/ca/unigram.xml
)


url=(
   https://translations.telegram.org/en/android/export
   https://translations.telegram.org/en/ios/export
   https://translations.telegram.org/en/tdesktop/export
   https://translations.telegram.org/en/macos/export
   https://translations.telegram.org/en/android_x/export
   https://translations.telegram.org/en/webk/export
   https://translations.telegram.org/en/weba/export
   https://translations.telegram.org/en/unigram/export
)

urlca=(
   https://translations.telegram.org/ca/android/export
   https://translations.telegram.org/ca/ios/export
   https://translations.telegram.org/ca/tdesktop/export
   https://translations.telegram.org/ca/macos/export
   https://translations.telegram.org/ca/android_x/export
   https://translations.telegram.org/ca/webk/export
   https://translations.telegram.org/ca/weba/export
   https://translations.telegram.org/ca/unigram/export

)


if [ ! -f ${cookies} ]
then
    echo "Missing ${cookies} file. It's a mandatory file."
    exit 1
fi



# Backup current files, just in case
echo "Backup current files, just in case"
backupfile=telegram-$(date +%Y%m%d).tgz
tar --create --gzip --file=${backupdir}/${backupfile} ./translations/

# Keep last 100 backup files only (~1 year)
# ls -t -d ${backupdir}/* | tail -n +100 | xargs rm --


# For each project
for i in 0 1 2 3 4 5 6 7;
do
   echo "$(date --iso-8601)|${projects[$i]}" >> ${logging}/check_telegram.log
   # Download current upstream source "en" file from translations.telegram.org
   # Download Telegram source file and save it

   wget --load-cookies ${cookies} --user-agent="User-Agent: Mozilla/5.0" -O ./translations/${files[$i]} ${url[$i]}

  wget --load-cookies ${cookies} --user-agent="User-Agent: Mozilla/5.0" -O ./translations/${filesca[$i]} ${urlca[$i]}


   #if [[ "${projects[$i]}" == "ios" ]] || [[ "${projects[$i]}" == "macos" ]] || [[ "${projects[$i]}" == "tdesktop" ]]
   #then
      #echo "Fix file format"
      #cp ./upstream/${resources[$i]}/${files[$i]} ./upstream/${resources[$i]}/${files[$i]}.tmp
      # sed -i '/^[a-zA-Z0-9]/s/^\(.*\) = /"\1" = /g' ./upstream/${resources[$i]}/${files[$i]}.tmp
      #iconv -f UTF-8 -t UTF-16LE ./upstream/${resources[$i]}/${files[$i]}.tmp -o ./upstream/${resources[$i]}/${files[$i]}
      #sed -i '1 s/^/\xff\xfe/' ./upstream/${resources[$i]}/${files[$i]}
      #rm ./upstream/${resources[$i]}/${files[$i]}.tmp
   #fi

   # Check if downloaded upstream file seems good
   firstline=$(head -n 1 ./translations/${files[$i]})

   if [ "${firstline}" = "<!DOCTYPE html>" ]
   then
     # Dowloaded Telegram file doesn't seems good.
     #echo "WARNING: Check cookies.txt file. Maybe it's malformed, or cookies are outdated."
     echo "WARNING: Check cookies.txt file." >> ${logging}/check_telegram.log
   fi
done

