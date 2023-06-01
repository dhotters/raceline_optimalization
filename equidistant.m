function [output] = equidistant(x, y, n)
% source: https://nl.mathworks.com/matlabcentral/answers/142161-how-can-i-interpolate-x-y-coordinate-path-with-fixed-interval
pathXY = [x, y]; % merge new x and y coordinates in one table
stepLengths = sqrt(sum(diff(pathXY,[],1).^2,2));
stepLengths = [0; stepLengths]; % add the starting point
cumulativeLen = cumsum(stepLengths); % Cumulative sum of all items --> last item contains total length
finalStepLocs = linspace(0,cumulativeLen(end), n);
output = interp1(cumulativeLen, pathXY, finalStepLocs);
end
