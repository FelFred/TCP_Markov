% Westwood+ testing

% Comentarios:
% Para esta versi�n del algoritmo se consideran muestras calculadas a
% partir del total de acks recibidos (datos asociados seran denominados Dk) en el intervalo anterior divido en
% RTT_k (rtt anterior, tambien denominado Tk o catching time interval).
% Se considerar� la llegada de un total m�ximo de cwnd ACKS (uno para cada paquete de la ventana de congesti�n)
% Se considerar� un intervalo de tiempo igual a un RTT durante cada
% iteraci�n 
% Se podr�a incluir un par�metro que determine el n�mero promedio de
% paquetes que se pierden en un ciclo (cuando hay perdidas)
% Ser�a bueno agregar un delay gaussiano para simular RTTs variables. La idea ser�a simular la aleatoriedad
% del queuing delay (se debe cuestionar qu� tan necesario y razonable es esto, por discutir)
% Se desea observar que tipo de comportamiento resulta de la respuesta
% frente a p�rdidas, comparandolo con gaimd.

% A partir de lo anterior se desea simulaci�n de montecarlo para obtener
% pdf.

 
%% Inicio c�digo
clear all
close all

alfa = 1; %0.31
beta = 0.5; %0.85
p = 0.001;
N = 0;
C = ceil(sqrt((alfa*(1+beta))/(2*p*(1-beta))))*10; % estados (ventanas de congestion, cwnd), se asume b=1 en f�rmula
% cwnd_array = cwnd_min:delta_cwnd:C; % vector de ventanas de congesti�n (espacio discretizado)

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
    %Actualizci�n de la ventana
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
