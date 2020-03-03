function robustObjInfo = createRobustObj()
% Manually set the robust objectives scenarios here. 4th Jan 2020. Y Xia.
%   No need to repeat calculation of dij for every structure.
robustObjInfo = cell(8,2);

robustObjInfo{1,1} = 'Setup';
robustObjInfo{1,2} = [3,0,0];

robustObjInfo{2,1} = 'Setup';
robustObjInfo{2,2} = [0,3,0];

robustObjInfo{3,1} = 'Setup';
robustObjInfo{3,2} = [0,0,3];

robustObjInfo{4,1} = 'Setup';
robustObjInfo{4,2} = [-3,0,0];

robustObjInfo{5,1} = 'Setup';
robustObjInfo{5,2} = [0,-3,0];

robustObjInfo{6,1} = 'Setup';
robustObjInfo{6,2} = [0,0,-3];

robustObjInfo{7,1} = 'Range';
robustObjInfo{7,2} = 3.5/100;

robustObjInfo{8,1} = 'Range';
robustObjInfo{8,2} = -3.5/100;

end

