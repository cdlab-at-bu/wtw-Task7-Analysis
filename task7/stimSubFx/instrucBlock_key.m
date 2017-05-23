function [] = instrucBlock_key(params,rects,display,blockMins,nBks,bkIdx)
% presents instructions screens for qTask
%
% bkIdx equals 1 or 2
% if bkIdx==1, present full task instructions
% if bkIdx==2, just present minimal instructions that say the task is
% continuing.

% unpack some parameters
wid = params.wid;
bkgd = params.bkgd;

% set the key(s) that the experimenter will press to advance instrucs
respKey = 'q';

% set params for practice trials
params.trialLimit = 1; % always do just one trial at a time
trialData = struct([]);
params.datarow = 0;
params.datafid = params.pracfid;
params.bkIdx = 0;
params.distrib = 'practice';
switch params.currency
    case 'money', params.unit = 'cent';
    case 'points', params.unit = 'point';
end

switch bkIdx
    case 1

        % instruc screen 1
        Screen('TextSize',wid,rects.txtsize_msg);
        if params.payoffLo==1, lowValPlural = ''; else lowValPlural = 's'; end % format messages flexibly
        msg = {};
        msg{1} = sprintf('You will see a token on the screen. Tokens can be sold for %s.',params.currency);
        msg{2} = sprintf('Each token is worth %d %s%s at first. You can increase its value by repeatedly pressing the spacebar. After some time, the token will "mature" and be worth more.',...
            params.payoffLo,params.unit,lowValPlural);
        msg{3} = 'Now try a practice round. Keep pressing until the token matures, then stop pressing to sell it.';
        txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
        showMsg(wid,bkgd,txt,respKey);

        % demo trial 1 -- practice waiting
        showTrials_key2(params,rects,display,trialData);

        % instruc screen 2
        Screen('TextSize',wid,rects.txtsize_msg);
        msg = {};
        msg{1} = 'Good. Let''s do it again. Keep pressing the spacebar until the token matures, then sell it.';
        txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
        showMsg(wid,bkgd,txt,respKey);

        % demo trial 2 -- practice waiting
        showTrials_key2(params,rects,display,trialData);

        % instruc screen 3
        Screen('TextSize',wid,rects.txtsize_msg);
        msg = {};
        msg{1} = 'You will have a limited amount of time to play.';
        msg{2} = 'If a token is taking too long, you might want to sell it before it matures in order to move on to a new one.';
        msg{3} = 'Next, practice selling the token before it matures.';
        txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
        showMsg(wid,bkgd,txt,respKey);

        % demo trial 3 -- practice waiting
        showTrials_key2(params,rects,display,trialData);

        % instruc screen 4
        Screen('TextSize',wid,rects.txtsize_msg);
        msg = {};
        msg{1} = 'Good. Let''s do it again. Practice selling the token before it matures.';
        txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
        showMsg(wid,bkgd,txt,respKey);

        % demo trial 4 -- practice waiting
        showTrials_key2(params,rects,display,trialData);

        % instruc screen 5
        Screen('TextSize',wid,rects.txtsize_msg);
        msg = {};
        if nBks>1 % instrucs differ for 1 block or multiple blocks.
            txt1 = sprintf('In the first block you will have %d minutes to play.',blockMins);
        else
            txt1 = sprintf('You will have %d minutes to play.',blockMins);
        end
        switch params.currency
            case 'money', txt2 = 'At the end of the experiment you will be paid what you earned, rounded to the next 25 cents. ';
            case 'points', txt2 = '';
        end
        msg{1} = sprintf('%s Your goal is to earn the most %s you can in the available time. %s',...
            txt1,params.currency,txt2);
        msg{2} = 'You should sell tokens quickly when they mature, since their value will not change again.';
        msg{3} = 'Any questions?';
        txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
        showMsg(wid,bkgd,txt,respKey);
        
    case 2
        
        % instruc screen 1
        Screen('TextSize',wid,rects.txtsize_msg);
        msg = {};
        msg{1} = 'In the next block, instead of just waiting, you will need to press the spacebar repeatedly. If you keep pressing, the token will mature after some amount of time.';
        msg{2} = 'Try a practice round. Keep making keypresses until the token matures, then stop pressing to sell it.';
        txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
        showMsg(wid,bkgd,txt,respKey);

        % demo trial 1 -- practice waiting
        showTrials_key2(params,rects,display,trialData);

        % instruc screen 2
        Screen('TextSize',wid,rects.txtsize_msg);
        msg = {};
        msg{1} = 'Good. Let''s do it again. Keep pressing the spacebar until the token matures, then sell it.';
        txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
        showMsg(wid,bkgd,txt,respKey);

        % demo trial 2 -- practice waiting
        showTrials_key2(params,rects,display,trialData);

        % instruc screen 3
        Screen('TextSize',wid,rects.txtsize_msg);
        msg = {};
        msg{1} = 'Like before, you can sell the token before it matures if you think it is taking too long.';
        msg{2} = 'In the next trial, practice selling the token before it matures.';
        txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
        showMsg(wid,bkgd,txt,respKey);

        % demo trial 3 -- practice waiting
        showTrials_key2(params,rects,display,trialData);

        % instruc screen 4
        Screen('TextSize',wid,rects.txtsize_msg);
        msg = {};
        msg{1} = 'Good. Let''s do it again. Practice selling the token before it matures.';
        txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
        showMsg(wid,bkgd,txt,respKey);

        % demo trial 4 -- practice waiting
        showTrials_key2(params,rects,display,trialData);

        % instruc screen 5
        Screen('TextSize',wid,rects.txtsize_msg);
        msg = {};
        txt1 = sprintf('You will have %d minutes to play.',blockMins);
        msg{1} = sprintf('%s Like before, your goal is to earn the most %s you can in the available time.',txt1,params.currency);
        msg{2} = 'Any questions?';
        txt = sprintf('%s\n\n',msg{:}); txt((end-1):end) = [];
        showMsg(wid,bkgd,txt,respKey);
        
end






