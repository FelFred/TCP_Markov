% Westwood testing

% Comentarios:
% Se considerar� la llegada de un total m�ximo de cwnd ACKS (uno para cada paquete de la ventana de congesti�n)
% Se considerar� un intervalo de tiempo igual a un RTT durante cada
% iteraci�n (suma de tiempos debe ser igual a RTT)
% Se necesita un vector de tiempos asociado a cada ACK para la estimaci�n de BWE
% Se necesita programar el filtro (tau se sacar� de uno de los papers del protocolo)
% Se necesita un par�metro que determine la diferencia promedio promedio entre los tiempos en que se reciben los ACKS
% Se necesita un par�metro que determine el n�mero promedio de paquetes que
% se pierden en un ciclo.
% Ser�a bueno agregar un delay adicional para cada ACK (se podr�a ocupar
% ruido gaussiano de baja amplitud). La idea ser�a simular la aleatoriedad
% del queuing delay (se debe cuestionar qu� tan necesario y razonable es esto, por discutir)
% Se desea realizar otra simulaci�n donde se simulen las ventanas en el
% tiempo para el caso de reno vs westwood. Se desea observar que tipo de
% comportamiento resulta de la respuesta frente a p�rdidas.

%% Inicio c�digo

alfa = 0.31; %0.31
beta = 0.85; %0.85
p = 0.001;
N = 0;
C = ceil(sqrt((alfa*(1+beta))/(2*p*(1-beta))))*10; % estados (ventanas de congestion, cwnd), se asume b=1 en f�rmula
% cwnd_array = cwnd_min:delta_cwnd:C; % vector de ventanas de congesti�n (espacio discretizado)

tau = 0.5;                          
m = 2;                                           % Una muestra virtual cada tau/m
RTT = 0.1;
dt_ack = 1.2*10^-4;    % tiempo promedio entre la llegada de 2 acks consecutivos  (podr�a ser varias veces este valor considerando que en las colas se mezclan paquetes de distintas conexiones)
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
    
    % C�lculom de BWE 
    n_virtual = floor( (RTT-(dt_ack * cwnd_array(t-1))) / (tau/m));  % Notar que tau/m es muy grande asi que nunca se tendr�n muestras virtuales, es decir n_virtual es 0 siempre.
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
    
    
    %Actualizci�n de la ventana
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