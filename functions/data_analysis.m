% ================================================================================
% File Name : data_analysis.m
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : 分析探测器扫描数据
% ================================================================================

function data_analysis(raws, calis)
    % 保存文件的目录
    time = datestr(datetime, 'HH-MM-ss');
    folder = strcat(pwd, '\resources\IMgs\', 2023-12-22, '\');

    % 
    save(strcat(pwd, '\resources\IMgs\2023-12-22\', 'raws_cali.mat'), 'raws', 'calis');

    save_tiff(raws, calis, folder);

end


function save_tiff(raws, calis)
    for i=1:5
        raw_data_to_tiff(raws(:, :, i), strcat(pwd, '\resources\IMgs\2023-12-22\', 'raw_', num2str(i), '.tiff'));
        raw_data_to_tiff(calis(:, :, i), strcat(pwd, '\resources\IMgs\2023-12-22\', 'cali_', num2str(i), '.tiff'));
    end
end