#!/bin/bash

PREFIX="euca"
export PYTHONPATH=./boto:./euca2ools-main
export PATH=./euca2ools-main/bin:$PATH
echo "Euca2ools version in use:"
euca-version

KERNEL=$1
RAMDISK=$2
IMAGE=$3

echo ""
echo "Step 1."
echo ""
echo "Bundle Kernel $KERNEL"
echo ""

DIR=`mktemp -d -p .`

echo "COMMAND:"
echo "$PREFIX-bundle-image --cert ${EC2_CERT} --privatekey ${EC2_PRIVATE_KEY} --ec2cert ${EUCALYPTUS_CERT} --user 000100739354 -i $KERNEL -d $DIR --kernel true"
echo ""
echo ""

BUKKIT=`echo $DIR | sed "s/\.\///" | sed "s/\.//" | tr '[A-Z]' '[a-z]'`
(sleep 1; echo) | $PREFIX-bundle-image --cert ${EC2_CERT} --privatekey ${EC2_PRIVATE_KEY} --ec2cert ${EUCALYPTUS_CERT} --user 000100739354 -i $KERNEL -d $DIR --kernel true
MANIFEST=`echo $DIR/*.manifest.xml`

echo ""
echo ""
echo "COMMAND:"
echo "$PREFIX-upload-bundle -a ${EC2_ACCESS_KEY} -s ${EC2_SECRET_KEY} --url ${S3_URL} --ec2cert ${EUCALYPTUS_CERT} -b $BUKKIT -m $MANIFEST"
echo ""
echo ""

(sleep 1; echo y) | $PREFIX-upload-bundle -a ${EC2_ACCESS_KEY} -s ${EC2_SECRET_KEY} --url ${S3_URL} --ec2cert ${EUCALYPTUS_CERT} -b $BUKKIT -m $MANIFEST
MANIFEST=`ls $DIR/*.manifest.xml | awk 'BEGIN {FS="/"}; {print $3}'`

echo $PREFIX-register $BUKKIT/$MANIFEST
EKI=`$PREFIX-register $BUKKIT/$MANIFEST | awk '{print $2}'`
rm -rf $DIR

echo ""
echo ""
echo ""




echo "Step 2."
echo ""
echo "Bundle Ramdisk $RAMDISK"

DIR=`mktemp -d -p .`

echo ""
echo "COMMAND:"
echo "$PREFIX-bundle-image --cert ${EC2_CERT} --privatekey ${EC2_PRIVATE_KEY} --ec2cert ${EUCALYPTUS_CERT} --user 000100739354 -i $RAMDISK -d  $DIR --ramdisk true"
echo ""
echo ""

BUKKIT=`echo $DIR | sed "s/\.\///" | sed "s/\.//" | tr '[A-Z]' '[a-z]'`
(sleep 1; echo) | $PREFIX-bundle-image --cert ${EC2_CERT} --privatekey ${EC2_PRIVATE_KEY} --ec2cert ${EUCALYPTUS_CERT} --user 000100739354 -i $RAMDISK -d $DIR --ramdisk true
MANIFEST=`echo $DIR/*.manifest.xml`

echo ""
echo ""
echo "COMMAND:"
echo "$PREFIX-upload-bundle -a ${EC2_ACCESS_KEY} -s ${EC2_SECRET_KEY} --url ${S3_URL} --ec2cert ${EUCALYPTUS_CERT} -b $BUKKIT -m $MANIFEST"
echo ""
echo ""

(sleep 1; echo y) | $PREFIX-upload-bundle -a ${EC2_ACCESS_KEY} -s ${EC2_SECRET_KEY} --url ${S3_URL} --ec2cert ${EUCALYPTUS_CERT} -b $BUKKIT -m $MANIFEST
MANIFEST=`ls $DIR/*.manifest.xml | awk 'BEGIN {FS="/"}; {print $3}'`
echo $PREFIX-register $BUKKIT/$MANIFEST
ERI=`$PREFIX-register $BUKKIT/$MANIFEST | awk '{print $2}'`
rm -rf $DIR
echo ""
echo ""
echo ""




echo "Step 3."
echo ""
echo "Bundle Image $IMAGE"

DIR=`mktemp -d -p .`

echo ""
echo "COMMAND:"
echo "$PREFIX-bundle-image --cert ${EC2_CERT} --privatekey ${EC2_PRIVATE_KEY} --ec2cert ${EUCALYPTUS_CERT} --user 000100739354 -i $IMAGE -d $DIR --kernel $EKI --ramdisk $ERI" 
echo ""
echo ""

BUKKIT=`echo $DIR | sed "s/\.\///" | sed "s/\.//" | tr '[A-Z]' '[a-z]'`
(sleep 1; echo) | $PREFIX-bundle-image --cert ${EC2_CERT} --privatekey ${EC2_PRIVATE_KEY} --ec2cert ${EUCALYPTUS_CERT} --user 000100739354 -i $IMAGE -d $DIR --kernel $EKI --ramdisk $ERI
MANIFEST=`echo $DIR/*.manifest.xml`

echo ""
echo ""
echo "COMMAND:"
echo "$PREFIX-upload-bundle -a ${EC2_ACCESS_KEY} -s ${EC2_SECRET_KEY} --url ${S3_URL} --ec2cert ${EUCALYPTUS_CERT} -b $BUKKIT -m $MANIFEST"
echo ""
echo ""


(sleep 1; echo y) | $PREFIX-upload-bundle -a ${EC2_ACCESS_KEY} -s ${EC2_SECRET_KEY} --url ${S3_URL} --ec2cert ${EUCALYPTUS_CERT} -b $BUKKIT -m $MANIFEST
MANIFEST=`ls $DIR/*.manifest.xml | awk 'BEGIN {FS="/"}; {print $3}'`
echo $MANIFEST
echo $PREFIX-register $BUKKIT/$MANIFEST
EMI=`$PREFIX-register $BUKKIT/$MANIFEST | awk '{print $2}'`
rm -rf $DIR
echo ""
echo ""
echo $EKI $ERI $EMI
exit 0
