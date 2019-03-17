function y = errfun(w1, w2)
% A little error function stolen from Matlab's PEAKS function.  GDDEMO
% should work with any ERRFUN that returns values in the interval [0,1].
%
% Copyright (c) 2019 Simon D. Levy
%
% MIT License

y =  3*(1-w1).^2.*exp(-(w1.^2) - (w2+1).^2) ...
    - 10*(w1/5 - w1.^3 - w2.^5).*exp(-w1.^2-w2.^2) ...
    - 1/3*exp(-(w1+1).^2 - w2.^2);

% scale output to [0,1]
y = (y + 10) / 20;
