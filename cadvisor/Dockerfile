FROM google/cadvisor:latest
# ADD auth.htpasswd /auth.htpasswd

EXPOSE 8080
ENTRYPOINT ["/usr/bin/cadvisor", "--http_auth_file", "auth.htpasswd", "--http_auth_realm", "localhost"]
