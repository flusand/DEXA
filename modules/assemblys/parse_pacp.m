% ================================================================================
% File Name : parse_pacp_file.m
% Version   : Version 1.0
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : Parsing Wireshark packet capture files
% ================================================================================

function  decPackets = parse_pacp(fileName)
    % 检查pcap 对应的Mat文件是否存在
    matFile=strcat(pwd, '\resources\FILES\MAT\', replace(fileName, 'pcap', 'mat'));
    if exist(matFile,'file')
        load(matFile);
        return;
    end
    
    pcapFile = strcat(pwd, '\resources\FILES\', fileName);
    pcap = pcapReader(pcapFile);
    decodedPackets = readAll(pcap);

    % 读取所有包数据
    hexPackets = zeros(pcap.PacketsRead, 336); packets = 0;
    for i=1:pcap.PacketsRead
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
  
    % 将十六进制数据转化需要的十进制
    decPackets = zeros(packets, 160 + 4);
    decPackets(1:end, 1:160) = hexPackets(1:end, 5:2:324)*256 + hexPackets(1:end, 6:2:324);
    decPackets(1:end, 161) = hexPackets(1:end, 325)*256 + hexPackets(1:end, 326);
    decPackets(1:end, 162) = hexPackets(1:end, 331)*256*256*256 + hexPackets(1:end, 332)*256*256 + hexPackets(1:end, 327)*256 + hexPackets(1:end, 328);
    decPackets(1:end, 163) = hexPackets(1:end, 329); % 扫描次数
    decPackets(1:end, 164) = hexPackets(1:end, 330); % 行方向
    % 将读取的pcap 保存对应的Mat文件
    save(matFile, 'decPackets');
end




