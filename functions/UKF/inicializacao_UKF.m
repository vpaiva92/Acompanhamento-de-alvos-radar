function [estado_predito, sigma_predito] = inicializacao_UKF(T, medicao, var_medicao, param_filtro)  
    
    % ERRO DO SENSOR
    var_x = var_medicao(1); var_y = var_medicao(2); covar_xy = var_medicao(3);
    tau = 500;
    alfa = 1/tau;
    
    % INICIALIZAÇÃO
    sigma_corrigido = [var_x    var_x/T             0     	covar_xy	0                   0;
                       var_x/T  (2*var_x/T^2)+10	0   	0           0                   0;
                       0        0                   30    	0           0                   0;
                       covar_xy 0                   0   	var_y       var_y/T             0;
                       0        0                   0       var_y/T     (2*var_y/T^2)+10 	0;
                       0        0                   0       0           0                   2*alfa*5];
    
    estado_corrigido = [medicao(2,1);
                        (medicao(2,1)-medicao(1,1))/T;
                        tau;
                        medicao(2,2);
                        (medicao(2,2)-medicao(1,2))/T;
                        0];
    
    % PREDIÇÃO
    [estado_predito, sigma_predito] = predicao_UKF(estado_corrigido, sigma_corrigido, T, param_filtro);
    
    % R. A. Singer, 
    % "Estimating Optimal Tracking Filter Performance for Manned Maneuvering Targets" 
    % in IEEE Transactions on Aerospace and Electronic Systems, vol. AES-6, no. 4, pp. 473-483, July 1970, 
    % doi: 10.1109/TAES.1970.310128.
    
    % R. A. Singer and K. W. Behnke, 
    % "Real-Time Tracking Filter Evaluation and Selection for Tactical Applications" 
    % in IEEE Transactions on Aerospace and Electronic Systems, vol. AES-7, no. 1, pp. 100-110, Jan. 1971, 
    % doi: 10.1109/TAES.1971.310257.
    
    % X. R. Li , Y. Bar-Shalom and T. Kirubarajan,
    % Estimation with Applications to Tracking and Navigation: Theory, Algorithms, and Software.
    % New York: Wiley, 2001.
    
    % S. Thrun, W. Burgard and D. Fox,
    % Probabilistic Robotics (Intelligent Robotics and Autonomous Agents). 
    % Cambridge: The MIT Press, 2005.
    
end