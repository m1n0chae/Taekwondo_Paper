clc; clear; close all; 

folder_path_main = fileparts(mfilename('fullpath'));  % 현재 파일 폴더 경로 가져오기

raw_data_cell = cell(10,1);


% 폴더 목록
folders = ["subject1_daedo", "subject1_KPNP", "subject2_daedo", "subject2_KPNP", "subject3_daedo", "subject3_KPNP", "subject4_daedo", "subject4_KPNP", "subject5_daedo", "subject5_KPNP"];

% 결과를 저장할 구조체 (각 subject에 대한 Daedo와 KPNP 데이터를 저장)
raw_data_struct = struct('daedo',[],'KPNP',[]);



% 각 폴더를 반복하면서 mat 파일을 로드하고 구조체에 저장
for i = 1:length(folders)
    folder_name = folders(i);
    cd(strcat(folder_path_main,'\',folders(i)))
    temp = load(folders(i));
    raw_data_cell{i,1} = load(folders(i));

    field_names = fields(temp.raw_data);
    if contains(folders(i),'daedo')
        for j = 1:length(field_names)
            if isfield(raw_data_struct.daedo, field_names{j})
                raw_data_struct.daedo.(field_names{j}) = [raw_data_struct.daedo.(field_names{j}); temp.raw_data.(field_names{j})];
            else
                raw_data_struct.daedo.(field_names{j}) = temp.raw_data.(field_names{j});
            end
        end

    else
        for j = 1:length(field_names)
            if isfield(raw_data_struct.KPNP, field_names{j})
                raw_data_struct.KPNP.(field_names{j}) = [raw_data_struct.KPNP.(field_names{j}); temp.raw_data.(field_names{j})];
            else
                raw_data_struct.KPNP.(field_names{j}) = temp.raw_data.(field_names{j});
            end
        end

    end
end

% raw_data_struct를 원하는 파일에 저장

cd(folder_path_main)
save('raw_data_struct.mat', 'raw_data_struct');


%% Find Correlation Between Max force and Velocity of foot 

valid_velocity_of_foot = [];
valid_max_force = [];

for i = 1:length(raw_data_struct.KPNP.preferred)
    if  ~isnan(raw_data_struct.KPNP.preferred(i).max_force) && raw_data_struct.KPNP.preferred(i).velocity_of_foot > 5000
        valid_velocity_of_foot = [valid_velocity_of_foot; raw_data_struct.KPNP.preferred(i).velocity_of_foot];
        valid_max_force = [valid_max_force; raw_data_struct.KPNP.preferred(i).max_force];
    
    end
end
valid_velocity_of_foot = valid_velocity_of_foot*0.001;
valid = [valid_velocity_of_foot valid_max_force];
% 상관계수 계산 (NaN 제외 후)
correlation_matrix = corrcoef(valid_velocity_of_foot, valid_max_force);
correlation_value = correlation_matrix(1, 2);  % 상관계수 값

p = polyfit(valid_velocity_of_foot, valid_max_force, 1); % 1차 다항식 회귀

figure;

hold on;
scatter(valid_velocity_of_foot, valid_max_force, 20,"filled")
plot(valid_velocity_of_foot, polyval(p, valid_velocity_of_foot), 'Color', [0.6350 0.0780 0.1840], 'LineWidth', 2); % 회귀선 플롯
hold off


%% Finding Foot Max speed
a = zeros(100,1);
for i = 1:100
    a(i,1) = raw_data_struct.KPNP.preferred(i).velocity_of_foot;
end

mean(a(a>1000))

%% Plot graph 

% plot (raw_data_struct.KPNP.preferred.velocity)
    
