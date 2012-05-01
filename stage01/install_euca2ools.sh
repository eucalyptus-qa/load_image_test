
        #dir=$(cat ../input/2b_tested.lst  | grep EUCA2OOLS_PATH | cut -f2 -d '=' | sed 's/[ \r]//g') 
        
        echo "Downloading euca2ools"
	    . ./download_euca2ools.sh
	    if [ ! $? -eq 0 ]; then
	   	echo "euca2ools installation failed"
   		exit 1
	    fi
	    #export PYTHONPATH="$(pwd)/boto:$(pwd)/euca2ools-2.0"
	    #export PATH="$(pwd)/euca2ools-2.0/bin:$PATH"
        #else
        #    dir="../../$dir"
        #    echo "EUCA2OOLS DIR: $dir"
        #    export PYTHONPATH=$dir/boto:$dir/euca2ools-2.0
        #    export PATH=$dir/euca2ools-2.0/bin:$PATH
   
	    #echo "EUCA2OOLS VERSION: $(euca-version)"
