hpipe_num=31
% timeh=25
timeh=24
dt=3600
% for i=1:hpipe_num
%     for t=1:timeh
%     gdaa(i,t)=-model.water_c /1e6.*model.pipemass(i,1).*m(i,t).*(1-(model.pipe(i,6).*model.pipe(i,3))/(model.water_c.*model.pipemass(i,1).*m(i,t))).*(1-model.water_dens.*(3.14/4).*model.pipe(i,4)^2.*model.pipe(i,3)/(m(i,t).*model.pipemass(i,1).*dt));
%     G(i,t)=model.water_c / 1e6.*model.pipemass(i,1).*m(i,t);
%     gdbb(i,t)=-model.water_c /1e6.*model.pipemass(i,1).*m(i,t).*(1-(model.pipe(i,6).*model.pipe(i,3))/(model.water_c.*model.pipemass(i,1).*m(i,t))).*(model.water_dens.*(3.14/4).*model.pipe(i,4)^2.*model.pipe(i,3)/(m(i,t).*model.pipemass(i,1).*dt));
%     end
% end
gdaa=value(gdaa)
gdbb=value(gdbb)
m=value(m)
tnode=value(tnode)
q_chp=value(q_chp)
lower=sol.solveroutput.lambda.lower
upper=sol.solveroutput.lambda.upper
eqlin=sol.solveroutput.lambda.eqlin
ineqlin=sol.solveroutput.lambda.ineqlin
% eqnonlin=sol.solveroutput.lambda.eqnonlin
model.Tmin =  ones(timeh,1) * model.node(:,3)';
model.pipemass=[100
100
200
100
100
100
100
200
100
300
100
100
200
100
100
100
100
200
100
300
100
100
0
0
0
300
100
100
100
100
100]

hload=model.load*1.1
T=timeh
C2=zeros(22,22,T)
for t=1:timeh
C2(1,12,t)=gdbb(21,t)

C2(2,13,t)=gdbb(22,t)

C2(3,4,t)=gdbb(13,t)

C2(4,8,t)=gdbb(14,t)
C2(4,9,t)=gdbb(15,t)
C2(4,10,t)=gdbb(16,t)
C2(4,11,t)=gdbb(17,t)

C2(5,4,t)=gdbb(18,t)
C2(5,7,t)=gdbb(19,t)

C2(6,17,t)=gdbb(26,t)

C2(7,18,t)=gdbb(27,t)

C2(8,19,t)=gdbb(28,t)

C2(9,20,t)=gdbb(29,t)

C2(10,21,t)=gdbb(30,t)

C2(11,22,t)=gdbb(31,t)

C2(12,3,t)=gdbb(11,t)

C2(13,3,t)=gdbb(12,t)

C2(14,1,t)=gdbb(1,t)

C2(14,2,t)=gdbb(2,t)

C2(15,14,t)=gdbb(3,t)
C2(15,16,t)=gdbb(8,t)

C2(16,6,t)=gdbb(10,t)

C2(17,5,t)=gdbb(20,t)

C2(18,16,t)=gdbb(9,t)

C2(19,15,t)=gdbb(4,t)

C2(20,15,t)=gdbb(5,t)

C2(21,15,t)=gdbb(6,t)

C2(22,15,t)=gdbb(7,t)
end

% 热价
hp=zeros(timeh,22)
for t=1:timeh
    for i=1:22
        hp(t,i)=-eqlin(i+(t-1)*22)
    end
end

%% 热力市场
%负荷热力市场能量付费
for t=1:timeh
    for i=1:22
        plhe(i,t)=hload(t,i).*hp(t,i)
    end
end

%CHP热力市场能量收费
for t=1:timeh
    for i=1:2
        pshe(i,t)=q_chp(t,i).*hp(t,i)
    end
end

for t=1:timeh
    pshe(6,t)=q_chp(t,3).*hp(t,6)
end

mseh=sum(plhe)-sum(pshe)

% for i=1:22
%     for t=1:timeh
%         lowerr(t,i)=lower(75+t+(i-1)*25)
%     end
% end

for i=1:22
    for t=1:timeh
        lowerr(t,i)=ineqlin(t+(i-1)*timeh)
    end
end
% for i=1:22
%     for t=1:timeh
%         upperr(t,i)=upper(75+t+(i-1)*25)
%     end
% end

for i=1:22
    for t=1:timeh
        upperr(t,i)=ineqlin(528+t+(i-1)*timeh)  %550
    end
end
tmin=model.Tmin(1,:)
tmax=model.node(:,4)
phg=zeros(24,22)

for i=1:22
    for t=1:timeh
        phg(t,i)=lowerr(t,i)*(tmin(i)-model.ta(1,t))
    end
end
for i=1:22
    for t=1:timeh
        cr(t,i)=upperr(t,i)*(tmax(i)-model.ta(1,t))
    end
end


hpp=hp'
msh=mseh+sum(phg')
t=1
pr(1)=-hpp(:,1)'*C2(:,:,1)*(model.t0'-model.ta(1,t))
for t=2:24
pr(t)=-hpp(:,t)'*C2(:,:,t)*(tnode(t-1,:)'-model.ta(1,t))
end
for t=1:timeh-1
fr(t)=hpp(:,t+1)'*C2(:,:,t+1)*(tnode(t,:)'-model.ta(1,t))
end
% ppre=ineqlin(2545:2566)'
% fr(timeh)=-ppre*(tnode(timeh,:)'-model.ta(1,timeh))
fr(timeh)=0
tr=pr+fr

ad=zeros(24,1)
for t=1:timeh-1
ad(t)=hpp(:,t+1)'*C2(:,:,t+1)*(model.ta(:,t+1)-model.ta(:,t))
end





