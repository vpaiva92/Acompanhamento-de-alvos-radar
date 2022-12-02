function [estados] = inicializacao_PF_w_anterior(Ns, T, medicao)

    % INICIALIZAÇÃO
    estado_corrigido = [medicao(2,1);
                        (medicao(2,1)-medicao(1,1))/T;
                        500;
                        medicao(2,2);
                        (medicao(2,2)-medicao(1,2))/T;
                        0];                                                        

    % PREDIÇÃO
    estados = [];
    for i = 1:Ns
        estado = modelo_alvo_w_anterior(estado_corrigido,T);
        estados = [estados [estado]];
    end
    
    % S. Thrun, W. Burgard and D. Fox,
    % Probabilistic Robotics (Intelligent Robotics and Autonomous Agents). 
    % Cambridge: The MIT Press, 2005.
    
    % C. Stachniss. 
    % "Particle Filter and Monte Carlo Localization" (Aula gravada, Curso: "Mobile Sensing and Robotics")
    % Universidade de Bonn, Alemanha, 2020. 
    
end