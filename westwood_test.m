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

%% Inicio código

alfa = 0.31; %0.31
beta = 0.85; %0.85
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
BWE_array = zeros(1,length(it_array));           % Vector de bwe filtrado
BWE_array(1) = 1*MSS/RTT;
last_time = -(RTT-dt_ack*1);
last_sample = BWE_array(1);
while (N<N_iteraciones)    
    N = N+1;
    t = N+1;
    x = rand;
    
    % Cálculom de BWE 
    n_virtual = floor( (RTT-(dt_ack * cwnd_array(t-1))) / (tau/m));  % Notar que tau/m es muy grande asi que nunca se tendrán muestras virtuales, es decir n_virtual es 0 siempre.
    n_samples = cwnd_array(t-1)+n_virtual;
    t_array = zeros(1,n_samples);
    t_array(1) = last_time;
    for l = 1:cwnd_array(t-1)
        t_array(l+1) = l*dt_ack;
    end
    deltat_array = zeros(1,n_samples-1);
    samples_array = zeros(1,length(t_array));
    samples_array(1) = last_sample;
    filtered_array = zeros(1,length(t_array));
    filtered_array(1) = BWE_array(t-1);
    for j = 1:n_samples-1
        deltat_array(j) = t_array(j+1)-t_array(j);
        alfa_k = (2*tau + deltat_array(j))/(2*tau - deltat_array(j));
        samples_array(j+1) = MSS/deltat_array(j);
        filtered_array(j+1) = alfa_k*filtered_array(t-1) + (1-alfa_k)*(samples_array(j+1)+samples_array(j))/2; 
    end   
    
    BWE_array(t) = filtered_array(end);
    % Fin BWE
    
    
    %Actualizción de la ventana
    if (x>=p)
        cwnd_array(t) = cwnd_array(t-1) + 1;
    else
        
        cwnd_array(t) = BWE_array(t-1) * RTT;
    end
end

figure()
plot(it_array, cwnd_array)

figure()
plot(it_array, BWE_array)