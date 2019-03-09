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
  fprintf ("Running fixed-text encoded file test %s:\n", ex_name);
  ref_text = read_one_line_utf8 (fullfile (ex_dir, "ref.txt"), "UTF-8");
  fprintf("Reference text: %s (%d chars)\n", ref_text, numel (ref_text));
  enc_files = mydir ([ex_dir "/txt-*.txt"]);
  for i_enc_file = 1:numel (enc_files)
    enc_file = enc_files{i_enc_file};
    file_base_name = regexprep (enc_file, "\.txt$", "");
    parts = strsplit (file_base_name(5:end), '@');
    encoding = parts{1};
    if numel (parts) > 1
      variant = parts{2};
    else
      variant = '';
    endif
    fprintf ("running: %s %s %s\n", ex_name, encoding, variant);
    fprintf ("  fgetl:\n");
    decoded_text = read_one_line_fgetl (fullfile (ex_dir, enc_file), encoding);
    check_line (ex_name, encoding, variant, 'fgetl', ref_text, decoded_text);
    fprintf ("  textscan:\n");
    decoded_text = read_one_line_textscan (fullfile (ex_dir, enc_file), encoding);
    check_line (ex_name, encoding, variant, 'textscan', ref_text, decoded_text);
  endfor
endfunction

function check_line (ex_name, encoding, variant, technique, ref_text, decoded_text)
  fprintf ("    decoded: %s (%d chars)\n", decoded_text, numel (decoded_text));
  ok = isequal (ref_text, decoded_text);
  if ok
    fprintf ("    ok: %s %s %s - %s\n", ex_name, encoding, variant, technique);
  else
    fprintf ("    FAIL: %s %s %s - %s\n", ex_name, encoding, variant, technique);
  endif  
endfunction

function [names, d] = mydir (the_dir_arg)
  d = dir (the_dir_arg);
  names = { d.name };
  tf = !ismember (names, {'.', '..', '.DS_Store'});
  names = names(tf);
  d = d(tf);
endfunction

function fid = my_fopen (file, encoding)
  [fid, msg] = fopen (file, "r", "native", encoding);
  if fid < 0
    error ("Failed opening file for reading: %s: %s", msg, file);
  endif  
endfunction

function out = read_one_line_fgetl (file, encoding)
  fid = my_fopen (file, encoding);
  out = fgetl (fid);
  fclose (fid);
endfunction

function out = read_one_line_textscan (file, encoding)
  fid = my_fopen (file, encoding);
  lines = textscan (fid, "%s", "Delimiter","");
  out = lines{1}{1};
  out = out(:)';
  fclose (fid);
endfunction

function out = read_one_line_utf8 (file)
  % Do a binary read because no transcoding is necessary or desired here
  [fid, msg] = fopen (file, "r");
  if fid < 0
    error ("Failed opening file for reading: %s: %s", msg, file);
  endif
  bytes = fread (file, Inf, '*char');
  fclose (fid);
  txt = bytes(:)';
  LFs = find (txt == "\n");
  if !isempty (LFs)
    txt(LFs(1):end) = [];
  endif
  out = txt;
endfunction
