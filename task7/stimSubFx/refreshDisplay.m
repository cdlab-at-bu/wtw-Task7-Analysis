function [flipTime] = refreshDisplay(wid,bkgd,rects,display)
% places stimuli on the screen
% trial-specific parameters are in the struct display

% clear the screen
Screen('FillRect',wid,bkgd);

% token
tokenColor.low = display.tokenColor;
tokenColor.high = [100 100 250];
if display.tokenPresent
    tokRect = rects.token;
    tokBorder = rects.tokenBorder;
    tokColor = tokenColor.(display.tokenState);
    Screen('FillOval',wid,255,tokBorder);
    Screen('FillOval',wid,tokColor,tokRect);
    points = display.tokenValue;
    switch display.currency
        case 'money', tokText = sprintf('%d%c',points,162);
        case 'points', tokText = sprintf('%d',points);
    end
    
    % if points<10, tokText = [' ',tokText]; end % pad with initial space
    tokVCen = mean([tokRect(2),tokRect(4)]);
    tokHCen = mean([tokRect(1),tokRect(3)]);
    Screen('TextSize',wid,rects.txtsize_token);
    boundRect = Screen('TextBounds',wid,tokText);
    DrawFormattedText(wid,tokText,tokHCen-boundRect(3)/2,tokVCen-boundRect(4)/2,255);

    % 'sold' message
    if display.soldMsg
        msg = 'SOLD';
        Screen('TextSize',wid,rects.txtsize_sold);
        DrawFormattedText(wid,msg,'center',rects.soldY,[255,50,50]);
    end
end

% progress bar for elapsed time within trial
timeColor = [200, 200, 200];
% frame for progress bar
Screen('FillRect',wid,0,rects.timeBarBorder);
Screen('FillRect',wid,bkgd,rects.timeBar);
    %%%% OPTIONAL: add hash marks to mark possible reward times
    % Screen('FillRect',wid,0,rects.timeBarHashRects);
% progress bar itself
timeBar = rects.timeBar;
timeBar(3) = timeBar(1) + display.trialTimeBar;
Screen('FillRect',wid,timeColor,timeBar);


% button, point total, and time remaining
% button (always present)
% buttonMsg = 'Press space to sell.';
% buttonColor = 150; % normal color
% buttonBorder = 20;
% buttonTextCol = 0;
% if display.soldMsg
%     buttonColor = 30; % color if just pressed
%     buttonBorder = 200;
%     buttonTextCol = 255;
% end
% Screen('FillRect',wid,buttonBorder,rects.buttonBorder);
% Screen('FillRect',wid,buttonColor,rects.button);
% Screen('TextSize',wid,30);
% DrawFormattedText(wid,buttonMsg,'center',rects.buttonMsgY,buttonTextCol,buttonColor);


% earnings
Screen('TextSize',wid,rects.txtsize_msg);
switch display.currency
    case 'money', earningsStr = sprintf(rects.earningsStr,display.totalWon/100);
    case 'points', earningsStr = sprintf(rects.earningsStr,display.totalWon);
end
DrawFormattedText(wid,earningsStr,rects.earningsMsgXY(1),rects.earningsMsgXY(2),255);

% digital display of time left in block
Screen('TextSize',wid,rects.txtsize_msg);
timeStr = sprintf(rects.timeStr,floor(display.timeLeft/60),floor(mod(display.timeLeft,60)));
DrawFormattedText(wid,timeStr,rects.timeMsgXY(1),rects.timeMsgXY(2));

% show the screen
flipTime = Screen('Flip',wid);







