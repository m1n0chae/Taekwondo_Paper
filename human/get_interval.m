function [rs_left, rs_right, rs_left_index, rs_right_index, maxT] = get_interval(signal)
[max_sig, max_idx] = max(signal);
th1 = 0.02*max_sig;
s = sort(signal(max_idx:end));
th2 = 0.02*max_sig + 0.99*mean(s(round(length(s)*0.5):round(length(s)*0.9)));
% th2 = th1 + mean(s(round(length(s)*0.5):round(length(s)*0.9)));
sam_freq = 2000;

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

maxT = max_idx;
end
