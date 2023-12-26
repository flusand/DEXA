%% �����Ȼ����˫�ֽܷ�
% һ��У׼����
% ���룺1���ӿ�����ȡ�ļ���read_air_files.m���л�õĿ���ͶӰ���ݣ�
%       2����У׼�����ȡ�ļ���read_calib_files_80kv.m���л�õ�У׼����ͶӰ���ݣ�
% ������ֽ�ʱ�Ĳ���

%% У׼����
close all;
clear;

load('air_cal_220mgCe_dualcaled_400uA_20180206_128ch.mat')%%%%
load('cali_bin123_data_220mgCe_dualcaled_400uA_20180206_128ch.mat');%%%%

pixel=size(cali_data,4);% 4ά���ݣ�1x2��AL��PMMA����ϣ�3��5�������ݣ�4��ÿ�������µ����ݡ�
t_al(1)=t_al(1)+0.001;
t_pmma(1)=t_pmma(1)+0.001;

AL_thick = t_al; % 
PMMA_thick = t_pmma; % 
[PMMA_thick0,AL_thick0]=meshgrid(PMMA_thick,AL_thick);%����������ϲ�ͬ�������ͬ��С�ľ���
[PMMA_thick3,AL_thick3]=meshgrid(PMMA_thick,AL_thick);

length=size(AL_thick0,1)*size(AL_thick0,2);
row=size(AL_thick0,1);
col=size(AL_thick0,2);

A1=reshape(AL_thick0,1,length)';
A2=reshape(PMMA_thick0,1,length)';
A=[A1 A2];%�γɲ�ͬ������

air = squeeze(rate_matrix(1,:)); %ɾ����һά�Ȼ����һ�������¸������ص�����
prj_pl = squeeze(cali_data(:,:,1,:));
pl = -log(prj_pl ./ (repmat(shiftdim(air,-1), [size(prj_pl,1) size(prj_pl,2) 1])+1));pl_=pl;%���Ȱ�airά�ȱ����ͶӰ������ͬ��3D��Ȼ�����ų���ͶӰ������ͬ��������

% Generate measurement points for H
air = squeeze(rate_matrix(2,:));
prj_ph = squeeze(cali_data(:,:,2,:));
ba = shiftdim(air,-1);
ph = -log(prj_ph ./ (repmat(shiftdim(air,-1), [size(prj_ph,1) size(prj_ph,2) 1])+1));ph_=ph;
ph = -log(prj_ph ./ (repmat(shiftdim(air,-1), [size(prj_ph,1) size(prj_ph,2) 1])+1));
PL =squeeze( ph(:, :, 40));
PH =squeeze( mean(ph(:, :, :),3));
PH = max(PH,0);
figure, mesh(PMMA_thick0,AL_thick0,PL),zlabel('PL'),ylabel('A1/mm'),xlabel('A2/mm')
figure, mesh(PMMA_thick0,AL_thick0,PH),zlabel('PH'),ylabel('A1/mm'),xlabel('A2/mm')

%% 
%M=inv(A'*A)*A'*L;
% M=[0.09387 0.02087;0.06938 0.02031];
for i=1:pixel
     L=reshape(pl(:,:,i),1,length)';
     H=reshape(ph(:,:,i),1,length)';
     [M1,bint,r,rint,status]=regress(L,A);%��С���˷���M
     [M2,bint,r,rint,status]=regress(H,A);
    M=[M1';M2'];
    center_x=ceil(size(pl,1)/2);
    center_y=ceil(size(pl,2)/2);
    % L_center=[pl(5,7,i); ph(5,7,i)];
    L_center=[pl(center_x,center_y,i); ph(center_x,center_y,i)];%0608
    L_center=squeeze(L_center);
    R(i)=cov(L_center);
    a = inv(M'*inv(R(i))*M)*M'*inv(R(i));
    A_MLE_param(:,:,i)=inv(M'*inv(R(i))*M)*M'*inv(R(i));
    L_withniose(1,:)=reshape(pl(:,:,i),1,length)
    L_withniose(2,:)=reshape(ph(:,:,i),1,length)
    A_MLE=A_MLE_param(:,:,i)*L_withniose;

    A_MLE_Al(:,:,i)=reshape(A_MLE(1,:),row,col);
    A_MLE_PMMA(:,:,i)=reshape(A_MLE(2,:),row,col);
    err_Al(:,:,i)=(A_MLE_Al(:,:,i)-AL_thick0);
    err_PMMA(:,:,i)=(A_MLE_PMMA(:,:,i)-PMMA_thick0);
end

% errpercent_Al=err_Al./AL_thick0;
% errpercent_PMMA=err_PMMA./PMMA_thick0;
% figure,plot3(A_MLE_Al,A_MLE_PMMA,err_Al);
% figure,plot3(A_MLE_Al,A_MLE_PMMA,err_PMMA);
% xnodes=-5:0.4:40;
% ynodes=-10:0.4:80;
% [zg_Al,xg,yg] = gridfit(A_MLE_Al,A_MLE_PMMA,err_Al,xnodes,ynodes);
% figure,plot3(xg,yg,zg_Al);
% [zg_PMMA,xg,yg] = gridfit(A_MLE_Al,A_MLE_PMMA,err_PMMA,xnodes,ynodes);
% figure,plot3(xg,yg,zg_PMMA);


%% �ֽ����

load('air_cal_220mgCe_dualcaled_400uA_20180206_128ch.mat')%%%%
load('cali_bin123_data_220mgCe_dualcaled_400uA_20180206_128ch.mat');%%%%


AL_thick = t_al; % 
PMMA_thick = t_pmma; % 
[PMMA_thick0,AL_thick0]=meshgrid(PMMA_thick,AL_thick);
length=size(PMMA_thick0,1)*size(PMMA_thick0,2);
row=size(PMMA_thick0,1);
col=size(PMMA_thick0,2);

air = squeeze(rate_matrix(1,:)); 
prj = squeeze(cali_data(:,:,1,:));
pl = -log(prj ./ (repmat(shiftdim(air,-1), [size(prj,1) size(prj,2) 1])+1));
air = squeeze(rate_matrix(2,:));
prj = squeeze(cali_data(:,:,2,:));                                                                                                                                               
ph = -log(prj ./ (repmat(shiftdim(air,-1), [size(prj,1) size(prj,2) 1])+1));  

PL1 =squeeze( ph(:, :, 40))';
PL1 = max(PL1,0);
figure, mesh(PMMA_thick3,AL_thick3,PL);hold on
mesh(PMMA_thick0,AL_thick0,PL1');zlabel('PH'),ylabel('A1/mm'),xlabel('A2/mm')
% ph=ph(:,:,1:48);
PH =squeeze( mean(mean(ph(:, :, :),1),2))';
PH = max(PH,0);
tic
for i=1:pixel
L_withniose_9(1,:)=reshape(pl(:,:,i),1,length);
L_withniose_9(2,:)=reshape(ph(:,:,i),1,length);
A_MLE_9=A_MLE_param(:,:,i)*L_withniose_9;

A_MLE_Al_9=reshape(A_MLE_9(1,:),row,col);
A_MLE_PMMA_9=reshape(A_MLE_9(2,:),row,col);
err_Al_9=(A_MLE_Al_9-AL_thick0);
err_PMMA_9=(A_MLE_PMMA_9-PMMA_thick0);
errpercent_Al=err_Al_9./AL_thick0;
errpercent_PMMA=err_PMMA_9./PMMA_thick0;
% figure,plot3(A_MLE_Al_9,A_MLE_PMMA_9,err_Al_9);
% figure,plot3(A_MLE_Al_9,A_MLE_PMMA_9,err_PMMA_9);

Al_err = griddata(A_MLE_Al(:,:,i),A_MLE_PMMA(:,:,i),err_Al(:,:,i),A_MLE_Al_9,A_MLE_PMMA_9);
Al_thick(:,:,i)=A_MLE_Al_9-Al_err;
PMMA_err = griddata(A_MLE_Al(:,:,i),A_MLE_PMMA(:,:,i),err_PMMA(:,:,i),A_MLE_Al_9,A_MLE_PMMA_9);
PMMA_thick_(:,:,i)=A_MLE_PMMA_9-PMMA_err;

err_Al_MLE(:,:,i)=abs(squeeze(Al_thick(:,:,i))-AL_thick0)./AL_thick0*100;
err_PMMA_MLE(:,:,i)=abs(squeeze(PMMA_thick_(:,:,i))-PMMA_thick0)./PMMA_thick0*100;
end
toc
% save('matfiles\err_9point_indiv_MLE_0601','err_Al_MLE','err_PMMA_MLE');
num=size(Al_thick,1)*size(Al_thick,2);
Al_thick_mean=squeeze(mean(Al_thick(:,:,1:pixel),3));
err_Al_MLE_mean=(Al_thick_mean-AL_thick0)./AL_thick0*100;
Al_thick1=reshape(Al_thick,num,pixel);
Al_std=std(squeeze(Al_thick1(3,:)));

PMMA_thick_mean=squeeze(mean(PMMA_thick_(:,:,1:pixel),3));
PMMA_thick1=reshape(PMMA_thick_,num,pixel);
PMMA_std=std(squeeze(PMMA_thick1(1,:)));
%% ����ֽ����
err_PMMA_point3=squeeze(mean(err_PMMA_MLE(:,:,:),3));
err_Al_point3=squeeze(mean(err_Al_MLE(:,:,:),3));

err_PMMA_point1=squeeze(mean(mean(err_PMMA_MLE(:,:,:),1),2));
err_Al_point1=squeeze(mean(mean(err_Al_MLE(:,:,:),1),2));
figure,plot(err_Al_point1,'.'),xlabel('pixel'),ylabel('bias/%'),axis([0 128 0 10])%title('��һ�����Ե��ڸ�������Al�ķֽ����'),
figure,plot(err_PMMA_point1,'.'),xlabel('pixel'),ylabel('bias/%'),axis([0 128 0 20])%title('��һ�����Ե��ڸ�������PMMA�ķֽ����'),
% save('matfiles\decompeError_bin123_180104','err_Al_point1','err_PMMA_point1')
%�����ֲ�ͼ
f1=err_Al_point1(find(abs(err_Al_point1)<0.5));
f2=err_Al_point1(find(abs(err_Al_point1)<1&abs(err_Al_point1)>=0.5));
f3=err_Al_point1(find(abs(err_Al_point1)<1.5&abs(err_Al_point1)>=1));
f4=err_Al_point1(find(abs(err_Al_point1)<2&abs(err_Al_point1)>=1.5));
f5=err_Al_point1(find(abs(err_Al_point1)<3&abs(err_Al_point1)>=2));
f6=err_Al_point1(find(abs(err_Al_point1)>3));
ratio=[size(f1,1) size(f2,1) size(f3,1) size(f4,1) size(f5,1) size(f6,1)]/(size(f1,1)+size(f2,1)+size(f3,1)+size(f4,1)+size(f5,1)+size(f6,1));
figure,pie(ratio)
legend('0.5%-1%','1%-1.5%','1.5%-2%','3%-2%','>3%'),title('Al')%'<0.5',

%ȥ��������
BadPixel=find(err_Al_point1<-2 | err_Al_point1>3);
GoodPixel=find(err_Al_point1<3 & err_Al_point1>-2);
% err_Al_point2=err_Al_point1([1:48 65:80]);
% err_PMMA_point2=err_PMMA_point1([1:48 65:80]);
err_Al_point2=err_Al_point1(GoodPixel);
err_PMMA_point2=err_PMMA_point1(GoodPixel);
mean_err_Al=mean(err_Al_point2);
std_err_Al=std(err_Al_point2);
mean_err_PMMA=mean(err_PMMA_point2);
std_err_PMMA=std(err_PMMA_point2);
figure,errorbar(mean_err_Al,std_err_Al)

%% 9�����
err_PMMA_MLE1=err_PMMA_MLE(:,:,:);
err_Al_MLE1=err_Al_MLE(:,:,:);
err_Al_MLE_9=reshape(err_Al_MLE1,size(err_Al_MLE1,1)*size(err_Al_MLE1,2),size(err_Al_MLE1,3));
err_PMMA_MLE_9=reshape(err_PMMA_MLE1,size(err_Al_MLE1,1)*size(err_Al_MLE1,2),size(err_Al_MLE1,3));

for i=1:size(err_Al_MLE1,1)*size(err_Al_MLE1,2) 
        err_Al9(i)=mean(abs(err_Al_MLE_9(i,:)),2);
        mean_al_err=mean(err_Al9);
        err_PMMA9(i)=mean(abs(err_PMMA_MLE_9(i,:)),2);
        std_Al9(i)=std(squeeze(abs(err_Al_MLE_9(i,:))));
        std_PMMA9(i)=std(squeeze(abs(err_PMMA_MLE_9(i,:))));
        err_Al9_mean(i)=mean(err_Al_MLE_9(i,:),2);
        err_PMMA9_mean(i)=mean(err_PMMA_MLE_9(i,:),2);
        err_Al9_std(i)=std(squeeze(err_Al_MLE_9(i,:)));
        err_PMMA9std(i)=std(squeeze(err_PMMA_MLE_9(i,:)));
end
figure,plot(err_Al9_mean,err_Al9_std,'.');xlabel('Al mean(%)'),ylabel('std(%)'),
figure,plot(err_PMMA9_mean,err_PMMA9std,'.');xlabel('PMMA mean(%)'),ylabel('std(%)'),
figure,plot(err_Al9,std_Al9,'.');xlabel('Al mean(%)'),ylabel('std(%)'),
figure,plot(err_PMMA9,std_PMMA9,'.');xlabel('PMMA mean(%)'),ylabel('std(%)'),
% save('matfiles\err_MLE_dual_220mgce_180206','err_Al9_mean','err_Al9_std','err_PMMA9_mean','err_PMMA9std','err_Al_point1','err_PMMA_point1')
