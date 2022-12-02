function [estado_posterior] = modelo_alvo(estado_anterior,T)

    % PARÂMETROS DO ALVO
    tau = abs(estado_anterior(3));
    alfa = 1/tau;
    beta = exp(-alfa*T);
    
    % VARIÂNCIA RUÍDO DE PROCESSO
    sigma_a = 5;
    sigma_w = 2*alfa*5;
    sigma_tau = 30;
 
    w1 = estado_anterior(6);
    w2 = beta*estado_anterior(6) + normrnd(0,sigma_w);
    w = (w1+w2)/2;
    
    % MATRIZ EVOLUÇÃO DE ESTADO
    if abs(w) > 0.05
        A = [1  sin(w*T)/w      0       0   -(1-cos(w*T))/w 0   ;
             0  cos(w*T)        0       0   -sin(w*T)       0   ;
             0  0               alfa    0   0               0   ;
             0  (1-cos(w*T))/w  0       1   sin(w*T)/w      0   ;
             0  sin(w*T)        0       0   cos(w*T)        0   ;
             0  0               0       0   0               beta];
    else
        A = [1  T  0    0   0   0   ;
             0  1  0    0   0   0   ;
             0  0  alfa	0   0   0   ;
             0  0  0    1   T   0   ;
             0  0  0    0   1   0   ;
             0  0  0    0   0   beta];
    end
    
    % MATRIZES RUÍDO DE PROCESSO
    B = [(T^2)/2    0   0       0;
         T          0   0       0;
         0          1   0       0;
         0          0   (T^2)/2 0;
         0          0   T       0;
         0          0   0       1];
     
     
    C = [0;0;1;0;0;0]*abs(492.996*exp(-0.138*abs(estado_anterior(6))));
         
    ruido_de_processo = [normrnd(0,sigma_a) ;normrnd(0,sigma_tau); normrnd(0,sigma_a) ;normrnd(0,sigma_w)];
    estado_posterior = A*estado_anterior + B*ruido_de_processo + C;
    
    % X. R. Li and Y. Bar-Shalom, 
    % "Design of an interacting multiple model algorithm for air traffic control tracking" 
    % in IEEE Transactions on Control Systems Technology, vol. 1, no. 3, pp. 186-194, Sept. 1993, 
    % doi: 10.1109/87.251886.
    
    % X. R. Li , Y. Bar-Shalom and T. Kirubarajan,
    % Estimation with Applications to Tracking and Navigation: Theory, Algorithms, and Software.
    % New York: Wiley, 2001.
    
    % X. R. Li and V. P. Jilkov, 
    % "Survey of maneuvering target tracking. Part I. Dynamic models" 
    % in IEEE Transactions on Aerospace and Electronic Systems, vol. 39, no. 4, pp. 1333-1364, Oct. 2003, 
    % doi: 10.1109/TAES.2003.1261132.
    
end