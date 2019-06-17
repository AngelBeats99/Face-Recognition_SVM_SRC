% Face recognition on yale data---ϡ���ʾ������SRC��
% by Ma Xin. 2018.6.22

clear all 
clc
close all 

%% ��ȡ�������ݡ����������γ����ݼ��ͱ�ǩ��

yaleData = 'C:\Users\maxee\Desktop\matlab\yaleBExtData ';
dataDir = dir(yaleData);  %dir �г�ָ��·���µ��������ļ��к����ļ�

label = [];
allsamples = [];
for i = 3:40 
  facefile = [yaleData,'\',dataDir(i).name];
  oneperson = dir ([facefile, '\*.pgm']); 
  Asample = [];
  
  for j = 1:length(oneperson)-1
      image = imread([oneperson(j).folder,'\',oneperson(j).name]);
      downsample = image(1:4:192, 1:4:168);
      imagedouble = double(downsample);   %ת��Ϊdouble��
      faceshape = reshape(imagedouble,48*42,1);  %reshape����˳��ת�������������
      Asample = [Asample,faceshape];  
      allsamples = [allsamples,faceshape];  %��������������m��������n��ά��
      label = [label,i-2];   %���б�ǩ��
  end 
  
   Allsample{i-2} = Asample;   %����1*38��cell����
end

%% �ֳ�ѵ�����Ͳ��Լ� ��p=7,13,20��

p = 13;
trainsamples = [];
testsamples = [];
trainlabels = [];
testlabels = [];

for i = 1:length(Allsample)
    m = size(Allsample{i},2);
    randse = randperm(m);
    train_one = Allsample{i}(:,randse(1:p));
    test_one = Allsample{i}(:,randse(p+1:m));
    trainlabel_one = i * ones(1,p);
    testlabel_one = i * ones(1,m-p);
    
    trainsamples = [trainsamples,train_one];
    testsamples = [testsamples,test_one];
    trainlabels = [trainlabels,trainlabel_one];
    testlabels = [testlabels,testlabel_one];

end

%% ��ά��100��ԭά��Ϊ2016������λ��

[Pro_Matrix,Mean_Image]=my_pca(trainsamples,100);
    %Pro_MatrixΪͶӰ����
    train_project=Pro_Matrix'*trainsamples;
    test_project=Pro_Matrix'*testsamples;
trainNorm = normc(train_project);
testNorm = normc(test_project);

%% ʶ�𲢼���׼ȷ��
testNum = size(testNorm,2);   %�ܲ�����
trainNum = size(trainNorm,2);   %��ѵ���� 

labelpre = zeros(1,testNum);   %��ǩԤ������ڴ� 
h = waitbar(0,'please wait...');   %��������������ֵ��0~1
classnum = length(Allsample);
testtime = zeros(1,testNum);

for i = 1:testNum
    t1 = clock;
    xp = SolveHomotopy_CBM_std(trainNorm,testNorm(:,i),'lambda',0.01);
    %��Ե�i��������������Homotopy�������Ż��⣬��L1ϡ���ʾ�Ż��㷨֮һ�����Ϊx_out
    r = zeros(1, classnum);
    
    for j = 1:classnum
        %��xp��Ԫ�ش�������xn.����xp����j���Ӧ��Ԫ�ر�����������Ϊ0
        xn = zeros(trainNum,1);                   
        index = (j==trainlabels);   %indexΪbool����
        xn(index) = xp(index);   %index��xp��λ���Զ����� 
    
        r(j) = norm((testNorm(:,i) - trainNorm * xn));   %����2����
    end
    
    [~,pos] = min(r);    %����r�������С��λ�� 
    labelpre(i) = pos;
    t2 = clock;
    testtime(i) = etime(t2,t1);
    
    per = i / testNum;
    waitbar(per, h, sprintf('%2.0f%%', per*100));   %��ʾÿ���������Խ�����    
end
close(h)
Avtest_time = mean(testtime,2);
accuracy = sum(labelpre == testlabels) / testNum;

fprintf(2,'ʶ����Ϊ��%3.2f%%\n\n',accuracy*100);
fprintf('ƽ��ÿ��ͼƬ��������ʱ��Ϊ��%3.4fs\n',Avtest_time);




