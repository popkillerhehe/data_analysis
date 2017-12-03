function r = mua_rate(cluster, timevector, t)

% finds rate of MUA, outputs as number of spikes per time bin
% function muar = mua_rate(file, start_time, end_time, t);
% MUA must be format [1, evemts]
%
% file should be the loaded file
% t is bin in seconds (for ex, .01 for 10ms or 1 for 1 second)
%
% ex:
% >> [mua.time, mua.rate] = mua_rate(cluster, 455.8529, 24855.7439, 1);
%
% returns a [2, :] matrix of spikes and times

%going through all the time and making a vector time_v with each millisecond


%duration = end_time-start_time;
duration = length(timevector);
start = min(timevector);
t = 2000.*t; %convert to time stamps

%time_v = start_time:t:end_time;
%if mod(duration,t) ~= 0 %if remainder doesnt equal zero
%    time_v = time_v(1:end-1);
%end

sized = ceil(length(timevector)./(t))-1;


%m = length(time_v);
%i = 1:m-1;
%rate = zeros(size(time_v));
%for i = 1:m-1
%    rate(i) = sum((tv > time_v(i)) & (tv < time_v(i+1)));
%end

rate = zeros(sized,1);
for i = 1:sized

  rate(i) = sum((cluster > timevector(1+t*(i-1))) & (cluster < timevector(1+t*i)));
end


%output time and rate
r = [timevector(1:length(rate)); rate'];
