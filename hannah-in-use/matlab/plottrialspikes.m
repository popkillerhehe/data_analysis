function f = plottrialspikes(trialoutput, fieldoutput, min_dist)
%input the output from MASSplacefieldnumDIRECTIONALtrials for trial output and min_dist, and fieldoutput from MASSplacefieldnumDIRECTIONAL

fieldoutput = fieldoutput(2:end, :);

trialnames = (fieldnames(trialoutput));

bins = 20;

totalcounts = zeros(1,bins);
totalcountsnum = 0;
firstcounts =zeros(1,bins);
firstcountsnum = 0;
lastcounts =zeros(1,bins);
lastcountsnum = 0;
lastnums= 0;
firstnums= 0;
totalnums = 0;
indytotal=zeros(1,bins);
indytotal2=zeros(1,bins);
indynumsstarttotal=zeros(1,bins);
indynumsendtotal=zeros(1,bins);
indynumsstarttotal2=zeros(1,bins);
indynumsendtotal2=zeros(1,bins);
actnum = 1;
lapcenterdist = [];
indynumsstarttotal2error = [];
indynumsendtotal2error = [];
indytotal2error  = [];
totalnumserror = [];
firstnumserror = [];
lastnumserror = [];
totalskewto = [];
totalskewaway = [];
%length(trialnames) %254
for k = 1:length(trialnames) %this is field

  currentname = char(trialnames(k));
  currenttrial = trialoutput.(currentname);
  centerX = fieldoutput(k, 6);
  centerY = fieldoutput(k, 7);
  fieldsize = fieldoutput(k, 1);

  closer = NaN(size(currenttrial,3),1);

  currdist = NaN(size(currenttrial,1), 1, size(currenttrial,3));

  disindex = [];
  skew = 0;
  skewcount = 0;

  for j=1:size(currenttrial,3) %this is lap

    dist = 100000;
    currenttrial(:,1,j);
    nonan = find(currenttrial(:,1,j)>0);
      %added
    if length(nonan)>0
    %if abs(currenttrial(nonan(end),1,j)-currenttrial(nonan(1),1,j))<4 %length of 40cm should take about 4 seconds max
    for z=1:size(currenttrial,1) %this is spikes in lap
      if currenttrial(z,4,j)>5
      nowdist = pdist([cell2mat(centerX),cell2mat(centerY); currenttrial(z,2,j), currenttrial(z,3,j)]);
      nowdist = nowdist./3.5;

      currdist(z,1,j) = (nowdist-min_dist(actnum,2));
      %currdist(z,1,j) = (nowdist);

      if nowdist < dist
      closer(j) = currenttrial(z,1,j);
      disindex(j) = z;
      dist = nowdist;
    end
      end
    end

      skew = skew+min_dist(actnum,7); %SKEW
      skewcount = skewcount+1;
    end


    compcentdist = pdist([cell2mat(centerX),cell2mat(centerY); min_dist(actnum,3),min_dist(actnum,4)]);

    compcentdist = compcentdist./3.5-min_dist(actnum,2);

    if nanmean(currenttrial((1:end),1,:))>=3;
      lapcenterdist = [lapcenterdist; j, compcentdist];

    end



    actnum = actnum+1;
    if min_dist(actnum-1,6)==1
      totalskewto(end+1) = skew./skewcount;
    else
    totalskewaway(end+1) = skew./skewcount;
    end

    end





%end MAYBE??







currentcount = 0;

indynums = 0;
indycount = 0;
indynumsstart = 0;
indynumsend = 0;
haveaddedfirst = 1;
haveaddedlast = 1;
if length(find(disindex>0))>=9
  wantedindex = find(disindex>0);
  for p = 1:length(disindex)

  centerin = disindex(p); %index in center
    if centerin>0

      currdist(1:centerin,1,p) = currdist(1:centerin,1,p)*-1;

      currdist(~isnan(currdist(:,1,p)),1,p);
      notnan = ~isnan(currdist(:,1,p));
      whatwewant = currdist(notnan,1,p);
      whatwewant = whatwewant(find(whatwewant>=-20 & whatwewant<=20));
      [N,edges] = histcounts(whatwewant, [-20:2:20], 'Normalization', 'probability');
      [Nums,edges] = histcounts(whatwewant, [-20:2:20]);


        if mean(~isnan(N))==1
        currentcount = currentcount+1;
        totalcountsnum = totalcountsnum+1;
        totalnums = totalnums+Nums;
        totalnumserror = [totalnumserror; Nums];
        indynums = indynums+Nums;
        indycount = indycount+1;


        if haveaddedfirst == 1;
          firstcountsnum = firstcountsnum+1;
          firstnums = firstnums+Nums;
          firstnumserror = [firstnumserror; Nums];
          haveaddedfirst = 2;
        end
        templast1 = Nums;
        end
      end
    end

if lastcountsnum == firstcountsnum-1
lastcountsnum = lastcountsnum+1;
lastnums = lastnums+templast1;
lastnumserror = [lastnumserror; templast1];
end

  %lastcountsnum = lastcountsnum+2;
  %lastnums = lastnums+templast1+templast2+templast3;
    %lastnumserror = [lastnumserror; templast1; templast2; templast3];
end
end



figure
subplot(2,1,1)
histogram(totalskewto, 'BinWidth', .2)
subplot(2,1,2)
histogram(totalskewaway, 'BinWidth', .2)


%THIS IS DOING ALL AVERAGING TOGETHER
%subplot(2,1,2)
figure
hold on




errorbar(edges(1:end-1)+1, firstnums./firstcountsnum./2, std(firstnumserror./2)./sqrt(firstcountsnum),'Color', 'red');
errorbar(edges(1:end-1)+1, lastnums./lastcountsnum./2, std(lastnumserror./2)./sqrt(lastcountsnum), 'Color', 'cyan');
errorbar(edges(1:end-1)+1, totalnums./totalcountsnum./2, std(totalnumserror./2)./sqrt(totalcountsnum), 'Color','black');
legend('Average of all first runs through all fields', 'Average of all last runs through all fields', 'All runs through all fields')
%legend('Average of all first runs through all fields', 'Average of all last runs through all fields')
title('Spiking as a function of location around place field center, all trials and all fields')
ylabel('Average spikes at location (spikes/cm)')
xlabel('cm from place field center')


ttresults = [];
ttresults2 = [];
ttresults3 = [];
ttresults4 = [];
ttresults5 = [];
for c = 1:size(totalnumserror,2)

  [m p n stats] = ttest(firstnumserror(:,c), lastnumserror(:,c), 'Tail', 'left');
    ttresults(end+1) = p;
  [m p n stats] = ttest2(firstnumserror(:,c), lastnumserror(:,c), 'Tail', 'left');
    ttresults2(end+1) = p;
  [m p n stats] = ttest2(firstnumserror(:,c), totalnumserror(:,c), 'Tail', 'left');
    ttresults3(end+1) = p;
    [m p n stats4] = ttest(firstnumserror(:,c), mean(totalnumserror(:,c)), 'Tail', 'left');
      ttresults4(end+1) = p;
      [m p n stats] = ttest(lastnumserror(:,c), mean(totalnumserror(:,c)));
        ttresults5(end+1) = p;
  %if c == bins./2+1
  if c == 11
    mean(firstnumserror(:,c))./2
    mean(lastnumserror(:,c))./2
    mean(totalnumserror(:,c))./2
    std(firstnumserror(:,c)./2)
    std((lastnumserror(:,c)./2))
    std((totalnumserror(:,c)./2))

    stats
    stats4
  end
end


ttresults
%ttresults2
%ttresults3
ttresults4
%ttresults5

%errorbar(edges(1:end-1), indytotal2./firstcountsnum, std(indytotal2error)./size(indytotal2error,1), 'Color', 'black')
%size(indytotal2error,1)

%legend('Average of all first runs through all fields', 'Average of all last runs through all fields', 'All runs through all fields')
%title('Spiking as a function of location around place field center, all trials and all fields')
%ylabel('Average proportion of spiking at location')
%xlabel('cm from place field center')



toplot = [];
for z=1:max(lapcenterdist(:,1))
  found = find(lapcenterdist(:,1)==z);
  meandist = nanmean(lapcenterdist(found,2));
  stderrorlap = nanstd(lapcenterdist(found,2)./3.5)./sqrt(length(found));
  toplot = [toplot; z, meandist, length(found), stderrorlap];
end
figure

wanted = find(toplot(:,3)>=5);
wanted = max(wanted)
x = toplot(1:wanted,1);
y = toplot(1:wanted,2)./3.5;
[k, yInf, y0, yFit] = fitExponential(x, y)
k = k
yInf = yInf
y0 = y0
scatter(x,y);
hold on
errorbar(x, y, toplot(1:wanted,4), 'LineStyle','none');
plot(x, yFit)
title('Place field centers converge with experience')
xlabel('Lap')
ylabel('Average distance of lap place field center from overall center (cm)')


%fitlm(x,y)
%[fitobject,gof] = fit(x,y,'exp1')



totalcountsnum

f = lapcenterdist;
%f = [edges(1:end-1)+1;firstcounts; lastcounts; totalcounts];
