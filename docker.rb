# 根据Dockerfile，创建 image 文件	
$ docker image build -t

# 列出本机的所有 image 文件
$ docker image ls

# 删除 image 文件
$ docker image rm [imageName]

# 运行这个 imageName 文件,生成容器
$ docker container run imageName

# 在本机的另一个终端窗口，查出容器的 ID
$ docker container ls

# 停止指定的容器运行,向容器里面的主进程发出 SIGKILL 信号
$ docker container kill [containerID]

# 启动已经生成、已经停止运行的容器文件
$ docker container start [containerID]

# 终止容器运行, 向容器里面的主进程发出 SIGTERM 信号，然后过一段时间再发出 SIGKILL 信号。
$ docker container stop [containerID]

# docker container logs命令用来查看 docker 容器的输出，即容器里面 Shell 的标准输出。如果docker run命令运行容器的时候，没有使用-it参数，就要用这个命令查看输出。
$ docker container logs

#docker container exec命令用于进入一个正在运行的 docker 容器。如果docker run命令运行容器的时候，没有使用-it参数，就要用这个命令进入容器。一旦进入了容器，就可以在容器的 Shell 执行命令了。
$ docker container exec -it [containerID] /bin/bash

#docker container cp命令用于从正在运行的 Docker 容器里面，将文件拷贝到本机。下面是拷贝到当前目录的写法。
$ docker container cp [containID]:[/path/to/file] .

