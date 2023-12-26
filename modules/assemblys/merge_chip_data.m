% ================================================================================
% File Name : merge_chip_data.m
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : Merge data from multiple chips
% ================================================================================

function [PC, section] = merge_chip_data(decPackets)
    totalFrames = decPackets(end, 162); % 下位机发出总的帧数（不包含停止命令）
    totalPackets = size(decPackets, 1); % 上位机接收到的数据总包数
    section = zeros(100, 5); % 记录扫描方向改变时所在帧开始位置
    lpn = 16 *2 * 2;  % line pixels number

    PC = zeros(totalFrames, lpn, 5);
    for i = 1:totalPackets
        chip = decPackets(i, 161);
        frame = decPackets(i, 162);
        count = decPackets(i, 163);
        
        % 记录每次横向扫描起始帧号以及横向扫描次数
        if 1 == i || (decPackets(i, end) ~= decPackets(i-1, end))
            if decPackets(i, end) ~= 2
                section(count, 1) = count;
                section(count, 2) = frame;
                section(count, 5) = i;
                section(end, 1) = count;
            else
                section(section(end, 1) +1, 2) = frame;
                section(section(end, 1) +1, 5) = i;
            end
        end
        
        % 实际接受扫描数据按照图像格式进行存放并且区分五能区域数据
        for j =1:5
            PC(frame, (chip-1)*32 + 1:chip*32, j) = decPackets(i, j:5:160);
        end
    end
    section(end, 2) = totalFrames;
    section(end, 5) = totalPackets;
    
    % 统计横向扫描数据：横向扫描次数、每次横向扫描起始帧、结束帧、总帧数
    for i = 1:section(end, 1)
        section(i, 3) = section(i + 1, 2) - 1;
        section(i, 4) = section(i + 1, 2) - section(i, 2);
    end
    section(section(end, 1)+1:end, :) = [];
end
