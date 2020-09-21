close all;
clear all;
clc;

%Este script faz simula��es da converg�ncia de um neur�nio com memristores
%n�o-lienares para diferentes valores de desvio padr�o utilizando as
%fun��es janela de Biolek e Joglekar. Os resultados s�o comparados
%em gr�ficos. S�o desconsideradas varia��es nos valores de D e u_v

d_mean = 9*10^(-9);
u_v_mean = 30*10^-15;
R_on_mean = 0.1*10^3;
R_off_mean = 16*10^3;

save_path = 'path';
save_weights = false;

analysis = 0;

%% Gr�ficos de converg�ncia com diferentes valores de p (Joglekar)

%MODIFICAR ESSES: ///////////////
%Tipo de modelo
type = 1;
%Normalizar G ou R
R_or_G = 'G';
%////////////////////////////////

N_epoch = 2000;         %N�mero de �pocas
T_epoch = 0.1;          %Per�odo de cada �poca

input_seq = [1 1 1 1 1];                %Sequ�ncia de inputs
input_epch = [1 100 101 102 103];       %�poca em que s�o apresentados

p = 10;

sigma_values = [0 0.15 0.30];
sigma_max = length(sigma_values);

time_conv_0 = [];
time_conv_15 = [];
time_conv_30 = [];

figure(1)
hold on;

for i = 1 : 13
    for sigma_index = 1 : sigma_max
        sigma = sigma_values(sigma_index);

        %Desvios padr�o
        d_sigma = sigma;
        u_v_sigma = sigma;
        R_on_sigma = 0;
        R_off_sigma = 0;
        
        analysis = analysis + 1;
        message = strcat(num2str(analysis), ' de 39');
        disp('An�lise:')
        disp(message)

        [time, g_total_current, g_threshold, g_neuron_state, ...
        g_spike, RMSE, spike_times] = ...
            train_neuron(N_epoch, ...
            T_epoch, input_seq, input_epch, type, ...
            R_on_mean, R_on_sigma, R_off_mean, R_off_sigma, ...
            u_v_mean, u_v_sigma, d_mean, d_sigma, ...
            p, R_or_G, save_path, save_weights);
        
        time_conv = 0;
        for j = 1 : length(RMSE)
            if RMSE(j) > 0.05
                time_conv = time(j);
            end
        end
    
        switch sigma_index
            case 1
                plot(time/T_epoch, 100*RMSE, 'color', 'r', 'linewidth', 1);
                time_conv_0 = [time_conv_0 time_conv];
            case 2
                plot(time/T_epoch, 100*RMSE, 'color', 'b', 'linewidth', 1);
                time_conv_15 = [time_conv_15 time_conv];
            case 3
                plot(time/T_epoch, 100*RMSE, 'color', 'g', 'linewidth', 1);
                time_conv_30 = [time_conv_30 time_conv];
        end
    end
end

xlabel('�poca de Treinamento');
ylabel('Erro Percentual');

mean_0 = mean(time_conv_0);
mean_15 = mean(time_conv_15);
mean_30 = mean(time_conv_30);
