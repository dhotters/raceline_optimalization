clc
clear all
close all

n = 10000;
spa = track_plotter("track\Spa.csv", n);

% Compute curvature
X = [spa.x_m, spa.y_m];

[L,R,K] = curvature(X);
figure;
plot(L,R)
title('Curvature radius vs. cumulative curve length')
xlabel L
ylabel R
figure;
h = plot(spa.x_m',spa.y_m'); 
grid on
axis equal
set(h,'marker','.');
xlabel x
ylabel y
title('2D curve with curvature vectors')
hold on
quiver(spa.x_m,spa.y_m,K(:,1),K(:,2));
hold off

