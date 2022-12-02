function [estados] = inicializacao_PF2(Ns, T, medicao, var_medicao, caracteristicas_alvo)
    
    % ERRO DO SENSOR
    var_dist = var_medicao(1); var_marc = var_medicao(2);                           
    
    % CARACTERÍSTICAS DO ALVO
    tau = caracteristicas_alvo(1); a_max = caracteristicas_alvo(2);    
    alfa = 1/tau;
    
    % RUÍDO DO PROCESSO
    var_a = ((4-pi)/pi)*(a_max)^2;
    var_w = 2*alfa*var_a;
    
    % INICIALIZAÇÃO
    estado_corrigido = [medicao(2,1)*cos(medicao(2,2));
                        (medicao(2,1)*cos(medicao(2,2))-medicao(1,1)*cos(medicao(1,2)))/T;
                        500;
                        medicao(2,1)*sin(medicao(2,2));
                        (medicao(2,1)*sin(medicao(2,2))-medicao(1,1)*sin(medicao(1,2)))/T;
                        0];                                                        

    % PREDIÇÃO
    estados = [];
    for i = 1:Ns
        estado = A*estado_corrigido + B*[estado_corrigido(3);estado_corrigido(6)] + C*[normrnd(0,var_w);normrnd(0,var_w)];
        estados = [estados [estado;1/Ns]];
    end
    
    % KUMAR, K. S. P., & ZHOU, H.
    % "A “current” statistical model and adaptive algorithm for estimating maneuvering targets"  
    % Journal of Guidance, Control, and Dynamics, 7(5), 596–602, 1984
    % doi:10.2514/3.19900 
    
    % THRUN, S.; BURGARD, W.; & FOX, D.
    % Probabilistic robotics
    % Cambridge, MIT press, 647 pages, 2008.
    
end