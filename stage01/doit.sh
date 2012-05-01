#!/bin/bash

function download_and_setup_euca2ools {
        dir=$(cat ../input/2b_tested.lst  | grep EUCA2OOLS_PATH | cut -f2 -d '=' | sed 's/[ \r]//g') 
        if [ -z $dir ] || ! ls ../../$dir/euca2ools-2.0 > /dev/null ; then
            echo "Downloading euca2ools"
	    . ./download_euca2ools.sh
	    if [ ! $? -eq 0 ]; then
	   	echo "euca2ools installation failed"
   		exit 1
	    fi
	    export PYTHONPATH="$(pwd)/boto:$(pwd)/euca2ools-2.0"
	    export PATH="$(pwd)/euca2ools-2.0/bin:$PATH"
        else
            dir="../../$dir"
            echo "EUCA2OOLS DIR: $dir"
            export PYTHONPATH=$dir/boto:$dir/euca2ools-2.0
            export PATH=$dir/euca2ools-2.0/bin:$PATH
        fi
	echo "EUCA2OOLS VERSION: $(euca-version)"
}

download_and_setup_euca2ools

if [ $1 = "xen" ]; then
./bundleit.sh ../share/euca-ubuntu-9.04-x86_64/xen-kernel/vmlinuz-2.6.27.21-0.1-xen ../share/euca-ubuntu-9.04-x86_64/xen-kernel/initrd-2.6.27.21-0.1-xen ../share/euca-ubuntu-9.04-x86_64/ubuntu.9-04.x86-64.img
else
./bundleit.sh ../share/euca-ubuntu-9.04-x86_64/kvm-kernel/vmlinuz-2.6.28-11-generic ../share/euca-ubuntu-9.04-x86_64/kvm-kernel/initrd.img-2.6.28-11-generic ../share/euca-ubuntu-9.04-x86_64/ubuntu.9-04.x86-64.img
fi
