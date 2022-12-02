function [correlacionados] = correlacao2(alvos, novos_contatos, medidas_cc, Ns, T, filtro) 
    %% INICIALIZANDO MATRIZES
    peso_correlacao = []; 
    
    H = [1 0 0 0 0 0;
         0 0 0 1 0 0];
    
    correlacionados = [];
     
    %% GATING COM ALVOS
    G = 4.605;
    for i = 1:length(medidas_cc(:,1))
        peso_medida = [];
        n = 0;
        for j = 1:6:55
            if filtro == 3 % PF
                peso = 0;
                if alvos(j,1) > 0
                    for k = 2:Ns+1
                        peso = peso + mvnpdf([alvos(j,k) alvos((j+3),k)], medidas_cc(i,1:2), 5*[medidas_cc(i,3) medidas_cc(i,5);medidas_cc(i,5) medidas_cc(i,4)]);
                    end
                    peso_medida = [peso_medida peso];
                else
                    peso_medida = [peso_medida peso];
                end
                
            else % EKF / UKF
                vetor_residual = [alvos(j,2) alvos(j+3,2)]-medidas_cc(i,1:2);
                norma = vetor_residual * (H*alvos(j:j+5,3:8)*H' + [medidas_cc(i,3) medidas_cc(i,5);medidas_cc(i,5) medidas_cc(i,4)]) * vetor_residual';
                if norma < G
                	peso_medida = [peso_medida norma];
                    n = 1;
                else
                	peso_medida = [peso_medida 0];
                end
            end
        end
        peso_correlacao = [peso_correlacao; peso_medida n];
    end  
    
    %% ASSOCIAÇÃO COM ALVOS    
    % NORMALIZANDO 
    for i = 1:length(peso_correlacao(:,1)) 
        if filtro == 3 % PF
            if any(peso_correlacao(i,1:10)>0) == 1
                peso_correlacao(i,1:10) = peso_correlacao(i,1:10)/sum(peso_correlacao(i,1:10));
            end
        else % EKF / UKF
            if peso_correlacao(i,11) == 1
                peso_correlacao(i,1:10) = peso_correlacao(i,1:10)/sum(peso_correlacao(i,1:10));
            end
        end
    end
    
    % ASSOCIANDO MEDIÇÃO
    for index_alvo = 1:10
        if filtro == 3 % PF
            if any(peso_correlacao(1:length(peso_correlacao(:,1)),index_alvo)>0) == 1
                [value,index_medida] = max(peso_correlacao(1:length(peso_correlacao(:,1)),index_alvo));
                correlacionados = [correlacionados;[index_medida index_alvo 1]];
            end
        else
            [value,index_medida] = min(peso_correlacao(1:length(peso_correlacao(:,1)),index_alvo));
            if value == 0
                if peso_correlacao(index_medida,11) == 1
                    correlacionados = [correlacionados;[index_medida index_alvo 1]];
                end
            else
                correlacionados = [correlacionados;[index_medida index_alvo 1]];
            end
        end
    end
    
    if isempty(correlacionados) == 0
        for i = 1:length(correlacionados(:,1))
            medidas_cc(correlacionados(i,1),:) = [0 0 0 0 0];
        end
    end
    
    %% ASSOCIAÇÃO COM NOVOS CONTATOS
    peso_correlacao_novos = [];
    for i = 1:length(medidas_cc(:,1))
        peso_medida = [];
        for j = 1:length(novos_contatos(:,1))
            distancia = sqrt((medidas_cc(i,1)-novos_contatos(j,1))^2+(medidas_cc(i,2)-novos_contatos(j,2))^2);
            if (distancia > 30*T) && (distancia < 270*T)
                peso = 150*T-distancia;
                peso_medida = [peso_medida peso];
            else
                peso_medida = [peso_medida 0];
            end
        end
        peso_correlacao_novos = [peso_correlacao_novos; peso_medida];
    end
        
    % NORMALIZANDO
    for i = 1:length(peso_correlacao_novos(:,1))
        if any(peso_correlacao_novos(i,1:length(peso_correlacao_novos(1,:)))>0) == 1
            peso_correlacao_novos(i,:) = peso_correlacao_novos(i,:)/sum(peso_correlacao_novos(i,:));
        end
    end
        
    % ASSOCIANDO MEDIÇÃO
    for index_contato = 1:length(peso_correlacao_novos(:,1))
        if any(peso_correlacao_novos(1:length(peso_correlacao_novos(:,1)),index_contato)>0) == 1
            [value,index_medida] = max(peso_correlacao_novos(1:length(peso_correlacao_novos(:,1)),index_contato));
            correlacionados = [correlacionados;[index_medida index_contato 2]];
        end
    end
    
    if isempty(correlacionados) == 0
        for i = 1:length(correlacionados(:,1))
            medidas_cc(correlacionados(i,1),:) = [0 0 0 0 0];
        end
    end
    
    %% MEDIÇÕES NÃO ASSOCIADAS
    for index_medida = 1:length(medidas_cc(:,1))
        if medidas_cc(index_medida,:) ~= [0 0 0 0 0]
            correlacionados = [correlacionados;[index_medida 0 3]];
        end
    end
    
    % P. Konstantinova and A. Udvarev and T. Semerdjiev
    % "A study of a target tracking algorithm using global nearest neighbor approach."
    % DOI: 10.1145/973620.973668, 2003.
    
    % Y. Bar-Shalom and T. E. Fortmann,
    % Tracking and Data Association
    % New York, Academic Press, 1988.
    
end