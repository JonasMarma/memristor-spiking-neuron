clc;
clear all;
close all;

%Este script plota as curvas de histerese para memristores não-lineares com
%as funções janela de Biolek e Joglekar para diferentes valores de p.

d = 9*10^(-9);
u_v = 30*10^-15;
R_on = 0.1*10^3;
R_off = 16*10^3;
initial_x = 0.5;

p_values = [1 5 10];

figure(1)

%% Histerese Jonglekar f6
subplot(2, 2, 1)
for i = 1 : length(p_values)
    f = 6;
    T = 1/f;
    t = 0:0.001:T;
    
    p = p_values(i);

    voltage = sin(2*pi*f*t);
    current = zeros(length(t),1);

    m = memristor(1, p, d, u_v, R_on, R_off, initial_x);

    for j=2:length(t)
        delta_t = t(j)-t(j-1);
        resistance = update(m, voltage(j), delta_t);
        current(j) = voltage(j)/resistance;
    end

    color = '';
    switch i
        case 1
            color = 'r';
        case 2
            color = 'b';
        case 3
            color = 'g';
    end
    plot(voltage, 1000*current, 'color', color, 'linewidth', 1);
    hold on
end

title('Função de Janela de Joglekar f = 6 Hz')
xlabel('Tensão [V]')
ylabel('Corrente [mA]')

%% Histerese Biolek f6
subplot(2,2,2)
for i = 1 : length(p_values)
    f = 6;
    T = 1/f;
    t = 0:0.001:T;
    
    p = p_values(i);

    voltage = sin(2*pi*f*t);
    current = zeros(length(t),1);

    m = memristor(2, p, d, u_v, R_on, R_off, initial_x);

    for j=2:length(t)
        delta_t = t(j)-t(j-1);
        resistance = update(m, voltage(j), delta_t);
        current(j) = voltage(j)/resistance;
    end
    
    color = '';
    switch i
        case 1
            color = 'r';
        case 2
            color = 'b';
        case 3
            color = 'g';
    end
    plot(voltage, 1000*current, 'color', color, 'linewidth', 1);
    hold on
end

title('Função de Janela de Biolek f = 6 Hz')
xlabel('Tensão [V]')
ylabel('Corrente [mA]')

legend('p = 1', 'p = 5', 'p = 10')

%% Histerese Jonglekar f10
subplot(2, 2, 3)
for i = 1 : length(p_values)
    f = 10;
    T = 1/f;
    t = 0:0.001:T;
    
    p = p_values(i);

    voltage = sin(2*pi*f*t);
    current = zeros(length(t),1);

    m = memristor(1, p, d, u_v, R_on, R_off, initial_x);

    for j=2:length(t)
        delta_t = t(j)-t(j-1);
        resistance = update(m, voltage(j), delta_t);
        current(j) = voltage(j)/resistance;
    end

    color = '';
    switch i
        case 1
            color = 'r';
        case 2
            color = 'b';
        case 3
            color = 'g';
    end
    plot(voltage, 1000*current, 'color', color, 'linewidth', 1);
    hold on
end

title('Função de Janela de Joglekar f = 10 Hz')
xlabel('Tensão [V]')
ylabel('Corrente [mA]')

%% Histerese Biolek f10
subplot(2,2,4)
for i = 1 : length(p_values)
    f = 10;
    T = 1/f;
    t = 0:0.001:T;
    
    p = p_values(i);

    voltage = sin(2*pi*f*t);
    current = zeros(length(t),1);

    m = memristor(2, p, d, u_v, R_on, R_off, initial_x);

    for j=2:length(t)
        delta_t = t(j)-t(j-1);
        resistance = update(m, voltage(j), delta_t);
        current(j) = voltage(j)/resistance;
    end
    
    color = '';
    switch i
        case 1
            color = 'r';
        case 2
            color = 'b';
        case 3
            color = 'g';
    end
    plot(voltage, 1000*current, 'color', color, 'linewidth', 1);
    hold on
end

title('Função de Janela de Biolek f = 10 Hz')
xlabel('Tensão [V]')
ylabel('Corrente [mA]')

legend('p = 1', 'p = 5', 'p = 10')
