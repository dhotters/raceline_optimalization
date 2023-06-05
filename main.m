clc
clear all
close all

n = 1000;
track = trackReader("track\Spa.csv", n);

% Vector of percentage trackwidth location of the race line
a_vec = ones(n, 1).*0.25; 

raceline = getRaceLine(a_vec, track);

% plot the current state
track_plotter(track, raceline);

%% TODO
%% 1 - Get a velocity profile with a given raceline curve
%% With this velocity profile compute the lap time
%% 2 - Close the track curves
%% 3 - Optimize the a_vec and create equality and inequality constraints