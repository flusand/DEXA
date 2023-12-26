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

file_qa = '20231214-0210-80kV-0.2mA-100FPS-2.33cmX-5cmpsY-8cm-26.4℃-QA.pcap';
file_spine = '20231214-0211-80kV-0.2mA-100FPS-2.33cmX-5cmpsY-8cm-26.6℃-Spine.pcap';
lpn = 16 *2 * 2;
overlap = 18;

% 骨密度计算验证
[S, E] = bmd_parameter(file_qa, lpn);
[raws, imgs, IMgs] = image_stitch(file_spine, lpn, overlap);

% 计算没像素点的骨密度值
bmds = bone_mineral_density(raws, S, E);
data_analysis(bmds);


 

rawThr = {[0 500], [0 500], [0 500], [0 500], [0 500]};
imgThr = {[0 0.2], [0 0.2], [0 0.2], [0 0.2], [0 0.2]};
IMgThr = {[0 0.2], [0 0.2], [0 0.2], [0 0.2], [0 0.2]};

for i=1:5
    raw = raws(:, :, i);
    img = imgs(:, :, i);    
    IMg = IMgs(:, :, i); 
    eval(['raw', num2str(i), '=', 'raw', ';']);
    eval(['img', num2str(i), '=', 'img', ';']);
    eval(['IMg', num2str(i), '=', 'IMg', ';']);
end

% figure(i);
% imshow(raw);
% figure(2);
% imshow(img);
% figure(3);
% imshow(IMg);




