function [t] = getLapTime(track, raceline, car)
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
% ie we detect the corner locations
raceline.K(1) = 0; % Else it will take start and end point as a corner
raceline.K(end) = 0;

% Find maxima of curvature (same as minimum radius)
[peaks, locations_idx] = findpeaks(raceline.K); 

% % visualize maxima of curvature as its more clear for debugging
% figure
% plot(raceline.L, raceline.R, 'r');
% hold on
% title("len vs R")
% scatter(raceline.L(locations_idx), 1./peaks, '*black');

%% Step 2 of the reference
% optimal velocity profile subject to **FREE** boundary conditions
% Note that the track is cut into sections hence the for loops
% sections are: 
% - start point to first corner
% - intra-corner sections
% - last corner to last point


%% From the start of the track to the first corner (location_idx(1))
% NOTE starting from v0 = 0 m/s -> could add this as an input as this is
% a boundary condition
v = zeros(n, 1);
for i = 2:locations_idx(1)
    v0 = v(i-1); % start velocity of the current segment
    
    % compute drag force
    D = car.cd * 1/2 * car.rho * v0^2 * car.S;

    % tangential force
    ft_max_current = ft_max - D; % including the drag force
    ft = sqrt(ft_max_current^2 - car.mass / raceline.R(i) * (ft_max_current/fn_max)^2 *v0);
    
    a = ft/car.mass; % acceleration F = ma
    s = raceline.L(i)-raceline.L(i-1); % segment length

    % compute velocity (as derived from v = v0 + at)
    v_current = sqrt(v0^2 + 2*a*s);

    % compute critical velocity at the point (from reference)
    v_critical = sqrt(fn_max*raceline.R(i)/car.mass);

    % Check if current velocity is within its bounds
    if ~(v_current < v_critical)
        v_current = v_critical;
    end

    % append correct velocity
    v(i) = v_current;
end

%% Then for all the detected corners of the track
for i = 1:length(locations_idx)
    %% At the corner locations we have V_crit always
    % compute critical velocity at the current corner location
    v_critical = sqrt(fn_max * raceline.R(locations_idx(i))/car.mass);

    if v(locations_idx(i)) < v_critical
        v0 = v(locations_idx(i));
    else
        v0 = v_critical;
        v(locations_idx(i)) = v_critical;
    end
    %v(locations_idx(i)) = v_critical;

    %% After the corner we have maximum acceleration

    %v0 = v(locations_idx(i)); % start velocity (at the corner) = same as vcrit
    
    % drag force
    D = car.cd * 1/2 * car.rho * v0^2 * car.S;

    % tangential force at the corner
    ft_max_current = ft_max - D; % including drag force
    ft = sqrt(ft_max_current^2 - car.mass / raceline.R(locations_idx(i)) * (ft_max_current/fn_max)^2 *v0);

    a = ft/car.mass; % acceleration at the corner
    s = raceline.L(locations_idx(i)) - raceline.L(locations_idx(i)-1); % segment length

    v_current = sqrt(v0^2 + 2*a*s);
%     if ~(v_current < v_critical)
%         v_current = v_critical;
%     end
    
    % set the velocity after the corner to the velocity using max
    % acceleration
    v(locations_idx(i)+1) = v_current;

    %% We need to compute the intra corner velocities
    % so from 2 points behind a corner to the next corner -> intra segment
    if ~(i == length(locations_idx))
        for j = locations_idx(i)+2:locations_idx(i+1)
            v0 = v(j-1); % start velocity of the current segment
            
            % compute drag force
            D = car.cd * 1/2 * car.rho * v0^2 * car.S;

            % tangential force
            ft_max_current = ft_max - D;
            ft = sqrt(ft_max_current^2 - car.mass / raceline.R(j-1) * (ft_max_current/fn_max)^2 *v0);

            a = ft/car.mass; % acceleration F = ma
            s = raceline.L(j)-raceline.L(j-1); % segment length

            % compute velocity (as derived from v = v0 + at)
            v_current = sqrt(v0^2 + 2*a*s);

            % compute critical velocity at the point (from reference)
%             v_critical = fn_max * sqrt(raceline.R(j)/car.mass);
% 
%             % Check if current velocity is within its bounds
%             if ~(v_current < v_critical)
%                 v_current = v_critical;
%             end

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
    v_critical = sqrt(fn_max * raceline.R(i)/car.mass);

    % Check if current velocity is within its bounds
    if ~(v_current < v_critical)
        v_current = v_critical;
    end

    % append correct velocity
    v(i) = v_current;
end

%v(end) = car.v_end; % BC

%% Step 3 of the reference
% Next up we have to do the same but we go backwards to solve the braking
% zones. The last bullet point of the reference then says to take the
% minimum solution of the acceleration zone and braking zone as the actual
% velocity in point i

%% NOTE This is also a boundary condition we say the end speed is 0 m/s
%% when using zeros !!!
v_bw = zeros(n, 1);

%% TODO Check from here on out as you gotta think in reverse
% From last point -1 to last corner
for i = n-1:-1:locations_idx(end)
    % we go from final point -1 (due to the BC) backwards
    v0 = v_bw(i+1); % start velocity of the current segment
    
    % compute drag force
    D = car.cd * 1/2 * car.rho * v0^2 * car.S;

    % tangential force
    fb_max_current = fb_max + D; % including the drag force
    fb = sqrt(fb_max_current^2 - car.mass / raceline.R(i) * (ft_max_current/fn_max)^2 *v0);
    
    a = fb/car.mass; % acceleration F = ma
    s = raceline.L(i+1)-raceline.L(i); % segment length

    % compute velocity (as derived from v = v0 + at)
    v_current = sqrt(v0^2 + 2*a*s);

%     % compute critical velocity at the point (from reference)
%     v_critical = sqrt(fn_max*raceline.R(i)/car.mass);
% 
%     % Check if current velocity is within its bounds
%     if ~(v_current < v_critical)
%         v_current = v_critical;
%     end

    % append correct velocity
    v_bw(i) = v_current;
end

%% Then at each corner location
for i = length(locations_idx):-1:1
    % At each corner location
    v_critical = sqrt(fn_max * raceline.R(i)/car.mass);
    if v_bw(locations_idx(i)) < v_critical
        v0 = v_bw(locations_idx(i));
    else
        v0 = v_critical;
        v_bw(locations_idx(i)) = v0;
    end

    % compute drag force
    D = car.cd * 1/2 * car.rho * v0^2 * car.S;

    % tangential force
    fb_max_current = fb_max + D; % including the drag force
    fb = sqrt(fb_max_current^2 - car.mass / raceline.R(i) * (ft_max_current/fn_max)^2 *v0);
    
    a = fb/car.mass; % acceleration F = ma
    s = raceline.L(locations_idx(i))-raceline.L(locations_idx(i)-1); % segment length

    % compute velocity (as derived from v = v0 + at)
    v_current = sqrt(v0^2 + 2*a*s);

    v_bw(locations_idx(i)-1) = v_current;

    if ~(i == 1)
        %% Intra corner for loop like before but backward
        for j = locations_idx(i)-2:-1:locations_idx(i-1)
            v0 = v(j+1); % start velocity of the current segment
            
            % compute drag force
            D = car.cd * 1/2 * car.rho * v0^2 * car.S;

            % tangential force
            fb_max_current = fb_max + D;
            fb = sqrt(fb_max_current^2 - car.mass / raceline.R(j+1) * (fb_max_current/fn_max)^2 *v0);

            a = fb/car.mass; % acceleration F = ma
            s = raceline.L(j+1)-raceline.L(j); % segment length

            % compute velocity (as derived from v = v0 + at)
            v_current = sqrt(v0^2 + 2*a*s);
            
            v_bw(j) = v_current;
        end
    end
end

%% From first corner to start point
for i = locations_idx(1)-2:-1:1
    v0 = v_bw(j+1);

    % compute drag force
    D = car.cd * 1/2 * car.rho * v0^2 * car.S;

    % tangential force
    fb_max_current = fb_max + D;
    fb = sqrt(fb_max_current^2 - car.mass / raceline.R(j+1) * (fb_max_current/fn_max)^2 *v0);

    a = fb/car.mass; % acceleration F = ma
    s = raceline.L(j+1)-raceline.L(j); % segment length

    % compute velocity (as derived from v = v0 + at)
    v_current = sqrt(v0^2 + 2*a*s);

    v_bw(j) = v_current;
end

%v_bw(1) = car.v_start; % BC

%% Final step of the reference
% We need the minimum of the above characteristics and this is the final
% velocity profile
v_final = zeros(n, 1);
for i = 1:n
    v_final(i) = min(v(i), v_bw(i));
end

%% debug figure
% plot(raceline.L, v, 'r')
% xlabel("s")
% ylabel("v")

%% Compute lap time from the velocity vector
% using v^2 = v0^2 + 2as as derived
t = 0;
for i = 2:n
    v0 = v(i-1);
    s = raceline.L(i) - raceline.L(i-1);
    a = (v(i)^2 - v0^2) / (2*s);

    dt = (v(i) - v0) / a;
    t = t + dt;
end

% % display the laptime
% disp("Lap time: " + t + " seconds")

end

