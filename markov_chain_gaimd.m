% GAIMD version of markov 
clear
close all

% Inicio del código
alfa = 1; %0.31
beta = 0.5; %0.85

p = 0.001;
% N = 1000; % iteraciones
N = 0;
C = ceil(sqrt((alfa*(1+beta))/(2*p*(1-beta))))*10; % estados (ventanas de congestion, cwnd), se asume b=1 en fórmula
cwnd_min = 2;
cwnd_max = C;
delta_cwnd = 0.025; %0.025
cwnd_array = cwnd_min:delta_cwnd:C; % vector de ventanas de congestión (espacio discretizado)
L_cwnd = length(cwnd_array);
prev_weight = zeros(1,L_cwnd); % vector de los pesos (peso = probabilidad de que este en ese estado)
prev_weight(1) = 1;
weight = zeros(1,L_cwnd); % siguiente vector de peso

% Cálculo del siguiente índice en base a incremento aditivo (función de alfa)
post_ai = cwnd_array + alfa;
post_md = cwnd_array * beta;
ai_index = indexing_general(cwnd_array, post_ai);
md_index = indexing_general(cwnd_array, post_md);
 

error = 1e-6;
while 1    
    N = N+1;
    if(mod(N,20) == 0 & N < 300)
        prev_weight = collapse_to_int(cwnd_array, prev_weight);
    end
    for i = 1:length(cwnd_array)
        cwnd = floor(cwnd_array(i));
        % Transición de probabilidades al siguiente vector de pesos
        weight(min(L_cwnd, ai_index(i))) = weight(min(L_cwnd, ai_index(i))) + prev_weight(i)*((1-p)^cwnd);        
        weight(max(1, md_index(i))) = weight(max(1, md_index(i))) + prev_weight(i)*(1-(1-p)^cwnd);      
    end
%     fprintf('weight = %1.16f\n', sum(weight)) % debería ser 1 siempre, si no es 1 se está "perdiendo" el peso    
    stem(cwnd_array, weight)
%     axis([25 43 0.022 0.027]) % prueba con p = 0.001
    axis([0 ceil(sqrt((alfa*(1+beta))/(2*p*(1-beta)))/7)*20 0 max(weight)])
%     fprintf('error = %4.12f\n', sum(abs(prev_weight-weight)))
    pause(0.001)
%     drawnow
    if sum(abs(prev_weight-weight)) < error
        break
    end
    prev_weight = weight;
    weight = zeros(1, L_cwnd);   
end
N
average = sum(prev_weight.*cwnd_array);
fprintf('theoretical = %4.3f, ', sqrt((alfa*(1+beta))/(2*p*(1-beta))))
fprintf('simulation = %4.3f\n', average)