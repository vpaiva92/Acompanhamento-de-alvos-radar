function [estados_preditos] = predicao_PF(estados, Ns, T)
    
    % REAMOSTRAGEM
    estados_corrigidos = [];
    amostras = randsample(Ns,Ns);
    for i = 1:Ns
        estados_corrigidos = [estados_corrigidos estados(1:6,amostras(i))];
    end

    % PREDIÇÃO
    estados_preditos = [];
    for i = 1:Ns
        estado = modelo_alvo(estados_corrigidos(1:6,i),T);
        estados_preditos = [estados_preditos estado];
    end
end