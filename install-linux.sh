#!/bin/bash

# ------------------------------------------------------------------------------
#  @brief Install a RICOH C306Z printer with a UserCode
#  @author Florian TOUEIX (https://github.com/ftwex)
#  @version 1.0.0
#  
#  The script discover the printer ip, download and adapt the driver
#  with the correct UserCode and install the printer.
# 
# ------------------------------------------------------------------------------

# Discover printers and get Ricoh printer uri
echo -n "Discovering the printer..."
printerInfos=$(lpinfo  -l -v | grep -B 3 -A 2 "make-and-model = RICOH MP C306Z")
printerURI=$(echo "$printerInfos" | head -n1 | sed 's/Device: uri = //g')
printerMakeAndModel=$(echo "$printerInfos" | sed -n 3p | sed 's/        info = //g')
printerMakeAndModelSlug=$(echo "$printerMakeAndModel" | sed 's/ /-/g')

echo "\033[0;32m$printerMakeAndModel found !\033[0m"
	
# Ask for UserCode
echo -n "Enter your UserCode :"
read userCode
if [ -z $userCode ] ;then
	echo "UserCode Empty" 
else
	# Get printer driver, update it with given UserCode and write it in cups ppd's path
	echo -n "Downloading and preparing the driver..."
	curl -s "https://www.openprinting.org/ppd-o-matic.php?driver=Postscript-Ricoh&printer=Ricoh-MP_C306Z&show=1" | sed "s/1001/$userCode/g" | sed "s/DefaultUserCode: None/DefaultUserCode: $userCode/g" > /usr/share/ppd/CustomRICOH_MP_C306Z.ppd
	echo "\033[0;32mOK\033[0m"

	echo -n "Installing the printer..."
	# Add printer to system
	lpadmin -p "$printerMakeAndModelSlug" \
		-v $printerURI \
		-m "$printerMakeAndModelSlug" \
		-P "/usr/share/ppd/CustomRICOH_MP_C306Z.ppd" \
		-E
	echo "\033[0;32mOK\033[0m\n\nReady to print !"
fi


