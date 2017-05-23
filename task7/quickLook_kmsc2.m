function [] = quickLook_kmsc2(subID)
% single-subject analysis
% for 2 conditions (run in 2 successive blocks)
%
% this function plots a single participant's trial-by-trial data
%   (same as quickLook.m).
% in addition, it also calculates the kaplan-meier survival curve and area
%   under the curve. This is an estimate of the average number of seconds
%   the participant was willing to wait. 
%
% input: subID (optional) is a string containing the subject ID. If an ID
%   is not supplied, user will be prompted to pick a file. 


% add path to directory of analysis subfunctions
addpath('anSubFx');

% identify the data file
if nargin>0 && ischar(subID)
    % if subID was given, load the file
    dfname = fullfile('data',sprintf('wtw-work-3_%s_1.mat',subID));
else
    % otherwise prompt the user to select a file
    [fname,pathname] = uigetfile('data/*');
    dfname = fullfile(pathname,fname);
end
d = load(dfname);
fprintf('file: %s\n',dfname);

% format data
[subInfo, trials] = formatData(d);
id = subInfo.id; % the subject ID

ceilVal = 16;

% clear figure windows
for f = 1:2, figure(f); clf; end

% analyze one block at a time
nBks = length(trials);
h = nan(1,nBks); % will hold handles to dataseries objects
rtForBoxplot = []; % will accumulate data for a boxplot
cName = cell(nBks,1);
for b = 1:nBks
    
    try
        cName{b} = subInfo.distribs{b}; % the timing condition
    catch
        cName{b} = '';
    end
    fprintf('  block %d, %s:\n',b,cName{b});
    
    % check if this is the 'active' condition
    if isfield(trials(b),'trialKeypressTimes') && ~isempty(trials(b).trialKeypressTimes{1})
        nTrials = numel(trials(b).trialKeypressTimes);
        iri = []; % will store all inter-response intervals
        for i = 1:nTrials
            iri = [iri; diff(trials(b).trialKeypressTimes{i})']; %#ok<AGROW>
        end
        fprintf('    ACTIVE condition: median IRI = %1.3f s (%1.1f resps/s)\n',...
            median(iri),1/median(iri));
        fprintf('      IQR %1.3f to %1.3f, based on n = %d\n',...
            prctile(iri,[25, 75]), numel(iri));
    end
    
    % plot of the subject's trialwise data
    figure(1);
    subplot(nBks,1,b);
    titleStr = sprintf('%s, cond = %s',id,cName{b});
    ssPlot(trials(b),titleStr,ceilVal); % external subfunction
    
    % calculate the kaplan-meier survival curve and print auc results
    [kmsc, auc] = qtask_kmSurvival(trials(b));
    fprintf('    auc = %1.2f s\n',auc);

    % plot the survival curve
    figure(2);
    hold on;
    titleStr = sprintf('%s: KM survival curves',id);
    h(b) = qtask_plotKm(kmsc,titleStr);
    hold off;
    
    % overall reward RT (may later examine as a function of delay length;
    % here the main goal is just to see that RTs are fast enough to suggest
    % participants are engaged with the task). 
    allRTs = trials(b).rewardRT;
    validRTs = allRTs(~isnan(allRTs));
    nRTs = length(validRTs);
    fprintf('    RT (from %d rewarded trials): median = %1.3f s, iqr = %1.3f - %1.3f s\n',...
        nRTs,median(validRTs),prctile(validRTs,[25,75]));
    rtForBoxplot = [rtForBoxplot; [validRTs, b*ones(nRTs,1)]]; %#ok<AGROW>
    
    % print total earnings
    blockEarnings = sum(trials(b).payoff);
    fprintf('    block earnings: $%1.2f\n',blockEarnings/100); % converting cents to dollars
    
    % print info about responding during the ITI
    if isfield(trials,'anyItiKeypress')
        k = trials(b).anyItiKeypress;
        fprintf('    %d of %d trials (%1.1f%%) have keypresses during the ITI.\n',...
            sum(k),length(k),100*sum(k)/length(k));
    else
        fprintf('    No ITI keypress info available.\n');
    end
        
end

% legend and formatting for figure 2 (survival curves)
set(h(1),'Color','b'); % block 1
if numel(h)>1, set(h(2),'Color','r'); end % block 2
legend(h,cName,'Interpreter','none');

% plot RTs in each block
figure(3); clf;
if length(unique(rtForBoxplot(:,2)))==nBks % ONLY if both blocks have data
    boxplot(rtForBoxplot(:,1),rtForBoxplot(:,2));
    set(gca,'Box','off','FontSize',16);
    % set(gca,'XTick',1:nBks,'XTickLabel',subInfo.distribs);
    set(gca,'XTick',1:nBks);
    ylim = get(gca,'YLim');
    set(gca,'YLim',[0, ylim(2)]);
    title(sprintf('%s: RT when rewarded',id),'Interpreter','none');
    xlabel('Block');
    ylabel('Reward RT (s)');
end

end




%%%%%
% subfunction to format one subject's data
function [subInfo, trials] = formatData(d)

% assess the number of blocks
bkIdx = [d.trialData.blockNum]';
nBks = max(bkIdx);

trials = struct([]);
for b = 1:nBks
    
    idx = bkIdx==b;
    
    % add data fields for trials
    trials(b).trialNums = (1:sum(idx))';
    if isfield(d.trialData,'itiKeypresses') % one subject lacks iti keypress data
        trials(b).itiKeypressTimes = {d.trialData(idx).itiKeypresses}';
        trials(b).anyItiKeypress = cellfun(@any,trials(b).itiKeypressTimes,'UniformOutput',true); % logical vector
    end
    if isfield(d.trialData,'trialKeypresses') % if there is an active condition
        trials(b).trialKeypressTimes = {d.trialData(idx).trialKeypresses}';
    end
    trials(b).designatedWait = [d.trialData(idx).designatedWait]';
    trials(b).outcomeWin = [d.trialData(idx).payoff]'~=0;
    trials(b).outcomeQuit = [d.trialData(idx).payoff]'==0;
    trials(b).payoff = [d.trialData(idx).payoff]';
    trials(b).startTime = [d.trialData(idx).initialTime]';
    trials(b).rewardTime = [d.trialData(idx).rwdOnsetTime]';
    trials(b).latency = [d.trialData(idx).latency]';
    trials(b).rewardRT = trials(b).latency - trials(b).rewardTime;
    trials(b).outcomeTime = [d.trialData(idx).outcomeTime]';
    trials(b).totalEarned = [d.trialData(idx).totalEarned]';

end

% display some info
subInfo.distribs = d.dataHeader.distribs;
subInfo.id = d.dataHeader.id;
subInfo.points = trials(b).totalEarned(end);
subInfo.money = subInfo.points/100;
fprintf('id: %s\n',subInfo.id);
fprintf('test date: %s\n',datestr(d.dataHeader.sessionTime));

end % end of subfunction






