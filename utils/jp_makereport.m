function S = jp_makereport(S, subnum)
%JP_MAKEREPORT Make an html report for anlaysis stages.
%

subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);
fname = fullfile(subdir, sprintf('jp_report%s.html', S.cfg.options.analysisname));
f = fopen(fname, 'w');

sessions = {};
for s=1:length(S.subjects(subnum).sessions)
  sessions{length(sessions)+1} = S.subjects(subnum).sessions(s).name;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% head (including style)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(f, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">\n');
fprintf(f, '<html lang="en-US" dir="ltr">\n');
fprintf(f, '<head>\n');
fprintf(f, '<title>Processing report for %s</title>\n', subname);

fprintf(f, '<style type="text/css" media="all">\n');
fprintf(f, 'body {background:#fff; color:#444; font-family:helvetica, arial, sans-serif; font-size:11px; line-height:1.6;}\n');
fprintf(f, 'h1 {text-align:center;}\n');
fprintf(f, 'h2 {margin-top:70px;background:#ccc; padding:10px;border:1px solid #000;}\n');
fprintf(f, 'h3 {margin-top:30px;color:#000;}\n');
fprintf(f, 'img {max-width:600px;}\n');
fprintf(f, 'a img {padding:8px; border:2px solid #888;}\n');
fprintf(f, 'a img:hover {border:2px solid #000;}\n');
fprintf(f, '</style>\n');
fprintf(f, '</head>\n');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Body
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(f, '<body>\n');
fprintf(f, '<h1>Processing report for %s</h1>\n', subname);
fprintf(f, '<p>Click on any image for a larger version (if available).</p>\n');




for s=1:length(S.analysis)
  stagename = S.analysis(s).name;
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % tsdiffana
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if findstr('tsdiffana', stagename)
    fprintf(f, '\n<h2>TSDIFFANA</h2>\n\n');
    
    for s=1:length(sessions)
      fprintf(f, '<h3>%s</h3>\n', sessions{s});
      
      img = fullfile(sessions{s}, sprintf('%s_%s_tsdiffana.png', subname, sessions{s}));
      imgfp = fullfile(subdir,img);
      if exist(imgfp)
        fprintf(f, '<div><a href="%s"><img src="%s"></a></div>\n', img, img);
      else
        fprintf(f, '<p>%s not found.</p>\n', img);
      end
    end
  end % tsdiffana
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % realignment Motion parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if findstr('realign', stagename)
    fprintf(f, '\n<h2>Realign</h2>\n\n');
    
    for s=1:length(sessions)
      fprintf(f, '<h3>%s</h3>\n', sessions{s});
      
      img = fullfile(sessions{s}, sprintf('%s_%s_motionparameters.png', subname, sessions{s}));
      imgfp = fullfile(subdir,img);
      
      if exist(imgfp)
        fprintf(f, '<div><a href="%s"><img src="%s"></a></div>\n', img, img);
      else
        fprintf(f, '<p>%s not found.</p>\n', img);
      end
    end
    
  end % realign
  
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % coregistration
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %if findstr('coregister', stagename)
  if ~isempty(regexp(stagename, 'jp_spm._coregister'))
    fprintf(f, '\n<h2>Coregister</h2>\n\n');
    
    fprintf(f, '<p>Coregistration lines up your structural image with a mean functional image. To check that this has been done properly:</p>\n');
    fprintf(f, '<ol>\n');
    fprintf(f, '<li>In SPM, click ''check Reg''.</li>\n');
    fprintf(f, '<li>Select two images: the mean functional image (mean*.nii, located in the first fMRI session directory), and the structural image for your subject.</li>\n');
    fprintf(f, '<li>These images should be lined up with each other, so as you click different locations in one image, the crosshairs should move to the corresponding point in the other image.</li>\n');
    fprintf(f, '</ol>\n\n');
  end % coregister
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % coregistration of structural to template
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if findstr('coregisterstructural2template', stagename)
    fprintf(f, '\n<h2>Coregister structural to template</h2>\n\n');
    fprintf(f, '<p>The structural image has been coregistered to a structural template in MNI space in order to hopefully aid the starting estimates for segmentation and normalization.</p>\n\n');
    fprintf(f, '<p>You should check that the functional images, structural image, and structural template are approximately aligned.</p>\n\n');
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % segmentation
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if findstr('segment', stagename)
    fprintf(f, '\n<h2>Segmentation</h2>\n\n');
    fprintf(f, '<p>It''s a good idea to use check Reg to view all the segmented (c*) images in your structural directory to ensure segmentation worked properly.</p>\n\n');
  end % segment
  
  
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % normalization
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if findstr('normalize', stagename)
    fprintf(f, '\n<h2>Normalization</h2>\n\n');
    fprintf(f, '<p>It''s a good idea to use check Reg to make sure normalization completed properly. Select a normalized functional image (w*) and one of the canonical template images (probably located in %s) to make sure they are aligned well.</p>\n', fullfile(spm('dir'), 'canonical'));
  end % normalize
  
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if findstr('model', stagename)
  fprintf(f, '\n<h2>Model Design</h2>\n\n');
  
  if isfield(S.cfg, 'jp_spm8_model')
    cfg = S.cfg.jp_spm8_model;
  elseif isfield(S.cfg, 'jp_spm5_model')
    cfg = S.cfg.jp_spm5_model;
  else
    error('not found');
  end
  
  if cfg.separatesessions == 0
    for s=1:length(sessions)
      fprintf(f, '<h3>%s</h3>\n', sessions{s});
      
      statpath = fullfile(cfg.statsdir, [subname '_' sessions{s}]);
      img = fullfile(statpath, 'design_matrix.png');
      %imgfp = fullfile(subdir,img);
      
      if exist(img)
        fprintf(f, '<div><a href="%s"><img src="%s"></a></div>\n', img, img);
      else
        fprintf(f, '<p>%s not found.</p>\n', img);
      end
    end
    
  else
    img = fullfile(cfg.statsdir, subname, 'design_matrix.png');
    if exist(img)
      fprintf(f, '<div><a href="%s"><img src="%s"></a></div>\n', img, img);
    else
      fprintf(f, '<p>%s not found.</p>\n', img);
    end
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if findstr('estimate', stagename)
  fprintf(f, '\n<h2>Model Estimation</h2>\n\n');
  if cfg.separatesessions == 0
    for s=1:length(sessions)
      fprintf(f, '<h3>%s</h3>\n', sessions{s});
      
      statpath = fullfile(cfg.statsdir, [subname '_' sessions{s}]);
      img = fullfile(statpath, 'mask.png');
      %imgfp = fullfile(subdir,img);
      
      if exist(img)
        fprintf(f, '<div><a href="%s"><img src="%s"></a></div>\n', img, img);
      else
        fprintf(f, '<p>%s not found.</p>\n', img);
      end
    end
    
  else
    img = fullfile(cfg.statsdir, subname, 'mask.png');
    if exist(img)
      fprintf(f, '<div><a href="%s"><img src="%s"></a></div>\n', img, img);
    else
      fprintf(f, '<p>%s not found.</p>\n', img);
    end
  end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf(f, '</body>\n</html>\n');
fclose(f);

