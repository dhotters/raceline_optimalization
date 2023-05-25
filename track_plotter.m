function [out] = track_plotter(filePath)
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
track.x_m = [track.x_m', track.x_m(1)];
track.y_m = [track.y_m', track.y_m(1)];
track.w_tr_right_m = [track.w_tr_right_m', track.w_tr_right_m(1)];
track.w_tr_left_m = [track.w_tr_left_m', track.w_tr_left_m(1)];

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
wr_x = [wr_x, wr_x(1)];
wr_y = [wr_y, wr_y(1)];
wl_x = [wl_x, wl_x(1)];
wl_y = [wl_y, wl_y(1)];

% Create splines to close all curves
x = linspace(min(track.x_m), max(track.x_m), 1000); % x values at which the splines are evaluated

% plot
hold on
plot(track.x_m, track.y_m)
plot(wr_x, wr_y, 'k')
plot(wl_x, wl_y, 'k')

% returns
out.x_m = track.x_m;
out.y_m = track.y_m;
out.wr_x = wr_x;
out.wr_y = wr_y;
out.wl_x = wl_x;
out.wl_y = wl_y;
end

