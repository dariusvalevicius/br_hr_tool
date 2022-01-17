dir_contents = dir('data/*.log');
%filenames = dir_contents.name{:};


num_files = length(dir_contents);

t = table('Size', [num_files, 5], 'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'Filename', 'hr_hz', 'hr_bpm', 'br_hz', 'br_bpm'});

for i = 1:num_files
    
    t{i, 1} = string(dir_contents(i).name);
    
    [hr_hz, hr_bpm, br_hz, br_bpm] = get_hr_br(fullfile('data', dir_contents(i).name)); 
    t(i, 2:5) = {hr_hz, hr_bpm, br_hz, br_bpm};

    disp('done');
end

writetable(t, 'leiden_hr_br.txt', 'Delimiter', '\t');
