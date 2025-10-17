function after_data = filtering_function(before_data)
fc = 350;
Ffs = 2000;

% reduct low frequency
filtering = 'bandpass';
% filtering = 'high';

after_data = cell(length(before_data),1);

for i = 1:length(before_data)

    % FFT로 스펙트럼에서 주요 성분이 감소하는 지점을 찾아 컷오프 주파수를 결정,
    % 최대 주파수 성분의 10%가 되는 지점을 컷오프로 설정합니다.


    % N=length(before_data);
    % X = fft(before_data{i,1});
    % X_magnitude = abs(X/N);   % 정규화된 크기 스펙트럼
    % f = Ffs*(0:(N/2))/N;
    % figure;
    % plot(f, X_magnitude(1:N/2+1));
    % title('Magnitude Spectrum');
    % xlabel('Frequency (Hz)');
    % ylabel('Magnitude');
    % 
    % [~, maxIdx] = max(X_magnitude(1:N/2+1)); % 가장 큰 성분의 위치
    % threshold = 0.3 * X_magnitude(maxIdx);  % 임계값 설정 (최대값의 10%로)
    % cutoff_idx = find(X_magnitude(1:N/2+1) < threshold, 1); % 임계값 아래로 떨어지는 첫 위치
    % fc = f(cutoff_idx); % 컷오프 주파수


    if strcmp(filtering,'bandpass')
        [Fb, Fa] = butter(3, [0.5/(Ffs/2), fc/(Ffs/2)], 'bandpass');
        after_data{i,1} = filtfilt(Fb, Fa, before_data{i,1});
    elseif strcmp(filtering,'high')
        [bH, aH] = butter(3, 0.5/(Ffs/2), 'high');
        after_data{i,1} = filtfilt(bH, aH, before_data{i,1});
    end
end

end