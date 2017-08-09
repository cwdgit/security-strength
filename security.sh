#!/bin/bash
# setup linux system security

# lock user
passwd -l xfs
passwd -l news
passwd -l nscd
passwd -l dbus
passwd -l vcsa
passwd -l games
passwd -l nobody
passwd -l avahi
passwd -l haldaemon
passwd -l gopher
passwd -l ftp
passwd -l mailnull
passwd -l pcap
passwd -l mail
passwd -l shutdown
passwd -l halt
passwd -l uucp
passwd -l operator
passwd -l sync
passwd -l adm
passwd -l lp

# lock file
chattr +i /etc/passwd
chattr +i /etc/shadow
chattr +i /etc/group
chattr +i /etc/gshadow

# Password security
cp /etc/pam.d/system-auth /etc/pam.d/system-auth.bak
cp /etc/pam.d/sshd /etc/pam.d/sshd.bak

sed -i 's#auth        required      pam_env.so#auth        required      pam_env.so\nauth       required       pam_tally.so  onerr=fail deny=6 unlock_time=300#' /etc/pam.d/system-auth

sed -i 's#auth        required      pam_env.so#auth        required      pam_env.so\nauth       required       pam_tally.so  onerr=fail deny=6 unlock_time=300#' /etc/pam.d/sshd

#sed -i 's#PASS_MAX_DAYS   99999#PASS_MAX_DAYS   90#' /etc/login.defs
#sed -i 's#PASS_MIN_DAYS   0#PASS_MAX_DAYS   60#' /etc/login.defs
#sed -i 's#PASS_MIN_LEN    5#PASS_MIN_LEN    10#' /etc/login.defs
#sed -i 's#PASS_WARN_AGE   7#PASS_WARN_AGE   10#' /etc/login.defs

#sed -i 's#password    sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok#password    sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5#'

#echo "password requisite pam_cracklib.so retry=3 difok=3 minlen=10 ucredit=-1 lcredit=-2 dcredit=-1 ocredit=-1" >> /etc/pam.d/system-auth

# system timeout 5 minite auto logout
echo "TMOUT=300" >>/etc/profile


# will system save history command list to 10
sed -i "s/HISTSIZE=1000/HISTSIZE=10/" /etc/profile

# enable /etc/profile go!
source /etc/profile

# add syncookie enable /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf

sysctl -p # exec sysctl.conf enable

# optimizer sshd_config
sed -i "s/#MaxAuthTries 6/MaxAuthTries 6/" /etc/ssh/sshd_config
sed -i  "s/#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config

# limit chmod important commands
chmod 700 /bin/ping
chmod 700 /usr/bin/finger
chmod 700 /usr/bin/who
chmod 700 /usr/bin/w
chmod 700 /usr/bin/locate
chmod 700 /usr/bin/whereis
chmod 700 /sbin/ifconfig
chmod 700 /usr/bin/pico
chmod 700 /bin/vi
chmod 700 /usr/bin/which
chmod 700 /usr/bin/gcc
chmod 700 /usr/bin/make
chmod 700 /bin/rpm

# history security

chattr +a /root/.bash_history
chattr +i /root/.bash_history

# write important command md5
cat > list << "EOF" 
/bin/ping
/bin/finger
/usr/bin/who
/usr/bin/w
/usr/bin/locate
/usr/bin/whereis
/sbin/ifconfig
/bin/pico
/bin/vi
/usr/bin/vim
/usr/bin/which
/usr/bin/gcc
/usr/bin/make
/bin/rpm
EOF

for i in `cat list`
do
   if [ ! -x $i ];then
   echo "$i not found,no md5sum!"
  else
   md5sum $i >> /var/log/`hostname`.log
  fi
done
rm -f list
