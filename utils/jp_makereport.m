function S = jp_makereport(S, subnum)
%JP_MAKEREPORT Make an html report for anlaysis stages.
%

subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);
fname = fullfile(subdir, 'jp_report.html');
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
fprintf(f, '<title>ICA report for %s</title>\n', subname);

fprintf(f, '<style type="text/css" media="all">\n');
fprintf(f, 'body {background:#fff; color:#444; font-family:helvetica, arial, sans-serif; font-size:11px; line-height:1.6;}\n');
fprintf(f, 'h1 {text-align:center;}\n');
fprintf(f, 'h2 {margin-top:70px;background:#ccc; padding:5px;}\n');
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
      
      img = fullfile(subdir, sessions{s}, sprintf('%s_%s_tsdiffana.png', subname, sessions{s}));
      if exist(img)      
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
      
      img = fullfile(subdir, sessions{s}, sprintf('%s_%s_motionparameters.png', subname, sessions{s}));
      if exist(img)      
        fprintf(f, '<div><a href="%s"><img src="%s"></a></div>\n', img, img);
      else
        fprintf(f, '<p>%s not found.</p>\n', img);
      end
    end 
    
  end % realign
  
  
  
  
  
  
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf(f, '</body>\n</html>\n');
fclose(f);

