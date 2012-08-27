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
./bundleit.sh ../share/instance_images/precise-server/xen-kernel/vmlinuz-3.2.0-23-virtual ../share/instance_images/precise-server/xen-kernel/initrd.img-3.2.0-23-virtual ../share/instance_images/precise-server/precise-server-cloudimg-amd64-ext3.img
else
./bundleit.sh ../share/instance_images/precise-server/kvm-kernel/vmlinuz-3.2.0-23-virtual ../share/instance_images/precise-server/kvm-kernel/initrd.img-3.2.0-23-virtual ../share/instance_images/precise-server/precise-server-cloudimg-amd64-ext3.img
fi
