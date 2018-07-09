% Westwood+ testing

% Comentarios:
% Para esta versión del algoritmo se consideran muestras calculadas a
% partir del total de acks recibidos (datos asociados seran denominados Dk) en el intervalo anterior divido en
% RTT_k (rtt anterior, tambien denominado Tk o catching time interval).
% Se considerará la llegada de un total máximo de cwnd ACKS (uno para cada paquete de la ventana de congestión)
% Se considerará un intervalo de tiempo igual a un RTT durante cada
% iteración 
% Se podría incluir un parámetro que determine el número promedio de
% paquetes que se pierden en un ciclo (cuando hay perdidas)
% Sería bueno agregar un delay gaussiano para simular RTTs variables. La idea sería simular la aleatoriedad
% del queuing delay (se debe cuestionar qué tan necesario y razonable es esto, por discutir)
% Se desea observar que tipo de comportamiento resulta de la respuesta
% frente a pérdidas, comparandolo con gaimd.

% A partir de lo anterior se desea simulación de montecarlo para obtener
% pdf.

 
%% Inicio código
clear all
close all

alfa = 1; %0.31
beta = 0.5; %0.85
p = 0.001;
N = 0;
C = ceil(sqrt((alfa*(1+beta))/(2*p*(1-beta))))*10; % estados (ventanas de congestion, cwnd), se asume b=1 en fórmula
% cwnd_array = cwnd_min:delta_cwnd:C; % vector de ventanas de congestión (espacio discretizado)

factor_perdida = 0.25;                               % Se ocupa para simular "bursts" de perdida. No solo se pierde un paquete sino que un factor_perdida% de ellos.
RTT = 0.1;
RTT_factor = 0.8;
RTT_min = RTT_factor*RTT;
N_iteraciones = 10000;
it_array = 1:N_iteraciones;                         % Vector de iteraciones
cwnd_array = zeros(1,length(it_array));
cwnd_array(1) = 2;
gaimd_array = cwnd_array; 
BWE_array = zeros(1,length(it_array));              % Vector de bwe filtrado
BWE_array(1) = 1/RTT;
n_perdidas = 0;
loss_flag = 0;


while (N<N_iteraciones-1)    
    N = N+1
    t = N+1;
    x = rand;     
    if (loss_flag)
        BWE_array(t) = 7*BWE_array(t-1)/8 + (1-factor_perdida)*cwnd_array(t-1)/(8*RTT);
    else
        BWE_array(t) = 7*BWE_array(t-1)/8 + cwnd_array(t-1)/(8*RTT);
    end
   
    loss_flag = 0;    
    %Actualizción de la ventana
    if (x>=p)
        cwnd_array(t) = cwnd_array(t-1) + 1;
        gaimd_array(t) = gaimd_array(t-1) + 1;
    else
        loss_flag = 1;
        n_perdidas = n_perdidas + 1;
        cwnd_array(t) = BWE_array(t-1) * RTT_min;
        gaimd_array(t) = gaimd_array(t-1) * beta;
    end
%     samples_array
%     filtered_array
%     t_array
%     figure()
%     plot(1:length(filtered_array), filtered_array,'o')
%     pause()
%     close all
end

figure()
plot(it_array/RTT, cwnd_array, 'r')
hold on
% figure()
plot(it_array/RTT, gaimd_array, 'b')
hold on
plot(it_array/RTT, (BWE_array*RTT), 'kx')
xlabel('Time [s/RTT]')
ylabel('Cwnd [packets]')
legend('Westwood Window','GAIMD Window','BWE_estimation')
