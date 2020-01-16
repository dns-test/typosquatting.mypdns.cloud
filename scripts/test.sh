#!/bin/bash
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

MySqlImport () {
	sudo mysql -u root -h localhost -e "CREATE DATABASE pyfunceble DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
	sudo mysql -u root -h localhost -e "CREATE USER 'root'@'%' IDENTIFIED BY ''"
	sudo mysql -u root -h localhost -e "CREATE USER 'pyfunceble'@'localhost' IDENTIFIED BY 'pyfunceble';"
	sudo mysql -u root -h localhost -e "GRANT ALL PRIVILEGES ON pyfunceble.* TO 'pyfunceble'@'localhost';"
	if [ -f "${HOME}/db/pyfunceble.sql" ]
	then
		sudo mysql --user=pyfunceble --password=pyfunceble pyfunceble < "${HOME}/db/pyfunceble.sql"
	fi

	exit ${?}
}
MySqlImport

MySqlExport () {
	if [ ! -d "${HOME}/db/" ]
	then
		sudo mkdir -p ${HOME}/db/
	fi
	sudo mysqldump --user=pyfunceble --password=pyfunceble --opt pyfunceble > ${HOME}/db/pyfunceble.sql
}

# **********************
# Setting date variables
# **********************
export script_dir="${TRAVIS_BUILD_DIR}/scripts"
export testdir="${TRAVIS_BUILD_DIR}/test_data"
export testfile="${testdir}/typosquatting.mypdns.cloud.list"
export whitelist="${testdir}/whitelist.txt"
export tag=$(date '+%F %X %Z %z')

##########################################
# Make sure all directories are in place #
##########################################

if [ ! -d "${testdir}" ]
then
	mkdir -p "${testdir}"
fi

# ***************
# Import via AXFR
# ***************

AXFRImport () {
	printf "\ntruncate ${testfile}\n"
	truncate -s 0 "${testfile}"
	printf "\nAXFR Importing\n"
    dig axfr typosquatting.mypdns.cloud @axfr.ipv4.mypdns.cloud -p 5353 \
		| grep -vE "(^(\*\.|$))|[SOA]" \
		| sed 's/\.rpz\.mypdns\.cloud.*$//;s/^\s*\(.*[^ \t]\)\(\s\+\)*$/\1/' \
		> "${testfile}"

	exit ${?}
 }
AXFRImport

#ImportWhiteList () {
	#printf "\nImporting whitelist\n"
	#truncate -s 0 "${whitelist}"
	#wget -qO "${whitelist}" 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/domain.list'
	#wget -qO- 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/wildcard.list' >> "${whitelist}"
#}
#ImportWhiteList

#WhiteListing () {
    #if [[ "$(git log -1 | tail -1 | xargs)" =~ "skip ci | ci skip" ]]
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

RunPyFunceble () {

    #tag=$(date '+%F %X %Z %z')
    ulimit -u
    cd ${script_dir}

    hash PyFunceble

    if [[ -f "${script_dir/}" ]]
    then
        rm "${script_dir}/.PyFunceble.yaml"
        rm "${script_dir}/.PyFunceble_production.yaml"
    fi

    PyFunceble --version
    PyFunceble --ci -q -ex --plain --idna -db -h --http \
		--database-type mariadb -m -p 4 \
        --hierarchical --cmd-before-end "bash ${TRAVIS_BUILD_DIR}/scripts/Commit.sh" \
        --autosave-minutes 20 \
        --ci-branch test-run \
        --ci-distribution-branch master \
        --commit-autosave-message "${tag}.${TRAVIS_BUILD_NUMBER} [Auto Saved]" \
        --commit-results-message "${tag}.${TRAVIS_BUILD_NUMBER}"
        --cmd "MySqlExport"
         -f ${testfile}
}

RunPyFunceble

exit ${?}
