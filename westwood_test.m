% Westwood testing

% Comentarios:
% Se considerará la llegada de un total máximo de cwnd ACKS (uno para cada paquete de la ventana de congestión)
% Se considerará un intervalo de tiempo igual a un RTT durante cada
% iteración (suma de tiempos debe ser igual a RTT)
% Se necesita un vector de tiempos asociado a cada ACK para la estimación de BWE
% Se necesita programar el filtro (tau se sacará de uno de los papers del protocolo)
% Se necesita un parámetro que determine la diferencia promedio promedio entre los tiempos en que se reciben los ACKS
% Se necesita un parámetro que determine el número promedio de paquetes que
% se pierden en un ciclo.
% Sería bueno agregar un delay adicional para cada ACK (se podría ocupar
% ruido gaussiano de baja amplitud). La idea sería simular la aleatoriedad
% del queuing delay (se debe cuestionar qué tan necesario y razonable es esto, por discutir)
% Se desea realizar otra simulación donde se simulen las ventanas en el
% tiempo para el caso de reno vs westwood. Se desea observar que tipo de
% comportamiento resulta de la respuesta frente a pérdidas.

% Notar que tau/m es muy grande asi que nunca se tendrán muestras
% virtuales, es decir n_virtual es 0 siempre (considerando tau = 0.5 y m =
% 2 valores de paper(s))
 
%% Inicio código
clear all
close all

alfa = 1; %0.31
beta = 0.5; %0.85
p = 0.001;
N = 0;
C = ceil(sqrt((alfa*(1+beta))/(2*p*(1-beta))))*10; % estados (ventanas de congestion, cwnd), se asume b=1 en fórmula
% cwnd_array = cwnd_min:delta_cwnd:C; % vector de ventanas de congestión (espacio discretizado)

tau = 0.5;                          
m = 2;                                           % Una muestra virtual cada tau/m
RTT = 0.1;
dt_ack = 1.2*10^-4;    % tiempo promedio entre la llegada de 2 acks consecutivos  (podría ser varias veces este valor considerando que en las colas se mezclan paquetes de distintas conexiones)
MSS = 1460 * 8;
N_iteraciones = 10000;
it_array = 1:N_iteraciones;                               % Vector de iteraciones
cwnd_array = zeros(1,length(it_array));
cwnd_array(1) = 2;
gaimd_array = cwnd_array; 
BWE_array = zeros(1,length(it_array));           % Vector de bwe filtrado
BWE_array(1) = 1/RTT;
last_time = -(RTT-dt_ack*1);
last_sample = BWE_array(1);
n_perdidas = 0;
while (N<N_iteraciones-1)    
    N = N+1
    t = N+1;
    x = rand;
    
    % Cálculom de BWE     
    n_samples = round(cwnd_array(t-1))+1;
    t_array = zeros(1,n_samples);
    t_array(1) = last_time;
    for l = 1:n_samples-1
        t_array(l+1) = l*dt_ack;
    end
    last_time = -(RTT-t_array(end));
    deltat_array = zeros(1,n_samples-1);
    samples_array = zeros(1,length(t_array));
    samples_array(1) = last_sample;
    filtered_array = zeros(1,length(t_array));
    filtered_array(1) = BWE_array(t-1);
    for j = 1:n_samples-1
        deltat_array(j) = t_array(j+1)-t_array(j);
        alfa_k = (2*tau - deltat_array(j))/(2*tau + deltat_array(j));
        samples_array(j+1) = 1/deltat_array(j);
        filtered_array(j+1) = alfa_k*filtered_array(j) + (1-alfa_k)*(samples_array(j+1)+samples_array(j))/2; 
    end   
    last_sample = samples_array(end);
    BWE_array(t) = filtered_array(end);
    % Fin BWE
    
    
    %Actualizción de la ventana
    if (x>=p)
        cwnd_array(t) = cwnd_array(t-1) + 1;
        gaimd_array(t) = gaimd_array(t-1) + 1;
    else
        n_perdidas = n_perdidas + 1;
        cwnd_array(t) = BWE_array(t-1) * RTT;
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
plot(it_array, cwnd_array, 'rx')
hold on
% figure()
plot(it_array, gaimd_array, 'b')
hold on
plot(it_array, (BWE_array*RTT), 'kx')
