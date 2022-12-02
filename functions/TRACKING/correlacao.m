function [caso,index] = correlacao(alvos, novos_contatos, medidas_cc, covariancia_cc, Ns, T, filtro)

    peso_correlacao = [];

    % CORRELACIONANDO COM ALVOS
    for i = 1:6:55
        if filtro == 3
            peso = 0;
            if alvos(i,1) > 0
                for j = 2:Ns+1
                    peso = peso + mvnpdf([alvos(i,j) alvos((i+3),j)], medidas_cc, 4*covariancia_cc);
                end
                peso_correlacao = [peso_correlacao; [alvos(i,1) peso]];
            else
                peso_correlacao = [peso_correlacao; [alvos(i,1) peso]];
            end
        else
            if alvos(i,1) > 0
                matriz_covar = [alvos(i,3) alvos(i,6);alvos(i+3,3) alvos(i+3,6)]+covariancia_cc;
                peso = mvnpdf([alvos(i,2) alvos(i+3,2)], medidas_cc, matriz_covar);
                peso_correlacao = [peso_correlacao; [alvos(i,1) peso]];
            else
                peso_correlacao = [peso_correlacao; [alvos(i,1) 0]];
            end
        end
    end
    
    if any(peso_correlacao(:,2)>0) == 1
        [value,index] = max(peso_correlacao(:,2));
        if length(index) > 1
            index = index(1);
        end
        caso = 1;
    else
        % CORRELACIONANDO COM NOVOS_CONTATOS
        peso_correlacao = [];
        for i = 1:length(novos_contatos(:,1))
            distancia = sqrt((medidas_cc(1)-novos_contatos(i,1))^2+(medidas_cc(2)-novos_contatos(i,2))^2);
            if (distancia > 70*T) && (distancia < 270*T)
                peso = 170*T-distancia;
                peso_correlacao = [peso_correlacao; peso];
            else
                peso_correlacao = [peso_correlacao; 0];
            end
        end
        
        if any(peso_correlacao > 0) == 1
            [value,index] = max(peso_correlacao);
        	if length(index) > 1
                index = index(1);
            end
        	caso = 2;
        else
          	caso = 3; index = 0;
        end
    end
end