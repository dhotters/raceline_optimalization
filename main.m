clc
clear all
close all

n = 1000;
track = track_plotter("track\Spa.csv", n);

% Vector of percentage trackwidth location of the race line
a_vec = ones(length(track.x_m), 1).*0.25; 

raceline = getRaceLine(a_vec, track);

% plot the current raceline based on the given coefficients
hold on
plot(raceline.x, raceline.y, 'r');
