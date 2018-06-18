% GAIMD version of markov 
clear

% Inicio del código
alfa = 0.31;
beta = 0.85;

p = 0.001;
% N = 1000; % iteraciones
C = ceil(sqrt((alfa*(1+beta))/(2*p*(1-beta))))*5; % estados (ventanas de congestion, cwnd), se asume b=1 en fórmula
cwnd_min = 2;
cwnd_max = C;
delta_cwnd = 0.025
cwnd_array = cwnd_min:delta_cwnd:C; % vector de ventanas de congestión (espacio discretizado)
L_cwnd = length(cwnd_array);
prev_weight = zeros(1,L_cwnd); % vector de los pesos (peso = probabilidad de que este en ese estado)
prev_weight(cwnd_min) = 1;
weight = zeros(1,L_cwnd); % siguiente vector de peso

% Cálculo del siguiente índice en base a incremento aditivo (función de alfa)
post_ai = cwnd_array + alfa;
remainder_array = mod(post_ai,delta_cwnd);
remainder_ineq = remainder_array >= delta_cwnd/2;
quotient_array = floor(post_ai/delta_cwnd);
final_value = quotient_array * delta_cwnd + remainder_ineq * delta_cwnd;
index_array = (final_value - cwnd_min)/delta_cwnd + 1;
index_array = uint8(index_array);
% Cálculo del indice asociado al cwnd sin incremento aditivo
cwnd_index = 

error = 1e-6;
while 1
    
    for i = 1:length(cwnd_array)
        cwnd = cwnd_array(i);
        % Transición de probabilidades al siguiente vector de pesos
        weight(min(cwnd_max, ceil(index_array(i)))) = weight(min(cwnd_max, ceil(index_array(i)))) + prev_weight(cwnd)*(1-p)^cwnd;
        weight(max(cwnd_min, ceil(cwnd*beta))) = weight(max(cwnd_min, ceil(cwnd*beta))) + prev_weight(cwnd)*(1-(1-p)^cwnd);
    end
%     fprintf('weight = %1.16f\n', sum(weight)) % debería ser 1 siempre, si no es 1 se está "perdiendo" el peso
    stem(weight)
%     axis([25 43 0.022 0.027]) % prueba con p = 0.001
    axis([0 ceil(sqrt((alfa*(1+beta))/(2*p*(1-beta)))/7)*20 0 max(weight)])
%     fprintf('error = %4.12f\n', sum(abs(prev_weight-weight)))
    pause(0.01)
%     drawnow
    if sum(abs(prev_weight-weight)) < error
        break
    end
    prev_weight = weight;
    weight = zeros(1, C);
end

average = sum(prev_weight.*(1:C));
fprintf('theoretical = %4.3f, ', sqrt((alfa*(1+beta))/(2*p*(1-beta))))
fprintf('simulation = %4.3f\n', average)