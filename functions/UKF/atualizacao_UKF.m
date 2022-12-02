function [estado_corrigido, sigma_corrigido] = atualizacao_UKF(estado_predito, sigma_predito, T, medicao, R, H, param_filtro)

    % PARÂMETROS DO FILTRO
    kappa = param_filtro(1); alfa_delta = param_filtro(2); beta = param_filtro(3);
    lambda = (alfa_delta^2)*(length(estado_predito)+kappa)-length(estado_predito);
    
    % SIGMA_PONTOS
    sigma_pontos = sigma_pontos_UKF(estado_predito, sigma_predito, param_filtro);

    % PESOS
    w_m0 = lambda/(length(estado_predito)+lambda); 
    w_c0 = (lambda/(length(estado_predito)+lambda))+(1-(alfa_delta^2)+beta);
    w_m = 1/(2*(length(estado_predito)+lambda)); w_c = 1/(2*(length(estado_predito)+lambda));
    
    % NORMALIZANDO
    soma_wm = w_m0 + 12*w_m; soma_wc = w_c0 + 12*w_c;
    w_m0 = w_m0/soma_wm; w_m = w_m/soma_wm;
    w_c0 = w_c0/soma_wc; w_c = w_c/soma_wc;
    
    % ATUALIZAÇÃO 
    z = w_m0*(H*sigma_pontos(:,1));
    for i = 2:length(sigma_pontos)
        z = z + w_m*(H*sigma_pontos(:,i));
    end

    S = w_c0*((H*sigma_pontos(:,1)-z)*(H*sigma_pontos(:,1)-z)');
    for i = 2:length(sigma_pontos)
        S = S + w_c*((H*sigma_pontos(:,i)-z)*(H*sigma_pontos(:,i)-z)');
    end
    S = S + R;

    sigma_xz = w_c0*((sigma_pontos(:,1)-estado_predito)*(H*sigma_pontos(:,1)-z)');
    for i = 2:length(sigma_pontos)
        sigma_xz = sigma_xz + w_c*((sigma_pontos(:,i)-estado_predito)*(H*sigma_pontos(:,i)-z)');
    end
    
    % GANHO DE KALMAN
    K = sigma_xz*inv(S);

    estado_corrigido = estado_predito + K*(medicao'-z);
    sigma_corrigido = sigma_predito - K*S*K';

    % S. Thrun, W. Burgard and D. Fox,
    % Probabilistic Robotics (Intelligent Robotics and Autonomous Agents). 
    % Cambridge: The MIT Press, 2005.
    
    % C. Stachniss.
    % "Unscented Kalman Filter" (Aula gravada, Curso: "Robot Mapping")
    % Universidade de Freiburg, Alemanha, 2012. 
    
end