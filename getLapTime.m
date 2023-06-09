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

n = length(raceline.x); % number of points used to discretize the track

%% Step 1 of the reference
% Find the local minima of the path radius
raceline.K(1) = 0; % Else it will take start and end point as a corner
raceline.K(end) = 0;
[peaks, locations_idx] = findpeaks(raceline.K); % Note negative for local minima
peaks = peaks; % correct values

% visualize maxima of curvature as its more clear for debugging
figure
plot(raceline.L, raceline.R, 'r');
hold on
title("len vs R")
scatter(raceline.L(locations_idx), 1./peaks, '*black');

%% Step 2 of the reference
% optimal velocity profile subject to **FREE** boundary conditions
% Note that the track is cut into sections hence the for loops


%% From the start of the track to the first corner (location_idx(1))
% NOTE starting from v0 = 0 m/s
v = zeros(n, 1);
for i = 2:locations_idx(1)
    v0 = v(i-1); % start velocity of the current segment

    % tangential force
    ft = sqrt(ft_max^2 - car.mass / raceline.R(i) * (ft_max/fn_max)^2 *v0);
    
    a = ft/car.mass; % acceleration F = ma
    s = raceline.L(i)-raceline.L(i-1); % segment length

    % compute velocity (as derived from v = v0 + at)
    v_current = sqrt(v0^2 + 2*a*s);

    % compute critical velocity at the point (from reference)
    v_critical = fn_max * sqrt(raceline.R(i)/car.mass);

    % Check if current velocity is within its bounds
    if ~(v_current < v_critical)
        v_current = v_critical;
    end

    % append correct velocity
    v(i) = v_current;
end

%% Then for all the detected corners of the track
for i = 1:length(locations_idx)
    % compute critical velocity at the corners
    v_critical = fn_max * sqrt(raceline.R(locations_idx(i))/car.mass);
    
    %% At the corner locations we have V_crit always
    v(locations_idx(i)) = v_critical;

    %% After the corner we have maximum acceleration

    v0 = v(locations_idx(i)); % start velocity (at the corner)

    % tangential force at the corner
    ft = sqrt(ft_max^2 - car.mass / raceline.R(locations_idx(i)) * (ft_max/fn_max)^2 *v0);

    a = ft/car.mass; % acceleration at the corner
    s = raceline.L(locations_idx(i)) - raceline.L(locations_idx(i)-1); % segment length

    v_current = sqrt(v0^2 + 2*a*s);
    if ~(v_current < v_critical)
        v_current = v_critical;
    end
    
    % set the velocity after the corner to the velocity using max
    % acceleration
    v(locations_idx(i)+1) = v_current;

    %% We need to compute the intra corner velocities
    % so from 2 points behind a corner to the next corner -> intra segment
    if ~(i == length(locations_idx))
        for j = locations_idx(i)+2:locations_idx(i+1)
            v0 = v(j-1); % start velocity of the current segment

            % tangential force
            ft = sqrt(ft_max^2 - car.mass / raceline.R(j) * (ft_max/fn_max)^2 *v0);

            a = ft/car.mass; % acceleration F = ma
            s = raceline.L(j)-raceline.L(j-1); % segment length

            % compute velocity (as derived from v = v0 + at)
            v_current = sqrt(v0^2 + 2*a*s);

            % compute critical velocity at the point (from reference)
            v_critical = fn_max * sqrt(raceline.R(j)/car.mass);

            % Check if current velocity is within its bounds
            if ~(v_current < v_critical)
                v_current = v_critical;
            end

            % append correct velocity
            v(j) = v_current;
        end
    end
end

%% From the final corner to the end of the track
for i = locations_idx(end)+2:n
    v0 = v(i-1); % start velocity of the current segment

    % tangential force
    ft = sqrt(ft_max^2 - car.mass / raceline.R(i) * (ft_max/fn_max)^2 *v0);
    
    a = ft/car.mass; % acceleration F = ma
    s = raceline.L(i)-raceline.L(i-1); % segment length

    % compute velocity (as derived from v = v0 + at)
    v_current = sqrt(v0^2 + 2*a*s);

    % compute critical velocity at the point (from reference)
    v_critical = fn_max * sqrt(raceline.R(i)/car.mass);

    % Check if current velocity is within its bounds
    if ~(v_current < v_critical)
        v_current = v_critical;
    end

    % append correct velocity
    v(i) = v_current;
end

figure
plot(raceline.L, v, 'r')
xlabel("s")
ylabel("v")

end

