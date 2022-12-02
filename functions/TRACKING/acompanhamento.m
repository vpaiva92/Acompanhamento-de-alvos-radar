function [alvos,novos_contatos,n]=acompanhamento(alvos, novos_contatos, medicao, var_sensor, filtro, Ns, T, n)

    % RUÍDO DA MEDIÇÃO
    var_dist = var_sensor(1); var_marc = var_sensor(2);
    aii = cosh(2*var_marc); ai = cosh(var_marc);
    bii = sinh(2*var_marc); bi = sinh(var_marc);
    c = (cos(medicao(2)))^2; d = (sin(medicao(2)))^2;
    var_x = ((medicao(1))^2)*exp(-2*var_marc)*[c*(aii-ai)+d*(bii-bi)]+var_dist*exp(-2*var_marc)*[c*(2*aii-ai)+d*(2*bii-bi)];
    var_y = ((medicao(1))^2)*exp(-2*var_marc)*[d*(aii-ai)+c*(bii-bi)]+var_dist*exp(-2*var_marc)*[d*(2*aii-ai)+c*(2*bii-bi)];
    covar_xy = sin(medicao(2))*cos(medicao(2))*exp(-4*var_marc)*[var_dist+(((medicao(1))^2)+var_dist)*(1-exp(var_marc))];
    var_medicao = [var_x var_y covar_xy];
    covariancia_cc = [var_x      covar_xy;
                      covar_xy   var_y   ];

    % MEDIDAS EM COORDENADAS CARTESIANAS
    medidas_cc = [medicao(1)*cos(medicao(2)) medicao(1)*sin(medicao(2))];
    
    % IDENTIFICANDO CASO E CORRELACIONANDO
    [caso,index] = correlacao(alvos, novos_contatos(:,1:2), medidas_cc, covariancia_cc, Ns, T, filtro(1));
    
    if caso == 1 % MEDIDA CORRELACIONADA COM ALVO
        index = 6*(index-1)+1;
        
        % CONTAGEM DE VEZES SEM CORRELACIONAR
        alvos(index+1,1) = 1; alvos(index+2,1) = 0;
        
        % PLOTAGEM
        nome_alvo = join(['contato',int2str(alvos(index,1))]);
        sz = 90;
        scatter(medidas_cc(1),medidas_cc(2),sz,'square','green')
        text(medidas_cc(1)+110,medidas_cc(2)-110,nome_alvo)
        
        % FILTRO E PRÓXIMA PREDIÇÃO
        if filtro(1) == 1 % EKF
            estado_anterior = alvos(index:index+5,2); P_anterior = alvos(index:index+5,3:8);
            [estado_predito, P_predito] = EKF(estado_anterior, P_anterior, T, medidas_cc, var_medicao);
            alvos(index:index+5,2) = estado_predito; alvos(index:index+5,3:8) = P_predito;    
        elseif filtro(1) == 2 % UKF
            estado_anterior = alvos(index:index+5,2); sigma_anterior = alvos(index:index+5,3:8);
            [estado_predito, sigma_predito] = UKF(estado_anterior, sigma_anterior, T, medidas_cc, var_medicao, [filtro(2) filtro(3) filtro(4)]);
            alvos(index:index+5,2) = estado_predito; alvos(index:index+5,3:8) = sigma_predito;    
        elseif filtro(1) == 3 % PF
            estados_anteriores = alvos(index:index+5,2:Ns+1);
            [estados_preditos] = PF(estados_anteriores, Ns, T, medidas_cc, var_medicao);
            alvos(index:index+5,2:Ns+1) = estados_preditos;
            % PLOTAGEM
            display('plot acompanhamento')
            nome_contato = join(['contato',int2str(alvos(index,1))]); 
            sz = 90;
            predicao = sum(estados_preditos,2)/Ns;
            scatter(predicao(1),predicao(4),sz,'square','green')
            text(predicao(1)+110,predicao(4)-110,nome_contato)
            xlim([-16000 16000])
            ylim([-12000 12000])
        end
        
    elseif caso == 2 % INÍCIO DE ACOMPANHAMENTO

        n = n + 1;
        nome_contato = join(['contato',int2str(n)]); 
        medidas_ini = [novos_contatos(index,1:2); medidas_cc];
        novos_contatos(index:length(novos_contatos),:) = [novos_contatos(index+1:length(novos_contatos),:);[0 0 0]];
        
        % PLOTAGEM
        sz = 90;
        scatter(medidas_cc(1),medidas_cc(2),sz,'square','green')
        text(medidas_cc(1)+110,medidas_cc(2)-110,nome_contato)
        
        % INICIALIZAÇÃO DO FILTRO E PRIMEIRA PREDIÇÃO
        alvos_acompanhados = [];
        for i = 1:6:55
            alvos_acompanhados = [alvos_acompanhados;alvos(i,1)];
        end
        index = nnz(alvos_acompanhados)*6 + 1;

        alvos(index+1,1) = 1; alvos(index,1) = n;
        if filtro(1) == 1 % EKF
         	[estado_predito, P_predito] = inicializacao_EKF(T, medidas_ini, var_medicao);
           	alvos(index:index+5,2) = estado_predito; alvos(index:index+5,3:8) = P_predito;
      	elseif filtro(1) == 2 % UKF
           	[estado_predito, sigma_predito] = inicializacao_UKF(T, medidas_ini, var_medicao, filtro(2));
           	alvos(index:index+5,2) = estado_predito; alvos(index:index+5,3:8) = sigma_predito;
      	elseif filtro(1) == 3 % PF
           	[estados_preditos] = inicializacao_PF(Ns, T, medidas_ini);
           	alvos(index:index+5,2:Ns+1) = estados_preditos;
            % PLOTAGEM
            %sz = 90;
            %predicao = sum(estados_preditos,2)/Ns;
            %scatter(predicao(1),predicao(4),sz,'square','green')
            %text(predicao(1)+110,predicao(4)-110,nome_contato)
            %xlim([-13000 13000])
            %ylim([-13000 13000])
        end
        
        
        
    elseif caso == 3 % PRIMEIRA OBSERVAÇÃO
        
        pos = nnz(novos_contatos(:,1));
        novos_contatos(pos+1,:) = [medidas_cc 1];
        
    end
        
end