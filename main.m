clc
clear all
close all

n = 1000;
track = track_plotter("track\Silverstone.csv", n);

% % Compute curvature
% X = [track.x_m, track.y_m];
% 
% [L,R,K] = curvature(X);
% figure;
% plot(L,R)
% title('Curvature radius vs. cumulative curve length')
% xlabel L
% ylabel R
% figure;
% h = plot(track.x_m',track.y_m'); 
% grid on
% axis equal
% set(h,'marker','.');
% xlabel x
% ylabel y
% title('2D curve with curvature vectors')
% hold on
% quiver(track.x_m,track.y_m,K(:,1),K(:,2));
% hold off
% 
% total_curvature = sum(1./R, 'omitnan');

% Vector of percentage trackwidth location of the race line
a_vec = ones(length(track.x_m), 1).*0.1; 

getRaceLine(a_vec, track)