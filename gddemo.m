function gddemo
% GDDEMO A little demonstration of gradient descent.  
%
% Click in the space above the error surface to drop a ball onto it.  Ball 
% descends gradient using local search (negative hill-climbing), after 
% which final weights are shown by intersecting lines on axes.  Click on 
% the axes below the error surface to show the error at the corresponding 
% weights.

% clear out any stale graphic handles for callback function
clear all

% arbitrary weight params to work with ACTFUN
WMIN = -3;
WMAX = 3;
WCNT = 60;

% get a grid of weight values
[w1grid,w2grid] = meshgrid(linspace(WMIN, WMAX, WCNT)); 

% compute the error values at those weights
ygrid = errfun(w1grid, w2grid);

% show the error values as a mesh
mesh(w1grid, w2grid, ygrid)

% use a black-and-white grid
colormap bone

% make the grid half transparent
alpha(0.5)

% make the figure look nice
axis([WMIN WMAX WMIN WMAX 0 1])
xlabel('Weight 1')
ylabel('Weight 2')
zlabel('Error')
set(gcf, 'Name', 'Gradient Descent Demo')

% set up callback function for mouse-button clicks
set(gcf, 'WindowButtonDownFcn', @callback);

% BEGIN CALLBACK FUNCTION ---------------------------------------------------

function callback(src, eventData)

% display params
DROPSTEP = 0.05;    % vertical drop on ball from "sky" on each step
DROPPAUSE = 0.05;   % pause between drop steps, in seconds
DESCPAUSE = 0.10;   % pause between gradient-descent steps
ZGAP = 0.01;        % gap between bottom of ball and surface
DERIVRAD = 0.1;     % radius for searching steepest gradient
DERIVCNT = 100;     % how many points to sample in square enclosing radius

% graphics handles, for erasing previous ball, lines
persistent ballh    
persistent xh
persistent yh
persistent zh

% last X, Y axis values clicked
persistent xlast
persistent ylast

% get foreground, background points where user clicked
xyzfb = get(gca, 'CurrentPoint');

% use foreground point
xyz = xyzfb(1,:); 

% parse point into individual coordinates 
x = xyz(1);
y = xyz(2);
z = xyz(3);

% get axis limits
[xmin,xmax] = getlim('XLim');
[ymin,ymax] = getlim('YLim');
[zmin,zmax] = getlim('ZLim');

% if user clicked in region above surface, run gradient descent
if z > zmax/2 & z <= zmax
    
    % erase any previous ball, line images
    ballh = trydel(ballh);
    xh = trydel(xh);
    yh = trydel(yh);
    zh = trydel(zh);
    
    % reset previous line coordinates
    xlast = [];
    ylast = [];
    
    % avoid erasing previously plotted objects
    hold on
    
    % get Z coordinates for kinematic drop points
    zdrop = z:-DROPSTEP:errfun(x, y)+ZGAP;
    
    % animate ball dropping from clicked point onto error surface
    for z = zdrop
        ballh = drawball(x, y, z);
        if z ~= zdrop(end)
            pause(DROPPAUSE)
            delete(ballh)
        end
    end
    
    % lastz tracks previous error value for halting descent
    lastz = Inf;
    
    % "loop forever", but we'll break when error stops falling
    while true
        
        % get a bunch of weight pairs in a radius around the current pair
        [nbrx,nbry] = discpoints(x, y, DERIVRAD, DERIVCNT);
        
        % compute the errors at those weight pairs
        nbrz = errfun(nbrx, nbry);
        
        % choose weight pair where the error is lowest
        j = find(nbrz == min(nbrz));
        x = nbrx(j);
        y = nbry(j);
        
        % compute the error at that weight pair 
        z = errfun(x, y);
        
        % if error has gone up, we're done
        if z > lastz
            xh = plotwgt(x, x, ymin, ymax); % draw line for final weight 1
            yh = plotwgt(xmin, xmax, y, y); %  line for final weight 2
            zh = plotvert(x, y, z);         %  line from weights to ball 
            break
        end
        
        % if we go off the edge of the surface, beep and halt
        if x < xmin | x > xmax | y < ymin | y > ymax
            beep
            break
        end
        
        % otherwise, continue animating the ball
        pause(DESCPAUSE)
        delete(ballh)
        ballh = drawball(x, y, z+ZGAP);
        lastz = z;
        
    end
    
% user clicked below surface or outside plot    
else
    
    % any click erases previous weight lines
    if isempty(xlast) & isempty(ylast)
        xh = trydel(xh);
        yh = trydel(yh);
        zh = trydel(zh);
    end
  
    % user clicked on bottom of plot (Z = 0)
    if abs(z-zmin) < .1
        
        % always remove previous ball image
        ballh = trydel(ballh);
        
        % draw line on X or Y axis if user clicked close enough to it
        xh = tryline(x, xmin, xmin, xmax, y, y, xh);
        yh = tryline(y, ymin, x, x, ymin, ymax, yh);
        
        % clicking on X (Y) axis tracks value on Y (X) axis
        if x == xmin
            ylast = y;
        elseif y == ymin
            xlast = x;
        end
        
        % if we have X and Y axis values, plot error at that weight pair
        if ~isempty(xlast) & ~isempty(ylast)
            z = errfun(xlast, ylast);               % compute error
            ballh = drawball(xlast, ylast, z+ZGAP); % draw ball
            zh = trydel(zh);                        % erase old vert. bar
            zh = plotvert(xlast, ylast, z);         % plot new vert. bar
        end
    end
end

% BEGIN LOCAL FUNCTIONS ---------------------------------------------------

% draw a line if axis was clicked
function h = tryline(xy, xymin, xlo, xhi, ylo, yhi, h)
if xy == xymin
    hold on
    h = trydel(h);
    h = plotwgt(xlo, xhi, ylo, yhi);
end

% get axis limits
function [lo,hi] = getlim(limstr)
lim = get(gca, limstr);
lo = lim(1);
hi = lim(2);

% delete a graphic object safely
function h = trydel(h)
if ~isempty(h)
    try % deal with invalid graphics handle
        delete(h)
    catch
        h = [];
    end
end

% plot a line corresponding to a weight
function h = plotwgt(xlo, xhi, ylo, yhi)
h = plot3([xlo xhi], [ylo yhi], [0 0], 'r');

% plot a vertical line between a weight pair and the ball 
function h = plotvert(x, y, z)
h = plot3([x x], [y y], [0 z], 'k');

% draw the ball at a specified location
function h = drawball(x, y, z)
h = plot3(x, y, z, '.r', 'MarkerSize',20);

