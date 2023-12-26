% ================================================================================
% File Name : image_process.m
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  :  
% ================================================================================

function  IMgs = image_stitch(fileName, lpn)
    [raws, calis] = parse_pacp(fileName, lpn);
    save(strcat(pwd, '\resources\IMgs\2023-12-22\', 'raws_cali.mat'), 'raws', 'calis');
end