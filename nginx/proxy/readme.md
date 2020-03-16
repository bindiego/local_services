### Secured L7 L4 nginx proxy 代理

#### Build the binary 构建

In order to build the binary for the native docker container, we use the same [image](https://github.com/nginxinc/docker-nginx/blob/master/mainline/buster/Dockerfile) to build.

借助docker来构建，采用了跟dockerhub上官方的镜像相同的Debian镜像构建

Simply run

```shell
make builder-build
```

Or, if you would like to run without docker, you could run ```make build``` to get the nginx binary, but make sure to adjust the ```configure``` options accordingly.

如果不打算使用Docker，也可以直接使用```make build```构建。但注意调整相关的```configure```参数就好了。

#### Run it 跑起来

L7

```shell
make l7
```

By default, it runs on port ```7443```

Test the https proxy 测试一下

```shell
curl https://www.baidu.com/ -v -x localhost:7443
```

L4

```shell
make l4
```

By default, this runs on port ```4443```
