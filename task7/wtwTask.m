function [] = wtwTask()
% presents the wtw experiment

try
    
    % skipping sync tests
    % Screen('Preference', 'SkipSyncTests', 1);
    % relax sync tests, allow SD of 3 ms rather than 1 ms
    Screen('Preference','SyncTestSettings',0.003);
    
    %%% modifiable parameters
    % timing
    sessMins = 10; % block duration in minutes: normally 10
    display.iti = 1; % intertrial interval in sec
    % payoff contingencies
    params.currency = 'money'; % set to 'money' or 'points'
    params.payoffHi = nan; % *** this is randomized in drawSample_mixExp.m
    params.payoffLo = 0; % cents
    % response key (only one required)
    params.respChar = {'space'};
    % token colors
    % this order is also fixed. If order of timing conditions is switched,
    % order of colors should be left the same. 
    blockTokenColor = {'green', 'purple', 'brown', 'pink'};
    
    %%% special display prefs if on windows OS
    if IsWin
        % modify text display settings
        % set font to helvetica (default is courier new)
        Screen('Preference', 'DefaultFontName', 'Helvetica');
        % set style to normal (=0) (default is bold [=1])
        Screen('Preference', 'DefaultFontStyle', 0);
    end
    
    % set path
    path(path,'stimSubFx');
    
    % name datafile
    [dataFileName,dataHeader] = gatherSubInfo('wtw-work-7',2);
    params.datafid = fopen([dataFileName,'.txt'],'w');
    params.datafid_keytimes = fopen([dataFileName,'_keytimes.txt'],'w'); % file to log keypress times
    params.pracfid = fopen([dataFileName,'_prac.txt'],'w');
    
    % set parameters based on the counterbalance condition
    % (timing distributions are defined in drawSample.m)
    switch dataHeader.cbal
        case 1
            timingDistribs = {'mixGam_rising', 'mixGam_falling', 'mixGam_rising', 'mixGam_falling'};
            trialsFx = {@showTrials, @showTrials, @showTrials, @showTrials};
        case 2
            timingDistribs = {'mixGam_falling', 'mixGam_rising', 'mixGam_falling', 'mixGam_rising'};
            trialsFx = {@showTrials, @showTrials, @showTrials, @showTrials};
        otherwise
            error('Unexpected value for counterbalance condition.');
    end
    
    % open the screen
    bkgd = 80; % set shade of gray for screen background
    [wid,origin,dataHeader] = manageExpt('open',dataHeader,bkgd); % standard initial tasks
    
    % write a file with header data
    hdr_fid = fopen([dataFileName,'_hdr.txt'],'w');
    fprintf(hdr_fid,'ID: %s\n',dataHeader.id);
    fprintf(hdr_fid,'cbal: %s\n',num2str(dataHeader.cbal));
    fprintf(hdr_fid,'bk1 distrib: %s\n',timingDistribs{1});
    fprintf(hdr_fid,'bk2 distrib: %s\n',timingDistribs{2});
    fprintf(hdr_fid,'bk1 trial function: %s\n',func2str(trialsFx{1}));
    fprintf(hdr_fid,'bk2 trial function: %s\n',func2str(trialsFx{2}));
    fprintf(hdr_fid,'randSeed: %16.16f\n',dataHeader.randSeed);
    fprintf(hdr_fid,'sessionTime: %s\n',num2str(dataHeader.sessionTime));
    fclose(hdr_fid);
    
    % set screen locations for stimuli and buttons
    rects = setRects(origin,wid,params);
    
    % initialize display
    HideCursor;
    params.wid = wid;
    params.bkgd = bkgd;
    display.totalWon = 0; % initial value
    display.currency = params.currency; 
    params.sessSecs = sessMins * 60;
    
    % colors to be used
    % tokColors.prac = [0, 0, 0];
    tokColors.green = 50+[0, 100, 0];
    tokColors.purple = 50+[80, 0, 100];
    tokColors.brown = 50+[100, 60, 0];
    tokColors.pink = 50+[130, 50, 60];
    
    % initialize data logging structure
    dataHeader.distribs = timingDistribs; % log this subject's timing distribution
    trialData = struct([]);
    params.datarow = 0;
    
    % present individual blocks
    nBks = length(trialsFx); % number of blocks to present
    for bkIdx = 1:nBks
    
        % set block-specific parameters
        params.bkIdx = bkIdx;
        params.distrib = timingDistribs{bkIdx};
        display.tokenColor = tokColors.(blockTokenColor{bkIdx});
        
        % show instructions
        if bkIdx==1
            instrucBlock(params,rects,display,sessMins,nBks,bkIdx);
        end
        
        % show the trials
        params.trialLimit = inf;
        [trialData, params, display] = trialsFx{bkIdx}(params,rects,display,trialData);
        
        % save data
        save(dataFileName,'dataHeader','trialData');
        
        % intermediate instructions screen
        % (shown after the non-final block[s])
        if bkIdx<nBks
            Screen('TextSize',wid,rects.txtsize_msg);            
            msg = sprintf('Block %d complete.\n\nIn the next block, the timing and structure of the task may change.\n\nPress the spacebar to begin block %d.',...
                bkIdx,bkIdx+1);
            showMsg(wid,bkgd,msg);
        end
        
    end % loop over blocks
    
%     % offer a free choice for the third block
%     lastBlockMins = 5;
%     chosenBlock = nan;
%     while isnan(chosenBlock)
%         chosenBlock = offerFreeChoice(params,rects,lastBlockMins,trialsFx);
%     end
%     % log the response
%     dataHeader.chosenBlock = chosenBlock;
%     choice_fid = fopen([dataFileName,'_freeChoice.txt'],'w');
%     fprintf(choice_fid,'Chosen block: %d\n',chosenBlock);
%     fclose(choice_fid);
%     % set block-specific parameters
%     params.bkIdx = bkIdx+1;
%     params.distrib = timingDistribs{chosenBlock};
%     display.tokenColor = tokColors.(blockTokenColor{chosenBlock});
%     params.sessSecs = lastBlockMins * 60;
%     % present the final block
%     params.trialLimit = inf;
%     [trialData, params, display] = trialsFx{chosenBlock}(params,rects,display,trialData); %#ok<ASGLU>
%     % save data
%     save(dataFileName,'dataHeader','trialData');
    
    % show the final screen
    switch params.currency
        case 'money', earningsStr = sprintf('Total earned: $%2.2f.',display.totalWon/100);
        case 'points', earningsStr = sprintf('Total earned: %d points.',display.totalWon);
    end
    Screen('TextSize',wid,rects.txtsize_msg);
    msg = sprintf('Complete!\n%s',earningsStr);
    showMsg(wid,bkgd,msg,'q');
    
    % close the expt
    manageExpt('close'); % note: this closes any text files open for writing
    
    % print some information
    fprintf('\n\nParticipant: %s\n',dataHeader.dfname);
    fprintf('%s\n\n',earningsStr);
    
catch ME
    
    % close the expt
    disp(getReport(ME));
    fclose('all');
    manageExpt('close');
    
end % try/catch loop

    

    


