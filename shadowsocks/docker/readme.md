## Shadowsocks with obfuscating

### Prerequisites

Install docker first. 先安装一下Docker吧，下面的脚本很快搞定。

[How to install docker on Ubuntu or Centos](https://github.com/bindiego/local_services/tree/develop/docker)

### Build the docker container

```make build```

### update the config.json according to your needs 更新一下配置文件，主要就密码就好了

```vim config.json```, yes vim FTW

### Run it

```make run```

Done.

```make all``` 构建镜像然后跑起来

### Client configuration 客户端配置，看下截图吧，比较简单

#### Phone

![](https://raw.githubusercontent.com/bindiego/local_services/develop/shadowsocks/docker/images/phone.png)

#### Computer

![](https://raw.githubusercontent.com/bindiego/local_services/develop/shadowsocks/docker/images/mac.png)

## To-do

- Switch to Alpine. I need this in about an hour so ... ye, when I have time or this stopped working one day :)

- Switch to [Rust](https://github.com/shadowsocks/shadowsocks-rust). Let's see :)

- Upgrade to [v2ray](https://github.com/shadowsocks/v2ray-plugin) plugin. Low priority since clients may not support
