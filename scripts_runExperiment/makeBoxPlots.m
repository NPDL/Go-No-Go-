params.subs = dir('Data');
params.conditions = unique(out.currentTrialType);

if ~isempty(findstr(params.subs(s).name, 'GNGC'))
            mats = dir(['Data/' params.subs(s).name]);
            for m = 1:length(mats)
                if ~isempty(findstr(mats(m).name, 'R')) && ~isempty(findstr(mats(m).name, 'gonogo'))
                    clearvars -except params mats s m
                    load(['Data/' params.subs(s).name '/' mats(m).name]);
                    %% Do Version-Specific Things
                    if ~exist('out', 'var') % if version 1, but this is a bad way to do it because out var could still exist
                        out = output;
                        out.runNum = out.runNo-4;
                        out.subName = [C.EXPT_STR '_' C.SUB_PRE '_' sprintf('%02d',out.sub)];
                        C.restBeforeTrials = C.REST_BEFORE_TRIALS;
                    end
                    out.runNumStr = sprintf('%02d',out.runNum);
                    out.taskName = 'gonogo';
                    
                    
                    
                end
            end
end
 
[a,b,c] = bplot(out.RT);
legend(a);
titleStr = sprintf('Graph of Responses for %s Condition', condition);
title(titleStr);
xlabel('Run Number'); % x-axis label
ylabel('RT (msec)'); % y-axis label
fig = gcf;
saveas(fig,'filename.jpg');
close all