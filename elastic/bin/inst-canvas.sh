#!/bin/bash

./deploy/kibana/bin/kibana-plugin remove canvas

NODE_OPTIONS="--max-old-space-size=4096" ./deploy/kibana/bin/kibana-plugin install https://download.elastic.co/kibana/canvas/kibana-canvas-0.1.1865.zip

