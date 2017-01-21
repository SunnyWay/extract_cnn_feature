#!/usr/bin/env sh

# caffe tools path
# CAFFE_TOOLS="CAFFE_HOME/build/tools"

# Directory contains input image 
IMAGE_DIR="image"

# Where to save the extracted features
TARGET_DIR="`pwd`"
IMAGE_LIST="$TARGET_DIR/image_list.txt"
FEATURE_LMDB="$TARGET_DIR/output_lmdb"
FEATURE_NPY="$TARGET_DIR/output.npy"

# The layer name where the features from.
LAYER_NAME="pool5/7x7_s1"     # GoogLeNet                  1024
 
# Resize images to the specific size for extracting.
RESIZE_HEIGHT=224
RESIZE_WIDTH=224

# The pre-trained cnn model used to extract features.
CNN_MODEL="model/bvlc_googlenet.caffemodel"

# The prototxt file definding the CNN_MODEL
CNN_PROTOTXT="model/bvlc_googlenet.prototxt"

# The line number of the CNN_PROTOTXT file, in that line prototxt define
# the image lmdb source for the data layer.
SOURCE_LINE=13

# The line number of the CNN_PROTOTXT file, tells the batch size.
BATCH_LINE=14


##########################################################################
# Now let's do it !
##########################################################################

# get the path where this script save
script_dir=$(cd "$(dirname "$0")";pwd)

# make tmp dir as work space
TMP_DIR=`date +"%s"`
TMP_DIR="$TARGET_DIR/$TMP_DIR"
mkdir -p $TMP_DIR

# generate image list
find "$IMAGE_DIR" ! -type d | sed "s/$/ 0/" > "$IMAGE_LIST"

# storage images into lmdb
echo "Storage images into lmdb..."
$CAFFE_TOOLS/convert_imageset \
	--resize_height=$RESIZE_HEIGHT \
	--resize_width=$RESIZE_WIDTH \
	"" \
	$IMAGE_LIST \
	"$TMP_DIR/im_lmdb"

# modify cnn prototxt, set image lmdb source for data layer
echo "Modify prototxt..."
sed -i $SOURCE_LINE"s|\".*\"|\"""$TMP_DIR/im_lmdb""\"|" $CNN_PROTOTXT

# compute the number of batches to extract.
image_num=`cat $IMAGE_LIST | wc -l`
batch_size=`awk 'NR=='$BATCH_LINE' {print $2}' $CNN_PROTOTXT`
batch_num=$(( ($image_num+$batch_size-1)/$batch_size ))
echo "images: $image_num; batch_size: $batch_size; batches: $batch_num"

echo "Extract image feature to $FEATURE_LMDB"
if [ -d "$FEATURE_LMDB" ]; then
	read -p "$FEATURE_LMDB already exists. Remove it or not(y/n)?" yn
	if [ $yn = 'y' -o $yn = 'Y' ]; then
		rm -r "$FEATURE_LMDB"
	fi
fi
$CAFFE_TOOLS/extract_features.bin \
	$CNN_MODEL \
	$CNN_PROTOTXT \
	$LAYER_NAME \
	"$FEATURE_LMDB" \
	$batch_num \
	lmdb \
	GPU

# remove the tmp dir
rm -r $TMP_DIR

# echo "Chop the redundant features at the tail..."
echo "Cut the redundant tail..."
python "$script_dir/cut_lmdb.py" "$FEATURE_LMDB" $image_num

echo "Convert features from lmdb to npy..."
echo $FEATURE_LMDB
echo ${FEATURE_LMDB}.npy
python "$script_dir/lmdb2npy.py" "$FEATURE_LMDB" "${FEATURE_NPY}"
