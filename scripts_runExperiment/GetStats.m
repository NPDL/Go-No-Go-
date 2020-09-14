function [FreqGo, InfreqGo, NoGo, FalseStarts] = GetStats (matfile)

DATA_DIR = 'Data/';
OVERWRITE = 0;

csv.Filename = strcat(DATA_DIR, 'AllSubjectsStats', '.csv');

if ~exist('matfile', 'var')
    listing = dir([DATA_DIR '/GoNoGo*.mat']);
    listing = {listing.name};  % can't I do this in one line?
    csv.out = {'Subject', 'RunNo', '%FreqGo', '%InFreqGo', '%NoGo', 'TotalTrials', 'hadFeedback', 'SoundDuration', 'SoundITI', 'FeedbackDuration', 'FeedbackITI', 'FreqGoCorrectRate', 'InfreqGoCorrectRate', 'NoGoCorrectRate', 'FreqGoRTsMean', 'InfreqGoRTsMean', 'NoGoRTsMean', 'FreqGoRTsSD', ...
            'InfreqGoRTsSD', 'NoGoRTsSD', 'FreqGoSound', 'InfreqGoSound', 'NoGoSound', 'AverageTrialDuration', 'AverageOnsetDuration', 'FalseStartRate', 'Participant', };
else
    listing = {['../' matfile]};  % This won't work anymore now that the subjects are each in their own folder
    csv.out = {};
end
                       
for k = 1:length(listing)
    matName = strcat(DATA_DIR, listing{k});
    load(matName);
    %% Calculate Stats for Each Subject
    FreqGo.isTrial = (out.trialNumber~=0)&(out.trialType==1);
    FreqGo.Total = sum(FreqGo.isTrial);
    FreqGo.isCorrect = (out.trialNumber~=0)&(out.trialType==1)&(out.keyPress==1);
    FreqGo.CorrectNo = sum(FreqGo.isCorrect);
    FreqGo.CorrectRate = FreqGo.CorrectNo/FreqGo.Total;
    FreqGo.isIncorrect = (out.trialNumber~=0)&(out.trialType==1)&(out.keyPress==0);
    FreqGo.IncorrectNo = sum(FreqGo.isIncorrect);
    FreqGo.IncorrectRate = FreqGo.IncorrectNo/FreqGo.Total;
    FreqGo.RTs = out.RT((out.trialNumber~=0)&(out.trialType==1)&(out.keyPress==1));
    FreqGo.RTsMean = mean(FreqGo.RTs);
    FreqGo.RTsSD = std(FreqGo.RTs);
    
    InfreqGo.isTrial = (out.trialNumber~=0)&(out.trialType==-1);
    InfreqGo.Total = sum(InfreqGo.isTrial);
    InfreqGo.isCorrect = (out.trialNumber~=0)&(out.trialType==-1)&(out.keyPress==1);
    InfreqGo.CorrectNo = sum(InfreqGo.isCorrect);
    InfreqGo.CorrectRate = InfreqGo.CorrectNo/InfreqGo.Total;
    InfreqGo.isIncorrect = (out.trialNumber~=0)&(out.trialType==-1)&(out.keyPress==0);
    InfreqGo.IncorrectNo = sum(InfreqGo.isIncorrect);
    InfreqGo.IncorrectRate = InfreqGo.IncorrectNo/InfreqGo.Total;
    InfreqGo.RTs = out.RT((out.trialNumber~=0)&(out.trialType==-1)&(out.keyPress==1));
    InfreqGo.RTsMean = mean(InfreqGo.RTs);
    InfreqGo.RTsSD = std(InfreqGo.RTs);
    %(InfreqGo.CorrectNo+InfreqGo.IncorrectNo)~=InfreqGo.Total && warning('Incorrect & Correct Trials Do Not Sum to Total Trials for Trial Type');(InfreqGo.CorrectNo+InfreqGo.Incorrect~=InfreqGo.Total) && warning('Incorrect & Correct Trials Do Not Sum to Total Trials for Trial Type');
    % Can also check that number of trials makes sense
   
    NoGo.isTrial = (out.trialNumber~=0)&(out.trialType==0);
    NoGo.Total = sum(NoGo.isTrial);
    NoGo.isCorrect = (out.trialNumber~=0)&(out.trialType==0)&(out.keyPress==0);
    NoGo.CorrectNo = sum(NoGo.isCorrect);
    NoGo.CorrectRate = NoGo.CorrectNo/NoGo.Total;
    NoGo.isIncorrect = (out.trialNumber~=0)&(out.trialType==0)&(out.keyPress==1);
    NoGo.IncorrectNo = sum(NoGo.isIncorrect);
    NoGo.IncorrectRate = NoGo.IncorrectNo/NoGo.Total;
    NoGo.RTs = out.RT((out.trialNumber~=0)&(out.trialType==0)&(out.keyPress==1));
    NoGo.RTsMean = mean(NoGo.RTs);
    NoGo.RTsSD = std(NoGo.RTs);
    %(NoGo.CorrectNo+NoGo.IncorrectNo)~=NoGo.Total && warning('Incorrect & Correct Trials Do Not Sum to Total Trials for Trial Type');(NoGo.CorrectNo+NoGo.Incorrect~=NoGo.Total) && warning('Incorrect & Correct Trials Do Not Sum to Total Trials for Trial Type');
    % Can also check that number of trials makes sense
    Trials.Total = FreqGo.Total + InfreqGo.Total + NoGo.Total;
    FreqGo.Percentage = FreqGo.Total/Trials.Total;
    InfreqGo.Percentage = InfreqGo.Total/Trials.Total;
    NoGo.Percentage = NoGo.Total/Trials.Total;
    
    AverageTrialDuration = mean(out.trialEnd(out.trialEnd~=0)-out.trialSoundStart(out.trialSoundStart~=0));
    
    % Have to account for rest periods
    startIdx = 0;
    diffArray = [];
    for j = 1:length(C.restBeforeTrials)
        if C.restBeforeTrials(j) ~=1  
             diffArray = [diffArray diff(out.trialSoundStart(startIdx+1:C.restBeforeTrials(j)-1))];
             startIdx = C.restBeforeTrials(j);
        end
    end
    diffArray = [diffArray diff(out.trialSoundStart(C.restBeforeTrials(j):end))];
    AverageOnsetDuration = mean(diffArray); 
    clear j startIdx diffArray
    
    FalseStarts.Number = length(out.keyPressFalseStarts) + length(out.keyPressFeedback);  % When feedback is given, you can false-start before the trial during the feedback wait period
    FalseStarts.Rate = FalseStarts.Number/Trials.Total;
    
   csv.out(k+1,:) = {out.subName, out.testOrPractice, out.runNum, FreqGo.Percentage, InfreqGo.Percentage, NoGo.Percentage, Trials.Total, C.giveFeedback, C.soundDuration, C.soundITI, C.feedbackDuration, C.feedbackITI, FreqGo.CorrectRate, InfreqGo.CorrectRate, NoGo.CorrectRate, FreqGo.RTsMean, InfreqGo.RTsMean, NoGo.RTsMean, FreqGo.RTsSD, ...
            InfreqGo.RTsSD, NoGo.RTsSD, audioFiles.Go1.name, audioFiles.Go2.name, audioFiles.NoGo.name, AverageTrialDuration, AverageOnsetDuration, FalseStarts.Rate, ''};   
   clearvars -except i listing DATA_DIR csv OVERWRITE FreqGo InfreqGo NoGo FalseStarts;
end
  
cell2csv(csv.Filename,csv.out,',','','',0);
end