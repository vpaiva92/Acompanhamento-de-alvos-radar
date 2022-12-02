function [estado_predito, sigma_predito] = UKF(estado_anterior, sigma_anterior, T, medicao, var_medicao, param_filtro)
    
    % MATRIZ DE MEDIÇÃO
    H = [1 0 0 0 0 0;
         0 0 0 1 0 0];

    % MATRIZ COVARIÂNCIA DA MEDIÇÃO
    var_x = var_medicao(1); var_y = var_medicao(2); covar_xy = var_medicao(3);
    R = [var_x covar_xy;covar_xy var_y];

    % ATUALIZAÇÃO
    [estado_corrigido, sigma_corrigido] = atualizacao_UKF(estado_anterior, sigma_anterior, T, medicao, R, H, param_filtro);

    % PREDIÇÃO
    [estado_predito, sigma_predito] = predicao_UKF(estado_corrigido, sigma_corrigido, T, param_filtro);

    % S. Thrun, W. Burgard and D. Fox,
    % Probabilistic Robotics (Intelligent Robotics and Autonomous Agents). 
    % Cambridge: The MIT Press, 2005.
    
    % C. Stachniss.
    % "Unscented Kalman Filter" (Aula gravada, Curso: "Robot Mapping")
    % Universidade de Freiburg, Alemanha, 2012. 
    
end    