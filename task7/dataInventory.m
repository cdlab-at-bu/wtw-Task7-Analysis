function [] = dataInventory()
% counts the number of participants per condition so far. 

% get names of all data files in the data directory
d = dir('data/*.mat');

% total n
n = numel(d);
fprintf('Total n = %d\n',n);

% initialize variables
all_cbal = nan(n,1);
all_nTrials = nan(n,1);

% load each file individually
for i = 1:n
    dfile = load(fullfile('data',d(i).name));
    all_cbal(i) = dfile.dataHeader.cbal;
    all_nTrials(i) = numel(dfile.trialData);
    assert(dfile.trialData(end).blockNum==4,'%s does not have 4 blocks',d(i).name);
    assert(dfile.trialData(end).outcomeTime>(9*60),'%s has a final block shorter than 9 min',d(i).name);
end % loop over individual data files

% summarize results
cbalValues = unique(all_cbal);
for i = 1:numel(cbalValues)
    thisValue = cbalValues(i);
    fprintf('  cbal %d: n = %d\n',thisValue,sum(all_cbal==thisValue));
end % loop over cbal values

% summarize number of trials per subject
% to check for data file completeness
fprintf('  trial count range: %d to %d\n',min(all_nTrials),max(all_nTrials));
ecdf(all_nTrials);

