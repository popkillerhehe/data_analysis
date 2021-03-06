function f = MASSaccelVsFiringRateNEW(spikestructure, posstructure, timestructure, binsize)
  %BIN SIZE IS FOR HISTOGRAM-- recommended is 2
%  %use clusterimport.m and posimport.m and timeimport.m to create spike and position structures
  %does conversion factor if needed for early recordings
  %window size is in seconds

%determine how many spikes
spikenames = (fieldnames(spikestructure));
spikenum = length(spikenames);

output = {'cluster name'; '# spikes'; 'neg slope'; 'neg r2'; 'neg p value'; 'pos slope'; 'pos r2'; 'pos p value'; 'all slope'; 'all r2'; 'all p value'};

figure
for k = 1:spikenum
    columns = 1;
    rows = spikenum;
    %if rem(spikenum,4) < rem(spikenum,3)
    %  rows = spikenum./4;
    %  columns = spikenum./rows;
    %else
    %  rows = spikenum./3;
    %  columns = ceil(spikenum./rows);
    %end

    name = char(spikenames(k))
    % get date of spike
    date = strsplit(name,'cluster_'); %splitting at year
    date = char(date(1,2));
    date = strsplit(date,'_maze_cl');
    date = char(date(1,1));
    date = strsplit(date,'_box_cl');
    date = char(date(1,1));
    date = strsplit(date,'_rotation_cl');
    date = char(date(1,1));
    date = strsplit(date,'_cl');
    date = char(date(1,1));
    date = strcat(date, '!');
    date = regexp(date,'_1!|_2!|_3!|_4!|_5!|_6!|_7!|_8!|_9!|_10!|_11!|_12!|_13!|_14!|_15!|_16!|_17!|_18!|_19!|_20!|_21!|_22!|_23!|_24!|_25!|_26!|_27!|_28!|_29!|_30!|_31!|_32!','split');
    %date = strsplit(date,'_1!'|'_2!'|'_3!','_4!','_5!','_6!','_7!','_8!','_9!','_10!','_11!','_12!','_13!','_14!','_15!','_16!','_17!','_18!','_19!','_20!','_21!','_22!','_23!','_24!', '_25!', '_26!', '_27!', '_28!', '_29!', '_30!', '_31!', '_32!')
    date = char(date(1,1));
    %date = regexp(date,'(?=[maze])_1_|_2_|_3_|_4_|_5_|_6_|_7_|_8_|_9_|_10_|_11_|_12_|_13_|_14_|_15_|_16_|_17_|_18_|_19_|_20_|_21_|_22_|_23_|_24_|_25_|_26_|_27_|_28_|_29_|_30_|_31_|_32_','split');
    %date = char(date(1,1));
    % formats date to be same as in position structure: date_2015_08_01_acc
    accformateddate = strcat(date, '_acc');
    accformateddate = strcat('date_', accformateddate);
    % formats date to be same as in time structure: date_2015_08_01_time
    timeformateddate = strcat(date, '_time');
    timeformateddate = strcat('date_', timeformateddate);
    % formats date to be same as in time structure: date_2015_08_01_position
    posformateddate = strcat(date, '_position');
    posformateddate = strcat('date_', posformateddate);

    %get conversion factor
    numdate = {date};
    numdate = char(strrep(numdate,'_',''));
    numdate = str2num(numdate);
      if numdate < 20170427
        actualseconds = length(timestructure.(timeformateddate)) / 2000;
        fakeseconds = timestructure.(timeformateddate)(end)-timestructure.(timeformateddate)(1);
        conversion = actualseconds/fakeseconds;
      elseif numdate == 20170715
        conversion = 10;
      else
        conversion = 1;
      end

      % limit the times in the time file to those in position files
      starttime = posstructure.(posformateddate)(1,1);
      endtime = posstructure.(posformateddate)(end,1);
      starttime = find(abs(timestructure.(timeformateddate)-starttime) < .001);
      endtime = find(abs(timestructure.(timeformateddate)-endtime) < .001);
      starttime = starttime(1,1);
      endtime = endtime(1,1);
      time = [timestructure.(timeformateddate)(starttime:endtime)];


    % does the thing
    % want to decide on output-- maybe number of spikes, slope, and r2 value
    spikename = char(spikenames(k));
    %set(0,'DefaultFigureVisible', 'off');
    subplot(ceil(columns), ceil(rows), k)
    accvrate = accelVsFiringRateNew((time.*conversion), (posstructure.(accformateddate).*conversion), (spikestructure.(spikename).*conversion), binsize);


    negslope = accvrate(1);
    negrsquared = accvrate(2);
    negpval = accvrate(3);
    posslope = accvrate(4);
    posrsquared = accvrate(5);
    pospval = accvrate(6);
    allslope = accvrate(7);
    allrsquared = accvrate(8);
    allpval = accvrate(9);

    spikesizes = spikestructure.(spikename);


    % made chart with name, number of spikes, number of points on graph, slope, and r2 value, and p value from t test
    newdata = {name; length(spikesizes); negslope; negrsquared;  negpval; posslope; posrsquared; pospval; allslope; allrsquared; allpval};

    output = horzcat(output, newdata);

  end

% outputs chart with spike name, number of spikes, slope, and r2 value
  f = output';
