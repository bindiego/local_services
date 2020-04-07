#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_address = ('127.0.0.1', 12345)
print "Starting up on %s:%s" % server_address
sock.bind(server_address)
sock.listen(1)
while True:
  print "Waiting for a connection"
  connection, client_address = sock.accept()
  try:
    print "Connection from", client_address
    data = connection.recv(1024)
    print "Receive '%s'" % data
  finally:
    connection.close()
