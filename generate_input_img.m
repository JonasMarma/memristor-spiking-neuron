%Cria um padrão de pesos de ruído ou um dos padrões pré estabelecidos

function input_img = generate_input_img(random, number)
    patterns = get_patterns();
    
    %Condições para gerar um padrão de ruído (número inválido ou random = true)
    if random || number == 0 || number > length(patterns)
        input_img = zeros(1, 64);
        for s = 1 : 64
            if randi([1 13], 1) == 1
                input_img(s) = 1;
            end
        end
    else
        input_img = patterns(number,:);
    end
end