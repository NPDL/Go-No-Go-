function cell2csv(fileName, cellArray, separator, overwrite, newline, excelYear, decimal)

% Writes cell array content into a *.csv file.
% 
% CELL2CSV(fileName, cellArray, separator, excelYear, decimal)
%
% fileName     = Name of the file to save. [ i.e. 'text.csv' ]
% cellArray    = Name of the Cell Array where the data is in
% separator    = sign separating the values (default = ';')
% excelYear    = depending on the Excel version, the cells are put into
%                quotes before they are written to the file. The separator
%                is set to semicolon (;)
% decimal      = defines the decimal separator (default = '.')
%
%         by Sylvain Fiedler, KA, 2004
% updated by Sylvain Fiedler, Metz, 06
% fixed the logical-bug, Kaiserslautern, 06/2008, S.Fiedler
% added the choice of decimal separator, 11/2010, S.Fiedler

% RL added overwrite/append functionality
% RL added newline after the last output
% RL changed optional args to default to conditionals when empty, as well
% as when they don't exist
% RL added optional newline argument (could consider editing this out so
% that it reverts to outputting a new line whenever there is an append)
% RL added an option to turn a cell array into a comma separated list

%% Checking für optional Variables
if ~strcmp(fileName(end-3:end),'.csv')
    error('file must end in .csv or won''t look correct');
end

if ~exist('separator', 'var') || isempty(separator)
    separator = ',';
end

if ~exist('excelYear', 'var') || isempty(excelYear)
    excelYear = 1997;
end

if ~exist('decimal', 'var') || isempty(decimal)
    decimal = '.';
end

if ~exist('overwrite', 'var') || isempty(overwrite)
    overwrite = 0;
end    

if ~exist('newline', 'var') || isempty(newline)
    newline = 0;
end 
    
%% Setting separator for newer excelYears
if excelYear > 2000
    separator = ';';
end

%% Write file

switch overwrite
    case 1
        datei = fopen(fileName, 'w');
    case 0
        datei = fopen(fileName, 'a+');
end    

% OUTPUT newline
if newline == 1
    fprintf(datei, '\n');
end
for z=1:size(cellArray, 1)
    for s=1:size(cellArray, 2)
        
        var = eval(['cellArray{z,s}']);
        % If zero, then empty cell
        if size(var, 1) == 0
            var = '';
        end
        % If numeric -> String
        if isnumeric(var)
            var = num2str(var);
            % Conversion of decimal separator (4 Europe & South America)
            % http://commons.wikimedia.org/wiki/File:DecimalSeparator.svg
            if decimal ~= '.'
                var = strrep(var, '.', decimal);
            end
        end
        % If logical -> 'true' or 'false'
        if islogical(var)
            if var == 1
                var = 'TRUE';
            else
                var = 'FALSE';
            end
        end
        
        % If cell, convert to a comma separated list
        varStr = '';
        if iscellstr(var)
            for i = 1:size(var,1)
                for j = 1:size(var,2)
                    varStr = [varStr var{i,j} ';'];
                end
            end
            var = varStr(1:end-1);
            clear varStr
        end
      
        % If newer version of Excel -> Quotes 4 Strings
        if excelYear > 2000
            var = ['"' var '"'];
        end
          
    
        % OUTPUT value
        fprintf(datei, '%s', var);
        
        % OUTPUT separator
        if s ~= size(cellArray, 2)
            fprintf(datei, separator);
        end
    end
    if z ~= size(cellArray, 1) % prevent a empty line at EOF
        % OUTPUT newline
        fprintf(datei, '\n');
    end
end
% Closing file
fclose(datei);
% END