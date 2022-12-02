function [estado_predito, P_predito] = predicao_EKF_fmod(estado_corrigido, P_corrigido, T)
    
    estado_predito = modelo_alvo(estado_corrigido, T);
    
    % PARÂMETROS ALVO
    w = estado_predito(6);
    tau = estado_predito(3);
    alfa = 1/tau;
    beta = exp(-alfa*T);
    
    % VARIÂNCIA RUÍDO DE PROCESSO
    sigma_a = 5;
    sigma_w = 2*alfa*(((4-pi)/pi)*(30-abs(w))^2);
    sigma_tau = 10;
    
    % MATRIZES RUÍDO DE PROCESSO
    if w > 0.001
        Q1 = [2*(w*T-sin(w*T))/w^3	(1-cos(w*T))/w^2    0	0                       (w*T-sin(w*T))/w^2	0;
              (1-cos(w*T))/w^2   	T                   0	-(w*T-sin(w*T))/w^2     0                   0;
              0                   	0                   0	0                       0                   0;
              0                     -(w*T-sin(w*T))/w^2 0   2*(w*T-sin(w*T))/w^2    (1-cos(w*T))/w^2    0;
              (w*T-sin(w*T))/w^2    0                   0   (1-cos(w*T))/w^2        T                   0;
              0                     0                   0   0                       0                   1];
    else
        Q1 = [0	0 0	0 0	0;
              0 T 0	0 0 0;
              0 0 0	0 0 0;
              0 0 0 0 0 0;
              0 0 0 0 T 0;
              0 0 0 0 0 1];
    end
      
    Q2 = [(T^4)/4*sigma_a	(T^2)/2*sigma_a     0           0               0             	0;
          (T^2)/2*sigma_a   T^2*sigma_a         0           0               0            	0;
          0                 0                   sigma_tau   0               0              	0;
          0                 0                   0           (T^4)/4*sigma_a	(T^2)/2*sigma_a	0;
          0                 0                   0           (T^2)/2*sigma_a	T^2*sigma_a   	0;
          0                 0                   0           0               0               0];
      
    Q = sigma_w*Q1 + Q2;
         
    % MATRIZ EVOLUÇÃO DE ESTADO
    if w > 0.001
        F = [1  sin(w*T)/w      0   0   -(1-cos(w*T))/w ((w*T*cos(w*T)-sin(w*T))/w^2)*estado_predito(2)-((w*T*sin(w*T)+cos(w*T)-1)/w^2)*estado_predito(5);
             0  cos(w*T)        0   0   -sin(w*T)       -T*sin(w*T)*estado_predito(2)-T*cos(w*T)*estado_predito(5)                                       ;
             0  0               0   0   0               0                                                                                                ;
             0  (1-cos(w*T))/w  0   1   sin(w*T)/w      ((w*T*sin(w*T)+cos(w*T)-1)/w^2)*estado_predito(2)-((w*T*cos(w*T)-sin(w*T))/w^2)*estado_predito(2);
             0  sin(w*T)        0   0   cos(w*T)        T*cos(w*T)*estado_predito(2)-T*sin(w*T)*estado_predito(5)                                        ;
             0  0               0   0   0               beta                                                                                             ];
    else
        F = [1  T               0   0   -(w*T^2)/2      -(T^2)/2*estado_predito(5)                    ;
             0  (1-(w*T)^2)/2   0   0   -(w*T)          -(w*T^2)*estado_predito(2)-T*estado_predito(5);
             0  0               0   0   0               0                                             ;
             0  (w*T^2)/2       0   1   T               (T^2)/2*estado_predito(2)                     ;
             0  (w*T)           0   0   (1-(w*T)^2)/2   T*estado_predito(2)-(w*T^2)*estado_predito(5) ;
             0  0               0   0   0               beta];
    end

    P_predito = F*P_corrigido*F'+Q;
    
    % X. R. Li and Y. Bar-Shalom, 
    % "Design of an interacting multiple model algorithm for air traffic control tracking" 
    % in IEEE Transactions on Control Systems Technology, vol. 1, no. 3, pp. 186-194, Sept. 1993, 
    % doi: 10.1109/87.251886.
    
    % X. R. Li and V. P. Jilkov, 
    % "Survey of maneuvering target tracking. Part I. Dynamic models" 
    % in IEEE Transactions on Aerospace and Electronic Systems, vol. 39, no. 4, pp. 1333-1364, Oct. 2003, 
    % doi: 10.1109/TAES.2003.1261132.
    
end