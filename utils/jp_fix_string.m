function new_string = jp_fix_string(s)

new_string = strrep(s,' ','_');
new_string = strrep(new_string,'>','\>');
new_string = strrep(new_string,'<','\<');
new_string = strrep(new_string,'(','_');
new_string = strrep(new_string,')','_');
new_string = strrep(new_string, '@', '\@');