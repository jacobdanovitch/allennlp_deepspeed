#!/bin/bash

pip uninstall -y deepspeed

cd /tmp
git clone https://github.com/microsoft/DeepSpeed

cd DeepSpeed
./install.sh

python basic_install_test.py
