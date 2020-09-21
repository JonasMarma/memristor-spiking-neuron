%Cria um padr�o de pesos de ru�do ou um dos padr�es pr� estabelecidos

function input_img = generate_input_img(random, number)
    patterns = get_patterns();
    
    %Condi��es para gerar um padr�o de ru�do (n�mero inv�lido ou random = true)
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