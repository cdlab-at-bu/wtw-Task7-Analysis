function [] = optGUT2()
% normative analysis for a given set of parameters in the mixed exponential
% schedule.

% parameters
k_early = 2;
theta_early = 2;
k_late = 6;
theta_late = 2;
trunc = 30;
iti = 1;
rwdLo = -1;
rwdHi = 8;
duration = 60*40; % in s

tGrid = 0:0.5:trunc;
earlyCDF = @(t) gamcdf(t,k_early,theta_early);
earlyInv = @(p) gaminv(p,k_early,theta_early);
lateCDF = @(t) gamcdf(t,k_late,theta_late);
lateInv = @(p) gaminv(p,k_late,theta_late);

% truncated CDFs on the discrete axis
cdf_fast = earlyCDF(tGrid);
cdf_fast(end) = 1; % apply truncation
cdf_slow = lateCDF(tGrid);
cdf_slow(end) = 1; % apply truncation

% plot a histogram for the density function of the fast distribution
figure(1); clf;
hist_fast = diff(cdf_fast);
hist_slow = diff(cdf_slow);
xvals = tGrid(2:end) - tGrid(2)/2;
plot(xvals,hist_fast,'r-','LineWidth',3);
hold on;
plot(xvals,hist_slow,'b-','LineWidth',3);
ylim = get(gca,'YLim');
ylim(1) = 0;
set(gca,'box','off','fontsize',20,'YLim',ylim);
xlabel('Elapsed time (s)');
ylabel('Approx PDFs');

% plot CDFs
figure(2); clf;
plot(tGrid,cdf_fast,'r-','LineWidth',3);
hold on;
plot(tGrid,cdf_slow,'b-','LineWidth',3);
set(gca,'box','off','fontsize',20,'YLim',[0,1]);
xlabel('Elapsed time (s)');
ylabel('CDFs');

% plot of the probability, over time, that this trial is slow.
figure(3); clf;
pSlow = (1 - cdf_slow) ./ (2 - cdf_fast - cdf_slow);
plot(tGrid,pSlow,'k-','LineWidth',3);
set(gca,'box','off','FontSize',16,'YLim',[0,1]);
xlabel('Elapsed time');
ylabel('Pr(Slow)')

% plot payoff curves
payoffCurve.hiFast = getPayoffCurve(tGrid, iti, earlyCDF, earlyInv, lateCDF, lateInv, rwdHi, rwdLo);
payoffCurve.hiSlow = getPayoffCurve(tGrid, iti, earlyCDF, earlyInv, lateCDF, lateInv, rwdLo, rwdHi);

figure(4); clf;
h1 = plot(tGrid,duration*payoffCurve.hiFast./100,'r','LineWidth',3);
hold on;
h2 = plot(tGrid,duration*payoffCurve.hiSlow./100,'b','LineWidth',3);
set(gca,'box','off','fontsize',20);
xlabel('Giving-up time (s)');
ylabel('Total pay (dollars)');
legend([h1,h2],'hiFast','hiSlow');

condNames = {'hiFast', 'hiSlow'};
for cIdx = 1:2
    thisName = condNames{cIdx};
    [maxRate, maxIdx] = max(payoffCurve.(thisName));
    bestGUT = tGrid(maxIdx);
    patientRate = payoffCurve.(thisName)(end);
    fprintf('Results for the %s condition:\n',thisName)
    fprintf('  best GUT: %1.2f s\n',bestGUT);
    fprintf('  max earnings: $%1.2f in %1.1f minutes\n',maxRate*duration/100,duration/60);
    fprintf('  beats full persistence by $%1.2f (%1.1f%%)\n',...
        (maxRate-patientRate)*duration/100,100*(maxRate-patientRate)/patientRate);
end

end % main function 



% subfunction to return one policy payoff curve
function [payoffCurve] = getPayoffCurve(tGrid, iti, earlyCDF, earlyInv, lateCDF, lateInv, rwdFast, rwdSlow)

cdf_fast = earlyCDF(tGrid);
cdf_fast(end) = 1; % apply truncation
cdf_fast = 0.5 * cdf_fast; % adjust for mixing fraction
cdf_slow = lateCDF(tGrid);
cdf_slow(end) = 1; % apply truncation
cdf_slow = 0.5 * cdf_slow; % adjust for mixing fraction

% expected reward per trial, for each giving-up time
expReward = rwdFast*cdf_fast + rwdSlow*cdf_slow;

% mean delay if rewarded 
timeIfRwd_slow = zeros(size(tGrid)); % slow trials
timeIfRwd_fast = zeros(size(tGrid)); % fast trials
    % need to sample for this one.
for i = 2:numel(tGrid)
    this_t = tGrid(i);
    this_F = earlyCDF(this_t);
    timeIfRwd_fast(i) = mean(earlyInv(this_F*rand(10000,1)));
    this_F = lateCDF(this_t);
    timeIfRwd_slow(i) = mean(lateInv(this_F*rand(10000,1)));
end

% expected delay per trial, for each giving up time
% terms: (1) delay if rewarded from the fast component, (2) delay if
% rewarded from the slow component, (3) delay if quit or truncated, (4) iti
expDelay = cdf_fast.*timeIfRwd_fast + cdf_slow.*timeIfRwd_slow + tGrid.*(1 - cdf_fast - cdf_slow) + iti;

% expected reward per s
payoffCurve = expReward./expDelay;
payoffCurve(1) = 0; % replace the NaN at GUT=0

end % subfunction getPayoffCurve


