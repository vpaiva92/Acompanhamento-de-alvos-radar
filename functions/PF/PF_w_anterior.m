function estados_preditos = PF_w_anterior(estados, Ns, T, medicao, var_medicao)
    
    % RUÍDO MEDIÇÃO
    var_x = var_medicao(1); var_y = var_medicao(2); covar_xy = var_medicao(3);
    sigma = [4*var_x 4*covar_xy;4*covar_xy 4*var_y];
    
    % ATUALIZAÇÃO
    peso_estados_atualizados = [];
    for i = 1:Ns
        peso = mvnpdf([estados(1,i) estados(4,i)],medicao,sigma);
        peso_estados_atualizados = [peso_estados_atualizados peso];
    end
    peso_estados_atualizados = peso_estados_atualizados/sum(peso_estados_atualizados);
    
    % REAMOSTRAGEM
    estados_corrigidos = [];
    amostras = randsample(Ns,Ns,true,peso_estados_atualizados);
    for i = 1:Ns
        estados_corrigidos = [estados_corrigidos estados(1:6,amostras(i))];
    end

    % PREDIÇÃO
    estados_preditos = [];
    for i = 1:Ns
        estado = modelo_alvo_w_anterior(estados_corrigidos(1:6,i),T);
        estados_preditos = [estados_preditos estado];
    end
    
    % S. Thrun, W. Burgard and D. Fox,
    % Probabilistic Robotics (Intelligent Robotics and Autonomous Agents). 
    % Cambridge: The MIT Press, 2005.
    
    % C. Stachniss. 
    % "Particle Filter and Monte Carlo Localization" (Aula gravada, Curso: "Mobile Sensing and Robotics")
    % Universidade de Bonn, Alemanha, 2020.  
    
end