function [score, time] = calc_dist(path, sij)
    score = 0;
    
    time = zeros(size(path));
    for i = 1:(length(path)-1)
        m = path(i);
        n = path(i+1);
        d_time = sij(m,n);
        time(i+1) = time(i) + d_time;
        score = score + d_time;
    end
end