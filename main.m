clc
clear all
close all

% globals
global track
global car
global raceline0
global t0

n = 400;
track = trackReader("track\Silverstone.csv", n);

% Setup car
% NOTE not a good idea to take F1 car values here cause those benefit a lot
% from aerodynamic performance hence we assume our vehicle does not benefit
% from aerodynamics -> else the max traction etc is not correct anymore as
% it is speed dependant
car.mass = 750; % kg
car.max_g_accel = 0.5; % Max G force in acceleration
car.max_g_brake = 1; % Max G force when braking
car.max_g_lateral = 1; % Max G force laterally
car.cd = 0.25; % drag coefficient (assumed constant)
car.rho = 1.225; % air density around the track
car.S = 1.3; % frontal area m2

% Vector of percentage trackwidth location of the race line
% x0 being the initial state of the coefficients (ie the design variables)
%x0 = ones(n, 1).*0.5; 
centerline = getRaceLine(ones(n, 1).*0.5, track);
%track_plotter(track, centerline);
x0 = getInitialCond(track, n, centerline);

% Compute raceline with the coeffcient vector
raceline0 = getRaceLine(x0, track); % We use the initial raceline to normalize
%raceline = load('raceline100.mat').raceline;

% Compute lap time, used for normalization
t0 = getLapTime(track, raceline0, car);

% Plot the current state
%track_plotter(track, raceline);

%% TODO
%% 1 - Get a velocity profile with a given raceline curve
%% With this velocity profile compute the lap time
%% 2 - Optimize the coefficient vector and create equality and inequality constraints

lb = zeros(n, 1);
ub = ones(n, 1);
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
options.FunValCheck     = 'off';
options.PlotFcns        = {@optimplotfval, @optimplotx, @optimplotfirstorderopt, @optimplotstepsize, @optimplotconstrviolation, @optimplotfunccount};
options.MaxIter         = 1000;
options.MaxFunEvals     = 1e9;
options.TolFun = 1e-3;
options.TolX = 1e-15;

%% fmincon to try it out on curvature
tic
figure(1)
[x,FVAL,EXITFLAG,OUTPUT] = fmincon(@opt, x0, [], [], [], [], lb, ub, @constraints, options);
toc

% plot result
figure(2)
raceline = getRaceLine(x, track);
save("raceline", "raceline");
track_plotter(track, getRaceLine(x, track));

function [f] = opt(x)
    global track
    global car
    global raceline0
    global t0

    % calculate raceline given a coef vector x
    raceline = getRaceLine(x, track);

    t = getLapTime(track, raceline, car) / t0; % estimate lap time
    K = sum(raceline.rad_per_meter) / sum(raceline0.rad_per_meter); % measure of total track curvature
    L = sum(raceline.L) / sum(raceline0.L); % path length

    % objective function
    %f = sum(raceline.rad_per_meter);
    f = t;
end

function [c, ceq] = constraints(x)

    % We have constraint that the start and end point of the coef vector must
    % be the same
    P_start = x(1);
    P_end = x(end);

    delta = P_start - P_end;

    ceq = delta;
    c = [];
end