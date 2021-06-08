function Pb207_Pb206_age = newton_method(Pb76_ratio, initial_guess, Tolerance) 
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

L235 = log(2)/9.8485E-10;
L238 = log(2)/1.55125E-10;
YoverX = (1/Pb76_ratio)/137.88;
x = initial_guess;

for i = 1:1000
f = (1/137.88)*((exp(9.8485E-10*x) - 1)/(exp(1.55125E-10*x) - 1)) - Pb76_ratio;
fprime = ((33189*exp((45599*x)/4E13)) - (39394*exp((19697*x)/2E13)) + (6205*exp((1241*x)/8E12))) ...
	/ (5.5152E15*(((exp((1241*x)/8E12))-1)^2));
x = (x - f/fprime);
if abs(f/fprime) < Tolerance
break
end
end

Pb207_Pb206_age = x/1000000;

end

