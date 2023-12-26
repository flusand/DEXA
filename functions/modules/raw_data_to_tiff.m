% ================================================================================
% File Name : raw_data_to_tiff.m
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : 原始数据保存成TIFF格式方便imageJ分析
% ================================================================================

function raw_data_to_tiff(rawData, filePath)
    % 每个像素的数值位数，single为单精度浮点型，对于32为系统为32
    imgSingle = single(rawData); 
    tiff = Tiff(filePath, 'w');
    
    % 图像数据的长、宽
    tags.ImageLength = size(imgSingle,1); 
    tags.ImageWidth = size(imgSingle,2);  
    
    % 图像数据的颜色空间
    tags.Photometric = 1;

    % 每个像素的数值位数，single为单精度浮点型，对于32为系统为32
    tags.BitsPerSample = 32;
    
    tags.SamplesPerPixel = 1;
    %  tagstruct.RowsPerStrip = 16;
    tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

    tags.Software = 'MATLAB';

    tags.SampleFormat = 3;
    tiff.setTag(tags)
    tiff.write(imgSingle);
    tiff.close
end