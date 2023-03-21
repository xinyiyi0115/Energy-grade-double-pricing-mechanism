function [mpc_bus, mpc_branch] = calculate_branch_para(mpc)
[mpc_branch.num, null_num] = size (mpc.branch);   %����֧·����
[mpc_bus.num, null_num] = size (mpc.bus);   %����ڵ�����
%[mpc_bus.gennum, null_num] = size (mpc.gen); %���㴫ͳ�����������

for i=1:mpc_branch.num %����ÿ��֧·����
    mpc_branch.o(i,i)=mpc.branch(i,4)./[mpc.branch(i,4)^2+mpc.branch(i,3)^2]
end
for i=1:mpc_branch.num-2 %����ÿ��֧·����
    mpc_branch.o1(i,i)=mpc.branch(i+2,4)./[mpc.branch(i+2,4)^2+mpc.branch(i+2,3)^2]
end
for i=1:mpc_branch.num %����ÿ��֧·����
    mpc_branch.I(i,i)=1
end

for i=1:mpc_branch.num
    for j=1:mpc_bus.num        
        if mpc.branch(i,1)==j    %����Ϊ1
            mpc_bus.A(i,j)=1
        else if mpc.branch(i,2)==j    %����Ϊ-1
                mpc_bus.A(i,j)=-1
            end
        end
    end
end

for i=1:mpc_branch.num-2
    for j=1:mpc_bus.num-1       
        if mpc.branch(i+2,1)==j+1    %����Ϊ1
            mpc_bus.A1(i,j)=1
        else if mpc.branch(i+2,2)==j+1    %����Ϊ-1
                mpc_bus.A1(i,j)=-1
            end
        end
    end
end

mpc_bus.H=mpc_branch.o*mpc_bus.A*inv(mpc_bus.A'*mpc_branch.o*mpc_bus.A)

%ѡ��ڵ�1Ϊ�ο��ڵ�
%for i=1:mpc_branch.num
    %mpc_bus.H(i,1)=0
%end





        
