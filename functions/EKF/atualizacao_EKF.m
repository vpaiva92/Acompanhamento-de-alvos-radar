function [estado_corrigido,P_corrigido] = atualizacao_EKF(estado_predito, P_predito, medicao, H, R)

    % CÁLCULO GANHO DE KALMAN
    K = P_predito*H'*inv(H*P_predito*H' + R);

    % ATUALIZAÇÃO
    estado_corrigido = estado_predito+K*(medicao'-H*estado_predito);
    P_corrigido = (eye(6)-K*H)*P_predito;
    
    % X. R. Li , Y. Bar-Shalom and T. Kirubarajan,
    % Estimation with Applications to Tracking and Navigation: Theory, Algorithms, and Software.
    % New York: Wiley, 2001.
    
    % S. Thrun, W. Burgard and D. Fox,
    % Probabilistic Robotics (Intelligent Robotics and Autonomous Agents). 
    % Cambridge: The MIT Press, 2005.
    
end