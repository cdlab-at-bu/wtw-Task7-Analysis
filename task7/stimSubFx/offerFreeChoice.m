function [chosenBlock] = offerFreeChoice(params,rects,blockMins,trialsFx)
% present a free choice of which task to repeat for the final block

% unpack some parameters
wid = params.wid;
bkgd = params.bkgd;

% set the description of blocks 1 and 2
taskDescrip = cell(1,2);
for bkIdx = 1:2
    if isequal(trialsFx{bkIdx},@showTrials) % passive task
        taskDescrip{bkIdx} = 'waiting';
    elseif isequal(trialsFx{bkIdx},@showTrials_key2) % active task
        taskDescrip{bkIdx} = 'key pressing';
    end
end

% display text
Screen('TextSize',wid,rects.txtsize_msg);
msg = {};
msg{1} = sprintf('For the final %d-minute block, you may choose whether to repeat the task from Block 1 (%s) or Block 2 (%s).',...
    blockMins,taskDescrip{1},taskDescrip{2});
msg{2} = sprintf('Press "1" to repeat the task from Block 1.\nPress "2" to repeat the task from Block 2.');
txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
resp = showMsg_return(wid,bkgd,txt,'12');

% interpret the response to pass back to main function
% beware it may be either a string or cell array, may contain multiple
% characters
chosenBlock = nan;
if any(ismember(resp,'1'))
    chosenBlock = 1;
elseif any(ismember(resp,'2'))
    chosenBlock = 2;
end

% second pre-block screen
msg = {};
msg{1} = 'Press the spacebar to begin.';
txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
showMsg(wid,bkgd,txt);



