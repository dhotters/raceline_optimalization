function [out] = track_plotter(filePath, n)
% This function will plot the track for a given csv file containing the
% following columns of data:
% x_m: x location data of the median (center) line
% y_m: y location data of the median (center) line
% w_tr_right_m: The track width to the right of the median line
% w_tr_left_m: The track width to the left of the median line
% Note that left/right is relative to the direction of travel on the track

% Load in the track data
track = table2struct(readtable(filePath),"ToScalar", true);

% close the curve
%track.x_m = [track.x_m', track.x_m(1)];
%track.y_m = [track.y_m', track.y_m(1)];
%track.w_tr_right_m = [track.w_tr_right_m', track.w_tr_right_m(1)];
%track.w_tr_left_m = [track.w_tr_left_m', track.w_tr_left_m(1)];

%% Compute the left and right track limits
wr_x = [];
wr_y = [];
wl_x = [];
wl_y = [];

for i = 1:length(track.x_m)-1
    % compute the vector of the direction
    cur_p = [track.x_m(i), track.y_m(i)];
    to_p = [track.x_m(i+1), track.y_m(i+1)];
    
    % This is the vector of direction
    d = to_p - cur_p;
    d = d/norm(d); % normalize

    % compute a vector 90 degrees with this direction vector
    w = [d(2), -d(1)]; % this rotates 90 deg CW

    % append the left and right track limits from the track width
    r_vec =  w.*track.w_tr_right_m(i);
    wr_x = [wr_x, cur_p(1) + r_vec(1)];
    wr_y = [wr_y, cur_p(2) + r_vec(2)];
    
    l_vec = -w.*track.w_tr_left_m(i);
    wl_x = [wl_x, cur_p(1) + l_vec(1)];
    wl_y = [wl_y, cur_p(2) + l_vec(2)];
end

% close the width curves
%wr_x = [wr_x, wr_x(1)];
%wr_y = [wr_y, wr_y(1)];
%wl_x = [wl_x, wl_x(1)];
%wl_y = [wl_y, wl_y(1)];

% Transform to equidistant data
centerline = equidistant(track.x_m, track.y_m, n);

% Do the same for the track width
right_limit = equidistant(wr_x', wr_y', n);
left_limit = equidistant(wl_x', wl_y', n);

% Plot the track
plot(centerline(:, 1), centerline(:, 2))
hold on
axis equal
plot(right_limit(:, 1), right_limit(:, 2))
plot(left_limit(:, 1), left_limit(:, 2))

% returns
out.x_m = centerline(:, 1);
out.y_m = centerline(:, 2);
out.tw_left_x = left_limit(:, 1);
out.tw_left_y = left_limit(:, 2);
out.tw_right_x = right_limit(:, 1);
out.tw_right_y = right_limit(:, 2);
end

