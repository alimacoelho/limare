%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Limaré VERSÃO MATLAB   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function limare()
tic
%% inicio dos cálculos

%%DEVELOPER OPTION - CUSTOM SHEET
if exist('databasecan.mat','file') %developer file
	name = "cananeia";
    data = struct2cell(load ('databasecan','-mat'));
    database = data{1,1}; %open constituents database
   if length(data)>2
       inicial = data{2,1}; %open default tide gauge (if exists)
       latitude = data{3,1};
   elseif length(data)>1
       inicial = data{2,1}; %open default tide gauge (if exists)
   end
filepath = 'D:\Documents\Code\MATLAB\t_tide\CAN_TEST.csv';
else


%%Entrada padrão do GLOSS
%import .csv as inicial
fprintf("Select Tide Gauge archive (.csv) \n ")
[file, path] = uigetfile('*.csv');

if isequal(file, 0)
    disp('User selected Cancel'); return
else
    disp(['User selected ', fullfile(path, file)]);
end
filepath = [path, file];
name = erase(file, '.csv');
inicial = readtable(filepath);
end

fprintf("Inicializando... \\n ");

%Matriz inicial 5 x n
%ano,dia, mes, hora, level
anoinicial = unique(inicial{1, 1}); %define o ano inicial ;
mesinicial = inicial{1, 2};
diainicial = inicial{1, 3};
horainicial = inicial{1, 4};
anofinal = inicial{(size(inicial, 1)), 1};
anostotais = anofinal - anoinicial + 1;
anoslong = anostotais - 19;
hoursperyear = zeros(anofinal - anoinicial + 1, 1);
anolongfinal = anoslong + anoinicial;

latitude = 0; %%%PADRAO
if exist('latitude', 'var') == 0
    latitude = input("Digite a latitude do maregrafo (separador decimal: ponto):  ");
else
end

%% IMPORTA BASE DE Componentes%
%%%cria um cell array - anual (componente(amplitude, fase)
%%cálculo pelo array ou por matriz?

% The input matrix = database
% File does not exist.
%import .csv as database

if exist('database.mat', 'file')
    database = load ('database', '-mat');
else
    fprintf("Select database archive (.mat)");
    [file2, path2] = uigetfile('*.mat');

    if isequal(file, 0)
        disp('User selected Cancel');
    else
        disp(['User selected ', fullfile(path2, file2)]);
        file2 = [path2, file2];
    end

    database = load (file2);
end

if isa(database, 'struct') == 1
    database = struct2cell(database);
    database = database{1, 1};
else
end

%% fim da limare_inic() - inicio das funções

%%[inicial,database] = limare_inic();
[vectoranual] = lim_vec();
[vectorlong] = lim_vec19();
[companuais, prevanuais] = lim_an(vectoranual);
%l = input("Deseja análise de longo período - 18.6 anos? (y(padrão)/n):  ")

[complong, prevlong] = lim_an19(vectorlong);

%%gera tabela individual por componente (não usado)

[tabelona] = lim_tab(companuais, database);

%if l ==  or("n", "N");
%else
[tablonga] = lim_tab19(complong, database);
%end

%[tendencia_comp] = lim_fit(tabelona) ;
%[tendencia_complong] = lim_fitlong(tablonga) ;
%calculates the slope and intercept and stores it into the "tendencia"
%cell array : tendencia (n) = {Amp(int(c), Slo(c)), Phase(int(c), Slo(c))

lim_exc(tabelona);

%if c == or ("y",  "Y");
% lim_exc_ind (tabelona)	;
%else
%end

%if l == or("n", "N");
%else
lim_exc19(tablonga);
%if c == "y" or "Y"
%	lim_exc_ind19 (tablonga);
%else
%end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%

%%%%%%%%%%%%%%%%%%%%%%%%%%% Módulo inicial: gera vetores anuais %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vectoranual] = lim_vec()
    %% gera vetor com elevações somente
    %Separação - Somente o Level
    for i = 0:1
        inicialvector = inicial(:, 5);
        outlier = isoutlier(inicialvector);
        findout = find(outlier);
        inicialvector{findout, :} = NaN; %Elimina os valores incoerentes, roda 2 vzs por segurança
    end

    iniv = table2array(inicialvector);
    inicial{:, 5} = iniv;

    %Separação em anos

    [~, ~, X] = unique(inicial(:, 1));

    %função unique retorna os valores únicos de todas as linhas(:) na coluna 1 (ano)
    %[~,~,X] extrai um vetor o índice dos valores únicos: 1º ano, indice 1, 2º ano, indice 2...

    %Primeiro ano = 1, segundo ano = 2....
    %Vetor X: 8670 valores de 1, depois 8784 valores de 2 (bissexto)...
    %definindo os vetores anuais

    localcell = accumarray(X, 1:size(inicial, 1), [], @(r){inicial(r, :)});

    %Gera uma cell array com y matrizes (1 por ano) contendo: ano,dia, mes, hora, level
    %Todos os valores anuais estão contidos nessa cell

    for i = anoinicial:anofinal
        hr = size(localcell{i - anoinicial + 1, 1});
        hoursperyear(i - anoinicial + 1, 1) = hr(1);
    end

    %Gerando o vetor de elevações p/ cada ano:

    cont1 = 1;
    vectoranual = cell(anostotais, 1);

    for y = 1:size(hoursperyear(:, 1))
        h = hoursperyear(y, 1);
        cont2 = cont1 + h - 1;
        vectoranual{y, 1} = table2array(inicialvector(cont1:cont2, 1));
        cont1 = cont2 + 1;
        fprintf("Montando vetores anuais...%d\n", y);

    end

    %% fim da lim_vec()
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Módulo: gerador de vetores 19 anos  %%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Baseado nos vetores anuais

function [vectorlong] = lim_vec19()
    vectorlong = cell(anoslong, 1);

    for indbase = 1:size(hoursperyear(:, 1)) - 18
        indfinal = indbase + 18;
        vector19 = cat(1, vectoranual{indbase:indfinal});
        vectorlong{indbase, 1} = vector19;
        fprintf("Montando vetores de 19 anos...%d\n", indbase);

    end

    %% fim da lim_vec19()
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Módulo análise anual  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%predefinir as cell arrays!!

function [companuais, prevanuais] = lim_an(vectoranual)
    companuais = cell(anofinal - anoinicial + 1, 1); % % %predefinir as cell arrays!!
    prevanuais = cell(anofinal - anoinicial + 1, 1);

    for y = anoinicial:anofinal
        fprintf("T_tide ano %d\n", y);

        if y == anoinicial
            mes = mesinicial;
            dia = diainicial;
            hora = horainicial;
        else
            mes = 1;
            dia = 1;
            hora = 0;
        end

        tempin = vectoranual{y - anoinicial + 1, 1}(:, 1);

        %%%Verifica se o ano tem menos de 30 dias
        nananuais = sum(isnan(tempin));

        if nananuais < size(tempin, 1) * (10/12)

            if exist('latitude') == 0
                [tidestruc, tempprev] = t_tide(tempin, 'interval', 1, 'start time', [y, mes, dia, hora, 0, 0], 'output', 'tempout1.txt', 'diary', 'none');
            else
                [tidestruc, tempprev] = t_tide(tempin, 'interval', 1, 'start time', [y, mes, dia, hora, 0, 0], 'latitude', latitude, 'output', 'tempout1.txt', 'diary', 'none');
            end

            temp = readtable('tempout1.txt', 'HeaderLines', 15);

            companuais{y - anoinicial + 1, 1} = temp;
            %% As componentes estão armazenadas nesse cell array, de y anos x 1

            prevanuais{y - anoinicial + 1, 1} = tempprev;

        else
            companuais{y - anoinicial + 1, 1} = array2table(NaN(size(companuais{y - anoinicial, 1})));

            prevanuais{y - anoinicial + 1, 1} = array2table(NaN(size(prevanuais{y - anoinicial, 1})));

        end

    end

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Módulo análise longas  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [complong, prevlong] = lim_an19(vectorlong)

    %%predefinições para o for e para determinar elementos "cell array":
    anolongfinal = anofinal - 19;
    complong = cell(anolongfinal - anoinicial + 1, 1);
    prevlong = cell(anolongfinal - anoinicial + 1, 1);

    for y = anoinicial:anolongfinal
        fprintf("T_tide 19 anos, inicial %d\n", y);

        if y == anoinicial
            mes = mesinicial;
            dia = diainicial;
            hora = horainicial;
        else
            mes = 1;
            dia = 1;
            hora = 0;
        end

        templongin = vectorlong{y - anoinicial + 1, 1}(:, 1);

        nanlong = sum(isnan(templongin));

        if nanlong < size(templongin, 1) * (10/12)
            [tidestruc, templongprev] = t_tide(templongin, 'interval', 1, 'start time', [y, mes, dia, hora, 0, 0], 'output', 'tempoutlong.txt', 'diary', 'none');

            %%%Verifica se o ano tem menos de 30 dias

            temp = readtable('tempoutlong.txt', 'HeaderLines', 15);
            %%Retira o cabeçalho da saída do t_tide, com dados de média, n de horas totais etc.

            complong{y - anoinicial + 1, 1} = temp;
            %% As componentes estão armazenadas nesse cell array, de y anos x 1

            prevlong{y - anoinicial + 1, 1} = templongprev;
        else
            complong{y - anoinicial + 1, 1} = array2table(NaN(size(complong{y - anoinicial, 1})));
            prevlong{y - anoinicial + 1, 1} = array2table(NaN(size(prevlong{y - anoinicial, 1})));
        end

    end

    complong = complong(~cellfun(@isempty, complong));

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Módulo "TABELONA" - componentes  (ANUAIS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tabelona] = lim_tab(companuais, database)

    freqbase = database{:, 2};
    ampbase = NaN(size(freqbase, 1), 1);
    amp_errbase = NaN(size(freqbase, 1), 1);
    phabase = NaN(size(freqbase, 1), 1);
    pha_errbase = NaN(size(freqbase, 1), 1);

    tabelona = NaN(size(freqbase, 1), anostotais, 5);

    for y = 1:size((companuais), 1) % % % %Nº de anos
        fprintf("Montando tabela anual %d\n", y);
        tempfreq = companuais{y, 1}{:, 2};
        tempamp = companuais{y, 1}{:, 3};
        tempamperr = companuais{y, 1}{:, 4};
        temppha = companuais{y, 1}{:, 5};
        tempphaerr = companuais{y, 1}{:, 6};

        [~, idx2] = ismembertol(freqbase, tempfreq, 10^ - 6); % %verifica a igualdade entre frequencias com tolerancia de 10^-6;

        [~, idx1] = ismembertol(tempfreq, freqbase, 10^ - 6); % %verifica a igualdade entre frequencias com tolerancia de 10^-6

        if isnan(tempfreq(1, 1)) %==1;
            freqbase = freqsave;
            ampbase = NaN(1, size(freqbase, 1))';
            amp_errbase = NaN(1, size(freqbase, 1))';
            phabase = NaN(1, size(freqbase, 1))';
            pha_errbase = NaN(1, size(freqbase, 1))';
        else
            freqbase(idx1) = tempfreq(idx2(idx1))';
            ampbase(idx1) = tempamp(idx2(idx1))';
            amp_errbase(idx1) = tempamperr(idx2(idx1))';
            phabase(idx1) = temppha(idx2(idx1))';
            pha_errbase(idx1) = tempphaerr(idx2(idx1))';
            freqsave = freqbase;
        end

        tabelona(:, y, 1) = freqbase;
        tabelona(:, y, 2) = ampbase;
        tabelona(:, y, 3) = phabase;
        tabelona(:, y, 4) = amp_errbase;
        tabelona(:, y, 5) = pha_errbase;

        %proximo ano
    end

    %insere tendencia após o ultimo ano aqui
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Módulo "TENDENCIA" COMPONENTES ANUAIS     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tendencia_comp] = lim_fit(tabelona) % % %mudar a saída: tendencia_comp
    ampmean = mean(tabelona, 2, 'omitnan');
    names = namebase;
    amps = tabelona(:, :, 2);
    pha = tabelona(:, :, 3);
    slope_amp = NaN(146, 1);
    slope_pha = NaN(146, 1);
    intercept_amp = NaN(146, 1);
    intercept_pha = NaN(146, 1);

    tendencia_comp = cell(146, 1);
    x = (anoinicial:anofinal);

    for c = 1:146
        y = amps(c, :);
        temp_trend_amp = polyfit(x, y, 1); %temp sai com os valores de slope e interc p/ a comp
        slope_amp(c) = temp_trend_amp(1);
        intercept_amp(c) = temp_trend_amp(2);

        z = pha(c, :);
        temp_trend_pha = polyfit(x, z, 1);
        slope_pha(c) = temp_trend_pha(1);
        intercept_pha(c) = temp_trend_pha(2);

        tendencia_comp{c} = {temp_trend_amp, temp_trend_pha};

    end %end for c = 1:146

end %end function

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Módulo "TABLONGA" - componentes  (LONGAS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tablonga] = lim_tab19(complong, database)

    namebase = database{:, 1};
    freqbase = database{:, 2};
    ampbase = NaN(size(freqbase, 1), 1);
    amp_errbase = NaN(size(freqbase, 1), 1);
    phabase = NaN(size(freqbase, 1), 1);
    pha_errbase = NaN(size(freqbase, 1), 1);

    tablonga = NaN(size(freqbase, 1), anoslong, 5);

    for y = 1:size((complong), 1) % % % %Nº de anos

        fprintf("Montando tabela longo periodo %d\n", y);

        tempfreq = complong{y, 1}{:, 2};
        tempamp = complong{y, 1}{:, 3};
        tempamperr = complong{y, 1}{:, 4};
        temppha = complong{y, 1}{:, 5};
        tempphaerr = complong{y, 1}{:, 6};

        [~, idx2] = ismembertol(freqbase, tempfreq, 10^ - 6); % %verifica a igualdade entre frequencias com tolerancia de 10^-6

        [~, idx1] = ismembertol(tempfreq, freqbase, 10^ - 6); % %verifica a igualdade entre frequencias com tolerancia de 10^-6

        if isnan(tempfreq(1, 1)) %==1
            freqbase = freqsave;
            ampbase = NaN(1, size(freqbase, 1))';
            amp_errbase = NaN(1, size(freqbase, 1))';
            phabase = NaN(1, size(freqbase, 1))';
            pha_errbase = NaN(1, size(freqbase, 1))';
        else
            freqbase(idx1) = tempfreq(idx2(idx1))';
            ampbase(idx1) = tempamp(idx2(idx1))';
            amp_errbase(idx1) = tempamperr(idx2(idx1))';
            phabase(idx1) = temppha(idx2(idx1))';
            pha_errbase(idx1) = tempphaerr(idx2(idx1))';
            freqsave = freqbase;
        end

        tablonga(:, y, 1) = freqbase;
        tablonga(:, y, 2) = ampbase;
        tablonga(:, y, 3) = phabase;
        tablonga(:, y, 4) = amp_errbase;
        tablonga(:, y, 5) = pha_errbase;

        %proximo ano
    end

    %insere tendencia após o ultimo ano aqui
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Módulo "TENDENCIA" COMPONENTES LONGAS     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tendencia_complong] = lim_fitlong(tablonga) % % %mudar a saída: tendencia_comp
    ampmean = mean(tablonga, 2, 'omitnan');
    amps = tablonga(:, :, 2);
    pha = tablonga(:, :, 3);
    slope_amp = NaN(146, 1);
    slope_pha = NaN(146, 1);
    intercept_amp = NaN(146, 1);
    intercept_pha = NaN(146, 1);

    tendencia_complong = cell(146, 1);
    x = (anoinicial:anolongfinal);

    for c = 1:146
        y = amps(c, :);
        temp_trend_amp = polyfit(x, y, 1); %temp sai com os valores de slope e interc p/ a comp
        slope_amp(c) = temp_trend_amp(1);
        intercept_amp(c) = temp_trend_amp(2);

        z = pha(c, :);
        temp_trend_pha = polyfit(x, z, 1);
        slope_pha(c) = temp_trend_pha(1);
        intercept_pha(c) = temp_trend_pha(2);

        tendencia_complong{c} = {temp_trend_amp, temp_trend_pha};

    end %end for c = 1:146

end %end function

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Módulo - ABAS amplitude, fase e erros  (ANUAIS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lim_exc(tabelona)

    arrayanos = NaN(anostotais, 1);

    for i = anoinicial:anofinal
        arrayanos(i - anoinicial + 1) = i;
    end

    arrayanos = num2cell(arrayanos);

    %%Cria cabeçalho%%%
    namebase = database{:, 1};
    freqbase = database{:, 2};

    nameheader = namebase;
    nameheader{end + 1} = 'YEAR';
    nameheader = circshift(nameheader, 1);
    nameheader = num2cell(nameheader');
    names = string(nameheader);

    freqheader = freqbase;
    freqheader(end + 1) = 0;
    freqheader = circshift(freqheader, 1);
    freqheader = num2cell(freqheader');

    %%%Coloca valores, frequencia e nome da componente
    Amp = reshape(tabelona(:, :, 2), [146, anostotais])';
    Amp = num2cell(Amp);
    Amp = cat(2, arrayanos, Amp);
    Amp = cat(1, freqheader, Amp);

    Pha = reshape(tabelona(:, :, 3), [146, anostotais])';
    Pha = num2cell(Pha);
    Pha = cat(2, arrayanos, Pha);
    Pha = cat(1, freqheader, Pha);

    Amp_err = reshape(tabelona(:, :, 4), [146, anostotais])';
    Amp_err = num2cell(Amp_err);
    Amp_err = cat(2, arrayanos, Amp_err);
    Amp_err = cat(1, freqheader, Amp_err);

    Pha_err = reshape(tabelona(:, :, 5), [146, anostotais])';
    Pha_err = num2cell(Pha_err);
    Pha_err = cat(2, arrayanos, Pha_err);
    Pha_err = cat(1, freqheader, Pha_err);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf("Exportando para excel (anuais)...\n");

    %%%Monta a tabela no excel
    exc = strcat('Componentes ', name, '.xlsx');

    allVars = 1:width(Amp);
    Amp = cell2table(Amp);
    Amp = renamevars(Amp, allVars, names);
    Amp_err = cell2table(Amp_err);
    Amp_err = renamevars(Amp_err, allVars, names);
    Pha = cell2table(Pha);
    Pha = renamevars(Pha, allVars, names);
    Pha_err = cell2table(Pha_err);
    Pha_err = renamevars(Pha_err, allVars, names);
    openexcel = "~"+exc;

if exist(openexcel,'file') == ~2
    [x,y] = system('taskkill /F /IM EXCEL.EXE'); %%fecha o excel
else
end
    writetable(Amp, exc, 'sheet', 'Amp')
    writetable(Amp_err, exc, 'sheet', 'Amp_err')
    writetable(Pha, exc, 'sheet', 'Pha')
    writetable(Pha_err, exc, 'sheet', 'Pha_err')

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Módulo - ABAS amplitude, fase e erros  (LONGAS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lim_exc19 (tablonga)
    arraylonganos = zeros(anostotais - 19, 1);

    for i = anoinicial:anolongfinal
        arraylonganos(i - anoinicial + 1) = i;
    end

    arraylonganos = num2cell(arraylonganos);

    %%Cria cabeçalho%%%
    namebase = database{:, 1};
    freqbase = database{:, 2};

    freqheader = freqbase;
    freqheader(end + 1) = 0;
    freqheader = circshift(freqheader, 1);
    freqheader = num2cell(freqheader');

    nameheader = namebase;
    nameheader{end + 1} = 'TIDE';
    nameheader = circshift(nameheader, 1);
    nameheader = num2cell(nameheader');
    names = string(nameheader);

    %%%Coloca valores, frequencia e nome da componente
    Amp19 = reshape(tablonga(:, :, 2), [146, anoslong])';
    Amp19 = num2cell(Amp19);
    Amp19 = cat(2, arraylonganos, Amp19);
    Amp19 = cat(1, freqheader, Amp19);

    Pha19 = reshape(tablonga(:, :, 3), [146, anoslong])';
    Pha19 = num2cell(Pha19);
    Pha19 = cat(2, arraylonganos, Pha19);
    Pha19 = cat(1, freqheader, Pha19);

    Amp19_err = reshape(tablonga(:, :, 4), [146, anoslong])';
    Amp19_err = num2cell(Amp19_err);
    Amp19_err = cat(2, arraylonganos, Amp19_err);
    Amp19_err = cat(1, freqheader, Amp19_err);

    Pha19_err = reshape(tablonga(:, :, 5), [146, anoslong])';
    Pha19_err = num2cell(Pha19_err);
    Pha19_err = cat(2, arraylonganos, Pha19_err);
    Pha19_err = cat(1, freqheader, Pha19_err);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%Monta a tabela no excel
    fprintf("Exportando para excel...(longo período) \n ");

    exc19 = strcat('Componentes19 ', name, '.xlsx');

    allVars = 1:width(Amp19);
    Amp19 = cell2table(Amp19);
    Amp19 = renamevars(Amp19, allVars, names);
    Amp19_err = cell2table(Amp19_err);
    Amp19_err = renamevars(Amp19_err, allVars, names);
    Pha19 = cell2table(Pha19);
    Pha19 = renamevars(Pha19, allVars, names);
    Pha19_err = cell2table(Pha19_err);
    Pha19_err = renamevars(Pha19_err, allVars, names);
    openexcel = "~"+exc19;

if exist(openexcel,'file') == ~2
    [x,y] = system('taskkill /F /IM EXCEL.EXE'); %%fecha o excel
else
end
    writetable(Amp19, exc19, 'sheet', 'Amp19')
    writetable(Amp19_err, exc19, 'sheet', 'Amp19_err')
    writetable(Pha19, exc19, 'sheet', 'Pha19')
    writetable(Pha19_err, exc19, 'sheet', 'Pha19_err')

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%% Módulo Tendencias %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tabtend, tabtendlong ] = lim_an (tabelona,tablonga)



% analisa o numero de linhas (nome, freq  numero de anos, 146 colunas mais 1 de anos)
tabtend = NaN(size(tabelona, 1), 8);
tabtendlong = NaN(size(tablonga, 1), 8);
%
for k = 1:anostotais
		x(1,k) = anoinicial+j;
		j = j+1;
	end 
xerr = x;
xerr(:,:) = 0;


warning('off','all');
for i = 1:146  %anuais
    A = NaN;
    P = NaN;
    ASP = NaN;
    PSP = NaN;
	amp = tabelona(i,:,2); %amp
	amperr = tabelona(i,:,4); %amperr
	pha = tabelona(i,:,3); %pha
	phaerr = tabelona(i,:,5); %phaerr
if sum(isnan(amp))>0
else
    try
    [A,ASP] = linfitxy(x, amp, xerr, amperr);
    [P,PSP] = linfitxy(x, pha, xerr, phaerr)  ;   

    tabtend(i,1) = A(1,1); %amp sl
    tabtend(i,2) = A(1,2);	%amp int
    tabtend(i,3) = P(1,1) ;  %pha sl
    tabtend(i,4) = P(1,2) ;  %amp int
    
    tabtend(i,5) = ASP(1,1); %amp_err sl
    tabtend(i,6) = ASP(1,2);	%amp_err int
    tabtend(i,7) = PSP(1,1); %pha_err sl
    tabtend(i,8) = PSP(1,2);	%pha_err int
   
    end  
end 
    
    
end


for i = 1:146  %long
    A = NaN;
    P = NaN;
    ASP = NaN;
    PSP = NaN;
	amp = tablonga(i,:,2); %amp
	amperr = tablonga(i,:,4); %amperr
	pha = tablonga(i,:,3); %pha
	phaerr = tablonga(i,:,5); %phaerr
if sum(isnan(amp))>0
else
    try
    [A,ASP] = linfitxy(x, amp, xerr, amperr);
    [P,PSP] = linfitxy(x, pha, xerr, phaerr)  ;   

    tabtendlong(i,1) = A(1,1); %amp sl
    tabtendlong(i,2) = A(1,2);	%amp int
    tabtendlong(i,3) = P(1,1) ;  %pha sl
    tabtendlong(i,4) = P(1,2) ;  %amp int
    
    tabtendlong(i,5) = ASP(1,1); %amp_err sl
    tabtendlong(i,6) = ASP(1,2);	%amp_err int
    tabtendlong(i,7) = PSP(1,1); %pha_err sl
    tabtendlong(i,8) = PSP(1,2);	%pha_err int
   
    end  
end 
    
    
end

%interc é calculado com base na 

end

toc



end %end root
