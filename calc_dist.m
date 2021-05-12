function [score, time] = calc_dist(path, sij, t0, d0)
    score = 0;
    if nargin < 3
        t0 = 0;
    end
    if nargin < 4
        d0 = zeros(size(path));
    end
        
    time = zeros(size(path)) - t0;
    time(1) = time(1) + d0(1);
    for i = 1:(length(path)-1)
        m = path(i);
        n = path(i+1);
        time(i+1) = time(i) + sij(m,n) + d0(i+1);
        score = score + sij(m,n);
    end
end