% GAIMD version of markov 
clear

% Inicio del código
alfa = 0.31;
beta = 0.85;

p = 0.001;
N = 1000; % iteraciones
C = ceil(sqrt((alfa*(1+beta))/(2*p*(1-beta))))*10; % estados (ventanas de congestion, cwnd), se asume b=1 en fórmula
cwnd_min = 2;
cwnd_max = C;
prev_weight = zeros(1, C); % vector de los pesos (peso = probabilidad de que este en ese estado)
prev_weight(cwnd_min) = 1;
weight = zeros(1, C); % siguiente vector de peso

error = 1e-6;
while 1 
    for cwnd = cwnd_min:cwnd_max
        weight(min(cwnd_max, ceil(cwnd+alfa))) = weight(min(cwnd_max, ceil(cwnd+alfa))) + prev_weight(cwnd)*(1-p)^cwnd;
        weight(max(cwnd_min, ceil(cwnd*beta))) = weight(max(cwnd_min, ceil(cwnd*beta))) + prev_weight(cwnd)*(1-(1-p)^cwnd);
    end
%     fprintf('weight = %1.16f\n', sum(weight)) % debería ser 1 siempre, si no es 1 se está "perdiendo" el peso
    stem(weight)
%     axis([25 43 0.022 0.027]) % prueba con p = 0.001
    axis([0 ceil(sqrt((alfa*(1+beta))/(2*p*(1-beta)))/7)*20 0 max(weight)])
%     fprintf('error = %4.12f\n', sum(abs(prev_weight-weight)))
    pause(0.1)
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