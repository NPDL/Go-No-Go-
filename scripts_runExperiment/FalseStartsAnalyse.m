function [FalseStarts] = FalseStartsAnalyse(output)

% "Feedback" and "Start" refer to the place at which the False Start was made
% The former indicates a button press before the sound start (technically part of the previous trial)
% The latter indicates a button press < 150 ms after the sound start

% Checking "Prior" will tell you if participants had a tendency to false start after being primed with a certain trial
% Checking "Subsequent" will tell you if there is something wrong with the code's timing.  
% In other words, if Subsequent rates for NoGo are lower than those for FreqGo or InFreqGo, then the participant is either omniscient or there is a problem with the code.

% Could improve this script by comparing Subsequent presses to those
% expected based on prior probability

Trials.Total = sum(output.trialNumber~=0);

FalseStarts.Number = length(output.keyPressFalseStarts) + length(output.keyPressFeedback);  % When feedback is given, you can false-start before the trial during the feedback wait period
FalseStarts.Rate = FalseStarts.Number/Trials.Total;

FalseStarts.Feedback.Number = length(output.keyPressFeedback);
FalseStarts.Feedback.Prior.Index = [];
for i = 1:length(output.keyPressFeedback)
    FalseStarts.Feedback.Prior.Index(end+1) = output.trialNumber((output.trialSoundStart < output.keyPressFeedback(i))&(output.trialEnd > output.keyPressFeedback(i)));
end
FalseStarts.Feedback.Prior.GoFreqRate = sum(output.trialType(FalseStarts.Feedback.Prior.Index)==1)/sum((output.trialNumber~=0)&(output.trialType==1));
FalseStarts.Feedback.Prior.GoInFreqRate = sum(output.trialType(FalseStarts.Feedback.Prior.Index)==-1)/sum((output.trialNumber~=0)&(output.trialType==-1));
FalseStarts.Feedback.Prior.NoGoRate = sum(output.trialType(FalseStarts.Feedback.Prior.Index)==0)/sum((output.trialNumber~=0)&(output.trialType==0));

FalseStarts.Feedback.Subsequent.Index = FalseStarts.Feedback.Prior.Index+1;
FalseStarts.Feedback.Subsequent.Index = FalseStarts.Feedback.Subsequent.Index(FalseStarts.Feedback.Subsequent.Index<sum(output.trialNumber~=0)+1);
FalseStarts.Feedback.Subsequent.GoFreqRate = sum(output.trialType(FalseStarts.Feedback.Subsequent.Index)==1)/sum((output.trialNumber~=0)&(output.trialType==1));
FalseStarts.Feedback.Subsequent.GoInFreqRate = sum(output.trialType(FalseStarts.Feedback.Subsequent.Index)==-1)/sum((output.trialNumber~=0)&(output.trialType==-1));
FalseStarts.Feedback.Subsequent.NoGoRate = sum(output.trialType(FalseStarts.Feedback.Subsequent.Index)==0)/sum((output.trialNumber~=0)&(output.trialType==0));

FalseStarts.Start.Number = length(output.keyPressFalseStarts);
FalseStarts.Start.Subsequent.Index = [];
for i = 1:length(output.keyPressFalseStarts)
    FalseStarts.Start.Subsequent.Index(end+1) = output.trialNumber((output.trialSoundStart < output.keyPressFalseStarts(i))&(output.trialEnd > output.keyPressFalseStarts(i)));
end
FalseStarts.Start.Subsequent.GoFreqRate = sum(output.trialType(FalseStarts.Start.Subsequent.Index)==1)/sum((output.trialNumber~=0)&(output.trialType==1));
FalseStarts.Start.Subsequent.GoInFreqRate = sum(output.trialType(FalseStarts.Start.Subsequent.Index)==-1)/sum((output.trialNumber~=0)&(output.trialType==-1));
FalseStarts.Start.Subsequent.NoGoRate = sum(output.trialType(FalseStarts.Start.Subsequent.Index)==0)/sum((output.trialNumber~=0)&(output.trialType==0));

FalseStarts.Start.Prior.Index = FalseStarts.Start.Subsequent.Index-1;
FalseStarts.Start.Prior.Index = FalseStarts.Start.Prior.Index(FalseStarts.Start.Prior.Index>0);
FalseStarts.Start.Prior.GoFreqRate = sum(output.trialType(FalseStarts.Start.Prior.Index)==1)/sum((output.trialNumber~=0)&(output.trialType==1));
FalseStarts.Start.Prior.GoInFreqRate = sum(output.trialType(FalseStarts.Start.Prior.Index)==-1)/sum((output.trialNumber~=0)&(output.trialType==-1));
FalseStarts.Start.Prior.NoGoRate = sum(output.trialType(FalseStarts.Start.Prior.Index)==0)/sum((output.trialNumber~=0)&(output.trialType==0));

end