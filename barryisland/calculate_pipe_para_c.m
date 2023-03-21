function [model_pipe, model_node] = calculate_pipe_para_c(model)
[model_pipe.num, null_num] = size (model.pipe);   %计算管道数量
[model_node.num, null_num] = size (model.node);   %计算节点数量
model_node.LD =  ismember(model.node(:,1),model.chp(:,1)); %从node节点矩阵中找出不接chp的节点
model_node.CHP = ismember(model.node(:,1),model.chp(:,1));  %从node节点矩阵中找出接chp的节点
%model_node.EB= ismember(model.node(:,1),model.boiler(:,2)); %从node节点矩阵中找出接electric boiler的节点

for i = 1 : model_pipe.num    %计算每一根管道的参数
L(i) = 500;
lambda(i) = model.pipe(i,6);  %温度传递系数=1/R
D(i) = model.pipe(i,4);       %内径 
A(i) = 3.14*(D(i)/2)^2;%截面积
model_pipe.A(i)=A(i);
L(i) = model.pipe(i,3);       %长度
R(i)=lambda(i)
end
rho = model.water_dens;      %水的密度
Cp = model.water_c;          %水的比热容
time=24;                     %调度周期24h
dt=3600;                      %调度间隔15*60s（为了与质量流速率单位相配合）
dx=500
Ta=model.t0
%%计算拓扑与流量
%% 计算温度混合矩阵
%计算节点-管道混合温度矩阵，（i，j)=1 第i个管道注入第j个节点 节点管道的关系，注入/输出/无关
%
model_node.A1T = zeros(model_pipe.num,model_node.num);       %supply网络中aij矩阵的初始化
model_node.A2T = zeros(model_pipe.num,model_node.num);   %注入节点的aij矩阵的group（非1元素变0）的初始化

%A1流出矩阵
for node = 1:model_node.num
    for pipe = 1:model_pipe.num
        if model.pipe(pipe,1) == node
            model_node.A1T(pipe,node) = 1; %流出为正
        end
    end
end    
model_node.A1=model_node.A1T'
%A2流入矩阵
for node = 1:model_node.num
    for pipe = 1:model_pipe.num
        if model.pipe(pipe,2) == node
            model_node.A2T(pipe,node) = 1;     %流入为正
        end
    end
end
model_node.A2=model_node.A2T'


