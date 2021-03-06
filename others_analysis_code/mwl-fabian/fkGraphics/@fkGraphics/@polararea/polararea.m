function h=polararea(varargin)
%POLARAREA polar area constructor
%
%  h=POLARAREA(param1,var1,...) constructs a polar area object with
%  properties set by the parameter/value pairs. Valid parameters are:
%   Parent - handle of parent axes (normal or polar axes)
%   AngleUnits - units for angular data ('radians' or 'degrees')
%   AngleData - angle data vector
%   RadiusData - radius data vector
%   AngleClip - clipping method for angle data (default='clip')
%   RadiusClip - clipping method for radius data (default='clip')
%   Baseline - radial baseline value for area plot (default=-Inf)
%   EdgeColor - color of edge (default=[0 0 0])
%   FaceColor - color of area (default=[0 0 0])
%   LineStyle - line style of edge (default='-')
%   LineWidth - line width of edge (default=1)
%   Alpha - alpha value for area (default=0.2)
%   Marker - marker style fo edge (default='o')
%   MarkerSize - marker size (default=6)
%   MarkerEdgeColor - color of marker outline (default=[0 0 0])
%   MarkerFaceColor - color of marker fill (default='none')
%   AutoClose - automatically close area (default='on')
%

%  Copyright 2008-2008 Fabian Kloosterman


%-------CONSTRUCTION-------

%find polar area parameters in arguments
p = {'AngleData', 'RadiusData', 'AngleClip', 'RadiusClip', 'Baseline', ...
     'EdgeColor', 'FaceColor', 'LineStyle', 'LineWidth', 'Alpha', 'Marker', ...
     'MarkerSize', 'MarkerEdgeColor', 'MarkerFaceColor', 'AngleUnits', ...
     'AutoClose'};

ind = find( ismember( lower(varargin(1:2:end)), lower(p) ) );
ind = [2*ind-1;2*ind];
args = varargin(ind(:));

%find parent parameter if any
parent_ind = find( strncmpi( varargin(1:2:end), 'parent',6 ) );
if ~isempty(parent_ind)
  parent = varargin{parent_ind*2};
else
  parent = gca;
end

%find remaining arguments and pass on to constructor
ind = setdiff(1:nargin,ind(:));
h=fkGraphics.polararea(varargin{ind}, 'Parent', double(parent));


%-------INITIALIZATION-------

%set remaining arguments
if ~isempty(args)
  set(h,args{:});
end

%create initial patch and line objects
hL(2) = patch(NaN,NaN,h.FaceColor,'LineStyle','none', 'FaceAlpha',h.Alpha, ...
              'Parent', double(h));

hL(1) = line(NaN,NaN, 'LineWidth',h.LineWidth,'LineStyle',h.LineStyle, ...
             'Marker',h.Marker,'MarkerEdgeColor', h.MarkerEdgeColor, ...
             'MarkerFaceColor', h.MarkerFaceColor, 'Color', h.EdgeColor, ...
             'MarkerSize', h.MarkerSize, 'Parent', double(h));

%store the handles
h.hHandles = hL;

%this object support legends
setappdata(double(h),'LegendLegendInfo',[]);

%we're done initializing
h.Initialized=1;


%-------LISTENERS-------

%create listener for when the line properties change
p = [h.findprop('LineWidth') h.findprop('LineStyle') h.findprop('Marker') ...
     h.findprop('MarkerEdgeColor') h.findprop('MarkerFaceColor') ...
     h.findprop('EdgeColor') h.findprop('MarkerSize')];
l = handle.listener(h, p, 'PropertyPostSet', @changedLineProps);

%create listener for when patch properties change
p = [h.findprop('FaceColor') h.findprop('Alpha')];
l(end+1)=handle.listener(h, p, 'PropertyPostSet', @changedPatchProps);


%-------SETTERS/GETTERS-------

%define set/get function angle data
p = h.findprop('AngleData');
set(p, 'GetFunction', @fkGraphics.getAngleData);
set(p, 'SetFunction', @fkGraphics.setAngleData);


%-------FINALIZE-------

%store listeners
h.PropertyListeners = l;

%set refreshmode to auto, which forces a refresh
h.RefreshMode = 'auto';


%-------LISTENER CALLBACK FUNCTIONS-------


function changedLineProps(hProp,eventdata) %#ok
%CHANGEDLINEPROPS set line properties
h=eventdata.affectedObject;
set(h.hHandles(1),'LineWidth',h.LineWidth, 'LineStyle',h.LineStyle, ...
                  'Marker',h.Marker,'MarkerEdgeColor', h.MarkerEdgeColor, ...
                  'MarkerFaceColor', h.MarkerFaceColor, 'Color', ...
                  h.EdgeColor, 'MarkerSize', h.MarkerSize);
%refresh legend
if ~isempty(getappdata(double(h),'LegendLegendInfo'))
  setLegendInfo(h);
end


function changedPatchProps(hProp,eventdata) %#ok
%CHANGEDPATCHPROPS set patch properties
h=eventdata.affectedObject;
set(h.hHandles(2),'FaceColor',h.FaceColor, 'FaceAlpha', h.Alpha);
%refresh legend
if ~isempty(getappdata(double(h),'LegendLegendInfo'))
  setLegendInfo(h);
end