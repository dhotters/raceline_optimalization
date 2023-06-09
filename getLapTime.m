function [out] = getLapTime(track, raceline, car)
%% This function computes the estimated laptime given a raceline, track 
%% and car properties
%% It does this by computing a velocity profile along the raceline which
%% depends on the car. the car is assumed to be a point mass

% compute limits
g = 9.80665; % m/s2 gravitational acceleration
ft_max = car.max_g_accel * car.mass * g;
fb_max = car.max_g_brake * car.mass * g;
fn_max = car.max_g_lateral * car.mass * g;

%% Step 1 of the reference
% Find the local minima of the path radius
[peaks, locations] = findpeaks(-raceline.R); % Note negative for local minima



end

