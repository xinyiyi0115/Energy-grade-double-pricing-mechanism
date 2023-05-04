clc
clear all
h=sdpvar(1,3)
t=sdpvar(4,3)
m=1.0
mf=1000 %t/h
v=0.9 %W/m*k
l=50  %m
c=4.2*10^3  %J/k*kg
r=0.08
mf=10^6/3600 %1000t/h=10^6kg/h=10^6/3600 kg/s  J/K*s=W/K
loss=exp(-v*l/(c*mf*m))
left=10^3*3.14*r^2*50/(10^6*m)
cost=0
T=3
for time=1:T
cost=cost+44.2*h(1,time)+0.03*h(1,time)^2
end

con1=[]
con2=[]
con3=[]
con4=[]
con5=[]
con6=[]
con7=[]
con8=[]
con9=[]


load=[-90,-90,-89.6]
t0=[61.4317
   40.0000
   39.9977
   61.4286]


time=1
con1=[h(1,time)==  4.2*m*(t(1,time)-t(3,time))];  
con2=[load(time)== 4.2*m*(t(2,time)-t(4,time))];
con3=[0==4.2*m*(t(3,time)-loss*((1-left)*t(2,time)+left*t0(2))+(1-loss)*19)]
con4=[0==4.2*m*(t(4,time)-loss*((1-left)*t(1,time)+left*t0(1))+(1-loss)*19)]
con5=[50<=t(1,time)<=100]
con6=[40<=t(2,time)<=100]
con7=[30<=t(3,time)<=100]
con8=[50<=t(4,time)<=100]
con9=[0<=h(1,time)<=120]

for time=2:T
con1=[con1,h(1,time)==  4.2*m*(t(1,time)-t(3,time))];  
con2=[con2,load(time)== 4.2*m*(t(2,time)-t(4,time))];
con3=[con3,0==4.2*m*(t(3,time)-loss*((1-left)*t(2,time)+left*t(2,time-1))+(1-loss)*19)]
con4=[con4,0==4.2*m*(t(4,time)-loss*((1-left)*t(1,time)+left*t(1,time-1))+(1-loss)*19)]
con5=[con5,50<=t(1,time)<=100]
con6=[con6,40<=t(2,time)<=100]
con7=[con7,30<=t(3,time)<=100]
con8=[con8,50<=t(4,time)<=100]
con9=[con9,0<=h(1,time)<=120]
end

con=con1+con2+con3+con4+con5+con6+con7+con8+con9

ops = sdpsettings('verbose',0,'savesolveroutput',1); 
result = solvesdp(con,cost,ops)

t=value(t)
h=value(h)
m=value(m)

price=zeros(4,3)
for time=1:3
    for i=1:4
        price(i,time)=result.solveroutput.lambda.eqlin(time+(i-1)*3,1)
    end
end

for time=1:3
    ms(time)=load(time)*price(2,time)+price(1,time)*h(time)
end

c2=[0 0 0 0
    0 0 0 0
    0 -0.001 0 0
    -0.001 0 0 0]

hgp(1)=result.solveroutput.lambda.ineqlin(7)
hgp(2)=result.solveroutput.lambda.ineqlin(9)
hgp(3)=result.solveroutput.lambda.ineqlin(11)


for time=1:3
    msh(time)=ms(time)+hgp(time)*59
end

time=1
pr(time)=price(:,time)'*c2*(t0+19)
time=2
pr(time)=price(:,time)'*c2*(t(:,time-1)+19)

for time=1:2
fr(time)=-price(:,time+1)'*c2*(t(:,time)+19)
end

tr=pr+fr
