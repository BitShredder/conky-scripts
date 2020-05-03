#!/bin/bash

USER="$(who | awk '{print $1}')"
SUDO="$(whoami)"
CONKY="$(which conky)"

INSTALLDIR=/home/${USER}/.conky
INITSCRIPT=/usr/local/bin/kk-conky-init.sh

WIDGETS[1]="Fuckin' Calendar (A display of the current fuckin' day, month and year)"
WIDGETS[2]="BCD Clock (A binary coded decimal clock)"
WIDGETS[3]="OS Badge (Display your distro name and logo)"

SELECTED[1]=1
SELECTED[2]=1
SELECTED[3]=1

function print_banner {

  clear
  tput rev; tput bold
  echo " KK Conky Scripts Installer "
  tput sgr0
  echo ""

}

function check_privileges {

  if [[ $SUDO != "root" ]]; then
    echo -e "[ERROR] Install script must be run with root privileges.\n"
    echo -e "Try: sudo ./install.sh\n"
    exit 1
  fi

}

function check_env {

  echo -n "[*] Looking for conky executable...."
  tput cuf 14

  if [[ $CONKY = "" ]]; then
    tput setaf 1
    echo "FAILED"
    tput sgr0
    echo -e "\nCould not find 'conky' executable.\n"
    echo -e "Try installing the $(tput bold)conky-all$(tput sgr0) package with your package manager.\n"
    exit 1
  fi

  tput setaf 2
  echo "OK"
  tput sgr0

}

function print_install_menu {

  STATUS=""
  echo -e "Please select/deselect the widgets you want to install by entering the corresponding number\n"
  
  tput bold
  for idx in "${!WIDGETS[@]}"; do
    if [ ${SELECTED[$idx]} = 1 ]; then
      STATUS="+"
    else
      STATUS="-"
    fi
    echo "[${STATUS}] $idx: ${WIDGETS[$idx]}"
  done
  tput sgr0

  echo -ne "\nEnter selection: "

}

function install {

  echo -n "[*] installing scripts...."
  tput cuf 24

  if [ ! -d $INSTALLDIR ]; then
    mkdir $INSTALLDIR
  fi

  echo "#!/bin/bash" > $INITSCRIPT
  echo "sleep 2" >> $INITSCRIPT

  COUNTER=1

  for dir in */; do
    if [ ${SELECTED[$COUNTER]} = 1 ]; then
      cp -r ${dir} /home/${USER}/.conky/
      echo "conky -q -c /home/${USER}/.conky/${dir}conkyrc &" >> $INITSCRIPT
    fi
    COUNTER=$((COUNTER+1))
  done

  echo "exit" >> $INITSCRIPT
  chmod +x $INITSCRIPT

  tput setaf 2
  echo "OK"
  tput sgr0

}

function setup_autostart {

  echo -n "[*] Registering autostart...."
  tput cuf 21

  if [ ! -d /home/$USER/.config/autostart ]; then
    mkdir -p /home/$USER/.config/autostart
  fi

  DESKTOPFILE=/home/$USER/.config/autostart/kkconky.desktop
  touch $DESKTOPFILE
  
  echo "[Desktop Entry]" >> $DESKTOPFILE
  echo "Name=Conky" >> $DESKTOPFILE
  echo "Type=Application" >> $DESKTOPFILE
  echo "Comment=Conky init script" >> $DESKTOPFILE
  echo "Exec=/usr/local/bin/kk-conky-init.sh" >> $DESKTOPFILE
  echo "X-GNOME-Autostart-Phase=panel" >> $DESKTOPFILE
  echo "X-KDE-autostart-after=panel" >> $DESKTOPFILE

  tput setaf 2
  echo "OK"
  tput sgr0

}

check_privileges
print_banner

key=0
while [[ $key != "" ]]; do
  print_install_menu
  read -n 1 key
  case $key in
    1)
        [[ ${SELECTED[1]} = 1 ]] && SELECTED[1]=0 || SELECTED[1]=1
        ;;
    2)
        [[ ${SELECTED[2]} = 1 ]] && SELECTED[2]=0 || SELECTED[2]=1
        ;;
    3)
        [[ ${SELECTED[3]} = 1 ]] && SELECTED[3]=0 || SELECTED[3]=1
        ;;
  esac
  tput cup 2 0; tput ed
done

check_env
install
setup_autostart

echo -n "[*] Starting conky...."
tput cuf 28
$INITSCRIPT
tput setaf 2
echo "OK"
tput sgr0

echo -e "\nDone. Enjoy your KK Conky Scripts\n"