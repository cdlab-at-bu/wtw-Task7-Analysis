function [delay,quantile] = drawSample(distrib,quantile)
% generates a sample from next quantile of the designated distribution
% timing parameters are specified within this function
% distrib may be 'gp' or 'unif'
% quantile is a vector (may be empty)

nQuants = 8; % number of partitions to sample w/o replacement
if isempty(quantile), quantile = randperm(nQuants); end
q = quantile(1);
quantile(1) = [];

switch distrib
        
    case 'gpTrunc'
        
        % gp distribution, with samples above the truncation point placed
        % AT the truncation point.
        
        params = {4, 2, 0};
        truncPt = 40;
        x = (q-1+rand)/nQuants;
        delay = icdf('gp',x,params{:});
        if delay>truncPt, delay = truncPt; end
        
    case 'unif'
        
        params = {0, 20};
        x = (q-1+rand)/nQuants;
        delay = icdf('unif',x,params{:});
        
        
    case 'fixed10' % used for practice
        
        delay = 10;
        
end


