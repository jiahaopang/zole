% Test the DispNet model obtained with the "Zoom and Learn" (ZOLE) method

close all
clear
clc
addpath ../../matlab
addpath ../../tools

%% some preparations
id = 4; % may try our 1 to 4
net_file = './DispNetC.prototxt';
weight_file = './zole.caffemodel';
height = 768;
width = 768;
imgL = imresize(imread(['./img/', num2str(id, '%02d'), '_L.png']), [height width]);
imgR = imresize(imread(['./img/', num2str(id, '%02d'), '_R.png']), [height width]);
gpu_device = 0;

%% load the model
caffe.reset_all();
if gpu_device >= 0
    caffe.set_mode_gpu();
    caffe.set_device(gpu_device);
else
    caffe.set_mode_cpu();
end
net = caffe.Net(net_file, weight_file, 'test');

%% test the model
net.blobs('img0').set_data(permute(imresize(imgL, [height width], 'bilinear'), [2 1 3]));
net.blobs('img1').set_data(permute(imresize(imgR, [height width], 'bilinear'), [2 1 3]));
net.forward_prefilled();
result = -net.blobs('predict_flow1').get_data()';

%% display the result
result = uint8((result - min(result(:))) / (max(result(:)) - min(result(:))) * 255);
figure; imshow([imresize(imgL, 0.5) repmat(result, [1 1 3])]);
