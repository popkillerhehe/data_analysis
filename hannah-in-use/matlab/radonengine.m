function E = radonengine()
%RADONENGINE creates a radon engine
%
%  e=RADONENGINE constructs an engine for computing the radon transform.
%
%  A radon engine has the following inputs:
%   matrix - input matrix
%   dx - sampling interval in x-dimension
%   dy - sampling interval in y-dimension
%   origin - x and y origin
%   rho_x - 0/1 use rho or rho_x
%
%  A radon engine contains the following engines:
%   smooth - optionally smooths the input matrix
%   radon - computes radon transform
%   project - gets projection in smoothed matrix for every peak found
%   peaks - finds peaks in radon transform
%   segment - find line segments for each peak found
%   randomize - optionally randomizes the input matrix
%
%  A radon engine has the following outputs:
%   radon - radon transform matrix
%   theta - vector of angles
%   rho - vector of rho or rho_x values
%   peaks - matrix of theta, rho and radon-score of all peaks found.
%   projections - the projections along the lines determined by the peaks
%   segments - line segments along each projection
%   radon_n - the number of pixels used for radon transform
%


smoothengine = fcnengine( 'slots_in', struct('matrix',[],'dx',1,'dy',1,...
                                             'sd',0,...
                                             'correct',0,...
                                             'nanexcl', 1), ...
                          'slots_out', {'matrix'}, ...
                          'positional_slots', [1 2 3], ...
                          'fcn', @dosmooth, ...
                          'name', 'smooth', ...
                          'output_caching', 1, ...
                          'can_disable', 1, ...
                          'types_in', {NaN, 'double', 'double', 'double', 'logical', 'logical'});

radonengine = fcnengine( 'slots_in', struct('matrix',[], ...
                                            'dx',1,'dy',1, ...
                                            'interp', 'linear', ...
                                            'method', 'integral', ...
                                            'valid', 1, ...
                                            'theta_range', [-0.5 0.5]*pi, ...
                                            'dtheta', 0.1, ...
                                            'rho_range', [], ...
                                            'drho', [], ...
                                            'rho_x', 0, ...
                                            'constraint', 'none'), ...
                         'slots_out', {'radon','theta','rho', 'n'} ,...
                         'positional_slots', 1, ...
                         'fcn', @doradon, ...
                         'name', 'radon', ...
                         'output_caching', 1, ...
                         'types_in', {NaN,'double','double','char', ...
                    'char','logical','double','double','double','double','logical','char'});

projectionengine = fcnengine( 'slots_in', struct('matrix',[],'dx',1, ...
                                                 'dy',1,'origin',[0 0],...
                                                 'peaks',[],...
                                                 'interp','linear', ...
                                                 'rho_x', 1),...
                              'slots_out', {'projections'}, ...
                              'positional_slots', 1:5, ...
                              'fcn', @doradonprojection, ...
                              'name', 'project', ...
                              'output_caching', 1, ...
                              'types_in', {NaN,'double','double', ...
                    'double',NaN,'char','logical'});

peakengine = fcnengine( 'slots_in', struct('matrix',[],'theta',[],'rho',[],...
                                           'threshold',[],...
                                           'ellipse',[0.5 0.01],...
                                           'npeaks',10), ...
                        'slots_out', {'peaks'},...
                        'positional_slots', 1:3, ...
                        'fcn', @doradonpeaks, ...
                        'name', 'peaks', ...
                        'output_caching', 1, ...
                        'types_in', {NaN,NaN,NaN,'double','double', ...
                    'double'});

segmentengine = fcnengine( 'slots_in', struct('projections',[],...
                                              'threshold', 0.2, ...
                                              'maxgap', 10, ...
                                              'minlength', 10), ...
                           'slots_out', {'segments'}, ...
                           'positional_slots', 1, ...
                           'fcn', @dofindsegments, ...
                           'name', 'segment', ...
                           'output_caching', 1, ...
                           'types_in', {NaN,'double','double','double'});


randomizematrix = randengine( 'randomize' );
randomizematrix.enable = 0;

connections = {
    'in', 1, 'randomize', 1; ...
    'randomize', 1, 'smooth', 1; ...
    'in', 2, 'smooth', 2; ...
    'in', 3, 'smooth', 3; ...
    'smooth', 1, 'radon', 1; ...
    'in', 2, 'radon', 2; ...
    'in', 3, 'radon', 3; ...
    'radon', 1, 'out', 1; ...
    'radon', 2, 'out', 2; ...
    'radon', 3, 'out', 3; ...
    'radon', 1, 'peaks', 1; ...
    'radon', 2, 'peaks', 2; ...
    'radon', 3, 'peaks', 3; ...
    'radon', 4, 'out', 7; ...
    'peaks', 1, 'out', 4; ...
    'smooth', 1, 'project', 1; ...
    'in', 2, 'project', 2; ...
    'in', 3, 'project', 3; ...
    'in', 4, 'project', 4; ...    
    'peaks', 1, 'project', 5; ...
    'project', 1, 'out', 5; ...
    'project', 1, 'segment', 1; ...
    'segment', 1, 'out', 6; ...
    'in', 5, 'radon', 11; ...
    'in', 5, 'project', 7 ...
    };
                                            

engines = {smoothengine, radonengine, projectionengine, peakengine, ...
           segmentengine, randomizematrix};

E = compoundengine( 'engines', engines, ...
                    'connections', connections, ...
                    'slots_in', struct('matrix',[],'dx',1,'dy',1,...
                                       'origin',[0 0], 'rho_x', 1 ), ...
                    'slots_out', {'radon','theta','rho','peaks','projections','segments','radon_n'},...
                    'name','engine', ...
                    'types_in', {[],[],[],[],'logical'});



function m = doradonpeaks(m, theta, rho, varargin)

m = radon_peaks_ellipse( m, 'theta', theta, 'rho', rho, varargin{:} );


function m = dosmooth( m, dx, dy, varargin )

args = struct('sd', 0);
[args, other, remainder] = parseArgs( varargin, args); %#ok

if nargin<2 || isempty(dx) || isnan(dx)
  dx = 1;
end
if nargin<3 || isempty(dy) || isnan(dy)
  dy = 1;
end

m = smoothn( m, args.sd, [dy dx], remainder{:});


function [m, theta, rho, n] = doradon( m, varargin )

%do radon transform
[m, n, options] = radon_transform( m', varargin{:} );

theta = options.theta;
rho = options.rho;


function segments = dofindsegments( p, varargin )

args = struct( 'threshold', 0.2, ...
               'maxgap', 10, ...
               'minlength', 10);

args = parseArgs(varargin, args);

segments = cell( numel(p), 1);

for k=1:numel(p)
  %find zero crossings
  [p2n_idx, n2p_idx] = zerocrossing( p(k).value - args.threshold );

  if isempty(p2n_idx) && isempty(p2n_idx)
    if p(k).value(1)>=args.threshold
      segments{k} = p(k); %everything above threshold
    else
      segments{k} = struct('value',{}, 'xlim',{},'ylim',{});
    end
    continue;
  end
  
  %correct open segments at beginning and end
  if ~isempty(p2n_idx) && (isempty(n2p_idx) || p2n_idx(1)<n2p_idx(1))
    n2p_idx = [1; n2p_idx];
  end
  if ~isempty(n2p_idx) && (isempty(p2n_idx) || n2p_idx(end)>p2n_idx(end))
    p2n_idx(end+1,1) = numel(p(k).value);
  end
  
  %convert indices to y-values
  p2n = interp1( [1 numel(p(k).value)], p(k).ylim, p2n_idx, 'linear' );
  n2p = interp1( [1 numel(p(k).value)], p(k).ylim, n2p_idx, 'linear' );  
  %combine segments that are separated by less than maxgap
  gap_indx = find( abs(n2p(2:end) - p2n(1:(end-1))) < args.maxgap );
  p2n( gap_indx ) = [];
  n2p( gap_indx+1 ) = [];
  p2n_idx( gap_indx ) = [];
  n2p_idx( gap_indx+1 ) = [];  
  %create segments
  segs = [n2p p2n];
  segs_idx = [n2p_idx p2n_idx];
  %remove segments that are too small
  small_idx = abs( diff(segs,1,2) )<args.minlength;
  segs( small_idx, : ) = [];  
  segs_idx( small_idx, :) = [];
  %store segments
  n = size(segs,1);
  if n>0
    v = cell(n,1);
    for s=1:n
      v{s} = p(k).value(ceil(segs_idx(s,1)):floor(segs_idx(s,2)));
    end
    
    segments{k} = struct( 'value', v,...
                          'xlim', mat2cell(interp1([1 numel(p(k).value)], p(k).xlim, segs_idx), ones(n,1),2),...
                          'ylim', mat2cell(segs, ones(n,1),2));
  end
end


function p = doradonprojection( m, dx, dy, origin, pks, varargin )

if nargin<4 || isempty(origin)
  %default origin (bottom left corner) of image
  origin = [0 0];
end

if nargin<5 || isempty(pks)
  %no peaks, no projections
  p = struct('value', {}, 'xlim', {}, 'ylim', {});
  return
end

%compute projections
p = radon_transform( m', 'dx', dx, 'dy', dy, 'method' ,'slice',  ...
                      'valid', 1, 'theta', pks(:,1), 'rho', pks(:,2), ...
                      varargin{:} );


%local image centers
ctrx = dx.*(size(m,2)-1)/2;
ctry = dy.*(size(m,1)-1)/2;

%intersect lines with local bounding box
[px, py] = lineboxintersect( pks(:,[1 2]), [-ctrx ctrx -ctry ctry] );


%transform to real world coordinates
px = px + ctrx + origin(1);
py = py + ctry + origin(2);

%sort
idx = find( px(:,1)>px(:,2) );
[px(idx,1), px(idx,2)] = swap(px(idx,1),px(idx,2));
[py(idx,1), py(idx,2)] = swap(py(idx,1),py(idx,2));

for j=1:numel(p)
  if py(j,1)>py(j,2)
    p{j} = flipud(p{j});
  end
end

p = struct( 'value', p, 'xlim', mat2cell(px, ones(size(px,1),1), 2), 'ylim', ...
            mat2cell(py, ones(size(py,1),1), 2) );

