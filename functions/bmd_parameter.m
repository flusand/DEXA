% ================================================================================
% File Name : bmd_parameter.m
% Version   : Version 1.0
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : 骨密度计算需要的参数
% ================================================================================

function  [S, E] = bmd_parameter(fileName, lpn)
    [raws, ~] = parse_pacp(fileName, lpn);
    
    % 寻找铝台阶
    segment = find_step(raws);
    
    % 寻找铝台阶边缘
    index = step_edge(segment);

    % 每个台阶的数据
    pixel_pc_prj = get_step_pc(segment, index);
    
    % 根据AL、PMMA实际厚度进行组合
    AL_PMMA = get_thick_compose();
    % 参数计算
    [S, E] = parameter_calcul(pixel_pc_prj, AL_PMMA);
end


% 找到探测器完整扫描铝阶梯体模数据
function  segment = find_step(raws)
    means = zeros(size(raws, 1)/64, 1); % 寻找规则根据每次扫描光子计数最小值
    for i=1:size(raws, 1)/64
        means(i, 1) = mean(raws((i-1)*64+1:i*64, 1:end, 1:2), 'all');
    end
    [~, index] = min(means);
    segment = raws((index-1)*64+1:index*64, 1:end, 1:end);
end


% 寻找铝台阶的最厚处的边缘
function  index = step_edge(segment)
    % 直接使用光子计数成像效果较差，使用空气校准之后的数据成像较好
    air_avg = repmat(mean(segment(1:end, 100:200, 1:end) + 1, 2), [1, size(segment, 2), 1]);
    cali = (segment+1) ./ air_avg; 
    gauss_img = imgaussfilt(cali(:, :, 1).^0.1);

    % 找出梯度较大的位置
    edges = int16(edge(gauss_img, "canny"));
    possible_edge = sum(edges, 1);
    possible_edge(possible_edge < 50) = 0;
    [~, col] = find(possible_edge ~= 0);
    index = col(1);
end


% 每个台阶扫描的数据
function  pixel_pc_prj = get_step_pc(segment, index)
    air_avg = repmat(mean(segment(1:end, 100:200, 1:end) + 1, 2), [1, size(segment, 2), 1]);
    pc_prj = -log((segment + 1) ./ air_avg);
    
    % 64像素对36组AL、PMMA厚度组合的高低能数据 
    pixel_pc_prj = zeros(2, 36, 64);
    for i=1:36
        index = index + 12;
        for pixel=1:64
            pixel_pc_prj(1, i, pixel) = mean(pc_prj(pixel, index+5:index+8, 1));
            pixel_pc_prj(2, i, pixel) = mean(pc_prj(pixel, index+5:index+8, 2));
        end
    end
    % pixel_one = pixel_pc_prj(1:end, 1:end, 1);
end


% 每个台阶扫描的数据
function  AL_PMMA = get_thick_compose()
    % AL、PMMA台阶每个台阶实际厚度(毫米)
    AL = [0.0001, 2, 4, 5, 6, 7];
    PMMA = [80, 85, 90, 95, 100, 105];
    [pmma, al] = meshgrid(PMMA, AL);
    
    al = reshape(al, 1, [])';
    pmma = reshape(pmma, 1, [])';

    % 形成不同厚度组合
    AL_PMMA=[al pmma]; 
    AL_PMMA = flipud(AL_PMMA);
end


% 参数计算
function [S, E] = parameter_calcul(pixel_pc_prj, AL_PMMA)
    % 预先构建参数
    S = zeros(2, 2, 64);
    E = zeros(2, 36, 64);

    for pixel=1:64
        % 使用最小二乘法求台阶求高、低能数据与实际厚度对应关系
        L = pixel_pc_prj(1, 1:end, pixel)';
        H = pixel_pc_prj(2, 1:end, pixel)';
        M1=regress(L,AL_PMMA); 
        M2=regress(H,AL_PMMA);
        M=[M1';M2']; % M 的列数代表基材料的个数，行数代表能区数。


        % 台阶厚度组合中位值高低能数据方差
        R = cov([L(size(L,1)/2); H(size(H,1)/2)]);
        S(:, :, pixel) = inv(M'/R*M)*M'/R;
        
        % 高低能数据预测实际厚度并计算误差
        LH = [L'; H']; 
        PAL_PMMA = S(:, :, pixel) * LH;
        E(1:end, 1:end, pixel) = AL_PMMA' - PAL_PMMA;
    end
end

