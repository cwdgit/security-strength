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
