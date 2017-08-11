# 功能说明及验证：

## 用户锁定

`
 passwd -l username 
` 

## 创建用户权限锁定

```
chattr +i /etc/passwd
chattr +i /etc/shadow
chattr +i /etc/group
chattr +i /etc/gshadow
```
锁定 之后无法创建用户，如果要创建用户需要chattr -i 

## 密码保护
所有用户（包括root） 在终端登录错误6次之后，锁定用户300秒

`
sed -i 's#auth        required      pam_env.so#auth        required      pam_env.so\nauth       required       pam_tally2.so  onerr=fail deny=6 even_deny_root unlock_time=300#' /etc/pam.d/system-auth
`
***

ssh 登陆错误超过3次之后，无法登陆（包括root用户），锁定300秒
 
 
`
echo "auth        required      pam_tally2.so onerr=fail deny=3 even_deny_root  unlock_time=300" >> /etc/pam.d/sshd
`
***
 
重置密码不能使用之前5次设置的密码（root用户没有限制）
 
 
`
sed -i 's#password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok#password    sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5#' /etc/pam.d/system-auth
`
***
 
设置 密码复杂度（retry=3：强口令必须输入三次 difok=3：至少有三个字符不出现在老口令中 ucredit=-1 lcredit=-2 dcredit=-1 ocredit=-1:至少有一个大写，两个小写，一个字母，一个特殊符号 enforce_for_root：不可以强行修改root密码 ）


`
sed -i 's#password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=#password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=\npassword requisite pam_cracklib.so retry=3 difok=3 minlen=10 ucredit=-1 lcredit=-2 dcredit=-1 ocredit=-1 enforce_for_root#' /etc/pam.d/system-auth
`
***
 
登陆后如果五分钟内没有操作退出登录
 
`
echo "TMOUT=300" >>/etc/profile
`
***
 
用户只能显示历史纪录的条数
 
`
sed -i "s/HISTSIZE=1000/HISTSIZE=10/" /etc/profile
`
***
 
开启syn cookies ,可防止少量syn 攻击
 
`
echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf
`
***

ssh连接次数限制

```
sed -i "s/#MaxAuthTries 6/MaxAuthTries 6/" /etc/ssh/sshd_config
sed -i  "s/#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config
```

md5校验重要命令，在被攻击后可快速定位，是否有重要命令被删（添加了常规命令）
 
```
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
```
