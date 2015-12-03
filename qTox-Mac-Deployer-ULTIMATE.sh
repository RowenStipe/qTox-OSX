#!/usr/bin/env bash

# qTox OSX auto BASH builder script by RowenStipe
# This uses the same process as doing it manually but with a few varients

# Use:./qTox-Mac-Deployer-ULTIMATE.sh [Processes/Install]
# Process: -u to update -b to build -d to make the aplication productionr eady or -ubd to run all at once
# Install: use -i to start install functionality

MAIN_DIR="/Users/${USER}" # Your home DIR really (Most of this happens in it) {DONT USE: ~ }
QT_DIR="${MAIN_DIR}/Qt5.5.1" # Folder name of QT install
VER="${QT_DIR}/5.5" # Potential future proffing for version testing
QMAKE="${VER}/clang_64/bin/qmake" # Don't change
MACDEPLOYQT="${VER}/clang_64/bin/macdeployqt" # Don't change

QTOX_DIR="${MAIN_DIR}/qTox" # Change to Git location

TOXCORE_DIR="${MAIN_DIR}/toxcore" # Change to Git location

FA_DIR="${MAIN_DIR}/filter_audio"

BUILD_DIR="${MAIN_DIR}/qTox-Mac_Build" # Change if needed

DEPLOY_DIR="${MAIN_DIR}/qTox-Mac_Deployed"

#Install stuff for Qt
DL_DIR="${MAIN_DIR}/Downloads"
QT_DMG="${DL_DIR}/qt-opensource-mac"
QT_DL="https://download.qt.io/official_releases/qt/5.5/5.5.1/qt-opensource-mac-x64-clang-5.5.1.dmg"
QT_DMG="qt-opensource-mac-x64-clang-5.5.1"


function fcho() {
	local msg="$1"; shift
	printf "\n$msg\n" "$@"
}

function build-toxcore {
	echo "Starting Toxcore build and install"
	cd $TOXCORE_DIR
	echo "Now working in: ${PWD}"
	
	#Check if libsodium is correct version
	if [ -e /usr/local/opt/libsodium/lib/libsodium.17.dylib ]; then
	   	fcho " Beginnning Toxcore compile "
  	else
		echo "Error: libsodium.17.dylib not found! Unable to build!"
		echo "Please make sure your Homebrew packages are up to date before retrying."
		exit 1
	fi
	sleep 3
	
	autoreconf -i 
	
	#Make sure the correct version of libsodium is used
	./configure --with-libsodium-headers=/usr/local/Cellar/libsodium/1.0.6/include/ --with-libsodium-libs=/usr/local/Cellar/libsodium/1.0.6/lib/
	
	sudo make clean
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
	fcho "Getting home brew formulas ..."
	sleep 3
	brew install git ffmpeg qrencode wget libtool automake autoconf libsodium check
	
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
		exit 3
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
	rm -r $BUILD_DIR
	rm -r $DEPLOY_DIR
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
		exit 0
	fi
	mkdir $DEPLOY_DIR
	cp -r $BUILD_DIR/qTox.app $DEPLOY_DIR/qTox.app
	cd $DEPLOY_DIR
	fcho "Now working in ${PWD}"
	$MACDEPLOYQT qTox.app
}

# The commands
if [ "$1" == "-i" ]; then
	install
	exit 0
fi
	
if [ "$1" == "-u" ]; then
	update
	exit 0
fi

if [ "$1" == "-b" ]; then
	build
	exit 0
fi

if [ "$1" == "-d" ]; then
	deploy
	exit 0
fi

if [ "$1" == "-ubd" ]; then
	update
	build
	deploy
	exit 0
fi

if [ "$1" == "-h" ]; then
	echo "This script was created to help ease the process of compiling and creating a distribuable qTox package for OSX systems."
	echo "The avilable commands are:"
	echo "-h -- This help text."
	echo "-i -- A slightly automated process for getting an OSX machine ready to build Toxcore and qTox."
	echo "-u -- Check for updates and build Toxcore from git & update qTox from git."
	echo "-b -- Builds qTox in: ${BUILD_DIR}"
	echo "-d -- Makes a distributeable qTox.app file in: ${DEPLOY_DIR}"
	echo "-ubd -- Does -u, -b, and -d sequentially"
	fcho "If you have anny issues with this script please report it to: https://github.com/RowenStipe/qTox-OSX/issues "
	fcho "Issues with Toxcore or qTox should be reported to their respective repos: https://github.com/irungentoo/toxcore | https://github.com/tux3/qTox"
	exit 0
fi

fcho "Oh dear! You seemed to of started this script improperly! Use -h to get avilable commands and information!" 
exit 0