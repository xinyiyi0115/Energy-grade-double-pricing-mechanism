clc
clear all
%% parameters
timeh=25;        %time
model.set=50;
dt=3600

%% 1. input parameters
% 读入参数  initial parameters input
define_heat_inputs_industrial_318;

% 根据流量读入管道时延参数、温度计算参数 calculate pipeline
[model_pipe,model_node] = calculate_pipe_para_c(model); %子函数结果导入

% 参数命名 calculate size
[chp_num, null_num] = size (model.chp);
[hnode_num, null_num] = size (model.node);
[hpipe_num, null_num] = size (model.pipe);

%设置待求变量 define varaibles
q_chp = sdpvar(timeh,3,'full');   %chp产热
cost = 0;    %成本初始值为0
tnode=sdpvar (timeh, hnode_num,'full');  %nodal tem
topipe=sdpvar(timeh,hpipe_num,'full'); %pipeline outlet tem
% m=sdpvar(hpipe_num,timeh,'full')
m=[1.19962716007219	1.19948528799756	1.19955972223118	1.19955969949280	1.19956072603904	1.19949640276693	1.19854308283307	1.11626616191563	0.947489381548397	0.806920513454559	0.801168317210849	0.800664417051307	0.800662838222110	0.801159357657039	0.806649814710826	0.945882596470132	1.11471042457740	1.19853249245717	1.19949446669217	1.19955970570281	1.19955969023199	1.19956075632307	1.19948628987131	1.19962008223260	1.19994921297388
1.19963025699256	1.19956676835241	1.19957088092138	1.19957085453029	1.19957185871816	1.19956895752785	1.19961396233776	1.19965988303047	1.19968600928827	1.19970536648603	1.19969938696052	1.19969128023110	1.19969029869871	1.19969754992527	1.19970375509691	1.19968475195458	1.19965761441606	1.19961005266257	1.19956575106086	1.19957085415261	1.19957084234875	1.19957190191504	1.19956087536294	1.19962327420694	1.19995122272080
1.19962870753237	1.19952602717499	1.19956530057628	1.19956527601154	1.19956629137860	1.19953267914739	1.19907852158541	1.15796302147305	1.07358769441833	1.00331293897029	1.00043385108569	1.00017784764121	1.00017656746041	1.00042845279115	1.00317678390387	1.07278367321236	1.15718401849673	1.19907127155987	1.19953010787652	1.19956527892771	1.19956526529037	1.19956632811906	1.19952358161713	1.19962167721977	1.19995021684734
0.999923730242888	0.999832756546262	0.999891770608225	0.999887477437154	0.999887905151413	0.999862430303853	0.995168163460082	0.952834075563827	0.913899643090835	0.879286363994153	0.864648900788785	0.850619777499811	0.850558324540083	0.864533114013573	0.879075952515659	0.913434989887694	0.952376544147298	0.994982459198424	0.999867894410338	0.999890980403031	0.999887267004146	0.999888134782144	0.999857357835969	0.999926155909039	1.02676088650346
0.999745023693195	0.999725571703495	0.999719288243606	0.999722359743735	0.999723038444233	0.999710821258597	1.01109192786417	1.05729878010082	1.00533298616822	0.968645112912964	1.00701860918343	1.04893322961617	1.04912428217999	1.00736309376642	0.968997862276247	1.00509647172685	1.05710168560704	1.01168322823883	0.999705030001874	0.999720169918247	0.999722592891224	0.999722809122742	0.999706470174196	0.999737433733751	1.02661685999220
0.999912301247495	0.999866188163714	0.999894346563961	0.999893817608113	0.999894241743656	0.999872422349523	0.995163671306772	0.952833349777043	0.913895395813039	0.879283009851367	0.864651595610864	0.850623537446304	0.850560593820378	0.864532932624986	0.879074068704962	0.913437008377653	0.952379290772283	0.994974341011386	0.999871189302799	0.999893553488827	0.999893589403081	0.999894485996378	0.999867194678284	0.999908151070569	1.02679278791025
0.999768332999897	0.999733047350516	0.999740047176710	0.999741615867099	0.999742271734903	0.999727547671929	0.996812788642615	0.953096334437836	0.914171961157414	0.879537557840204	0.864746927145647	0.850642857417225	0.850582525096351	0.864629402023636	0.879333109671852	0.913724125186371	0.952648307656225	0.996582763602940	0.999724185759394	0.999740720197656	0.999741804022035	0.999742100446421	0.999723053836997	0.999762929172854	1.02663010487242
0.800045987559363	0.800052755707007	0.800057426719971	0.800057360316513	0.800057438158502	0.800053932644562	0.800039755051405	0.800068249466714	0.800062299696422	0.800063084329049	0.800099166278675	0.800231854348547	0.800236296357990	0.800100819423153	0.800063713680488	0.800062625376926	0.800068896594692	0.800040125465921	0.800054042860686	0.800057434076169	0.800057362369870	0.800057438054783	0.800053457645594	0.800045658723336	0.853450103791824
1.01074194216220	0.883312075616830	0.901090644318537	0.901090807943847	0.901089346219619	0.883308916758831	0.865529990439784	0.829986166550692	0.812285552019673	0.802809869570302	0.802736745931813	0.802680675944473	0.802691503644160	0.802768903654096	0.802832429310443	0.812289011434535	0.829992625981410	0.865536763332835	0.883311263732460	0.901090623482999	0.901090805076048	0.901088872620246	0.883320943596285	1.01075318404249	0.918409025661037
0.870277973091912	0.827805863008554	0.833735166584432	0.833735176857230	0.833734741510480	0.827805594680925	0.821869834179138	0.810040889159648	0.804136717802448	0.800978680074409	0.800978360161332	0.801048128878801	0.801054699451658	0.800990181498411	0.800986619555416	0.804138088061071	0.810043473721873	0.821872338753166	0.827806450482883	0.833735164543385	0.833735177270201	0.833734583574876	0.827809286960764	0.870281501161325	0.875103078413164
1.19962716007219	1.19948528799756	1.19955972223118	1.19955969949281	1.19956072603904	1.19949640276693	1.19854308283307	1.11626616191563	0.947489381548397	0.806920513454558	0.801168317210849	0.800664417051307	0.800662838222110	0.801159357657039	0.806649814710826	0.945882596470132	1.11471042457740	1.19853249245717	1.19949446669217	1.19955970570281	1.19955969023199	1.19956075632307	1.19948628987131	1.19962008223260	1.19994921297388
1.19963025699256	1.19956676835241	1.19957088092138	1.19957085453030	1.19957185871816	1.19956895752785	1.19961396233776	1.19965988303047	1.19968600928827	1.19970536648603	1.19969938696052	1.19969128023110	1.19969029869871	1.19969754992527	1.19970375509691	1.19968475195458	1.19965761441606	1.19961005266257	1.19956575106086	1.19957085415261	1.19957084234875	1.19957190191504	1.19956087536294	1.19962327420694	1.19995122272080
1.19962870753237	1.19952602717499	1.19956530057628	1.19956527601154	1.19956629137860	1.19953267914739	1.19907852158541	1.15796302147305	1.07358769441833	1.00331293897029	1.00043385108569	1.00017784764121	1.00017656746041	1.00042845279115	1.00317678390387	1.07278367321236	1.15718401849673	1.19907127155987	1.19953010787652	1.19956527892771	1.19956526529037	1.19956632811906	1.19952358161713	1.19962167721977	1.19995021684734
0.999923730242888	0.999832756546262	0.999891770608225	0.999887477437154	0.999887905151414	0.999862430303853	0.995168163460082	0.952834075563827	0.913899643090835	0.879286363994153	0.864648900788785	0.850619777499811	0.850558324540083	0.864533114013573	0.879075952515659	0.913434989887694	0.952376544147298	0.994982459198424	0.999867894410338	0.999890980403031	0.999887267004146	0.999888134782144	0.999857357835969	0.999926155909039	1.02676088650346
0.999745023693195	0.999725571703495	0.999719288243606	0.999722359743736	0.999723038444233	0.999710821258597	1.01109192786417	1.05729878010082	1.00533298616822	0.968645112912964	1.00701860918343	1.04893322961617	1.04912428217999	1.00736309376642	0.968997862276247	1.00509647172685	1.05710168560704	1.01168322823883	0.999705030001874	0.999720169918247	0.999722592891224	0.999722809122742	0.999706470174196	0.999737433733751	1.02661685999220
0.999912301247495	0.999866188163714	0.999894346563961	0.999893817608114	0.999894241743656	0.999872422349523	0.995163671306772	0.952833349777043	0.913895395813039	0.879283009851367	0.864651595610863	0.850623537446304	0.850560593820378	0.864532932624986	0.879074068704962	0.913437008377653	0.952379290772283	0.994974341011386	0.999871189302799	0.999893553488827	0.999893589403081	0.999894485996378	0.999867194678284	0.999908151070569	1.02679278791025
0.999768332999897	0.999733047350516	0.999740047176710	0.999741615867100	0.999742271734903	0.999727547671929	0.996812788642615	0.953096334437836	0.914171961157414	0.879537557840204	0.864746927145647	0.850642857417225	0.850582525096351	0.864629402023636	0.879333109671852	0.913724125186371	0.952648307656225	0.996582763602939	0.999724185759394	0.999740720197656	0.999741804022035	0.999742100446421	0.999723053836997	0.999762929172854	1.02663010487242
0.800045987559363	0.800052755707007	0.800057426719971	0.800057360316514	0.800057438158502	0.800053932644562	0.800039755051405	0.800068249466714	0.800062299696422	0.800063084329049	0.800099166278675	0.800231854348547	0.800236296357990	0.800100819423154	0.800063713680488	0.800062625376926	0.800068896594692	0.800040125465921	0.800054042860686	0.800057434076169	0.800057362369870	0.800057438054783	0.800053457645594	0.800045658723336	0.853450103791824
1.01074194216220	0.883312075616830	0.901090644318537	0.901090807943846	0.901089346219619	0.883308916758831	0.865529990439784	0.829986166550692	0.812285552019673	0.802809869570302	0.802736745931813	0.802680675944473	0.802691503644160	0.802768903654096	0.802832429310443	0.812289011434535	0.829992625981410	0.865536763332835	0.883311263732460	0.901090623482999	0.901090805076048	0.901088872620246	0.883320943596285	1.01075318404249	0.918409025661037
0.870277973091912	0.827805863008554	0.833735166584432	0.833735176857230	0.833734741510480	0.827805594680925	0.821869834179138	0.810040889159648	0.804136717802448	0.800978680074409	0.800978360161332	0.801048128878801	0.801054699451658	0.800990181498411	0.800986619555416	0.804138088061071	0.810043473721873	0.821872338753166	0.827806450482883	0.833735164543385	0.833735177270201	0.833734583574876	0.827809286960764	0.870281501161325	0.875103078413164
1.19962716007219	1.19948528799756	1.19955972223118	1.19955969949280	1.19956072603904	1.19949640276693	1.19854308283307	1.11626616191563	0.947489381548397	0.806920513454558	0.801168317210849	0.800664417051306	0.800662838222110	0.801159357657039	0.806649814710826	0.945882596470132	1.11471042457740	1.19853249245717	1.19949446669217	1.19955970570281	1.19955969023199	1.19956075632307	1.19948628987131	1.19962008223260	1.19994921297388
1.19963025699256	1.19956676835241	1.19957088092138	1.19957085453028	1.19957185871816	1.19956895752785	1.19961396233776	1.19965988303047	1.19968600928827	1.19970536648603	1.19969938696052	1.19969128023110	1.19969029869871	1.19969754992527	1.19970375509692	1.19968475195458	1.19965761441606	1.19961005266257	1.19956575106086	1.19957085415261	1.19957084234875	1.19957190191504	1.19956087536294	1.19962327420694	1.19995122272080
0.999999787056583	0.999999758573598	0.999999828891973	0.999999828896856	0.999999828399837	0.999999765207796	0.999999346451668	0.999999017807943	0.999998996327816	0.999998959201184	0.999998777969392	0.999998588079693	0.999998590029943	0.999998782221148	0.999998963141669	0.999999000992710	0.999999024592566	0.999999353906131	0.999999769014309	0.999999828893506	0.999999828897503	0.999999828389338	0.999999769556161	0.999999792876882	0.999998280320047
0.999999437659231	0.999999505925253	0.999999568675624	0.999999568313444	0.999999568329267	0.999999516632832	0.999999169134784	0.999999181628206	0.999999130099869	0.999999087371711	0.999999105583400	0.999999126663734	0.999999129646055	0.999999111662648	0.999999092867360	0.999999134079392	0.999999187844796	0.999999178276735	0.999999520021047	0.999999568721848	0.999999568328182	0.999999568301655	0.999999516982788	0.999999443475348	0.999998652859200
0.997404635735669	0.997409523582941	0.997408839637664	0.997408839962545	0.997408840551606	0.997409525999339	0.997410471305030	0.997413022357706	0.997413620459516	0.997414385991715	0.997415870521719	0.997417375458668	0.997417384836546	0.997415884127131	0.997414400842496	0.997413632116697	0.997413030356424	0.997410486304965	0.997409527847548	0.997408841743314	0.997408840563776	0.997408839946446	0.997409523978151	0.997404636635150	0.997404110670310
0.870277973091912	0.827805863008554	0.833735166584432	0.833735176857230	0.833734741510480	0.827805594680925	0.821869834179138	0.810040889159648	0.804136717802448	0.800978680074409	0.800978360161332	0.801048128878801	0.801054699451658	0.800990181498411	0.800986619555416	0.804138088061071	0.810043473721873	0.821872338753166	0.827806450482883	0.833735164543385	0.833735177270201	0.833734583574876	0.827809286960764	0.870281501161325	0.875103078413164
1.01074194216220	0.883312075616830	0.901090644318537	0.901090807943847	0.901089346219619	0.883308916758831	0.865529990439784	0.829986166550692	0.812285552019673	0.802809869570302	0.802736745931813	0.802680675944473	0.802691503644160	0.802768903654096	0.802832429310443	0.812289011434535	0.829992625981410	0.865536763332835	0.883311263732460	0.901090623482999	0.901090805076048	0.901088872620246	0.883320943596285	1.01075318404249	0.918409025661037
0.999923730242888	0.999832756546262	0.999891770608225	0.999887477437152	0.999887905151414	0.999862430303853	0.995168163460082	0.952834075563827	0.913899643090835	0.879286363994153	0.864648900788785	0.850619777499811	0.850558324540083	0.864533114013573	0.879075952515659	0.913434989887694	0.952376544147298	0.994982459198424	0.999867894410338	0.999890980403031	0.999887267004146	0.999888134782144	0.999857357835969	0.999926155909039	1.02676088650346
0.999745023693195	0.999725571703495	0.999719288243606	0.999722359743736	0.999723038444233	0.999710821258597	1.01109192786417	1.05729878010082	1.00533298616822	0.968645112912964	1.00701860918343	1.04893322961617	1.04912428217999	1.00736309376642	0.968997862276247	1.00509647172685	1.05710168560704	1.01168322823883	0.999705030001874	0.999720169918247	0.999722592891224	0.999722809122742	0.999706470174196	0.999737433733751	1.02661685999220
0.999912301247495	0.999866188163714	0.999894346563961	0.999893817608113	0.999894241743656	0.999872422349523	0.995163671306772	0.952833349777043	0.913895395813039	0.879283009851367	0.864651595610864	0.850623537446304	0.850560593820378	0.864532932624986	0.879074068704962	0.913437008377653	0.952379290772283	0.994974341011386	0.999871189302799	0.999893553488827	0.999893589403081	0.999894485996378	0.999867194678284	0.999908151070569	1.02679278791025
0.999768332999897	0.999733047350516	0.999740047176710	0.999741615867100	0.999742271734903	0.999727547671929	0.996812788642615	0.953096334437836	0.914171961157414	0.879537557840204	0.864746927145647	0.850642857417225	0.850582525096351	0.864629402023636	0.879333109671852	0.913724125186371	0.952648307656225	0.996582763602939	0.999724185759394	0.999740720197656	0.999741804022035	0.999742100446421	0.999723053836997	0.999762929172854	1.02663010487242]
%CHP1 的为第一列，CHP2为第二列
Ta = model.ta;   %外部温度

%% CHP unit constraint
%约束初始化 constraint 
CHP_constraint = [];
CHP_pb=[];
%可行域约束 feasible region
for t=1:timeh
CHP_pb=[CHP_pb,q_chp(t,1)>=0];
CHP_pb=[CHP_pb,q_chp(t,1)<=60]
end
for t=1:timeh
CHP_pb=[CHP_pb,q_chp(t,2)>=0];
CHP_pb=[CHP_pb,q_chp(t,2)<=60]
end
for t=1:timeh
CHP_pb=[CHP_pb,q_chp(t,3)>=0];
CHP_pb=[CHP_pb,q_chp(t,3)<=60]
end

CHP_constraint = CHP_constraint + CHP_pb
%% DHS constraint
DHS_constraint=[];
H_q=[]; %节点热力平衡
%求C矩阵 calculate matrices
model.pipemass=2*model.pipemass
model_node.GC=zeros(hpipe_num,hpipe_num)
% gdaa=sdpvar(hpipe_num,timeh,'full')
% G=sdpvar(hpipe_num,timeh,'full')
% gdbb=sdpvar(hpipe_num,timeh,'full')
% rmm=sdpvar(hpipe_num,timeh,'full')
gdaa=ones(hpipe_num,timeh)
G=ones(hpipe_num,timeh)
gdbb=ones(hpipe_num,timeh)
rmm=ones(hpipe_num,timeh)
for i=1:hpipe_num
    for t=1:timeh
    gdaa(i,t)=-model.water_c /1e6.*model.pipemass(i,1).*m(i,t).*exp(-(model.pipe(i,6).*model.pipe(i,3))/(model.water_c.*model.pipemass(i,1).*m(i,t))).*(1-model.water_dens.*(3.14/4).*model.pipe(i,4)^2.*model.pipe(i,3)/(m(i,t).*model.pipemass(i,1).*dt));
    G(i,t)=model.water_c / 1e6.*model.pipemass(i,1).*m(i,t);
    gdbb(i,t)=-model.water_c /1e6.*model.pipemass(i,1).*m(i,t).*exp(-(model.pipe(i,6).*model.pipe(i,3))/(model.water_c.*model.pipemass(i,1).*m(i,t))).*(model.water_dens.*(3.14/4).*model.pipe(i,4)^2.*model.pipe(i,3)/(m(i,t).*model.pipemass(i,1).*dt));
    end
end

for i=1:hpipe_num
    for t=1:timeh
    rmm(i,t)=model.water_c / 1e6.*model.pipemass(i,1).*m(i,t).*(exp(-(model.pipe(i,6).*model.pipe(i,3))/(model.water_c.*model.pipemass(i,1).*m(i,t)))-1).*model.ta(1,t)
    end
end

%节点注入热量  heat input
chp_q_yw=zeros(chp_num,model_node.num)
for i=1:model_node.num
    for j=1:chp_num
      if model.chp_a(j,1)==i
          chp_q_yw(j,i)=1
      end
    end
end
hload=model.load*0.9
q_zhu_node=q_chp*chp_q_yw-hload(1:timeh,:)  %QG-QD
%节点热能平衡约束 heat nodal balance& temperature mixing
t=1
H_q=[H_q,q_zhu_node(t,1)==rmm(21,t)+G(1,t).*tnode(t,1)+gdaa(21,t).*tnode(t,12)+gdbb(21,t).*model.t0(12)]
H_q=[H_q,q_zhu_node(t,2)==rmm(22,t)+G(2,t).*tnode(t,2)+gdaa(22,t).*tnode(t,13)+gdbb(22,t).*model.t0(13)]
H_q=[H_q,q_zhu_node(t,3)==rmm(13,t)+(G(11,t)+G(12,t)).*tnode(t,3)+gdaa(13,t).*tnode(t,4)+gdbb(13,t).*model.t0(4)]
H_q=[H_q,q_zhu_node(t,4)==rmm(14,t)+rmm(15,t)+rmm(16,t)+rmm(17,t)+(G(13,t)+G(18,t)).*tnode(t,4)+gdaa(14,t).*tnode(t,8)+gdaa(15,t).*tnode(t,9)+gdaa(16,t).*tnode(t,10)+gdaa(17,t).*tnode(t,11)+gdbb(14,t).*model.t0(8)+gdbb(15,t).*model.t0(9)+gdbb(16,t).*model.t0(10)+gdbb(17,t).*model.t0(11)]
H_q=[H_q,q_zhu_node(t,5)==rmm(18,t)+rmm(19,t)+G(20,t).*tnode(t,5)+gdaa(18,t).*tnode(t,4)+gdaa(19,t).*tnode(t,7)+gdbb(18,t).*model.t0(4)+gdbb(19,t).*model.t0(7)]
H_q=[H_q,q_zhu_node(t,6)==rmm(26,t)+G(10,t).*tnode(t,6)+gdaa(26,t).*tnode(t,17)+gdbb(26,t).*model.t0(17)]
H_q=[H_q,q_zhu_node(t,7)==rmm(27,t)+G(19,t).*tnode(t,7)+gdaa(27,t).*tnode(t,18)+gdbb(27,t).*model.t0(18)]
H_q=[H_q,q_zhu_node(t,8)==rmm(28,t)+G(14,t).*tnode(t,8)+gdaa(28,t).*tnode(t,19)+gdbb(28,t).*model.t0(19)]
H_q=[H_q,q_zhu_node(t,9)==rmm(29,t)+G(15,t).*tnode(t,9)+gdaa(29,t).*tnode(t,20)+gdbb(29,t).*model.t0(20)]
H_q=[H_q,q_zhu_node(t,10)==rmm(30,t)+G(16,t).*tnode(t,10)+gdaa(30,t).*tnode(t,21)+gdbb(30,t).*model.t0(21)]
H_q=[H_q,q_zhu_node(t,11)==rmm(31,t)+G(17,t).*tnode(t,11)+gdaa(31,t).*tnode(t,22)+gdbb(31,t).*model.t0(22)]
H_q=[H_q,q_zhu_node(t,12)==rmm(11,t)+G(21,t).*tnode(t,12)+gdaa(11,t).*tnode(t,3)+gdbb(11,t).*model.t0(3)]
H_q=[H_q,q_zhu_node(t,13)==rmm(12,t)+G(22,t).*tnode(t,13)+gdaa(12,t).*tnode(t,3)+gdbb(12,t).*model.t0(3)]
H_q=[H_q,q_zhu_node(t,14)==rmm(1,t)+rmm(2,t)+G(3,t).*tnode(t,14)+gdaa(1,t).*tnode(t,1)+gdaa(2,t).*tnode(t,2)+gdbb(1,t).*model.t0(1)+gdbb(2,t).*model.t0(2)]
H_q=[H_q,q_zhu_node(t,15)==rmm(8,t)+rmm(3,t)+(G(4,t)+G(5,t)+G(6,t)+G(7,t)).*tnode(t,15)+gdaa(3,t).*tnode(t,14)+gdaa(8,t).*tnode(t,16)+gdbb(3,t).*model.t0(14)+gdbb(8,t).*model.t0(16)]
H_q=[H_q,q_zhu_node(t,16)==rmm(10,t)+(G(8,t)+G(9,t)+G(25,t)).*tnode(t,16)+gdaa(10,t).*tnode(t,6)+gdbb(10,t).*model.t0(6)]
H_q=[H_q,q_zhu_node(t,17)==rmm(20,t)+G(26,t).*tnode(t,17)+gdaa(20,t).*tnode(t,5)+gdbb(20,t).*model.t0(5)]
H_q=[H_q,q_zhu_node(t,18)==rmm(9,t)+G(27,t).*tnode(t,18)+gdaa(9,t).*tnode(t,16)+gdbb(9,t).*model.t0(16)]
H_q=[H_q,q_zhu_node(t,19)==rmm(4,t)+G(28,t).*tnode(t,19)+gdaa(4,t).*tnode(t,15)+gdbb(4,t).*model.t0(15)]
H_q=[H_q,q_zhu_node(t,20)==rmm(5,t)+G(29,t).*tnode(t,20)+gdaa(5,t).*tnode(t,15)+gdbb(5,t).*model.t0(15)]
H_q=[H_q,q_zhu_node(t,21)==rmm(6,t)+G(30,t).*tnode(t,21)+gdaa(6,t).*tnode(t,15)+gdbb(6,t).*model.t0(15)]
H_q=[H_q,q_zhu_node(t,22)==rmm(7,t)+G(31,t).*tnode(t,22)+gdaa(7,t).*tnode(t,15)+gdbb(7,t).*model.t0(15)]
for t=2:timeh
H_q=[H_q,q_zhu_node(t,1)==rmm(21,t)+G(1,t).*tnode(t,1)+gdaa(21,t).*tnode(t,12)+gdbb(21,t).*tnode(t-1,12)]
H_q=[H_q,q_zhu_node(t,2)==rmm(22,t)+G(2,t).*tnode(t,2)+gdaa(22,t).*tnode(t,13)+gdbb(22,t).*tnode(t-1,13)]
H_q=[H_q,q_zhu_node(t,3)==rmm(13,t)+(G(11,t)+G(12,t)).*tnode(t,3)+gdaa(13,t).*tnode(t,4)+gdbb(13,t).*tnode(t-1,4)]
H_q=[H_q,q_zhu_node(t,4)==rmm(14,t)+rmm(15,t)+rmm(16,t)+rmm(17,t)+(G(13,t)+G(18,t)).*tnode(t,4)+gdaa(14,t).*tnode(t,8)+gdaa(15,t).*tnode(t,9)+gdaa(16,t).*tnode(t,10)+gdaa(17,t).*tnode(t,11)+gdbb(14,t).*tnode(t-1,8)+gdbb(15,t).*tnode(t-1,9)+gdbb(16,t).*tnode(t-1,10)+gdbb(17,t).*tnode(t-1,11)]
H_q=[H_q,q_zhu_node(t,5)==rmm(18,t)+rmm(19,t)+G(20,t).*tnode(t,5)+gdaa(18,t).*tnode(t,4)+gdaa(19,t).*tnode(t,7)+gdbb(18,t).*tnode(t-1,4)+gdbb(19,t).*tnode(t-1,7)]
H_q=[H_q,q_zhu_node(t,6)==rmm(26,t)+G(10,t).*tnode(t,6)+gdaa(26,t).*tnode(t,17)+gdbb(26,t).*tnode(t-1,17)]
H_q=[H_q,q_zhu_node(t,7)==rmm(27,t)+G(19,t).*tnode(t,7)+gdaa(27,t).*tnode(t,18)+gdbb(27,t).*tnode(t-1,18)]
H_q=[H_q,q_zhu_node(t,8)==rmm(28,t)+G(14,t).*tnode(t,8)+gdaa(28,t).*tnode(t,19)+gdbb(28,t).*tnode(t-1,19)]
H_q=[H_q,q_zhu_node(t,9)==rmm(29,t)+G(15,t).*tnode(t,9)+gdaa(29,t).*tnode(t,20)+gdbb(29,t).*tnode(t-1,20)]
H_q=[H_q,q_zhu_node(t,10)==rmm(30,t)+G(16,t).*tnode(t,10)+gdaa(30,t).*tnode(t,21)+gdbb(30,t).*tnode(t-1,21)]
H_q=[H_q,q_zhu_node(t,11)==rmm(31,t)+G(17,t).*tnode(t,11)+gdaa(31,t).*tnode(t,22)+gdbb(31,t).*tnode(t-1,22)]
H_q=[H_q,q_zhu_node(t,12)==rmm(11,t)+G(21,t).*tnode(t,12)+gdaa(11,t).*tnode(t,3)+gdbb(11,t).*tnode(t-1,3)]
H_q=[H_q,q_zhu_node(t,13)==rmm(12,t)+G(22,t).*tnode(t,13)+gdaa(12,t).*tnode(t,3)+gdbb(12,t).*tnode(t-1,3)]
H_q=[H_q,q_zhu_node(t,14)==rmm(1,t)+rmm(2,t)+G(3,t).*tnode(t,14)+gdaa(1,t).*tnode(t,1)+gdaa(2,t).*tnode(t,2)+gdbb(1,t).*tnode(t-1,1)+gdbb(2,t).*tnode(t-1,2)]
H_q=[H_q,q_zhu_node(t,15)==rmm(8,t)+rmm(3,t)+(G(4,t)+G(5,t)+G(6,t)+G(7,t)).*tnode(t,15)+gdaa(3,t).*tnode(t,14)+gdaa(8,t).*tnode(t,16)+gdbb(3,t).*tnode(t-1,14)+gdbb(8,t).*tnode(t-1,16)]
H_q=[H_q,q_zhu_node(t,16)==rmm(10,t)+(G(8,t)+G(9,t)+G(25,t)).*tnode(t,16)+gdaa(10,t).*tnode(t,6)+gdbb(10,t).*tnode(t-1,6)]
H_q=[H_q,q_zhu_node(t,17)==rmm(20,t)+G(26,t).*tnode(t,17)+gdaa(20,t).*tnode(t,5)+gdbb(20,t).*tnode(t-1,5)]
H_q=[H_q,q_zhu_node(t,18)==rmm(9,t)+G(27,t).*tnode(t,18)+gdaa(9,t).*tnode(t,16)+gdbb(9,t).*tnode(t-1,16)]
H_q=[H_q,q_zhu_node(t,19)==rmm(4,t)+G(28,t).*tnode(t,19)+gdaa(4,t).*tnode(t,15)+gdbb(4,t).*tnode(t-1,15)]
H_q=[H_q,q_zhu_node(t,20)==rmm(5,t)+G(29,t).*tnode(t,20)+gdaa(5,t).*tnode(t,15)+gdbb(5,t).*tnode(t-1,15)]
H_q=[H_q,q_zhu_node(t,21)==rmm(6,t)+G(30,t).*tnode(t,21)+gdaa(6,t).*tnode(t,15)+gdbb(6,t).*tnode(t-1,15)]
H_q=[H_q,q_zhu_node(t,22)==rmm(7,t)+G(31,t).*tnode(t,22)+gdaa(7,t).*tnode(t,15)+gdbb(7,t).*tnode(t-1,15)]
end
DHS_constraint = DHS_constraint + H_q;

%节点温度约束 nodal temperature constraint 
DHS_node_stemp_limit=[];
model.Tmax =  ones(timeh,1) * model.node(:,4)';
model.Tmin =  ones(timeh,1) * model.node(:,3)';
DHS_node_stemp_limit = [DHS_node_stemp_limit,model.Tmin <=tnode];
DHS_node_stemp_limit = [DHS_node_stemp_limit,tnode <= model.Tmax];
DHS_constraint = DHS_constraint +DHS_node_stemp_limit;

% gda=sdpvar(hpipe_num,timeh,'full')
% gdb=sdpvar(hpipe_num,timeh,'full')
% rm=sdpvar(hpipe_num,timeh,'full')

gda=ones(hpipe_num,timeh)
gdb=ones(hpipe_num,timeh)
rm=ones(hpipe_num,timeh)

for i=1:hpipe_num
    for t=1:timeh
    gda(i,t)=exp(-(model.pipe(i,6).*model.pipe(i,3))/(model.water_c.*model.pipemass(i,1).*m(i,t))).*(1-model.water_dens.*(3.14/4).*model.pipe(i,4)^2.*model.pipe(i,3)/(m(i,t).*model.pipemass(i,1).*dt));
    gdb(i,t)=exp(-(model.pipe(i,6).*model.pipe(i,3))/(model.water_c.*model.pipemass(i,1).*m(i,t))).*(model.water_dens.*(3.14/4).*model.pipe(i,4)^2.*model.pipe(i,3)/(m(i,t).*model.pipemass(i,1).*dt));
    end
end


for i=1:hpipe_num
    for t=1:timeh
    rm(i,t)=(1-exp(-(model.pipe(i,6).*model.pipe(i,3))/(model.water_c.*model.pipemass(i,1).*m(i,t)))).*model.ta(1,t)
    end
end



%管道出口温度约束 pipeline temperature constraint 
DHS_pipe_stemp_limit=[]
model.Tsau=ones(timeh,1)*model.pipe(:,11)';
model.Tsad=ones(timeh,1)*model.pipe(:,10)';

t=1
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,1)<=gda(1,t).*tnode(t,1)+gdb(1,t).*model.t0(1)+rm(1,t)<=model.Tsau(t,1)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,2)<=gda(2,t).*tnode(t,2)+gdb(2,t).*model.t0(2)+rm(2,t)<=model.Tsau(t,2)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,3)<=gda(3,t).*tnode(t,14)+gdb(3,t).*model.t0(14)+rm(3,t)<=model.Tsau(t,3)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,4)<=gda(4,t).*tnode(t,15)+gdb(4,t).*model.t0(15)+rm(4,t)<=model.Tsau(t,4)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,5)<=gda(5,t).*tnode(t,15)+gdb(5,t).*model.t0(15)+rm(5,t)<=model.Tsau(t,5)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,6)<=gda(6,t).*tnode(t,15)+gdb(6,t).*model.t0(15)+rm(6,t)<=model.Tsau(t,6)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,7)<=gda(7,t).*tnode(t,15)+gdb(7,t).*model.t0(15)+rm(7,t)<=model.Tsau(t,7)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,8)<=gda(8,t).*tnode(t,16)+gdb(8,t).*model.t0(16)+rm(8,t)<=model.Tsau(t,8)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,9)<=gda(9,t).*tnode(t,16)+gdb(9,t).*model.t0(16)+rm(9,t)<=model.Tsau(t,9)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,10)<=gda(10,t).*tnode(t,6)+gdb(10,t).*model.t0(6)+rm(10,t)<=model.Tsau(t,10)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,11)<=gda(11,t).*tnode(t,3)+gdb(11,t).*model.t0(3)+rm(11,t)<=model.Tsau(t,11)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,12)<=gda(12,t).*tnode(t,3)+gdb(12,t).*model.t0(3)+rm(12,t)<=model.Tsau(t,12)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,13)<=gda(13,t).*tnode(t,4)+gdb(13,t).*model.t0(4)+rm(13,t)<=model.Tsau(t,13)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,14)<=gda(14,t).*tnode(t,8)+gdb(14,t).*model.t0(8)+rm(14,t)<=model.Tsau(t,14)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,15)<=gda(15,t).*tnode(t,9)+gdb(15,t).*model.t0(9)+rm(15,t)<=model.Tsau(t,15)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,16)<=gda(16,t).*tnode(t,10)+gdb(16,t).*model.t0(10)+rm(16,t)<=model.Tsau(t,16)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,17)<=gda(17,t).*tnode(t,11)+gdb(17,t).*model.t0(11)+rm(17,t)<=model.Tsau(t,17)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,18)<=gda(18,t).*tnode(t,4)+gdb(18,t).*model.t0(4)+rm(18,t)<=model.Tsau(t,18)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,19)<=gda(19,t).*tnode(t,7)+gdb(19,t).*model.t0(7)+rm(19,t)<=model.Tsau(t,19)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,20)<=gda(20,t).*tnode(t,5)+gdb(20,t).*model.t0(5)+rm(20,t)<=model.Tsau(t,20)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,21)<=gda(21,t).*tnode(t,12)+gdb(21,t).*model.t0(12)+rm(21,t)<=model.Tsau(t,21)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,22)<=gda(22,t).*tnode(t,13)+gdb(22,t).*model.t0(13)+rm(22,t)<=model.Tsau(t,22)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,23)<=gda(23,t).*tnode(t,14)+gdb(23,t).*model.t0(14)+rm(23,t)<=model.Tsau(t,23)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,24)<=gda(24,t).*tnode(t,15)+gdb(24,t).*model.t0(15)+rm(24,t)<=model.Tsau(t,24)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,25)<=gda(25,t).*tnode(t,16)+gdb(25,t).*model.t0(16)+rm(25,t)<=model.Tsau(t,25)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,26)<=gda(26,t).*tnode(t,17)+gdb(26,t).*model.t0(17)+rm(26,t)<=model.Tsau(t,26)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,27)<=gda(27,t).*tnode(t,18)+gdb(27,t).*model.t0(18)+rm(27,t)<=model.Tsau(t,27)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,28)<=gda(28,t).*tnode(t,19)+gdb(28,t).*model.t0(19)+rm(28,t)<=model.Tsau(t,28)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,29)<=gda(29,t).*tnode(t,20)+gdb(29,t).*model.t0(20)+rm(29,t)<=model.Tsau(t,29)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,30)<=gda(30,t).*tnode(t,21)+gdb(30,t).*model.t0(21)+rm(30,t)<=model.Tsau(t,30)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,31)<=gda(31,t).*tnode(t,22)+gdb(31,t).*model.t0(22)+rm(31,t)<=model.Tsau(t,31)]

for t=2:timeh
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,1)<=gda(1,t).*tnode(t,1)+gdb(1,t).*tnode(t-1,1)+rm(1,t)<=model.Tsau(t,1)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,2)<=gda(2,t).*tnode(t,2)+gdb(2,t).*tnode(t-1,2)+rm(2,t)<=model.Tsau(t,2)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,3)<=gda(3,t).*tnode(t,14)+gdb(3,t).*tnode(t-1,14)+rm(3,t)<=model.Tsau(t,3)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,4)<=gda(4,t).*tnode(t,15)+gdb(4,t).*tnode(t-1,15)+rm(4,t)<=model.Tsau(t,4)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,5)<=gda(5,t).*tnode(t,15)+gdb(5,t).*tnode(t-1,15)+rm(5,t)<=model.Tsau(t,5)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,6)<=gda(6,t).*tnode(t,15)+gdb(6,t).*tnode(t-1,15)+rm(6,t)<=model.Tsau(t,6)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,7)<=gda(7,t).*tnode(t,15)+gdb(7,t).*tnode(t-1,15)+rm(7,t)<=model.Tsau(t,7)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,8)<=gda(8,t).*tnode(t,16)+gdb(8,t).*tnode(t-1,16)+rm(8,t)<=model.Tsau(t,8)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,9)<=gda(9,t).*tnode(t,16)+gdb(9,t).*tnode(t-1,16)+rm(9,t)<=model.Tsau(t,9)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,10)<=gda(10,t).*tnode(t,6)+gdb(10,t).*tnode(t-1,6)+rm(10,t)<=model.Tsau(t,10)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,11)<=gda(11,t).*tnode(t,3)+gdb(11,t).*tnode(t-1,3)+rm(11,t)<=model.Tsau(t,11)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,12)<=gda(12,t).*tnode(t,3)+gdb(12,t).*tnode(t-1,3)+rm(12,t)<=model.Tsau(t,12)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,13)<=gda(13,t).*tnode(t,4)+gdb(13,t).*tnode(t-1,4)+rm(13,t)<=model.Tsau(t,13)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,14)<=gda(14,t).*tnode(t,8)+gdb(14,t).*tnode(t-1,8)+rm(14,t)<=model.Tsau(t,14)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,15)<=gda(15,t).*tnode(t,9)+gdb(15,t).*tnode(t-1,9)+rm(15,t)<=model.Tsau(t,15)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,16)<=gda(16,t).*tnode(t,10)+gdb(16,t).*tnode(t-1,10)+rm(16,t)<=model.Tsau(t,16)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,17)<=gda(17,t).*tnode(t,11)+gdb(17,t).*tnode(t-1,11)+rm(17,t)<=model.Tsau(t,17)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,18)<=gda(18,t).*tnode(t,4)+gdb(18,t).*tnode(t-1,4)+rm(18,t)<=model.Tsau(t,18)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,19)<=gda(19,t).*tnode(t,7)+gdb(19,t).*tnode(t-1,7)+rm(19,t)<=model.Tsau(t,19)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,20)<=gda(20,t).*tnode(t,5)+gdb(20,t).*tnode(t-1,5)+rm(20,t)<=model.Tsau(t,20)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,21)<=gda(21,t).*tnode(t,12)+gdb(21,t).*tnode(t-1,12)+rm(21,t)<=model.Tsau(t,21)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,22)<=gda(22,t).*tnode(t,13)+gdb(22,t).*tnode(t-1,13)+rm(22,t)<=model.Tsau(t,22)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,23)<=gda(23,t).*tnode(t,14)+gdb(23,t).*tnode(t-1,14)+rm(23,t)<=model.Tsau(t,23)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,24)<=gda(24,t).*tnode(t,15)+gdb(24,t).*tnode(t-1,15)+rm(24,t)<=model.Tsau(t,24)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,25)<=gda(25,t).*tnode(t,16)+gdb(25,t).*tnode(t-1,16)+rm(25,t)<=model.Tsau(t,25)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,26)<=gda(26,t).*tnode(t,17)+gdb(26,t).*tnode(t-1,17)+rm(26,t)<=model.Tsau(t,26)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,27)<=gda(27,t).*tnode(t,18)+gdb(27,t).*tnode(t-1,18)+rm(27,t)<=model.Tsau(t,27)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,28)<=gda(28,t).*tnode(t,19)+gdb(28,t).*tnode(t-1,19)+rm(28,t)<=model.Tsau(t,28)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,29)<=gda(29,t).*tnode(t,20)+gdb(29,t).*tnode(t-1,20)+rm(29,t)<=model.Tsau(t,29)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,30)<=gda(30,t).*tnode(t,21)+gdb(30,t).*tnode(t-1,21)+rm(30,t)<=model.Tsau(t,30)]
DHS_pipe_stemp_limit=[DHS_pipe_stemp_limit,model.Tsad(t,31)<=gda(31,t).*tnode(t,22)+gdb(31,t).*tnode(t-1,22)+rm(31,t)<=model.Tsau(t,31)]
end
DHS_constraint = DHS_constraint + DHS_pipe_stemp_limit

% %end of horizon constraint
% DHS_end=[]
% DHS_end = [DHS_end,model.tn<=tnode(timeh,:)];
% DHS_constraint = DHS_constraint+DHS_end;
 
% %% 节点水力平衡约束
% DHS_node_hy=[]
% DHS_node_hy=[DHS_node_hy,(model_node.A1-model_node.A2)*G==0];
% DHS_hy=[]
% for t=1:timeh
%     for i=1:hpipe_num
%     DHS_hy=[DHS_hy,0.8<=m(i,t)<=1.2];  %495
%     end
% end
% DHS_constraint = DHS_constraint+DHS_node_hy;
%% Objective function
cost=0
%热尺度
for t = 1: timeh
    for k = 1:chp_num
        cost = cost  +model.chpcost(k,4) * q_chp(t,k) + ...
             + model.chpcost(k,5) * q_chp(t,k)^2
    end
end

%% Solver
objective = cost;
constraints = DHS_constraint+CHP_constraint;
options = sdpsettings('verbose',1,'debug',1,'savesolveroutput',1,'savesolverinput',1);
sol = optimize(constraints,objective,options);
alter=1;
