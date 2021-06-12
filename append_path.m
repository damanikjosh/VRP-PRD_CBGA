function [path, dist, time] = append_path(agent, path, node, n, sij, tr)
    
    if nargin < 6
        tr = 0;
    end
    
    start_node = agent.nodes(1);
    end_node = agent.nodes(2);
    
    nodes = path.node;
    times = path.time;
    trs = path.tr;
    
    dist = 0;
    if ~isempty(node)
        nodes = [nodes(1:n) node nodes(n+1:end)];
        times = [times(1:n) 0 times(n+1:end)];
        trs = [trs(1:n) tr trs(n+1:end)];
    end
    
    if ~isempty(nodes)
        add_dist = sij(start_node, nodes(1));
        dist = dist + add_dist;
        times(1) = max([trs(1) add_dist]);
    end
    
    for i = 1:length(nodes)-1
        add_dist = sij(nodes(i), nodes(i+1));
        dist = dist + add_dist;
        times(i+1) = max([trs(i+1) times(i) + add_dist]);
    end
    
    if isempty(nodes)
        add_dist = sij(start_node, end_node);
        dist = add_dist;
        time = add_dist;
    else
        add_dist = sij(nodes(end), end_node);
        dist = dist + add_dist;
        time = times(end) + add_dist;
    end
    
    path.node = nodes;
    path.time = times;
    path.tr = trs;
end