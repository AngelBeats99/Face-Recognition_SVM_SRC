% Face recognition on yale data---SVM����
% by Ma Xin. 2018.6.22

clear all 
clc
close all

%% ��ȡ�������ݡ�������

yaleData = 'C:\Users\maxee\Desktop\matlab\yaleBExtData ';
dataDir = dir(yaleData);  %dir �г�ָ��·���µ��������ļ��к����ļ�
 
 
for i = 3:40 
  facefile = [yaleData,'\',dataDir(i).name];
  oneperson = dir ([facefile, '\*.pgm']); 
  Asample = []; 
  for j = 1:length(oneperson)-1
      image = imread([oneperson(j).folder,'\',oneperson(j).name]);
      downsample = image(1:4:192, 1:4:168);
      imagedouble = double(downsample);   %ת��Ϊdouble��
      faceshape = reshape(imagedouble,1,48*42);  %reshape����˳��ת�������������
      Asample = [Asample;faceshape];   %m��������n��ά��
  end 
  
   Allsample{i-2} = Asample;   %����1*38��cell����
   
end

%% ����ѵ�����ϣ�p=7,13,20��
p = 13;
TrainData = [];
TestData = [];
TrainLabel = [];
TestLabel = [];

for i = 1:length(Allsample)
    % traindata and testdata for every person 
    [m,~] = size(Allsample{i});
    randse = randperm(m);   %�õ�������У���Ϊ�������е��ļ����ж���64��ͼ����ã���ȡm
    train_onep = Allsample{i}(randse(1:p),:);   
    test_onep = Allsample{i}(randse(p+1:m),:);
    trainlabel_onep = i * ones(p,1);
    testlabel_onep = i * ones(m-p,1);
    
    % sum to all traindata and testdata 
    TrainData = [TrainData; train_onep];
    TestData = [TestData; test_onep];
    TrainLabel = [TrainLabel; trainlabel_onep];
    TestLabel = [TestLabel; testlabel_onep];
end 


%% PCA��ά��50,100,200ά��ԭά��Ϊ2016��

trainsamples = TrainData';
testsamples = TestData';
[Pro_Matrix,Mean_Image]=my_pca(trainsamples,1000);
    %Pro_MatrixΪͶӰ����
    train_project=Pro_Matrix'*trainsamples;
    test_project=Pro_Matrix'*testsamples;

TrainData = train_project';
TestData = test_project';


%% ��һ��

%����ѵ�����Ͳ��Լ� 
Data = [TrainData;TestData];
Label = [TrainLabel;TestLabel];
%����˳������γ��µ�����
a = size(Data,1);
b = randperm(a);
RandData = Data(b,:);
RandLabel = Label(b);

Guiyi = mapminmax(RandData',-1,1);
NormData = Guiyi';

%% �������յ�ѵ�����Ͳ��Լ���ѵ�������� 

trainNum = size(TrainData,1);
DataNum = size(Data,1);

TrainSample = NormData(1:trainNum,:); 
TrainSample_label = RandLabel(1:trainNum);

TestSample = NormData(trainNum+1:DataNum,:);
TestSample_label = RandLabel(trainNum+1:DataNum);

%ѵ��ģ�ͣ�����ѵ������ʱ��
t1 = clock;
model = svmtrain(TrainSample_label,TrainSample,'-s 0 -t 2 -c 50'); %ѡ�ø�˹�˺���
t2 = clock;
SVMtrainTime = etime(t2,t1);

%���Բ�����ƽ��ÿ��ͼƬ��������ʱ��
t3 = clock;
[predicted_label, accuracy, decision_values] = svmpredict(TestSample_label,TestSample,model);
t4 = clock;
TestTime = etime(t4,t3);
t = TestTime / size(TestSample,1);

fprintf('ģ��ѵ��ʱ��Ϊ��%3.4fs\n',SVMtrainTime);
fprintf('ƽ��ÿ��ͼƬ��������ʱ��Ϊ��%3.4fs\n',t);
    





