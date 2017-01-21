# Introduction #

This repo provides some scripts to extract CNN feature and it is based on **convert_imageset** and **extract_feature.bin** from [caffe](http://caffe.berkeleyvision.org/) directly. The extracted feautres will be cast into numpy array.

## Dependencies ##

- [caffe](http://caffe.berkeleyvision.org/) and its python wrapper.
- python 2.7 and [numpy](http://www.numpy.org/) package.

## Usage ##

Download the [GoogLeNet](http://dl.caffe.berkeleyvision.org/bvlc_googlenet.caffemodel) and save it in the **model** directory then run **extract_features.sh**, you will abtain the 1024d features of the images in the directory **image**.


If you want to extract features of other model or other layers, just modify the first part of **extract_features.sh**. The detail explaination is as following.

- `CAFFE_TOOLS` defines where **convert_imageset** and **extract_feature.bin** are. Usually it is `CAFFE_HOME/build/tools`. It is useful when you work with several versions of caffe.

- `IMAGE_DIR` is the directory which contains the input images. The script will recursively find regular files in it. You need to make sure all the regular files are images.

- `LAYER_NAME` is the name of the CNN layer which produces target feature. You can find it in model prototxt. You may need to care about the in-place layer if you want to extract the feature before ReLU or dropout. Some common layer names are listed below.

- `RESIZE_HEIGHT` and `RESIZE_WIDTH`. Before extrating, image will be resized to fit the CNN model input size. When you extract the feature of a convolutional layer or a pooling layer, you can delete the full conected layer in the model prototxt, then the input image size can be abitrary.

- `CNN_MODEL` and `CNN_PROTOTXT` specify the trained caffe model parameters and model prototxt respectively. Some common model prototxt is in **model** directory.

- `SOURCE_LINE` and `BATCH_LINE`, tow weird arguments :smirk:. They are the line numbers of prototxt file. In the `SOURCE_LINE` prototxt defines the input directory and in the `BATCH_LINE` prototxt defines the batchi\_size.

After you setting up, you can run the script and wait for features :smile:.

## Common Model and Layer ##

Layer Name       | Model        | #Dimension | Notes
---|---|---|---
conv5\_3          | VGG16        | 512x14x14  |
fc7              | VGG16, VGG19 | 4096       | After ReLU and Dropout
pool5/7x7\_s1     | GoogLeNet    | 1024       | 
prob             | VGG16, VGG19 | 1000       | 
fc8              | VGG16, VGG19 | 1000       | Without Softmax
loss3/classifier | GoogLeNet    | 1000       | without Softmax
