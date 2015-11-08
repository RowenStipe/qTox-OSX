# How to build qTox on Mac for deployment (At least on 10.10 )
- REQUIRED: Toxcore (Latest Homebrew), Qt 5.5, filter_audio (Latest Git), Xcode, git (Homebrew), ffmpeg (Homebrew), qrencode (Homebrew), ond (obviously) Homebrew

- RECOMENDED: Github Dektop for Mac: https://mac.github.com

#### Install nessecarry applications

Install Xcode: https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12

Install Homebrew using Terminal ` ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" `

Homebrew prequisites `brew install git ffmpeg qrencode`

Toxcore Homebrew install formula
```
	brew tap Tox/tox
	brew install --HEAD libtoxcore
```

* Homebrew usage instructions: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/FAQ.md
	
Check out `filter_audio` from https://github.com/irungentoo/filter_audio
	1. Open Terminal type `cd /git/path/to/filter_audio/`
	2. In Terminal type `sudo make install`

Install Qt Creator 5.5 for compiling: http://www.qt.io/download-open-source/

##### The following is needed in-order to compile and deploy qTox

Check out the latest qTox version or using your own fork
	# 1. In Terminal cd to your qTox git DIR
	# 2. In Terminal type `sudo bash bootstrap-osx.sh`

Open Qt and open the Qt project file

Set compile from `Debug` to `Release` (Simply for folder name)

Click build and go get a drink if you want. You've got time.

From here you can use the created `qtox.app` in the  `build-qtox-Desktop_Qt_5_5_1_clang_64bit-Release` folder. (Might say -Debug if you didn't change to Release)

The created `qtox.app` will work on your system but it's not a self contained application and needs to be deployed to work on others systems.

##### Deploy for OSX

In Terminal CD to your `build-qtox-Desktop_Qt_5_5_1_clang_64bit-Release` directory. Possibly just `cd ~/build-qtox-Desktop_Qt_5_5_1_clang_64bit-Release/`

Now in terminal type 
```
/path/to/Qt/5.5/clang_64/bin/macdeployqt qtox.app

if you used a standard Qt install then

~/Qt/5.5/clang_64/bin/macdeployqt qtox.app
```

You may get the following
```
WARNING: Plugin "libqsqlodbc.dylib" uses private API and is not Mac App store compliant.
WARNING: Plugin "libqsqlpsql.dylib" uses private API and is not Mac App store compliant.
ERROR: no file at "/opt/local/lib/mysql55/mysql/libmysqlclient.18.dylib"
ERROR: no file at "/usr/local/lib/libpq.5.dylib"
``` 
* This doesn't effect the `qTox.app` file that is created

It is possible that some libraries might be missing from `/usr/local/lib/` or equivalent than those shown above, if so they need to be tracked down and added where the macdeployqt thinks they should be located. (Messy wording I know but I don’t have the list of libraries I needed when I got this running the first time.)