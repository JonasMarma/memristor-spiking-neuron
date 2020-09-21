close all;
clear all;
clc;

%Este script faz a simulação da convergência de um neurônio com sinapses
%memristivas e plota as variações dos principais parâmetros na soma.

rng('default');
s = rng;

d_mean = 9*10^(-9);
u_v_mean = 30*10^-15;
R_on_mean = 0.1*10^3;
R_off_mean = 16*10^3;

save_path = 'test_results';
if exist('test_results', 'dir')
    rmdir('test_results', 's')
end
mkdir('test_results')

save_weights = true;

analysis = 0;

%% Gráficos de convergência com diferentes valores de p (Joglekar)

%Tipo de modelo
type = 1;
p = 1;
%Normalizar G ou R
R_or_G = 'R';

%2 padrões: 4000
N_epoch = 4000;         %Número de épocas
T_epoch = 0.1;          %Período de cada época

input_seq = [1 3 4 1 1];        %Sequência de inputs
input_epch = [1 1500 4000 6000 7000];       %Época em que são apresentados

%Desvios padrão
d_sigma = 0;
u_v_sigma = 0;
R_on_sigma = 0;
R_off_sigma = 0;

[time, g_total_current, g_threshold, g_neuron_state, ...
g_spike, RMSE, spike_times] = ...
    train_neuron(N_epoch, ...
    T_epoch, input_seq, input_epch , type, ...
    R_on_mean, R_on_sigma, R_off_mean, R_off_sigma, ...
    u_v_mean, u_v_sigma, d_mean, d_sigma, ...
    p, R_or_G, save_path, save_weights);

epochs = time/T_epoch;

figure(1)
lin = 4;
col = 1;

subplot(lin, col, 1)
plot(epochs, g_neuron_state, 'Color', 'k');
ylabel('Estado')
set(gca,'XTick',[])
xlim([0 N_epoch])

subplot(lin, col, 2)
plot(epochs, g_threshold, 'Color', 'k', 'LineWidth', 1);
ylabel('Limiar de Disparo')
set(gca,'XTick',[])
xlim([0 N_epoch])
ylim([0 120])

subplot(lin, col, 3)
plot(epochs, g_spike, 'Color', 'k');
ylabel('Spikes')
set(gca,'XTick',[])
xlim([0 N_epoch])

subplot(lin, col, 4)
plot(epochs, 100*RMSE, 'color', 'k', 'LineWidth', 1);
ylabel('Erro Percentual');
xlim([0 N_epoch])

xlabel('Época de Treinamento');










