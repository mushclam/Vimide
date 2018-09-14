echo "[VIMIDE Installing]"
echo "Check Vundle setup..."

# PWD
BASE=${PWD}
# vim bundle path
VIM_BUNDLE_HOME=${HOME}"/.vim/bundle"
# vimrc file names
VIMRC="/.vimrc"
INS_VIMRC=${PWD}"/install_vimrc"
UNINS_VIMRC=${PWD}"/uninstall_vimrc"
CONFIG="/compile.config"

# if vundle already installed, skip this process
# if not, install Vundle
if [ -w ${VIM_BUNDLE_HOME}"/Vundle.vim" ]; then
	echo "Already Vundle exist! Skip to install Vundle."
else
	echo "[Vundle Install]"
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Install Dist package of YCM tagbar
echo "[Install Dependency Packages]"
sudo apt-get install clang build-essential cmake python-dev python3-dev ctags -y

# if .vimrc is not exist in home dir, cp install_vimrc to home dir
# if not, Ask user to replace .vimrc.
if [ ! -w ${HOME}${VIMRC} ]; then
	cp ${INS_VIMRC} ${HOME}${VIMRC}
else
	echo "'.vimrc' is already exist!"
	echo -n "Do yo want replace old to new one? [y/N]"
	read ANSWER
	if [ ANSWER == 'y' ]; then
		cp ${INS_VIMRC} ${HOME}${VIMRC}
	else
		echo "[Install with original .vimrc]"
	fi
fi

# Install Other Plugins
vim +PluginInstall +qall

# Compile Vimproc
if [ -w ${VIM_BUNDLE_HOME}"/vimproc.vim" ]; then
    NAME=$(grep Vimproc ${BASE}${CONFIG})
    STATUS=${NAME##V*=}
    if [ ${STATUS} != "1" ]; then
        echo "[Compile Vimproc]"
        cd ${VIM_BUNDLE_HOME}"/vimproc.vim" && make && cd ${BASE}
        sed -i 's/Vimproc=0/Vimproc=1/' ${BASE}${CONFIG}
    else
        echo "[Vimproc Already Compiled]"
    fi
else
    echo "[Vimproc is not exist]"
fi

# Compile YCM
if [ -w ${VIM_BUNDLE_HOME}"/youcompleteme" ]; then
    NAME=$(grep YCM ${BASE}${CONFIG})
    STATUS=${NAME##Y*=}
    if [ ${STATUS} != "1" ]; then
        echo "[Compile YCM]"
        cd ${VIM_BUNDLE_HOME}"/youcompleteme"
        python3 install.py --clang-completer
        cd ${BASE}
        sed -i 's/YCM=0/YCM=1/' ${BASE}${CONFIG}
    else
        echo "[YCM Already Compiled]"
    fi
else
    echo "[YCM is not exist]"
fi

echo "[VIMIDE Installing DONE!]"
