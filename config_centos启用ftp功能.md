# https://www.kancloud.cn/chandler/bc-linux/52710
centos启用ftp功能
vsftpd作为FTP服务器，在Linux系统中是非常常用的。下面我们介绍如何在centos系统上安装vsftp。
什么是vsftpd
vsftpd是一款在Linux发行版中最受推崇的FTP服务器程序。特点是小巧轻快，安全易用。
vsftpd 的名字代表”very secure FTP daemon”, 安全是它的开发者 Chris Evans 考虑的首要问题之一。在这个 FTP 服务器设计开发的最开始的时候，高安全性就是一个目标。
##1、安装vsftpd
1、以管理员（root）身份执行以下命令
yum install vsftpd
2、设置开机启动vsftpd ftp服务
chkconfig vsftpd on
3、启动vsftpd服务(默认ftp服务是没有启动的，用下面命令启动)
service vsftpd start

管理vsftpd相关命令：

停止vsftpd:  service vsftpd stop

重启vsftpd:  service vsftpd restart
安装完后，有/etc/vsftpd/vsftpd.conf 文件，用来配置，还有新建了一个ftp用户和ftp的组，指向home目录为/var/ftp,默认是nologin（不能登录系统）

可以用下面命令查看用户

cat /etc/passwd

2、安装ftp客户端组件（用来验证是否vsftpd）
yum -y install ftp

执行命令尝试登录

ftp localhost

输入用户名ftp，密码随便（因为默认是允许匿名的）
登录成功，就代表ftp服务可用了。
但是，外网是访问不了的，所以还要继续配置。
3、配置防火墙
因为ftp默认的端口为21，而centos默认是没有开启的，所以要修改iptables文件

vi /etc/sysconfig/iptables

在行上面有22 -j ACCEPT 下面另起一行输入跟那行差不多的，只是把22换成21，或者添加这行代码：-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT，然后:wq保存。
保存和关闭文件，重启防火墙：

service iptables restart

外网是可以访问上去了，可是发现没法返回目录，也上传不了，因为selinux作怪了。
##4、配置vsftpd服务器
默认的配置文件是/etc/vsftpd/vsftpd.conf，你可以用文本编辑器打开。
vi /etc/vsftpd/vsftpd.conf
添加ftp用户
下面是添加ftpuser用户，设置根目录为/home/wwwroot/ftpuser,禁止此用户登录SSH的权限，并限制其访问其它目录。
１、修改/etc/vsftpd/vsftpd.conf

把第一行的 anonymous_enable=YES ，改为NO，取消匿名登陆
将底下三行
#chroot_list_enable=YES
# (default follows)
#chroot_list_file=/etc/vsftpd.chroot_list
改为

chroot_list_enable=YES
# (default follows)
chroot_list_file=/etc/vsftpd/chroot_list
重启
service vsftpd restart

##5、新建一个用户(ftpuser为用户名，随便就可以)

useradd ftpuser

修改密码（输入两次）

passwd ftpuser

这样一个用户建完，可以用这个登录，记得用普通登录不要用匿名了。登录后默认的路径为 /home/ftpuser.
> 这种方法不能设置自己的目录，推荐使用下面的方法设置用户和用户ftp目录。

6、增加用户ftpuser，指向目录/home/wwwroot/ftpuser,禁止登录SSH权限。
useradd -d /home/wwwroot/ftpuser -g ftp -s /sbin/nologin ftpuser

1、设置用户口令

passwd ftpuser

2、编辑文件chroot_list:

vi /etc/vsftpd/chroot_list
内容为ftp用户名,每个用户占一行,如：
peter
john
另外，如果觉得以后管理ftp用户名嫌麻烦，可以使用centos官方发布的脚本管理。地址如下：

http://wiki.centos.org/HowTos/Chroot_Vsftpd_with_non-system_users

7、修改selinux（遇到的问题经常与之有关）
getsebool -a | grep ftp

执行上面命令，再返回的结果看到两行都是off，代表，没有开启外网的访问。(这是因为服务器开启了selinux，这限制了FTP的登录。)

....

allow_ftpd_full_access off

....

....

ftp_home_dir off
只要把上面都变成on就行

执行

setsebool -P allow_ftpd_full_access 1

setsebool -P ftp_home_dir off 1
再重启一下vsftpd

service vsftpd restart

这样应该没问题了（如果，还是不行，看看是不是用了ftp客户端工具用了passive模式访问了，如提示Entering Passive mode，就代表是passive模式，默认是不行的，因为ftp passive模式被iptables挡住了，下面会讲怎么开启，如果懒得开的话，就看看你客户端ftp是否有port模式的选项，或者把passive模式的选项去掉。如果客户端还是不行，看看客户端上的主机的电脑是否开了防火墙，关吧）

8、开启passive模式
默认是开启的，但是要指定一个端口范围，打开vsftpd.conf文件，在后面加上

pasv_min_port=30000
pasv_max_port=30999
表示端口范围为30000~30999，这个可以随意改。

改完重启一下vsftpd

由于指定这段端口范围，iptables也要相应的开启这个范围，所以像上面那样打开iptables文件

也是在21上下面另起一行，更那行差不多，只是把21 改为30000:30999,然后:wq保存，重启下iptables。这样就搞定了。
