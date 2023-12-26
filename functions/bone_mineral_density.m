% ================================================================================
% File Name : bmd_parameter.m
% Version   : Version 1.0
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : 骨密度计算需要的参数
% ================================================================================

function  [s, m] = bone_mineral_density(raws, S, E)
    air_avg = repmat(mean(raws(1:64, 100:200, 1:end), 2) + 1, [size(raws, 1)/64, size(raws, 2), 1]);
    pc_prj = -log((raws + 1) ./ air_avg);
    


    
    for i=64:64:size(raws, 1)
        
    end
    s = 0;
    m = 0;
end