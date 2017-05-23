function [] = ssPlot(trialData,titleStr,ceilVal)
% plots a single subject's trial-by-trial data

isWin = trialData.outcomeWin;
isQuit = trialData.outcomeQuit;

hold on;
% plot win trials
plot(trialData.trialNums(isWin),trialData.designatedWait(isWin),'b.-','LineWidth',1,'Markersize',12);
% plot quit trials
plot(trialData.trialNums(isQuit),trialData.latency(isQuit),'r.-','LineWidth',1,'Markersize',12);
% plot the scheduled reward time for quit trials
ceilingWait = trialData.designatedWait; 

ceilingWait(ceilingWait>ceilVal) = ceilVal;
plot(trialData.trialNums(isQuit),ceilingWait(isQuit),'k.','LineWidth',1,'Markersize',12);
hold off;

% formatting and axis labeling
set(gca,'YLim',[0 ceilVal+1],'FontSize',16,'Box','off');
ylabel('Time (s)');
xlabel('Trial number');
title(titleStr,'Interpreter','none');

% add a legend only if there is at least one trial in each category
if any(isQuit) && any(isWin)
    legend('Success','Quit');
end

