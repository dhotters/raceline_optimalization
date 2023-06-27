function [x] = getInitialCond(track, n, centerline)

x0 = ones(n, 1).*0.5; 


lb = zeros(n, 1);
ub = ones(n, 1);
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
options.FunValCheck     = 'off';
options.PlotFcns        = {@optimplotfval, @optimplotx, @optimplotfirstorderopt, @optimplotstepsize, @optimplotconstrviolation, @optimplotfunccount};
options.MaxIter         = 100;
options.MaxFunEvals     = 1e9;
options.TolFun = 1e-3;
options.TolX = 1e-6;

%% fmincon to try it out on curvature
figure(1)
[x,FVAL,EXITFLAG,OUTPUT] = fmincon(@opt, x0, [], [], [], [], lb, ub, @constraints, options);

function [f] = opt(x)
    % calculate raceline given a coef vector x
    raceline = getRaceLine(x, track);

    K = sum(raceline.rad_per_meter) / sum(centerline.rad_per_meter); % measure of total track curvature
    L = sum(raceline.L) / sum(centerline.L); % path length

    % objective function
    %f = sum(raceline.rad_per_meter);
    f = K;
end

function [c, ceq] = constraints(x)

    % We have constraint that the start and end point of the coef vector must
    % be the same
    P_start = x(1);
    P_end = x(end);

    delta = P_start - P_end;

    ceq = [delta];
    c = [];
end
end

