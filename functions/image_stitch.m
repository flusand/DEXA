% ================================================================================
% File Name : image_process.m
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  :  
% ================================================================================
function  [raws, cali, IMgs] = image_stitch(file_spine, lpn, overlap)
    [raws, cali] = parse_pacp(file_spine, lpn);
    
    % 图像重叠区域拼接
    temp = cali;
    W = repmat(transpose([linspace(1, 0, overlap) linspace(0, 1, overlap)]), [1, size(cali, 2), 5]);
    IMgs = temp(1:lpn-overlap, 1:end, 1:end);
    for i= lpn+1:lpn:size(temp, 1)
        fusion = temp(i-overlap:i+overlap-1, 1:end, 1:end) .* W;
        temp(i:i+overlap-1, 1:end, 1:end) = fusion(1:overlap, 1:end, 1:end) + fusion(overlap+1:end, 1:end, 1:end);
        IMgs = cat(1, IMgs, temp(i:i + lpn-overlap, 1:end, 1:end));
    end

    % 将数据保存到TIFF 方便使用ImageJ分析
    width = size(raws, 1);
    height = size(raws, 2);
    tags = set_tags(width, height); 
    save_image(raws, tags, 'raw');
    save_image(cali, tags, 'cali');
    save_image(IMgs, tags, 'IMgs');
end

function save_image(data, tags, type)
    for i = 1:size(data, 3)
        filePath = strcat('resources\IMgs\', type, '_', num2str(i), '.tif');
        save_tiff(data(:, :, i), tags, filePath);
    end
end

function save_tiff(data, tags, filePath)
    imgs = single(data); % 将需要保存的数据转换为Single为32位单精度浮点型 
    tiff = Tiff(filePath, 'w'); % 创建tiff对象 
    tiff.setTag(tags) % tiff 设置tags
    tiff.write(imgs); 
    tiff.close
end

function tags = set_tags(width, height)
     % 图像数据的长、宽
    tags.ImageLength = width; 
    tags.ImageWidth = height;  
    
    % 图像数据的颜色空间
    tags.Photometric = 1;

    % 每个像素的数值位数，single为单精度浮点型，对于32为系统为32
    tags.BitsPerSample = 32;
    
    tags.SamplesPerPixel = 1;
    %  tagstruct.RowsPerStrip = 16;
    tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

    tags.Software = 'MATLAB';

    tags.SampleFormat = Tiff.SampleFormat.IEEEFP;
    
end
