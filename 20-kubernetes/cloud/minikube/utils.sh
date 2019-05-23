#!/usr/bin/env sh

install_envsubst () 
{
    if ! test -f /tmp/envsubst ; then
        curl -L "https://github.com/a8m/envsubst/releases/download/v1.1.0/envsubst-$(uname -s)-$(uname -m)" -o /tmp/envsubst
        chmod 755 /tmp/envsubst
    fi 
}