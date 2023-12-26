% ================================================================================
% File Name : image_process.m
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : Image Processing : spinal、hipbone、 arm、 leg、 foot、 body、 
%                                phantom_al、  phantom_spinal、 phantom_al_spinal 
% ================================================================================
function img = image_process(I, methon)
    eval(['img = ', methon, '(I);']);
end



function  img = raw(I)
    m = min(I, [], "all");
    M = max(I, [], "all");
    normalization = (I - m)./(M - m);
    img = normalization;
end




function  img = relur(I)
    Iblur = imgaussfilt(I);
    median = medfilt2(Iblur, [3 3], 'symmetric');
    m = min(median, [], "all");
    M = max(median, [], "all");
    normalization = (median - m)./(M - m);
    img = imadjust(normalization, [0 1], [0 1], 10);
end


function  img = spine(I)
   % 降噪处理
   
    median = medfilt2(I, [3 3], 'symmetric');
    
    Iblur = imgaussfilt(median);
    

    % 数据归一化
    m = min(Iblur, [], "all");
    M = max(Iblur, [], "all");
    normalization = (Iblur - m)./(M - m);

    % 幂指数变换
    % gammacorr = .7;
    % power = normalization.^gammacorr;、

    % 对数变换
    img = -log(normalization + 0.001);
    m = min(img, [], "all");
    M = max(img, [], "all");
    img = (img - m)./(M - m);

%     img = imadjust(normalization, [0 1], [0 1], 1.3);


    % 降噪处理
    Iblur = imgaussfilt(img);
    mask = double(imbinarize(Iblur,graythresh(Iblur))); % 对图像直接进行二值化
    target = double(mask.*Iblur);
    outline = edge(target, "canny");
    contours = bwboundaries(outline);
end

