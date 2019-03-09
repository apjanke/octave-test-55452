function run_bug_55452_tests
  
  this_dir = fileparts (mfilename ("fullpath"));

  # Run all the fixed-text examples
  encoded_files_dir = fullfile (this_dir, "encoded-files");
  ex_names = mydir (encoded_files_dir);
  for i_ex_name = 1:numel (ex_names)
    ex_name = ex_names{i_ex_name};
    ex_dir = fullfile (encoded_files_dir, ex_name);
    run_fixed_text_encoded_file_test (ex_name, ex_dir);
  endfor
endfunction

function run_fixed_text_encoded_file_test (ex_name, ex_dir)
  fprintf ("Running fixed-text encoded file test %s:\n");
  ref_text = slurp_file (fullfile (ex_dir, "ref.txt"), "UTF-8");
  enc_files = mydir ("ex_dir/txt-*.txt");
  for i_enc_file = 1:numel (enc_files)
    enc_file = enc_files{i};
    file_base_name = regexprep (enc_file, "\.txt$", "");
    [encoding,variant] = strsplit (file_base_name(5:end), '@');
    decoded_text = slurp_file (enc_file, encoding);
    ok = isequal (ref_text, decoded_text);
    if ok
      % This display assumes that you're running Octave in a UTF-8 locale, because
      % the descriptive text it's including is in UTF-8
      fprintf ("ok: %s (\"%s\")\n", ex_name, ref_text);
    else
      fprintf ("FAIL: %s (\"%s\")\n", ex_name, ref_text);      
    endif
  endfor
endfunction

function [names, d] = mydir (the_dir_arg)
  d = dir (the_dir_arg);
  names = { d.name };
  tf = !ismember (names, {'.', '..'});
  names = names(tf);
  d = d(tf);
endfunction

function out = slurp_file (file, encoding)
  [fh, msg] = fopen (file, "r", "native", encoding);
  if fh < 0
    error ("Failed opening file for reading: %s: %s", msg, file);
  endif
endfunction
