function f = matRad_objFuncRobust(d_i,objective,d_ref, min_worst, max_worst)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matRad IPOPT callback: objective function for inverse planning supporting mean dose
% objectives, EUD objectives, squared overdosage, squared underdosage,
% squared deviation and DVH objectives
% 
% call
%    f = matRad_objFunc(d_i,objective,d_ref)
%
% input
%    d_i:       dose vector in VOI
%    objective: matRad objective struct
%    d_ref:     reference dose /effect value to evaluate objective
%
% output
%   f: objective function value
%
% References
%   [1] http://www.sciencedirect.com/science/article/pii/S0958394701000577
%   [2] http://www.sciencedirect.com/science/article/pii/S0360301601025858
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2015 the matRad development team. 
% 
% This file is part of the matRad project. It is subject to the license 
% terms in the LICENSE file found in the top-level directory of this 
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part 
% of the matRad project, including this file, may be copied, modified, 
% propagated, or distributed except according to the terms contained in the 
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
numOfVoxels = numel(d_i);
            
if isequal(objective.type, 'square underdosing') 

    % underdose : dose minus prefered dose
%     underdose = d_i - d_ref;  % Commented on 4th Jan 2020. Y Xia.
    underdose = min_worst - d_ref;

    % apply positive operator
    underdose(underdose>0) = 0;

    % calculate objective function
    f = (objective.penalty/numOfVoxels)*(underdose'*underdose);

elseif isequal(objective.type, 'square overdosing')

    % overdose : dose minus prefered dose
%     overdose = d_i - d_ref;   % Commented on 4th Jan 2020. Y Xia.
    overdose = max_worst - d_ref;

    % apply positive operator
    overdose(overdose<0) = 0;

    % calculate objective function
    f = (objective.penalty/numOfVoxels)*(overdose'*overdose);

elseif isequal(objective.type, 'square deviation')

   % deviation : dose minus prefered dose
   deviation = d_i - d_ref;

   % claculate objective function
   f = (objective.penalty/numOfVoxels)*(deviation'*deviation);

elseif isequal(objective.type, 'mean')              

    % calculate objective function
    f = (objective.penalty/numOfVoxels)*sum(d_i);

elseif isequal(objective.type, 'EUD') 

    % get exponent for EUD
    exponent = objective.EUD;

    % calculate objective function and delta
    if sum(d_i.^exponent)>0
        f = objective.penalty * nthroot((1/numOfVoxels) * sum(d_i.^exponent),exponent);
    end

elseif isequal(objective.type, 'max DVH objective') ||...
       isequal(objective.type, 'min DVH objective')

    % get reference Volume
    refVol = objective.volume/100;

    % calc deviation
    deviation = d_i - d_ref;

    % calc d_ref2: V(d_ref2) = refVol
    d_ref2 = matRad_calcInversDVH(refVol,d_i);

    % apply lower and upper dose limits
    if isequal(objective.type, 'max DVH objective')
         deviation(d_i < d_ref | d_i > d_ref2) = 0;
%         deviation(min_worst < d_ref | max_worst > d_ref2) = 0;
    elseif isequal(objective.type, 'min DVH objective')
         deviation(d_i > d_ref | d_i < d_ref2) = 0;
%         deviation(max_worst > d_ref | min_worst < d_ref2) = 0;
    end

    % claculate objective function
    f = (objective.penalty/numOfVoxels)*(deviation'*deviation);
    
elseif isequal(objective.type, 'margin square overdosing')       
    
%     pixel_margin = objective.margin;
%     border_perc = 0.95;
%     margin_perc = 0.05;
%     Vdi = objective.Vdi;
%     voiMargin = objective.voiMargin;
%     index = find(voiMargin ~= 0);
%     zero_index = find(voiMargin == 0);
%     
%     b = pixel_margin(1) / (erfinv(2 * border_perc - 1) - erfinv(2 * margin_perc - 1));
%     a = erfinv(2 * border_perc - 1) * b * (-1);
%     pi = (1 + erf((- Vdi - a) ./ b)) / 2;
    pi = objective.pi;
    pii = pi .* d_ref;
%     pii(zero_index) = 0;
%     pii = pii(index);
%     
    
    overdose = d_i - pii;
    f = (objective.penalty / numOfVoxels) * sum((overdose(overdose > 0)) .^ 2);
    
end
      
        

   