function [mpc_bus, mpc_branch] = calculate_branch_para(mpc)
[mpc_branch.num, null_num] = size (mpc.branch);   %计算支路数量
[mpc_bus.num, null_num] = size (mpc.bus);   %计算节点数量
%[mpc_bus.gennum, null_num] = size (mpc.gen); %计算传统发电机组数量

for i=1:mpc_branch.num %计算每条支路参数
    mpc_branch.o(i,i)=mpc.branch(i,4)./[mpc.branch(i,4)^2+mpc.branch(i,3)^2]
end
for i=1:mpc_branch.num-2 %计算每条支路参数
    mpc_branch.o1(i,i)=mpc.branch(i+2,4)./[mpc.branch(i+2,4)^2+mpc.branch(i+2,3)^2]
end
for i=1:mpc_branch.num %计算每条支路参数
    mpc_branch.I(i,i)=1
end

for i=1:mpc_branch.num
    for j=1:mpc_bus.num        
        if mpc.branch(i,1)==j    %流入为1
            mpc_bus.A(i,j)=1
        else if mpc.branch(i,2)==j    %流出为-1
                mpc_bus.A(i,j)=-1
            end
        end
    end
end

for i=1:mpc_branch.num-2
    for j=1:mpc_bus.num-1       
        if mpc.branch(i+2,1)==j+1    %流入为1
            mpc_bus.A1(i,j)=1
        else if mpc.branch(i+2,2)==j+1    %流出为-1
                mpc_bus.A1(i,j)=-1
            end
        end
    end
end

mpc_bus.H=mpc_branch.o*mpc_bus.A*inv(mpc_bus.A'*mpc_branch.o*mpc_bus.A)

%选择节点1为参考节点
%for i=1:mpc_branch.num
    %mpc_bus.H(i,1)=0
%end





        
