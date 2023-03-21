function [model_pipe, model_node] = calculate_pipe_para_c(model)
[model_pipe.num, null_num] = size (model.pipe);   %����ܵ�����
[model_node.num, null_num] = size (model.node);   %����ڵ�����
model_node.LD =  ismember(model.node(:,1),model.chp(:,1)); %��node�ڵ�������ҳ�����chp�Ľڵ�
model_node.CHP = ismember(model.node(:,1),model.chp(:,1));  %��node�ڵ�������ҳ���chp�Ľڵ�
%model_node.EB= ismember(model.node(:,1),model.boiler(:,2)); %��node�ڵ�������ҳ���electric boiler�Ľڵ�

for i = 1 : model_pipe.num    %����ÿһ���ܵ��Ĳ���
L(i) = 500;
lambda(i) = model.pipe(i,6);  %�¶ȴ���ϵ��=1/R
D(i) = model.pipe(i,4);       %�ھ� 
A(i) = 3.14*(D(i)/2)^2;%�����
model_pipe.A(i)=A(i);
L(i) = model.pipe(i,3);       %����
R(i)=lambda(i)
end
rho = model.water_dens;      %ˮ���ܶ�
Cp = model.water_c;          %ˮ�ı�����
time=24;                     %��������24h
dt=3600;                      %���ȼ��15*60s��Ϊ�������������ʵ�λ����ϣ�
dx=500
Ta=model.t0
%%��������������
%% �����¶Ȼ�Ͼ���
%����ڵ�-�ܵ�����¶Ⱦ��󣬣�i��j)=1 ��i���ܵ�ע���j���ڵ� �ڵ�ܵ��Ĺ�ϵ��ע��/���/�޹�
%
model_node.A1T = zeros(model_pipe.num,model_node.num);       %supply������aij����ĳ�ʼ��
model_node.A2T = zeros(model_pipe.num,model_node.num);   %ע��ڵ��aij�����group����1Ԫ�ر�0���ĳ�ʼ��

%A1��������
for node = 1:model_node.num
    for pipe = 1:model_pipe.num
        if model.pipe(pipe,1) == node
            model_node.A1T(pipe,node) = 1; %����Ϊ��
        end
    end
end    
model_node.A1=model_node.A1T'
%A2�������
for node = 1:model_node.num
    for pipe = 1:model_pipe.num
        if model.pipe(pipe,2) == node
            model_node.A2T(pipe,node) = 1;     %����Ϊ��
        end
    end
end
model_node.A2=model_node.A2T'


