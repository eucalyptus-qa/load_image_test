#!/usr/bin/perl
use strict;

require "../lib/timed_run.pl";

my $distro = "";
my $version = "";
my $arch = "64";

my $line;

read_input_file();

$distro = $ENV{'QA_DISTRO'};
$version = $ENV{'QA_DISTRO_VER'};
$arch = $ENV{'QA_ARCH'};

print "\n";

print "Installing latest euca2ools\n";
print `./install_euca2ools.sh`;

my $image = "";
my $image_vmlinuz = "";
my $image_initrd = "";

my $is_custom_image = 0;

if( is_custom_load_image_from_memo() ){
	print "\n";
	if( !is_custom_load_image_vmlinuz_from_memo() ){
		print "[TEST_REPORT]\tFAILED:You must provide CUSTOM_LOAD_IMAGE_VMLINUZ file\n";
		exit(1);
	};
	print "\n";
	if( !is_custom_load_image_initrd_from_memo() ){
		print "[TEST_REPORT]\tFAILED:You must provide CUSTOM_LOAD_IMAGE_INITRD file\n";
		exit(1)
	};
	print "\n";

	$is_custom_image = 1;
};



if( $is_custom_image == 1 ){
    print "Loading custom images\n";
	print "\n";

	$image = $ENV{'QA_MEMO_CUSTOM_LOAD_IMAGE'};
	$image_vmlinuz = $ENV{'QA_MEMO_CUSTOM_LOAD_IMAGE_VMLINUZ'};
	$image_initrd = $ENV{'QA_MEMO_CUSTOM_LOAD_IMAGE_INITRD'};

}elsif( $distro eq "UBUNTU" || $distro eq "DEBIAN" || $distro eq "FEDORA" || ( ($distro eq "RHEL" || $distro eq "CENTOS") && $version =~ /^6\./) || $ENV{'IS_VMWARE'} == 1 ){
	print "Distro $distro\n";
	print "Loading KVM images\n";
	print "\n";

	if( $arch eq "64" ){
		$image = "instance_images/precise-server/precise-server-cloudimg-amd64-ext3.img";
		$image_vmlinuz = "instance_images/precise-server/kvm-kernel/vmlinuz-3.2.0-23-virtual";
		$image_initrd = "instance_images/precise-server/kvm-kernel/initrd.img-3.2.0-23-virtual";
	}else{
		$image = "euca-ubuntu-9.04-i386/ubuntu.9-04.x86.img";
		$image_vmlinuz = "euca-ubuntu-9.04-i386/kvm-kernel/vmlinuz-2.6.28-11-server";
		$image_initrd = "euca-ubuntu-9.04-i386/kvm-kernel/initrd.img-2.6.28-11-server";
	};

}elsif( $distro eq "OPENSUSE" || $distro eq "SLES" || ( ($distro eq "RHEL" || $distro eq "CENTOS") && $version =~ /^5\./) ){
	print "Distro $distro\n";
        print "Loading XEN images\n";
	print "\n";

        if( $arch eq "64" ){
                $image = "instance_images/precise-server/precise-server-cloudimg-amd64-ext3.img";
                $image_vmlinuz = "instance_images/precise-server/xen-kernel/vmlinuz-3.2.0-23-virtual";
                $image_initrd = "instance_images/precise-server/xen-kernel/initrd.img-3.2.0-23-virtual";
        }else{
                $image = "euca-ubuntu-9.04-i386/ubuntu.9-04.x86.img";
                $image_vmlinuz = "euca-ubuntu-9.04-i386/xen-kernel/vmlinuz-2.6.24-19-xen";
                $image_initrd = "euca-ubuntu-9.04-i386/xen-kernel/initrd.img-2.6.24-19-xen";
        };

}else{
	print "[TEST_REPORT]\tFAILED : UNKNOWN DISTRO $distro !!\n";
	exit(1);
};


print "\n";
print "IMAGE\t$image\n";
print "IMAGE_VMLINUZ\t$image_vmlinuz\n";
print "IMAGE_INITRD\t$image_initrd\n";
print "\n";



my $cmd = "./bundleit.sh ../share/$image_vmlinuz ../share/$image_initrd ../share/$image";

print "COMMAND: $cmd\n\n";

my $toed = timed_run("$cmd", 1800);             # 30 min deadline

my $output = get_recent_outstr();
my $err_str = get_recent_errstr();

print "\n################# STDOUT ##################\n";
print $output . "\n";
print "\n\n################# STDERR ##################\n";
print $err_str . "\n";

if( $toed ){
	print "[TEST_REPORT]\tFAILED : LOAD IMAGE TIME-OUT !!\n";
	exit(1);
};

my @temp_arr = split( /\n/, $output );
my $last_m = @temp_arr[@temp_arr-1];

if( $last_m =~ /eki(.+)\s+eri(.+)\semi(.+)/ ){
	print "Last Message : $last_m\n";
	print "[TEST_REPORT]\tLOAD IMAGE has Completed\n";
	exit(0);
}else{
	print "[TEST_REPORT]\tLOAD IMAGE has FAILED !!\n";
	exit(1);
};

exit(1);

1;







####################### SUB-ROUTINES ####################################


sub is_custom_load_image_from_memo{
	$ENV{'QA_MEMO_CUSTOM_LOAD_IMAGE'} = "";
        if( $ENV{'QA_MEMO'} =~ /^CUSTOM_LOAD_IMAGE=(.+)\n/m ){
                my $extra = $1;
                $extra =~ s/\r//g;
                print "FOUND in MEMO\n";
                print "CUSTOM_LOAD_IMAGE=$extra\n";
                $ENV{'QA_MEMO_CUSTOM_LOAD_IMAGE'} = $extra;
                return 1;
        };
        return 0;
};



sub is_custom_load_image_vmlinuz_from_memo{
	$ENV{'QA_MEMO_CUSTOM_LOAD_IMAGE_VMLINUZ'} = "";
        if( $ENV{'QA_MEMO'} =~ /^CUSTOM_LOAD_IMAGE_VMLINUZ=(.+)\n/m ){
                my $extra = $1;
                $extra =~ s/\r//g;
                print "FOUND in MEMO\n";
                print "CUSTOM_LOAD_IMAGE_VMLINUZ=$extra\n";
                $ENV{'QA_MEMO_CUSTOM_LOAD_IMAGE_VMLINUZ'} = $extra;
                return 1;
        };
        return 0;
};

sub is_custom_load_image_initrd_from_memo{
	$ENV{'QA_MEMO_CUSTOM_LOAD_IMAGE_INITRD'} = "";
        if( $ENV{'QA_MEMO'} =~ /^CUSTOM_LOAD_IMAGE_INITRD=(.+)\n/m ){
                my $extra = $1;
                $extra =~ s/\r//g;
                print "FOUND in MEMO\n";
                print "CUSTOM_LOAD_IMAGE_INITRD=$extra\n";
                $ENV{'QA_MEMO_CUSTOM_LOAD_IMAGE_INITRD'} = $extra;
                return 1;
        };
        return 0;
};



# Read input values from input.txt
sub read_input_file{

	my $is_memo = 0;
	my $memo = "";

	open( INPUT, "< ../input/2b_tested.lst" ) || die $!;

	$ENV{'QA_DISTRO'} = "";
	$ENV{'IS_VMWARE'} = 0;

	my $line;
	while( $line = <INPUT> ){
		chomp($line);
		if( $is_memo ){
			if( $line ne "END_MEMO" ){
				$memo .= $line . "\n";
			};
		};

        	if( $line =~ /^([\d\.]+)\t(.+)\t(.+)\t(\d+)\t(.+)\t\[(.+)\]/ ){
			my $qa_ip = $1;
			my $qa_distro = $2;
			my $qa_distro_ver = $3;
			my $qa_arch = $4;
			my $qa_source = $5;
			my $qa_roll = $6;

			my $this_roll = lc($6);
			if( $this_roll =~ /clc/ && $ENV{'QA_DISTRO'} eq "" ){
				print "\n";
				print "IP $qa_ip [Distro $qa_distro, Version $qa_distro_ver, ARCH $qa_arch] is built from $qa_source as Eucalyptus-$qa_roll\n";
				$ENV{'QA_DISTRO'} = $qa_distro;
				$ENV{'QA_DISTRO_VER'} = $qa_distro_ver;
				$ENV{'QA_ARCH'} = $qa_arch;
				$ENV{'QA_SOURCE'} = $qa_source;
				$ENV{'QA_ROLL'} = $qa_roll;
			}elsif( $this_roll =~ /nc/ ){
				$qa_distro = lc($qa_distro);
				if( $qa_distro eq "vmware" ){
					$ENV{'IS_VMWARE'} = 1;
				};
			};

		}elsif( $line =~ /^MEMO/ ){
			$is_memo = 1;
		}elsif( $line =~ /^END_MEMO/ ){
			$is_memo = 0;
		};
	};	

	close(INPUT);

	$ENV{'QA_MEMO'} = $memo;

	return 0;
};




