function [out] = curvature(X)
% Alternate way to compute the curvature
% this method computes the rad/m change which will be minimized

N = size(X, 1);

%% TODO Add first and last point to this computation?
R = [];
rad_per_meter = [];
for i = 2:N-1
    P_c = X(i, :); % Central point
    P_f = X(i+1, :); % forward point
    P_b = X(i-1, :); % backward point
    
    % line segments
    seg_1 = P_c - P_b;
    seg_2 = P_f - P_c;

    % compute angle between them
    a = abs(atan2d(seg_1(1)*seg_2(2) - seg_1(2)*seg_2(1), seg_1(1)*seg_2(1)+seg_1(2)*seg_2(2)));

    % compute rad/m
    rad_per_meter = [rad_per_meter, (a/(norm(seg_1) + norm(seg_2)))^2];

    % Additionally also compute local radius
    R = [R, circumradius(P_b, P_c, P_f)];
end


% Output
out.rad_per_meter = rad_per_meter;
out.R = R;
out.K = 1./R;
end

