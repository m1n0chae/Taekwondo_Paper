clc;close all; clear;
load('scaling_factor.mat')

for i = 1:5
    % 예) Subject 폴더 이름 "Subject1", "Subject2" ... 생성
    subjectName = ['Subject' num2str(i)];
    
    % 폴더 경로
    folderPath = fullfile(subjectName);
    
    % 1) force_for_paper.mat 불러오기
    forceFile = fullfile(folderPath, 'force_for_paper.mat');
    load(forceFile, 'force_for_paper');  % 변수 force_for_paper가 로드됨
    forceCell_Player{i,1} = force_for_paper;

    % 2) result_for_paper.mat 불러오기
    resultFile = fullfile(folderPath, 'result_for_paper.mat');
    load(resultFile, 'result_for_paper'); % 변수 result_for_paper가 로드됨
    resultCell_Player{i,1} = result_for_paper;
end



%% 5-0 : Figure check on Human data

group_straight = [22,23,38,39,40,43]; % 그냥 뾰족한 놈들 
group_front = [2,3,4,5,6,7,8,9,10,11,13,15,16,17,18,19,20,21,24,25,30,41,42]; % 앞 부분이 뾰족
group_rear = [1,12,14,26,27,28,29,31,32,33,34,35,36,37]; % 뒤에 피크가 뾰족

close all;

result_Player = [];
force_Player = [];
for i = 1:5
    for j = 1:length(forceCell_Player{i,1})
        result_Player = [result_Player; resultCell_Player{i,1}(j,:)];
        force_Player = [force_Player; forceCell_Player{i,1}(j,:)];
    end
end

% size unifying
for i =1:43
    force_Player{i,1} = force_Player{i,1}(1:250);
end


for i = 1:length(force_Player)
    x_player = 0:1/1000:1/1000*(length(force_Player{i})-1);

    figure;
    set(gcf, 'Position', [680   458   280   250]); 

    plot((x_player)*1000-result_Player(i,5)*1000,force_Player{i}*0.001,'Color',[0.6350, 0.0780, 0.1840, 0.4],'LineWidth', 1.5)

    xlabel('Time (ms)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');
    ylabel('Force (kN)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');
    grid on;

    % 축 Bold 설정
    ax = gca;
    set(ax, 'FontWeight', 'bold', 'FontSize', 8, 'FontName', 'Arial', ...
        'LineWidth', 1, 'Box', 'off', 'TickDir', 'out');

    ylim([-0.1 2])
    xlim([-10 40])

    
end

%% 5-1-3-1 : Raw data of Human kick - 비슷한 애들 끼리 그룹 나눠서 : Group Front 

group_straight = [22,23,38,39,40,43]; 
group_front = [2,3,4,5,6,7,8,9,10,11,13,15,16,17,18,19,20,21,24,25,30,41,42]; 
group_rear = [1,12,14,26,27,28,29,31,32,33,34,35,36,37]; 

clc; close all;
figure(5130);
set(gcf, 'Position', [680   458   240   230]); 
index = 16;

a=0;
for i = group_front
    a = a+force_Player{i,1}((result_Player(i,6)-10):result_Player(i,6)+100)*0.001;
end
a=a/length(group_front);

hold on 
for i = group_front
    x_player = 0:1/1000:1/1000*(length(force_Player{i})-1);

    plot((x_player-result_Player(i,5))*1000,force_Player{i,1}*0.001,'LineStyle', '-','Color',[0.3, 0.3, 0.3, 0.2],'LineWidth', 1);
    
end

plot(((0:1/1000:1/1000*110))*1000-11, a, 'Color',[192/255, 0, 0,0.8], 'LineWidth', 1.5)

plot((((0:1/1000:1/1000*110))*1000-11),(a)*mdl_max_force.Coefficients.Estimate(1),'LineStyle', '-','Color',[192/255, 0, 0,0.8],'LineWidth', 1.5);

hold off

xlabel('Time (ms)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');
ylabel('Force (kN)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');
grid on;

ax = gca;
set(ax, 'FontWeight', 'bold', 'FontSize', 8, 'FontName', 'Arial', ...
        'LineWidth', 1, 'Box', 'off', 'TickDir', 'out');

ylim([-0.5 2])
xlim([-10 40])
yticks(0:0.5:2)
xticks(0:10:40)


%% 5-1-3-2 : Raw data of Human kick - 비슷한 애들 끼리 그룹 나눠서 : Group Rear

group_straight = [22,23,38,39,40,43];
group_front = [2,3,4,5,6,7,8,9,10,11,13,15,16,17,18,19,20,21,24,25,30,41,42]; 
group_rear = [1,12,14,26,27,28,29,31,32,33,34,35,36,37]; 

clc; close all;
figure(5132);
set(gcf, 'Position', [680   458    240   230]); 


b=0;
for i = group_rear
    b = b+force_Player{i,1}((result_Player(i,6)-10):result_Player(i,6)+100)*0.001;
end
b=b/length(group_rear);

hold on 
for i = group_rear
    x_player = 0:1/1000:1/1000*(length(force_Player{i})-1);
    plot((x_player-result_Player(i,5))*1000,force_Player{i,1}*0.001,'LineStyle', '-','Color',[0.3, 0.3, 0.3, 0.2],'LineWidth', 1);

end

plot((0:1/1000:1/1000*110)*1000-11,b, 'Color',[192/255, 0, 0,0.8], 'LineWidth', 1.5)


plot((0:1/1000:1/1000*110)*1000-11, b*mdl_max_force.Coefficients.Estimate(1),'LineStyle', '-','Color',[192/255, 0, 0,0.8],'LineWidth', 1.5);


hold off



xlabel('Time (ms)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');
ylabel('Force (kN)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');
grid on;

ax = gca;
set(ax, 'FontWeight', 'bold', 'FontSize', 8, 'FontName', 'Arial', ...
        'LineWidth', 1, 'Box', 'off', 'TickDir', 'out');

ylim([-0.5 2])
xlim([-10 40])

yticks(0:0.5:2)
xticks(0:10:40)
%% 5-1-3-3 : Raw data of Human kick - 비슷한 애들 끼리 그룹 나눠서 : Group Straight 

group_straight = [22,23,38,39,40,43]; % 그냥 뾰족한 놈들 
group_front = [2,3,4,5,6,7,8,9,10,11,13,15,16,17,18,19,20,21,24,25,30,41,42]; % 앞 부분이 뾰족
group_rear = [1,12,14,26,27,28,29,31,32,33,34,35,36,37]; % 뒤에 피크가 뾰족

clc; close all;
figure(5133);
set(gcf, 'Position', [680   458   240   230]); % Figure 크기 고정 (x, y, width, height)

c=0;
for i = group_straight
    c = c+force_Player{i,1}((result_Player(i,6)-10):result_Player(i,6)+100)*0.001;
end
c=c/length(group_straight);

hold on 
for i = group_straight
    x_player = 0:1/1000:1/1000*(length(force_Player{i})-1);

    plot((x_player-result_Player(i,5))*1000,force_Player{i,1}*0.001,'LineStyle', '-','Color',[0.3, 0.3, 0.3, 0.2],'LineWidth', 1);

end

plot((0:1/1000:1/1000*110)*1000-11,c, 'Color',[192/255, 0, 0,0.8], 'LineWidth', 1.5)

plot((0:1/1000:1/1000*110)*1000-11, c*mdl_max_force.Coefficients.Estimate(1),'LineStyle', '-','Color',[192/255, 0, 0,0.8],'LineWidth', 1.5);

hold off


xlabel('Time (ms)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');
ylabel('Force (kN)', 'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Arial');
grid on;

ax = gca;
set(ax, 'FontWeight', 'bold', 'FontSize', 8, 'FontName', 'Arial', ...
        'LineWidth', 1, 'Box', 'off', 'TickDir', 'out');

ylim([-0.5 2])
xlim([-10 40])

yticks(0:0.5:2)
xticks(0:10:40)
%% Table 2 Calculation

mean_impulse_player = mean(result_Player(:,1))
std_impulse_player = std(result_Player(:,1))

mean_maxforce_player = mean(result_Player(:,2))
std_maxforce_player = std(result_Player(:,2))

mean_impact_duration_player = mean(result_Player(:,3))
std_impact_duration_player = std(result_Player(:,3))

a = [mean_maxforce_player std_maxforce_player]*mdl_max_force.Coefficients.Estimate(1);
b = [mean_impact_duration_player std_impact_duration_player]*mdl_impact_duration.Coefficients.Estimate(1);
c = [mean_impulse_player std_impulse_player]*mdl_impulse.Coefficients.Estimate(1);
