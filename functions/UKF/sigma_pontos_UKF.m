function [sigma_pontos] = sigma_pontos_UKF(estado, sigma, param_filtro)

    % PARÂMETROS FILTRO
    kappa = param_filtro(1); alfa_delta = param_filtro(2);
    lambda = ((alfa_delta^2)*(length(estado)+kappa))-length(estado);            
    
    % SIGMA PONTOS
    delta_sigma = real(sqrtm((length(estado)+lambda)*sigma));
    sigma_pontos = [estado];
    for i = 1:length(estado)
        sigma_pontos =[sigma_pontos estado+delta_sigma(:,i) estado-delta_sigma(:,i)];
    end
    
    % S. Thrun, W. Burgard and D. Fox,
    % Probabilistic Robotics (Intelligent Robotics and Autonomous Agents). 
    % Cambridge: The MIT Press, 2005.
    
    % C. Stachniss.
    % "Unscented Kalman Filter" (Aula gravada, Curso: "Robot Mapping")
    % Universidade de Freiburg, Alemanha, 2012. 
    
end