function [] = track_plotter(track, raceline)
% This function will plot the track for a track struct
% Additionaly also capable of plotting the current raceline

%% Plot the track
figure(1)
plot(track.x_m, track.y_m, '--b')
hold on
axis equal

% plot track limits
plot(track.tw_left_x, track.tw_left_y, 'black');
plot(track.tw_right_x, track.tw_right_y, 'black');

% Check if a raceline is given or not
if ~exist('raceline', 'var')
    raceline.x = 0;
    raceline.y = 0;
end

% Plot raceline
plot(raceline.x, raceline.y, 'r');
end

