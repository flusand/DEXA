% ================================================================================
% File Name : bmd_parameter.m
% Version   : Version 1.0
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : 骨密度计算需要的参数
% ================================================================================

function  bmds = bone_mineral_density(raws, S, E)
    air_avg = repmat(mean(raws(1:64, 100:200, 1:end), 2) + 1, [size(raws, 1)/64, size(raws, 2), 1]);
    pixel_pc_prj = -log((raws + 1) ./ air_avg);
    
    % 保存每个像素的骨密度值
    bmds = zeros(size(raws, 1), size(raws, 2));
    for i=1:size(raws, 1)
        pixel = mod(i, 64);
        if pixel == 0
            pixel = 64;
        end
        L = pixel_pc_prj(i, 1:end, 1)';
        H = pixel_pc_prj(i, 1:end, 2)';
        LH = [L'; H'];
        PAL_PMMA = S(:, :, pixel) * LH;
        bmds(i,:) = PAL_PMMA(1, 1:end) + mean(E(1, :, pixel));
    end
end