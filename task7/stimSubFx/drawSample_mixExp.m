function [thisDelay,thisReward,seq] = drawSample_mixExp(distrib,seq)
% subfunction to draw a delay duration and reward magnitude
% for mixture-of-exponentials environments
% generates a sample from next quantile of the designated distribution
% timing parameters are specified within this function

% possible reward magnitudes
rwdLarge = 8;
rwdSmall = -1;

% timing parameters for exponentials
muFast = 2;
muSlow = 8; % also used for the practice duration

% timing parameters for gamma
kFast = 2;
thetaFast = 2;
kSlow = 6;
thetaSlow = 2;

truncPt = 30;

% control the sequential structure of sampling
nUnique = 8; % number of quantiles to sequence
[nextItem, seq] = seqAppend(seq,nUnique);

% nextItem is a value from 1 to 8. Values 1-4 correspond to the quartiles
% of the fast exponential distribution, and 

% identify the distribution
switch distrib

    case 'practice'
        % for practice, just a fixed delay set to muSlow, and large reward
        thisDelay = muSlow;
        thisReward = rwdLarge;
        return;
              
%     case 'mixExp_rising'
%         % determine the current component and reward magnitude
%         if nextItem<5 % faster component
%             thisReward = rwdSmall;
%             thisMu = muFast;
%         else % slower component
%             thisReward = rwdLarge;
%             thisMu = muSlow;
%         end
%         
%     case 'mixExp_falling'
%        % determine the current component and reward magnitude
%         if nextItem<5 % faster component
%             thisReward = rwdLarge;
%             thisMu = muFast;
%         else % slower component
%             thisReward = rwdSmall;
%             thisMu = muSlow;
%         end
        
    case 'mixGam_rising'
        % determine the current component and reward magnitude
        if nextItem<5 % faster component
            thisReward = rwdSmall;
            thisK = kFast;
            thisTheta = thetaFast;
        else % slower component
            thisReward = rwdLarge;
            thisK = kSlow;
            thisTheta = thetaSlow;
        end
        
    case 'mixGam_falling'
       % determine the current component and reward magnitude
        if nextItem<5 % faster component
            thisReward = rwdLarge;
            thisK = kFast;
            thisTheta = thetaFast;
        else % slower component
            thisReward = rwdSmall;
            thisK = kSlow;
            thisTheta = thetaSlow;
        end
        
    otherwise
        error('Unrecognized distribution "%s"',distrib);
end

 % sample the current delay
thisQuartile = mod(nextItem-1,4)+1; % 1-4 and 5-8 each map to 1-4
thisPerc = (thisQuartile + rand - 1)/4;
% thisDelay = expinv(thisPerc,thisMu);
thisDelay = gaminv(thisPerc,thisK,thisTheta);
thisDelay = min(thisDelay,truncPt); % apply truncation




