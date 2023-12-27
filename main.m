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

qaFile = '20231214-0210-80kV-0.2mA-100FPS-2.33cmX-5cmpsY-8cm-26.4℃-QA.pcap';
spineFile = '20231214-0211-80kV-0.2mA-100FPS-2.33cmX-5cmpsY-8cm-26.6℃-Spine.pcap';
lpn = 16 *2 * 2;
overlap = 18;

% 骨密度计算验证
[S, E] = bmd_parameter(qaFile, lpn);
[raws, imgs, IMgs] = image_stitch(spineFile, lpn, overlap);

% 计算没像素点的骨密度值
bmds = bone_mineral_density(raws, S, E);
data_analysis(bmds);




