function [Pro_Matrix,Mean_Image]=my_pca(Train_SET,Eigen_NUM)
%���룺
%Train_SET��ѵ����������ÿ����һ��������ÿ��һ��������Dim*Train_Num
%Eigen_NUM��ͶӰά��

%�����
%Pro_Matrix��ͶӰ����
%Mean_Image����ֵͼ��

[Dim,Train_Num]=size(Train_SET);

 Mean_Image=mean(Train_SET,2); %���еľ�ֵ ά�ȵľ�ֵ 
 Train_SET=bsxfun(@minus,Train_SET,Mean_Image);  %ÿһ�е�Ԫ�ؽ�ȥÿһ�еľ�ֵ  

 R=Train_SET*Train_SET'/(Train_Num-1); %
    
 [eig_vec,eig_val]=eig(R);  %��������������ֵ  
 eig_val=diag(eig_val);  % ȡ����ĶԽ��߷��ص�����
 [~,ind]=sort(eig_val,'descend');  %���������� ~Ϊ���кõ����� indΪ���Ӧ��Ԫ����������
 W=eig_vec(:,ind);   %ԭ���������ľ������°�������
 Pro_Matrix=W(:,1:Eigen_NUM);   %ȡ1��ͶӰά��
    
