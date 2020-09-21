close all;
clear all;
clc;

%Este script faz 1000 simulações da convergência de um neurônio ignorando
%casos em que não há convergência. Ao final, é calculada a média das épocas
%necessárias para a convergência e seu desvio padrão.

d_mean = 9*10^(-9);
u_v_mean = 30*10^-15;
R_on_mean = 0.1*10^3;
R_off_mean = 16*10^3;

save_path = 'path';
save_weights = false;

analysis = 0;

%% Gráficos de convergência com diferentes valores de p (Joglekar)

%MODIFICAR ESSES: ///////////////
%Tipo de modelo
type = 2;
%Normalizar G ou R
R_or_G = 'G';

%Mudar aqui para ver o tempo de convergência de diferentes valores de p
p = 10;

%////////////////////////////////

N_epoch = 900;         %Número de épocas
T_epoch = 0.1;          %Período de cada época

input_seq = [1 1 1 1 1];        %Sequência de inputs
input_epch = [1 100 101 102 103];       %Época em que são apresentados

%Desvios padrão
d_sigma = 0;
u_v_sigma = 0;
R_on_sigma = 0;
R_off_sigma = 0;

p_values = [1 5 10];
p_max = length(p_values);

time_conv = [];

count_analysis = 0;
while count_analysis < 1000
    analysis = analysis + 1;
    disp('Analise:')
    disp(num2str(analysis))

    [time, g_total_current, g_threshold, g_neuron_state, ...
    g_spike, RMSE, spike_times] = ...
        train_neuron(N_epoch, ...
        T_epoch, input_seq, input_epch , type, ...
        R_on_mean, R_on_sigma, R_off_mean, R_off_sigma, ...
        u_v_mean, u_v_sigma, d_mean, d_sigma, ...
        p, R_or_G, save_path, save_weights);

    new_time_conv = 0;
    for j = 1 : length(RMSE)
        if RMSE(j) > 0.05
            new_time_conv = time(j);
        end
    end
    
    if new_time_conv < 90
        time_conv = [time_conv new_time_conv];
        count_analysis = count_analysis + 1;
    end
end

%Média e desvio padrão do tempo de convergência
mean = mean(time_conv)
stdr_dev = std(time_conv)

save(strcat('analise1000_p=',num2str(p),'type=',num2str(type)))

disp('ok')
