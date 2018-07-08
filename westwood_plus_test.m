% Westwood+ testing

% Comentarios:
% Para esta versi�n del algoritmo se consideran muestras calculadas a
% partir del total de acks recibidos (datos asociados seran denominados Dk) en el intervalo anterior divido en
% RTT_k (rtt anterior, tambien denominado Tk o catching time interval).
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

% Notar que tau/m es muy grande asi que nunca se tendr�n muestras
% virtuales, es decir n_virtual es 0 siempre (considerando tau = 0.5 y m =
% 2 valores de paper(s))
 
%% Inicio c�digo
clear all
close all

alfa = 1; %0.31
beta = 0.5; %0.85
p = 0.001;
N = 0;
C = ceil(sqrt((alfa*(1+beta))/(2*p*(1-beta))))*10; % estados (ventanas de congestion, cwnd), se asume b=1 en f�rmula
% cwnd_array = cwnd_min:delta_cwnd:C; % vector de ventanas de congesti�n (espacio discretizado)



tau = 0.5;                          
m = 2;                                           % Una muestra virtual cada tau/m
RTT = 0.1;
RTT_min = 0.8*RTT;
dt_ack = 1.2*10^-4;    % tiempo promedio entre la llegada de 2 acks consecutivos  (podr�a ser varias veces este valor considerando que en las colas se mezclan paquetes de distintas conexiones)
MSS = 1460 * 8;
N_iteraciones = 10000;
it_array = 1:N_iteraciones;                               % Vector de iteraciones
cwnd_array = zeros(1,length(it_array));
cwnd_array(1) = 2;
gaimd_array = cwnd_array; 
BWE_array = zeros(1,length(it_array));           % Vector de bwe filtrado
BWE_array(1) = 1/RTT;
n_perdidas = 0;

while (N<N_iteraciones-1)    
    N = N+1
    t = N+1;
    x = rand;     
    
    BWE_array(t) = 7*BWE_array(t-1)/8 + cwnd_array(t-1)/(8*RTT);
        
    %Actualizci�n de la ventana
    if (x>=p)
        cwnd_array(t) = cwnd_array(t-1) + 1;
        gaimd_array(t) = gaimd_array(t-1) + 1;
    else
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
