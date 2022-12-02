function [estado_predito, P_predito] = EKF_fmod(estado_anterior, P_anterior, T, medicao, var_medicao)

    % MATRIZ DE MEDIÇÃO
    H = [1 0 0 0 0 0;
         0 0 0 1 0 0];

    % MATRIZ COVARIÂNCIA DA MEDIÇÃO
    var_x = var_medicao(1); var_y = var_medicao(2); covar_xy = var_medicao(3);
    R = [var_x covar_xy;covar_xy var_y];

    % ATUALIZAÇÃO
    [estado_corrigido, P_corrigido] = atualizacao_EKF(estado_anterior, P_anterior, medicao, H, R);
    
    % PREDIÇÃO
    [estado_predito, P_predito] = predicao_EKF_fmod(estado_corrigido, P_corrigido, T);

    % X. R. Li , Y. Bar-Shalom and T. Kirubarajan,
    % Estimation with Applications to Tracking and Navigation: Theory, Algorithms, and Software.
    % New York: Wiley, 2001.
    
    % S. Thrun, W. Burgard and D. Fox,
    % Probabilistic Robotics (Intelligent Robotics and Autonomous Agents). 
    % Cambridge: The MIT Press, 2005.
end