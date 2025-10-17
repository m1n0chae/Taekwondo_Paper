function [rs_left, rs_right, rs_left_index, rs_right_index, maxT] = get_interval(signal)
    % 최대값과 그 인덱스
    [max_sig, max_idx] = max(signal);
    th1 = 0.01 * max_sig;
    
    % 최대값 위치부터 끝까지 구간만 sort해서 평균 구함
    s = sort(signal(max_idx:end));
    th2 = 0.03*max_sig;
    % th2 = th1 + mean(s(round(length(s)*0.5):round(length(s)*0.9)));
    
    sam_freq = 2000;
    
    % 기본값 (찾지 못하는 경우를 대비해서 NaN 초기화)
    rs_left       = NaN;
    rs_left_index = NaN;
    rs_right      = NaN;
    rs_right_index= NaN;

    % -----------------------------
    % 왼쪽 구간 찾기
    % -----------------------------
    for i = 1 : (max_idx - 1)
        % 인덱스 계산
        left_idx1 = max_idx - i - 1;  % signal(...) 접근용
        left_idx2 = max_idx - i;      % signal(...) 접근용
        
        % -----------------------------
        % 1) 인덱스 유효성 체크
        % -----------------------------
        % left_idx1, left_idx2가 모두 1 이상이어야 signal(...)로 접근 가능
        if left_idx1 < 1 || left_idx2 < 1
            break;  % 더 이상 왼쪽으로 갈 수 없으므로 중단
        end
        
        % -----------------------------
        % 2) 실제 임계점 체크
        % -----------------------------
        if (signal(left_idx1) - th1) * (signal(left_idx2) - th1) <= 0
            % ---- 추가 계산 ----
            % 코드상 원래 (max_idx-i-1)-1을 rs_left_index로 사용
            % 즉 left_idx1 - 1:
            left_idx3 = left_idx1 - 1;
            
            % 이 역시 1 이상인지 체크
            if left_idx3 < 1
                break; % 더 이상 유효한 인덱스가 아님
            end
            
            rs_left_index = left_idx3;
            rs_left       = left_idx3 / sam_freq;
            
            break;  % 왼쪽 경계 찾았으므로 반복 중단
        end
    end

    % -----------------------------
    % 오른쪽 구간 찾기
    % -----------------------------
    for i = 1 : (length(signal) - max_idx - 1)
        right_idx1 = max_idx + i + 1;  % signal(...) 접근용
        right_idx2 = max_idx + i;      % signal(...) 접근용
        
        % -----------------------------
        % 1) 인덱스 유효성 체크
        % -----------------------------
        % right_idx1, right_idx2가 모두 신호 길이 이하여야 함
        if right_idx1 > length(signal) || right_idx2 > length(signal)
            break; % 신호 범위를 벗어났으므로 중단
        end
        
        % -----------------------------
        % 2) 실제 임계점 체크
        % -----------------------------
        if (signal(right_idx1) - th2) * (signal(right_idx2) - th2) <= 0
            % 원 코드에서 rs_right_index = max_idx + i + 4;
            % 즉 right_idx1 + 3:
            right_idx3 = right_idx1 + 3;
            
            % 유효 인덱스 확인
            if right_idx3 > length(signal)
                break; % 범위를 벗어남
            end
            
            rs_right_index = right_idx3;
            rs_right       = right_idx3 / sam_freq;
            
            break;  % 오른쪽 경계 찾았으므로 반복 중단
        end
    end
    
    % -----------------------------
    % 최대값 시점(초)
    % -----------------------------
    maxT = (max_idx - 1) / sam_freq;
end