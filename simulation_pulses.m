clear all
clc

%Este script faz uma simula��o das varia��es de condut�ncia e resist�ncia
%de memristores com fun��o janela de Joglekar e Biolek de diferentes
%valores de p para quando � aplicado um pulso positivo de tens�o seguido de
%um pulso negativo.

t = 0:0.001:4;

p = 10;
d = 9*10^(-9);
u_v = 30*10^-15;
R_on = 0.1*10^3;
R_off = 16*10^3;
initial_x = 0;

p_values = [1 5 10];

figure(1)
logy = true;

for p_index = 1 : length(p_values)
    %% Ver pulsos com Joglekar
    
    color = '';
    switch p_index
        case 1
            color = 'r';
        case 2
            color = 'b';
        case 3
            color = 'g';
    end
    p = p_values(p_index)
    
    resistance = zeros(length(t),1);

    m = memristor(1, p, d, u_v, R_on, R_off, initial_x);

    amp = 1;

    for i = 2 : floor(length(t)/2)
        delta_t = t(i)-t(i-1);
        resistance(i) = update(m, amp, delta_t);
    end
    for i = floor(length(t)/2)+1 : length(t)
        delta_t = t(i)-t(i-1);
        resistance(i) = update(m, -amp, delta_t);
    end

    subplot(2,2,1)
    title('Resist�ncia com Fun��o Janela de Joglekar')
    plot(t, resistance./1000, 'color', color, 'linewidth', 2)
    hold on

    if logy
        set(gca, 'YScale', 'log')
    end
    grid on
    xlabel('Tempo [s]')
    ylabel('Resist�ncia [k \Omega]')

    subplot(2,2,3)
    title('Condut�ncia com Fun��o Janela de Joglekar')
    G = 1./resistance;
    plot(t, G, 'color', color, 'linewidth', 2)
    hold on
    ylim([0.5e-4 1.5e-2])

    if logy
        set(gca, 'YScale', 'log')
    end
    grid on
    xlabel('Tempo [s]')
    ylabel('Condut�ncia [S]')

    %% Ver pulsos com Biolek
    resistance = zeros(length(t),1);

    m = memristor(2, p, d, u_v, R_on, R_off, initial_x);

    amp = 1;

    for i = 2 : floor(length(t)/2)
        delta_t = t(i)-t(i-1);
        resistance(i) = update(m, amp, delta_t);
    end
    for i = floor(length(t)/2)+1 : length(t)
        delta_t = t(i)-t(i-1);
        resistance(i) = update(m, -amp, delta_t);
    end


    subplot(2,2,2)
    title('Resist�ncia com Fun��o Janela de Biolek')
    plot(t, resistance./1000, 'color', color, 'linewidth', 2)
    hold on

    if logy
        set(gca, 'YScale', 'log')
    end
    grid on
    xlabel('Tempo [s]')
    ylabel('Resist�ncia [k \Omega]')

    subplot(2,2,4)
    title('Condut�ncia com Fun��o Janela de Biolek')
    G = 1./resistance;
    plot(t, G, 'color', color, 'linewidth', 2)
    hold on
    ylim([0.5e-4 1.5e-2])

    if logy
        set(gca, 'YScale', 'log')
    end
    grid on
    xlabel('Tempo [s]')
    ylabel('Condut�ncia [S]')
end














