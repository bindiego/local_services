## Shadowsocks with obfuscating

### Prerequisites

Install docker first.

[How to install docker on Ubuntu or Centos](https://github.com/bindiego/local_services/tree/develop/docker)

### Build the docker container

```make build```

### update the config.json according to your needs

```vim config.json```, yes vim FTW

### Run it

```make run```

Done.

### Client configuration

#### Phone

![](https://raw.githubusercontent.com/bindiego/localservices/develop/images/phone.png)

#### Computer

![](https://raw.githubusercontent.com/bindiego/localservices/develop/images/mac.png)

## To-do

- Switch to Alpine. I need this in about an hour so ... ye, when I have time or this stopped working one day :)

- Switch to [Rust](https://github.com/shadowsocks/shadowsocks-rust). Let's see :)

- Upgrade to [v2ray](https://github.com/shadowsocks/v2ray-plugin) plugin. Low priority since clients may not support
