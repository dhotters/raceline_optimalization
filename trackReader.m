function [out] = trackReader(filePath, n)
% This function will create a struct containing all the required track data
% It also creates equidistant points
% following columns of data:
% x_m: x location data of the median (center) line
% y_m: y location data of the median (center) line
% w_tr_right_m: The track width to the right of the median line
% w_tr_left_m: The track width to the left of the median line
% Note that left/right is relative to the direction of travel on the track

% Load in the track data
track = table2struct(readtable(filePath),"ToScalar", true);

% close the track
track.x_m = [track.x_m', track.x_m(1)]';
track.y_m = [track.y_m', track.y_m(1)]';
track.w_tr_right_m = [track.w_tr_right_m', track.w_tr_right_m(1)]';
track.w_tr_left_m = [track.w_tr_left_m', track.w_tr_left_m(1)]';

% Transform to equidistant data
[centerline, cumulativeLen, finalStepLocs] = equidistant(track.x_m, track.y_m, n);

% Get track limits at same locations
limit_left_equi = interp1(cumulativeLen, track.w_tr_left_m, finalStepLocs, 'spline');
limit_right_equi = interp1(cumulativeLen, track.w_tr_right_m, finalStepLocs, 'spline');


%% First segment

% compute the vector of the direction
cur_p = [centerline(1, 1), centerline(1, 2)];
to_p = [centerline(2, 1), centerline(2, 2)];

% This is the vector of direction
d = to_p - cur_p;
s_cur = norm(d);
d = d/s_cur; % normalize

% compute a vector 90 degrees with this direction vector
% ie normal to the median
w = [d(2), -d(1)]; % this rotates 90 deg CW

% append the left and right track limits from the track width
r_vec =  w.*limit_right_equi(1);
wr_x = [cur_p(1) + r_vec(1)];
wr_y = [cur_p(2) + r_vec(2)];

l_vec = -w.*limit_left_equi(1);
wl_x = [cur_p(1) + l_vec(1)];
wl_y = [cur_p(2) + l_vec(2)];

% L(s)
L = [0, s_cur];

for i = 2:n-1
    % compute the vector of the direction
    cur_p = [centerline(i, 1), centerline(i, 2)];
    to_p = [centerline(i+1, 1), centerline(i+1, 2)];
    last_p = [centerline(i-1, 1), centerline(i-1, 2)];
    
    % This is the vector of direction
    d_to = to_p - cur_p;
    s_cur = norm(d_to);

    % this is vector of direction between last and to point
    d = to_p - last_p;
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

    % L(s)
    L = [L, s_cur];
end

% close the track
wr_x = [wr_x, wr_x(1)];
wr_y = [wr_y, wr_y(1)];
wl_x = [wl_x, wl_x(1)];
wl_y = [wl_y, wl_y(1)];

left_limit = [wl_x', wl_y'];
right_limit = [wr_x', wr_y'];

% returns
out.x_m = centerline(:, 1);
out.y_m = centerline(:, 2);
out.tw_left_x = left_limit(:, 1);
out.tw_left_y = left_limit(:, 2);
out.tw_right_x = right_limit(:, 1);
out.tw_right_y = right_limit(:, 2);
out.L = L;
out.name = extractAfter(extractBefore(filePath, "."), "\");
end

