%SyncHist - Compute a histogram on event-synchronized samples (e.g. a PSTH).
%
% Compute a histogram on event-synchronized point-process (e.g. spikes) or
% continuous (e.g. voltages) samples, obtained using the function <a href="matlab:help Sync">Sync</a>.
% Individual values Xi(t) (for trial i and time t) can be averaged or
% summed across trials. Alternatively, complete time-varying distributions
% can also be computed, i.e. this function can compute for each time t the
% distribution of Xi(t) across trials i.
%
%  USAGE
%
%    To sum across trials:
%    [sum,timeBins] = SyncHist(synchronized,indices,'mode','sum',<options>)
%
%    To average across trials (computes a frequency for point processes):
%    [mean,std,conf,timeBins] = SyncHist(synchronized,indices,'mode','mean',<options>)
%    ('conf' = 95% confidence interval for continuous data)
%
%    To compute the full distribution:
%    [distribution,timeBins,valueBins] = SyncHist(synchronized,indices,'mode','dist',<options>)
%
%    synchronized   resynchronized samples (obtained using <a href="matlab:help Sync">Sync</a>)
%    indices        synchronizing event indices (obtained using <a href="matlab:help Sync">Sync</a>)
%    <options>      optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'mode'        type of histogram: 'sum' (default), 'mean' or 'dist'
%     'durations'   durations before and after synchronizing events for each
%                   trial (in s) (default = [-0.5 0.5])
%     'nBins'       total number of time bins (default 100)
%     'type'        either 'linear' or 'circular' (use radians) depending on
%                   the type of data in the raster (default 'linear')
%     'smooth'      standard deviation for Gaussian kernel (default 0, no
%                   smoothing)
%     'hist'        [m M n], lower and upper bounds, and number of bins,
%                   respectively (default [min max 100]) (only for 'dist' mode)
%    =========================================================================
%
%  EXAMPLE 1
%
%    [raster,indices] = Sync(spikes,stimuli);     % compute spike raster data
%    figure;PlotSync(raster,indices);             % plot spike raster
%    [m,t] = SyncHist(raster,indices,'mean');     % compute PSTH
%    figure;bar(t,m);                             % plot PSTH
%
%  EXAMPLE 2
%
%    [vsync,indices] = Sync(velocity,trials);     % make velocity timestamps
%                                                 % relative to trial onsets
%    [d,x,t] = SyncHist(vsync,indices,'dist');    % compute velocity distribution
%                                                 % across trials
%    figure;PlotColorMap(d,1);                    % plot distribution as color map
%
%  SEE
%
%    See also Sync, SyncMap, PlotSync, PETHTransition.

% Copyright (C) 2004-2010 by Michaël Zugaro
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

function [a,b,c,d] = SyncHist(synchronized,indices,varargin)

% Default values
durations = [-0.5 0.5];
nBins = 100;
smooth = 0;
type = 'linear';
hist = [];
a = [];
b = [];
c = [];
d = [];
mode = 'sum';

% Check number of parameters
if nargin < 2 | mod(length(varargin),2) ~= 0,
  error('Incorrect number of parameters (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
end

if isempty(indices) || isempty(synchronized), return; end

% Check parameter sizes
if size(indices,2) ~= 1,
	error('Parameter ''indices'' is not a vector (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
end
if size(indices,1) ~= size(synchronized,1),
	error('Parameters ''synchronized'' and ''indices'' have different lengths (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
end

% Parse parameter list
for i = 1:2:length(varargin),
	if ~ischar(varargin{i}),
		error(['Parameter ' num2str(i+1) ' is not a property (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).']);
	end
	switch(lower(varargin{i})),
		case 'mode',
			mode = lower(varargin{i+1});
			if ~isstring(mode,'sum','mean','dist'),
				error('Incorrect value for property ''mode'' (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
			end

		case 'durations',
			durations = varargin{i+1};
			if ~isdvector(durations,'#2','<'),
				error('Incorrect value for property ''durations'' (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
			end

		case 'nbins',
			nBins = varargin{i+1};
			if ~isdscalar(nBins,'>0'),
				error('Incorrect value for property ''nBins'' (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
			end

		case 'smooth',
			smooth = varargin{i+1};
			if ~isdvector(smooth,'>=0') | length(smooth) > 2,
				error('Incorrect value for property ''smooth'' (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
			end

		case 'hist',
			hist = varargin{i+1};
			if ~isdvector(hist,'#3') | hist(1) > hist(2) | ~isiscalar(hist(3),'>0'),
				error('Incorrect value for property ''hist'' (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
			end

		case 'type',
			type = lower(varargin{i+1});
			if ~isstring(type,'linear','circular'),
				error('Incorrect value for property ''type'' (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
			end

		otherwise,
			error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).']);

	end
end

% Check number of output parameters
switch(mode),
	case 'sum',
		if nargout > 2,
			error('Incorrect number of output parameters (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
		end
	case 'mean',
		if nargout > 4,
			error('Incorrect number of output parameters (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
		end
	case 'dist',
		if nargout > 3,
			error('Incorrect number of output parameters (type ''help <a href="matlab:help SyncHist">SyncHist</a>'' for details).');
		end
end

if size(synchronized,2) == 1,
	% Point process data
	pointProcess = true;
	synchronized(:,2) = 1;
	if isempty(hist),
		hist = [0 max(synchronized(:,2)) 100];
	end
else
	% Continuous data
	pointProcess = false;
	if isempty(hist),
		hist = [min(min(synchronized(:,2:end))) max(max(synchronized(:,2:end))) 100];
	end
end

% Compute histogram
nTrials = max(indices);
start = durations(1);
stop = durations(2);
timeBinSize = (stop - start)/nBins;
timeBins = (start:timeBinSize:stop-timeBinSize)+timeBinSize/2;
binnedTime = Bin(synchronized(:,1),[start stop],nBins,'trim');

if strcmp(type,'circular'),
	range = isradians(synchronized(:,2:end));
	for j = 2:size(synchronized,2),
		synchronized(:,j) = exp(i*synchronized(:,j));
	end
end

switch(mode),

	case 'sum',
		% Smoothed sum
		for j = 2:size(synchronized,2),
			a(:,j-1) = Smooth(Accumulate(binnedTime,synchronized(:,j),nBins),smooth);
		end
		b = timeBins;
		c = [];
	case 'mean',
		if pointProcess,
			% Smoothed mean
			for j = 2:size(synchronized,2),
				a(:,j-1) = Smooth(Accumulate(binnedTime,synchronized(:,j),nBins),smooth)/(nTrials*timeBinSize);
			end
			b = []; % Not yet implemented
			c = []; % Not yet implemented
		else
			% Number of values in each time bin
			n = Accumulate(binnedTime,1,nBins);
			% Smoothed mean
			for j = 2:size(synchronized,2),
				a(:,j-1) = Smooth(Accumulate(binnedTime,synchronized(:,j),nBins),smooth)./Smooth(n,smooth);
			end
			if strcmp(type,'circular'),
				b = []; % Variance not computed for circular data
				c = []; % Confidence intervals not computed for circular data
			else
				% Variance V = E(X²)-E(X)²
				for j = 2:size(synchronized,2),
					sq = Smooth(Accumulate(binnedTime,synchronized(:,j).^2,nBins),smooth)./Smooth(n,smooth); % E(X²)
					b(:,j-1) = sqrt(sq-a(:,j-1).^2);
					% 95% confidence intervals
					for i = 1:nBins,
						c(i,j-1,1) = prctile(synchronized(binnedTime==i,2),5);
						c(i,j-1,2) = prctile(synchronized(binnedTime==i,2),95);
					end
				end
			end
		end
		d = timeBins;
	case 'dist',
		if pointProcess,
			% Number of points in each (time,trial) bin
			n = Accumulate([binnedTime indices],1);
			% Smoothed distribution
			a = Smooth(Accumulate([n(:)+1 repmat((1:nBins)',nTrials,1)],1),smooth)/nTrials;
			b = timeBins;
			c = 0:max(max(n));
		else
			minValue = hist(1);
			maxValue = hist(2);
			nValueBins = hist(3);
			% Number of values in each time bin
			n = Accumulate(binnedTime,1,nBins);
			for j = 2:size(synchronized,2),
				% Binned values
				binnedValues = Bin(synchronized(:,j),[minValue maxValue],nValueBins);
				% Smoothed distribution
				a(:,:,j-1) = Smooth(Accumulate([binnedValues binnedTime],1,[nValueBins nBins]),smooth)./Smooth(repmat(n',nValueBins,1),smooth);
			end
			range = maxValue - minValue;
			binSize = range/nValueBins;
			b = timeBins;
			c = (minValue:range/nValueBins:maxValue-binSize)'+binSize/2;
		end
		d = [];
end

if strcmp(type,'circular'),
	a(:,2:end) = wrap(a(:,2:end),range);
end
