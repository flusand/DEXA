% ================================================================================
% File Name : image_process.m
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  :  
% ================================================================================
function  [raws, imgs, IMgs] = image_stitch(file_spine, lpn, overlap)
    [raws, imgs] = parse_pacp(file_spine, lpn);
    
    % 图像重叠区域拼接
    temp = imgs;
    W = repmat(transpose([linspace(1, 0, overlap) linspace(0, 1, overlap)]), [1, size(imgs, 2), 5]);
    IMgs = temp(1:lpn-overlap, 1:end, 1:end);
    for i= lpn+1:lpn:size(temp, 1)
        fusion = temp(i-overlap:i+overlap-1, 1:end, 1:end) .* W;
        temp(i:i+overlap-1, 1:end, 1:end) = fusion(1:overlap, 1:end, 1:end) + fusion(overlap+1:end, 1:end, 1:end);
        IMgs = cat(1, IMgs, temp(i:i + lpn-overlap, 1:end, 1:end));
    end
end
