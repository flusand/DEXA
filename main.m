% ================================================================================
% File Name : main.m
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : Dual Energy X-ray Imaging Main Program
% ================================================================================

clc;
clear;
close all;

fileName = '20231214-0211-80kV-0.2mA-100FPS-2.33cmX-5cmpsY-8cm-26.6℃-Spine.pcap';
lpn = 16 *2 * 2; overlap = 18;  % 像素重叠个数 

[width, height, channels, PC]= pixel_photon_count(fileName);

% 解析pcap数据文件得到需要的图像数据
decPackets = parse_pacp(fileName); % 解析pcap文件
[PC, section] = merge_chip_data(decPackets, lpn); % 解析pcap文件
[raws, imgs, IMgs] = image_stitching(PC, section, lpn, overlap);

for i=1:5
    raw = raws(:, :, i);
    img = imgs(:, :, i);    
    IMg = IMgs(:, :, i); 
  
    eval(['raw', num2str(i), '=', 'raw', ';']);
    eval(['img', num2str(i), '=', 'img', ';']);
    eval(['IMg', num2str(i), '=', 'IMg', ';']);
end




