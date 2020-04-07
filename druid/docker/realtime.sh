#!/bin/bash -eu

usage="Usage: realtime.sh (start|stop|status)"

if [ $# -lt 1 ]; then
  echo $usage
  exit 1
fi

sh ./bin/node.sh realtime $1
