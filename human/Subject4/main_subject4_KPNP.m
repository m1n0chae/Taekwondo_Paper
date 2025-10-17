clc; clear ; close all;


folders = "preferred";


raw_data = struct();


for i = 1:length(folders)

raw_data.(folders(i)) = [];

folder_path_main = fileparts(mfilename('fullpath')); 
folder_path = strcat(fileparts(mfilename('fullpath')),'\',folders(i));  
cd(folder_path) 
csv_files = dir(fullfile(folder_path, '*.csv'));
file_names_csv = {csv_files.name}; 
trc_files = dir(fullfile(folder_path, '*.trc')); 
file_names_trc = {trc_files.name}; 

data_force_cell = cell(length(file_names_csv),1);
data_location = cell(length(file_names_csv),1);


    for j = 1:length(file_names_csv)

    current_name = readtable(file_names_csv{j},'VariableNamingRule', 'preserve');

    cd(folder_path_main) 
    data_force_cell{j,2} = cropTable(current_name);

    folder_path = strcat(fileparts(mfilename('fullpath')),'\',folders(i));  
    cd(folder_path)

    data_force_cell{j,1} = struct('loadcell', table2array(data_force_cell{j,2}(2:end,3)),'force_plate_force',...
        struct('x',table2array(data_force_cell{j,2}(2:end,6)),'y',table2array(data_force_cell{j,2}(2:end,7)),'z',table2array(data_force_cell{j,2}(2:end,8))),...
        'force_plate_moment', struct('x',table2array(data_force_cell{j,2}(2:end,10)),'y',table2array(data_force_cell{j,2}(2:end,11)),'z', ...
        table2array(data_force_cell{j,2}(2:end,12))),'force_plate_COP',struct('x',table2array(data_force_cell{j,2}(2:end,10)),'y',table2array(data_force_cell{j,2}(2:end,11))));
    data_location{j,1} = read_trcFile(file_names_trc{j});



    end
    
raw_data.(folders(i)) = struct('force',data_force_cell(:,1),'location',data_location);
processed_data.(folders(i)) = struct('force',data_force_cell(:,1),'location',data_location);
end



%% Data organization & Force data Calibration 

fields = {'preferred'};

cut_range = 150;

for f = 1:length(fields)
    for idx = [1:10 12:length(raw_data.(fields{f}))]

        loadcell_data = raw_data.(fields{f})(idx).force.loadcell;
        [~, max_idx] = max(loadcell_data);  

        raw_data.(fields{f})(idx).force.loadcell = raw_data.(fields{f})(idx).force.loadcell(:,:)-mean(raw_data.(fields{f})(idx).force.loadcell(max_idx-100:max_idx-50,:));
        raw_data.(fields{f})(idx).force.loadcell = raw_data.(fields{f})(idx).force.loadcell * 400*100 * 0.3985 / 0.4095 / 1100*9.81 ;  %calibration
        
        start_idx = max(1, max_idx - cut_range);
        end_idx = min(length(loadcell_data), max_idx + cut_range);
        
        raw_data.(fields{f})(idx).force.loadcell = raw_data.(fields{f})(idx).force.loadcell(start_idx:end_idx);
        

    end
end


%% Data Integration 

force = [];
field_names = fieldnames(raw_data);

for i = 1:length(field_names)
    force = horzcat(force, raw_data.(field_names{i}).force);
end

raw_data.total = struct('force',force);


folder_path = strcat(fileparts(mfilename('fullpath')));  
cd(folder_path) 

parts = strsplit(folder_path, '\');

subject_name = char(parts(end));


%% Data Processing _ only total force data

folder_path = strcat(fileparts(mfilename('fullpath')));  
cd(folder_path) 

valid_list = [1:length(raw_data.total.force)];


subject_name_force = strcat(subject_name,'_force');
eval([subject_name_force '=cell(length(raw_data.total.force),1);']);


for i = valid_list 
    [~, max_index] = max(raw_data.total.force(i).loadcell);
    raw_data.total.cropped_force(i).loadcell = raw_data.total.force(i).loadcell();


    eval([subject_name_force '{i,1} = raw_data.total.cropped_force(i).loadcell;']);


end


save((subject_name_force),subject_name_force);

% Result Extraction
result = zeros(length(raw_data.total.force),8);

for i = valid_list
    disp(sprintf('%d th trial',i))

    [rs_left,rs_right,rs_left_index, rs_right_index, ~] = eval(['get_interval(' subject_name_force '{i,1}(:,1));']);

    result(i,1) = eval(['trapz(' subject_name_force '{i,1}(rs_left_index:rs_right_index,1)*0.001);']);      %충격량
    data = eval([subject_name_force '{i,1}(:,1)']);
    result(i,2) = max(data);
    result(i,3) = rs_right-rs_left;    

    result(i,5) = rs_left;
    result(i,6) = rs_left_index;
    result(i,7) = rs_right;
    result(i,8) = rs_right_index;

end

subject_name_result = [subject_name '_result'];
save((subject_name_result),"result");


%% Data Filtering For Paper

idx = [2 4 5 6 8 10 12 13 14 15 16 18 19];
result_for_paper = result(idx,:);
force_for_paper = subject4_KPNP_force(idx,1);


for i = 1:length(force_for_paper)
    x = 0:1/2000:1/2000*(length(force_for_paper{i,1})-1);
    figure;
    plot(x,force_for_paper{i,1});
end

save('force_for_paper','force_for_paper')
save('result_for_paper','result_for_paper')

%% read_trcFile
function q = read_trcFile(fname)

fin = fopen(fname, 'r');	
if fin == -1								
	error(['unable to open ', fname])		
end

nextline = fgetl(fin);
nextline = fgetl(fin);
nextline = fgetl(fin);

values = sscanf(nextline, '%f %f %f %f');
numframes = values(3);
q.nummarkers = values(4);
numcolumns=3*q.nummarkers+2;

nextline = fgetl(fin);
q.labels = cell(1, q.nummarkers+2);
[q.labels{1}, nextline] = strtok(nextline); % should be Frame#
[q.labels{2}, nextline] = strtok(nextline); % should be Time
for i=1:q.nummarkers
	[markername, nextline] = strtok(nextline);
    q.labels{2+i} = markername;
end

nextline = fgetl(fin);

data = fscanf(fin, '%f', [numcolumns, numframes])';
% assert(data(end) ~= 0, 'Empty data exists!')
q.frame = data(:, 1);
q.time = data(:, 2);
for i = 1:numel(q.labels)-2
    label = strrep(q.labels{i+2}, '.', '_');
    if ~isempty(regexp(label, '*', 'once')), continue, end
    q.(label) = struct('x', data(:, 3*i), ...
        'y', data(:, 3*i+1), ...
        'z', data(:, 3*i+2));
end
fclose(fin);

end

%% Get Interval

function [rs_left, rs_right, rs_left_index, rs_right_index, maxT] = get_interval(signal)
[max_sig, max_idx] = max(signal);
th1 = 0.02*max_sig;
s = sort(signal(max_idx:end));
th2 = 0.02*max_sig + 0.99*mean(s(round(length(s)*0.5):round(length(s)*0.9)));
sam_freq = 1000;

for i = 1:max_idx-1
    rs_left = i;
    if (signal(max_idx-i-1)-th1)*(signal(max_idx-i)-th1) <= 0
        rs_left_index = ((max_idx-i-1)-1);
        rs_left = ((max_idx-i-1)-1)/sam_freq;

        break
    else
        continue
    end
end

for i = 1:(length(signal)-max_idx-1)
    rs_right = i;
    if (signal(max_idx+i+1)-th2)*(signal(max_idx+i)-th2) <= 0
        rs_right_index = (max_idx+i);
        rs_right = (max_idx+i)/sam_freq;

        break
    else
        continue
    end
end

maxT = (max_idx-1)/sam_freq;
end



%% Crop Table
function croppedTable = cropTable(inputTable)
    arr = table2array(inputTable(:,1));
    nanIndices = find(isnan(arr),2);

    croppedTable = inputTable(1:nanIndices(2)-1, :);
end
