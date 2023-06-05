clc
clear all
close all

n = 1000;
track = trackReader("track\Spa.csv", n);

% Vector of percentage trackwidth location of the race line
% x0 being the initial state of the coefficients (ie the design variables)
x0 = ones(n, 1).*0.5; 

% Compute raceline with the coeffcient vector
raceline = getRaceLine(x0, track);

% Plot the current state
track_plotter(track, raceline);

% Setup car
car.mass = 1000; % kg
getLapTime(track, raceline, car)

%% TODO
%% 1 - Get a velocity profile with a given raceline curve
%% With this velocity profile compute the lap time
%% 2 - Optimize the a_vec and create equality and inequality constraints