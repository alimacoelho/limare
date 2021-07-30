%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Limaré VERSÃO MATLAB   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




function limare()
tic
%% inicio dos cálculos

	%%Entrada padrão do GLOSS
	%import .csv as inicial
	fprintf("Select Tide Gauge archive (.csv) \n ")
	[file,path] = uigetfile('*.csv');
	if isequal(file,0)
		disp('User selected Cancel'); return
	else
		disp(['User selected ', fullfile(path,file)]);
	end

	fprintf("Inicializando... \n ");

	filepath = [path,file];

	inicial = readtable(filepath);
	%Matriz inicial 5 x n
	%ano,dia, mes, hora, level
	anoinicial = unique(inicial{1,1}); %define o ano inicial ;
	mesinicial = inicial{1,2};
	diainicial = inicial{1,3};
	horainicial = inicial{1,4};
	anofinal = inicial{(size(inicial,1)),1};
	anostotais = anofinal- anoinicial+1;
	anoslong = anostotais - 19;
	hoursperyear = zeros(anofinal-anoinicial+1,1);
    anolongfinal = anoslong+anoinicial;
    if exist('latitude','var') == 0
		latitude = input("Digite a latitude do maregrafo (separador decimal: ponto):  ");
    else
    end
    
    
    
    
    %% IMPORTA BASE DE Componentes%
	%%%cria um cell array - anual (componente(amplitude, fase)
	%%cálculo pelo array ou por matriz?

	% The input matrix = database
	% File does not exist.
	%import .csv as database
    
    if exist('database.mat','file')
		database = load ('database','-mat');
	else
		fprintf("Select database archive (.mat)");
		[file2,path2] = uigetfile('*.mat');
		if isequal(file,0)
			disp('User selected Cancel');
		else
			disp(['User selected ', fullfile(path2,file2)]);
			file2 = [path2,file2];
		end
		database = load (file2);
    end
    
    if isa(database,'struct') ==1
        database = struct2cell(database);
        database = database{1,1};
    else
    end
    
    name = erase(file, '.csv');
    
    
%% fim da limare_inic() - inicio das funções











%%[inicial,database] = limare_inic();
[vectoranual] = lim_vec();
[vectorlong]= lim_vec19();
[companuais,prevanuais] = lim_an(vectoranual);
%l = input("Deseja análise de longo período - 18.6 anos? (y(padrão)/n):  ")

[complong, prevlong] = lim_an19(vectorlong); 
        
        %%gera tabela individual por componente (não usado)
	

[tabelona] = lim_tab(companuais,database);


	%if l ==  or("n", "N");
	%else
	[tablonga] = lim_tab19(complong,database);	
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
	
.
.
















	
	
	
	
	
	
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%

%%%%%%%%%%%%%%%%%%%%%%%%%%% Módulo inicial: gera vetores anuais %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vectoranual] = lim_vec()
	%% gera vetor com elevações somente
	%Separação - Somente o Level
	for i = 0:1
		inicialvector = inicial(:,5);
		outlier = isoutlier(inicialvector);
		findout = find(outlier);
		inicialvector{findout,:} = NaN;  %Elimina os valores incoerentes, roda 2 vzs por segurança
	end
	
	iniv = table2array(inicialvector);
	inicial{:,5} = iniv;
	
	
	%Separação em anos
	
	[~,~,X] = unique(inicial(:,1));
	
	%função unique retorna os valores únicos de todas as linhas(:) na coluna 1 (ano)
	%[~,~,X] extrai um vetor o índice dos valores únicos: 1º ano, indice 1, 2º ano, indice 2...
	
	%Primeiro ano = 1, segundo ano = 2....
	%Vetor X: 8670 valores de 1, depois 8784 valores de 2 (bissexto)...
	%definindo os vetores anuais
	
	localcell = accumarray(X,1:size(inicial,1),[],@(r){inicial(r,:)});
	
	%Gera uma cell array com y matrizes (1 por ano) contendo: ano,dia, mes, hora, level
	%Todos os valores anuais estão contidos nessa cell
	
	
	
	for i = anoinicial:anofinal
		hr = size(localcell{i-anoinicial+1,1});
		hoursperyear(i-anoinicial+1,1) = hr(1);
	end
	
	
	%Gerando o vetor de elevações p/ cada ano:
	
	cont1=1;
	vectoranual = cell(anostotais,1);
	
	
	for y = 1:size(hoursperyear(:,1))
		h = hoursperyear(y,1);
		cont2 = cont1+h-1;
		vectoranual{y,1} = table2array(inicialvector(cont1:cont2,1));
		cont1 = cont2+1;
		fprintf("Montando vetores anuais...%d\n",y);
		
	end
	%% fim da lim_vec()
end









%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Módulo: gerador de vetores 19 anos  %%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Baseado nos vetores anuais

function [vectorlong]= lim_vec19()
	vectorlong = cell(anoslong,1);
	
	for indbase = 1:size(hoursperyear(:,1))-18
		indfinal = indbase+18;
		vector19 = cat(1,vectoranual{indbase:indfinal});
		vectorlong{indbase,1} = vector19;
		fprintf("Montando vetores de 19 anos...%d\n",indbase);
		
	end
	
%% fim da lim_vec19()   
end






%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Módulo análise anual  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%predefinir as cell arrays!!


function [companuais,prevanuais] = lim_an(vectoranual)
	companuais = cell(anofinal-anoinicial+1,1);%%%predefinir as cell arrays!!
	prevanuais = cell(anofinal-anoinicial+1,1);
	
	
	for y = anoinicial:anofinal
		fprintf("T_tide ano %d\n",y);
		
		if y == anoinicial
			mes = mesinicial;
			dia = diainicial;
			hora = horainicial;
		else
			mes = 1;
			dia = 1;
			hora = 0;
		end
		
		
		tempin = vectoranual{y-anoinicial+1,1}(:,1);
		
		%%%Verifica se o ano tem menos de 30 dias
		nananuais = sum(isnan(tempin));
		
		if nananuais < size(tempin,1)*(10/12)
			
			if exist('latitude')==0
				[tidestruc,tempprev] = t_tide(tempin,'interval',1,'start time', [y,mes,dia,hora,0,0], 'output', 'tempout1.txt','diary','none');
			else
				[tidestruc,tempprev] = t_tide(tempin,'interval',1,'start time', [y,mes,dia,hora,0,0], 'latitude', latitude, 'output', 'tempout1.txt','diary','none');
			end
			
			
			temp = readtable('tempout1.txt','HeaderLines',15);
			
			companuais{y-anoinicial+1,1} = temp;
			%% As componentes estão armazenadas nesse cell array, de y anos x 1
			
			prevanuais{y-anoinicial+1,1} = tempprev;
			
		else
			companuais{y-anoinicial+1,1} = array2table(NaN(size(companuais{y-anoinicial,1})));
			
			
			prevanuais{y-anoinicial+1,1} = array2table(NaN(size(prevanuais{y-anoinicial,1})));
			
		end 
		
	end
	
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Módulo análise longas  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [complong, prevlong] = lim_an19(vectorlong)
	
	
	%%predefinições para o for e para determinar elementos "cell array":
	anolongfinal = anofinal-19;
	complong = cell(anolongfinal-anoinicial+1,1);
	prevlong = cell(anolongfinal-anoinicial+1,1);
	
	for y = anoinicial:anolongfinal
		fprintf("T_tide 19 anos, inicial %d\n",y);
		if y == anoinicial
			mes = mesinicial;
			dia = diainicial;
			hora = horainicial;
		else
			mes = 1;
			dia = 1;
			hora = 0;
		end
		
		templongin = vectorlong{y-anoinicial+1,1}(:,1);
		
		nanlong = sum(isnan(templongin));
		
		if nanlong < size(templongin,1)*(10/12)
			[tidestruc,templongprev] = t_tide(templongin,'interval',1,'start time', [y,mes,dia,hora,0,0], 'output', 'tempoutlong.txt','diary','none');
			
			%%%Verifica se o ano tem menos de 30 dias
			
			
			temp = readtable('tempoutlong.txt','HeaderLines',15);
			%%Retira o cabeçalho da saída do t_tide, com dados de média, n de horas totais etc.
			
			complong{y-anoinicial+1,1} = temp;
			%% As componentes estão armazenadas nesse cell array, de y anos x 1
			
			
			prevlong{y-anoinicial+1,1} = templongprev;
		else
			complong{y-anoinicial+1,1} = array2table(NaN(size(complong{y-anoinicial,1})));
			prevlong{y-anoinicial+1,1} = array2table(NaN(size(prevlong{y-anoinicial,1})));
		end
	end
	
	complong = complong(~cellfun(@isempty, complong));
	
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Módulo "TABELONA" - componentes  (ANUAIS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tabelona] = lim_tab(companuais,database)
	
	
	
	
	freqbase = database{:,2};
	ampbase = 		NaN(size(freqbase,1),1);
	amp_errbase = 	NaN(size(freqbase,1),1);
	phabase = 		NaN(size(freqbase,1),1);
	pha_errbase = 	NaN(size(freqbase,1),1);
	
	
	
	tabelona = NaN(size(freqbase,1),anostotais,5);
	
	
	for y = 1:size((companuais),1) %%%%Nº de anos
		fprintf("Montando tabela anual %d\n",y);
		tempfreq = companuais{y,1}{:,2};
		tempamp = companuais{y,1}{:,3};
		tempamperr = companuais{y,1}{:,4};
		temppha = companuais{y,1}{:,5};
		tempphaerr = companuais{y,1}{:,6};
		
		[~,idx2] = ismembertol(freqbase,tempfreq,10^-6); %%verifica a igualdade entre frequencias com tolerancia de 10^-6;
		
		[~,idx1] = ismembertol(tempfreq,freqbase,10^-6); %%verifica a igualdade entre frequencias com tolerancia de 10^-6
		
		if isnan(tempfreq(1,1)) %==1;
			freqbase = freqsave;
			ampbase = NaN(1,size(freqbase,1))';
			amp_errbase = NaN(1,size(freqbase,1))';
			phabase = NaN(1,size(freqbase,1))';
			pha_errbase = NaN(1,size(freqbase,1))';
		else
			freqbase(idx1) = tempfreq(idx2(idx1))';
			ampbase(idx1) = tempamp(idx2(idx1))';
			amp_errbase(idx1) = tempamperr(idx2(idx1))';
			phabase(idx1) = temppha(idx2(idx1))';
			pha_errbase(idx1) = tempphaerr(idx2(idx1))';
			freqsave = freqbase;
		end
		
		tabelona(:,y,1) = freqbase;
		tabelona(:,y,2) = ampbase;
		tabelona(:,y,3) = phabase;
		tabelona(:,y,4) = amp_errbase;
		tabelona(:,y,5) = pha_errbase;
		
		%proximo ano
    end
%insere tendencia após o ultimo ano aqui		
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Módulo "TENDENCIA" COMPONENTES ANUAIS     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function[tendencia_comp] = lim_fit(tabelona) %%%mudar a saída: tendencia_comp
   ampmean = mean(tabelona,2,'omitnan');    
   amps = tabelona(:,:,2);
   pha = tabelona(:,:,3);
   slope_amp = NaN(146,1);
   slope_pha = NaN(146,1);
   intercept_amp = NaN(146,1);
   intercept_pha = NaN(146,1);
    
   tendencia_comp = cell(146,1);
   x = (anoinicial:anofinal);
	for c = 1:146
		y = amps(c,:);
		temp_trend_amp = polyfit(x,y,1); %temp sai com os valores de slope e interc p/ a comp
        slope_amp(c)= temp_trend_amp(1);
        intercept_amp(c) = temp_trend_amp(2);
        
        z = pha(c,:);
        temp_trend_pha = polyfit(x,z,1);
        slope_pha(c)= temp_trend_pha(1);
        intercept_pha(c) = temp_trend_pha(2);
  
        tendencia_comp{c} = {temp_trend_amp, temp_trend_pha};      
        
	end %end for c = 1:146 
    
    
    
end %end function

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Módulo "TABLONGA" - componentes  (LONGAS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [tablonga] = lim_tab19(complong,database)
	
	
	namebase = database{:,1};
	freqbase = database{:,2};
	ampbase = 		NaN(size(freqbase,1),1);
	amp_errbase = 	NaN(size(freqbase,1),1);
	phabase = 		NaN(size(freqbase,1),1);
	pha_errbase = 	NaN(size(freqbase,1),1);
	
	
	
	tablonga = NaN(size(freqbase,1),anoslong,5);
	
	
	for y = 1:size((complong),1) %%%%Nº de anos
		
		fprintf("Montando tabela longo periodo %d\n",y);
		
		
		tempfreq = complong{y,1}{:,2};
		tempamp = complong{y,1}{:,3};
		tempamperr = complong{y,1}{:,4};
		temppha = complong{y,1}{:,5};
		tempphaerr = complong{y,1}{:,6};
		
		[~,idx2] = ismembertol(freqbase,tempfreq,10^-6); %%verifica a igualdade entre frequencias com tolerancia de 10^-6
		
		[~,idx1] = ismembertol(tempfreq,freqbase,10^-6); %%verifica a igualdade entre frequencias com tolerancia de 10^-6
		
		if isnan(tempfreq(1,1)) %==1
			freqbase = freqsave;
			ampbase = NaN(1,size(freqbase,1))';
			amp_errbase = NaN(1,size(freqbase,1))';
			phabase = NaN(1,size(freqbase,1))';
			pha_errbase = NaN(1,size(freqbase,1))';
		else
			freqbase(idx1) = tempfreq(idx2(idx1))';
			ampbase(idx1) = tempamp(idx2(idx1))';
			amp_errbase(idx1) = tempamperr(idx2(idx1))';
			phabase(idx1) = temppha(idx2(idx1))';
			pha_errbase(idx1) = tempphaerr(idx2(idx1))';
			freqsave = freqbase;
		end
		
		
		
		
		tablonga(:,y,1) = freqbase;
		tablonga(:,y,2) = ampbase;
		tablonga(:,y,3) = phabase;
		tablonga(:,y,4) = amp_errbase;
		tablonga(:,y,5) = pha_errbase;
		
		%proximo ano
	end
%insere tendencia após o ultimo ano aqui	
end
	
	
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Módulo "TENDENCIA" COMPONENTES LONGAS     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function[tendencia_complong] = lim_fitlong(tablonga) %%%mudar a saída: tendencia_comp
   ampmean = mean(tablonga,2,'omitnan');    
   amps = tablonga(:,:,2);
   pha = tablonga(:,:,3);
   slope_amp = NaN(146,1);
   slope_pha = NaN(146,1);
   intercept_amp = NaN(146,1);
   intercept_pha = NaN(146,1);
    
   tendencia_complong = cell(146,1);
   x = (anoinicial:anolongfinal);
	for c = 1:146
		y = amps(c,:);
		temp_trend_amp = polyfit(x,y,1); %temp sai com os valores de slope e interc p/ a comp
        slope_amp(c)= temp_trend_amp(1);
        intercept_amp(c) = temp_trend_amp(2);
        
        z = pha(c,:);
        temp_trend_pha = polyfit(x,z,1);
        slope_pha(c)= temp_trend_pha(1);
        intercept_pha(c) = temp_trend_pha(2);
  
        tendencia_complong{c} = {temp_trend_amp, temp_trend_pha};      
        
	end %end for c = 1:146 
    
    
    
end %end function




	
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Módulo - ABAS amplitude, fase e erros  (ANUAIS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   function lim_exc(tabelona)
        
        
        arrayanos = NaN(anostotais,1);
        for i=anoinicial:anofinal
            arrayanos(i-anoinicial+1) = i;
        end
        arrayanos = num2cell(arrayanos);
        
        %%Cria cabeçalho%%%
        namebase = database{:,1};
        freqbase = database{:,2};
        
        freqheader = freqbase;
        freqheader(end+1) = 0;
        freqheader = circshift(freqheader,1);
        freqheader = num2cell(freqheader') ;
        
        nameheader = namebase;
        nameheader{end+1} = 'TIDE';
        nameheader = circshift(nameheader,1);
        nameheader = num2cell(nameheader');
        
        %%%Coloca valores, frequencia e nome da componente
        Amp = reshape(tabelona(:,:,2),[146,anostotais])';
        Amp = num2cell(Amp);
        Amp = cat(2,arrayanos,Amp);
        Amp = cat(1,freqheader,Amp);
        Amp = cat(1,nameheader,Amp);
        
        
        
        Pha = reshape(tabelona(:,:,3),[146,anostotais])';
        Pha = num2cell(Pha);
        Pha = cat(2,arrayanos,Pha);
        Pha = cat(1,freqheader,Pha);
        Pha = cat(1,nameheader,Pha);
        
        
        Amp_err = reshape(tabelona(:,:,4),[146,anostotais])';
        Amp_err = num2cell(Amp_err);
        Amp_err = cat(2,arrayanos,Amp_err); 
        Amp_err = cat(1,freqheader,Amp_err);
        Amp_err = cat(1,nameheader,Amp_err);
        
        
        Pha_err = reshape(tabelona(:,:,5),[146,anostotais])';
        Pha_err = num2cell(Pha_err);
        Pha_err = cat(2,arrayanos,Pha_err);
        Pha_err = cat(1,freqheader,Pha_err);
        Pha_err = cat(1,nameheader,Pha_err);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf("Exportando para excel (anuais)...");
        
        %%%Monta a tabela no excel
        exc = strcat('Componentes ',name,'.xlsx');
        
xlswrite(exc,Amp,'Amplitude');
xlswrite(exc,Pha ,'Phase');
xlswrite(exc,Amp_err ,'Amplitude error');
xlswrite(exc,Pha_err ,'Phase error');
        
        
        
        
	
end 		







   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%% Módulo - ABAS amplitude, fase e erros  (LONGAS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lim_exc19 (tablonga)
	arraylonganos = zeros(anostotais-19,1);
	
	for i=anoinicial:anolongfinal
		arraylonganos(i-anoinicial+1) = i;
	end
	arraylonganos = num2cell(arraylonganos);
	
	%%Cria cabeçalho%%%
	namebase = database{:,1};
        freqbase = database{:,2};
        
        freqheader = freqbase;
        freqheader(end+1) = 0;
        freqheader = circshift(freqheader,1);
        freqheader = num2cell(freqheader') ;
        
        nameheader = namebase;
        nameheader{end+1} = 'TIDE';
        nameheader = circshift(nameheader,1);
        nameheader = num2cell(nameheader');
        
        %%%Coloca valores, frequencia e nome da componente
        Amp19 = reshape(tablonga(:,:,2),[146,anoslong])';
        Amp19 = num2cell(Amp19);
        Amp19 = cat(2,arraylonganos,Amp19);
        Amp19 = cat(1,freqheader,Amp19);
        Amp19 = cat(1,nameheader,Amp19);
        
        
        
        Pha19 = reshape(tablonga(:,:,3),[146,anoslong])';
        Pha19 = num2cell(Pha19);
        Pha19 = cat(2,arraylonganos,Pha19);
        Pha19 = cat(1,freqheader,Pha19);
        Pha19 = cat(1,nameheader,Pha19);
        
        
        Amp19_err = reshape(tablonga(:,:,4),[146,anoslong])';
        Amp19_err = num2cell(Amp19_err);
        Amp19_err = cat(2,arraylonganos,Amp19_err); 
        Amp19_err = cat(1,freqheader,Amp19_err);
        Amp19_err = cat(1,nameheader,Amp19_err);
        
        
        Pha19_err = reshape(tablonga(:,:,5),[146,anoslong])';
        Pha19_err = num2cell(Pha19_err);
        Pha19_err = cat(2,arraylonganos,Pha19_err);
        Pha19_err = cat(1,freqheader,Pha19_err);
        Pha19_err = cat(1,nameheader,Pha19_err);
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%Monta a tabela no excel
	fprintf("Exportando para excel...(longo período) \n ");
	
    exc19 = strcat('Componentes19 ',name,'.xlsx');
xlswrite(exc19,Amp19 ,'Amplitude');
xlswrite(exc19,Pha19 ,'Phase');
xlswrite(exc19,Amp19_err ,'Amplitude error');
xlswrite(exc19,Pha19_err ,'Phase error');
	
	%exceltypes = {'*.xlsx';'*.xls';'*.csv';'*.txt*';'*.*'};
	%[file,name,path] = uiputfile(exceltypes,'Save as','Componentes19.xlsx');
	%if isequal(file,0)
	%	disp('User selected Cancel'); return
	%else
	%	disp(['User selected ', fullfile(path,file)]);
	%end
	
	
	
end	






	%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%% Módulo ABAS - cada componente (ANUAIS)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lim_exc_ind (tabelona)	
	compheader = ["YEAR","FREQ.","AMPLITUDE","AMP_ERR","PHASE","PHASE_ERR"];
	for i=anoinicial:anofinal
		arrayanos(i-anoinicial+1) = i;
	end
	
	
	
	Z0  	= cat(2,arrayanos,reshape(tabelona(	1	,:,:),[anostotais,5]));
	SA  	= cat(2,arrayanos,reshape(tabelona(	2	,:,:),[anostotais,5]));
	SSA 	= cat(2,arrayanos,reshape(tabelona(	3	,:,:),[anostotais,5]));
	MSM 	= cat(2,arrayanos,reshape(tabelona(	4	,:,:),[anostotais,5]));
	MM  	= cat(2,arrayanos,reshape(tabelona(	5	,:,:),[anostotais,5]));
	MSF 	= cat(2,arrayanos,reshape(tabelona(	6	,:,:),[anostotais,5]));
	MF  	= cat(2,arrayanos,reshape(tabelona(	7	,:,:),[anostotais,5]));
	ALP1	= cat(2,arrayanos,reshape(tabelona(	8	,:,:),[anostotais,5]));
	twoQ1 	= cat(2,arrayanos,reshape(tabelona(	9	,:,:),[anostotais,5]));
	SIG1	= cat(2,arrayanos,reshape(tabelona(	10	,:,:),[anostotais,5]));
	Q1  	= cat(2,arrayanos,reshape(tabelona(	11	,:,:),[anostotais,5]));
	RHO1	= cat(2,arrayanos,reshape(tabelona(	12	,:,:),[anostotais,5]));
	O1  	= cat(2,arrayanos,reshape(tabelona(	13	,:,:),[anostotais,5]));
	TAU1	= cat(2,arrayanos,reshape(tabelona(	14	,:,:),[anostotais,5]));
	BET1	= cat(2,arrayanos,reshape(tabelona(	15	,:,:),[anostotais,5]));
	NO1 	= cat(2,arrayanos,reshape(tabelona(	16	,:,:),[anostotais,5]));
	CHI1	= cat(2,arrayanos,reshape(tabelona(	17	,:,:),[anostotais,5]));
	PI1 	= cat(2,arrayanos,reshape(tabelona(	18	,:,:),[anostotais,5]));
	P1  	= cat(2,arrayanos,reshape(tabelona(	19	,:,:),[anostotais,5]));
	S1  	= cat(2,arrayanos,reshape(tabelona(	20	,:,:),[anostotais,5]));
	K1  	= cat(2,arrayanos,reshape(tabelona(	21	,:,:),[anostotais,5]));
	PSI1	= cat(2,arrayanos,reshape(tabelona(	22	,:,:),[anostotais,5]));
	PHI1	= cat(2,arrayanos,reshape(tabelona(	23	,:,:),[anostotais,5]));
	THE1	= cat(2,arrayanos,reshape(tabelona(	24	,:,:),[anostotais,5]));
	J1  	= cat(2,arrayanos,reshape(tabelona(	25	,:,:),[anostotais,5]));
	twoPO1	= cat(2,arrayanos,reshape(tabelona(	26	,:,:),[anostotais,5]));
	SO1 	= cat(2,arrayanos,reshape(tabelona(	27	,:,:),[anostotais,5]));
	OO1 	= cat(2,arrayanos,reshape(tabelona(	28	,:,:),[anostotais,5]));
	UPS1	= cat(2,arrayanos,reshape(tabelona(	29	,:,:),[anostotais,5]));
	ST36	= cat(2,arrayanos,reshape(tabelona(	30	,:,:),[anostotais,5]));
	twoNS2	= cat(2,arrayanos,reshape(tabelona(	31	,:,:),[anostotais,5]));
	ST37	= cat(2,arrayanos,reshape(tabelona(	32	,:,:),[anostotais,5]));
	ST1 	= cat(2,arrayanos,reshape(tabelona(	33	,:,:),[anostotais,5]));
	OQ2 	= cat(2,arrayanos,reshape(tabelona(	34	,:,:),[anostotais,5]));
	EPS2	= cat(2,arrayanos,reshape(tabelona(	35	,:,:),[anostotais,5]));
	ST2 	= cat(2,arrayanos,reshape(tabelona(	36	,:,:),[anostotais,5]));
	ST3 	= cat(2,arrayanos,reshape(tabelona(	37	,:,:),[anostotais,5]));
	O2  	= cat(2,arrayanos,reshape(tabelona(	38	,:,:),[anostotais,5]));
	twoN2 	= cat(2,arrayanos,reshape(tabelona(	39	,:,:),[anostotais,5]));
	MU2 	= cat(2,arrayanos,reshape(tabelona(	40	,:,:),[anostotais,5]));
	SNK2	= cat(2,arrayanos,reshape(tabelona(	41	,:,:),[anostotais,5]));
	N2  	= cat(2,arrayanos,reshape(tabelona(	42	,:,:),[anostotais,5]));
	NU2 	= cat(2,arrayanos,reshape(tabelona(	43	,:,:),[anostotais,5]));
	ST4 	= cat(2,arrayanos,reshape(tabelona(	44	,:,:),[anostotais,5]));
	OP2 	= cat(2,arrayanos,reshape(tabelona(	45	,:,:),[anostotais,5]));
	GAM2	= cat(2,arrayanos,reshape(tabelona(	46	,:,:),[anostotais,5]));
	H1  	= cat(2,arrayanos,reshape(tabelona(	47	,:,:),[anostotais,5]));
	M2 		= cat(2,arrayanos,reshape(tabelona(	48	,:,:),[anostotais,5]));
	H2  	= cat(2,arrayanos,reshape(tabelona(	49	,:,:),[anostotais,5]));
	MKS2	= cat(2,arrayanos,reshape(tabelona(	50	,:,:),[anostotais,5]));
	ST5 	= cat(2,arrayanos,reshape(tabelona(	51	,:,:),[anostotais,5]));
	ST6 	= cat(2,arrayanos,reshape(tabelona(	52	,:,:),[anostotais,5]));
	LDA2	= cat(2,arrayanos,reshape(tabelona(	53	,:,:),[anostotais,5]));
	L2  	= cat(2,arrayanos,reshape(tabelona(	54	,:,:),[anostotais,5]));
	twoSK2	= cat(2,arrayanos,reshape(tabelona(	55	,:,:),[anostotais,5]));
	T2  	= cat(2,arrayanos,reshape(tabelona(	56	,:,:),[anostotais,5]));
	S2  	= cat(2,arrayanos,reshape(tabelona(	57	,:,:),[anostotais,5]));
	R2  	= cat(2,arrayanos,reshape(tabelona(	58	,:,:),[anostotais,5]));
	K2  	= cat(2,arrayanos,reshape(tabelona(	59	,:,:),[anostotais,5]));
	MSN2	= cat(2,arrayanos,reshape(tabelona(	60	,:,:),[anostotais,5]));
	ETA2	= cat(2,arrayanos,reshape(tabelona(	61	,:,:),[anostotais,5]));
	ST7 	= cat(2,arrayanos,reshape(tabelona(	62	,:,:),[anostotais,5]));
	twoSM2	= cat(2,arrayanos,reshape(tabelona(	63	,:,:),[anostotais,5]));
	ST38	= cat(2,arrayanos,reshape(tabelona(	64	,:,:),[anostotais,5]));
	SKM2	= cat(2,arrayanos,reshape(tabelona(	65	,:,:),[anostotais,5]));
	twoSN2	= cat(2,arrayanos,reshape(tabelona(	66	,:,:),[anostotais,5]));
	NO3 	= cat(2,arrayanos,reshape(tabelona(	67	,:,:),[anostotais,5]));
	MO3 	= cat(2,arrayanos,reshape(tabelona(	68	,:,:),[anostotais,5]));
	M3  	= cat(2,arrayanos,reshape(tabelona(	69	,:,:),[anostotais,5]));
	NK3 	= cat(2,arrayanos,reshape(tabelona(	70	,:,:),[anostotais,5]));
	SO3 	= cat(2,arrayanos,reshape(tabelona(	71	,:,:),[anostotais,5]));
	MK3 	= cat(2,arrayanos,reshape(tabelona(	72	,:,:),[anostotais,5]));
	SP3 	= cat(2,arrayanos,reshape(tabelona(	73	,:,:),[anostotais,5]));
	SK3 	= cat(2,arrayanos,reshape(tabelona(	74	,:,:),[anostotais,5]));
	ST8 	= cat(2,arrayanos,reshape(tabelona(	75	,:,:),[anostotais,5]));
	N4  	= cat(2,arrayanos,reshape(tabelona(	76	,:,:),[anostotais,5]));
	threeMS4	= cat(2,arrayanos,reshape(tabelona(	77	,:,:),[anostotais,5]));
	ST39	= cat(2,arrayanos,reshape(tabelona(	78	,:,:),[anostotais,5]));
	MN4 	= cat(2,arrayanos,reshape(tabelona(	79	,:,:),[anostotais,5]));
	ST9 	= cat(2,arrayanos,reshape(tabelona(	80	,:,:),[anostotais,5]));
	ST40	= cat(2,arrayanos,reshape(tabelona(	81	,:,:),[anostotais,5]));
	M4  	= cat(2,arrayanos,reshape(tabelona(	82	,:,:),[anostotais,5]));
	ST10	= cat(2,arrayanos,reshape(tabelona(	83	,:,:),[anostotais,5]));
	SN4 	= cat(2,arrayanos,reshape(tabelona(	84	,:,:),[anostotais,5]));
	KN4 	= cat(2,arrayanos,reshape(tabelona(	85	,:,:),[anostotais,5]));
	MS4 	= cat(2,arrayanos,reshape(tabelona(	86	,:,:),[anostotais,5]));
	MK4 	= cat(2,arrayanos,reshape(tabelona(	87	,:,:),[anostotais,5]));
	SL4 	= cat(2,arrayanos,reshape(tabelona(	88	,:,:),[anostotais,5]));
	S4  	= cat(2,arrayanos,reshape(tabelona(	89	,:,:),[anostotais,5]));
	SK4 	= cat(2,arrayanos,reshape(tabelona(	90	,:,:),[anostotais,5]));
	MNO5	= cat(2,arrayanos,reshape(tabelona(	91	,:,:),[anostotais,5]));
	twoMO5	= cat(2,arrayanos,reshape(tabelona(	92	,:,:),[anostotais,5]));
	threeMP5	= cat(2,arrayanos,reshape(tabelona(	93	,:,:),[anostotais,5]));
	MNK5	= cat(2,arrayanos,reshape(tabelona(	94	,:,:),[anostotais,5]));
	twoMP5	= cat(2,arrayanos,reshape(tabelona(	95	,:,:),[anostotais,5]));
	twoMK5	= cat(2,arrayanos,reshape(tabelona(	96	,:,:),[anostotais,5]));
	MSK5	= cat(2,arrayanos,reshape(tabelona(	97	,:,:),[anostotais,5]));
	threeKM5	= cat(2,arrayanos,reshape(tabelona(	98	,:,:),[anostotais,5]));
	twoSK5	= cat(2,arrayanos,reshape(tabelona(	99	,:,:),[anostotais,5]));
	ST11	= cat(2,arrayanos,reshape(tabelona(	100	,:,:),[anostotais,5]));
	twoNM6	= cat(2,arrayanos,reshape(tabelona(	101	,:,:),[anostotais,5]));
	ST12	= cat(2,arrayanos,reshape(tabelona(	102	,:,:),[anostotais,5]));
	twoMN6	= cat(2,arrayanos,reshape(tabelona(	103	,:,:),[anostotais,5]));
	ST13	= cat(2,arrayanos,reshape(tabelona(	104	,:,:),[anostotais,5]));
	ST41	= cat(2,arrayanos,reshape(tabelona(	105	,:,:),[anostotais,5]));
	M6  	= cat(2,arrayanos,reshape(tabelona(	106	,:,:),[anostotais,5]));
	MSN6	= cat(2,arrayanos,reshape(tabelona(	107	,:,:),[anostotais,5]));
	MKN6	= cat(2,arrayanos,reshape(tabelona(	108	,:,:),[anostotais,5]));
	ST42	= cat(2,arrayanos,reshape(tabelona(	109	,:,:),[anostotais,5]));
	twoMS6	= cat(2,arrayanos,reshape(tabelona(	110	,:,:),[anostotais,5]));
	twoMK6	= cat(2,arrayanos,reshape(tabelona(	111	,:,:),[anostotais,5]));
	NSK6	= cat(2,arrayanos,reshape(tabelona(	112	,:,:),[anostotais,5]));
	twoSM6	= cat(2,arrayanos,reshape(tabelona(	113	,:,:),[anostotais,5]));
	MSK6	= cat(2,arrayanos,reshape(tabelona(	114	,:,:),[anostotais,5]));
	S6  	= cat(2,arrayanos,reshape(tabelona(	115	,:,:),[anostotais,5]));
	ST14	= cat(2,arrayanos,reshape(tabelona(	116	,:,:),[anostotais,5]));
	ST15	= cat(2,arrayanos,reshape(tabelona(	117	,:,:),[anostotais,5]));
	M7  	= cat(2,arrayanos,reshape(tabelona(	118	,:,:),[anostotais,5]));
	ST16	= cat(2,arrayanos,reshape(tabelona(	119	,:,:),[anostotais,5]));
	threeMK7	= cat(2,arrayanos,reshape(tabelona(	120	,:,:),[anostotais,5]));
	ST17	= cat(2,arrayanos,reshape(tabelona(	121	,:,:),[anostotais,5]));
	ST18	= cat(2,arrayanos,reshape(tabelona(	122	,:,:),[anostotais,5]));
	threeMN8	= cat(2,arrayanos,reshape(tabelona(	123	,:,:),[anostotais,5]));
	ST19	= cat(2,arrayanos,reshape(tabelona(	124	,:,:),[anostotais,5]));
	M8  	= cat(2,arrayanos,reshape(tabelona(	125	,:,:),[anostotais,5]));
	ST20	= cat(2,arrayanos,reshape(tabelona(	126	,:,:),[anostotais,5]));
	ST21	= cat(2,arrayanos,reshape(tabelona(	127	,:,:),[anostotais,5]));
	threeMS8	= cat(2,arrayanos,reshape(tabelona(	128	,:,:),[anostotais,5]));
	threeMK8	= cat(2,arrayanos,reshape(tabelona(	129	,:,:),[anostotais,5]));
	ST22	= cat(2,arrayanos,reshape(tabelona(	130	,:,:),[anostotais,5]));
	ST23	= cat(2,arrayanos,reshape(tabelona(	131	,:,:),[anostotais,5]));
	ST24	= cat(2,arrayanos,reshape(tabelona(	132	,:,:),[anostotais,5]));
	ST25	= cat(2,arrayanos,reshape(tabelona(	133	,:,:),[anostotais,5]));
	ST26	= cat(2,arrayanos,reshape(tabelona(	134	,:,:),[anostotais,5]));
	fourMK9	= cat(2,arrayanos,reshape(tabelona(	135	,:,:),[anostotais,5]));
	ST27	= cat(2,arrayanos,reshape(tabelona(	136	,:,:),[anostotais,5]));
	ST28	= cat(2,arrayanos,reshape(tabelona(	137	,:,:),[anostotais,5]));
	M10 	= cat(2,arrayanos,reshape(tabelona(	138	,:,:),[anostotais,5]));
	ST29	= cat(2,arrayanos,reshape(tabelona(	139	,:,:),[anostotais,5]));
	ST30	= cat(2,arrayanos,reshape(tabelona(	140	,:,:),[anostotais,5]));
	ST31	= cat(2,arrayanos,reshape(tabelona(	141	,:,:),[anostotais,5]));
	ST32	= cat(2,arrayanos,reshape(tabelona(	142	,:,:),[anostotais,5]));
	ST33	= cat(2,arrayanos,reshape(tabelona(	143	,:,:),[anostotais,5]));
	M12 	= cat(2,arrayanos,reshape(tabelona(	144	,:,:),[anostotais,5]));
	ST34	= cat(2,arrayanos,reshape(tabelona(	145	,:,:),[anostotais,5]));
	ST35	= cat(2,arrayanos,reshape(tabelona(	146	,:,:),[anostotais,5]));
	
	
	Z0  	=	 cat(1,compheader,	Z0  	);
	SA  	=	 cat(1,compheader,	SA  	);
	
	SSA 	=	 cat(1,compheader,	SSA 	);
	MSM 	=	 cat(1,compheader,	MSM 	);
	MM  	=	 cat(1,compheader,	MM  	);
	MSF 	=	 cat(1,compheader,	MSF 	);
	MF  	=	 cat(1,compheader,	MF  	);
	ALP1	=	 cat(1,compheader,	ALP1	);
	twoQ1 	=	 cat(1,compheader,	twoQ1 	);
	SIG1	=	 cat(1,compheader,	SIG1	);
	Q1  	=	 cat(1,compheader,	Q1  	);
	RHO1	=	 cat(1,compheader,	RHO1	);
	O1  	=	 cat(1,compheader,	O1  	);
	TAU1	=	 cat(1,compheader,	TAU1	);
	BET1	=	 cat(1,compheader,	BET1	);
	NO1 	=	 cat(1,compheader,	NO1 	);
	CHI1	=	 cat(1,compheader,	CHI1	);
	PI1 	=	 cat(1,compheader,	PI1 	);
	P1  	=	 cat(1,compheader,	P1  	);
	S1  	=	 cat(1,compheader,	S1  	);
	K1  	=	 cat(1,compheader,	K1  	);
	PSI1	=	 cat(1,compheader,	PSI1	);
	PHI1	=	 cat(1,compheader,	PHI1	);
	THE1	=	 cat(1,compheader,	THE1	);
	J1  	=	 cat(1,compheader,	J1  	);
	twoPO1	=	 cat(1,compheader,	twoPO1	);
	SO1 	=	 cat(1,compheader,	SO1 	);
	OO1 	=	 cat(1,compheader,	OO1 	);
	UPS1	=	 cat(1,compheader,	UPS1	);
	ST36	=	 cat(1,compheader,	ST36	);
	twoNS2	=	 cat(1,compheader,	twoNS2	);
	ST37	=	 cat(1,compheader,	ST37	);
	ST1 	=	 cat(1,compheader,	ST1 	);
	OQ2 	=	 cat(1,compheader,	OQ2 	);
	EPS2	=	 cat(1,compheader,	EPS2	);
	ST2 	=	 cat(1,compheader,	ST2 	);
	ST3 	=	 cat(1,compheader,	ST3 	);
	O2  	=	 cat(1,compheader,	O2  	);
	twoN2 	=	 cat(1,compheader,	twoN2 	);
	MU2 	=	 cat(1,compheader,	MU2 	);
	SNK2	=	 cat(1,compheader,	SNK2	);
	N2  	=	 cat(1,compheader,	N2  	);
	NU2 	=	 cat(1,compheader,	NU2 	);
	ST4 	=	 cat(1,compheader,	ST4 	);
	OP2 	=	 cat(1,compheader,	OP2 	);
	GAM2	=	 cat(1,compheader,	GAM2	);
	H1  	=	 cat(1,compheader,	H1  	);
	M2 	=	 cat(1,compheader,	M2 	);
	H2  	=	 cat(1,compheader,	H2  	);
	MKS2	=	 cat(1,compheader,	MKS2	);
	ST5 	=	 cat(1,compheader,	ST5 	);
	ST6 	=	 cat(1,compheader,	ST6 	);
	LDA2	=	 cat(1,compheader,	LDA2	);
	L2  	=	 cat(1,compheader,	L2  	);
	twoSK2	=	 cat(1,compheader,	twoSK2	);
	T2  	=	 cat(1,compheader,	T2  	);
	S2  	=	 cat(1,compheader,	S2  	);
	R2  	=	 cat(1,compheader,	R2  	);
	K2  	=	 cat(1,compheader,	K2  	);
	MSN2	=	 cat(1,compheader,	MSN2	);
	ETA2	=	 cat(1,compheader,	ETA2	);
	ST7 	=	 cat(1,compheader,	ST7 	);
	twoSM2	=	 cat(1,compheader,	twoSM2	);
	ST38	=	 cat(1,compheader,	ST38	);
	SKM2	=	 cat(1,compheader,	SKM2	);
	twoSN2	=	 cat(1,compheader,	twoSN2	);
	NO3 	=	 cat(1,compheader,	NO3 	);
	MO3 	=	 cat(1,compheader,	MO3 	);
	M3  	=	 cat(1,compheader,	M3  	);
	NK3 	=	 cat(1,compheader,	NK3 	);
	SO3 	=	 cat(1,compheader,	SO3 	);
	MK3 	=	 cat(1,compheader,	MK3 	);
	SP3 	=	 cat(1,compheader,	SP3 	);
	SK3 	=	 cat(1,compheader,	SK3 	);
	ST8 	=	 cat(1,compheader,	ST8 	);
	N4  	=	 cat(1,compheader,	N4  	);
	threeMS4	=	 cat(1,compheader,	threeMS4	);
	ST39	=	 cat(1,compheader,	ST39	);
	MN4 	=	 cat(1,compheader,	MN4 	);
	ST9 	=	 cat(1,compheader,	ST9 	);
	ST40	=	 cat(1,compheader,	ST40	);
	M4  	=	 cat(1,compheader,	M4  	);
	ST10	=	 cat(1,compheader,	ST10	);
	SN4 	=	 cat(1,compheader,	SN4 	);
	KN4 	=	 cat(1,compheader,	KN4 	);
	MS4 	=	 cat(1,compheader,	MS4 	);
	MK4 	=	 cat(1,compheader,	MK4 	);
	SL4 	=	 cat(1,compheader,	SL4 	);
	S4  	=	 cat(1,compheader,	S4  	);
	SK4 	=	 cat(1,compheader,	SK4 	);
	MNO5	=	 cat(1,compheader,	MNO5	);
	twoMO5	=	 cat(1,compheader,	twoMO5	);
	threeMP5	=	 cat(1,compheader,	threeMP5	);
	MNK5	=	 cat(1,compheader,	MNK5	);
	twoMP5	=	 cat(1,compheader,	twoMP5	);
	twoMK5	=	 cat(1,compheader,	twoMK5	);
	MSK5	=	 cat(1,compheader,	MSK5	);
	threeKM5	=	 cat(1,compheader,	threeKM5	);
	twoSK5	=	 cat(1,compheader,	twoSK5	);
	ST11	=	 cat(1,compheader,	ST11	);
	twoNM6	=	 cat(1,compheader,	twoNM6	);
	ST12	=	 cat(1,compheader,	ST12	);
	twoMN6	=	 cat(1,compheader,	twoMN6	);
	ST13	=	 cat(1,compheader,	ST13	);
	ST41	=	 cat(1,compheader,	ST41	);
	M6  	=	 cat(1,compheader,	M6  	);
	MSN6	=	 cat(1,compheader,	MSN6	);
	MKN6	=	 cat(1,compheader,	MKN6	);
	ST42	=	 cat(1,compheader,	ST42	);
	twoMS6	=	 cat(1,compheader,	twoMS6	);
	twoMK6	=	 cat(1,compheader,	twoMK6	);
	NSK6	=	 cat(1,compheader,	NSK6	);
	twoSM6	=	 cat(1,compheader,	twoSM6	);
	MSK6	=	 cat(1,compheader,	MSK6	);
	S6  	=	 cat(1,compheader,	S6  	);
	ST14	=	 cat(1,compheader,	ST14	);
	ST15	=	 cat(1,compheader,	ST15	);
	M7  	=	 cat(1,compheader,	M7  	);
	ST16	=	 cat(1,compheader,	ST16	);
	threeMK7	=	 cat(1,compheader,	threeMK7	);
	ST17	=	 cat(1,compheader,	ST17	);
	ST18	=	 cat(1,compheader,	ST18	);
	threeMN8	=	 cat(1,compheader,	threeMN8	);
	ST19	=	 cat(1,compheader,	ST19	);
	M8  	=	 cat(1,compheader,	M8  	);
	ST20	=	 cat(1,compheader,	ST20	);
	ST21	=	 cat(1,compheader,	ST21	);
	threeMS8	=	 cat(1,compheader,	threeMS8	);
	threeMK8	=	 cat(1,compheader,	threeMK8	);
	ST22	=	 cat(1,compheader,	ST22	);
	ST23	=	 cat(1,compheader,	ST23	);
	ST24	=	 cat(1,compheader,	ST24	);
	ST25	=	 cat(1,compheader,	ST25	);
	ST26	=	 cat(1,compheader,	ST26	);
	fourMK9	=	 cat(1,compheader,	fourMK9	);
	ST27	=	 cat(1,compheader,	ST27	);
	ST28	=	 cat(1,compheader,	ST28	);
	M10 	=	 cat(1,compheader,	M10 	);
	ST29	=	 cat(1,compheader,	ST29	);
	ST30	=	 cat(1,compheader,	ST30	);
	ST31	=	 cat(1,compheader,	ST31	);
	ST32	=	 cat(1,compheader,	ST32	);
	ST33	=	 cat(1,compheader,	ST33	);
	M12 	=	 cat(1,compheader,	M12 	);
	ST34	=	 cat(1,compheader,	ST34	);
	ST35	=	 cat(1,compheader,	ST35	);
	
	
	
	
	writecell(	Z0  	,'Componentes individuais.xlsx','Sheet','	Z0  	');
	writecell(	SA  	,'Componentes individuais.xlsx','Sheet','	SA  	');
	writecell(	SSA 	,'Componentes individuais.xlsx','Sheet','	SSA 	');
	writecell(	MSM 	,'Componentes individuais.xlsx','Sheet','	MSM 	');
	writecell(	MM  	,'Componentes individuais.xlsx','Sheet','	MM  	');
	writecell(	MSF 	,'Componentes individuais.xlsx','Sheet','	MSF 	');
	writecell(	MF  	,'Componentes individuais.xlsx','Sheet','	MF  	');
	writecell(	ALP1	,'Componentes individuais.xlsx','Sheet','	ALP1	');
	writecell(	twoQ1 	,'Componentes individuais.xlsx','Sheet','	2Q1 	');
	writecell(	SIG1	,'Componentes individuais.xlsx','Sheet','	SIG1	');
	writecell(	Q1  	,'Componentes individuais.xlsx','Sheet','	Q1  	');
	writecell(	RHO1	,'Componentes individuais.xlsx','Sheet','	RHO1	');
	writecell(	O1  	,'Componentes individuais.xlsx','Sheet','	O1  	');
	writecell(	TAU1	,'Componentes individuais.xlsx','Sheet','	TAU1	');
	writecell(	BET1	,'Componentes individuais.xlsx','Sheet','	BET1	');
	writecell(	NO1 	,'Componentes individuais.xlsx','Sheet','	NO1 	');
	writecell(	CHI1	,'Componentes individuais.xlsx','Sheet','	CHI1	');
	writecell(	PI1 	,'Componentes individuais.xlsx','Sheet','	PI1 	');
	writecell(	P1  	,'Componentes individuais.xlsx','Sheet','	P1  	');
	writecell(	S1  	,'Componentes individuais.xlsx','Sheet','	S1  	');
	writecell(	K1  	,'Componentes individuais.xlsx','Sheet','	K1  	');
	writecell(	PSI1	,'Componentes individuais.xlsx','Sheet','	PSI1	');
	writecell(	PHI1	,'Componentes individuais.xlsx','Sheet','	PHI1	');
	writecell(	THE1	,'Componentes individuais.xlsx','Sheet','	THE1	');
	writecell(	J1  	,'Componentes individuais.xlsx','Sheet','	J1  	');
	writecell(	twoPO1	,'Componentes individuais.xlsx','Sheet','	2PO1	');
	writecell(	SO1 	,'Componentes individuais.xlsx','Sheet','	SO1 	');
	writecell(	OO1 	,'Componentes individuais.xlsx','Sheet','	OO1 	');
	writecell(	UPS1	,'Componentes individuais.xlsx','Sheet','	UPS1	');
	writecell(	ST36	,'Componentes individuais.xlsx','Sheet','	ST36	');
	writecell(	twoNS2	,'Componentes individuais.xlsx','Sheet','	2NS2	');
	writecell(	ST37	,'Componentes individuais.xlsx','Sheet','	ST37	');
	writecell(	ST1 	,'Componentes individuais.xlsx','Sheet','	ST1 	');
	writecell(	OQ2 	,'Componentes individuais.xlsx','Sheet','	OQ2 	');
	writecell(	EPS2	,'Componentes individuais.xlsx','Sheet','	EPS2	');
	writecell(	ST2 	,'Componentes individuais.xlsx','Sheet','	ST2 	');
	writecell(	ST3 	,'Componentes individuais.xlsx','Sheet','	ST3 	');
	writecell(	O2  	,'Componentes individuais.xlsx','Sheet','	O2  	');
	writecell(	twoN2 	,'Componentes individuais.xlsx','Sheet','	2N2 	');
	writecell(	MU2 	,'Componentes individuais.xlsx','Sheet','	MU2 	');
	writecell(	SNK2	,'Componentes individuais.xlsx','Sheet','	SNK2	');
	writecell(	N2  	,'Componentes individuais.xlsx','Sheet','	N2  	');
	writecell(	NU2 	,'Componentes individuais.xlsx','Sheet','	NU2 	');
	writecell(	ST4 	,'Componentes individuais.xlsx','Sheet','	ST4 	');
	writecell(	OP2 	,'Componentes individuais.xlsx','Sheet','	OP2 	');
	writecell(	GAM2	,'Componentes individuais.xlsx','Sheet','	GAM2	');
	writecell(	H1  	,'Componentes individuais.xlsx','Sheet','	H1  	');
	writecell(	M2  	,'Componentes individuais.xlsx','Sheet','	M2		');
	writecell(	H2  	,'Componentes individuais.xlsx','Sheet','	H2  	');
	writecell(	MKS2	,'Componentes individuais.xlsx','Sheet','	MKS2	');
	writecell(	ST5 	,'Componentes individuais.xlsx','Sheet','	ST5 	');
	writecell(	ST6 	,'Componentes individuais.xlsx','Sheet','	ST6 	');
	writecell(	LDA2	,'Componentes individuais.xlsx','Sheet','	LDA2	');
	writecell(	L2  	,'Componentes individuais.xlsx','Sheet','	L2  	');
	writecell(	twoSK2	,'Componentes individuais.xlsx','Sheet','	2SK2	');
	writecell(	T2  	,'Componentes individuais.xlsx','Sheet','	T2  	');
	writecell(	S2  	,'Componentes individuais.xlsx','Sheet','	S2  	');
	writecell(	R2  	,'Componentes individuais.xlsx','Sheet','	R2  	');
	writecell(	K2  	,'Componentes individuais.xlsx','Sheet','	K2  	');
	writecell(	MSN2	,'Componentes individuais.xlsx','Sheet','	MSN2	');
	writecell(	ETA2	,'Componentes individuais.xlsx','Sheet','	ETA2	');
	writecell(	ST7 	,'Componentes individuais.xlsx','Sheet','	ST7 	');
	writecell(	twoSM2	,'Componentes individuais.xlsx','Sheet','	2SM2	');
	writecell(	ST38	,'Componentes individuais.xlsx','Sheet','	ST38	');
	writecell(	SKM2	,'Componentes individuais.xlsx','Sheet','	SKM2	');
	writecell(	twoSN2	,'Componentes individuais.xlsx','Sheet','	2SN2	');
	writecell(	NO3 	,'Componentes individuais.xlsx','Sheet','	NO3 	');
	writecell(	MO3 	,'Componentes individuais.xlsx','Sheet','	MO3 	');
	writecell(	M3  	,'Componentes individuais.xlsx','Sheet','	M3  	');
	writecell(	NK3 	,'Componentes individuais.xlsx','Sheet','	NK3 	');
	writecell(	SO3 	,'Componentes individuais.xlsx','Sheet','	SO3 	');
	writecell(	MK3 	,'Componentes individuais.xlsx','Sheet','	MK3 	');
	writecell(	SP3 	,'Componentes individuais.xlsx','Sheet','	SP3 	');
	writecell(	SK3 	,'Componentes individuais.xlsx','Sheet','	SK3 	');
	writecell(	ST8 	,'Componentes individuais.xlsx','Sheet','	ST8 	');
	writecell(	N4  	,'Componentes individuais.xlsx','Sheet','	N4  	');
	writecell(	threeMS4	,'Componentes individuais.xlsx','Sheet','	3MS4	');
	writecell(	ST39	,'Componentes individuais.xlsx','Sheet','	ST39	');
	writecell(	MN4 	,'Componentes individuais.xlsx','Sheet','	MN4 	');
	writecell(	ST9 	,'Componentes individuais.xlsx','Sheet','	ST9 	');
	writecell(	ST40	,'Componentes individuais.xlsx','Sheet','	ST40	');
	writecell(	M4  	,'Componentes individuais.xlsx','Sheet','	M4  	');
	writecell(	ST10	,'Componentes individuais.xlsx','Sheet','	ST10	');
	writecell(	SN4 	,'Componentes individuais.xlsx','Sheet','	SN4 	');
	writecell(	KN4 	,'Componentes individuais.xlsx','Sheet','	KN4 	');
	writecell(	MS4 	,'Componentes individuais.xlsx','Sheet','	MS4 	');
	writecell(	MK4 	,'Componentes individuais.xlsx','Sheet','	MK4 	');
	writecell(	SL4 	,'Componentes individuais.xlsx','Sheet','	SL4 	');
	writecell(	S4  	,'Componentes individuais.xlsx','Sheet','	S4  	');
	writecell(	SK4 	,'Componentes individuais.xlsx','Sheet','	SK4 	');
	writecell(	MNO5	,'Componentes individuais.xlsx','Sheet','	MNO5	');
	writecell(	twoMO5	,'Componentes individuais.xlsx','Sheet','	2MO5	');
	writecell(	threeMP5	,'Componentes individuais.xlsx','Sheet','	3MP5	');
	writecell(	MNK5	,'Componentes individuais.xlsx','Sheet','	MNK5	');
	writecell(	twoMP5	,'Componentes individuais.xlsx','Sheet','	2MP5	');
	writecell(	twoMK5	,'Componentes individuais.xlsx','Sheet','	2MK5	');
	writecell(	MSK5	,'Componentes individuais.xlsx','Sheet','	MSK5	');
	writecell(	threeKM5	,'Componentes individuais.xlsx','Sheet','	3KM5	');
	writecell(	twoSK5	,'Componentes individuais.xlsx','Sheet','	2SK5	');
	writecell(	ST11	,'Componentes individuais.xlsx','Sheet','	ST11	');
	writecell(	twoNM6	,'Componentes individuais.xlsx','Sheet','	2NM6	');
	writecell(	ST12	,'Componentes individuais.xlsx','Sheet','	ST12	');
	writecell(	twoMN6	,'Componentes individuais.xlsx','Sheet','	2MN6	');
	writecell(	ST13	,'Componentes individuais.xlsx','Sheet','	ST13	');
	writecell(	ST41	,'Componentes individuais.xlsx','Sheet','	ST41	');
	writecell(	M6  	,'Componentes individuais.xlsx','Sheet','	M6  	');
	writecell(	MSN6	,'Componentes individuais.xlsx','Sheet','	MSN6	');
	writecell(	MKN6	,'Componentes individuais.xlsx','Sheet','	MKN6	');
	writecell(	ST42	,'Componentes individuais.xlsx','Sheet','	ST42	');
	writecell(	twoMS6	,'Componentes individuais.xlsx','Sheet','	2MS6	');
	writecell(	twoMK6	,'Componentes individuais.xlsx','Sheet','	2MK6	');
	writecell(	NSK6	,'Componentes individuais.xlsx','Sheet','	NSK6	');
	writecell(	twoSM6	,'Componentes individuais.xlsx','Sheet','	2SM6	');
	writecell(	MSK6	,'Componentes individuais.xlsx','Sheet','	MSK6	');
	writecell(	S6  	,'Componentes individuais.xlsx','Sheet','	S6  	');
	writecell(	ST14	,'Componentes individuais.xlsx','Sheet','	ST14	');
	writecell(	ST15	,'Componentes individuais.xlsx','Sheet','	ST15	');
	writecell(	M7  	,'Componentes individuais.xlsx','Sheet','	M7  	');
	writecell(	ST16	,'Componentes individuais.xlsx','Sheet','	ST16	');
	writecell(	threeMK7	,'Componentes individuais.xlsx','Sheet','	3MK7	');
	writecell(	ST17	,'Componentes individuais.xlsx','Sheet','	ST17	');
	writecell(	ST18	,'Componentes individuais.xlsx','Sheet','	ST18	');
	writecell(	threeMN8	,'Componentes individuais.xlsx','Sheet','	3MN8	');
	writecell(	ST19	,'Componentes individuais.xlsx','Sheet','	ST19	');
	writecell(	M8  	,'Componentes individuais.xlsx','Sheet','	M8  	');
	writecell(	ST20	,'Componentes individuais.xlsx','Sheet','	ST20	');
	writecell(	ST21	,'Componentes individuais.xlsx','Sheet','	ST21	');
	writecell(	threeMS8	,'Componentes individuais.xlsx','Sheet','	3MS8	');
	writecell(	threeMK8	,'Componentes individuais.xlsx','Sheet','	3MK8	');
	writecell(	ST22	,'Componentes individuais.xlsx','Sheet','	ST22	');
	writecell(	ST23	,'Componentes individuais.xlsx','Sheet','	ST23	');
	writecell(	ST24	,'Componentes individuais.xlsx','Sheet','	ST24	');
	writecell(	ST25	,'Componentes individuais.xlsx','Sheet','	ST25	');
	writecell(	ST26	,'Componentes individuais.xlsx','Sheet','	ST26	');
	writecell(	fourMK9	,'Componentes individuais.xlsx','Sheet','	4MK9	');
	writecell(	ST27	,'Componentes individuais.xlsx','Sheet','	ST27	');
	writecell(	ST28	,'Componentes individuais.xlsx','Sheet','	ST28	');
	writecell(	M10 	,'Componentes individuais.xlsx','Sheet','	M10 	');
	writecell(	ST29	,'Componentes individuais.xlsx','Sheet','	ST29	');
	writecell(	ST30	,'Componentes individuais.xlsx','Sheet','	ST30	');
	writecell(	ST31	,'Componentes individuais.xlsx','Sheet','	ST31	');
	writecell(	ST32	,'Componentes individuais.xlsx','Sheet','	ST32	');
	writecell(	ST33	,'Componentes individuais.xlsx','Sheet','	ST33	');
	writecell(	M12 	,'Componentes individuais.xlsx','Sheet','	M12 	');
	writecell(	ST34	,'Componentes individuais.xlsx','Sheet','	ST34	');
	writecell(	ST35	,'Componentes individuais.xlsx','Sheet','	ST35	');
	
	
	
	
end












	
 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%% Módulo ABAS - cada componente (ANUAIS)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lim_exc_ind19 (tablonga)	       
	compheader = ["YEAR","FREQ.","AMPLITUDE","AMP_ERR","PHASE","PHASE_ERR"];
	
	
	
	Z0  	= cat(2,arraylonganos,reshape(tablonga(	1	,:,:),[anoslong,5]));
	SA  	= cat(2,arraylonganos,reshape(tablonga(	2	,:,:),[anoslong,5]));
	SSA 	= cat(2,arraylonganos,reshape(tablonga(	3	,:,:),[anoslong,5]));
	MSM 	= cat(2,arraylonganos,reshape(tablonga(	4	,:,:),[anoslong,5]));
	MM  	= cat(2,arraylonganos,reshape(tablonga(	5	,:,:),[anoslong,5]));
	MSF 	= cat(2,arraylonganos,reshape(tablonga(	6	,:,:),[anoslong,5]));
	MF  	= cat(2,arraylonganos,reshape(tablonga(	7	,:,:),[anoslong,5]));
	ALP1	= cat(2,arraylonganos,reshape(tablonga(	8	,:,:),[anoslong,5]));
	twoQ1 	= cat(2,arraylonganos,reshape(tablonga(	9	,:,:),[anoslong,5]));
	SIG1	= cat(2,arraylonganos,reshape(tablonga(	10	,:,:),[anoslong,5]));
	Q1  	= cat(2,arraylonganos,reshape(tablonga(	11	,:,:),[anoslong,5]));
	RHO1	= cat(2,arraylonganos,reshape(tablonga(	12	,:,:),[anoslong,5]));
	O1  	= cat(2,arraylonganos,reshape(tablonga(	13	,:,:),[anoslong,5]));
	TAU1	= cat(2,arraylonganos,reshape(tablonga(	14	,:,:),[anoslong,5]));
	BET1	= cat(2,arraylonganos,reshape(tablonga(	15	,:,:),[anoslong,5]));
	NO1 	= cat(2,arraylonganos,reshape(tablonga(	16	,:,:),[anoslong,5]));
	CHI1	= cat(2,arraylonganos,reshape(tablonga(	17	,:,:),[anoslong,5]));
	PI1 	= cat(2,arraylonganos,reshape(tablonga(	18	,:,:),[anoslong,5]));
	P1  	= cat(2,arraylonganos,reshape(tablonga(	19	,:,:),[anoslong,5]));
	S1  	= cat(2,arraylonganos,reshape(tablonga(	20	,:,:),[anoslong,5]));
	K1  	= cat(2,arraylonganos,reshape(tablonga(	21	,:,:),[anoslong,5]));
	PSI1	= cat(2,arraylonganos,reshape(tablonga(	22	,:,:),[anoslong,5]));
	PHI1	= cat(2,arraylonganos,reshape(tablonga(	23	,:,:),[anoslong,5]));
	THE1	= cat(2,arraylonganos,reshape(tablonga(	24	,:,:),[anoslong,5]));
	J1  	= cat(2,arraylonganos,reshape(tablonga(	25	,:,:),[anoslong,5]));
	twoPO1	= cat(2,arraylonganos,reshape(tablonga(	26	,:,:),[anoslong,5]));
	SO1 	= cat(2,arraylonganos,reshape(tablonga(	27	,:,:),[anoslong,5]));
	OO1 	= cat(2,arraylonganos,reshape(tablonga(	28	,:,:),[anoslong,5]));
	UPS1	= cat(2,arraylonganos,reshape(tablonga(	29	,:,:),[anoslong,5]));
	ST36	= cat(2,arraylonganos,reshape(tablonga(	30	,:,:),[anoslong,5]));
	twoNS2	= cat(2,arraylonganos,reshape(tablonga(	31	,:,:),[anoslong,5]));
	ST37	= cat(2,arraylonganos,reshape(tablonga(	32	,:,:),[anoslong,5]));
	ST1 	= cat(2,arraylonganos,reshape(tablonga(	33	,:,:),[anoslong,5]));
	OQ2 	= cat(2,arraylonganos,reshape(tablonga(	34	,:,:),[anoslong,5]));
	EPS2	= cat(2,arraylonganos,reshape(tablonga(	35	,:,:),[anoslong,5]));
	ST2 	= cat(2,arraylonganos,reshape(tablonga(	36	,:,:),[anoslong,5]));
	ST3 	= cat(2,arraylonganos,reshape(tablonga(	37	,:,:),[anoslong,5]));
	O2  	= cat(2,arraylonganos,reshape(tablonga(	38	,:,:),[anoslong,5]));
	twoN2 	= cat(2,arraylonganos,reshape(tablonga(	39	,:,:),[anoslong,5]));
	MU2 	= cat(2,arraylonganos,reshape(tablonga(	40	,:,:),[anoslong,5]));
	SNK2	= cat(2,arraylonganos,reshape(tablonga(	41	,:,:),[anoslong,5]));
	N2  	= cat(2,arraylonganos,reshape(tablonga(	42	,:,:),[anoslong,5]));
	NU2 	= cat(2,arraylonganos,reshape(tablonga(	43	,:,:),[anoslong,5]));
	ST4 	= cat(2,arraylonganos,reshape(tablonga(	44	,:,:),[anoslong,5]));
	OP2 	= cat(2,arraylonganos,reshape(tablonga(	45	,:,:),[anoslong,5]));
	GAM2	= cat(2,arraylonganos,reshape(tablonga(	46	,:,:),[anoslong,5]));
	H1  	= cat(2,arraylonganos,reshape(tablonga(	47	,:,:),[anoslong,5]));
	M2 		= cat(2,arraylonganos,reshape(tablonga(	48	,:,:),[anoslong,5]));
	H2  	= cat(2,arraylonganos,reshape(tablonga(	49	,:,:),[anoslong,5]));
	MKS2	= cat(2,arraylonganos,reshape(tablonga(	50	,:,:),[anoslong,5]));
	ST5 	= cat(2,arraylonganos,reshape(tablonga(	51	,:,:),[anoslong,5]));
	ST6 	= cat(2,arraylonganos,reshape(tablonga(	52	,:,:),[anoslong,5]));
	LDA2	= cat(2,arraylonganos,reshape(tablonga(	53	,:,:),[anoslong,5]));
	L2  	= cat(2,arraylonganos,reshape(tablonga(	54	,:,:),[anoslong,5]));
	twoSK2	= cat(2,arraylonganos,reshape(tablonga(	55	,:,:),[anoslong,5]));
	T2  	= cat(2,arraylonganos,reshape(tablonga(	56	,:,:),[anoslong,5]));
	S2  	= cat(2,arraylonganos,reshape(tablonga(	57	,:,:),[anoslong,5]));
	R2  	= cat(2,arraylonganos,reshape(tablonga(	58	,:,:),[anoslong,5]));
	K2  	= cat(2,arraylonganos,reshape(tablonga(	59	,:,:),[anoslong,5]));
	MSN2	= cat(2,arraylonganos,reshape(tablonga(	60	,:,:),[anoslong,5]));
	ETA2	= cat(2,arraylonganos,reshape(tablonga(	61	,:,:),[anoslong,5]));
	ST7 	= cat(2,arraylonganos,reshape(tablonga(	62	,:,:),[anoslong,5]));
	twoSM2	= cat(2,arraylonganos,reshape(tablonga(	63	,:,:),[anoslong,5]));
	ST38	= cat(2,arraylonganos,reshape(tablonga(	64	,:,:),[anoslong,5]));
	SKM2	= cat(2,arraylonganos,reshape(tablonga(	65	,:,:),[anoslong,5]));
	twoSN2	= cat(2,arraylonganos,reshape(tablonga(	66	,:,:),[anoslong,5]));
	NO3 	= cat(2,arraylonganos,reshape(tablonga(	67	,:,:),[anoslong,5]));
	MO3 	= cat(2,arraylonganos,reshape(tablonga(	68	,:,:),[anoslong,5]));
	M3  	= cat(2,arraylonganos,reshape(tablonga(	69	,:,:),[anoslong,5]));
	NK3 	= cat(2,arraylonganos,reshape(tablonga(	70	,:,:),[anoslong,5]));
	SO3 	= cat(2,arraylonganos,reshape(tablonga(	71	,:,:),[anoslong,5]));
	MK3 	= cat(2,arraylonganos,reshape(tablonga(	72	,:,:),[anoslong,5]));
	SP3 	= cat(2,arraylonganos,reshape(tablonga(	73	,:,:),[anoslong,5]));
	SK3 	= cat(2,arraylonganos,reshape(tablonga(	74	,:,:),[anoslong,5]));
	ST8 	= cat(2,arraylonganos,reshape(tablonga(	75	,:,:),[anoslong,5]));
	N4  	= cat(2,arraylonganos,reshape(tablonga(	76	,:,:),[anoslong,5]));
	threeMS4	= cat(2,arraylonganos,reshape(tablonga(	77	,:,:),[anoslong,5]));
	ST39	= cat(2,arraylonganos,reshape(tablonga(	78	,:,:),[anoslong,5]));
	MN4 	= cat(2,arraylonganos,reshape(tablonga(	79	,:,:),[anoslong,5]));
	ST9 	= cat(2,arraylonganos,reshape(tablonga(	80	,:,:),[anoslong,5]));
	ST40	= cat(2,arraylonganos,reshape(tablonga(	81	,:,:),[anoslong,5]));
	M4  	= cat(2,arraylonganos,reshape(tablonga(	82	,:,:),[anoslong,5]));
	ST10	= cat(2,arraylonganos,reshape(tablonga(	83	,:,:),[anoslong,5]));
	SN4 	= cat(2,arraylonganos,reshape(tablonga(	84	,:,:),[anoslong,5]));
	KN4 	= cat(2,arraylonganos,reshape(tablonga(	85	,:,:),[anoslong,5]));
	MS4 	= cat(2,arraylonganos,reshape(tablonga(	86	,:,:),[anoslong,5]));
	MK4 	= cat(2,arraylonganos,reshape(tablonga(	87	,:,:),[anoslong,5]));
	SL4 	= cat(2,arraylonganos,reshape(tablonga(	88	,:,:),[anoslong,5]));
	S4  	= cat(2,arraylonganos,reshape(tablonga(	89	,:,:),[anoslong,5]));
	SK4 	= cat(2,arraylonganos,reshape(tablonga(	90	,:,:),[anoslong,5]));
	MNO5	= cat(2,arraylonganos,reshape(tablonga(	91	,:,:),[anoslong,5]));
	twoMO5	= cat(2,arraylonganos,reshape(tablonga(	92	,:,:),[anoslong,5]));
	threeMP5	= cat(2,arraylonganos,reshape(tablonga(	93	,:,:),[anoslong,5]));
	MNK5	= cat(2,arraylonganos,reshape(tablonga(	94	,:,:),[anoslong,5]));
	twoMP5	= cat(2,arraylonganos,reshape(tablonga(	95	,:,:),[anoslong,5]));
	twoMK5	= cat(2,arraylonganos,reshape(tablonga(	96	,:,:),[anoslong,5]));
	MSK5	= cat(2,arraylonganos,reshape(tablonga(	97	,:,:),[anoslong,5]));
	threeKM5	= cat(2,arraylonganos,reshape(tablonga(	98	,:,:),[anoslong,5]));
	twoSK5	= cat(2,arraylonganos,reshape(tablonga(	99	,:,:),[anoslong,5]));
	ST11	= cat(2,arraylonganos,reshape(tablonga(	100	,:,:),[anoslong,5]));
	twoNM6	= cat(2,arraylonganos,reshape(tablonga(	101	,:,:),[anoslong,5]));
	ST12	= cat(2,arraylonganos,reshape(tablonga(	102	,:,:),[anoslong,5]));
	twoMN6	= cat(2,arraylonganos,reshape(tablonga(	103	,:,:),[anoslong,5]));
	ST13	= cat(2,arraylonganos,reshape(tablonga(	104	,:,:),[anoslong,5]));
	ST41	= cat(2,arraylonganos,reshape(tablonga(	105	,:,:),[anoslong,5]));
	M6  	= cat(2,arraylonganos,reshape(tablonga(	106	,:,:),[anoslong,5]));
	MSN6	= cat(2,arraylonganos,reshape(tablonga(	107	,:,:),[anoslong,5]));
	MKN6	= cat(2,arraylonganos,reshape(tablonga(	108	,:,:),[anoslong,5]));
	ST42	= cat(2,arraylonganos,reshape(tablonga(	109	,:,:),[anoslong,5]));
	twoMS6	= cat(2,arraylonganos,reshape(tablonga(	110	,:,:),[anoslong,5]));
	twoMK6	= cat(2,arraylonganos,reshape(tablonga(	111	,:,:),[anoslong,5]));
	NSK6	= cat(2,arraylonganos,reshape(tablonga(	112	,:,:),[anoslong,5]));
	twoSM6	= cat(2,arraylonganos,reshape(tablonga(	113	,:,:),[anoslong,5]));
	MSK6	= cat(2,arraylonganos,reshape(tablonga(	114	,:,:),[anoslong,5]));
	S6  	= cat(2,arraylonganos,reshape(tablonga(	115	,:,:),[anoslong,5]));
	ST14	= cat(2,arraylonganos,reshape(tablonga(	116	,:,:),[anoslong,5]));
	ST15	= cat(2,arraylonganos,reshape(tablonga(	117	,:,:),[anoslong,5]));
	M7  	= cat(2,arraylonganos,reshape(tablonga(	118	,:,:),[anoslong,5]));
	ST16	= cat(2,arraylonganos,reshape(tablonga(	119	,:,:),[anoslong,5]));
	threeMK7	= cat(2,arraylonganos,reshape(tablonga(	120	,:,:),[anoslong,5]));
	ST17	= cat(2,arraylonganos,reshape(tablonga(	121	,:,:),[anoslong,5]));
	ST18	= cat(2,arraylonganos,reshape(tablonga(	122	,:,:),[anoslong,5]));
	threeMN8	= cat(2,arraylonganos,reshape(tablonga(	123	,:,:),[anoslong,5]));
	ST19	= cat(2,arraylonganos,reshape(tablonga(	124	,:,:),[anoslong,5]));
	M8  	= cat(2,arraylonganos,reshape(tablonga(	125	,:,:),[anoslong,5]));
	ST20	= cat(2,arraylonganos,reshape(tablonga(	126	,:,:),[anoslong,5]));
	ST21	= cat(2,arraylonganos,reshape(tablonga(	127	,:,:),[anoslong,5]));
	threeMS8	= cat(2,arraylonganos,reshape(tablonga(	128	,:,:),[anoslong,5]));
	threeMK8	= cat(2,arraylonganos,reshape(tablonga(	129	,:,:),[anoslong,5]));
	ST22	= cat(2,arraylonganos,reshape(tablonga(	130	,:,:),[anoslong,5]));
	ST23	= cat(2,arraylonganos,reshape(tablonga(	131	,:,:),[anoslong,5]));
	ST24	= cat(2,arraylonganos,reshape(tablonga(	132	,:,:),[anoslong,5]));
	ST25	= cat(2,arraylonganos,reshape(tablonga(	133	,:,:),[anoslong,5]));
	ST26	= cat(2,arraylonganos,reshape(tablonga(	134	,:,:),[anoslong,5]));
	fourMK9	= cat(2,arraylonganos,reshape(tablonga(	135	,:,:),[anoslong,5]));
	ST27	= cat(2,arraylonganos,reshape(tablonga(	136	,:,:),[anoslong,5]));
	ST28	= cat(2,arraylonganos,reshape(tablonga(	137	,:,:),[anoslong,5]));
	M10 	= cat(2,arraylonganos,reshape(tablonga(	138	,:,:),[anoslong,5]));
	ST29	= cat(2,arraylonganos,reshape(tablonga(	139	,:,:),[anoslong,5]));
	ST30	= cat(2,arraylonganos,reshape(tablonga(	140	,:,:),[anoslong,5]));
	ST31	= cat(2,arraylonganos,reshape(tablonga(	141	,:,:),[anoslong,5]));
	ST32	= cat(2,arraylonganos,reshape(tablonga(	142	,:,:),[anoslong,5]));
	ST33	= cat(2,arraylonganos,reshape(tablonga(	143	,:,:),[anoslong,5]));
	M12 	= cat(2,arraylonganos,reshape(tablonga(	144	,:,:),[anoslong,5]));
	ST34	= cat(2,arraylonganos,reshape(tablonga(	145	,:,:),[anoslong,5]));
	ST35	= cat(2,arraylonganos,reshape(tablonga(	146	,:,:),[anoslong,5]));
	
	
	Z0  	=	 cat(1,compheader,	Z0  	);
	SA  	=	 cat(1,compheader,	SA  	);
	SSA 	=	 cat(1,compheader,	SSA 	);
	MSM 	=	 cat(1,compheader,	MSM 	);
	MM  	=	 cat(1,compheader,	MM  	);
	MSF 	=	 cat(1,compheader,	MSF 	);
	MF  	=	 cat(1,compheader,	MF  	);
	ALP1	=	 cat(1,compheader,	ALP1	);
	twoQ1 	=	 cat(1,compheader,	twoQ1 	);
	SIG1	=	 cat(1,compheader,	SIG1	);
	Q1  	=	 cat(1,compheader,	Q1  	);
	RHO1	=	 cat(1,compheader,	RHO1	);
	O1  	=	 cat(1,compheader,	O1  	);
	TAU1	=	 cat(1,compheader,	TAU1	);
	BET1	=	 cat(1,compheader,	BET1	);
	NO1 	=	 cat(1,compheader,	NO1 	);
	CHI1	=	 cat(1,compheader,	CHI1	);
	PI1 	=	 cat(1,compheader,	PI1 	);
	P1  	=	 cat(1,compheader,	P1  	);
	S1  	=	 cat(1,compheader,	S1  	);
	K1  	=	 cat(1,compheader,	K1  	);
	PSI1	=	 cat(1,compheader,	PSI1	);
	PHI1	=	 cat(1,compheader,	PHI1	);
	THE1	=	 cat(1,compheader,	THE1	);
	J1  	=	 cat(1,compheader,	J1  	);
	twoPO1	=	 cat(1,compheader,	twoPO1	);
	SO1 	=	 cat(1,compheader,	SO1 	);
	OO1 	=	 cat(1,compheader,	OO1 	);
	UPS1	=	 cat(1,compheader,	UPS1	);
	ST36	=	 cat(1,compheader,	ST36	);
	twoNS2	=	 cat(1,compheader,	twoNS2	);
	ST37	=	 cat(1,compheader,	ST37	);
	ST1 	=	 cat(1,compheader,	ST1 	);
	OQ2 	=	 cat(1,compheader,	OQ2 	);
	EPS2	=	 cat(1,compheader,	EPS2	);
	ST2 	=	 cat(1,compheader,	ST2 	);
	ST3 	=	 cat(1,compheader,	ST3 	);
	O2  	=	 cat(1,compheader,	O2  	);
	twoN2 	=	 cat(1,compheader,	twoN2 	);
	MU2 	=	 cat(1,compheader,	MU2 	);
	SNK2	=	 cat(1,compheader,	SNK2	);
	N2  	=	 cat(1,compheader,	N2  	);
	NU2 	=	 cat(1,compheader,	NU2 	);
	ST4 	=	 cat(1,compheader,	ST4 	);
	OP2 	=	 cat(1,compheader,	OP2 	);
	GAM2	=	 cat(1,compheader,	GAM2	);
	H1  	=	 cat(1,compheader,	H1  	);
	M2 	=	 cat(1,compheader,	M2 	);
	H2  	=	 cat(1,compheader,	H2  	);
	MKS2	=	 cat(1,compheader,	MKS2	);
	ST5 	=	 cat(1,compheader,	ST5 	);
	ST6 	=	 cat(1,compheader,	ST6 	);
	LDA2	=	 cat(1,compheader,	LDA2	);
	L2  	=	 cat(1,compheader,	L2  	);
	twoSK2	=	 cat(1,compheader,	twoSK2	);
	T2  	=	 cat(1,compheader,	T2  	);
	S2  	=	 cat(1,compheader,	S2  	);
	R2  	=	 cat(1,compheader,	R2  	);
	K2  	=	 cat(1,compheader,	K2  	);
	MSN2	=	 cat(1,compheader,	MSN2	);
	ETA2	=	 cat(1,compheader,	ETA2	);
	ST7 	=	 cat(1,compheader,	ST7 	);
	twoSM2	=	 cat(1,compheader,	twoSM2	);
	ST38	=	 cat(1,compheader,	ST38	);
	SKM2	=	 cat(1,compheader,	SKM2	);
	twoSN2	=	 cat(1,compheader,	twoSN2	);
	NO3 	=	 cat(1,compheader,	NO3 	);
	MO3 	=	 cat(1,compheader,	MO3 	);
	M3  	=	 cat(1,compheader,	M3  	);
	NK3 	=	 cat(1,compheader,	NK3 	);
	SO3 	=	 cat(1,compheader,	SO3 	);
	MK3 	=	 cat(1,compheader,	MK3 	);
	SP3 	=	 cat(1,compheader,	SP3 	);
	SK3 	=	 cat(1,compheader,	SK3 	);
	ST8 	=	 cat(1,compheader,	ST8 	);
	N4  	=	 cat(1,compheader,	N4  	);
	threeMS4	=	 cat(1,compheader,	threeMS4	);
	ST39	=	 cat(1,compheader,	ST39	);
	MN4 	=	 cat(1,compheader,	MN4 	);
	ST9 	=	 cat(1,compheader,	ST9 	);
	ST40	=	 cat(1,compheader,	ST40	);
	M4  	=	 cat(1,compheader,	M4  	);
	ST10	=	 cat(1,compheader,	ST10	);
	SN4 	=	 cat(1,compheader,	SN4 	);
	KN4 	=	 cat(1,compheader,	KN4 	);
	MS4 	=	 cat(1,compheader,	MS4 	);
	MK4 	=	 cat(1,compheader,	MK4 	);
	SL4 	=	 cat(1,compheader,	SL4 	);
	S4  	=	 cat(1,compheader,	S4  	);
	SK4 	=	 cat(1,compheader,	SK4 	);
	MNO5	=	 cat(1,compheader,	MNO5	);
	twoMO5	=	 cat(1,compheader,	twoMO5	);
	threeMP5	=	 cat(1,compheader,	threeMP5	);
	MNK5	=	 cat(1,compheader,	MNK5	);
	twoMP5	=	 cat(1,compheader,	twoMP5	);
	twoMK5	=	 cat(1,compheader,	twoMK5	);
	MSK5	=	 cat(1,compheader,	MSK5	);
	threeKM5	=	 cat(1,compheader,	threeKM5	);
	twoSK5	=	 cat(1,compheader,	twoSK5	);
	ST11	=	 cat(1,compheader,	ST11	);
	twoNM6	=	 cat(1,compheader,	twoNM6	);
	ST12	=	 cat(1,compheader,	ST12	);
	twoMN6	=	 cat(1,compheader,	twoMN6	);
	ST13	=	 cat(1,compheader,	ST13	);
	ST41	=	 cat(1,compheader,	ST41	);
	M6  	=	 cat(1,compheader,	M6  	);
	MSN6	=	 cat(1,compheader,	MSN6	);
	MKN6	=	 cat(1,compheader,	MKN6	);
	ST42	=	 cat(1,compheader,	ST42	);
	twoMS6	=	 cat(1,compheader,	twoMS6	);
	twoMK6	=	 cat(1,compheader,	twoMK6	);
	NSK6	=	 cat(1,compheader,	NSK6	);
	twoSM6	=	 cat(1,compheader,	twoSM6	);
	MSK6	=	 cat(1,compheader,	MSK6	);
	S6  	=	 cat(1,compheader,	S6  	);
	ST14	=	 cat(1,compheader,	ST14	);
	ST15	=	 cat(1,compheader,	ST15	);
	M7  	=	 cat(1,compheader,	M7  	);
	ST16	=	 cat(1,compheader,	ST16	);
	threeMK7	=	 cat(1,compheader,	threeMK7	);
	ST17	=	 cat(1,compheader,	ST17	);
	ST18	=	 cat(1,compheader,	ST18	);
	threeMN8	=	 cat(1,compheader,	threeMN8	);
	ST19	=	 cat(1,compheader,	ST19	);
	M8  	=	 cat(1,compheader,	M8  	);
	ST20	=	 cat(1,compheader,	ST20	);
	ST21	=	 cat(1,compheader,	ST21	);
	threeMS8	=	 cat(1,compheader,	threeMS8	);
	threeMK8	=	 cat(1,compheader,	threeMK8	);
	ST22	=	 cat(1,compheader,	ST22	);
	ST23	=	 cat(1,compheader,	ST23	);
	ST24	=	 cat(1,compheader,	ST24	);
	ST25	=	 cat(1,compheader,	ST25	);
	ST26	=	 cat(1,compheader,	ST26	);
	fourMK9	=	 cat(1,compheader,	fourMK9	);
	ST27	=	 cat(1,compheader,	ST27	);
	ST28	=	 cat(1,compheader,	ST28	);
	M10 	=	 cat(1,compheader,	M10 	);
	ST29	=	 cat(1,compheader,	ST29	);
	ST30	=	 cat(1,compheader,	ST30	);
	ST31	=	 cat(1,compheader,	ST31	);
	ST32	=	 cat(1,compheader,	ST32	);
	ST33	=	 cat(1,compheader,	ST33	);
	M12 	=	 cat(1,compheader,	M12 	);
	ST34	=	 cat(1,compheader,	ST34	);
	ST35	=	 cat(1,compheader,	ST35	);
	
	
	
	
	writecell(	Z0  	,'Componentes individuais 19.xlsx','Sheet','	Z0  	');
	writecell(	SA  	,'Componentes individuais 19.xlsx','Sheet','	SA  	');
	writecell(	SSA 	,'Componentes individuais 19.xlsx','Sheet','	SSA 	');
	writecell(	MSM 	,'Componentes individuais 19.xlsx','Sheet','	MSM 	');
	writecell(	MM  	,'Componentes individuais 19.xlsx','Sheet','	MM  	');
	writecell(	MSF 	,'Componentes individuais 19.xlsx','Sheet','	MSF 	');
	writecell(	MF  	,'Componentes individuais 19.xlsx','Sheet','	MF  	');
	writecell(	ALP1	,'Componentes individuais 19.xlsx','Sheet','	ALP1	');
	writecell(	twoQ1 	,'Componentes individuais 19.xlsx','Sheet','	2Q1 	');
	writecell(	SIG1	,'Componentes individuais 19.xlsx','Sheet','	SIG1	');
	writecell(	Q1  	,'Componentes individuais 19.xlsx','Sheet','	Q1  	');
	writecell(	RHO1	,'Componentes individuais 19.xlsx','Sheet','	RHO1	');
	writecell(	O1  	,'Componentes individuais 19.xlsx','Sheet','	O1  	');
	writecell(	TAU1	,'Componentes individuais 19.xlsx','Sheet','	TAU1	');
	writecell(	BET1	,'Componentes individuais 19.xlsx','Sheet','	BET1	');
	writecell(	NO1 	,'Componentes individuais 19.xlsx','Sheet','	NO1 	');
	writecell(	CHI1	,'Componentes individuais 19.xlsx','Sheet','	CHI1	');
	writecell(	PI1 	,'Componentes individuais 19.xlsx','Sheet','	PI1 	');
	writecell(	P1  	,'Componentes individuais 19.xlsx','Sheet','	P1  	');
	writecell(	S1  	,'Componentes individuais 19.xlsx','Sheet','	S1  	');
	writecell(	K1  	,'Componentes individuais 19.xlsx','Sheet','	K1  	');
	writecell(	PSI1	,'Componentes individuais 19.xlsx','Sheet','	PSI1	');
	writecell(	PHI1	,'Componentes individuais 19.xlsx','Sheet','	PHI1	');
	writecell(	THE1	,'Componentes individuais 19.xlsx','Sheet','	THE1	');
	writecell(	J1  	,'Componentes individuais 19.xlsx','Sheet','	J1  	');
	writecell(	twoPO1	,'Componentes individuais 19.xlsx','Sheet','	2PO1	');
	writecell(	SO1 	,'Componentes individuais 19.xlsx','Sheet','	SO1 	');
	writecell(	OO1 	,'Componentes individuais 19.xlsx','Sheet','	OO1 	');
	writecell(	UPS1	,'Componentes individuais 19.xlsx','Sheet','	UPS1	');
	writecell(	ST36	,'Componentes individuais 19.xlsx','Sheet','	ST36	');
	writecell(	twoNS2	,'Componentes individuais 19.xlsx','Sheet','	2NS2	');
	writecell(	ST37	,'Componentes individuais 19.xlsx','Sheet','	ST37	');
	writecell(	ST1 	,'Componentes individuais 19.xlsx','Sheet','	ST1 	');
	writecell(	OQ2 	,'Componentes individuais 19.xlsx','Sheet','	OQ2 	');
	writecell(	EPS2	,'Componentes individuais 19.xlsx','Sheet','	EPS2	');
	writecell(	ST2 	,'Componentes individuais 19.xlsx','Sheet','	ST2 	');
	writecell(	ST3 	,'Componentes individuais 19.xlsx','Sheet','	ST3 	');
	writecell(	O2  	,'Componentes individuais 19.xlsx','Sheet','	O2  	');
	writecell(	twoN2 	,'Componentes individuais 19.xlsx','Sheet','	2N2 	');
	writecell(	MU2 	,'Componentes individuais 19.xlsx','Sheet','	MU2 	');
	writecell(	SNK2	,'Componentes individuais 19.xlsx','Sheet','	SNK2	');
	writecell(	N2  	,'Componentes individuais 19.xlsx','Sheet','	N2  	');
	writecell(	NU2 	,'Componentes individuais 19.xlsx','Sheet','	NU2 	');
	writecell(	ST4 	,'Componentes individuais 19.xlsx','Sheet','	ST4 	');
	writecell(	OP2 	,'Componentes individuais 19.xlsx','Sheet','	OP2 	');
	writecell(	GAM2	,'Componentes individuais 19.xlsx','Sheet','	GAM2	');
	writecell(	H1  	,'Componentes individuais 19.xlsx','Sheet','	H1  	');
	writecell(	M2  	,'Componentes individuais 19.xlsx','Sheet','	M2		');
	writecell(	H2  	,'Componentes individuais 19.xlsx','Sheet','	H2  	');
	writecell(	MKS2	,'Componentes individuais 19.xlsx','Sheet','	MKS2	');
	writecell(	ST5 	,'Componentes individuais 19.xlsx','Sheet','	ST5 	');
	writecell(	ST6 	,'Componentes individuais 19.xlsx','Sheet','	ST6 	');
	writecell(	LDA2	,'Componentes individuais 19.xlsx','Sheet','	LDA2	');
	writecell(	L2  	,'Componentes individuais 19.xlsx','Sheet','	L2  	');
	writecell(	twoSK2	,'Componentes individuais 19.xlsx','Sheet','	2SK2	');
	writecell(	T2  	,'Componentes individuais 19.xlsx','Sheet','	T2  	');
	writecell(	S2  	,'Componentes individuais 19.xlsx','Sheet','	S2  	');
	writecell(	R2  	,'Componentes individuais 19.xlsx','Sheet','	R2  	');
	writecell(	K2  	,'Componentes individuais 19.xlsx','Sheet','	K2  	');
	writecell(	MSN2	,'Componentes individuais 19.xlsx','Sheet','	MSN2	');
	writecell(	ETA2	,'Componentes individuais 19.xlsx','Sheet','	ETA2	');
	writecell(	ST7 	,'Componentes individuais 19.xlsx','Sheet','	ST7 	');
	writecell(	twoSM2	,'Componentes individuais 19.xlsx','Sheet','	2SM2	');
	writecell(	ST38	,'Componentes individuais 19.xlsx','Sheet','	ST38	');
	writecell(	SKM2	,'Componentes individuais 19.xlsx','Sheet','	SKM2	');
	writecell(	twoSN2	,'Componentes individuais 19.xlsx','Sheet','	2SN2	');
	writecell(	NO3 	,'Componentes individuais 19.xlsx','Sheet','	NO3 	');
	writecell(	MO3 	,'Componentes individuais 19.xlsx','Sheet','	MO3 	');
	writecell(	M3  	,'Componentes individuais 19.xlsx','Sheet','	M3  	');
	writecell(	NK3 	,'Componentes individuais 19.xlsx','Sheet','	NK3 	');
	writecell(	SO3 	,'Componentes individuais 19.xlsx','Sheet','	SO3 	');
	writecell(	MK3 	,'Componentes individuais 19.xlsx','Sheet','	MK3 	');
	writecell(	SP3 	,'Componentes individuais 19.xlsx','Sheet','	SP3 	');
	writecell(	SK3 	,'Componentes individuais 19.xlsx','Sheet','	SK3 	');
	writecell(	ST8 	,'Componentes individuais 19.xlsx','Sheet','	ST8 	');
	writecell(	N4  	,'Componentes individuais 19.xlsx','Sheet','	N4  	');
	writecell(	threeMS4	,'Componentes individuais 19.xlsx','Sheet','	3MS4	');
	writecell(	ST39	,'Componentes individuais 19.xlsx','Sheet','	ST39	');
	writecell(	MN4 	,'Componentes individuais 19.xlsx','Sheet','	MN4 	');
	writecell(	ST9 	,'Componentes individuais 19.xlsx','Sheet','	ST9 	');
	writecell(	ST40	,'Componentes individuais 19.xlsx','Sheet','	ST40	');
	writecell(	M4  	,'Componentes individuais 19.xlsx','Sheet','	M4  	');
	writecell(	ST10	,'Componentes individuais 19.xlsx','Sheet','	ST10	');
	writecell(	SN4 	,'Componentes individuais 19.xlsx','Sheet','	SN4 	');
	writecell(	KN4 	,'Componentes individuais 19.xlsx','Sheet','	KN4 	');
	writecell(	MS4 	,'Componentes individuais 19.xlsx','Sheet','	MS4 	');
	writecell(	MK4 	,'Componentes individuais 19.xlsx','Sheet','	MK4 	');
	writecell(	SL4 	,'Componentes individuais 19.xlsx','Sheet','	SL4 	');
	writecell(	S4  	,'Componentes individuais 19.xlsx','Sheet','	S4  	');
	writecell(	SK4 	,'Componentes individuais 19.xlsx','Sheet','	SK4 	');
	writecell(	MNO5	,'Componentes individuais 19.xlsx','Sheet','	MNO5	');
	writecell(	twoMO5	,'Componentes individuais 19.xlsx','Sheet','	2MO5	');
	writecell(	threeMP5	,'Componentes individuais 19.xlsx','Sheet','	3MP5	');
	writecell(	MNK5	,'Componentes individuais 19.xlsx','Sheet','	MNK5	');
	writecell(	twoMP5	,'Componentes individuais 19.xlsx','Sheet','	2MP5	');
	writecell(	twoMK5	,'Componentes individuais 19.xlsx','Sheet','	2MK5	');
	writecell(	MSK5	,'Componentes individuais 19.xlsx','Sheet','	MSK5	');
	writecell(	threeKM5	,'Componentes individuais 19.xlsx','Sheet','	3KM5	');
	writecell(	twoSK5	,'Componentes individuais 19.xlsx','Sheet','	2SK5	');
	writecell(	ST11	,'Componentes individuais 19.xlsx','Sheet','	ST11	');
	writecell(	twoNM6	,'Componentes individuais 19.xlsx','Sheet','	2NM6	');
	writecell(	ST12	,'Componentes individuais 19.xlsx','Sheet','	ST12	');
	writecell(	twoMN6	,'Componentes individuais 19.xlsx','Sheet','	2MN6	');
	writecell(	ST13	,'Componentes individuais 19.xlsx','Sheet','	ST13	');
	writecell(	ST41	,'Componentes individuais 19.xlsx','Sheet','	ST41	');
	writecell(	M6  	,'Componentes individuais 19.xlsx','Sheet','	M6  	');
	writecell(	MSN6	,'Componentes individuais 19.xlsx','Sheet','	MSN6	');
	writecell(	MKN6	,'Componentes individuais 19.xlsx','Sheet','	MKN6	');
	writecell(	ST42	,'Componentes individuais 19.xlsx','Sheet','	ST42	');
	writecell(	twoMS6	,'Componentes individuais 19.xlsx','Sheet','	2MS6	');
	writecell(	twoMK6	,'Componentes individuais 19.xlsx','Sheet','	2MK6	');
	writecell(	NSK6	,'Componentes individuais 19.xlsx','Sheet','	NSK6	');
	writecell(	twoSM6	,'Componentes individuais 19.xlsx','Sheet','	2SM6	');
	writecell(	MSK6	,'Componentes individuais 19.xlsx','Sheet','	MSK6	');
	writecell(	S6  	,'Componentes individuais 19.xlsx','Sheet','	S6  	');
	writecell(	ST14	,'Componentes individuais 19.xlsx','Sheet','	ST14	');
	writecell(	ST15	,'Componentes individuais 19.xlsx','Sheet','	ST15	');
	writecell(	M7  	,'Componentes individuais 19.xlsx','Sheet','	M7  	');
	writecell(	ST16	,'Componentes individuais 19.xlsx','Sheet','	ST16	');
	writecell(	threeMK7	,'Componentes individuais 19.xlsx','Sheet','	3MK7	');
	writecell(	ST17	,'Componentes individuais 19.xlsx','Sheet','	ST17	');
	writecell(	ST18	,'Componentes individuais 19.xlsx','Sheet','	ST18	');
	writecell(	threeMN8	,'Componentes individuais 19.xlsx','Sheet','	3MN8	');
	writecell(	ST19	,'Componentes individuais 19.xlsx','Sheet','	ST19	');
	writecell(	M8  	,'Componentes individuais 19.xlsx','Sheet','	M8  	');
	writecell(	ST20	,'Componentes individuais 19.xlsx','Sheet','	ST20	');
	writecell(	ST21	,'Componentes individuais 19.xlsx','Sheet','	ST21	');
	writecell(	threeMS8	,'Componentes individuais 19.xlsx','Sheet','	3MS8	');
	writecell(	threeMK8	,'Componentes individuais 19.xlsx','Sheet','	3MK8	');
	writecell(	ST22	,'Componentes individuais 19.xlsx','Sheet','	ST22	');
	writecell(	ST23	,'Componentes individuais 19.xlsx','Sheet','	ST23	');
	writecell(	ST24	,'Componentes individuais 19.xlsx','Sheet','	ST24	');
	writecell(	ST25	,'Componentes individuais 19.xlsx','Sheet','	ST25	');
	writecell(	ST26	,'Componentes individuais 19.xlsx','Sheet','	ST26	');
	writecell(	fourMK9	,'Componentes individuais 19.xlsx','Sheet','	4MK9	');
	writecell(	ST27	,'Componentes individuais 19.xlsx','Sheet','	ST27	');
	writecell(	ST28	,'Componentes individuais 19.xlsx','Sheet','	ST28	');
	writecell(	M10 	,'Componentes individuais 19.xlsx','Sheet','	M10 	');
	writecell(	ST29	,'Componentes individuais 19.xlsx','Sheet','	ST29	');
	writecell(	ST30	,'Componentes individuais 19.xlsx','Sheet','	ST30	');
	writecell(	ST31	,'Componentes individuais 19.xlsx','Sheet','	ST31	');
	writecell(	ST32	,'Componentes individuais 19.xlsx','Sheet','	ST32	');
	writecell(	ST33	,'Componentes individuais 19.xlsx','Sheet','	ST33	');
	writecell(	M12 	,'Componentes individuais 19.xlsx','Sheet','	M12 	');
	writecell(	ST34	,'Componentes individuais 19.xlsx','Sheet','	ST34	');
	writecell(	ST35	,'Componentes individuais 19.xlsx','Sheet','	ST35	');
	
	
        
        
        
        
        
        
end



toc
if 
%se tabelona e tablonga existem, retorna as tabelas 
end
end %end root
