function [estado, P] = inicializacao_KF(T, medicao, var_medicao, caracteristicas_alvo)
    
    % ERRO DO SENSOR
    dist = var_medicao(1); marc = var_medicao(2);                           
    
    % CARACTERÍSTICAS DO ALVO
    A = caracteristicas_alvo(1); p_0 = caracteristicas_alvo(2); 
    p_max = caracteristicas_alvo(3); ro = caracteristicas_alvo(4);          
    
    % RUÍDO DE PROCESSO
    m1 = (A^2*T^2/3)*(1+4*p_0-p_max);                                       % VARIÂNCIA DO MOVIMENTO RADIAL
    m2 = m1/(medicao(2,1)^2);                                                 % VARIÂNCIA DO MOVIMENTO ANGULAR
    Q = [m1*(1-ro^2)    0          ;
         0              m2*(1-ro^2)];                                       % MATRIZ COVARIÂNCIA DO RUÍDO DE PROCESSO

    % Inicialização
    P_corrigido = [dist     dist/T          0     	0       0               0;
                   dist/T   m1+(2*dist/T^2) ro*m1	0       0               0;
                   0        ro*m1           m1    	0       0               0;
                   0        0               0   	marc 	marc/T          0;
                   0        0               0       marc/T	m2+(2*marc/T^2) ro*m2;
                   0        0               0       0    	ro*m2           m2];

    estado_corrigido = [medicao(2,1);
                        (medicao(2,1)-medicao(1,1))/T;
                        0;
                        medicao(2,2);
                        (medicao(2,2)-medicao(1,2))/T;
                        0];
                    
    % RUÍDO DA MEDIÇAO
    R = [dist 0   ;
         0    marc];                                                        % MATRIZ COVARIÂNCIA DO RUÍDO DA MEDIÇÃO
    
    phi = [1 T 0  0 0 0 ;
           0 1 1  0 0 0 ;
           0 0 ro 0 0 0 ;
           0 0 0  1 T 0 ; 
           0 0 0  0 1 1 ; 
           0 0 0  0 0 ro];                                                  % MATRIZ DE EVOLUÇÃO DE ESTADOS
     
    G = [0 0;
         0 0;
         1 0;
         0 0;
         0 0;
         0 1];                                                              % MATRIZ DE RUÍDO DE PROCESSO

    % PREDIÇÃO
    estado = phi*estado_corrigido;
    P = phi*P_corrigido*phi'+G*Q*G';                 
    
    % R. A. Singer and K. W. Behnke 
    % "Real-Time Tracking Filter Evaluation and Selection for Tactical Applications" 
    % IEEE Transactions on Aerospace and Electronic Systems, vol. AES-7, no. 1, pp. 100-110, Jan. 1971
    % doi: 10.1109/TAES.1971.310257
end