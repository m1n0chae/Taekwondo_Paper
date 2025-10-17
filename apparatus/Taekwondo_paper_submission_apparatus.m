clc; clear; close all;

% Load
load('result_hitted_0422.mat')
load('result_hitting_0422.mat')
load('data_cropped.mat')     % 'data' (또는 data_cropped) 포함 가정
% load('force_data.mat')  % 필요 시만

% Sizes / helpers
N_TR = size(result_hitting, 1);   % 전체 trial 수
Fs   = 2000;

%% Impulse 계산 (열 12, 13 생성/갱신)
inertia_moment = 7.5398;
l = 1.041;

if size(result_hitting,2) < 12, result_hitting(:,12) = 0; end
for i = 1:N_TR
    result_hitting(i,12) = inertia_moment/l * result_hitting(i,7) * (1+result_hitting(i,11));
end

if size(result_hitting,2) < 13, result_hitting(:,13) = 0; end
if size(result_hitted ,2) < 13, result_hitted(:,13)  = 0; end

result_hitting(:,13) = result_hitting(:,3) .* result_hitting(:,4) / 3;
result_hitted(:,13)  = result_hitted(:,3)  .* result_hitted(:,4)  / 3;

%% 자리만 생성(필요 시)
num_trials = numel(data_cropped);  % data_cropped{i,1} 파형 기준
max_impact_force_fitting_hitted = zeros(num_trials,1);
contact_time_fitting_hitted     = zeros(num_trials,1);
impulse_values_fitting_hitted   = zeros(num_trials,1);
impulse_theory_fitting_hitted   = zeros(num_trials,1);

impulse_values_fitting_hitting  = zeros(num_trials,1);
max_impact_force_fitting_hitting= zeros(num_trials,1);
contact_time_fitting_hitting    = zeros(num_trials,1);
impulse_theory_fitting_hitting  = zeros(num_trials,1);

%% Check Raw data (샘플 몇 개)
x_data_hitting = 0:1/Fs:100/Fs;
figure;
sample_list = 1:min(5, N_TR);
for k = 1:numel(sample_list)
    i = sample_list(k);
    subplot(1,5,k);
    hold on;
    if i <= numel(data_cropped) && ~isempty(data_cropped{i,1})
        plot(x_data_hitting', data_cropped{i,1}(:,2), 'b')
        plot(x_data_hitting', data_cropped{i,1}(:,1), 'r')
    end
    if size(result_hitting,2) >= 10
        xline(result_hitting(i,9)  - 100/Fs)
        xline(result_hitting(i,10) - 100/Fs)
    end
    hold off
    ylim([0 600]); title(sprintf('Trial %d',i));
end


%% Figure 1-2) Raw data 
index_weak_abs   = min(3, numel(data_cropped));
index_strong_abs = min(5, numel(data_cropped));

clc; close all;
figure(1200); set(gcf,'Position',[680 458 240 230]);
ax = gca; set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial','LineWidth',1,'Box','off','TickDir','out');

x = linspace(0, size(data_cropped{index_weak_abs,1},1)*0.0005, size(data_cropped{index_weak_abs,1},1))*1000-10;
y_striking_weak   = data_cropped{index_weak_abs,1}(:,2)*0.001;
y_impacted_weak   = data_cropped{index_weak_abs,1}(:,1)*0.001;
y_striking_strong = data_cropped{index_strong_abs,1}(:,2)*0.001;
y_impacted_strong = data_cropped{index_strong_abs,1}(:,1)*0.001;

hold on
plot(x+1.5, y_striking_weak,  'LineWidth',1.5,'Color',[0, 0, 204/255]);
plot(x+1.5, y_impacted_weak,  'LineWidth',1.5,'Color',[192/255, 0, 0]);
plot(x-1,   y_striking_strong,'LineWidth',2.5,'Color',[0, 0, 204/255]);
plot(x-1,   y_impacted_strong,'LineWidth',2.5,'Color',[192/255, 0, 0]);
hold off

grid on; xlabel('Time (ms)'); ylabel('Force (kN)');
ylim([-0.5 3]); xlim([-10 40]); xticks(0:10:50); yticks(0:1:3);


%% Figure 1-3 ) Raw data (Stronger one) 
pad_len = 300; dt_ms = 1/Fs*1000; t_shift = -10;

y_ss = data_cropped{index_strong_abs,1}(:,2)*0.001;
y_is = data_cropped{index_strong_abs,1}(:,1)*0.001;
Ns = numel(y_ss);
z  = zeros(pad_len,1);
y_ss_p = [z; y_ss; z];
y_is_p = [z; y_is; z];
x_s_p  = ((-pad_len):(Ns-1+pad_len))*dt_ms + t_shift;

clc; close all;
figure(1300); clf; set(gcf,'Position',[680 458 240 230])
ax = gca; set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial','LineWidth',1,'Box','off','TickDir','out')
hold on
plot(x_s_p - 8, y_ss_p, 'LineWidth',1.5,'Color',[0 0 204/255])
plot(x_s_p - 8, y_is_p, 'LineWidth',1.5,'Color',[192/255 0 0])
hold off
grid on; xlabel('Time (ms)'); ylabel('Force (kN)');
xlim([-10 40]); ylim([-2 12]); xticks(0:10:40); yticks(0:4:12)

%% Figure 2-1) Angle vs Rebound Angle 
x_data       = result_hitting(:,1);
y_data_angle = result_hitted(:,6);
ux = unique(x_data);
mean_y_angle = arrayfun(@(x) mean(y_data_angle(x_data==x)), ux);
std_y_angle  = arrayfun(@(x) std( y_data_angle(x_data==x)), ux);

y_data_striking7 = result_hitting(:,7);
y_data_impacted7 = result_hitted(:,7);
mean_y_striking7 = arrayfun(@(x) mean(y_data_striking7(x_data==x)), ux);
std_y_striking7  = arrayfun(@(x) std( y_data_striking7(x_data==x)), ux);
mean_y_impacted7 = arrayfun(@(x) mean(y_data_impacted7(x_data==x)), ux);
std_y_impacted7  = arrayfun(@(x) std( y_data_impacted7(x_data==x)), ux);

close all;
figure(3100);
set(gcf, 'Position', [680 458 240 230]);

errorbar(ux, mean_y_angle, std_y_angle, 'o-', 'Color', [0, 0, 0], ...
         'MarkerFaceColor', [0, 0, 0],  'MarkerSize', 3,'CapSize', 2, 'LineWidth', 0.75, 'LineStyle', '-');
hold off;
grid on;

xlim([20, 80])
ylim([10, 50])
xticks(20:10:80)

ax = gca;
ax.LineWidth = 1;
ax.FontWeight = 'bold';
ax.FontSize   = 8;
ax.FontName   = 'Arial';

ax = gca;
set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial',...
       'LineWidth',1,'Box','off','TickDir','out');
xlabel('Angle (deg)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');
ylabel('Rebound Angle (deg)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');


%% Figure 2-2) Angle vs e (전체) 

x_data = result_hitting(:,1);         
y_data_striking_e = result_hitting(:,8); 

ux = unique(x_data);
mean_y_e = arrayfun(@(x) mean(y_data_striking_e(x_data == x)), ux);
std_y_e  = arrayfun(@(x) std( y_data_striking_e(x_data == x)),  ux);

clc; close all;
figure(2200); set(gcf,'Position',[680 458 240 230]); hold on;
errorbar(ux, mean_y_e, std_y_e, 'o-', 'Color',[0 0 0], ...
         'MarkerFaceColor',[0 0 0], 'MarkerSize',3, 'CapSize',2, ...
         'LineWidth',0.75, 'LineStyle','-');
hold off; grid on;

ylim([0.5 0.65]);
ax = gca; ax.LineWidth = 1; ax.FontWeight = 'bold'; ax.FontSize = 8; ax.FontName = 'Arial';
ax.XTick = ux;

xlabel('Angle (deg)', 'FontWeight','bold', 'FontSize',9, 'FontName','Arial');
ylabel('Coefficient of Restitution', 'FontWeight','bold', 'FontSize',9, 'FontName','Arial');



%% Figure 2-3) Impulse 비교 (전체)
x_data    = result_hitting(:,1);
y_data_striking  = result_hitting(:,2);
y_data_impacted  = result_hitted(:,2);
y_data_calculated    = result_hitting(:,8);
y_data_impulse = result_hitting(:,12);
y_data_striking_triangle   = result_hitting(:,13);
y_data_impacted_triangle   = result_hitted(:,13);

% ==== (2) 고유 x 및 평균, 표준편차 계산 ====
unique_x = unique(x_data);

mean_y_striking = arrayfun(@(x) mean(y_data_striking(x_data == x)), unique_x);
std_y_striking  = arrayfun(@(x) std(y_data_striking(x_data == x)),  unique_x);

mean_y_impacted = arrayfun(@(x) mean(y_data_impacted(x_data == x)), unique_x);
std_y_impacted  = arrayfun(@(x) std(y_data_impacted(x_data == x)),  unique_x);

mean_y_impulse = arrayfun(@(x) mean(y_data_impulse(x_data == x)), unique_x);
std_y_impulse  = arrayfun(@(x) std(y_data_impulse(x_data == x)),  unique_x);


mean_y_calc = arrayfun(@(x) mean(y_data_calculated(x_data == x)), unique_x);
std_y_calc  = arrayfun(@(x) std(y_data_calculated(x_data == x)),  unique_x);


mean_striking_triangle = arrayfun(@(x) mean(y_data_striking_triangle(x_data == x)), unique_x);
std_striking_triangle  = arrayfun(@(x) std(y_data_striking_triangle(x_data == x)),  unique_x);


mean_impacted_triangle = arrayfun(@(x) mean(y_data_impacted_triangle(x_data == x)), unique_x);
std_impacted_triangle  = arrayfun(@(x) std(y_data_impacted_triangle(x_data == x)),  unique_x);



% ==== (3) Figure 생성 및 플롯 ====
clc; close all;
figure(2300);
set(gcf, 'Position', [680, 458, 240, 230]);
hold on;

% --- 기존 장비: striking (파랑), impacted (빨강), calculated (검정?)
% errorbar(unique_x, mean_y_striking, std_y_striking, 'o-', 'Color', [0, 0, 204/255], ...
%          'MarkerFaceColor', [0, 0, 204/255], 'MarkerSize', 3, 'CapSize', 2, 'LineWidth', 0.75);
% errorbar(unique_x, mean_y_impacted, std_y_impacted, 'o-', 'Color', [192/255, 0, 0], ...
%          'MarkerFaceColor', [192/255, 0, 0],  'MarkerSize', 3,'CapSize', 2, 'LineWidth', 0.75);
errorbar(unique_x, mean_y_impulse, std_y_impulse, 'o-', 'Color', [0, 0, 0], ...
         'MarkerFaceColor', [0, 0, 0], 'MarkerSize', 3, 'CapSize', 2, 'LineWidth', 0.75, 'LineStyle', '-');
plot(unique_x, mean_y_calc, 'o-', ...
     'Color', [0,0,0], 'MarkerFaceColor', [0,0,0], ...
     'MarkerSize',3, 'LineWidth',0.75, 'LineStyle','None');

% errorbar(unique_x, mean_striking_triangle, std_striking_triangle, 'o-', 'Color', [0, 191/255, 255/255], ...
%          'MarkerFaceColor', [0, 191/255, 255/255],  'MarkerSize', 3,'CapSize', 2, 'LineWidth', 1.5, 'LineStyle', ':');
% errorbar(unique_x, mean_impacted_triangle, std_impacted_triangle, 'o-', 'Color', [255/255, 165/255, 0], ...
%          'MarkerFaceColor', [255/255, 165/255, 0], 'MarkerSize', 3, 'CapSize', 2, 'LineWidth', 2, 'LineStyle', ':');


hold off;
grid on;

xlim([20, 80])
ylim([0, 50])
ax = gca;
ax.LineWidth = 1;
ax.FontWeight= 'bold';
ax.FontSize  = 8;
ax.FontName  = 'Arial';
ax.XTick     = unique_x;
ax.YTick     = [0,10,20,30,40,50,60];

xlabel('Angle (deg)', 'FontWeight','bold', 'FontSize',9, 'FontName','Arial');
ylabel('Impulse (Ns)', 'FontWeight','bold', 'FontSize',9, 'FontName','Arial');


%% Figure 3-1) 타격기의 Angle에 따른 Max Force (양 옆에 그리기)

% % scatter(result_hitting(:,1), result_hitting(:,3), 50, [0, 0, 204/255], 'filled');  % 원본 데이터
% % scatter(result_hitted(:,1), result_hitted(:,3), 50, [192/255, 0, 0], 'filled');  % 원본 데이터
% 


% X축 데이터 (Striking Object Angle)
x_data = result_hitting(:,1);

% Y축 데이터 (Max Force)
y_data_striking = result_hitting(:,3);
y_data_impacted = result_hitted(:,3);


% 고유한 x 값 찾기
unique_x = unique(x_data);

% Striking Object의 평균 및 표준편차 계산
mean_y_striking = arrayfun(@(x) mean(y_data_striking(x_data == x)), unique_x);
std_y_striking = arrayfun(@(x) std(y_data_striking(x_data == x)), unique_x);

% Impacted Object의 평균 및 표준편차 계산
mean_y_impacted = arrayfun(@(x) mean(y_data_impacted(x_data == x)), unique_x);
std_y_impacted = arrayfun(@(x) std(y_data_impacted(x_data == x)), unique_x);


% 새로운 Figure 생성 (좌우로 긴 형태)

clc;close all;
figure(2100);
set(gcf, 'Position', [680 458 240 230]); % Figure 크기 고정 (x, y, width, height)

hold on;

% 첫 번째 그래프: Maximum Force By Angle

errorbar(unique_x, mean_y_striking*0.001, std_y_striking*0.001, 'o-', 'Color', [0, 0, 204/255], ...
         'MarkerFaceColor', [0, 0, 204/255], 'MarkerSize', 3, 'CapSize', 2, 'LineWidth', 0.75);
errorbar(unique_x, mean_y_impacted*0.001, std_y_impacted*0.001, 'o-', 'Color', [192/255, 0, 0], ...
         'MarkerFaceColor', [192/255, 0, 0],  'MarkerSize', 3,'CapSize', 2, 'LineWidth', 0.75);

% legend({'Striking Object', 'Impacted Object'}, 'FontSize', 5, 'FontWeight', 'bold', 'FontName', 'Arial');

% plot(unique_x, mean_y_striking*0.001, 'o-', ...
%      'Color', [0,0,204/255], 'MarkerFaceColor', [0,0,204/255], ...
%      'MarkerSize',3, 'LineWidth',1.5, 'LineStyle',':');
% plot(unique_x, mean_y_impacted*0.001, 'o-', ...
%      'Color',  [192/255, 0, 0], 'MarkerFaceColor', [192/255, 0, 0], ...
%      'MarkerSize',3, 'LineWidth',1.5, 'LineStyle',':');

hold off

grid on;

xlim([20 80])
ylim([0 10])

% X축, Y축 두껍게 설정
ax = gca;
ax.LineWidth = 1; % X, Y축 두께 설정
ax.FontWeight = 'bold'; % 축 글씨 Bold 처리
ax.FontSize = 8; % 글씨 크기 설정
ax.FontName = 'Arial'; % 글꼴 설정
ax.XTick = unique_x; % X축 Ticks 설정
ax.YTick = yticks; % Y축 Ticks 그대로 유지

% X, Y Label 스타일 적용
xlabel('Angle (deg)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');
ylabel('Maximum Force (kN)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');

hold off;


%% Figure 3-2) 타격기의 Angle에 따른 Impact Duration (양 옆에 그리기)

% ==== (1) 데이터 준비 ====
% 기존 데이터
x_data = result_hitting(:,1);
y_data_striking = result_hitting(:,4);
y_data_impacted = result_hitted(:,4);


% ==== (2) 고유한 x값 및 평균, 표준편차 계산 ====
% (가) 기존 장비
unique_x = unique(x_data);

mean_y_striking = arrayfun(@(x) mean(y_data_striking(x_data == x)), unique_x);
std_y_striking  = arrayfun(@(x) std(y_data_striking(x_data == x)),  unique_x);

mean_y_impacted = arrayfun(@(x) mean(y_data_impacted(x_data == x)), unique_x);
std_y_impacted  = arrayfun(@(x) std(y_data_impacted(x_data == x)),  unique_x);


% ==== (3) Figure 생성 및 플롯 ====
clc; close all;
figure(2200);
set(gcf, 'Position', [680, 458, 240, 230]); % Figure 크기 고정 (x, y, width, height)
hold on;
errorbar(unique_x, mean_y_striking*1000, std_y_striking*1000, 'o-', 'Color', [0, 0, 204/255], ...
         'MarkerFaceColor', [0, 0, 204/255], 'MarkerSize', 3, 'CapSize', 2, 'LineWidth', 0.75);
errorbar(unique_x, mean_y_impacted*1000, std_y_impacted*1000, 'o-', 'Color', [192/255, 0, 0], ...
         'MarkerFaceColor', [192/255, 0, 0],  'MarkerSize', 3,'CapSize', 2, 'LineWidth', 0.75);

% plot(unique_x, mean_y_striking*1000, 'o-', ...
%      'Color', [0,0,204/255], 'MarkerFaceColor', [0,0,204/255], ...
%      'MarkerSize',3, 'LineWidth',1.5, 'LineStyle',':');
% plot(unique_x, mean_y_impacted*1000, 'o-', ...
%      'Color',  [192/255, 0, 0], 'MarkerFaceColor', [192/255, 0, 0], ...
%      'MarkerSize',3, 'LineWidth',1.5, 'LineStyle',':');


hold off;
grid on;

xlim([20, 80])
ylim([0, 50])

% 축 스타일
ax = gca;
ax.LineWidth = 1;
ax.FontWeight = 'bold';
ax.FontSize   = 8;
ax.FontName   = 'Arial';

ax.XTick = unique_x; % (필요시 daedo 측도 함께 설정 가능)
xlabel('Angle (deg)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');
ylabel('Impact Duration (ms)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');






%% Figure 3-3) 타격기의 Angle에 따른 Impulse (양 옆에 그리기)

% ==== (1) 데이터 준비 ====
x_data = result_hitting(:,1);
y_data_striking   = result_hitting(:,2);
y_data_impacted   = result_hitted(:,2);
y_data_calculated = result_hitting(:,8);  % (추가 계산된 이론값?)
y_data_impulse = result_hitting(:,12);
y_data_striking_triangle = result_hitting(:,13);
y_data_impacted_triangle = result_hitted(:,13);


% ==== (2) 고유 x 및 평균, 표준편차 계산 ====
unique_x = unique(x_data);

mean_y_striking = arrayfun(@(x) mean(y_data_striking(x_data == x)), unique_x);
std_y_striking  = arrayfun(@(x) std(y_data_striking(x_data == x)),  unique_x);

mean_y_impacted = arrayfun(@(x) mean(y_data_impacted(x_data == x)), unique_x);
std_y_impacted  = arrayfun(@(x) std(y_data_impacted(x_data == x)),  unique_x);

mean_y_impulse = arrayfun(@(x) mean(y_data_impulse(x_data == x)), unique_x);
std_y_impulse  = arrayfun(@(x) std(y_data_impulse(x_data == x)),  unique_x);


mean_y_calc = arrayfun(@(x) mean(y_data_calculated(x_data == x)), unique_x);
std_y_calc  = arrayfun(@(x) std(y_data_calculated(x_data == x)),  unique_x);


mean_striking_triangle = arrayfun(@(x) mean(y_data_striking_triangle(x_data == x)), unique_x);
std_striking_triangle  = arrayfun(@(x) std(y_data_striking_triangle(x_data == x)),  unique_x);


mean_impacted_triangle = arrayfun(@(x) mean(y_data_impacted_triangle(x_data == x)), unique_x);
std_impacted_triangle  = arrayfun(@(x) std(y_data_impacted_triangle(x_data == x)),  unique_x);



% ==== (3) Figure 생성 및 플롯 ====
clc; close all;
figure(2300);
set(gcf, 'Position', [680, 458, 240, 230]);
hold on;

% --- 기존 장비: striking (파랑), impacted (빨강), calculated (검정?)
errorbar(unique_x, mean_y_striking, std_y_striking, 'o-', 'Color', [0, 0, 204/255], ...
         'MarkerFaceColor', [0, 0, 204/255], 'MarkerSize', 3, 'CapSize', 2, 'LineWidth', 0.75);
errorbar(unique_x, mean_y_impacted, std_y_impacted, 'o-', 'Color', [192/255, 0, 0], ...
         'MarkerFaceColor', [192/255, 0, 0],  'MarkerSize', 3,'CapSize', 2, 'LineWidth', 0.75);
% errorbar(unique_x, mean_y_impulse, std_y_impulse, 'o-', 'Color', [0, 128/255, 0], ...
%          'MarkerFaceColor', [0, 128/255, 0], 'MarkerSize', 3, 'CapSize', 2, 'LineWidth', 2, 'LineStyle', ':');
% plot(unique_x, mean_y_calc, 'o-', ...
%      'Color', [0,0,0], 'MarkerFaceColor', [0,0,0], ...
%      'MarkerSize',3, 'LineWidth',1.5, 'LineStyle',':');
% 
errorbar(unique_x, mean_striking_triangle, std_striking_triangle, 'o-', 'Color', [0, 191/255, 255/255], ...
         'MarkerFaceColor', [0, 191/255, 255/255],  'MarkerSize', 3,'CapSize', 2, 'LineWidth', 1, 'LineStyle', 'None');
errorbar(unique_x, mean_impacted_triangle, std_impacted_triangle, 'o-', 'Color', [255/255, 165/255, 0], ...
         'MarkerFaceColor', [255/255, 165/255, 0], 'MarkerSize', 3, 'CapSize', 2, 'LineWidth', 1, 'LineStyle', 'None');


hold off;
grid on;

xlim([20, 80])
ylim([0, 50])
ax = gca;
ax.LineWidth = 1;
ax.FontWeight= 'bold';
ax.FontSize  = 8;
ax.FontName  = 'Arial';
ax.XTick     = unique_x;
ax.YTick     = [0,10,20,30,40,50,60];

xlabel('Angle (deg)', 'FontWeight','bold', 'FontSize',9, 'FontName','Arial');
ylabel('Impulse (Ns)', 'FontWeight','bold', 'FontSize',9, 'FontName','Arial');


%% Figure 4-1) Max Force 회귀(전체, intercept=0)
clc;
mdl_max_force = fitlm(result_hitted(:,3), result_hitting(:,3), 'Intercept', false);
disp(mdl_max_force)

mask_force = result_hitted(:,3) < 3000;  % 가중 예시
mdl_max_force_weight = fitlm(result_hitted(mask_force,3), result_hitting(mask_force,3), 'Intercept', false);

xv = result_hitting(:,3);
yv = result_hitted(:,3);
ft = fittype('a*x','independent','x','coefficients','a');
linear_fit_maxforce = fit(xv, yv, ft);
y_pred = linear_fit_maxforce.a * xv;
ss_res = sum((yv - y_pred).^2);
ss_tot = sum((yv - mean(yv)).^2);
r2_A   = 1 - (ss_res / ss_tot);
disp(['R-squared on Maximum Force (No Intercept): ', num2str(r2_A)]);

x_fit = linspace(0, max(xv), 100);
y_fit = linear_fit_maxforce.a * x_fit;

close all; figure(3100); set(gcf,'Position',[680 458 240 230]);
plot(result_hitting(:,3)*0.001, result_hitted(:,3)*0.001, 'o','MarkerSize',3, ...
     'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]); hold on;
plot(x_fit*0.001, y_fit*0.001, 'Color',[0.3 0.3 0.3 0.5], 'LineWidth',1.5);
xlabel('Maximum Force by Striking (kN)','FontWeight','bold','FontSize',9,'FontName','Arial');
ylabel('Maximum Force by Impacted (kN)','FontWeight','bold','FontSize',9,'FontName','Arial');
grid on; xlim([0 12]); ylim([0 12]); xticks(0:3:12); yticks(0:3:12);
text(12*0.05,12*0.9,['R^2 = ',num2str(r2_A, '%.4f')],'FontSize',10,'FontName','Arial');
ax=gca; set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial','LineWidth',1,'Box','off','TickDir','out');

%% Figure 4-2) Impact duration 회귀(전체, intercept=0)
mdl_impact_duration = fitlm(result_hitted(:,4), result_hitting(:,4), 'Intercept', false);
disp(mdl_impact_duration)

mask_dur = result_hitted(:,4) < 0.035 & result_hitted(:,4) > 0.015;
mdl_impact_duration_weight = fitlm(result_hitted(mask_dur,4), result_hitting(mask_dur,4), 'Intercept', false);

xv = result_hitting(:,4);
yv = result_hitted(:,4);
linear_fit_impact_duration = fit(xv, yv, ft);

y_pred = linear_fit_impact_duration.a * xv;
ss_res = sum((yv - y_pred).^2);
ss_tot = sum((yv - mean(yv)).^2);
r2_sig = 1 - (ss_res / ss_tot);
disp(['R-squared on Impact Duration (No Intercept): ', num2str(r2_sig)]);
disp(['a :', num2str(linear_fit_impact_duration.a)]);

close all; figure(3200); set(gcf,'Position',[680 458 240 230]); hold on;
x_fit = linspace(0, max(xv), 100);
y_fit = linear_fit_impact_duration.a * x_fit;
plot(result_hitting(:,4)*1000, result_hitted(:,4)*1000, 'o','MarkerSize',3, ...
     'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
plot(x_fit*1000, y_fit*1000, 'Color',[0.3 0.3 0.3 0.5],'LineWidth',1.5);
hold off;
xlabel('Impact Duration by Striking (ms)','FontWeight','bold','FontSize',9,'FontName','Arial');
ylabel('Impact Duration by Impacted (ms)','FontWeight','bold','FontSize',9,'FontName','Arial');
grid on; xlim([0 50]); ylim([0 50]); xticks(0:10:50); yticks(0:10:50);
text(50*0.05,50*0.9,['R^2 = ',num2str(r2_sig, '%.4f')],'FontSize',10,'FontName','Arial');
ax=gca; set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial','LineWidth',1,'Box','off','TickDir','out');

%% Figure 4-3) Impulse 회귀(전체, intercept=0)
mdl_impulse = fitlm(result_hitted(:,2), result_hitting(:,2), 'Intercept', false);
disp(mdl_impulse)

xv = result_hitting(:,2);
yv = result_hitted(:,2);
linear_fit_impulse = fit(xv, yv, ft);

y_pred = linear_fit_impulse.a * xv;
ss_res = sum((yv - y_pred).^2);
ss_tot = sum((yv - mean(yv)).^2);
r2_imp = 1 - (ss_res / ss_tot);
disp(['R-squared on Impulse (No Intercept): ', num2str(r2_imp)]);
disp(['a :', num2str(linear_fit_impulse.a)]);

close all; figure(3300); set(gcf,'Position',[680 458 240 230]); hold on;
plot(result_hitting(:,2), result_hitted(:,2), 'o','MarkerSize',3, ...
     'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
x_fit = linspace(0, max(xv), 100);
y_fit = linear_fit_impulse.a * x_fit;
plot(x_fit, y_fit, 'Color',[0.3 0.3 0.3 0.5],'LineWidth',1.5);
hold off;
xlabel('Impulse by Striking (Ns)','FontWeight','bold','FontSize',9,'FontName','Arial');
ylabel('Impulse by Impacted (Ns)','FontWeight','bold','FontSize',9,'FontName','Arial');
grid on; xlim([0 40]); ylim([0 40]); xticks(0:8:40); yticks(0:8:40);
text(40*0.05,40*0.9,['R^2 = ',num2str(r2_imp, '%.4f')],'FontSize',10,'FontName','Arial');
ax=gca; set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial','LineWidth',1,'Box','off','TickDir','out');

%% nRMSE, MAPE 
coef_maxF  = mdl_max_force.Coefficients.Estimate(1);
coef_sigma = mdl_impact_duration.Coefficients.Estimate(1);
coef_imp   = mdl_impulse.Coefficients.Estimate(1);

nRMSE_array = nan(N_TR,1);
for i = 1:min(N_TR, numel(data_cropped))
    true_force = data_cropped{i,1}(:,2);
    est_force  = data_cropped{i,1}(:,1) * coef_maxF;
    rmse  = sqrt( mean( (true_force - est_force).^2 ) );
    nRMSE_array(i) = rmse / max(true_force);
end

true_maxF = result_hitting(:,3);
true_sigma= result_hitting(:,4);
true_imp  = result_hitting(:,2);

est_maxF  = result_hitted(:,3) * coef_maxF;
est_sigma = result_hitted(:,4) * coef_sigma;
est_imp   = result_hitted(:,2) * coef_imp;

mape_maxF  = mean(abs((true_maxF  - est_maxF ) ./ true_maxF )) * 100;
mape_sigma = mean(abs((true_sigma - est_sigma) ./ true_sigma)) * 100;
mape_imp   = mean(abs((true_imp   - est_imp  ) ./ true_imp  )) * 100;

clc; disp('---------------- MAPE & nRMSE (All) ----------------');
disp(['MAPE in Max Force (%)        : ', num2str(mape_maxF)]);
disp(['MAPE in Impact Duration (%)  : ', num2str(mape_sigma)]);
disp(['MAPE in Impulse (%)          : ', num2str(mape_imp)]);
disp('-----------------------------------------------------');

mean_nRMSE = mean(nRMSE_array, 'omitnan');
std_nRMSE  = std(nRMSE_array, 0, 'omitnan');
fprintf('nRMSE 평균  = %.4f\n', mean_nRMSE);
fprintf('nRMSE 표준편차 = %.4f\n', std_nRMSE);

% MaxForce <= 3000N 구간
idx_small = (result_hitted(:,3) <= 3000);
mape_maxF_small = mean(abs((true_maxF(idx_small) - est_maxF(idx_small)) ./ true_maxF(idx_small))) * 100;
disp(['[MaxForce <= 3000N] MAPE in Max Force (%) : ', num2str(mape_maxF_small)]);


% 1) ≤3000N 구간 인덱스(전체 데이터 기준)
index_weight_force = find(result_hitted(:,3) <= 3000);

% 2) 해당 구간으로만 학습한 가중(부분) 모델
mdl_max_force_weight       = fitlm(result_hitted(index_weight_force,3), ...
                                   result_hitting(index_weight_force,3), ...
                                   'Intercept', false);
mdl_impact_duration_weight = fitlm(result_hitted(index_weight_force,4), ...
                                   result_hitting(index_weight_force,4), ...
                                   'Intercept', false);
mdl_impulse_weight         = fitlm(result_hitted(index_weight_force,2), ...
                                   result_hitting(index_weight_force,2), ...
                                   'Intercept', false);

% 3) 계수 추출 (가중/비가중)
aF_w = mdl_max_force_weight.Coefficients.Estimate(1);
aS_w = mdl_impact_duration_weight.Coefficients.Estimate(1);
aI_w = mdl_impulse_weight.Coefficients.Estimate(1);

aF_u = mdl_max_force.Coefficients.Estimate(1);
aS_u = mdl_impact_duration.Coefficients.Estimate(1);
aI_u = mdl_impulse.Coefficients.Estimate(1);


% 5) True / Estimate (가중/비가중) 생성
true_maxF  = result_hitting(:,3);
true_sigma = result_hitting(:,4);
true_imp   = result_hitting(:,2);

est_maxF_w  = result_hitted(:,3) * aF_w;
est_sigma_w = result_hitted(:,4) * aS_w;
est_imp_w   = result_hitted(:,2) * aI_w;

est_maxF_u  = result_hitted(:,3) * aF_u;
est_sigma_u = result_hitted(:,4) * aS_u;
est_imp_u   = result_hitted(:,2) * aI_u;

% 6) MAPE 함수
mape = @(t,e) mean(abs((t - e) ./ t)) * 100;

% 7) 전체(Trajectory 범위) MAPE
mape_maxF_w_all  = mape(true_maxF , est_maxF_w );
mape_sigma_w_all = mape(true_sigma, est_sigma_w);
mape_imp_w_all   = mape(true_imp  , est_imp_w  );

mape_maxF_u_all  = mape(true_maxF , est_maxF_u );
mape_sigma_u_all = mape(true_sigma, est_sigma_u);
mape_imp_u_all   = mape(true_imp  , est_imp_u  );

% 8) 평가 구간 내부에서 ≤3000N만 따로 MAPE
idx_small = (result_hitted(:,3) <= 3000);

mape_maxF_w_small  = mape(true_maxF(idx_small) , est_maxF_w(idx_small) );
mape_sigma_w_small = mape(true_sigma(idx_small), est_sigma_w(idx_small));
mape_imp_w_small   = mape(true_imp(idx_small)  , est_imp_w(idx_small)  );

mape_maxF_u_small  = mape(true_maxF(idx_small) , est_maxF_u(idx_small) );
mape_sigma_u_small = mape(true_sigma(idx_small), est_sigma_u(idx_small));
mape_imp_u_small   = mape(true_imp(idx_small)  , est_imp_u(idx_small)  );

% 9) 결과 출력
disp('================ MAPE (Weighted-by-≤3000N vs Unweighted) ================');
disp('--- [ALL in number_range] ---');
fprintf('MaxF  : Weighted = %.3f%%,  Unweighted = %.3f%%\n', mape_maxF_w_all , mape_maxF_u_all );
fprintf('Sigma : Weighted = %.3f%%,  Unweighted = %.3f%%\n', mape_sigma_w_all, mape_sigma_u_all);
fprintf('Impulse: Weighted = %.3f%%, Unweighted = %.3f%%\n', mape_imp_w_all  , mape_imp_u_all );

disp('--- [SUBSET: result\_hitted\ <= 3000 N in number\_range] ---');
fprintf('MaxF  : Weighted = %.3f%%,  Unweighted = %.3f%%\n', mape_maxF_w_small , mape_maxF_u_small );
fprintf('Sigma : Weighted = %.3f%%,  Unweighted = %.3f%%\n', mape_sigma_w_small, mape_sigma_u_small);
fprintf('Impulse: Weighted = %.3f%%, Unweighted = %.3f%%\n', mape_imp_w_small  , mape_imp_u_small );
disp('========================================================================');

%% Figure 4-1-1) Raw Data Figure of Measured and Proposed Max Force & Impact Duration by Simple Mulitplication METHOD (Both High and Low Angle)

% -------------------------------------------------
%  (1) 기본 설정
% -------------------------------------------------
pad_len = 300;         % 앞·뒤 0-padding 길이
fs      = 2000;        % 샘플링 주파수(Hz)

x_data_hitted          = (0:1/fs:100/fs)';            % 101×1
x_data_hitted_padded   = (-pad_len/fs:1/fs:(100+pad_len)/fs)';  % 701×1

% 압축된 타임벡터가 필요하면 동일한 방식으로 *_padded 변수로 복사
x_data_hitting         = x_data_hitted;               % 예시용
x_data_hitting_padded  = x_data_hitted_padded;

% -------------------------------------------------
%  (2) 신호 패딩 및 오차 계산
% -------------------------------------------------

measured_striking_padded  = cell(35,1);
measured_impacted_padded  = cell(35,1);
estimated_striking_padded = cell(35,1);
estimated_impacted_padded = cell(35,1);

errors = zeros(35,2);

for i = 1:35                               

    % ------- 원본 & 추정 신호 -------
    true_val         = data_cropped{i,1}(:,2);   % 101×1
    impacted_val     = data_cropped{i,1}(:,1);

    % ------- 0-padding -------
    pad = zeros(pad_len,1);
    measured_impacted_padded{i}  = [pad; impacted_val;  pad];
    measured_striking_padded{i}  = [pad; true_val;      pad];

end

% -------------------------------------------------
%  (3) 예시 플롯 (index_weak 선택)
% -------------------------------------------------
close all; clc
figure(3123); clf
set(gcf,'Position',[680 458 240 230])

index_weak = 3;   % 1:35 내부 위치 기준 (1~35)

% ---------- 타임 시프트(원래 코드 로직 유지) ----------
t_impacted = x_data_hitted_padded*1000 - 9;
t_striking = x_data_hitted_padded*1000 - 9;

% ---------- 그래프 ----------
hold on
plot(t_impacted, measured_impacted_padded{index_weak}*0.001, ...
     'Color',[192/255 0 0],'LineWidth',1.5)                 % 측정 Impacted

plot(t_striking, measured_striking_padded{index_weak}*0.001, ...
     'Color',[0 0 204/255],'LineWidth',1.5)                 % 측정 Striking

% 추정값(모델 계수 적용)
plot(t_striking * mdl_impact_duration.Coefficients.Estimate(1), ...
     measured_impacted_padded{index_weak} * mdl_max_force.Coefficients.Estimate(1) * 0.001, ...
     ':','Color',[192/255 0 0 0.8],'LineWidth',1.5)         % 추정 Striking

hold off

% ---------- 축 스타일 ----------
xlabel('Time (ms)','FontWeight','bold','FontSize',9,'FontName','Arial')
ylabel('Force (kN)','FontWeight','bold','FontSize',9,'FontName','Arial')
grid on


measured_impacted_padded_lowandgle = measured_impacted_padded{index_weak};
measured_striking_padded_lowangle = measured_striking_padded{index_weak};




xlim([-10 40])
ylim([-0.3 2])
xticks(0:10:40); yticks(0:1:2)

ax = gca;
set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial', ...
       'LineWidth',1,'Box','off','TickDir','out')

%% Figure 4-1-2) Raw Data Figure of Measured and Proposed Max Force & Impact Duration by Simple Mulitplication METHOD (Both High and Low Angle)

% -------------------------------------------------
% (1) 기본 설정
% -------------------------------------------------
pad_len = 300;          % 앞·뒤 0-padding 길이
fs      = 2000;         % 샘플링 주파수 [Hz]

x_data_hitted         = (0:1/fs:100/fs)';                      % 101×1
x_data_hitted_padded  = (-pad_len/fs : 1/fs : (100+pad_len)/fs)';  % 701×1

% -------------------------------------------------
% (2) 신호 계산 & 패딩
% -------------------------------------------------

measured_striking_padded  = cell(35,1);
measured_impacted_padded  = cell(35,1);

for idx = 1:35
    true_val     = data_cropped{idx,1}(:,2);   % (101×1)
    impacted_val = data_cropped{idx,1}(:,1);

    pad = zeros(pad_len,1);
    measured_striking_padded{idx} = [pad; true_val;     pad];
    measured_impacted_padded{idx} = [pad; impacted_val; pad];
end

% -------------------------------------------------
% (3) 플롯 : index_weak = 8 (1:35 기준)
% -------------------------------------------------
close all; clc
figure(4120); clf
set(gcf,'Position',[680 458 240 230])

index_weak = 8;            % 1:35 내부 인덱스 (1-based)


t_imp = x_data_hitted_padded*1000 - 14;
t_str = x_data_hitted_padded*1000 - 14;

hold on
% (1) 측정 Impacted
plot(t_imp, measured_impacted_padded{index_weak}*0.001, ...
     'Color',[192/255 0 0], 'LineWidth',1.5)

% (2) 측정 Striking
plot(t_str, measured_striking_padded{index_weak}*0.001, ...
     'Color',[0 0 204/255], 'LineWidth',1.5)

% (3) 추정 Striking (점선)
plot(t_str * mdl_impact_duration.Coefficients.Estimate(1), ...
     measured_impacted_padded{index_weak} * mdl_max_force.Coefficients.Estimate(1) * 0.001, ...
     ':', 'Color',[192/255 0 0 0.8], 'LineWidth',1.5)
hold off

% ---- 축·라벨 ----
xlabel('Time (ms)','FontWeight','bold','FontSize',9,'FontName','Arial')
ylabel('Force (kN)','FontWeight','bold','FontSize',9,'FontName','Arial')
grid on
xlim([-10 40]); ylim([-0.9 6])
xticks(0:10:40); yticks(0:2:6)

ax = gca;
set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial', ...
       'LineWidth',1,'Box','off','TickDir','out')

%% Figure 4-1-3) Raw Data Figure of Measured and Proposed Max Force & Impact Duration by Simple Mulitplication METHOD (Both High and Low Angle)

% -------------------------------------------------
% (1) 기본 설정
% -------------------------------------------------
pad_len = 300;                  % 앞·뒤 0-padding 길이
fs      = 2000;                 % 샘플링 주파수 [Hz]

x_data_hitted        = (0:1/fs:100/fs)';                          % 101×1
x_data_hitted_padded = (-pad_len/fs : 1/fs : (100+pad_len)/fs)';  % 701×1

% -------------------------------------------------
% (2) 측정 신호 패딩
% -------------------------------------------------
measured_striking_padded = cell(35,1);
measured_impacted_padded = cell(35,1);

for idx = 1:35

    true_val     = data_cropped{idx,1}(:,2);  % 101×1
    impacted_val = data_cropped{idx,1}(:,1);

    z = zeros(pad_len,1);
    measured_striking_padded{idx} = [z; true_val;     z];
    measured_impacted_padded{idx} = [z; impacted_val; z];
end

% -------------------------------------------------
% (3) 플롯 : index_weak = 13 (1:35 기준)
% -------------------------------------------------
close all; clc
figure(4130); clf
set(gcf,'Position',[680 458 240 230])

index_weak = 13;      % 1:35 내 인덱스 (1-based)

t_imp = x_data_hitted_padded*1000 - 18;
t_str = x_data_hitted_padded*1000 - 18;

hold on
% (1) 측정 Impacted
plot(t_imp, measured_impacted_padded{index_weak}*0.001, ...
     'Color',[192/255 0 0], 'LineWidth',1.5)

% (2) 측정 Striking
plot(t_str, measured_striking_padded{index_weak}*0.001, ...
     'Color',[0 0 204/255], 'LineWidth',1.5)

% (3) 추정 Striking (점선)
plot(t_str * mdl_impact_duration.Coefficients.Estimate(1), ...
     measured_impacted_padded{index_weak} * mdl_max_force.Coefficients.Estimate(1) * 0.001, ...
     ':', 'Color',[192/255 0 0 0.8], 'LineWidth',1.5)
hold off

% ---- 축·라벨 ----
xlabel('Time (ms)','FontWeight','bold','FontSize',9,'FontName','Arial')
ylabel('Force (kN)','FontWeight','bold','FontSize',9,'FontName','Arial')
grid on
xlim([-10 40]); ylim([-1.8 12])
xticks(0:10:40); yticks(0:4:12)

ax = gca;
set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial', ...
       'LineWidth',1,'Box','off','TickDir','out')

%% Figure 4-2) MAPE scatter plots
err_maxF   = abs((true_maxF  - est_maxF ) ./ true_maxF ) * 100;
err_sigma  = abs((true_sigma - est_sigma) ./ true_sigma) * 100;
err_imp    = abs((true_imp   - est_imp  ) ./ true_imp  ) * 100;

clc;  figure(4330); set(gcf,'Position',[680 458 240 230]);
scatter(result_hitting(:,3)*0.001, err_maxF, 15, 'k', 'filled');
xlabel('Maximum Force (kN)','FontWeight','bold','FontSize',8,'FontName','Arial');
ylabel('MAPE(%)','FontWeight','bold','FontSize',8,'FontName','Arial'); grid on;
ax=gca; set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial','LineWidth',1,'Box','off','TickDir','out');
ylim([0 15]); xlim([0 12]); yticks(0:3:15); xticks(0:3:12);

clc; figure(4360); set(gcf,'Position',[680 458 240 230]);
scatter(result_hitting(:,4)*1000, err_sigma, 15, 'k', 'filled');
xlabel('Impact Duration (ms)','FontWeight','bold','FontSize',9,'FontName','Arial');
ylabel('MAPE(%)','FontWeight','bold','FontSize',9,'FontName','Arial'); grid on;
ax=gca; set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial','LineWidth',1,'Box','off','TickDir','out');
ylim([0 15]); xlim([0 50]); yticks(0:3:15);

clc;  figure(4390); set(gcf,'Position',[680 458 240 230]);
scatter(result_hitting(:,2), err_imp, 15, 'k', 'filled');
xlabel('Impulse (Ns)','FontWeight','bold','FontSize',9,'FontName','Arial');
ylabel('MAPE(%)','FontWeight','bold','FontSize',9,'FontName','Arial'); grid on;
ax=gca; set(ax,'FontWeight','bold','FontSize',8,'FontName','Arial','LineWidth',1,'Box','off','TickDir','out');
ylim([0 15]); xlim([0 40]); yticks(0:3:15); xticks(0:8:40);
