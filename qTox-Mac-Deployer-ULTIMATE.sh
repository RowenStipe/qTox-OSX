#!/usr/bin/env bash

# qTox OSX auto BASH builder script by RowenStipe
# This uses the same process as doing it manually but with a few varients

# Use:./qTox-Mac-Deployer-ULTIMATE.sh [Process] [OPTIONAL]
# Process: -u to update -b to build -d or -ubd to run all at once
# optional -c value for cleanup

# Set your main Dir
MAIN_DIR="/Users/Rowen" # Your home DIR really (Most of this happens in it) {DONT USE: ~ }
QT_DIR="${MAIN_DIR}/Qt-55" # Folder name of QT install
# Yes I know mine's weird -Rowen
VER="${QT_DIR}/5.5" # Potential future proffing for version testing
QMAKE="${VER}/clang_64/bin/qmake" # Don't change
MACDEPLOYQT="${VER}/clang_64/bin/macdeployqt" # Don't change

QTOX_DIR="${MAIN_DIR}/qTox" # Change to Git location

TOXCORE_DIR="${MAIN_DIR}/toxcore" # Change to Git location


BUILD_DIR="${MAIN_DIR}/qTox-Mac-Deployment" # Change if needed
DEPLOY_DIR="${MAIN_DIR}/qTox-deployed"

function update {
	echo "------------------------------"
	echo "Starting update process ..."
	
	#First update Toxcore from git
	cd $TOXCORE_DIR
	echo "Now in ${PWD}"
	echo "Pulling ..."
	git pull
	# The following was addapted from: https://github.com/irungentoo/toxcore/blob/47cac28df4065c52fb54a732759d551d79e45af7/other/osx_build_script_toxcore.sh
	read -r -p "Did Toxcore update from git? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
		echo "Starting Toxcore build and install"
		#If libsodium is built with macports, link it from /opt/local/ to /usr/local
		if [ ! -L "/usr/local/lib/libsodium.dylib" ]; then
		#Control will enter here if $DIRECTORY doesn't exist.
		   ln -s /opt/local/lib/libsodium.dylib /usr/local/lib/libsodium.dylib
		fi
		echo "The symlink /usr/local/lib/libsodium.dylib exists."
		sleep 3
		
		./configure CC="gcc -arch ppc -arch i386" CXX="g++  -arch ppc -arch i386" CPP="gcc -E" CXXCPP="g++ -E" 
		
		make clean
		make	
		echo "------------------------"
		echo "Sudo required, please enter your password:"
		sudo make install	
	else
	    echo "Moving on!"
	fi
	
	#Now let's update qTox!
	cd $QTOX_DIR
	echo "Now in ${PWD}"
	echo "Pulling ..."
	git pull
	read -r -p "Did qTox update from git? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
		echo "Starting OSX bootstrap ..."
		echo "Sudo required:"
		sudo bash ./bootstrap-osx.sh
	else
	    echo "Moving on!"
	fi
	
}

function build {
	echo "------------------------------"
	echo "Starting build process ..."
	mkdir $BUILD_DIR
	cd $BUILD_DIR
	echo "Now working in ${PWD}"
	echo "Starting qmake ... "
	$QMAKE $QTOX_DIR/qtox.pro
	make
}

function deploy {
	echo "------------------------------"
	echo "starting deployment process ..."
	cd $BUILD_DIR
	if [ ! -d $BUILD_DIR ]; then
		echo "Error: Build directory not detected, please run -ubd, or -b before deploying"
		exit
	fi
	mkdir $DEPLOY_DIR
	cp -r $BUILD_DIR/qTox.app $DEPLOY_DIR/qTox.app
	cd $DEPLOY_DIR
	echo "Now working in ${PWD}"
	$MACDEPLOYQT qTox.app
}

function clean {
	echo "------------------------------"
	echo "Starting cleanup process ..."
	rm -r $BUILD_DIR
	echo "Cleared out build files!"
}
	
if [ "$1" == "-u" ]; then
	update
fi
if [ "$1" == "-b" ]; then
	build
fi
if [ "$1" == "-d" ]; then
	deploy
fi
if [ "$1" == "-ubd" ]; then
	update
	build
	deploy
fi

if [ "$2" == "-c" ]; then
	clean
fi

echo "Nothing else, goodbye!" 
exit