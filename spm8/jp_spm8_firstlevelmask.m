function S = jp_spm8_firstlevelmask(S, subnum)
%JP_SPM8_FIRSTLEVELMASK make a first-level functional mask.
%
% S = JP_SPM8_FIRSTLEVELMASK(S, SUBNUM) uses code from spm_spm to
% create a "first level" functional mask without having to actually
% estimate a first level model.
%
% The output is saved in the main subject directory with a default name of firstlevelmask.nii.
%

% Jonathan Peelle
% University of Pennsylvania

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
error('not working!!!');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);


subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

try
  funprefix = S.subjects(subnum).funprefix;
catch
  funprefix = jp_getinfo('funprefix', S.subjdir, subname);
end

try
  fundirs = jp_getsessions(S, subnum);
catch
  fundirs = jp_getinfo('sessions', S.subjdir, subname);
end

% log files
[alllog, errorlog, masklog] = jp_createlogs(subname, S.subjdir, mfilename);


maskfile = fullfile(S.subjdir, subname, cfg.maskname);


jp_log(masklog, 'Getting functional images...');
P = jp_getfunimages([cfg.prefix funprefix], S.subjdir, subname, fundirs, S.cfg.options.mriext);
nScan = size(P,1);
jp_log(masklog, sprintf('done. %i images found.\n', nScan));


VY = spm_vol(P);
spm_check_orientations(VY);

jp_log(masklog, 'Computing mask...\n');

%% The following from spm_spm

%-Initialise
%==========================================================================
%fprintf('%-40s: %30s','Initialising parameters','...computing');        %-#
%xX            = SPM.xX;
%[nScan nBeta] = size(xX.X);

 
%-If xM is not a structure then assume it's a vector of thresholds
%--------------------------------------------------------------------------

xM = -Inf(nScan,1);

if ~isstruct(xM)
    xM = struct('T',    [],...
                'TH',   xM,...
                'I',    0,...
                'VM',   {[]},...
                'xs',   struct('Masking','analysis threshold'));
end




M        = VY(1).mat;
DIM      = VY(1).dim(1:3)';
xdim     = DIM(1); ydim = DIM(2); zdim = DIM(3);
YNaNrep  = spm_type(VY(1).dt(1),'nanrep');



%-Initialise new mask name: current mask & conditions on voxels
%----------------------------------------------------------------------
VM    = struct('fname',  maskfile,...
               'dim',    DIM',...
               'dt',     [spm_type('uint8') spm_platform('bigend')],...
               'mat',    M,...
               'pinfo',  [1 0 0]',...
               'descrip','jp_spm8_firstlevelmask:resultant analysis mask');
VM    = spm_create_vol(VM);





%==========================================================================
% - F I T   M O D E L   &   W R I T E   P A R A M E T E R    I M A G E S
%==========================================================================
 
%-MAXMEM is the maximum amount of data processed at a time (bytes)
%--------------------------------------------------------------------------
MAXMEM = spm_get_defaults('stats.maxmem');
mmv    = MAXMEM/8/nScan;
blksz  = min(xdim*ydim,ceil(mmv));                             %-block size
nbch   = ceil(xdim*ydim/blksz);                                %-# blocks
nbz    = max(1,min(zdim,floor(mmv/(xdim*ydim))));   nbz = 1;   %-# planes
blksz  = blksz * nbz;
 
%-Initialise variables used in the loop
%==========================================================================
[xords, yords] = ndgrid(1:xdim, 1:ydim);
xords = xords(:)'; yords = yords(:)';           % plane X,Y coordinates
%S     = 0;                                      % Volume (voxels)
%s     = 0;                                      % Volume (voxels > UF)
Cy    = 0;                                      % <Y*Y'> spatially whitened
CY    = 0;                                      % <(Y - <Y>) * (Y - <Y>)'>
EY    = 0;                                      % <Y>    for ReML
%i_res = round(linspace(1,nScan,nSres))';        % Indices for residual
 
%-Initialise XYZ matrix of in-mask voxel co-ordinates (real space)
%--------------------------------------------------------------------------
XYZ   = zeros(3,xdim*ydim*zdim);



% go through blocks
for z = 1:nbz:zdim     
  
  
      % current plane-specific parameters
    %----------------------------------------------------------------------
    CrPl    = z:min(z+nbz-1,zdim);       %-plane list
    zords   = CrPl(:)*ones(1,xdim*ydim); %-plane Z coordinates
    CrBl    = [];                        %-parameter estimates
    CrResI  = [];                        %-normalized residuals
    CrResSS = [];                        %-residual sum of squares
    Q       = [];                        %-in mask indices for this plane
 
    for bch = 1:nbch                     %-loop over blocks
      
      
      
      %-Print progress information in command window
      %------------------------------------------------------------------
      if numel(CrPl) == 1
        str = sprintf('Plane %3d/%-3d, block %3d/%-3d',...
          z,zdim,bch,nbch);
      else
        str = sprintf('Planes %3d-%-3d/%-3d',z,CrPl(end),zdim);
      end
      if z==1&&bch==1, str2=''; else str2=repmat(sprintf('\b'),1,72); end
      fprintf('%s%-40s: %30s',str2,str,' ');                          %-#
      
      %-construct list of voxels in this block
      %------------------------------------------------------------------
      I     = (1:blksz) + (bch - 1)*blksz;       %-voxel indices
      I     = I(I <= numel(CrPl)*xdim*ydim);     %-truncate
      xyz   = [repmat(xords,1,numel(CrPl)); ...
        repmat(yords,1,numel(CrPl)); ...
        reshape(zords',1,[])];
      xyz   = xyz(:,I);                          %-voxel coordinates
      nVox  = size(xyz,2);                       %-number of voxels
      
      %-Get data & construct analysis mask
      %=================================================================
      fprintf('%s%30s',repmat(sprintf('\b'),1,30),'...read & mask data')
      Cm    = true(1,nVox);                      %-current mask
      
      
      %-Compute explicit mask
      % (note that these may not have same orientations)
      %------------------------------------------------------------------
      %   for i = 1:length(xM.VM)
      %
      %     %-Coordinates in mask image
      %     %--------------------------------------------------------------
      %     j = xM.VM(i).mat\M*[xyz;ones(1,nVox)];
      %
      %     %-Load mask image within current mask & update mask
      %     %--------------------------------------------------------------
      %     Cm(Cm) = spm_get_data(xM.VM(i),j(:,Cm),false) > 0;
      %   end
      
      %-Get the data in mask, compute threshold & implicit masks
      %------------------------------------------------------------------
      Y     = zeros(nScan,nVox);
      for i = 1:nScan
        
        %-Load data in mask
        %--------------------------------------------------------------
        if ~any(Cm), break, end                %-Break if empty mask
        Y(i,Cm)  = spm_get_data(VY(i),xyz(:,Cm),false);
        
        Cm(Cm)   = Y(i,Cm) > xM.TH(i);         %-Threshold (& NaN) mask
        if xM.I && ~YNaNrep && xM.TH(i) < 0    %-Use implicit mask
          Cm(Cm) = abs(Y(i,Cm)) > eps;
        end
      end
      
      %-Mask out voxels where data is constant
      %------------------------------------------------------------------
      Cm(Cm) = any(diff(Y(:,Cm),1));
      Y      = Y(:,Cm);                          %-Data within mask
      CrS    = sum(Cm);                          %-# current voxels
      
      
      jj = NaN(xdim,ydim,numel(CrPl));
      
      
    end %(bch)
  
  %-Write Mask image
  %------------------------------------------------------------------
  if ~isempty(Q), jj(Q) = 1; end
  VM    = spm_write_plane(VM, ~isnan(jj), CrPl);
  
end

fprintf('\n');

