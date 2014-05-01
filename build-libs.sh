#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
BSPS="zed_E16G3_512mb zed_E64G4_512mb parallella_E16G3_1GB"

function build-xml() {
	# Build the XML parser library
	echo '==============================='
	echo '============ E-XML ============'
	echo '==============================='
	cd src/e-xml
	${MAKE} clean
	${MAKE} all
	cd ../../
}


function build-loader() {
	# Build the Epiphnay Loader library
	echo '=================================='
	echo '============ E-LOADER ============'
	echo '=================================='
	cd src/e-loader
	${MAKE} clean
	${MAKE} all
	cd ../../
}


function build-hal() {
	# Build the Epiphnay HAL library
	echo '==============================='
	echo '============ E-HAL ============'
	echo '==============================='
	cd src/e-hal
	${MAKE} clean
	${MAKE} all
	for bsp in ${BSPS}; do
		cp -f Release/libe-hal.so ../../bsps/${bsp}
	done
	cd ../../
}


function build-server() {
	# Build the Epiphnay GDB RSP Server
	echo '=================================='
	echo '============ E-SERVER ============'
	echo '=================================='
	cd src/e-server
	${MAKE} clean
	${MAKE} all
	cd ../../
}


function build-utils() {
	# Install the Epiphnay GNU Tools wrappers
	echo '================================='
	echo '============ E-UTILS ============'
	echo '================================='
	cd src/e-utils
	echo 'Building e-reset'
	cd e-reset
	${MAKE}  all
	cd ../
	echo 'Building e-loader'
	cd e-loader
	${MAKE} all
	cd ../
	echo 'Building e-read'
	cd e-read
	${MAKE} all
	cd ../
	echo 'Building e-write'
	cd e-write
	${MAKE} all
	cd ../
	echo 'Building e-hw-rev'
	cd e-hw-rev
	${MAKE} all
	cd ../
	cd ../../
}


function build-lib() {
	# build the Epiphnay Runtime Library
	echo '==============================='
	echo '============ E-LIB ============'
	echo '==============================='
	if [ ! -d "${ESDK}/tools/e-gnu/bin" ]; then
		echo "In order to build the E-LIB the e-gcc compiler is required. Please"
		echo "install the Epiphany GNU tools suite first at ${ESDK}/tools/e-gnu!"
		exit
	fi
	cd src/e-lib
	make clean

	# Always use the epiphany toolchain for building e-lib
	make CROSS_COMPILE=e- all
	cd ../../
}


function usage() {
	echo "Usage: build-libs.sh [pkg-list] [-a] [-h]"
	echo "   'pkg-list' is any combination of package numbers or names"
	echo "        to be built. Items are separated by spaces and names"
	echo "        are given in lowercase (e.g, 'e-hal'). The packages"
	echo "        enumeration is as follows:"
	echo ""
	echo "        1   - E-XML"
	echo "        2   - E-LOADER"
	echo "        3   - E-HAL"
	echo "        4   - E-SERVER"
	echo "        5   - E-UTILS"
	echo "        6   - E-LIB"
	echo ""
	echo "        -a  - Build all packages"
	echo "        -h  - Print this help message"	
	echo ""
	echo "   Example: The following command will build e-hal, e-xml and e-lib:"
	echo ""
	echo "   $ ./build-libs.sh 1 3 e-lib"
	
	exit
}

if [[ $# == 0 ]]; then
	usage
fi

CROSS_PREFIX=

case $(uname -p) in
	arm*)
		# Use native arm compiler (no cross prefix)
		CROSS_PREFIX=
		;;
	   *)
		# Use cross compiler
		CROSS_PREFIX="CROSS_COMPILE=arm-linux-gnueabihf-"
		;;
esac

MAKE="make $CROSS_PREFIX " 

while [[ $# > 0 ]]; do
	if   [[ "$1" == "1" || "$1" == "e-xml"    ]]; then
		build-xml
		
	elif [[ "$1" == "2" || "$1" == "e-loader" ]]; then
		build-loader
		
	elif [[ "$1" == "3" || "$1" == "e-hal"    ]]; then
		build-hal
		
	elif [[ "$1" == "4" || "$1" == "e-server" ]]; then
		build-server
		
	elif [[ "$1" == "5" || "$1" == "e-utils"  ]]; then
		build-utils
		
	elif [[ "$1" == "6" || "$1" == "e-lib"    ]]; then
		build-lib
		
	elif [[ "$1" == "-a" ]]; then
		build-xml
		build-loader
		build-hal
		build-server
		build-utils
		build-lib
		exit

	elif [[ "$1" == "-h" ]]; then
		usage
	fi

	shift
done


