function [subInfo, d] = group_analysis()
% James Lynch
% 5/16/17
% Group-Level Analysis of wtw-work/task7 data
%    combine all subjects data into single 



% --- INITIALIZE VARIABLES AND READ IN DATA FILES ---
%
%taskName = input('Enter task name: ', 's');
taskName = 'task7'; % just use this for now to save hassle of always having to enter 'task7'
subID = [160:199]; % cheat to get a list of subject IDs to use for struct objects
 

% Directories/filenames
output_dir = '/Users/cdlab_admin/Documents/wtw_work/analysis/group_analysis';  % directory where output will be saved
data_dir = ['/Users/cdlab_admin/Documents/wtw_work/analysis/' taskName '/'];  % directory that contains subject data
groupData_filename = [output_dir '/groupData.mat'];


% Access data files
cd '/Users/cdlab_admin/Documents/wtw_work/analysis/task7/data';
files = dir('*.mat');  % select .mat data files
numSubj = length(files);


% Create a struct that will contain all the subjects and save it
groupData = struct();
for i = 1:numSubj
    data = load(files(i).name);
    groupData(i).data = data;
    
end
save(groupData_filename, 'groupData');


% Return to group_analysis directory
cd '/Users/cdlab_admin/Documents/wtw_work/analysis/group_analysis';
addpath('anSubFx') % directory with analysis subfunctions

[subInfo, d] = formatData(groupData, numSubj);


% --- CALL AND RUN ANALYSIS SUBFUNCTIONS ---
%
nBks = length(d);
h = nan(1,nBks); % will hold handles to dataseries objects
cName = cell(2,1);
cName = {'mixGam_falling', 'mixGam_rising'};
group_auc = struct();
group_kmsc = struct();


for b = 1:nBks
    
    survival = struct();
    
    marker_rising = 1;
    marker_falling = 1;
    for i = 1:numSubj
        
        condition = subInfo(i).distribs(b);
        
        % calculate the kaplan-meier survival curve and print auc results
        % code borrowed from 'quickLook_kmsc2.m' by Joe McGuire
        [survival(i).kmsc, survival(i).auc] = qtask_kmSurvival_groupAnalysis(d(b).trials(i));
        
        if strcmp(condition, cName{1})
            group_auc(b).mixGam_falling(marker_falling) = survival(i).auc;
            group_kmsc(b).mixGam_falling(marker_falling).kmsc = survival(i).kmsc;
            marker_falling = marker_falling+1;
        else
            group_auc(b).mixGam_rising(marker_rising) = survival(i).auc;
            group_kmsc(b).mixGam_rising(marker_rising).kmsc = survival(i).kmsc;
            marker_rising = marker_rising+1;
        end
    end
        
    % Plot the survival curve for each subject in each condition, for each block
    
    % mixGam_rising
    figure;
    hold on;
    titleStr = sprintf('Block %d mixGam_rising KM survival curves', b);
    for i = 1:length(group_kmsc(b).mixGam_rising)
        %hold on;
        h(b) = qtask_plotKm_groupAnalysis(group_kmsc(b).mixGam_rising(i).kmsc,titleStr);
        %hold off;
    end
    
    % mixGam_falling
    figure;
    hold on;
    titleStr = sprintf('Block %d mixGam_falling KM survival curves', b);
    for i = 1:length(group_kmsc(b).mixGam_falling)
        %hold on;
        h(b) = qtask_plotKm_groupAnalysis(group_kmsc(b).mixGam_falling(i).kmsc,titleStr);
        %hold off;
    end

   
end


%CHECK
%group_auc
%group_kmsc


%print average AUC for each condition in each block and create a bar graph
plot_matrix = zeros(nBks, 2);
figure;
for b = 1:nBks
    fprintf(' \n');
    fprintf('    Mean AUC for Block %d mixGam_rising = %2.3f \n',b, mean(group_auc(b).mixGam_rising));
    fprintf('    Mean AUC for Block %d mixGam_falling = %2.3f \n',b, mean(group_auc(b).mixGam_falling));
    
    plot_matrix(b,1) = mean(group_auc(b).mixGam_rising);
    plot_matrix(b,2) = mean(group_auc(b).mixGam_falling);
    
end

bar(plot_matrix)
ylim([0 15]);
legend('Rising', 'Falling');
legend('boxoff');
ax = gca;
ax.YTick = [0:2:14];
title('Group Average AUC', 'FontSize', 18);
ylabel('AUC', 'FontSize', 14);
xlabel('Blocks', 'FontSize', 14);


end


% Subfunction to organize subject data by condition block
function [subInfo, d] = formatData(groupData, numSubj)

% --- ORGANIZE DATA ---
d = struct(); % create a new struct to organize data by condition block
subInfo = struct(); % create a new struct to organize subject info

% for each subject ...
for i = 1:numSubj
    
    bkIdx = [groupData(i).data.trialData.blockNum]';  % block indices for subject 'i'
    nBks = max(bkIdx);  
    
    % fill in fields for 'd'
    for b = 1:nBks  % for each block ...
        %following code is borrowed from 'quickLook_kmsc2.m' by Joe McGuire (with minor changes to accomodate this group dataset)
        idx = bkIdx==b;
        
        d(b).trials(i).trialNum = (1:sum(idx));  %organize the number of trials within each block for each subject
        
        if isfield(groupData(i).data.trialData,'itiKeypresses') % one subject lacks iti keypress data
            d(b).trials(i).itiKeypressTimes = {groupData(i).data.trialData(idx).itiKeypresses}';
            d(b).trials(i).anyItiKeypress = cellfun(@any,d(b).trials(i).itiKeypressTimes,'UniformOutput',true); % logical vector
        end
        if isfield(groupData(i).data.trialData,'trialKeypresses') % if there is an active condition
            d(b).trials(i).trialKeypressTimes = {groupData(i).data.trialData(idx).trialKeypresses}';
        end
        
        d(b).trials(i).designatedWait = [groupData(i).data.trialData(idx).designatedWait]';
        d(b).trials(i).outcomeWin = [groupData(i).data.trialData(idx).payoff]'~=0;
        d(b).trials(i).outcomeQuit = [groupData(i).data.trialData(idx).payoff]'==0;
        d(b).trials(i).payoff = [groupData(i).data.trialData(idx).payoff]';
        d(b).trials(i).startTime = [groupData(i).data.trialData(idx).initialTime]';
        d(b).trials(i).rewardTime = [groupData(i).data.trialData(idx).rwdOnsetTime]';
        d(b).trials(i).latency = [groupData(i).data.trialData(idx).latency]';
        d(b).trials(i).rewardRT = d(b).trials(i).latency - d(b).trials(i).rewardTime;
        d(b).trials(i).outcomeTime = [groupData(i).data.trialData(idx).outcomeTime]';
        d(b).trials(i).totalEarned = [groupData(i).data.trialData(idx).totalEarned]';
    end
    
    % fill in fields for 'subInfo'
    subInfo(i).distribs = groupData(i).data.dataHeader.distribs;
    subInfo(i).id = groupData(i).data.dataHeader.id;
    subInfo(i).points = 0; % initialize as 0
    for b = 1:nBks
        subInfo(i).points = subInfo(i).points + d(b).trials(i).totalEarned(end);
    end
    subInfo(i).money = subInfo(i).points/100;
    
end

end



% Subfunction removing 0's from group_auc and group_kmsc
function [group_auc, group_kmsc] = kmsc_GroupFormat(group_auc, group_kmsc, numSubj)





end

    





% --- CREATE ANALYSIS PLOTS ---
%

% Boxplot of reaction times




    
    






