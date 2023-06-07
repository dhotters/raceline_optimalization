clc
clear all
close all

n = 200;
global track
track = trackReader("track\Spa.csv", n);

% Vector of percentage trackwidth location of the race line
% x0 being the initial state of the coefficients (ie the design variables)
x0 = ones(n, 1).*0.5; 

% % Compute raceline with the coeffcient vector
% raceline = getRaceLine(x0, track);
% 
% % Plot the current state
% track_plotter(track, raceline);

% % Setup car
% car.mass = 1000; % kg
% car.friction_coef = 1.25;
% 
% getLapTime(track, raceline, car)

%% TODO
%% 1 - Get a velocity profile with a given raceline curve
%% With this velocity profile compute the lap time
%% 2 - Optimize the a_vec and create equality and inequality constraints

lb = zeros(n, 1);
ub = ones(n, 1);
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
options.FunValCheck     = 'off';
options.PlotFcns        = {@optimplotfval, @optimplotx, @optimplotfirstorderopt, @optimplotstepsize, @optimplotconstrviolation, @optimplotfunccount};
options.MaxIter         = 1000;
options.MaxFunEvals = 1e9;

%% fmincon to try it out on curvature
tic
[x,FVAL,EXITFLAG,OUTPUT] = fmincon(@opt, x0, [], [], [], [], lb, ub, [], options);
toc

% plot result
figure(2)
track_plotter(track, getRaceLine(x, track));

function [f] = opt(x)
    global track

    % calculate raceline given a coef vector x
    raceline = getRaceLine(x, track);

    % objective function
    f = sum(raceline.rad_per_meter);
end