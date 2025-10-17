function after_data = filtering_function_for_array(before_data)
fc = 350;
Ffs = 2000;

% Reduce low frequency
filtering = 'bandpass';
% filtering = 'high';

% 필터링 방식에 따라 적절한 필터 설계
if strcmp(filtering, 'bandpass')
    [Fb, Fa] = butter(3, [0.5/(Ffs/2), fc/(Ffs/2)], 'bandpass');
    after_data = filtfilt(Fb, Fa, before_data);
elseif strcmp(filtering, 'high')
    [bH, aH] = butter(3, 0.5/(Ffs/2), 'high');
    after_data = filtfilt(bH, aH, before_data);
end

end
