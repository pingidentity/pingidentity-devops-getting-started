#!/bin/bash

# This installs required dependencies into the configure-es container. These are used in the enrichment script.
# Author: Ryan Ivis -- Ping Identity

yum install -y epel-release
yum install -y python-pip
pip install requests