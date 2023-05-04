clc
clear all
h=sdpvar(1,1)
t=sdpvar(4,1)
m=sdpvar(1,1)
mf=1000 %t/h
v=0.9 %W/m*k
l=50  %m
c=4.2*10^3  %J/k*kg
mf=10^6/3600 %1000t/h=10^6kg/h=10^6/3600 kg/s  J/K*s=W/K
loss=exp(-v*l/(c*mf))
cost=44.2*h+0.03*h^2
con1=[]
con2=[]
con3=[]
con4=[]
con5=[]
con6=[]
con7=[]
con8=[]
con9=[]
con10=[]

con1=[h==  4.2*m*(t(1)-t(3))];  
con2=[-90== 4.2*m*(t(2)-t(4))];
con3=[0==4.2*m*(t(3)-exp(-v*l/(c*mf*m))*t(2)+(1-exp(-v*l/(c*mf*m)))*19)]
con4=[0==4.2*m*(t(4)-exp(-v*l/(c*mf*m))*t(1)+(1-exp(-v*l/(c*mf*m)))*19)]
con5=[50<=t(1)<=100]
con6=[40<=t(2)<=100]
con7=[30<=t(3)<=100]
con8=[50<=t(4)<=100]
con9=[0<=h<=120]
% con10=[0.8<=m<=1.2]
con10=[m==1.0]

con=con1+con2+con3+con4+con5+con6+con7+con8+con9+con10

ops = sdpsettings('verbose',0,'savesolveroutput',1); 
result = solvesdp(con,cost,ops)

t=value(t)
h=value(h)
m=value(m)



