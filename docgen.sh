#!/bin/bash

set -x
rm -rf ./docs
mkdir ./docs
cp *.gif *.png docs/

JAZZY=$(type -p jazzy)
[[ -n "${JAZZY}" ]] && ${JAZZY} --min-acl internal \
                                -g https://github.com/bradhowes/SoundFonts -a "Brad Howes" \
                                -u https://linkedin.com/in/bradhowes
