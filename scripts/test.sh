#!/usr/bin/env bash
# **********************
# Run PyFunceble Testing
# **********************
# Created by: @spirillen
# Copyright: My Privacy DNS (https://www.mypdns.org/wiki/License)

# ****************************************************************
# This test script uses PyFunceble by @funilrys aka Nissar Chababy
# Find PyFunceble at: https://github.com/funilrys/PyFunceble
# ****************************************************************

# ******************
# Database functions
# ******************


MySqlImport



# **********************
# Setting date variables
# **********************
#printf "\nSetting Variables\n"
#source ${TRAVIS_BUILD_DIR}/scripts/variables.sh

##########################################
# Make sure all directories are in place #
##########################################

printf "\nMaking testdir...\n"

if [ ! -d "${testdir}" ]
then
	mkdir -p "${testdir}"
	ls -lha "${testdir}"
fi

# ***************
# Import via AXFR
# ***************
printf "\nAXFR Importing\n"

#AXFRImport () {
	truncate -s 0 "${testfile}"
	
    dig axfr typosquatting.mypdns.cloud @axfr.ipv4.mypdns.cloud -p 5353 grep -vE "(^(\*\.|$))|[SOA]" sed 's/\.rpz\.mypdns\.cloud.*$//;s/^\s*\(.*[^ \t]\)\(\s\+\)*$/\1/' > "${testfile}"

	printf "\nAXFR Importing... DONE!\n"
	exit ${?}
#}
AXFRImport

#ImportWhiteList () {
	#printf "\nImporting whitelist\n"
	#truncate -s 0 "${whitelist}"
	#wget -qO "${whitelist}" 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/domain.list'
	#wget -qO- 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/wildcard.list' >> "${whitelist}"
#}
#ImportWhiteList

#WhiteListing () {
    #if [[ "$(git log -1 | tail -1 | xargs)" =~ "ci skip" ]]
        #then
			#printf "\nRunning whitelist\n"
            #hash uhb_whitelist
            #uhb_whitelist -f "${testfile}" -o "${testfile}"
	#else
		#printf "\nSkipping whitelist\n"
    #fi
#}
#WhiteListing

#exit ${?}

#bash "${script_dir}/pyfunceble.sh"

exit ${?}
