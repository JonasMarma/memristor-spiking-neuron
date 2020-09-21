%Classe instanciada para a criação de cada um dos memristores
%correspondentes às sinapses. A função update faz a atualização do
%componente a partir de uma tensão aplicada por um determinado intervalo
%(pequeno) de tempo

classdef memristor < handle
    properties
        type        %Tipo de janela
        p           %Parâmetro de não linearidade
        d           %Largura do memristor
        u_v         %Dopant drift mobilty
        R_on        %Resistência mínima
        R_off       %Resistência máxima
        
        x           %Posição normalizada da camada (entre 0 e 1)
        width       %Posição da camada
        resistance  %Resistência atual
        f_p
    end
    
    methods
        function obj = memristor(type, p, d, u_v, R_on, R_off, initial_x)
            if nargin == 0
                obj.type = 1;
                obj.p=1;
                obj.d = 9*10^(-9);
                obj.u_v = 30*10^-15;
                obj.R_on = 0.1*10^3;
                obj.R_off = 16*10^3;
                
                obj.x = 0.5;
            else
                obj.type = type;
                obj.p = p;
                obj.d = d;
                obj.u_v = u_v;
                obj.R_on = R_on;
                obj.R_off = R_off;
                
                obj.x = initial_x;
            end
            
            obj.width = obj.x * obj.d;
            obj.resistance = obj.R_on*(obj.width / obj.d) + obj.R_off*(1 - obj.width / obj.d);
        end
        
        function resistance = update(obj, voltage, delta_t)
            %Calcular a corrente e velocidade de drift
            current = voltage / obj.resistance;
            
            %Aplicar window function
            %1 = Joglekar, 2 = Biolek
            switch obj.type
                case 1
                    obj.f_p = 1 - (2 * obj.x - 1)^(2 * obj.p);
                case 2
                    obj.f_p = 1 - (obj.x - heaviside(-current))^(2 * obj.p);
                otherwise
                    error('Invalid memristor windoe function')
            end
            
            V_d = (obj.u_v * obj.R_on * current * obj.f_p) / obj.d;
            
            new_width = obj.width + V_d*delta_t;
            
            if new_width < 0.00001*obj.d
                new_width = 0.00001*obj.d;
            elseif new_width > 0.99999*obj.d
                new_width = 0.99999*obj.d;
            end
            
            %Mudar a largura da camada pela velocidade de drift
            obj.width = new_width;
            %Normalizar a largura
            obj.x = obj.width / obj.d;
            
            %Alterar a resistência
            obj.resistance = obj.R_on*(obj.width / obj.d) + obj.R_off*(1 - obj.width / obj.d);
            
            resistance = obj.resistance;
        end
    end
end