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

qaFile = '20231227-020101-80kV-0.2mA-100FPS-2.33cmX-5cmpsY-5cm-22.5℃-QA.pcap';
spineFile = '20231227-020102-80kV-0.2mA-100FPS-2.33cmX-5cmpsY-5cm-22.5℃-QA.pcap';
lpn = 16 *2 * 2;
overlap = 18;

% 骨密度计算验证
[S, E] = bmd_parameter(qaFile, lpn);
[raws, imgs, IMgs] = image_stitch(qaFile, lpn, overlap);

for i=1:5
    raw = raws(:, :, i);
    img = imgs(:, :, i);    
    IMg = IMgs(:, :, i); 
    eval(['raw', num2str(i), '=', 'raw', ';']);
    eval(['img', num2str(i), '=', 'img', ';']);
    eval(['IMg', num2str(i), '=', 'IMg', ';']);
end

% 计算没像素点的骨密度值
bmds = bone_mineral_density(raws, S, E);
data_analysis(bmds);



% x = 1:64;
% pixel1 = img2(65:128, :);
% avg1 = mean(pixel1, 2);
% stds1 = std(pixel1, 0, 2);
% 
% pixel2 = img2(129:192, :);
% avg2 = mean(pixel2, 2);
% stds2 = std(pixel2, 0, 2);
% 
% pixel3 = img3(193:256, :);
% avg3 = mean(pixel3, 2);
% stds3 = std(pixel3, 0, 2);
% 
% plot(x, avg1','r-',x, avg2, 'b--', x, avg3,'g-.');
% plot(x, stds1','r-',x, stds2, 'b--', x, stds3,'g-.');
