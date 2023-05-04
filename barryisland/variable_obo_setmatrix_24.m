clc
clear all
%% 定义并初始化变量
time=24;        %时间断面
dt = 60*60;       %时间间隔
model.dt = dt;    %放入结构体内
model.time = time;   %放入结构体内
model.set=50;



%% 1. 定义系数，读入数据
% 读入参数
define_heat_inputs_24_new_cost;
define_electric_inputs_old;

% 根据流量读入管道时延参数、温度计算参数
[model_pipe,model_node] = calculate_pipe_para_c(model); %子函数结果导入
[mpc_bus, mpc_branch] = calculate_branch_para(mpc)
LD=model_node.LD;
CHP=model_node.CHP;

% 参数命名
[chp_num, null_num] = size (model.chp);
[hnode_num, null_num] = size (model.node);
[hpipe_num, null_num] = size (model.pipe);
[ebus_num, null_num] = size (mpc.bus);
[ebranch_num, null_num] = size (mpc.branch);


%设置待求变量
p_chp = sdpvar(time,chp_num,'full');   %chp发电
q_chp = sdpvar(time,chp_num,'full');   %chp产热
jd=sdpvar(time,ebus_num,'full')
cost = 0;    %成本初始值为0
tnode=sdpvar (time, hnode_num,'full');  %供热网络节点温度 
m=ones(hpipe_num,time)
% m=sdpvar(hpipe_num,time,'full')

Ta = model.t0;   %外部温度

%% CHP unit constraint
%约束初始化
CHP_constraint = [];
CHP_q = [];
for t=1:time %ineqlin 1-288
%CHP1
CHP_q=[CHP_q,-1.91.*q_chp(t,1)+p_chp(t,1)+3.55<=0];
CHP_q=[CHP_q,-0.0833*q_chp(t,1)-p_chp(t,1)+5.42<=0];
CHP_q=[CHP_q,8.667*q_chp(t,1)-p_chp(t,1)-143.3390<=0];
CHP_q=[CHP_q,2*q_chp(t,1)+p_chp(t,1)-70<=0];
%CHP2
CHP_q=[CHP_q,-1.91.*q_chp(t,2)+p_chp(t,2)+4.65<=0];
CHP_q=[CHP_q,-0.0833*q_chp(t,2)-p_chp(t,2)+11.32<=0];
CHP_q=[CHP_q,8.667*q_chp(t,2)-p_chp(t,2)-160.3390<=0];
CHP_q=[CHP_q,2*q_chp(t,2)+p_chp(t,2)-69<=0];
%CHP3
CHP_q=[CHP_q,-2.79.*q_chp(t,3)+p_chp(t,3)+8.7<=0];
CHP_q=[CHP_q,-0.0833*q_chp(t,3)-1.65*p_chp(t,3)+5.52<=0];
CHP_q=[CHP_q,8.667*q_chp(t,3)-p_chp(t,3)-141.3390<=0];
CHP_q=[CHP_q,2*q_chp(t,3)+p_chp(t,3)-68<=0];
end

CHP_constraint = CHP_constraint + CHP_q 

%% DHS constraint
DHS_constraint=[];
H_q=[]; %节点热力平衡

%节点注入热量
chp_q_yw=zeros(chp_num,model_node.num)
for i=1:model_node.num
    for j=1:chp_num
      if model.chp_a(j,1)==i
          chp_q_yw(j,i)=1
      end
    end
end
hload=model.load_new
q_zhu_node=q_chp*chp_q_yw-hload(1:time,:) %QG-QD
tstart=[93.1915467600000,79.0107301300000,79.5947769000000,79.5995857700000,78.7490805100000,79.5774333600000,77.7922183900000,77.8075660100000,77.8151370500000,77.8004116200000,80.9087520900000,84.6967854400000,79.9338100300000,79.9368342200000,80.7926476000000,80.8039332400000,80.8020890100000,80.8043711700000,78.8707064000000,80.8017698600000,80.8019862800000,69.2795360600000,69.2889614000000,69.2912127400000,67.6847982600000,66.4197532000000,66.4207831500000,67.2312652000000,66.4246094900000,66.4238066000000,67.9279744300000,94.5795463800000,80.0185438200000,79.0051656900000,93.1851069300000,93.1750238200000,93.1798326900000,93.1829146200000,93.1576802700000,91.4058310000000,91.3878129200000,91.3953839700000,91.3806585400000,94.4066094100000,94.3969618100000,94.4009602600000,94.3974526800000,94.3951702400000,94.3841801600000,94.3823359300000,94.3846180800000,94.3948510600000,94.3820167800000,94.3822332000000,82.8826912500000,82.8692083200000,82.8714596600000,80.0110295400000,80.0000001200000,80.0010300700000,80.0125771400000,80.0048564100000,80.0040535200000,80.0143288700000,80.9040206600000,67.9243172400000]

cent=ones(hpipe_num,time)
for i=1:hpipe_num
    for t=1:time
    cent(i,t)=model.water_dens.*(3.14/4).*model.pipe(i,4)^2.*model.pipe(i,3)/(m(i,t).*model.pipemass(i,1).*dt)
    end
end
%% 中间变量
% gdaa=sdpvar(hpipe_num,T,'full')
% G=sdpvar(hpipe_num,T,'full')
% gdbb=sdpvar(hpipe_num,T,'full')
    gdaa=zeros(hpipe_num,time)
    G=zeros(hpipe_num,time)
    gdbb=zeros(hpipe_num,time)
for i=1:hpipe_num
    for t=1:time
    gdaa(i,t)=-model.water_c /1e6.*model.pipemass(i,1).*m(i,t).*(1-(model.pipe(i,6).*model.pipe(i,3))/(model.water_c.*model.pipemass(i,1).*m(i,t))).*(1-model.water_dens.*(3.14/4).*model.pipe(i,4)^2.*model.pipe(i,3)/(m(i,t).*model.pipemass(i,1).*dt));
    G(i,t)=model.water_c / 1e6.*model.pipemass(i,1).*m(i,t);
    gdbb(i,t)=-model.water_c /1e6.*model.pipemass(i,1).*m(i,t).*(1-(model.pipe(i,6).*model.pipe(i,3))/(model.water_c.*model.pipemass(i,1).*m(i,t))).*(model.water_dens.*(3.14/4).*model.pipe(i,4)^2.*model.pipe(i,3)/(m(i,t).*model.pipemass(i,1).*dt));
    end
end
for i=1:hpipe_num
    for t=1:time
    rm(i,t)=model.water_c / 1e6.*model.pipemass(i,1).*m(i,t).*(exp(-(model.pipe(i,6).*model.pipe(i,3))/(model.water_c.*model.pipemass(i,1).*m(i,t)))-1).*model.t01(1,t)
    end
end

tp=zeros(hnode_num,hpipe_num)
for i=1:hpipe_num
    for j=1:hnode_num
if model.pipe(j,2)==i
tp(i,j)=1
end
    end
end

for t=1:time
r(:,t)=tp*rm(:,t)
end

%% 节点热能平衡约束
t=1
    H_q=[H_q,G(1,t).*tnode(t,1)+gdaa(67,t).*tnode(t,34)+r(1,t)==q_zhu_node(t,1)]
    H_q=[H_q,G(34,t).*tnode(t,2)+gdaa(35,t).*tnode(t,3)+gdbb(35,t).*tstart(3)+gdaa(36,t).*tnode(t,4)+gdbb(36,t).*tstart(4)+gdaa(37,t).*tnode(t,5)+gdbb(37,t).*tstart(5)+gdaa(68,t).*tnode(t,35)+gdbb(68,t).*tstart(35)+r(2,t)==q_zhu_node(t,2)]
    H_q=[H_q,G(35,t).*tnode(t,3)+gdaa(69,t).*tnode(t,36)+r(3,t)==q_zhu_node(t,3)]
    H_q=[H_q,G(36,t).*tnode(t,4)+gdaa(70,t).*tnode(t,37)+r(4,t)==q_zhu_node(t,4)]
    H_q=[H_q,G(37,t).*tnode(t,5)+gdaa(38,t).*tnode(t,6)+gdbb(38,t).*tstart(6)+gdaa(39,t).*tnode(t,7)+gdbb(39,t).*tstart(7)+gdaa(43,t).*tnode(t,11)+gdbb(43,t).*tstart(11)+gdaa(71,t).*tnode(t,38)+gdbb(71,t).*tstart(38)+r(5,t)==q_zhu_node(t,5)]
    H_q=[H_q,G(38,t).*tnode(t,6)+gdaa(72,t).*tnode(t,39)+r(6,t)==q_zhu_node(t,6)]
    H_q=[H_q,(G(39,t)+G(66,t)).*tnode(t,7)+gdaa(40,t).*tnode(t,8)+gdbb(40,t).*tstart(8)+gdaa(41,t).*tnode(t,9)+gdbb(41,t).*tstart(9)+gdaa(42,t).*tnode(t,10)+gdbb(42,t).*tstart(10)+gdaa(73,t).*tnode(t,40)+gdbb(73,t).*tstart(40)+r(7,t)==q_zhu_node(t,7)]
    H_q=[H_q,G(40,t).*tnode(t,8)+gdaa(74,t).*tnode(t,41)+r(8,t)==q_zhu_node(t,8)]
    H_q=[H_q,G(41,t).*tnode(t,9)+gdaa(75,t).*tnode(t,42)+r(9,t)==q_zhu_node(t,9)]
    H_q=[H_q,G(42,t).*tnode(t,10)+gdaa(76,t).* tnode(t,43)+r(10,t)==q_zhu_node(t,10)]
    H_q=[H_q,(G(43,t)+G(64,t)).*tnode(t,11)+gdaa(44,t).*tnode(t,12)+gdbb(44,t).*tstart(12)+gdaa(45,t).*tnode(t,13)+gdbb(45,t).*tstart(13)+gdaa(77,t).*tnode(t,44)+gdbb(77,t).*tstart(44)+r(11,t)==q_zhu_node(t,11)]
    H_q=[H_q,G(44,t).*tnode(t,12)+gdaa(78,t).*tnode(t,45)+r(12,t)==q_zhu_node(t,12)]
    H_q=[H_q,G(45,t).*tnode(t,13)+gdaa(46,t).*tnode(t,14)+gdbb(46,t).*tstart(14)+r(13,t)==q_zhu_node(t,13)]
    H_q=[H_q,G(46,t).*tnode(t,14)+gdaa(47,t).*tnode(t,15)+gdbb(47,t).*tstart(15)+gdaa(50,t).*tnode(t,18)+gdbb(50,t).*tstart(18)+gdaa(51,t).*tnode(t,19)+gdbb(51,t).*tstart(19)+gdaa(80,t).*tnode(t,47)+gdbb(80,t).*tstart(47)+r(14,t)==q_zhu_node(t,14)]
    H_q=[H_q,G(47,t).*tnode(t,15)+gdaa(48,t).*tnode(t,16)+gdbb(48,t).*tstart(16)+gdaa(49,t).*tnode(t,17)+gdbb(49,t).*tstart(17)+gdaa(81,t).*tnode(t,48)+gdbb(81,t).*tstart(48)+r(15,t)==q_zhu_node(t,15)]   
    H_q=[H_q,G(48,t).*tnode(t,16)+gdaa(82,t).*tnode(t,49)+r(16,t)==q_zhu_node(t,16)]
    H_q=[H_q,G(49,t).*tnode(t,17)+gdaa(83,t).*tnode(t,50)+r(17,t)==q_zhu_node(t,17)]
    H_q=[H_q,G(50,t).*tnode(t,18)+gdaa(84,t).*tnode(t,51)+r(18,t)==q_zhu_node(t,18)]
    H_q=[H_q,G(51,t)*tnode(t,19)+gdaa(52,t).*tnode(t,20)+gdbb(52,t).*tstart(20)+gdaa(53,t).*tnode(t,21)+gdbb(53,t).*tstart(21)+gdaa(54,t).*tnode(t,22)+gdbb(54,t).*tstart(22)+gdaa(85,t).*tnode(t,52)+gdbb(85,t).*tstart(52)+r(19,t)==q_zhu_node(t,19)]
    H_q=[H_q,G(52,t).*tnode(t,20)+gdaa(86,t).*tnode(t,53)+r(20,t)==q_zhu_node(t,20)]
    H_q=[H_q,G(53,t).*tnode(t,21)+gdaa(87,t).*tnode(t,54)+r(21,t)==q_zhu_node(t,21)]
    H_q=[H_q,(G(54,t)+G(57,t)).*tnode(t,22)+gdaa(55,t).*tnode(t,23)+gdbb(55,t).*tstart(23)+gdaa(56,t).*tnode(t,24)+gdbb(56,t).*tstart(24)+gdaa(88,t).*tnode(t,55)+gdbb(88,t).*tstart(55)+r(22,t)==q_zhu_node(t,22)]  
    H_q=[H_q,G(55,t).*tnode(t,23)+gdaa(89,t).*tnode(t,56)+r(23,t)==q_zhu_node(t,23)]
    H_q=[H_q,G(56,t).*tnode(t,24)+gdaa(90,t).*tnode(t,57)+r(24,t)==q_zhu_node(t,24)]
    H_q=[H_q,G(60,t).*tnode(t,25)+gdaa(57,t).*tnode(t,22)+gdbb(57,t).*tstart(22)+gdaa(58,t).*tnode(t,26)+gdbb(58,t).*tstart(26)+gdaa(59,t).*tnode(t,27)+gdbb(59,t).*tstart(27)+gdaa(91,t).*tnode(t,58)+gdbb(91,t).*tstart(58)+r(25,t)==q_zhu_node(t,25)]
    H_q=[H_q,G(58,t).*tnode(t,26)+gdaa(92,t).*tnode(t,59)+r(26,t)==q_zhu_node(t,26)]
    H_q=[H_q,G(59,t).*tnode(t,27)+gdaa(93,t).*tnode(t,60)+r(27,t)==q_zhu_node(t,27)]  
    H_q=[H_q,G(63,t).*tnode(t,28)+gdaa(60,t).*tnode(t,25)+gdbb(60,t).*tstart(25)+gdaa(61,t).*tnode(t,29)+gdbb(61,t).*tstart(29)+gdaa(62,t).*tnode(t,30)+gdbb(62,t).*tstart(30)+gdaa(94,t).*tnode(t,61)+gdbb(94,t).*tstart(61)+r(28)==q_zhu_node(t,28)]
    H_q=[H_q,G(61,t).*tnode(t,29)+gdaa(95,t).*tnode(t,62)+r(29,t)==q_zhu_node(t,29)]
    H_q=[H_q,G(62,t).*tnode(t,30)+gdaa(96,t).*tnode(t,63)+r(30,t)==q_zhu_node(t,30)] 
    H_q=[H_q,G(65,t).*tnode(t,31)+gdaa(63,t).*tnode(t,28)+gdbb(63,t).*tstart(28)+gdaa(66,t).*tnode(t,7)+gdbb(66,t).*tstart(7)+gdaa(97,t).*tnode(t,64)+gdbb(97,t).*tstart(64)+r(31,t)==q_zhu_node(t,31)]  
    H_q=[H_q,G(31,t).*tnode(t,32)+gdaa(98,t).*tnode(t,65)+r(32,t)==q_zhu_node(t,32)]
    H_q=[H_q,G(32,t).*tnode(t,33)+gdaa(99,t).*tnode(t,66)+r(33,t)==q_zhu_node(t,33)]
    H_q=[H_q,G(67,t).*tnode(t,34)+gdaa(34,t).*tnode(t,2)+gdbb(34,t).*tstart(2)+r(34,t)==q_zhu_node(t,34)]  
    H_q=[H_q,(G(68,t)+G(2,t)+G(3,t)+G(4,t)).*tnode(t,35)+gdaa(1,t).*tnode(t,1)+gdbb(1,t).*tstart(1)+r(35,t)==q_zhu_node(t,35)]  
    H_q=[H_q,G(69,t).*tnode(t,36)+gdaa(2,t).*tnode(t,35)+gdbb(2,t).*tstart(35)+r(36,t)==q_zhu_node(t,36)]  
    H_q=[H_q,G(70,t).*tnode(t,37)+gdaa(3,t).*tnode(t,35)+gdbb(3,t).*tstart(35)+r(37,t)==q_zhu_node(t,37)]  
    H_q=[H_q,(G(71,t)+G(5,t)+G(6,t)+G(10,t)).*tnode(t,38)+gdaa(4,t).*tnode(t,35)+gdbb(4,t).*tstart(35)+r(38,t)==q_zhu_node(t,38)]
    H_q=[H_q,G(72,t).*tnode(t,39)+gdaa(5,t).*tnode(t,38)+gdbb(5,t).*tstart(38)+r(39,t)==q_zhu_node(t,39)]  
    H_q=[H_q,(G(73,t)+G(7,t)+G(8,t)+G(9,t)).*tnode(t,40)+gdaa(6,t).*tnode(t,38)+gdbb(6,t).*tstart(38)+gdaa(33,t).*tnode(t,64)+gdbb(33,t).*tstart(64)+r(40,t)==q_zhu_node(t,40)]  
    H_q=[H_q,G(74,t).*tnode(t,41)+gdaa(7,t).*tnode(t,40)+gdbb(7,t).*tstart(40)+r(41,t)==q_zhu_node(t,41)]  
    H_q=[H_q,G(75,t).*tnode(t,42)+gdaa(8,t).*tnode(t,40)+gdbb(8,t).*tstart(40)+r(42,t)==q_zhu_node(t,42)]  
    H_q=[H_q,G(76,t).*tnode(t,43)+gdaa(9,t).*tnode(t,40)+gdbb(9,t).*tstart(40)+r(43,t)==q_zhu_node(t,43)] 
    H_q=[H_q,(G(77,t)+G(11,t)+G(12,t)).*tnode(t,44)+gdaa(10,t).*tnode(t,38)+gdbb(10,t).*tstart(38)+gdaa(31,t).*tnode(t,32)+gdbb(31,t).*tstart(32)+r(44,t)==q_zhu_node(t,44)]  
    H_q=[H_q,G(78,t).*tnode(t,45)+gdaa(11,t).*tnode(t,44)+gdbb(11,t).*tstart(44)+r(45,t)==q_zhu_node(t,45)]  
    H_q=[H_q,(G(79,t)+G(13,t)).*tnode(t,46)+gdaa(12,t).*tnode(t,44)+gdbb(12,t).*tstart(44)+r(46,t)==q_zhu_node(t,46)]  
    H_q=[H_q,(G(80,t)+G(14,t)+G(18,t)+G(17,t)).*tnode(t,47)+gdaa(13,t).*tnode(t,46)+gdbb(13,t).*tstart(46)+r(47,t)==q_zhu_node(t,47)] 
    H_q=[H_q,(G(81,t)+G(15,t)+G(16,t)).*tnode(t,48)+gdaa(14,t).*tnode(t,47)+gdbb(14,t).*tstart(47)+r(48,t)==q_zhu_node(t,48)]  
    H_q=[H_q,G(82,t).*tnode(t,49)+gdaa(15,t).*tnode(t,48)+gdbb(15,t).*tstart(48)+r(49,t)==q_zhu_node(t,49)]  
    H_q=[H_q,G(83,t).*tnode(t,50)+gdaa(16,t).*tnode(t,48)+gdbb(16,t).*tstart(48)+r(50,t)==q_zhu_node(t,50)] 
    H_q=[H_q,G(84,t).*tnode(t,51)+gdaa(17,t).*tnode(t,47)+gdbb(17,t).*tstart(47)+r(51,t)==q_zhu_node(t,51)]
    H_q=[H_q,(G(85,t)+G(19,t)+G(20,t)+G(21,t)).*tnode(t,52)+gdaa(18,t).*tnode(t,47)+gdbb(18,t).*tstart(47)+r(52,t)==q_zhu_node(t,52)]
    H_q=[H_q,G(86,t).*tnode(t,53)+gdaa(19,t).*tnode(t,52)+gdbb(19,t).*tstart(52)+r(53,t)==q_zhu_node(t,53)] 
    H_q=[H_q,G(87,t).*tnode(t,54)+gdaa(20,t).*tnode(t,52)+gdbb(20,t).*tstart(52)+r(54,t)==q_zhu_node(t,54)]
    H_q=[H_q,(G(88,t)+G(23,t)+G(22,t)).*tnode(t,55)+gdaa(21,t).*tnode(t,52)+gdbb(21,t).*tstart(52)+gdaa(24,t).*tnode(t,58)+gdbb(24,t).*tstart(58)+r(55,t)==q_zhu_node(t,55)]  
    H_q=[H_q,G(89,t).*tnode(t,56)+gdaa(22,t).*tnode(t,55)+gdbb(22,t).*tstart(55)+r(56,t)==q_zhu_node(t,56)] 
    H_q=[H_q,G(90,t).*tnode(t,57)+gdaa(23,t).*tnode(t,55)+gdbb(23,t).*tstart(55)+r(57,t)==q_zhu_node(t,57)]
    H_q=[H_q,(G(91,t)+G(24,t)+G(25,t)+G(26,t)).*tnode(t,58)+gdaa(27,t).*tnode(t,61)+gdbb(27,t).*tstart(61)+r(58,t)==q_zhu_node(t,58)]
    H_q=[H_q,G(92,t).*tnode(t,59)+gdaa(25,t).*tnode(t,58)+gdbb(25,t).*tstart(58)+r(59,t)==q_zhu_node(t,59)] 
    H_q=[H_q,G(93,t).*tnode(t,60)+gdaa(26,t).*tnode(t,58)+gdbb(26,t).*tstart(58)+r(60,t)==q_zhu_node(t,60)]
    H_q=[H_q,(G(94,t)+G(27,t)+G(28,t)+G(29,t)).*tnode(t,61)+gdaa(30,t).*tnode(t,64)+gdbb(30,t).*tstart(64)+r(61,t)==q_zhu_node(t,61)]
    H_q=[H_q,G(95,t).*tnode(t,62)+gdaa(28,t).*tnode(t,61)+gdbb(28,t).*tstart(61)+r(62,t)==q_zhu_node(t,62)] 
    H_q=[H_q,G(96,t).*tnode(t,63)+gdaa(29,t).*tnode(t,61)+gdbb(29,t).*tstart(61)+r(63,t)==q_zhu_node(t,63)]
    H_q=[H_q,(G(97,t)+G(30,t)+G(33,t)).*tnode(t,64)+gdaa(32,t).*tnode(t,33)+gdbb(32,t).*tstart(33)+r(64,t)==q_zhu_node(t,64)]
    H_q=[H_q,G(98,t).*tnode(t,65)+gdaa(64,t).*tnode(t,11)+gdbb(64,t).*tstart(11)+r(65,t)==q_zhu_node(t,65)]
    H_q=[H_q,G(99,t).*tnode(t,66)+gdaa(65,t).*tnode(t,31)+gdbb(65,t).*tstart(31)+r(66,t)==q_zhu_node(t,66)]

for t=2:time
    H_q=[H_q,G(1,t).*tnode(t,1)+gdaa(67,t).*tnode(t,34)+r(1,t)==q_zhu_node(t,1)]
    H_q=[H_q,G(34,t).*tnode(t,2)+gdaa(35,t).*tnode(t,3)+gdbb(35,t).*tnode(t-1,3)+gdaa(36,t).*tnode(t,4)+gdbb(36,t).*tnode(t-1,4)+gdaa(37,t)*tnode(t,5)+gdbb(37,t).*tnode(t-1,5)+gdaa(68,t).*tnode(t,35)+gdbb(68,t).*tnode(t-1,35)+r(2,t)==q_zhu_node(t,2)]
    H_q=[H_q,G(35,t).*tnode(t,3)+gdaa(69,t).*tnode(t,36)+r(3,t)==q_zhu_node(t,3)]
    H_q=[H_q,G(36,t).*tnode(t,4)+gdaa(70,t).*tnode(t,37)+r(4,t)==q_zhu_node(t,4)]
    H_q=[H_q,G(37,t).*tnode(t,5)+gdaa(38,t).*tnode(t,6)+gdbb(38,t).*tnode(t-1,6)+gdaa(39,t).*tnode(t,7)+gdbb(39,t).*tnode(t-1,7)+gdaa(43,t).*tnode(t,11)+gdbb(43,t).*tnode(t-1,11)+gdaa(71,t).*tnode(t,38)+gdbb(71,t).*tnode(t-1,38)+r(5,t)==q_zhu_node(t,5)]
    H_q=[H_q,G(38,t).*tnode(t,6)+gdaa(72,t).*tnode(t,39)+r(6,t)==q_zhu_node(t,6)]
    H_q=[H_q,(G(39,t)+G(66,t)).*tnode(t,7)+gdaa(40,t).*tnode(t,8)+gdbb(40,t).*tnode(t-1,8)+gdaa(41,t).*tnode(t,9)+gdbb(41,t).*tnode(t-1,9)+gdaa(42,t).*tnode(t,10)+gdbb(42,t).*tnode(t-1,10)+gdaa(73,t).*tnode(t,40)+gdbb(73,t).*tnode(t-1,40)+r(7,t)==q_zhu_node(t,7)]
    H_q=[H_q,G(40,t).*tnode(t,8)+gdaa(74,t).*tnode(t,41)+r(8,t)==q_zhu_node(t,8)]
    H_q=[H_q,G(41,t).*tnode(t,9)+gdaa(75,t).*tnode(t,42)+r(9,t)==q_zhu_node(t,9)]
    H_q=[H_q,G(42,t).*tnode(t,10)+gdaa(76,t).* tnode(t,43)+r(10,t)==q_zhu_node(t,10)]
    H_q=[H_q,(G(43,t)+G(64,t)).*tnode(t,11)+gdaa(44,t).*tnode(t,12)+gdbb(44,t).*tnode(t-1,12)+gdaa(45,t).*tnode(t,13)+gdbb(45,t).*tnode(t-1,13)+gdaa(77,t).*tnode(t,44)+gdbb(77,t).*tnode(t-1,44)+r(11,t)==q_zhu_node(t,11)]
    H_q=[H_q,G(44,t).*tnode(t,12)+gdaa(78,t).*tnode(t,45)+r(12,t)==q_zhu_node(t,12)]
    H_q=[H_q,G(45,t).*tnode(t,13)+gdaa(46,t).*tnode(t,14)+gdbb(46,t).*tnode(t-1,14)+r(13,t)==q_zhu_node(t,13)]
    H_q=[H_q,G(46,t).*tnode(t,14)+gdaa(47,t).*tnode(t,15)+gdbb(47,t).*tnode(t-1,15)+gdaa(50,t).*tnode(t,18)+gdbb(50,t).*tnode(t-1,18)+gdaa(51,t).*tnode(t,19)+gdbb(51,t).*tnode(t-1,19)+gdaa(80,t).*tnode(t,47)+gdbb(80,t).*tnode(t-1,47)+r(14,t)==q_zhu_node(t,14)]
    H_q=[H_q,G(47,t).*tnode(t,15)+gdaa(48,t).*tnode(t,16)+gdbb(48,t).*tnode(t-1,16)+gdaa(49,t).*tnode(t,17)+gdbb(49,t).*tnode(t-1,17)+gdaa(81,t).*tnode(t,48)+gdbb(81,t).*tnode(t-1,48)+r(15,t)==q_zhu_node(t,15)]   
    H_q=[H_q,G(48,t).*tnode(t,16)+gdaa(82,t).*tnode(t,49)+r(16,t)==q_zhu_node(t,16)]
    H_q=[H_q,G(49,t).*tnode(t,17)+gdaa(83,t).*tnode(t,50)+r(17,t)==q_zhu_node(t,17)]
    H_q=[H_q,G(50,t).*tnode(t,18)+gdaa(84,t).*tnode(t,51)+r(18,t)==q_zhu_node(t,18)]
    H_q=[H_q,G(51,t)*tnode(t,19)+gdaa(52,t).*tnode(t,20)+gdbb(52,t).*tnode(t-1,20)+gdaa(53,t).*tnode(t,21)+gdbb(53,t).*tnode(t-1,21)+gdaa(54,t).*tnode(t,22)+gdbb(54,t).*tnode(t-1,22)+gdaa(85,t).*tnode(t,52)+gdbb(85,t).*tnode(t-1,52)+r(19,t)==q_zhu_node(t,19)]
    H_q=[H_q,G(52,t).*tnode(t,20)+gdaa(86,t).*tnode(t,53)+r(20,t)==q_zhu_node(t,20)]
    H_q=[H_q,G(53,t).*tnode(t,21)+gdaa(87,t).*tnode(t,54)+r(21,t)==q_zhu_node(t,21)]
    H_q=[H_q,(G(54,t)+G(57,t)).*tnode(t,22)+gdaa(55,t).*tnode(t,23)+gdbb(55,t).*tnode(t-1,23)+gdaa(56,t).*tnode(t,24)+gdbb(56,t).*tnode(t-1,24)+gdaa(88,t).*tnode(t,55)+gdbb(88,t).*tnode(t-1,55)+r(22,t)==q_zhu_node(t,22)]  
    H_q=[H_q,G(55,t).*tnode(t,23)+gdaa(89,t).*tnode(t,56)+r(23,t)==q_zhu_node(t,23)]
    H_q=[H_q,G(56,t).*tnode(t,24)+gdaa(90,t).*tnode(t,57)+r(24,t)==q_zhu_node(t,24)]
    H_q=[H_q,G(60,t).*tnode(t,25)+gdaa(57,t).*tnode(t,22)+gdbb(57,t).*tnode(t-1,22)+gdaa(58,t).*tnode(t,26)+gdbb(58,t).*tnode(t-1,26)+gdaa(59,t).*tnode(t,27)+gdbb(59,t).*tnode(t-1,27)+gdaa(91,t).*tnode(t,58)+gdbb(91,t).*tnode(t-1,58)+r(25,t)==q_zhu_node(t,25)]
    H_q=[H_q,G(58,t).*tnode(t,26)+gdaa(92,t).*tnode(t,59)+r(26,t)==q_zhu_node(t,26)]
    H_q=[H_q,G(59,t).*tnode(t,27)+gdaa(93,t).*tnode(t,60)+r(27,t)==q_zhu_node(t,27)]  
    H_q=[H_q,G(63,t).*tnode(t,28)+gdaa(60,t).*tnode(t,25)+gdbb(60,t).*tnode(t-1,25)+gdaa(61,t).*tnode(t,29)+gdbb(61,t).*tnode(t-1,29)+gdaa(62,t).*tnode(t,30)+gdbb(62,t).*tnode(t-1,30)+gdaa(94,t).*tnode(t,61)+gdbb(94,t).*tnode(t-1,61)+r(28,t)==q_zhu_node(t,28)]
    H_q=[H_q,G(61,t).*tnode(t,29)+gdaa(95,t).*tnode(t,62)+r(29,t)==q_zhu_node(t,29)]
    H_q=[H_q,G(62,t).*tnode(t,30)+gdaa(96,t).*tnode(t,63)+r(30,t)==q_zhu_node(t,30)] 
    H_q=[H_q,G(65,t).*tnode(t,31)+gdaa(63,t).*tnode(t,28)+gdbb(63,t).*tnode(t-1,28)+gdaa(66,t).*tnode(t,7)+gdbb(66,t).*tnode(t-1,7)+gdaa(97,t).*tnode(t,64)+gdbb(97,t).*tnode(t-1,64)+r(31,t)==q_zhu_node(t,31)]  
    H_q=[H_q,G(31,t).*tnode(t,32)+gdaa(98,t).*tnode(t,65)+r(32,t)==q_zhu_node(t,32)]
    H_q=[H_q,G(32,t).*tnode(t,33)+gdaa(99,t).*tnode(t,66)+r(33,t)==q_zhu_node(t,33)]
    H_q=[H_q,G(67,t).*tnode(t,34)+gdaa(34,t).*tnode(t,2)+gdbb(34,t).*tnode(t-1,2)+r(34,t)==q_zhu_node(t,34)]  
    H_q=[H_q,(G(68,t)+G(2,t)+G(3,t)+G(4,t)).*tnode(t,35)+gdaa(1,t).*tnode(t,1)+gdbb(1,t).*tnode(t-1,1)+r(35,t)==q_zhu_node(t,35)]  
    H_q=[H_q,G(69,t).*tnode(t,36)+gdaa(2,t).*tnode(t,35)+gdbb(2,t).*tnode(t-1,35)+r(36,t)==q_zhu_node(t,36)]  
    H_q=[H_q,G(70,t).*tnode(t,37)+gdaa(3,t).*tnode(t,35)+gdbb(3,t).*tnode(t-1,35)+r(37,t)==q_zhu_node(t,37)]  
    H_q=[H_q,(G(71,t)+G(5,t)+G(6,t)+G(10,t)).*tnode(t,38)+gdaa(4,t).*tnode(t,35)+gdbb(4,t).*tnode(t-1,35)+r(38,t)==q_zhu_node(t,38)]
    H_q=[H_q,G(72,t).*tnode(t,39)+gdaa(5,t).*tnode(t,38)+gdbb(5,t).*tnode(t-1,38)+r(39,t)==q_zhu_node(t,39)]  
    H_q=[H_q,(G(73,t)+G(7,t)+G(8,t)+G(9,t)).*tnode(t,40)+gdaa(6,t).*tnode(t,38)+gdbb(6,t).*tnode(t-1,38)+gdaa(33,t).*tnode(t,64)+gdbb(33,t).*tnode(t-1,64)+r(40,t)==q_zhu_node(t,40)]  
    H_q=[H_q,G(74,t).*tnode(t,41)+gdaa(7,t).*tnode(t,40)+gdbb(7,t).*tnode(t-1,40)+r(41,t)==q_zhu_node(t,41)]  
    H_q=[H_q,G(75,t).*tnode(t,42)+gdaa(8,t).*tnode(t,40)+gdbb(8,t).*tnode(t-1,40)+r(42,t)==q_zhu_node(t,42)]  
    H_q=[H_q,G(76,t).*tnode(t,43)+gdaa(9,t).*tnode(t,40)+gdbb(9,t).*tnode(t-1,40)+r(43,t)==q_zhu_node(t,43)] 
    H_q=[H_q,(G(77,t)+G(11,t)+G(12,t)).*tnode(t,44)+gdaa(10,t).*tnode(t,38)+gdbb(10,t).*tnode(t-1,38)+gdaa(31,t).*tnode(t,32)+gdbb(31,t).*tnode(t-1,32)+r(44,t)==q_zhu_node(t,44)]  
    H_q=[H_q,G(78,t).*tnode(t,45)+gdaa(11,t).*tnode(t,44)+gdbb(11,t).*tnode(t-1,44)+r(45,t)==q_zhu_node(t,45)]  
    H_q=[H_q,(G(79,t)+G(13,t)).*tnode(t,46)+gdaa(12,t).*tnode(t,44)+gdbb(12,t).*tnode(t-1,44)+r(46,t)==q_zhu_node(t,46)]  
    H_q=[H_q,(G(80,t)+G(14,t)+G(18,t)+G(17,t)).*tnode(t,47)+gdaa(13,t).*tnode(t,46)+gdbb(13,t).*tnode(t-1,46)+r(47,t)==q_zhu_node(t,47)] 
    H_q=[H_q,(G(81,t)+G(15,t)+G(16,t)).*tnode(t,48)+gdaa(14,t).*tnode(t,47)+gdbb(14,t).*tnode(t-1,47)+r(48,t)==q_zhu_node(t,48)]  
    H_q=[H_q,G(82,t).*tnode(t,49)+gdaa(15,t).*tnode(t,48)+gdbb(15,t).*tnode(t-1,48)+r(49,t)==q_zhu_node(t,49)]  
    H_q=[H_q,G(83,t).*tnode(t,50)+gdaa(16,t).*tnode(t,48)+gdbb(16,t).*tnode(t-1,48)+r(50,t)==q_zhu_node(t,50)] 
    H_q=[H_q,G(84,t).*tnode(t,51)+gdaa(17,t).*tnode(t,47)+gdbb(17,t).*tnode(t-1,47)+r(51,t)==q_zhu_node(t,51)]
    H_q=[H_q,(G(85,t)+G(19,t)+G(20,t)+G(21,t)).*tnode(t,52)+gdaa(18,t).*tnode(t,47)+gdbb(18,t).*tnode(t-1,47)+r(52,t)==q_zhu_node(t,52)]
    H_q=[H_q,G(86,t).*tnode(t,53)+gdaa(19,t).*tnode(t,52)+gdbb(19,t).*tnode(t-1,52)+r(53,t)==q_zhu_node(t,53)] 
    H_q=[H_q,G(87,t).*tnode(t,54)+gdaa(20,t).*tnode(t,52)+gdbb(20,t).*tnode(t-1,52)+r(54,t)==q_zhu_node(t,54)]
    H_q=[H_q,(G(88,t)+G(23,t)+G(22,t)).*tnode(t,55)+gdaa(21,t).*tnode(t,52)+gdbb(21,t).*tnode(t-1,52)+gdaa(24,t).*tnode(t,58)+gdbb(24,t).*tnode(t-1,58)+r(55,t)==q_zhu_node(t,55)]  
    H_q=[H_q,G(89,t).*tnode(t,56)+gdaa(22,t).*tnode(t,55)+gdbb(22,t).*tnode(t-1,55)+r(56,t)==q_zhu_node(t,56)] 
    H_q=[H_q,G(90,t).*tnode(t,57)+gdaa(23,t).*tnode(t,55)+gdbb(23,t).*tnode(t-1,55)+r(57,t)==q_zhu_node(t,57)]
    H_q=[H_q,(G(91,t)+G(24,t)+G(25,t)+G(26,t)).*tnode(t,58)+gdaa(27,t).*tnode(t,61)+gdbb(27,t).*tnode(t-1,61)+r(58,t)==q_zhu_node(t,58)]
    H_q=[H_q,G(92,t).*tnode(t,59)+gdaa(25,t).*tnode(t,58)+gdbb(25,t).*tnode(t-1,58)+r(59,t)==q_zhu_node(t,59)] 
    H_q=[H_q,G(93,t).*tnode(t,60)+gdaa(26,t).*tnode(t,58)+gdbb(26,t).*tnode(t-1,58)+r(60,t)==q_zhu_node(t,60)]
    H_q=[H_q,(G(94,t)+G(27,t)+G(28,t)+G(29,t)).*tnode(t,61)+gdaa(30,t).*tnode(t,64)+gdbb(30,t).*tnode(t-1,64)+r(61,t)==q_zhu_node(t,61)]
    H_q=[H_q,G(95,t).*tnode(t,62)+gdaa(28,t).*tnode(t,61)+gdbb(28,t).*tnode(t-1,61)+r(62,t)==q_zhu_node(t,62)] 
    H_q=[H_q,G(96,t).*tnode(t,63)+gdaa(29,t).*tnode(t,61)+gdbb(29,t).*tnode(t-1,61)+r(63,t)==q_zhu_node(t,63)]
    H_q=[H_q,(G(97,t)+G(30,t)+G(33,t)).*tnode(t,64)+gdaa(32,t).*tnode(t,33)+gdbb(32,t).*tnode(t-1,33)+r(64,t)==q_zhu_node(t,64)]
    H_q=[H_q,G(98,t).*tnode(t,65)+gdaa(64,t).*tnode(t,11)+gdbb(64,t).*tnode(t-1,11)+r(65,t)==q_zhu_node(t,65)]
    H_q=[H_q,G(99,t).*tnode(t,66)+gdaa(65,t).*tnode(t,31)+gdbb(65,t).*tnode(t-1,31)+r(66,t)==q_zhu_node(t,66)]

end


DHS_constraint = DHS_constraint + H_q;

%节点温度约束
DHS_node_stemp_limit=[];
model.Tmax =  ones(time,1) * model.node(:,4)';
model.Tmin =  ones(time,1) * model.node(:,3)';
DHS_node_stemp_limit = [DHS_node_stemp_limit,model.Tmin <=tnode];  %330
DHS_node_stemp_limit = [DHS_node_stemp_limit,tnode <= model.Tmax];
DHS_constraint = DHS_constraint + H_q+DHS_node_stemp_limit;

%最终时刻约束
%end of horizon constraint
% DHS_end=[]
% DHS_end = [DHS_end,model.tn<=tnode(time,:)];
% DHS_constraint = DHS_constraint+DHS_end;



% %% 节点水力平衡约束
% DHS_node_hy=[]
% DHS_node_hy=[DHS_node_hy,(model_node.A1-model_node.A2)*G==0];
% DHS_node_hy=[DHS_node_hy,(model_node.A1-model_node.A2)*G==0];
% DHS_hy=[]
% for t=1:time
%     for i=1:hpipe_num
%     DHS_hy=[DHS_hy,0.8<=m(i,t)<=1.2];  %495
%     end
% end
% DHS_constraint = DHS_constraint + H_q+DHS_node_stemp_limit+DHS_node_hy+DHS_hy;

%% EPS constraint
EPS_constraint=[];
E_p=[];  %节点功率平衡约束
jd_2pi=[]; %节点相角约束

%节点角度约束
for t=1:time
    for i=1:ebus_num
        jd_2pi=[jd_2pi,-6.28<=jd(t,i)<=6.28];
    end
end
%选定参考节点
ck=[]
for t=1:time
    ck=[ck,jd(t,1)==0]
end


chp_yw=zeros(3,33)
chp_yw(1,1)=1
chp_yw(2,32)=1
chp_yw(3,33)=1
%支路潮流计算:
E_branch=[]
M=100*mpc_branch.o*mpc_bus.A
p_branch=M*jd'  
for i=1:ebranch_num
    mpc.branch(i,14)=32
end

branchmax =  ones(time,1) * mpc.branch(:,14)';
branchmin = -ones(time,1) * mpc.branch(:,14)';
E_branch=[E_branch,branchmin<=p_branch']
E_branch=[E_branch,p_branch'<=branchmax]
%支路节点关联矩阵
H=zeros(ebus_num,ebranch_num)
for i=1:ebus_num
    for j=1:ebranch_num
        if mpc.branch(j,1)==i
            H(i,j)=1
        else if mpc.branch(j,2)==i
                H(i,j)=-1
            end
        end
    end
end
b=H*M
p_sumbus=b*jd'
eeload=mpc.load.*8
p_zhu_bus=p_chp*chp_yw-eeload
%节点能量平衡-EPS
for t=1:time
    for i=1:33
        E_p=[E_p,p_sumbus(i,t)==p_zhu_bus(t,i)]
    end
end


EPS_constraint= E_p+jd_2pi+ck+E_branch

%% Objective function

for t = 1: time
    for k = 1:chp_num
        cost = cost + model.chpcost(k,1) + model.chpcost(k,2) * p_chp(t,k) + model.chpcost(k,4) * q_chp(t,k) + ...
            model.chpcost(k,3) * p_chp(t,k)^2 + model.chpcost(k,5) * q_chp(t,k)^2 + model.chpcost(k,6) * q_chp(t,k) * p_chp(t,k);
    end
end

% for t = 1: time
%     for k = 1:chp_num
%         cost = cost + model.chpcost(k,1) + model.chpcost(k,4) * q_chp(t,k) + ...
%             + model.chpcost(k,5) * q_chp(t,k)^2 ;
%     end
% end


%% Solver
objective = cost;
constraints = DHS_constraint+CHP_constraint+ EPS_constraint; 
options = sdpsettings('verbose',1,'debug',1,'savesolveroutput',1,'savesolverinput',1);
sol = optimize(constraints,objective,options);
alter=1;

% %  c1=z1*model_node.A1T-y1*model_node.A1T
% %  c2=-x1*model_node.A1T
% %  c=c1+c2
% %  cc1=model_node.A1*model_node.A1T
% %  cc2=-model_node.A2*model_node.A1T