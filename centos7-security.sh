#!/bin/bash
# setup linux system security
echo "############锁定用户###########"
# lock user
passwd -l dbus
passwd -l games
passwd -l nobody
passwd -l ftp
passwd -l mail
passwd -l shutdown
passwd -l halt
passwd -l operator
passwd -l sync
passwd -l adm
passwd -l lp

echo "###########锁定用户###########"
# lock file
chattr +i /etc/passwd
chattr +i /etc/shadow
chattr +i /etc/group
chattr +i /etc/gshadow

echo "#############密码保护#############"
# Password security
cp /etc/pam.d/system-auth /etc/pam.d/system-auth.bak
cp /etc/pam.d/sshd /etc/pam.d/sshd.bak
#设置终端登录限制
sed -i 's#auth        required      pam_env.so#auth        required      pam_env.so\nauth       required       pam_tally2.so  onerr=fail deny=6 even_deny_root unlock_time=300#' /etc/pam.d/system-auth


#设置ssh限制
echo "auth        required      pam_tally2.so onerr=fail deny=3 even_deny_root  unlock_time=300" >> /etc/pam.d/sshd


#禁止使用旧密码(root用户没有限制)
sed -i 's#password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok#password    sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5#' /etc/pam.d/system-auth


#密码复杂度设置
sed -i 's#password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=#password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=\npassword requisite pam_cracklib.so retry=3 difok=3 minlen=10 ucredit=-1 lcredit=-2 dcredit=-1 ocredit=-1 enforce_for_root#' /etc/pam.d/system-auth


# system timeout 5 minite auto logout
echo "TMOUT=300" >>/etc/profile

echo "##############历史记录设置#############"
# will system save history command list to 10
sed -i "s/HISTSIZE=1000/HISTSIZE=10/" /etc/profile

# enable /etc/profile go!
source /etc/profile

echo "#########syn优化##########"
# add syncookie enable /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf

sysctl -p # exec sysctl.conf enable

# optimizer sshd_config
sed -i "s/#MaxAuthTries 6/MaxAuthTries 6/" /etc/ssh/sshd_config
sed -i  "s/#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config


echo "#######重要命令md5sum校验#########"
# limit chmod important commands
chmod 700 /bin/ping
chmod 700 /usr/bin/who
chmod 700 /usr/bin/w
chmod 700 /usr/bin/whereis
chmod 700 /bin/vi
chmod 700 /usr/bin/which
chmod 700 /usr/bin/make
chmod 700 /bin/rpm

# history security

chattr +a /root/.bash_history
chattr +i /root/.bash_history

# write important command md5
cat > list << "EOF" 
/bin/ping
/usr/bin/who
/usr/bin/w
/usr/bin/whereis
/bin/vi
/usr/bin/vim
/usr/bin/which
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
