function [estado_predito, sigma_predito] = predicao_UKF(estado_corrigido, sigma_corrigido, T, param_filtro)
    
    % PARÂMETROS DO ALVO
    w = estado_corrigido(6);
    tau = estado_corrigido(3);
    alfa = 1/tau;

    % PARÂMETROS DO FILTRO
    kappa = param_filtro(1); alfa_delta = param_filtro(2); beta = param_filtro(3);
    lambda = (alfa_delta^2)*(length(estado_corrigido)+kappa)-length(estado_corrigido);
    
    % SIGMA_PONTOS
    sigma_pontos = sigma_pontos_UKF(estado_corrigido, sigma_corrigido, param_filtro);

    % VARIÂNCIA RUÍDO DE PROCESSO
    sigma_a = 5;
    sigma_w = 2*alfa*(((4-pi)/pi)*(30-abs(w))^2);
    sigma_tau = 10;
    
    % PESOS
    w_m0 = lambda/(length(estado_corrigido)+lambda); 
    w_c0 = (lambda/(length(estado_corrigido)+lambda))+(1-(alfa_delta^2)+beta);
    w_m = 1/(2*(length(estado_corrigido)+lambda)); w_c = 1/(2*(length(estado_corrigido)+lambda));

    % NORMALIZANDO
    soma_wm = w_m0 + 12*w_m; soma_wc = w_c0 + 12*w_c;
    w_m0 = w_m0/soma_wm; w_m = w_m/soma_wm;
    w_c0 = w_c0/soma_wc; w_c = w_c/soma_wc;

    % PREDIÇÃO
    sigma_pontos_preditos = [];
    for i = 1:length(sigma_pontos)
        sigma_predito = modelo_alvo(sigma_pontos(:,i),T);
        sigma_pontos_preditos = [sigma_pontos_preditos sigma_predito];
    end
    
    estado_predito = w_m0*sigma_pontos_preditos(:,1);

    for i = 2:length(sigma_pontos_preditos)
        estado_predito = estado_predito + w_m*sigma_pontos_preditos(:,i);
    end

    w = estado_predito(6);
    
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
      
    Q2 = [(T^4)/4*sigma_a	(T^3)/2*sigma_a     0           0               0             	0;
          (T^3)/2*sigma_a   T^2*sigma_a         0           0               0            	0;
          0                 0                   sigma_tau   0               0              	0;
          0                 0                   0           (T^4)/4*sigma_a	(T^3)/2*sigma_a	0;
          0                 0                   0           (T^3)/2*sigma_a	T^2*sigma_a   	0;
          0                 0                   0           0               0               0];
      
    Q = sigma_w*Q1 + Q2;
    
    sigma_predito = w_c0*((sigma_pontos_preditos(:,1)-estado_predito)*(sigma_pontos_preditos(:,1)-estado_predito)');
    for i = 2:length(sigma_pontos_preditos)
        sigma_predito = sigma_predito + w_c*((sigma_pontos_preditos(:,i)-estado_predito)*(sigma_pontos_preditos(:,i)-estado_predito)');
    end

    sigma_predito = sigma_predito + Q;
 
    % X. R. Li and Y. Bar-Shalom, 
    % "Design of an interacting multiple model algorithm for air traffic control tracking" 
    % in IEEE Transactions on Control Systems Technology, vol. 1, no. 3, pp. 186-194, Sept. 1993, 
    % doi: 10.1109/87.251886.
    
    % X. R. Li and V. P. Jilkov, 
    % "Survey of maneuvering target tracking. Part I. Dynamic models" 
    % in IEEE Transactions on Aerospace and Electronic Systems, vol. 39, no. 4, pp. 1333-1364, Oct. 2003, 
    % doi: 10.1109/TAES.2003.1261132.
    
    % X. R. Li , Y. Bar-Shalom and T. Kirubarajan,
    % Estimation with Applications to Tracking and Navigation: Theory, Algorithms, and Software.
    % New York: Wiley, 2001.
    
    % S. Thrun, W. Burgard and D. Fox,
    % Probabilistic Robotics (Intelligent Robotics and Autonomous Agents). 
    % Cambridge: The MIT Press, 2005.
    
    % C. Stachniss.
    % "Unscented Kalman Filter" (Aula gravada, Curso: "Robot Mapping")
    % Universidade de Freiburg, Alemanha, 2012. 
    
end