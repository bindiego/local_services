#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import sys, traceback

from threading import Thread

import csv
csvdata = []
csvfile = 'apiquery.csv'
csvfields = ['start', 'end', 'duration']

# Util function to write csv data into csv file
def write_csv():
  if len(csvdata) > 0:
    try:
      with open(csvfile, 'wb') as f:
        writer = csv.DictWriter(f, fieldnames=csvfields,
          delimiter=',',
          lineterminator='\r\n',
          doublequote=True,
          quoting=csv.QUOTE_ALL)
        writer.writeheader()
        writer.writerows(csvdata)
    except Exception, ex:
      print >>sys.stderr, "Error: writing csv file: " + csvfile
      print >>sys.stderr, traceback.format_exc()
      return -1
  else:
    print "Nothing to write"

import socket
def check_tcp_status(ip, port, interval=1, reps=10):
  for i in range(0, reps):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_address = (ip, port)

    d = {}
    print 'Connecting to %s:%s.' % server_address
    start = time.time()

    try:
      sock.connect(server_address)
    except:
      print 'Error'
    finally:
      end = time.time()
      d['start'] = time.strftime("%a %b %d %H:%M:%S %Y", time.localtime(start))
      d['end'] = time.strftime("%a %b %d %H:%M:%S %Y", time.localtime(end))
      d['duration'] = format(end - start, '.6f')
      csvdata.append(d)
      time.sleep(interval)

      message = "I'm TCP client"
      print 'Sending "%s".' % message
      sock.sendall(message)

      print 'Closing socket.'
      sock.close()

if __name__ == "__main__":
  threads = []
  try:
    for i in range(0, 2):
      threads.append(
        Thread(target=check_tcp_status,
          args=("apiquery.ptengine.cn", 80, 1, 5)
        )
      )

    # start all threads
    for p in threads:
      p.start()
    # wait all threads complete
    for p in threads:
      p.join()

    write_csv()

  except Exception, ex:
    print >>sys.stderr, "Error: unable to start thread"
    print >>sys.stderr, traceback.format_exc()
