clc; clear ; close all;


folder_path = fileparts(mfilename('fullpath'));  
cd(folder_path)
tdms_files = dir(fullfile(folder_path, '*.tdms')); 
file_names = {tdms_files.name}; 

% data = tdmsread("T00_DAQ.tdms", ChannelGroupName = "StrainGauge");
temp = cell(length(file_names),1);

for n=0:length(file_names)-1
    if n<=9
        temp{n+1} = tdmsread("T0"+string(n)+"_DAQ.tdms");
        disp("T0"+string(n)+"_DAQ.tdms")
    else
        temp{n+1} = tdmsread("T"+string(n)+"_DAQ.tdms");
        disp("T"+string(n)+"_DAQ.tdms")
    end
end

data = cell(length(file_names),1);

for n=1:length(file_names)
    data{n} = table2array(temp{n,1}{1,1}(:,1:2));
end


%% Data Processing 


%data filtering
data = filtering_function(data);

%data cropping and zeroing
for i = 1:numel(data)
    X = data{i,1};              
    if isempty(X) || ~isnumeric(X)
        warning('data{%d,1}is empty or not a number.', i);
        continue
    end

    peak_col = 1;                   
    peak_col = min(peak_col, size(X,2));
    [~, max_index] = max(X(:, peak_col));   


    i0 = max(1, max_index - 150);
    i1 = min(size(X,1), max_index + 150);

    b0 = max(1, max_index - 150);
    b1 = max(1, max_index - 50);
    if b0 > b1
        b0 = max(1, i0);
        b1 = max(1, min(i1, max_index - 1));
    end

    baseline = mean(X(b0:b1, :), 1);          
    seg = X(i0:i1, :) - baseline;

    data{i,1} = seg * 1e6 * 0.453592 / 0.4095 / 1100;
end

% Data Cropping
data_cropped = cell(length(file_names),1);

for i = 1:numel(data)
    data_cropped{i} = data{i}(100:200,:);
end

data = data_cropped;

% Result Extraction

result_hitting = zeros(length(data),10);
result_hitted = zeros(length(data),10);



load("angle_after_collision.mat")
load("angle.mat")

inertia_moment =  7.5398; 
l = 1.041;
g = 9.81;
m = 13.5;
x0 = 0.0451;
y0 = 0.3856;
alpha = atan(x0/y0);
e = zeros(125,1);

for i = 1:length(data)
    [rs_left,rs_right,rs_left_index, rs_right_index, ~] = get_interval(data{i,1}(:,2));

    % result
    result_hitting(i,1) = angle(i);
    result_hitting(i,2) = trapz(data{i,1}(rs_left_index:rs_right_index,2)*0.0005);      % impulse
    result_hitting(i,3) = max(data{i,1}(:,2));      % maximum force
    result_hitting(i,4) = rs_right-rs_left;      % impact duration
    result_hitting(i,6) = angle_after_collision(i);
    result_hitting(i,7) = (2*m*g/inertia_moment*((l-l*cos(deg2rad(angle(i)))+(x0^2+y0^2)^0.5*cos(deg2rad(angle(i))+alpha)-y0)))^0.5; % w_i
    result_hitting(i,8) = inertia_moment/l*(2*m*g/inertia_moment*((l-l*cos(deg2rad(angle(i)))+(x0^2+y0^2)^0.5*cos(deg2rad(angle(i))+alpha)-y0)))^0.5*1.6; % impulse when e=0.6
    result_hitting(i,8) = (2*m*g/inertia_moment*((l-l*cos(deg2rad(angle_after_collision(i)))+(x0^2+y0^2)^0.5*cos(deg2rad(angle_after_collision(i))+alpha)-y0)))^0.5/(2*m*g/inertia_moment*((l-l*cos(deg2rad(angle(i)))+(x0^2+y0^2)^0.5*cos(deg2rad(angle(i))+alpha)-y0)))^0.5; % e 
    result_hitting(i,9) = rs_left;
    result_hitting(i,10) = rs_right;


    [rs_left,rs_right,rs_left_index, rs_right_index, ~] = get_interval(data{i,1}(:,1));

    result_hitted(i,1) = angle(i);
    result_hitted(i,2) = trapz(data{i,1}(rs_left_index:rs_right_index,1)*0.0005);
    result_hitted(i,3) = max(data{i,1}(:,1));
    result_hitted(i,4) = rs_right-rs_left;
    result_hitted(i,6) = angle_after_collision(i);
    result_hitted(i,7) = -(2*m*g/inertia_moment*((l-l*cos(deg2rad(angle_after_collision(i)))+(x0^2+y0^2)^0.5*cos(deg2rad(angle_after_collision(i))+alpha)-y0)))^0.5; %w_f
    result_hitted(i,8) = inertia_moment/l*(result_hitting(i,7)-result_hitted(i,7)); %theoritical impulse
    result_hitted(i,9) = rs_left;
    result_hitted(i,10) = rs_right;

    e(i,1) = result_hitted(i,7)/result_hitting(i,7);

end



save("result_hitting_0422","result_hitting")
save("result_hitted_0422","result_hitted")



function out = ternary_str(cond, trueStr, falseStr)
    if cond, out = trueStr; else, out = falseStr; end
end
