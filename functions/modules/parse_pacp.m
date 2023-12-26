% ================================================================================
% File Name : parse_pacp_file.m
% Version   : Version 1.0
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : Parsing Wireshark packet capture files
% ================================================================================

function  [raws, imgs] = parse_pacp(fileName, lpn)
    
    % 检查该文件是否解析
    matFile=strcat(pwd, '\resources\FILES\MAT\', replace(fileName, 'pcap', 'mat'));
    if exist(matFile,'file')
        load(matFile); % 文件加载
        return;
    end

    % 根据数据协议解析PCAP文件
    [hexPackets, packets] =  parse_file (fileName);
  
    % 将十六进制数据转化需要的十进制
    decPackets = hex_to_dec (hexPackets, packets);

    % 将两颗芯片数据合并成一个完整的帧数据
    [PC, section] = frame_merge (decPackets, lpn);
   
    % 将解析出来的数据转换成图像格式
    [raws, imgs] = multi_channel_image (PC, section, lpn);

    % 将读取的pcap 保存对应的Mat文件
    save(matFile, 'raws', 'imgs');
end


% 读取PCAP文件
function  [hexPackets, packets] =  parse_file (fileName)
     % 根据数据协议解析PCAP文件
    pcapReaderObj = pcapReader(strcat(pwd, '\resources\FILES\', fileName));
    decodedPackets = readAll(pcapReaderObj);
    
    % 读取所有包数据
    packets = 0; % 记录有效包的总数
    hexPackets = zeros(pcapReaderObj.PacketsRead, 336); 
    for i=1:pcapReaderObj.PacketsRead
        if(decodedPackets(i).PacketLength == 378) % 使用数据包长度判断数据包是否为有效视频数据
            if(decodedPackets(i).Packet.eth.Payload(29,1) == 255 && decodedPackets(i).Packet.eth.Payload(30,1) == 255 && ...
               decodedPackets(i).Packet.eth.Payload(31,1) == 255 && decodedPackets(i).Packet.eth.Payload(32,1) == 255 && ...
               decodedPackets(i).Packet.eth.Payload(361,1) == 254 && decodedPackets(i).Packet.eth.Payload(362,1) == 254 && ...
               decodedPackets(i).Packet.eth.Payload(363,1) == 254 && decodedPackets(i).Packet.eth.Payload(364,1) == 254)
                
                packets = packets + 1; % 记录总包数
                hexPackets(packets,1:end) = decodedPackets(i).Packet.eth.Payload(29:end,1)'; % 保存线阵原始数据
            end
        end
    end
    
    hexPackets = hexPackets(1:packets, 1:end); % 删除预建矩阵中多余的0行数据，获得线阵原始数据
end


function  decPackets = hex_to_dec (hexPackets, packets)
    decPackets = zeros(packets, 160 + 4);
    decPackets(1:end, 1:160) = hexPackets(1:end, 5:2:324)*256 + hexPackets(1:end, 6:2:324);
    decPackets(1:end, 161) = hexPackets(1:end, 325)*256 + hexPackets(1:end, 326);
    decPackets(1:end, 162) = hexPackets(1:end, 331)*256*256*256 + hexPackets(1:end, 332)*256*256 + hexPackets(1:end, 327)*256 + hexPackets(1:end, 328);
    decPackets(1:end, 163) = hexPackets(1:end, 329); % 扫描次数
    decPackets(1:end, 164) = hexPackets(1:end, 330); % 行方向
end


function  [PC, section] = frame_merge (decPackets, lpn)
    % 合并两颗芯片的数据
    totalFrames = decPackets(end, 162); % 下位机发出总的帧数（不包含停止命令）
    totalPackets = size(decPackets, 1); % 上位机接收到的数据总包数
    PC = zeros(totalFrames, lpn, 5); 
    section = zeros(100, 5); % 记录扫描方向改变时所在帧开始位置
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



function  [raws, imgs] = multi_channel_image (PC, section, lpn)
    % 空气校准
    air_avg = repmat(mean(PC(200:300, 1:end, 1:end), 1), [size(PC, 1), 1, 1]);
    pc = (PC+1) ./air_avg;
    maxFrames = max(section(:, 4));
    totalScan = size(section, 1);

    raws = zeros(lpn*totalScan, maxFrames, 5); % 原始数据 
    imgs = zeros(lpn*totalScan, maxFrames, 5); % 空气校准数据
    for i= 1:totalScan
        raws_slices = permute(PC(section(i, 2):section(i, 3), 1:end, 1:end), [2 1 3]);
        imgs_slices = permute(pc(section(i, 2):section(i, 3), 1:end, 1:end), [2 1 3]);
        if mod(i,2) == 0
            raws((i-1)*lpn + 1:i*lpn, 1:section(i, 4), 1:end) = circshift(flip(raws_slices, 2), 2, 2);
            imgs((i-1)*lpn + 1:i*lpn, 1:section(i, 4), 1:end) = circshift(flip(imgs_slices, 2), 2, 2);
        else
            raws((i-1)*lpn + 1:i*lpn, 1:section(i, 4), 1:end) = circshift(raws_slices, 0, 2);
            imgs((i-1)*lpn + 1:i*lpn, 1:section(i, 4), 1:end) = circshift(imgs_slices, 0, 2);
        end
    end
end

   