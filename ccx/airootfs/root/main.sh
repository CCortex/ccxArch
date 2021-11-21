#!/usr/bin/env bash

# Startup script ccxArch automated install

set -e

# run every installation script with log output
runInstallScripts()
{
    cd script
    for s in *.sh
    do
        echo $s
        bash $s
    done
}

runInstallScripts
