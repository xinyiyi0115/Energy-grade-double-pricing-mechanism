p_chp=value(p_chp)
q_chp=value(q_chp)
eqlin=sol.solveroutput.lambda.eqlin
ineqlin=sol.solveroutput.lambda.ineqlin
tnode=value(tnode)
m=value(m)
gdbb=value(gdbb)
gdaa=value(gdaa)
%% 耦合操作成本
%碰界情况确认
T=25
for t=1:T
%CHP1
r11(t)=-1.91.*q_chp(t,1)+p_chp(t,1)+3.55;
r12(t)=-0.0833*q_chp(t,1)-p_chp(t,1)+5.42;
r13(t)=8.667*q_chp(t,1)-p_chp(t,1)-143.3390;
r14(t)=2*q_chp(t,1)+p_chp(t,1)-70;
%CHP2
r21(t)=-1.91.*q_chp(t,2)+p_chp(t,2)+4.65;
r22(t)=-0.0833*q_chp(t,2)-p_chp(t,2)+11.32;
r23(t)=8.667*q_chp(t,2)-p_chp(t,2)-160.3390;
r24(t)=2*q_chp(t,2)+p_chp(t,2)-69;
%CHP3
r31(t)=-2.79.*q_chp(t,3)+p_chp(t,3)+8.7;
r32(t)=-0.0833*q_chp(t,3)-1.65*p_chp(t,3)+5.52;
r33(t)=8.667*q_chp(t,3)-p_chp(t,3)-141.3390;
r34(t)=2*q_chp(t,3)+p_chp(t,3)-68;
end
%% 对应阴影价格
for t=1:25
    for i=1:4
        cp1(i,t)=ineqlin(3168+i+(t-1)*12) 
        cp2(i,t)=ineqlin(3168+4+i+(t-1)*12)
        cp3(i,t)=ineqlin(3168+8+i+(t-1)*12)
    end
end


C2=zeros(66,66,T)
for t=1:T
C2(2,3,t)=gdbb(35,t)
C2(2,4,t)=gdbb(36,t)
C2(2,5,t)=gdbb(37,t)
C2(2,35,t)=gdbb(68,t)


C2(5,6,t)=gdbb(38,t)
C2(5,7,t)=gdbb(39,t)
C2(5,11,t)=gdbb(43,t)
C2(5,38,t)=gdbb(71,t)

C2(7,8,t)=gdbb(40,t)
C2(7,9,t)=gdbb(41,t)
C2(7,10,t)=gdbb(42,t)
C2(7,40,t)=gdbb(73,t)

C2(11,12,t)=gdbb(44,t)
C2(11,13,t)=gdbb(45,t)
C2(11,44,t)=gdbb(77,t)


C2(13,14,t)=gdbb(46,t)

C2(14,15,t)=gdbb(47,t)
C2(14,18,t)=gdbb(50,t)
C2(14,19,t)=gdbb(51,t)
C2(14,47,t)=gdbb(80,t)

C2(15,16,t)=gdbb(48,t)
C2(15,17,t)=gdbb(49,t)
C2(15,48,t)=gdbb(81,t)

C2(19,20,t)=gdbb(52,t)
C2(19,21,t)=gdbb(53,t)
C2(19,22,t)=gdbb(54,t)
C2(19,52,t)=gdbb(85,t)

C2(22,23,t)=gdbb(55,t)
C2(22,24,t)=gdbb(56,t)
C2(22,55,t)=gdbb(88,t)

C2(25,22,t)=gdbb(57,t)
C2(25,26,t)=gdbb(58,t)
C2(25,27,t)=gdbb(59,t)
C2(25,58,t)=gdbb(91,t)
C2(28,25,t)=gdbb(60,t)
C2(28,29,t)=gdbb(61,t)
C2(28,30,t)=gdbb(62,t)
C2(28,61,t)=gdbb(94,t)

C2(31,28,t)=gdbb(63,t)
C2(31,7,t)=gdbb(66,t)
C2(31,64,t)=gdbb(97,t)

C2(34,2,t)=gdbb(34,t)

C2(35,1,t)=gdbb(1,t)

C2(36,35,t)=gdbb(2,t)

C2(37,35,t)=gdbb(3,t)

C2(38,35,t)=gdbb(4,t)

C2(39,38,t)=gdbb(5,t)

C2(40,38,t)=gdbb(6,t)
C2(40,64,t)=gdbb(33,t)

C2(41,40,t)=gdbb(7,t)

C2(42,40,t)=gdbb(8,t)

C2(43,40,t)=gdbb(9,t)

C2(44,38,t)=gdbb(10,t)
C2(44,32,t)=gdbb(31,t)

C2(45,44,t)=gdbb(11,t)

C2(46,44,t)=gdbb(12,t)

C2(47,46,t)=gdbb(13,t)

C2(48,47,t)=gdbb(14,t)

C2(49,48,t)=gdbb(15,t)

C2(50,48,t)=gdbb(16,t)
C2(51,47,t)=gdbb(17,t)

C2(52,47,t)=gdbb(18,t)

C2(53,52,t)=gdbb(19,t)

C2(54,52,t)=gdbb(20,t)

C2(55,52,t)=gdbb(21,t)
C2(55,58,t)=gdbb(24,t)

C2(56,55,t)=gdbb(22,t)

C2(57,55,t)=gdbb(23,t)

C2(58,61,t)=gdbb(27,t)

C2(59,58,t)=gdbb(25,t)

C2(60,58,t)=gdbb(26,t)

C2(61,64,t)=gdbb(30,t)

C2(62,61,t)=gdbb(28,t)

C2(63,61,t)=gdbb(29,t)

C2(64,33,t)=gdbb(32,t)

C2(65,11,t)=gdbb(64,t)

C2(66,31,t)=gdbb(65,t)
end
% 热价
ep=zeros(25,33)
for t=1:25
    for i=1:33
        ep(t,i)=eqlin(1650+i+(t-1)*33)
    end
end
hp=zeros(25,66)
for t=1:25
    for i=1:66
        hp(t,i)=eqlin(i+(t-1)*66)
    end
end
%% 热力市场
%负荷热力市场能量付费
for t=1:25
    for i=1:66
        plhe(i,t)=hload(t,i).*hp(t,i)
    end
end
       
%CHP热力市场能量收费
for t=1:25
    for i=32:33
        pshe(i-30,t)=q_chp(t,i-30).*hp(t,i)
    end
end

for t=1:25
    pshe(1,t)=q_chp(t,1).*hp(t,1)
end
mseh=sum(plhe)-sum(pshe)


%CHP热力市场能量收费
for i=1:66
    for t=1:25
        lowerr(t,i)=ineqlin(t+(i-1)*25)
    end
end
tmin=[60,20,50,50,20,50,20,50,50,50,20,50,20,20,20,50,60,60,20,60,60,20,60,60,20,60,60,20,60,60,20,60,60,20,60,80,80,60,80,60,80,80,80,60,80,60,60,80,80,80,80,60,80,80,60,80,80,60,80,80,60,80,80,60,20,20]
phg=zeros(25,66)

for i=1:66
    for t=1:25
        phg(t,i)=lowerr(t,i)*(tmin(i)-model.t0(1,t))
    end
end
hpp=hp'
msh=mseh+sum(phg')
t=1
pr(1)=-hpp(:,1)'*C2(:,:,1)*(tstart'-model.t0(1,t))
for t=2:24
pr(t)=-hpp(:,t)'*C2(:,:,t)*(tnode(t-1,:)'-model.t0(1,t))
end
for t=1:24
fr(t)=hpp(:,t+1)'*C2(:,:,t+1)*(tnode(t,:)'-model.t0(1,t))
end

tr=pr+fr


%% 电力市场
%负荷电力市场能量付费
for t=1:25
    for i=1:33
        plpe(i,t)=ep(t,i).*eeload(t,i)
    end
end

%CHP 电力市场能量收费
for t=1:25
    for i=1:3
        pspe(i,t)=p_chp(t,i).*ep(t,i)
    end
end
msep=sum(plpe)-sum(pspe)

for i=1:37
    for t=1:25
        lr(i,t)=ineqlin(6175+t+(i-1)*25,1)
    end
end

for t=1:25
        cr(t)=32*sum(lr(:,t))
end








