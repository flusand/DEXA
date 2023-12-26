% ================================================================================
% File Name : parse_pacp_file.m
% Version   : Version 1.0
% Author    : FLUSAND
% Time      : 10/15/2023
% Language  : MATLAB2022B
% Company   : 深圳翱翔锐影科技有限公司
% Function  : Parsing Wireshark packet capture files
% ================================================================================

function  [s, m, cpc, pc] = parse_qa(fileName)
    decPackets = parse_pacp(fileName);
    [PC, section] = merge_chip_data(decPackets, lpn);
end

















