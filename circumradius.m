function [radius] = circumradius(A, B, C)
% computes the circumradius for a triangle with nodes A, B and C

% compute length of the sides of the triangle
a = hypot(A(1)-C(1), A(2)-C(2)); % between A and C
b = hypot(B(1)-C(1), B(2)-C(2)); % between B and C
c = hypot(A(1)-B(1), A(2)-B(2)); % between A and B

% calculate the area using heron's formula
s = (a+b+c)/2;
area = sqrt(s*(s - a)*(s - b)*(s - c));

% compute the circumradius
radius = a*b*c/(4*area);
end

