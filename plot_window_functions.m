close all;
clear all;
clc;

%Este script é independente dos demais e apenas gera gráficos comparando as
%funções janela de Biolek e Joglekar para diferetes valores de p

x = linspace(0, 1);

figure(1)
subplot(1, 2, 1)
hold on

p = 1;
f = 1 - (2*x - 1).^(2*p);
plot(x, f, 'color', 'r', 'linewidth', 1)

p = 5;
f = 1 - (2*x - 1).^(2*p);
plot(x, f, 'color', 'b', 'linewidth', 1)

p = 10;
f = 1 - (2*x - 1).^(2*p);
plot(x, f, 'color', 'g', 'linewidth', 1)

ylim([0 1.1])

xlabel('x')
ylabel('f(x)')

hold off


subplot(1, 2, 2)
hold on
%casos positivos
p = 1;
f = 1 - (x - 0).^(2*p);
plot(x, f, '--r', 'linewidth', 1)

p = 5;
f = 1 - (x - 0).^(2*p);
plot(x, f, '--b', 'linewidth', 1.6)

p = 10;
f = 1 - (x - 0).^(2*p);
plot(x, f, '--g', 'linewidth', 1)

%casos negativos
p = 1;
f = 1 - (x - 1).^(2*p);
plot(x, f, 'color', 'r', 'linewidth', 1)

p = 5;
f = 1 - (x - 1).^(2*p);
plot(x, f, 'color', 'b', 'linewidth', 1.6)

p = 10;
f = 1 - (x - 1).^(2*p);
plot(x, f, 'color', 'g', 'linewidth', 1)


ylim([0 1.1])

xlabel('x')
ylabel('f(x)')

hold off






