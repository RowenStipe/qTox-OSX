#!/usr/bin/env bash

# qTox OSX auto BASH builder script by RowenStipe
# This uses the same process as doing it manually but with a few varients

# Use:./qTox-Mac-Deployer-ULTIMATE.sh [Process] [OPTIONAL]
# Process: -u to update -b to build -d or -ubd to run all at once
# optional -c value for cleanup

# Set your main Dir
MAIN_DIR="/Users/Rowen" # Your home DIR really (Most of this happens in it) {DONT USE: ~ }
QT_DIR="${MAIN_DIR}/Qt" # Folder name of QT install
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

function install {
	fcho "=============================="
	fcho "This script will install the nessicarry applications and libraries needed to compile qTox properly."
	fcho "Note that this is not a 100% automated install it just helps simplfiy the process for less experianced or lazy users."
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
	
	cd $MAIN_DIR # just in case
	if [ -e $TOX_DIR/.git/index] # Check if this exists
		fcho "Toxcore git repo already inplace !"
		cd $TOX_DIR
		git pull
	else
		fcho "Cloning Toxcore git ... "
		git clone https://github.com/irungentoo/toxcore.git
	fi
	if [ -e $QTOX_DIR/.git/index] # Check if this exists
		fcho "qTox git repo already inplace !"
		cd $QTOX_DIR
		git pull
	else
		fcho "Cloning qTox git ... "
		git clone https://github.com/tux3/qTox.git
	fi
	if [ -e $FA_DIR/.git/index] # Check if this exists
		fcho "Filter_Audio git repo already inplace !"
		cd $FA_DIR
		git pull
		sudo make install
	else
		fcho "Cloning Filter_Audio git ... "
		git clone https://github.com/irungentoo/filter_audio.git
		cd $FA_DIR
		sudo make install
	fi
	
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
	fcho "Please enter your password to mount Qt Creator to install:"
	sudo hdutil attach $QT_DMG.dmg
	
}

function update {
	fcho "------------------------------"
	fcho "Starting update process ..."
	
	#First update Toxcore from git
	cd $TOXCORE_DIR
	fcho "Now in ${PWD}"
	fcho "Pulling ..."
	git pull
	# The following was addapted from: https://github.com/irungentoo/toxcore/blob/47cac28df4065c52fb54a732759d551d79e45af7/other/osx_build_script_toxcore.sh
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