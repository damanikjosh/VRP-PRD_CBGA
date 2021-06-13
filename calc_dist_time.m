function [dists, times] = calc_dist_time(nodes, trs, sij)
    dists = zeros(1, length(nodes));
    times = zeros(1, length(nodes));
    for i = 1:length(nodes)-1
        add_dist = sij(nodes(i), nodes(i+1));
        dists(i+1) = dists(i) + add_dist;
        times(i+1) = max([trs(i+1) times(i) + add_dist]);
    end
end