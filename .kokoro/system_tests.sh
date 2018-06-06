#!/bin/bash

source $KOKORO_GFILE_DIR/secrets.sh

cd github/ruby-docs-samples/
./spec/kokoro-run-all.sh
