#!/bin/bash
# Author: Ryan Ivis -- Ping Identity

# This installs required dependencies into the configure-es container. 
# These are REQUIRED for the enrichment script to work.

yum install -y epel-release
yum install -y python-pip
pip install requests