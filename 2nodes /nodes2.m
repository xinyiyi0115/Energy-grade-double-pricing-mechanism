clc
clear all
h=sdpvar(1,1)
t=sdpvar(4,1)
m=sdpvar(1,1)
mf=100 %kg/s
v=0.9 %W/m*k
l=50  %m
c=4.2*10^3  %J/k*kg
r=0.08
loss=exp(-v*l/(c*mf*m))
left=10^3*3.14*r^2*50/(mf*m*3600)
cost=0
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

con1=[h==  0.42*m*(t(1)-t(3))];  
con2=[-20== 0.42*m*(t(2)-t(4))];
con3=[0==0.42*m*(t(3)-loss*t(2)+(1-loss)*19)]
con4=[0==0.42*m*(t(4)-loss*t(1)+(1-loss)*19)]
con5=[50<=t(1)<=100]
con6=[40<=t(2)<=100]
con7=[30<=t(3)<=100]
con8=[60<=t(4)<=100]
con9=[0<=h<=30]
con10=[0.8<=m<=1.2]


con=con1+con2+con3+con4+con5+con6+con7+con8+con9+con10

ops = sdpsettings('verbose',0,'savesolveroutput',1); 
result = solvesdp(con,cost,ops)

t=value(t)
h=value(h)
m=value(m)

ms=-result.solveroutput.lambda.eqnonlin(2)*20+result.solveroutput.lambda.eqnonlin(1)*h
msh=ms+result.solveroutput.lambda.lower(3)*59
gradep=result.solveroutput.lambda.lower(3)*59

tt=t+273.15
pricepro=-result.solveroutput.lambda.eqnonlin(1)
pricecon=-result.solveroutput.lambda.eqnonlin(2)
gradeprice=result.solveroutput.lambda.lower(3)
genpay=-result.solveroutput.lambda.eqnonlin(1)*h
loadpay=-result.solveroutput.lambda.eqnonlin(2)*20
gradepay=result.solveroutput.lambda.lower(3)*59
