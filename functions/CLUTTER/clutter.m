clear all;
close all;
clc;
%% Leitura do Arquivo CSV
filename = 'captura 2 - 8rpm.csv';
M = [csvread(filename)];
clear filename;

%% variaveos
azmt = M(1,2);
volta = 1;
impar = 73; par = 72;
for k=1:size(M,1)
    azmt_ant = azmt;
    
    M(k,2) = mod(M(k,2)+(ceil(volta/2)-1)*impar+floor(volta/2)*par,7500);
    azmt = M(k,2);
    if azmt<azmt_ant
        volta = volta+1;
        if mod(volta,2) == 1
            M(k,2) = M(k,2)+73;
        else
            M(k,2) = M(k,2)+72;
        end
    end
end
%% Salvando matriz M corrigida
save('M.mat','M')
%% Loop que realiza comparações entre quatro revolucoes consecutivas
% vetor de saida indicado pela matriz pontos
volta = 1;
apaga = true;
azmt = M(1,2);
pontos = [];
pontos_4 = [];
pontos_3 = [];
pontos_2 = [];
pontos_1 = [];
for k=1:size(M,1)
    azmt_ant = azmt;
    azmt = M(k,2);
    if azmt < azmt_ant
        if size(pontos_4,1)~= 0
            % vetor que indicara a repeticao de info de uma volta em
            % relacao a outra
            rep = zeros(size(pontos,1),4); 
            
            % comp volta 1 com volta 5
            for p=1:size(pontos,1)
                for q=1:size(pontos_1,1)
                    logic_azmt = pontos(p,1) <= pontos_1(q,1)+2 & pontos(p,1) >= pontos_1(q,1)-2;
                    logic_dist = pontos(p,2) <= pontos_1(q,2)+50 & pontos(p,2) >= pontos_1(q,2) - 50;
                    if logic_azmt & logic_dist
                        rep(p,1) = 1;
                    end
                end
            end
            % comp volta 2 com volta 5
            for p=1:size(pontos,1)
                for q=1:size(pontos_2,1)
                    logic_azmt = pontos(p,1) <= pontos_2(q,1)+2 & pontos(p,1) >= pontos_2(q,1)-2;
                    logic_dist = pontos(p,2) <= pontos_2(q,2)+50 & pontos(p,2) >= pontos_2(q,2)-50;
                    if logic_azmt & logic_dist
                        rep(p,2) = 1;
                    end
                end
            end
            % comp volta 3 com volta 5
            for p=1:size(pontos,1)
                for q=1:size(pontos_3,1)
                    logic_azmt = pontos(p,1) <= pontos_3(q,1)+2 & pontos(p,1) >= pontos_3(q,1)-2;
                    logic_dist = pontos(p,2) <= pontos_3(q,2)+50 & pontos(p,2) >= pontos_3(q,2)-50;
                    if logic_azmt & logic_dist
                        rep(p,3) = 1;
                    end
                end
            end
            % comp volta 4 com volta 5
            for p=1:size(pontos,1)
                for q=1:size(pontos_4,1)
                    logic_azmt = pontos(p,1) <= pontos_3(q,1)+2 & pontos(p,1) >= pontos_3(q,1)-2;
                    logic_dist = pontos(p,2) <= pontos_4(q,2)+50 & pontos(p,2) >= pontos_4(q,2)-50;
                    if logic_azmt & logic_dist
                        rep(p,4) = 1;
                    end
                end
            end
            
            % Performa a soma das comparacoes
            S = sum(rep');
            S = S';
            
            % realiza a indicacao dos indices que foram considerados
            % clutter por repeticao em pelo menos duas voltas
            ind = [];
            for p=1:size(S,1)
                if S(p) > 0
                    ind = [ind;p];
                end
            end
            
            % estabelece vetor de clutter
            clutter_all = pontos(ind,:);
            
            apaga = true;    
        end
        pontos_4 = pontos_3;
        pontos_3 = pontos_2;
        pontos_2 = pontos_1;
        pontos_1 = pontos;
        pontos = [];
        volta = volta+1;
    end
    % finaliza loop
    if volta == 6
        break
    end
    pontos = [pontos; M(k,2:3)];
end
%% Logica para avaliar pontos repetidos
% o indice seq é ref a um conj de pontos pertencentes ao mesmo objeto.
seq = 0;
pontos = [];
for k=1:size(clutter_all,1)
    azmt_cnt = clutter_all(k,1);
    dist_cnt = clutter_all(k,2);
    
    ind = 0;
    inside = false;
    idx = [];
    % Logica que verifica se pontos pertencem ao meso grupo considerando
    % pequenas variacoes de azimute e distancia
    for p=1:size(pontos,1)
        logic_azmt = (azmt_cnt <= pontos(p,1)+1) & (azmt_cnt >= pontos(p,1)-1);
        logic_dist = (dist_cnt >= pontos(p,2)-50) & (dist_cnt <= pontos(p,2)+50);
        if logic_azmt & logic_dist
            inside = true;
            ind = p;
        else
            idx = [idx;p];
        end
    end
    
    % Inseri dados na matriz pt caso nv dados
    if length(idx) == size(pontos,1)
        seq = seq+1;
        pontos = [pontos; [clutter_all(k,:) seq]];
    end
    
    % Inseri dados na matriz pt caso dados "repetidos"
    if inside
        pontos = [pontos; [clutter_all(k,:) pontos(ind,3)]];
    end
end
%% Loop que avalia a quantidade de pontos repetidos para cada objeto
count = [1:1:seq]';
count(:,2) = 0;
for p=1:size(pontos,1)
    for m=1:seq
        if m == pontos(p,3)
            count(m,2) = count(m,2)+1;
        end
    end
end

% Loop que adiciona conjunto de pontos dentro de um unico ponto pela media
% tambem calcula o desvio padrao para aquele conjunto de pontos
clutter = [];
for p=1:size(count,1)
    azmt = []; dist = [];
    for m=1:size(pontos,1)
        if count(p,1) == pontos(m,3)
            azmt = [azmt,pontos(m,1)];
            dist = [dist,pontos(m,2)];
        end
    end
    % calculo da media e desvios padroes
    dp_azmt = round(std(azmt));
    azmt = round(mean(azmt));
    dp_dist = round(std(dist));
    dist = round(mean(dist));
    clutter = [clutter; [dp_azmt, azmt, dp_dist, dist, count(p,2)]];
end

%% salvo arquivo para ser usado em outras etapas
save('clutter.mat','clutter')