#!/bin/bash

USER="$(who | awk '{print $1}')"
SUDO="$(whoami)"
CONKY="$(which conky)"

function print_banner {

  echo ""
  tput rev; tput bold
  echo " KK Conky Scripts Installer "
  tput sgr0
  echo ""

}

function check_env {

  echo -n "[*] Looking for conky executable...."

  if [[ $CONKY == "" ]]; then
    echo -e "[ERROR] Could not find 'conky' executable.\n"
    echo -e "Try: sudo apt install conky-all"
    exit 1
  fi

  echo "OK"

}

function check_privileges {

  echo -n "[*] Checking privileges...."

  if [[ $SUDO != "root" ]]; then
    echo -e "[ERROR] Install script must be run with root priveleges. Try running as:\n\n"
    echo -e "sudo ./install.sh\n"
    exit 1
  fi

  echo "OK"

}

function setup_init_script {

  echo -n "[*] Creating startup file...."

  if [[ -f !/home/$USER/.config/autostart ]]; then
    mkdir -p /home/$USER/.config/autostart
  fi

  FILE=/usr/local/bin/kk-conky-init.sh
  echo "#!/bin/bash" >> $FILE
  echo "sleep 2" >> $FILE

  for dir in */; do
    echo "conky -q -c /home/$USER/.conky/$dir/conkyrc &" >> $FILE
  done

  echo "exit" >> $FILE
  chmod +x $FILE

  echo "OK"

}

function setup_autostart {

  echo -n "[*] Registering autostart...."

  DESKTOPFILE=/home/$USER/.config/autostart/kkconky.desktop
  touch $DESKTOPFILE
  
  echo "[Desktop Entry]" >> $DESKTOPFILE
  echo "Name=Conky" >> $DESKTOPFILE
  echo "Type=Application" >> $DESKTOPFILE
  echo "Comment=Conky init script" >> $DESKTOPFILE
  echo "Exec=/usr/local/bin/kk-conky-init.sh" >> $DESKTOPFILE
  echo "X-GNOME-Autostart-Phase=panel" >> $DESKTOPFILE
  echo "X-KDE-autostart-after=panel" >> $DESKTOPFILE

  echo "OK"

}

print_banner
check_env
check_privileges
setup_init_script
setup_autostart

echo -e "\nDone. Enjoy your KK Conky Scripts\n"