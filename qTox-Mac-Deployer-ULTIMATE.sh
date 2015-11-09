#!/usr/bin/env bash

# qTox OSX auto BASH builder script by RowenStipe
# This uses the same process as doing it manually but with a few varients

# Use:./qTox-Mac-Deployer-ULTIMATE.sh [Processes/Install] [OPTIONAL]
# Process: -u to update -b to build -d or -ubd to run all at once
# Install: use -i to start install functionality

# Optional: -c value for cleanup

MAIN_DIR="/Users/Rowen" # Your home DIR really (Most of this happens in it) {DONT USE: ~ }
QT_DIR="${MAIN_DIR}/Qt5.5.1" # Folder name of QT install
VER="${QT_DIR}/5.5" # Potential future proffing for version testing
QMAKE="${VER}/clang_64/bin/qmake" # Don't change
MACDEPLOYQT="${VER}/clang_64/bin/macdeployqt" # Don't change

QTOX_DIR="${MAIN_DIR}/qTox" # Change to Git location

TOXCORE_DIR="${MAIN_DIR}/toxcore" # Change to Git location

FA_DIR="${MAIN_DIR}/filter_audio"

BUILD_DIR="${MAIN_DIR}/qTox-Mac-Deployment" # Change if needed

DEPLOY_DIR="${MAIN_DIR}/qTox-deployed"

DL_DIR="${MAIN_DIR}/Downloads"
QT_DMG="${DL_DIR}/qt-opensource-mac"
QT_DL="https://download.qt.io/official_releases/qt/5.5/5.5.1/qt-opensource-mac-x64-clang-5.5.1.dmg"
QT_DMG="qt-opensource-mac-x64-clang-5.5.1"


function fcho() {
	local fch="$1"; shift
	printf "\n$fch\n" "$@"
}

# The following was addapted from: https://github.com/irungentoo/toxcore/blob/47cac28df4065c52fb54a732759d551d79e45af7/other/osx_build_script_toxcore.sh
function build-toxcore {
	echo "Starting Toxcore build and install"
	cd $TOXCORE_DIR
	echo "No working in: ${PWD}"
	#If libsodium is built with macports, link it from /opt/local/ to /usr/local
	if [ ! -e /usr/local/opt/libsodium/lib/libsodium.13.dylib ]; then
	#Control will enter here if $DIRECTORY doesn't exist.
	   	ln -s /usr/local/opt/libsodium/lib/libsodium.dylib /usr/local/lib/libsodium.dylib
  	else
		echo "The symlink /usr/local/lib/libsodium.dylib exists."
	fi
	sleep 3
	
	./configure CC="gcc -arch ppc -arch i386" CXX="g++  -arch ppc -arch i386" CPP="gcc -E" CXXCPP="g++ -E" 
	
	make clean
	make	
	echo "------------------------------"
	echo "Sudo required, please enter your password:"
	sudo make install
}

function install {
	fcho "=============================="
	fcho "This script will install the nessicarry applications and libraries needed to compile qTox properly."
	fcho "Note that this is not a 100\% automated install it just helps simplfiy the process for less experianced or lazy users."
	read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
	if [ -e /usr/local/bin/brew ]; then
		fcho "Homebrew already installed!"
	else
		fcho "Installing homebrew ..."
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
	fcho "Updating brew formulas ..."
	brew update
	fcho "Getting home brew formulas (You may have them already) ..."
	sleep 3
	brew install git ffmpeg qrencode wget
	
	fcho "Installing x-code Comand line tools ..."
	xcode-select --install
	
	fcho "Starting git repo checks ..."
	
	cd $MAIN_DIR # just in case
	if [ -e $TOX_DIR/.git/index ]; then # Check if this exists
		fcho "Toxcore git repo already inplace !"
		cd $TOX_DIR
		git pull
	else
		fcho "Cloning Toxcore git ... "
		git clone https://github.com/irungentoo/toxcore.git
	fi
	if [ -e $QTOX_DIR/.git/index ]; then # Check if this exists
		fcho "qTox git repo already inplace !"
		cd $QTOX_DIR
		git pull
	else
		fcho "Cloning qTox git ... "
		git clone https://github.com/tux3/qTox.git
	fi
	if [ -e $FA_DIR/.git/index ]; then # Check if this exists
		fcho "Filter_Audio git repo already inplace !"
		cd $FA_DIR
		git pull
		fcho "Please enter your password to install Filter_Audio:"
		sudo make install
	else
		fcho "Cloning Filter_Audio git ... "
		git clone https://github.com/irungentoo/filter_audio.git
		cd $FA_DIR
		fcho "Please enter your password to install Filter_Audio:"
		sudo make install
	fi
	
	read -r -p "wget Qt Creator? [Y/n] " response
	if [[ $response =~ ^([nN]|[nN])$ ]]; then
		cd $MAIN_DIR
		fcho "Now working in ${PWD}"
		fcho "Getting Qt Creator for Mac ..."
		sleep 2
		fcho "Go ..."
		sleep 1
		fcho "Go get a drink for this one ..."
		sleep 1
		fcho "It might take a while ..."
	
		# Now let's get Qt creator because: It helps trust me.
		wget $QT_DL
	fi
	
	read -r -p "Unpackage Qt Creator? [Y/n] " response
	if [[ $response =~ ^([nN]|[nN])$ ]]; then
	fcho "Please enter your password to mount Qt Creator to install:"
	sudo hdiutil attach $QT_DMG.dmg
	sudo cp -rf /Volumes/$QT_DMG/$QT_DMG.app $MAIN_DIR/qt-opensource-mac-installer.app
	sudo hdiutil detach /Volumes/$QT_DMG
	
	fcho "The following file: qt-opensource-mac-installer.app should now be located in your \$MAIN_DIR: ${MAIN_DIR}"
	fi
	
	read -r -p "Install Qt-Creator now? [Y/n] " response
	if [[ $response =~ ^([nN]|[nN])$ ]]; then
		echo "To finish install run: qt-opensource-mac-installer.app"
		echo "Before attempting to fun any other functions in this script. "
		exit
	else
	    open -W qt-opensource-mac-installer.app	
	fi
	
	fcho "If all went well you should now have all the tools needed to compile qTox!"
	
	read -r -p "Would you like to install toxcore now? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
		build-toxcore	
	else
	    fcho "You can simply use the -u command and say [Yes/n] when prompted"
	fi
	
}

function update {
	fcho "------------------------------"
	fcho "Starting update process ..."
	
	#First update Toxcore from git
	cd $TOXCORE_DIR
	fcho "Now in ${PWD}"
	fcho "Pulling ..."
	git pull
	read -r -p "Did Toxcore update from git? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
		build-toxcore	
	else
	    fcho "Moving on!"
	fi
	
	#Now let's update qTox!
	cd $QTOX_DIR
	fcho "Now in ${PWD}"
	fcho "Pulling ..."
	git pull
	read -r -p "Did qTox update from git? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
		fcho "Starting OSX bootstrap ..."
		fcho "Sudo required:"
		sudo bash ./bootstrap-osx.sh
	else
	    fcho "Moving on!"
	fi
	
}

function build {
	fcho "------------------------------"
	fcho "Starting build process ..."
	mkdir $BUILD_DIR
	cd $BUILD_DIR
	fcho "Now working in ${PWD}"
	fcho "Starting qmake ... "
	$QMAKE $QTOX_DIR/qtox.pro
	make
}

function deploy {
	fcho "------------------------------"
	fcho "starting deployment process ..."
	cd $BUILD_DIR
	if [ ! -d $BUILD_DIR ]; then
		fcho "Error: Build directory not detected, please run -ubd, or -b before deploying"
		exit
	fi
	mkdir $DEPLOY_DIR
	cp -r $BUILD_DIR/qTox.app $DEPLOY_DIR/qTox.app
	cd $DEPLOY_DIR
	fcho "Now working in ${PWD}"
	$MACDEPLOYQT qTox.app
}

function clean {
	fcho "------------------------------"
	fcho "Starting cleanup process ..."
	rm -r $BUILD_DIR
	fcho "Cleared out build files!"
}

if [ "$1" == "-i" ]; then
	install
fi
	
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

fcho "Nothing else, goodbye!" 
exit