function croppedTable = cropTable(inputTable)
    % 입력받은 테이블에서 각 열에 대해 두 번째 NaN이 나타나기 전까지의 데이터를 잘라내는 함수
    arr = table2array(inputTable(:,1));
    nanIndices = find(isnan(arr),2);


    % NaN이 두 번째 나오기 전까지의 데이터만 유지
    croppedTable = inputTable(1:nanIndices(2)-1, :);
end
