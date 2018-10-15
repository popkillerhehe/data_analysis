function [values probs] = decodeshitVelNEW(timevector, clusters, vel, tdecode)

% decodes velocity  based on cell firing. t is bins in seconds
% returns [predictedV, actualV]
% for now make sure bins in binVel function are the same. will implement that as a variable later
%
%
%NEED TO PUT TIMES WITH THE OUTPUT OR IT GETS SUPER CONFUSING. DO THIS
%
% to plot: imagesc([minx maxx], [miny maxy], decoded.probs')
% ex: imagesc([0 length(decoded.probs)], [2 24], decoded.probs')
%
% to plot actual velocity over it:
% temp = binning(assvel(1,:)', ceil(length(assvel)/length(decoded.probs)));
% temp = temp/ceil(length(assvel)/length(decoded.probs));
% plot(temp, 'LineWidth',1.5, 'Color', 'w');
tic
tdecode = tdecode*2000;
tm = 1;
assvel = assignvel(timevector, vel);
asstime = assvel(2,:);


%find number of clusters
clustname = (fieldnames(clusters))
numclust = length(clustname)

%bin the velocities
% for now let's bin velocity as 0-10, 10-30, 30-60, 60-100, 100+


vbin = [0; 5; 10; 15; 20; 25; 30; 35; 40; 45; 50]; %C


%binnedV = binVel(timevec, vel, t/2000);


% for each cluster,find the firing rate at esch velocity range
j = 1;
fxmatrix = zeros(numclust, length(vbin));
while j <= numclust
    name = char(clustname(j))

    fxmatrix(j,:) = firingPerVelNEW(asstime, vel, clusters.(name), vbin);
    %fxmatrix(j,:) = firingPerVel(asstime, assvel, clusters.(name), t./2000);
    j = j+1;
end

fxmatrix


 %find prob the animal is each velocity DONT NEED BUT CAN BE USEFUL
%{
probatvelocity = zeros(length(vbin),1);
legitV = find(binnedV<100);
for k = 1:length(vbin)
    numvel = find(binnedV == (k));
    probatvelocity(k) = length(numvel)./length(legitV);
end
probatvelocity
%}


% permue times
  maxprob = [];
  spikenum = 1;
  times = [];

%percents = zeros(length(timevector)-(rem(length(timevector), t)), length(vbin)) ;
percents = [];

while tm <= length(timevector)-(rem(length(timevector), tdecode)) & (tm+tdecode) < length(timevector)
      %for the cluster, permute through the velocities
      endprob = [];

        for k = (1:length(vbin)) % six for the 6 groups of velocities
          %PERMUTE THROUGH THE CLUSTERS
          %productme = 1; OLD
          productme =0;
          expme = 0;
          c = 1;
          while c <= numclust
              size(numclust);
              name = char(clustname(c));
              ni = find(clusters.(name)>timevector(tm) & clusters.(name)<timevector(tm+tdecode)); % finds index (number) of spikes in range time
              fx = (fxmatrix(c, k));  %should be the rate for cell c at vel k.


              %fxni = (fx^length(ni)); OLD
              %productme = productme*fxni; OLD

               productme = (productme + length(ni)*log(fx));
              %productme = productme + log((fx^length(ni)));

              expme = (expme) + (fx);
              c = c+1; % goes to next cell, same velocity

          end
          % now have all cells at that velocity
          tmm = tdecode./2000;

          %IF YOU WANT TO MULTIPLY BY PROB OF LOCATION COMMENT OUT FIRST LINE AND IN SECOND LINE
          endprob(end+1) = (productme) + (-tmm.*expme); %NEW
          %endprob(end+1) = log(probatvelocity(k)) + (productme) + (-tmm.*expme); %NEW


        %  if max(isinf(endprob)) ==1
        %      warning('youve got an infinity')
              %length(ni)
              %log(productme) %this is inf
          %elseif mean(endprob) ==0
          %    warning('youve got all zeros')
          %    endprob
          %end



        end


        [val, idx] = (max(endprob));

        nums = isfinite(endprob);
        nums = find(nums == 1);
      endprob = endprob(nums);

        test = exp(endprob);
            if max(isinf(test)) == 1
            endprob = exp(endprob-(max(endprob)*.2));
            else
              endprob = test;
            end

        conv = 1./sum(endprob);
      endprob = endprob*conv;



        percents = vertcat(percents, endprob);

        maxprob(end+1) = idx;
        %maxprob(end+1) = find(max(endprob)); %finds most likely range: 1 is for 0-10, 2 for 10-30, etc
                                          % if I want probabilities need to make a matrix of endprobs instead of selecting max
        times(end+1) = timevector(tm);

    tm = tm+tdecode; %for overlap?

end

%length(find(binnedV==4))

%ans = find(binnedV<50);
%[h,p,ci,stats] = ttest2(maxprob, binnedV);
probs = percents;


%values = [maxprob; binnedV, times'];
%v = [maxprob; binnedV];
v = maxprob;
%vbin = [0; 10; 15; 20; 30; 40; 50];


for k=1:length(vbin)
  bin = find(v==k);
  if k<length(vbin)
  v(bin) = (vbin(k)+vbin(k+1))/2;
elseif k==length(vbin)
  highestvel = find(vel(1,:)>vbin(end));
  highestvel = median(vel(1,highestvel));
  v(bin) = highestvel;
end
end

values = [v; times];

toc
%[h,p,ci,stats] = ttest2(maxprob, binnedV)
%probs = percents;
%values = [maxprob; binnedV];
