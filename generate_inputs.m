%Cria uma matriz em que cada linha corresponde aos inputs (sequências de
%pulsos e tensões nulas) correspondentes a cada sinapse.

function inputs = generate_inputs(amp, freq, N_epoch, T_epoch, Ts, N_inputs, pattern_period, duty, pattern_sequence, pattern_epochs)

    %Vetor de tempo
    t = 0:Ts:T_epoch;
    %Função dente de serra
    fun = (sawtooth(2*pi*freq*t) + 1)/2;
    %Obter PWM
    pwm = amp*(fun>(1-duty));

    step_per_epoch = T_epoch/Ts;

    %Criar vetor de zeros com o número total de passos usados    
    inputs = zeros(N_inputs, N_epoch*step_per_epoch);
    
    index = 0;

    for epoch = 1 : N_epoch
        %Gerar a imagem para a época atual
        
        %Mudar o índice do padrão apresentado
        if index + 1 <= length(pattern_epochs)
            if epoch == pattern_epochs(index + 1)
                index = index + 1;
            end
        end
        
        %Gerar padrão ou ruído
        if index == 0 || index > length(pattern_sequence)
            input_img = generate_input_img(true, 0);
        elseif mod(epoch, pattern_period) == 0
            input_img = generate_input_img(false, pattern_sequence(index));
        else
            input_img = generate_input_img(true, pattern_sequence(index));
        end

        %Preencher os inputs de acordo com a imagem gerada
        for i = 1 : N_inputs
            %Gerar uma sequência de impulsos para a intensidade do pixel
            if input_img(i) == 1
                initial = epoch*step_per_epoch;

                inputs(i, initial : initial + step_per_epoch) = pwm;
            else
                continue;
            end
        end
    end
end