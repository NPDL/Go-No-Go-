function [] = MakeTimingFiles ()
clear all;

timingConstants.stimDur = .45;
timingConstants.keyPressDur = 0.1;
timingConstants.dir = 'Data/TimingFiles/varied';

if exist(timingConstants.dir, 'dir')
  rmdir(timingConstants.dir, 's');
end
mkdir(timingConstants.dir);

% get cleaned mats so false alarms are accounted for correctly
mats = dir('Data/GNGC_*/GNGC_*-gonogo_R0*-clean*'); 

 for m = 1:length(mats)  
  clearvars -except mats m timingConstants 
  
  % only get runs 1-3 and get mats that are already cleaned   
   if ~isempty(regexp(mats(m).name, '_R0[123]', 'match'))
     load([mats(m).folder '/' mats(m).name]);   
     out.runNumStr = sprintf('%02d', out.runNum);
     out.regressors = struct('name', {'FreqGoSuccess', 'FreqGoFail', 'InfreqGoSuccess', ...
                      'InfreqGoFail', 'NoGoSuccess', 'NoGoFail', 'ExtraPresses'}, 'isTrial', ...
                      {cleanStats.FreqGo.isCorrect, cleanStats.FreqGo.isIncorrect, cleanStats.InfreqGo.isCorrect, ...
                      cleanStats.InfreqGo.isIncorrect, cleanStats.NoGo.isCorrect, cleanStats.NoGo.isIncorrect, 'N/A'});          
     out.noPressDuration = timingConstants.stimDur; 
     timing = struct;
     for r = 1:length(out.regressors)
       timing(r).fileName = [timingConstants.dir '/' out.subName '-' out.taskName '_' out.runNumStr '-' out.regressors(r).name '.txt'];
       if ~strcmp(out.regressors(r).name, 'ExtraPresses')
         timing(r).isTrialForRegressor = out.regressors(r).isTrial;
         timing(r).numTrialsForRegressor = sum(timing(r).isTrialForRegressor);
         timing(r).onset = out.trialSoundStart(timing(r).isTrialForRegressor);
         if ismember(out.regressors(r).name, {'FreqGoFail', 'InfreqGoFail', 'NoGoSuccess'})
           timing(r).duration = repmat(out.noPressDuration,[1,timing(r).numTrialsForRegressor]);
         else
           timing(r).duration = out.RT(timing(r).isTrialForRegressor);
           timing(r).duration(timing(r).duration < out.noPressDuration) = out.noPressDuration;
         end
       elseif strcmp(out.regressors(r).name, 'ExtraPresses')
         timing(r).onset = sort([out.keyPressTrialExtras, out.keyPressInterim, out.keyPressFeedback]);
         timing(r).numTrialsForRegressor = length(timing(r).onset);
         timing(r).duration = repmat(timingConstants.keyPressDur,[1,timing(r).numTrialsForRegressor]);
       end
       timing(r).weighting = ones(1,timing(r).numTrialsForRegressor);
       timing(r).out = [timing(r).onset', timing(r).duration', timing(r).weighting'];
       dlmwrite(timing(r).fileName, timing(r).out, 'delimiter', '\t', 'precision','%.3f');                
      end
      clear r
    end
 end
  
end
