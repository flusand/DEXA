% ================================================================================
% File Name : image_stitching.m
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : image stitching 
% ================================================================================

function [raws, imgs, IMgs] = image_stitching(PC, section, lpn, overlap)

    % 空气校准
    air_mean = mean(PC(200:300, 1:end, 1:end), 1);
    air_mean = repmat(air_mean, [size(PC, 1), 1, 1]);
    pc = (PC+1) ./air_mean;
   
    % 创建容器
    maxFrames = max(section(:, 4));
    totalScan = size(section, 1);
    raws = zeros(lpn*totalScan, maxFrames, 5); 
    imgs = zeros(lpn*totalScan, maxFrames, 5);
    for i= 1:totalScan
        raws_slices = permute(PC(section(i, 2):section(i, 3), 1:end, 1:end), [2 1 3]);
        imgs_slices = permute(pc(section(i, 2):section(i, 3), 1:end, 1:end), [2 1 3]);
        if mod(i,2) == 0
            raws((i-1)*lpn + 1:i*lpn, 1:section(i, 4), 1:end) = circshift(flip(raws_slices, 2), 2, 2);
            imgs((i-1)*lpn + 1:i*lpn, 1:section(i, 4), 1:end) = circshift(flip(imgs_slices, 2), 2, 2);
        else
            raws((i-1)*lpn + 1:i*lpn, 1:section(i, 4), 1:end) = circshift(raws_slices, 0, 2);
            imgs((i-1)*lpn + 1:i*lpn, 1:section(i, 4), 1:end) = circshift(imgs_slices, 0, 2);
        end
    end
    
    % 图像重叠区域拼接
    temp = imgs;
    W = repmat(transpose([linspace(1, 0, overlap) linspace(0, 1, overlap)]), [1, max(section(:, 4)), 5]);
    IMgs = temp(1:lpn-overlap, 1:end, 1:end);
    for i= lpn+1:lpn:size(temp, 1)
        fusion = temp(i-overlap:i+overlap-1, 1:end, 1:end) .* W;
        temp(i:i+overlap-1, 1:end, 1:end) = fusion(1:overlap, 1:end, 1:end) + fusion(overlap+1:end, 1:end, 1:end);
        IMgs = cat(1, IMgs, temp(i:i + lpn-overlap, 1:end, 1:end));
    end
end