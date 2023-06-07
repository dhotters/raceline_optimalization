function [out] = getRaceLine(a_vec, track)
%% This function computes the race line based on an input vector of
%% Coefficients

% track must be a struct containing the current track data such as median
% center line x_m and y_m aswell as the left and right track limit x and y
% coordinates

% We take the right limit as our reference for the coefficients


% Check if a_vec contains values between 0-1
if ~(min(a_vec) >= 0 && max(a_vec) <= 1)
error("a_vec contains values which are out of bounds of the track!")
end

% Compute direction vector around the right limit of the track

new_points_x = [];
new_points_y = [];
for i = 1:length(track.tw_left_x)-1

left_point = [track.tw_left_x(i), track.tw_left_y(i)];
right_point = [track.tw_right_x(i), track.tw_right_y(i)];

% Compute vector crossing from right to left limit
width_vec = left_point - right_point;

% compute current track width
current_tw = norm(width_vec);

% compute new location of point
ref_p = right_point;

new_p = ref_p + width_vec.*a_vec(i);
new_points_x = [new_points_x, new_p(1)];
new_points_y = [new_points_y, new_p(2)];

% Debug arrows
% quiver(ref_p(1), ref_p(2),width_vec(1), width_vec(2), 'g')
% hold on
end

% calculate curvature of the current raceline
% Compute curvature
curv = curvature([new_points_x', new_points_y']);

% Close the raceline
new_points_x = [new_points_x, new_points_x(1)];
new_points_y = [new_points_y, new_points_y(1)];

% Output
out.x = new_points_x;
out.y = new_points_y;

out.K = curv.K;
out.L = curv.L;
out.rad_per_meter = curv.rad_per_meter;
end

