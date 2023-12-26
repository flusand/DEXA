% ================================================================================
% File Name : pixel_photon_count.m
% Version   : Version 1.0
% Author    : 刘志
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : 从PCAP文件根据骨密度数据协议，将数据转换成图像格式
% =================================================================================

function  [width, height, channels, PC] = pixel_photon_count(fileName)
    
    decPackets = parse_pacp(fileName);
    
    [PC, section] = merge_chip_data(decPackets);  % 解析pcap文件
    
    [raws, imgs, IMgs] = image_stitching(PC, section, lpn, overlap); %   
    
end