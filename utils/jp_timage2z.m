function jp_timage2z(imgs, df)
%JP_TIMAGE2Z Convert a Nifti T map to Z scores using spm_t2z.
%
%



% make sure required SPM function is in the path
if ~exist('spm_t2z')
    error('The SPM function spm_t2z is required.');
end


% check the other inputs

if isempty(imgs)
    imgs = spm_select(Inf, 'image', 'Select T images to convert...', [], pwd, '^spmT.*');
end

if nargin < 2 || isempty(df)
    error('Must supply degrees of freedom.');
end

clc

% Go through each image, convert to Z, and save

for i=1:size(imgs,1)
   fprintf('Converting image %i/%i...\n', i, size(imgs,1));
   
   %thisimg = fileparts(strtok(imgs(i,:), ','));
   thisimg = strtok(imgs(i,:));
   
   [pth, nm, ext] = fileparts(thisimg);

   Vin = spm_vol(thisimg);

   % the output image will have the same properties as the input, just
   % change the name
   Vout = Vin;
   Vout.fname = fullfile(pth, [nm '_Z.nii']);


   % get the t values, and initialize an output data matrix Y2
   [Y,XYZ] = spm_read_vols(Vin);

   Ysize = size(Y);
   Y = reshape(Y,1,prod(size(Y)));
   
   % only do voxels that are not 0 or NaN
   goodY = find([~isnan(Y) .* (Y~=0)]);
   
   fprintf('Found values to convert in %i of %i total voxels.\n', length(goodY), length(Y));

   % Go through Y and convert any numberic values to z
   jp_progress(); % initialize progress bar

   for w=1:length(goodY)
       if mod(w,500)==0; jp_progress(w, length(goodY)); end

       ww = goodY(w);
       
       if Y(ww)~=0 && ~isnan(Y(ww))
           Y(ww) = spm_t2z(Y(ww), df);
       end
   end


   %    for x=1:size(Y,1)
   %        for y=1:size(Y,2)
   %            for z=1:size(Y,3)
   %                %if mod(x*(y*z),1000)==0
   %                    jp_progress(x*(y*z), prod(size(Y)));
   %                %end
   %
   %                %if Y(x,y,z)~=0 && ~isnan(Y(x,y,z))
   %                %    Y(x,y,z) = spm_t2z(Y(x,y,z), df);
   %                %end
   %            end
   %        end
   %    end


   % reshape back
   Y = reshape(Y, Ysize);

   % Now write the output volume
   fprintf('done calculating.\nWriting %s...', Vout.fname);
   spm_write_vol(Vout, Y);

   fprintf('done.\n\n');
end

fprintf('\n\nAll done.\n');
