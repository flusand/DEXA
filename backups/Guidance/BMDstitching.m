% trying of F:\Refer\其他\翱翔数据拼接\20230921-80kV-0.2mA-FPS50-30.7℃-01

clear,close,clc;
load('.\resources\EW1.mat');
HD1 = EW1;
EN = 2*(1:size(EW1,1)/64/2); % Even Number list of rows with EW1
for i = 1:numel(EN),
    T = EW1(64*(EN(i))-64+1:64*(EN(i)),:);
    HD1(64*(EN(i))-64+1:64*(EN(i)),:) = circshift(T,2,2); % the better way is sub-pixels interpolation
end
lpn = 64; % line pixels number
A = reshape(HD1,[lpn,size(EW1,1)/lpn,601]);
A = permute(A,[2 1 3]);
o = 4; % overlap is 4 lines, 4 is from the data
F = zeros(size(EW1,1)-(size(EW1,1)/lpn-1)*o, size(EW1,2));
F(1:64-o,:) = squeeze(A(1,1:64-o,:));
R1 = (0:1/(o-1):1)';
R2 = flipud(R1);
for i = 1:size(EW1,1)/lpn-1,
    U = squeeze(A(i,end-o+1:end,:));
    D = squeeze(A(i+1,1:o,:));
    f = bsxfun(@times,R1,U)+bsxfun(@times,R2,D);
    F(64*i-o+1-(i-1)*o:64*i-(i-1)*o,:) = f;
    F(64*i-(i-1)*o+1:64*i-(i-1)*o+64-o,:) = squeeze(A(i+1,o+1:64,:));
end
imtool(EW1,[]);
imtool(F,[]);