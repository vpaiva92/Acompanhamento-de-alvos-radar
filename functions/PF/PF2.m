function [acomp,estados_preditos] = PF2(estados, Ns, T, medicao, var_medicao, caracteristicas_alvo)
    
    % RUÍDO MEDIÇÃO
    var_x = var_medicao(1); var_y = var_medicao(2); covar_xy = var_medicao(3);
    
    % ATUALIZAÇÃO
    peso_estados_atualizados = [];
    for i = 1:Ns
        peso = mvnpdf([estados(1,i) estados(4,i)],mu,sigma);
        peso_estados_atualizados = [peso_estados_atualizados peso];
    end
    peso_estados_atualizados = peso_estados_atualizados/sum(peso_estados_atualizados);
    
    % REAMOSTRAGEM
    estados_corrigidos = [];
    amostras = randsample(Ns,Ns,true,peso_estados_atualizados);
    for i = 1:Ns
        estados_corrigidos = [estados_corrigidos [estados(1:6,amostras(i));1/Ns]];
    end

    % PREDIÇÃO
    estados_preditos = [];
    for i = 1:Ns
        estado = modelo_dinamico_1(estados_corrigidos(1:6;i),T);
        estados_preditos = [estados_preditos estado];
    end
    
    % THRUN, S.; BURGARD, W.; & FOX, D.
    % Probabilistic robotics
    % MIT press, 647 pages, 2008.
    
end