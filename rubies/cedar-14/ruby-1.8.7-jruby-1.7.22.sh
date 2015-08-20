#!/bin/sh

source `dirname $0`/../common.sh
source `dirname $0`/common.sh

docker run -v $OUTPUT_DIR:/tmp/output -v $CACHE_DIR:/tmp/cache -e VERSION=1.7.22 -e RUBY_VERSION=1.8.7 -t hone/jruby-builder:$STACK
