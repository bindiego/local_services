## Force https

I generated the [certificate](https://gist.github.com/bindiego/15ceb929310d4bc160e882d7a0b2cfcb) myself and do the redirection at nginx.

### Basic auth for a server

generate username password

```
htpasswd -c -i -b auth.htpasswd <USERNAME> <PASSWORD>
```

consult the cadvisor site configuration for more details.

More details for [nginx](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/)
