function audioFiles = demoSounds(sub, isBlind)

% Clean Up
clearvars -except sub isBlind
PsychPortAudio('Close');% Close all audio handles
CedrusResponseBox('CloseAll');

exptStr = 'GNGC';
if isBlind == 0
    subPre = 'S';
else
    subPre = 'CB';
end

subNum = sub;
subName = [exptStr '_' subPre '_' sprintf('%02d',subNum)]; 
taskName = 'gonogo';
runName = 'sounds';
dirName = strcat('Data/', subName);
mkdir(dirName);
matName = strcat('Data/', subName, '/', subName, '-', taskName, '_', runName, '-D', datestr(now, 'mmdd'), '.mat');

if exist(matName, 'file')
    load(matName, 'AUDIO_FILE_TYPES');
else
    filesToChoose = {'Sounds/SummerNight.wav'; 'Sounds/Water.wav'; 'Sounds/Unwind.wav'};
    fileOrdersPossible = perms([1:length(filesToChoose)]);
    index = mod(sub-1, length(fileOrdersPossible))+1;
    fileOrder = fileOrdersPossible(index,:);
    AUDIO_FILE_TYPES = struct('name', {filesToChoose{fileOrder(1)}; filesToChoose{fileOrder(2)}; filesToChoose{fileOrder(3)}; 'Sounds/click.wav'; 'Sounds/timeout.wav'; 'Sounds/correct.wav'; 'Sounds/incorrect.wav'}, ...
                             'type', {'Go1'; 'Go2'; 'NoGo'; 'Click'; 'Timeout'; 'Correct'; 'Wrong'});  
    save(matName);                         
end

    %% Load and Initialize Audio Files for Feedback   
    for i = 1:length(AUDIO_FILE_TYPES) %for each filetype
        filetype = AUDIO_FILE_TYPES(i).type;
        filename = AUDIO_FILE_TYPES(i).name;
        audioFiles.(filetype) = dir(filename);  %create a structure containing all associated files        
        for j = 1:length(audioFiles.(filetype)) %for each file, load and get info
            [audioFiles.(filetype)(j).wavedata, audioFiles.(filetype)(j).freq] = audioread(fullfile(fileparts(filename), audioFiles.(filetype)(j).name)); % load sound file
            audioFiles.(filetype)(j).duration = length(audioFiles.(filetype)(j).wavedata) ./ audioFiles.(filetype)(j).freq;
            audioFiles.(filetype)(j).channels = size(audioFiles.(filetype)(j).wavedata,2);
            audioFiles.(filetype)(j).pahandle = PsychPortAudio('Open', [], [], 2, audioFiles.(filetype)(j).freq, audioFiles.(filetype)(j).channels, 0); % opens sound buffer at a different frequency
            PsychPortAudio('FillBuffer', audioFiles.(filetype)(j).pahandle, audioFiles.(filetype)(j).wavedata'); % loads data into buffer
        end
        clear filetype filename;
    end
    InitializePsychSound(1); %initializes sound driver...the 1 pushes for low latency   
    
    while 1
        prompt = 'Press to Play Sound (1=Go1, 2=Go2, 3=NoGo, 4=Click, 5=TimeOut, 6=Ding, 7=Buzz)';
        x = input(prompt);
        playSound(audioFiles,AUDIO_FILE_TYPES(x).type);
    end 

% Clean Up
PsychPortAudio('Close');% Close all audio handles
CedrusResponseBox('CloseAll');

end

function [] = playSound(audioFiles, neededFileType)
if(~isfield(audioFiles, neededFileType)); error('Missing a needed audio file. Check Code.'); end %make sure the file type we need has been added!
 i = randi(length(audioFiles.(neededFileType))); 
 PsychPortAudio('Start', audioFiles.(neededFileType)(i).pahandle, 1,0); %starts sound immediately
 WaitSecs(audioFiles.(neededFileType)(i).duration); %waits for the whole duration of sound for it to play,if this wait is too short then sounds will be cutoff
 PsychPortAudio('Stop', audioFiles.(neededFileType)(i).pahandle);% Stop sound playback
end