#!/bin/bash

# Scrip installs all the software needed for my "Home Lab" server:
# Cockpit, Samba, Plex, Fail2Ban, Docker, and Docker-compose
# The server can run a web-based graphical interface,
# website hosting, file server, stream videos, photos, and audio. 
# Website hosting runs on Nginx, WordPress, and Mysql.

source .var

banner()
{
  echo "+------------------------------------------+"
  printf "| %-40s |\n" "$(date)"                                  
  echo "|                                          |"
  printf "|$(tput bold) %-40s $(tput sgr0)|\n" "$@"               
  echo "+------------------------------------------+"
}

banner2()
{
  echo "+------------------------------------------+"
  printf "|$(tput bold) %-40s $(tput sgr0)|\n" "$@"
  echo "+------------------------------------------+"
}

banner "    S T A R T "

echo
echo

banner2 "    C R E A T E  U S E R"
useradd -p $(openssl passwd $USERPASS) $USER -m -c "$USERROLL" -G sudo -s /bin/bash
echo
echo "        $USER"

echo
echo

banner2 "    L A P T O P  L I D  O F F"
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
echo
echo "HIBERNATE/SLEEP/SUSPEND IS OFF"

echo
echo

banner2 "    U P D A T E  O S"
apt update && apt upgrade -y
echo
echo "ALL UP TO DAIT"

echo
echo


banner2 "    C R E A T E D  D I R"
mkdir /home/$USER/{.ssh,$SAMBA,}
mkdir /home/$USER/$SAMBA/{public_files,$PLEX}
mkdir /home/$USER/$SAMBA/$PLEX/{movies,series,cartoons,anime,photos,homevideo}
echo "
     - .ssh
     - $SAMBA
     - public_files
     - $PLEX"


echo
echo

banner2 "    P O L I C Y  U P D A T E"
groupadd --system $USERGROUP
groupadd --system smbgroup
groupadd --system dockergroup
groupadd --system plexgroup

useradd --system --no-create-home --group dockergroup,$USERGROUP -s /bin/false docker
useradd --system --no-create-home --group smbgroup -s /bin/false smbuser
useradd --system --no-create-home --group plexgroup -s /bin/false plex

usermod -aG docker,adm $USER

chown -R $USER:$USER /home/$USER
chown -R plex: /home/$USER/$SAMBA/$PLEX
chown -R $USER:docker /home/$USER

chown -R smbuser:smbgroup /home/$USER/$SAMBA
chmod -R g+w /home/$USER/$SAMBA
echo "
     - $USER
     - Samba
     - Docker
     - Plex"

echo
echo

banner2 "    S S H  K E Y"
echo "$KEY" >> /home/$USER/.ssh/authorized_keys
echo
echo "SSH KEY FROM "$SSHUSER" ADDED"

echo
echo

banner2 "L O C K  S S H"
bash lock_ssh.sh

echo
echo

sleep 2s

banner2 "    C O C K P I T  S E T U P"
apt install cockpit -y
cat <<EOF > /etc/netplan/00-installer-config.yaml
network:
  renderer: NetworkManager
  ethernets:
    $MREZA:
      dhcp4: true
  version: 2
EOF

netplan apply && service cockpit start

echo
echo

banner2 "S A M B A  S E T U P"
apt install samba -y

cat <<EOF > /etc/samba/smb.conf
[global]
server string = File Server
workgroup = WORKGROUP
security = user
map to guest = Bad User
name resolve order = bcast host
include = /etc/samba/shares.conf
EOF

cat <<EOF > /etc/samba/shares.conf
[Public Files]
path = home/$USER/$SAMBA/public_files
force user = smbuser
force group = smbgroup
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
public = yes
writable = yes

[Plex]
path = home/$USER/$SAMBA/$PLEX
orce user = smbuser
force group = smbgroup
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
public = yes
writable = yes
EOF

service smbd start

echo
echo

banner2 "    P L E X  S E T U P"
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

apt update
echo y | apt install plexmediaserver -y

service plexmediaserver start
cat <<EOF > /etc/ufw/applications.d/plexmediaserver
[plexmediaserver]
title=Plex Media Server (Standard)
description=The Plex Media Server
ports=32400/tcp|3005/tcp|5353/udp|8324/tcp|32410:32414/udp

[plexmediaserver-dlna]
title=Plex Media Server (DLNA)
description=The Plex Media Server (additional DLNA capability only)
ports=1900/udp|32469/tcp

[plexmediaserver-all]
title=Plex Media Server (Standard + DLNA)
description=The Plex Media Server (with additional DLNA capability)
ports=32400/tcp|3005/tcp|5353/udp|8324/tcp|32410:32414/udp|1900/udp|32469/tcp
EOF

echo
echo

banner2 "    D O C K E R  S E T U P"
apt install docker.io -y && apt install docker-compose -y

echo
echo

banner2 "    C L O N E  W E B S I T E  C O N F I G"
# Create docker-compose config
git clone https://github.com/sekkigit/wordpress.git /home/$USER/docker

echo "
    CREATED:

     - .env
     - docker-compose.yml
     - default.conf"
echo
echo

banner2 "    U F W  C O N F I G"
ufw default reject incoming
ufw default allow outgoing
ufw limit $PORTSSH/tcp
ufw allow 9090/tcp
ufw allow 80
ufw allow 443
ufw allow Samba
ufw app update plexmediaserver
ufw allow plexmediaserver-all
ufw --force enable
ufw status

sleep 2

echo
echo

banner2 "    F A I L 2 B A N"
apt install fail2ban -y
systemctl enable fail2ban
systemctl start fail2ban
echo
echo "Fail2Ban STARTED"

echo
echo

banner2 "    D O C K E R - C O M P O S E  U P"
docker-compose -f /home/$USER/docker/docker-compose.yml up -d
docker ps

echo
echo

banner2 "    C L E A N  U P  P A C K A G E"
apt autoclean
apt autoremove
apt clean

echo
echo

banner2 "I N S T A L L E D"
echo "
    SERVICES:

     - COCKPIT
     - DOCKER
     - SAMBA
     - PLEX
     - UFW
     - FAIL2BAN"

echo
echo

banner2 "C H E K  S T A T U S"
echo "
  OPEN IN WEB:

     - $IP:9090       :Cockpit
     - $IP:32400/web  :Plex
     - $IP:80         :Website

    OPEN IN EXPLORER:

     - $IP            :Samba
     
    PUBLIC IP:

     - $PUBIP"
echo

banner "ssh -p $PORTSSH $USER@$IP : $USERPASS"

cat <<EOF > log
_________________________________________________________________
CREATED:

     - $USER:User
     - $USERPASS:User pass
     - $SSHUSER:SSH user
     - $PORTSSH:SSH port
     - $IP:80:Website
     - $IP:9090:Cockpit
     - $IP:32400/web:Plex
     - $IP:Samba
     - $PUBIP:Public IP

  ssh -p $PORTSSH $USER@$IP : $USERPASS
-----------------------------------------------------------------
EOF