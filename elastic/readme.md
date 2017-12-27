### To increase file descriptors

#### CentOS7

file: /etc/security/limits.d/20-nproc.conf 

or maybe just file

/etc/security/limits.conf 

```
*          soft    nproc     4096
root       soft    nproc     unlimited
```

to

```
@ptmind          soft    nproc     65536
@ptmind          hard    nproc     65536
@ptmind          soft    nofile    65536
@ptmind          hard    nofile    65536
```

change 4096 to unlimited

double check 

```
sysctl -a | less
```

update

```
fs.file-max = 1614933
```

Finally, run the command

```
sudo sysctl -p; sysctl -p
```

### AQI data 
collected from http://www.stateair.net/
