%Este é o script responsável por fazer a simulação de um neurônio com a
%aplicação de uma sequência de pulsos em suas sinapses.
%É neste arquivo em que são simladas as características biológicas do
%neurônio integra-dispara e onde é controlada as atualizações dos pesos
%sinápticos dos memristores.

%É a principal função utilizada pelos arquivos:
%simulation_p.m
%simulation_p_1000.m
%simulation_pulses.m
%simulation_sigma_all.m
%simulation_sigma_duv.m
%simulation_soma_parameters.m

function [time, g_total_current, g_threshold, g_neuron_state, g_spike, RMSE, spike_times] = train_neuron(N_epoch, ...
    T_epoch, input_seq, input_epch, type, ...
    R_on_mean, R_on_sigma, R_off_mean, R_off_sigma, ...
    u_v_mean, u_v_sigma, d_mean, d_sigma, ...
    p, R_or_G, save_path, save_weights)
    %% Parâmetros de inputs das sinapses
    N_synapse = 8*8;                %Quantidade de sinapses (e inputs)

    spike_amp = 1;                  %Amplitude dos spikes (inputs)
    duty = 0.1;                     %Duty cycle dos pulsos
    freq = 50;                      %Frequência máxima dos spikes 50 Hz

    Ts = 0.001;                     %Time step
    N_steps = T_epoch/Ts;           %Quantidade de passos por época

    pattern_period = 9;             %A cada quantos padrões de ruído é apresentado o padrão

    %Gerar matriz de inputs
        %cada linha é o input para uma sinapse
        %cada colune é o seu valor correspondente
    inputs = generate_inputs(spike_amp, freq, N_epoch, T_epoch, Ts, N_synapse, pattern_period, duty, input_seq, input_epch);
    
    %% Vetor do tempo
    total_steps = N_steps*N_epoch;
    time = linspace(0, N_epoch*T_epoch, total_steps);
    
    %% Plotar inputs
%     epochs = linspace(0, 26, 2600);
%     
%     for i = 1 : 64
%         input_i = inputs(i, :)*0.5 + i;
% %         for j = 1 : length(input_i)
% %             if mod(input_i(j),1) == 0
% %                 input_i(j) = NaN;
% %             end
% %         end
%         plot(epochs, input_i, 'LineWidth', 0.5, 'Color', 'k');
%     end
%     xlim([0 26])
%     ylim([0 65])
%     xlabel('Época')
%     ylabel('Input')
%     return;

    %% Parâmetros da soma
    T_refractory = T_epoch;     %Período mínimo entre potenciais de ação
    T_count_spikes = 0.8;       %Perído em que é computada a frequência de spikes
    T_STDP = 2*T_epoch;         %Período após spike em em as sinapes são enfraquecidas

    target_spike_freq = 1;      %Frequência alvo, busacada pela homeostase

    count_spikes = 5;           %Quantidade de spikes usados para estimar a frequência

    spike_times = [];           %Momentos em que ocorreram spikes

    threshold = 5;              %Limiar para disparo (inicial)

    delta_thres = 0.001;        %Velocidade de mudança de limiar (plast intr)

    neuron_state = 0;           %Estado do neurônio (inicial)

    %% Parâmetros dos pesos sinápticos
    voltage_increment = 1;
    voltage_decrement = -0.5;

    increment_period = 0.01;
    decrement_period = 0.01;

    potentiated_weights = zeros(1, 64);     %Vetor de pesos que foram incrementados (não decrementar no STDP)

    %% Esses de baixo fazer em vetores para adicionar variações de memristores

    G_on_mean = 1/R_on_mean;
    G_off_mean = 1/R_off_mean;

    %Criação dos memristores para as sinapses
    syn_array = [];
    
        for s = 1 : 64
            initial_x = rand;

            d = get_normal(d_mean, d_sigma);
            u_v = get_normal(u_v_mean, u_v_sigma);
            R_on = get_normal(R_on_mean, R_on_sigma);
            R_off = get_normal(R_off_mean, R_off_sigma);

            synapse = memristor(type, p, d, u_v, R_on, R_off, initial_x);
            syn_array = [syn_array synapse];
        end
    

    %% Vetores para fazer gráficos

    g_total_current = zeros(1, total_steps);

    g_threshold = zeros(1, total_steps);

    g_neuron_state = zeros(1, total_steps);

    g_spike = zeros(1, total_steps);

    RMSE = zeros(1, total_steps);
    
    compare_vector = get_patterns();
    compare_index = 0;

    N_frames = 0;

    for t = 1 : length(time)
        %% Fazer a multiplicação sináptica e obter a soma ponderada dos pulsos
        total_current = 0;

        weight = zeros(1, 64);

        for s = 1 : N_synapse
            if R_or_G == 'R'
                %Peso pela resistência normalizada
                R = syn_array(s).resistance;
                R_norm = R/R_off_mean;
                weight(s) = 1 - R_norm;
            elseif R_or_G == 'G'
                %Peso pela condutância normalizada
                G = 1./(syn_array(s).resistance);
                G_norm = G/G_on_mean;
                weight(s) = G_norm;
            else
                error('Must normalize weight by resistance (R) or conductance (G)')
            end
            total_current = total_current + weight(s) * inputs(s, t);
        end

        %Registrar a corrente atual no gráfico
        g_total_current(t) = total_current;


        %% Simular o estado do neurônio e verificar se houve disparo

        %Simular passo na equação diferencial
        d_neuron_state = -0.01*neuron_state + 0.5*total_current;
        %0.01 = g/tau
        %0.5 = 1/tau

        neuron_state = neuron_state + d_neuron_state;

        %Registrar no gráfico
        g_neuron_state(t) = neuron_state;

        %% Se o estado excedeu o limiar e não houve nenhum outro potencial de
        % ação dentro do período refratário, disparar
        if neuron_state > threshold && (isempty(spike_times) || abs(time(t) - spike_times(end)) > T_refractory)
            %Registrar o momento de disparo
            spike_times = [spike_times time(t)];

            %Registrar no gráfico de spikes:
            g_spike(t) = 1;

            %Zerar o estado do neurônio
            neuron_state = 0;

            %% STDP - Reforço das sinapses que dispararam antes do spike
            potentiated_weights = zeros(1, 64); %vetor para indicar que o peso deve ser incrementado
            for s = 1 : N_synapse
                %Fortalecer as sinapses dos inputs que dispararam logo
                %antes de ocorrer o disparo do neurônio
                if inputs(s,t) > 0.5
                    syn_array(s).update(voltage_increment, increment_period);
                    potentiated_weights(s) = 1;
                end
            end

            %% Registrar os pesos (para o vídeo)
            if save_weights
                N_frames = N_frames + 1;
                i = reshape(weight(1,:), 8, 8)';
                i = imresize(i, 10, 'nearest');
                imwrite(i, strcat(save_path, '/', num2str(N_frames) , '.png'));
            end

        end

        %% STDP - Enfraquecimento das sinapses que dispararam depois do spike
        if ~isempty(spike_times) && (abs(time(t) - spike_times(end)) < T_STDP)
            for s = 1 : N_synapse
                %Enfraquecer sinapses que estão disparando agora
                if inputs(s,t) > 0.5 && potentiated_weights(s) ~= 1
                    syn_array(s).update(voltage_decrement, decrement_period);
                end
            end
        end


        %% Plasticidade intrínseca (ajuste do limiar)

        %Estimar a frequência de spikes observando os últimos spikes dentro do
        %período T_count_spikes
        spikes_freq = 0;
        if ~isempty(spike_times) %Para evitar divisão por 0
            count_spikes = 0;
            for spike = 1 : length(spike_times)
                if time(t) - spike_times(length(spike_times) - spike + 1) < T_count_spikes
                    count_spikes = count_spikes + 1;
                end
            end

            spikes_freq = count_spikes/T_count_spikes;
        end

        %Se a frequência está acima do desejado, subir o limiar
        %Se não, abaixar o limiar
        if spikes_freq > target_spike_freq
            threshold = threshold + delta_thres;
        else
            threshold = threshold - delta_thres;
        end

        g_threshold(t) = threshold;

        %% Cálculo do erro

        %Mudar o vetor com o qual é feita a comparação
        curr_epoch = t/N_steps;

        if curr_epoch < input_epch(2)
            compare_index = input_seq(1);
        else
            switch curr_epoch
                case input_epch(2)
                    compare_index = input_seq(2);
                case input_epch(3)
                    compare_index = input_seq(3);
                case input_epch(4)
                    compare_index = input_seq(4);
                case input_epch(5)
                    compare_index = input_seq(5);
            end
        end

        RMSE(t) = sqrt(mean((weight - compare_vector(compare_index, :)).^2));

    end

    if save_weights
        video = VideoWriter(strcat(save_path, '/', 'weights.avi')); %create the video object
        open(video); %open the file for writing
        for i=1:N_frames %where N is the number of images
          I = imread(strcat(save_path, '/', num2str(i) ,'.png')); %read the next image
          writeVideo(video,I); %write the image to file
        end
        close(video); %close the file
    end
    
end

function value = get_normal(mean, sigma)
    value = -1;
    while value < 0
        value = mean*normrnd(1, sigma);
    end
end



