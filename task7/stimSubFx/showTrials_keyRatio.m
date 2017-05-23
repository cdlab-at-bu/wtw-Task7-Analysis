function [trialData, params, display] = showTrials_key(params,rects,display,trialData)
% subfunction to display 1 run of trials
% showTrials_key is a variant that requires active responding in order to
% persist. 

% unpack parameters
wid = params.wid;
bkgd = params.bkgd;
sessSecs = params.sessSecs;
datarow = params.datarow;
trialLimit = params.trialLimit;
block = params.bkIdx;
datafid = params.datafid;
datafid_keytimes = params.datafid_keytimes;
% special params for the keypress variant
secPerKey = 1/6; % increment in nominal elapsed time per response
timeout = 0.5; % length of pause (in s) that is interpreted as a quit

% initial display settings
display.timeLeft = sessSecs;
display.tokenValue = params.payoffLo;
display.tokenState = 'low';
display.soldMsg = false;
display.tokenPresent = false;
display.trialTimeBar = 0; % pixels in the progress bar

% show the initial screen
refreshDisplay(wid,bkgd,rects,display);
changeDisp = false; % register whether anything has changed on each loop
flipTimeIsRwdTime = false; % initialize

% show trials
% each trial consists of the following 3 phases:
%   feedback, iti, waiting
trialNum = 0;
seq = [];
trialPhase = 'iti';
phaseOnset = GetSecs;
runOnset = phaseOnset;
keyDown = true; % keypress to start the block should not carry over and be called an ITI response
trialKeypressTimes = [];
trialTimeElapsed = 0;
while ((GetSecs-runOnset)<sessSecs) && (trialNum<=trialLimit) % proceed continuously until time is up

    % determine how far we are into the current trial phase
    timeNow = GetSecs; % timeNow is used below instead of multiple GetSecs calls
    eventLatency = timeNow-phaseOnset;
    
    % if the ITI is ending, begin a trial
    % change phase: "iti" -> "waiting"
    if strcmp(trialPhase,'iti') && (timeNow-phaseOnset)>display.iti/2
        trialPhase = 'waiting';
        trialTimeElapsed = 0; % the within-trial progress bar
        trialKeypressTimes = [];
        phaseOnset = timeNow;
%         waitDuration = delayList(1); % waiting time on this trial
%         delayList(1) = []; % (cycle forward in the list)
        [waitDuration, seq] = drawSample(params.distrib,seq); % waiting time on this trial
        trialNum = trialNum + 1;
        if trialNum>trialLimit, continue; end % prevent final screen update if exiting
        initialTime = timeNow-runOnset; % exact time elapsed - for later logging
        display.tokenPresent = true;
        display.tokenValue = params.payoffLo;
        display.tokenState = 'low';
        rwdTime = nan; % initialize reward onset time
        changeDisp = true;

    elseif strcmp(trialPhase,'waiting')

        % if the token has matured, update it
        if trialTimeElapsed>waitDuration && strcmp(display.tokenState,'low')
            display.tokenValue = params.payoffHi;
            display.tokenState = 'high';
            changeDisp = true;
            flipTimeIsRwdTime = true; % next screen redraw is the reward onset time
        end
        
        % monitor key presses
        %%% *Add a minimum inter-response interval, say 100 ms?
        if ~keyDown && detectResponse(params.respChar) % key was just pressed
            trialKeypressTimes = [trialKeypressTimes, timeNow-phaseOnset]; %#ok<AGROW>
            keyDown = true;
            trialTimeElapsed = trialTimeElapsed + secPerKey;
        elseif keyDown && ~detectResponse(params.respChar) % key was just released
            keyDown = false;
        end

        % if "sell" has been selected, end the trial
        % i.e., if there has been an inter-resp delay longer than timeout
        %   after at least one response has been made.
        % change phase: "waiting" -> "feedback"
        % a line is added to the data record here
        if numel(trialKeypressTimes)>0 && ((timeNow-phaseOnset)-trialKeypressTimes(end))>timeout

            keyDown = true;
            trialPhase = 'feedback';
            phaseOnset = timeNow;
            earnings = display.tokenValue;
            sellTime = timeNow-runOnset;
            display.totalWon = display.totalWon + earnings;
            display.soldMsg = true;
            changeDisp = true;

            % save data to matlab structure
            datarow = datarow+1; % number for the new trial
            trialData(datarow).blockNum = block;
            trialData(datarow).trialNum = trialNum;
            trialData(datarow).initialTime = initialTime;
            trialData(datarow).trialKeypresses = trialKeypressTimes;
                % holds latencies (relative to the onset of feedback) of
                % any keypress responses during the feedback/iti period
                % preceding this trial. Usually this will be an empty 
                % matrix.
            trialData(datarow).designatedWait = waitDuration;
            trialData(datarow).rwdOnsetTime = rwdTime; % will sometimes be nan
            trialData(datarow).latency = eventLatency; % "sell" response time, relative to trial onset
            trialData(datarow).outcomeTime = sellTime; % "sell" time since start of block
            trialData(datarow).payoff = earnings; % current trial payoff
            trialData(datarow).totalEarned = display.totalWon;
            
            % write data in csv format
            % columns: 1=block, 2=trialnum, 3=trial start time, 
            % 4=number of keypresses, 5=wait required,
            % 6=reward time, 7=time waited, 8=sell time, 9=trial earnings
            % 10=total earnings
            fprintf(datafid,'%d,%d,%1.3f,%d,%1.3f,%1.3f,%1.3f,%1.3f,%d,%d\n',...
                block,trialNum,initialTime,numel(trialKeypressTimes),...
                waitDuration,rwdTime,eventLatency,sellTime,earnings,...
                display.totalWon);
            % write key-press times to a separate file
            fprintf(datafid_keytimes,'%d,%d,',block,trialNum);
            fprintf(datafid_keytimes,'%1.3f,',trialKeypressTimes);
            fprintf(datafid_keytimes,'\n');

        end

    % end of the feedback phase
    % change phase: "feedback" -> "iti"
    elseif strcmp(trialPhase,'feedback') && (timeNow-phaseOnset)>display.iti/2
        trialPhase = 'iti';
        phaseOnset = timeNow;
        display.tokenPresent = false;
        display.tokenValue = [];
        display.tokenState = 'low';
        display.soldMsg = false;
        changeDisp = true;
    end

    trialTimeBar = ceil(rects.timeBarMax*trialTimeElapsed/50); % full bar length is 50 sec
    if display.trialTimeBar~=trialTimeBar
        display.trialTimeBar = trialTimeBar;
        changeDisp = true;
    end

    % digital display of time remaining
    timeLeft = ceil((runOnset+sessSecs)-timeNow);
    if display.timeLeft~=timeLeft
        display.timeLeft = timeLeft;
        changeDisp = true;
    end

    % display any updates to the display on this cycle
    if changeDisp
        changeDisp = false;
        flipTime = refreshDisplay(wid,bkgd,rects,display);
        if flipTimeIsRwdTime
            rwdTime = flipTime - phaseOnset;
            flipTimeIsRwdTime = false;
        end
    end

    WaitSecs(.001);

end

params.datarow = datarow;
    


