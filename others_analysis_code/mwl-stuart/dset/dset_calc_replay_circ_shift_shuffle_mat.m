function [score] = dset_calc_replay_circ_shift_shuffle_mat(dset, recon, nshuffle, slope, intercept)
% 
% pfEdges = dset.clusters(1).pf_edges;
% 
% %make individual trajectory pdfs
% leftIdx =  [pfEdges(1,1):pfEdges(1,2), pfEdges(2,1):pfEdges(2,2)];
% rightIdx = [pfEdges(1,1):pfEdges(1,2), pfEdges(3,1):pfEdges(3,2)];
% outIdx =   [fliplr(pfEdges(2,1) : pfEdges(2,2)), pfEdges(3,1):pfEdges(3,2) ] ;

score = zeros(size(dset.mu.bursts,1), 3, nshuffle);

wb = my_waitbar(0);

for i = 1:nshuffle
   for j = 1:size(dset.mu.bursts,1)
           
        tempIdx = recon.tbins >= dset.mu.bursts(j,1) & recon.tbins <= dset.mu.bursts(j,2);
       
        for k = 1:3
            pdf = recon.pdf{k}(:,tempIdx);
            pdf2 = pdf;
            shift = randi(size(pdf2,1));
            
            pdf2 = circshift(pdf2, [shift 0]);
                        
            pdf = normalize( pdf2 .* pdf);
            
            score(j,k,i) = compute_line_score(recon.tbins(tempIdx), recon.pbins{k}, pdf, slope(j,k), intercept(j,k));

            
        end
        
%             
%         
%        [~, ~, stats.score(j,1,i)] = est_line_detect(recon.tbins(tempIdx), recon.pbins(leftIdx), pdf(leftIdx,:));
%        [~, ~, stats.score(j,2,i)] = est_line_detect(recon.tbins(tempIdx), recon.pbins(rightIdx), pdf(rightIdx,:));
%        [~, ~, stats.score(j,3,i)] = est_line_detect(recon.tbins(tempIdx), recon.pbins(sort(outIdx)), pdf(outIdx,:));
       
   end    
   wb = my_waitbar(i/nshuffle, wb);

end




end
 