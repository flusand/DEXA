

bmd = [1.682, 1.562, 1.442, 1.322, 1.202, 1.082, 0.962, 0.842, 0.722, 0.602, 0.482, 0.362, 0.242, 0.122];

T = (bmd - 1.016)/0.12;
T(2,:)=bmd(1,:);


%     img = image_process(imgs(:, :, i), 'spine');
% 
%     figure(i);
%     imshow(img(1:end, 1:2:end), [0 0.75]);
%     imwrite(img(1:end, 1:2:end), '1.png')

%     avg = mean(raw(1:64, 200:300), 2);
%     a = repmat(avg, [21, size(raw, 2)]);b       
%     c = raw ./ a;
% 
%     d = img - c;


function t = saveAsTiffSingle(X, filepath)
% https://www.cnblogs.com/lionyiss/p/9552979.html
    im = single(X);
    t = Tiff(filepath,'w');
    tagstruct.ImageLength = size(im,1); 
    tagstruct.ImageWidth = size(im,2);  

    tagstruct.Photometric = 1;

    % 每个像素的数值位数，single为单精度浮点型，对于32为系统为32
    tagstruct.BitsPerSample = 32;

    tagstruct.SamplesPerPixel = 1;
%     tagstruct.RowsPerStrip = 16;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

    tagstruct.Software = 'MATLAB';

    tagstruct.SampleFormat = 3;
    t.setTag(tagstruct)

    t.write(im);

    t.close
end




%   img = single(raw);
%     tiff = Tiff("1.tiff",'w');
%     tags.ImageLength = size(img,1); 
%     tags.ImageWidth = size(img,2);  
%     tags.Photometric = 1;
% 
%     % 每个像素的数值位数，single为单精度浮点型，对于32为系统为32
%     tags.BitsPerSample = 32;
% 
%     tags.SamplesPerPixel = 1;
% %     tagstruct.RowsPerStrip = 16;
%     tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tags.Software = 'MATLAB';
%     tags.SampleFormat = 3;
%     tiff.setTag(tags)
% 
%     tiff.write(img);
%     tiff.close
