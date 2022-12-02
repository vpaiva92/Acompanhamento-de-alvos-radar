function [alvos, novos_contatos] = atualizacao (alvos, novos_contatos, T, Ns, filtro)

    % RETIRANDO NOVOS CONTATOS NÃO CORRELACIONADOS
    for i = 1:20
        if novos_contatos(i,3) == 2
            novos_contatos(i:20,:) = [novos_contatos(i+1:20,:);[0 0 0]];
        elseif novos_contatos(i,3) == 1
            novos_contatos(i,3) = 2;
        end
    end
    
    for i = 1:6:55
        if alvos(i,1) > 0
            if alvos(i+1,1) == 0 % ALVOS NÃO ACOMPANHADOS

                % AUMENTANDO CONTADOR DE ACOMPANHAMENTO
                alvos(i+2,1) = alvos(i+2,1) + 1;

                % RETIRANDO ALVOS NÃO CORRELACIONADOS DEPOIS DE 3 VEZES
                if alvos(i+2,1) == 4
                    alvos(i:60,1:length(alvos(1,:))) = [alvos(i+6:60,1:length(alvos(1,:)));zeros(6,length(alvos(1,:)))];
                end
                
                % RETIRANDO ALVOS COM VELOCIDADES NÃO COMPATÍVEIS
                %if filtro(1) == 3 % PF
                %    velocidade = sqrt((sum(alvos(i+1,2:Ns+1))/Ns)^2+((sum(alvos(i+4,2:Ns+1))/Ns)^2));
                %    if velocidade < 30*T
                %        alvos(i:60,1:length(alvos(1,:))) = [alvos(i+6:60,1:length(alvos(1,:)));zeros(6,length(alvos(1,:)))];
                %    end
                %else % UKF e PF
                %    velocidade = sqrt(alvos(i+1,2)^2+alvos(i+4,2)^2);
                %    if velocidade < 30*T
                %        alvos(i:60,1:length(alvos(1,:))) = [alvos(i+6:60,1:length(alvos(1,:)));zeros(6,length(alvos(1,:)))];
                %    end
                %end
                    
                % PRÓXIMA PREDIÇÃO DOS ALVOS QUE NÃO FORAM CORRELACIONADOS
                if filtro(1) == 1 % EKF
                    estado_anterior = alvos(i:i+5,2); P_anterior = alvos(i:i+5,3:8);
                    [estado_predito, P_predito] = predicao_EKF(estado_anterior, P_anterior, T);
                    alvos(i:i+5,2) = estado_predito; alvos(i:i+5,3:8) = P_predito;    
                elseif filtro(1) == 2 % UKF
                    estado_anterior = alvos(i:i+5,2); sigma_anterior = alvos(i:i+5,3:8);
                    [estado_predito, sigma_predito] = predicao_UKF(estado_anterior, sigma_anterior, T, filtro(2));
                    alvos(i:i+5,2) = estado_predito; alvos(i:i+5,3:8) = sigma_predito;    
                elseif filtro(1) == 3 % PF
                    estados_anteriores = alvos(i:i+5,2:Ns+1);
                    [estados_preditos] = predicao_PF(estados_anteriores, Ns, T);
                    alvos(i:i+5,2:Ns+1) = estados_preditos;
                    % PLOTAGEM
                    %display('atualiza')
                    %nome_contato = join(['contato',int2str(alvos(i,1))]); 
                    %sz = 90;
                    %predicao = sum(estados_preditos,2)/Ns;
                    %scatter(predicao(1),predicao(4),sz,'square','green')
                    %text(predicao(1)+110,predicao(4)-110,nome_contato)
                    %xlim([-16000 16000])
                    %ylim([-12000 12000])
                end

            else % REINICIANCO CONTROLE DE ACOMPANHAMENTO
                alvos(i+1,1) = 0;
            end
        end
    end
end