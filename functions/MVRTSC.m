function [Plabel,Timecost] = MVRTSC(A,mu,lambda,numClust)
% Multi-View Robust Tensor-based Subspace Clustering code.
% Definition:
%     [Plabel,Timecost]=MVRTSC(A,mu,lambda,numClust)
%
% Inputs:
% A               3rd mode tensor [n*n*V], non-negative adjacency tensor.
% mu              scalar, regularization parameter that controls the L_{2,1} norm.
% lambda          scalar, regularization parameter that controls the subspace clustering term.
% numClust        scalar, the number of clusters.
% 
% Outputs:
% Plabel          vector [1*n], the final clustering labels for each node in the netwrok.
% Timecost        scalar, the time cost for each attempt.
%
%
% required external files:
%  [1] wshrinkObj, "On unifying multi-view self-representations for clustering by tensor multi-rank minimization."
%  [2] Tensor Toolbox for MATLAB: <a href="https://www.tensortoolbox.org">www.tensortoolbox.org</a>

%%%%
%
% Copyright (C)   <Esraa Al-Sharoa & Mohammad Al-Wardat>
%  
%%%%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% 

[n1,n2,n3]=size(A);
I=eye(n1,n2);
Z=eps*ones(size(A));
E=Z; Y1=Z; Y2=Z;  
dY1=Z;    
iter = 1;
tol=0.01;
gamma1=0.01;
gamma2=0.01;
rho = 2;           
Uopt = zeros(n1,numClust);
w_v = eps*ones(n3,1);
max_gamma = 1e10; 
max_iter=500;


tic;
for i=1:max_iter
                                      
        
        % update B
        B = reshape(wshrinkObj(Z+Y2/gamma2,1/gamma2,[n1 n2 n3],0,3),[n1 n2 n3]);
        
        % update E
        
        if n3==2
            
        F = [A(:,:,1)-A(:,:,1)*Z(:,:,1)+Y1(:,:,1)/gamma1;...
        A(:,:,2)-A(:,:,2)*Z(:,:,2)+Y1(:,:,2)/gamma1];
        [Econcat] = solve_l1l2(F,mu/gamma1);
        E(:,:,1) = Econcat(1:size(A(:,:,1),1),:);
        E(:,:,2) = Econcat(size(A(:,:,1),1)+1:size(A(:,:,1),1)+size(A(:,:,2),1),:);
        
         
            
        elseif n3==3
         
         F = [A(:,:,1)-A(:,:,1)*Z(:,:,1)+Y1(:,:,1)/gamma1;...
         A(:,:,2)-A(:,:,2)*Z(:,:,2)+Y1(:,:,2)/gamma1;...
         A(:,:,3)-A(:,:,3)*Z(:,:,3)+Y1(:,:,3)/gamma1];
         [Econcat] = solve_l1l2(F,mu/gamma1);
         E(:,:,1) = Econcat(1:size(A(:,:,1),1),:);
         E(:,:,2) = Econcat(size(A(:,:,1),1)+1:size(A(:,:,1),1)+size(A(:,:,2),1),:);
         E(:,:,3) = Econcat(size(A(:,:,1),1)+size(A(:,:,2),1)+1:end,:);
        
            
        elseif n3==4
                
        F = [A(:,:,1)-A(:,:,1)*Z(:,:,1)+Y1(:,:,1)/gamma1;...
        A(:,:,2)-A(:,:,2)*Z(:,:,2)+Y1(:,:,2)/gamma1;...
        A(:,:,3)-A(:,:,3)*Z(:,:,3)+Y1(:,:,3)/gamma1;...
        A(:,:,4)-A(:,:,4)*Z(:,:,4)+Y1(:,:,4)/gamma1];
        [Econcat] = solve_l1l2(F,mu/gamma1);
        E(:,:,1) = Econcat(1:size(A(:,:,1),1),:);
        E(:,:,2) = Econcat(size(A(:,:,1),1)+1:size(A(:,:,1),1)+size(A(:,:,2),1),:);
        E(:,:,3) = Econcat(size(A(:,:,1),1)+size(A(:,:,2),1)+1:size(A(:,:,1),1)+size(A(:,:,2),1)+size(A(:,:,3),1),:);
        E(:,:,4) = Econcat(size(A(:,:,1),1)+size(A(:,:,2),1)+size(A(:,:,3),1)+1:end,:);
                
        elseif n3==5
            
        F = [A(:,:,1)-A(:,:,1)*Z(:,:,1)+Y1(:,:,1)/gamma1;...
        A(:,:,2)-A(:,:,2)*Z(:,:,2)+Y1(:,:,2)/gamma1;
        A(:,:,3)-A(:,:,3)*Z(:,:,3)+Y1(:,:,3)/gamma1;...
        A(:,:,4)-A(:,:,4)*Z(:,:,4)+Y1(:,:,4)/gamma1;
        A(:,:,5)-A(:,:,5)*Z(:,:,5)+Y1(:,:,5)/gamma1;];
            [Econcat] = solve_l1l2(F,mu/gamma1);
        E(:,:,1) = Econcat(1:size(A(:,:,1),1),:);
        E(:,:,2) = Econcat(size(A(:,:,1),1)+1:size(A(:,:,1),1)+size(A(:,:,2),1),:);
        E(:,:,3) = Econcat(size(A(:,:,1),1)+size(A(:,:,2),1)+1:size(A(:,:,1),1)+size(A(:,:,2),1)+size(A(:,:,3),1),:);
        E(:,:,4) = Econcat(size(A(:,:,1),1)+size(A(:,:,2),1)+size(A(:,:,3),1)+1:size(A(:,:,1),1)+size(A(:,:,2),1)+size(A(:,:,3),1)+size(A(:,:,4),1),:);
        E(:,:,5) = Econcat(size(A(:,:,1),1)+size(A(:,:,2),1)+size(A(:,:,3),1)+size(A(:,:,4),1)+1:end,:);
        
        end
       
        %update Z
            for v=1:1:n3
            t(:,:,v)=gamma2*I+gamma1*A(:,:,v)'*A(:,:,v);
            N(:,:,v)=A(:,:,v)-E(:,:,v)+Y1(:,:,v)/gamma1;
            D(:,:,v)=getD(Z(:,:,v));
            Z(:,:,v)=inv(t(:,:,v))*(gamma2*B(:,:,v)-Y2(:,:,v)+ gamma1*A(:,:,v)'*N(:,:,v)...
                +lambda*w_v(v)*(D(:,:,v)^(-0.5))*(Uopt*Uopt')*(D(:,:,v)^(-0.5)));
            end 
        Z(Z<0)=0;
        
        for v=1:1:n3
            Z(:,:,v)=0.5*(Z(:,:,v)+Z(:,:,v)');
        end
        
       % compute Psi
       for v=1:n3
           Dv(:,:,v)=getD(Z(:,:,v));
           Psi(:,:,v)=(Dv(:,:,v))^(-0.5)*Z(:,:,v)*(Dv(:,:,v))^(-0.5);
       end 
        % Tucker decomposition 
        C = [numClust numClust  1];
        [Uf]= tucker_als(Psi,C);  % HOOI
        Uopt = Uf{1};   % Common subspace
        w_v = Uf{3};
        
        %update Y1
        for j=1:n3
           dY1(:,:,j)=A(:,:,j)-A(:,:,j)*Z(:,:,j)-E(:,:,j); 
        end
        Y1 = Y1 + gamma1*dY1;
        
        %update Y2
        dY2=Z-B;
        Y2 = Y2+gamma2*dY2;
        
        
        err1=norm(dY1(:),'Inf'); err2=norm(dY2(:),'Inf');  % stopping criteria 
        error1(iter)=err1; error2(iter)=err2; 
        err = max(err1,err2);
        
        gamma1 = min(rho*gamma1,max_gamma);
        gamma2 = min(rho*gamma2,max_gamma);
        
        %if mod(iter,10) == 0
        disp(['iter ' num2str(iter) ', err=' num2str(err)])
        %end
    if err < tol
       break;
    end
    iter = iter + 1;
end
Timecost=toc;

norm_mat = repmat(sqrt(sum(Uopt.*Uopt,2)),1,size(Uopt,2));  
for i=1:size(norm_mat,1)
   if (norm_mat(i,1)==0)
        norm_mat(i,:) = 1;
    end
end
Uf1 = Uopt./norm_mat;
          % Evaluation metrics 
        Plabel = kmeans(Uf1(:,1:numClust),numClust,'replicates',100,'emptyAction','singleton');     
end

