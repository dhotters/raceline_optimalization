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

% Transform to equidistant data
[centerline, cumulativeLen, finalStepLocs] = equidistant(track.x_m, track.y_m, n);

% Get track limits at same locations
limit_left_equi = interp1(cumulativeLen, track.w_tr_left_m, finalStepLocs, 'spline');
limit_right_equi = interp1(cumulativeLen, track.w_tr_right_m, finalStepLocs, 'spline');

%% limits have to be offset still by track widths
wr_x = [];
wr_y = [];
wl_x = [];
wl_y = [];
for i = 1:n-1
    % compute the vector of the direction
    cur_p = [centerline(i, 1), centerline(i, 2)];
    to_p = [centerline(i+1, 1), centerline(i+1, 2)];
    
    % This is the vector of direction
    d = to_p - cur_p;
    d = d/norm(d); % normalize

    % compute a vector 90 degrees with this direction vector
    % ie normal to the median
    w = [d(2), -d(1)]; % this rotates 90 deg CW

    % append the left and right track limits from the track width
    r_vec =  w.*limit_right_equi(i);
    wr_x = [wr_x, cur_p(1) + r_vec(1)];
    wr_y = [wr_y, cur_p(2) + r_vec(2)];
    
    l_vec = -w.*limit_left_equi(i);
    wl_x = [wl_x, cur_p(1) + l_vec(1)];
    wl_y = [wl_y, cur_p(2) + l_vec(2)];
end

left_limit = [wl_x', wl_y'];
right_limit = [wr_x', wr_y'];

%% Plot the track
plot(centerline(:, 1), centerline(:, 2), 'b')
hold on
axis equal

% plot track limits
plot(wl_x, wl_y, 'black');
plot(wr_x, wr_y, 'black');


% returns
out.x_m = centerline(:, 1);
out.y_m = centerline(:, 2);
out.tw_left_x = left_limit(:, 1);
out.tw_left_y = left_limit(:, 2);
out.tw_right_x = right_limit(:, 1);
out.tw_right_y = right_limit(:, 2);
end

