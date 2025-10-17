clc; clear ; close all;


% 폴더 리스트
folders = ["preferred", "weak_short", "weak_long", "middle_long", "middle_short", "strong_short", "strong_long"];


data = struct();


for i = 1:length(folders)

a = folders(i);
data.a = [];
folder_path = fileparts(mfilename('fullpath'));  % 현재 파일 폴더 경로 가져오기
cd(strcat(folder_path,'\',folders(i))) %현재 파일로 폴더 경로 바꾸기
csv_files = dir(fullfile(folder_path, '*.csv')); % 폴더 내의 csv 파일 목록 불러오기
file_names_csv = {csv_files.name}; % 파일 이름만 추출
trc_files = dir(fullfile(folder_path, '*.trc')); % 폴더 내의 csv 파일 목록 불러오기
file_names_trc = {trc_files.name}; % 파일 이름만 추출




end

data_force_cell = cell(length(file_names_csv),1);
data_location = cell(length(file_names_csv),1);


for i = 1:length(file_names_csv)
    temp = readtable(file_names_csv{i},'VariableNamingRule', 'preserve');
    data_force_cell{i,2} = cropTable(temp);
    data_force_cell{i,1} = struct('loadcell', table2array(data_force_cell{i,2}(2:end,3)),'force_plate_force',...
    struct('x',table2array(data_force_cell{i,2}(2:end,6)),'y',table2array(data_force_cell{i,2}(2:end,7)),'z',table2array(data_force_cell{i,2}(2:end,8))),...
    'force_plate_moment', struct('x',table2array(data_force_cell{i,2}(2:end,10)),'y',table2array(data_force_cell{i,2}(2:end,11)),'z', ...
    table2array(data_force_cell{i,2}(2:end,12))),'force_plate_COP',struct('x',table2array(data_force_cell{i,2}(2:end,10)),'y',table2array(data_force_cell{i,2}(2:end,11))));
    data_location{i,1} = read_trcFile(file_names_trc{i});
end


