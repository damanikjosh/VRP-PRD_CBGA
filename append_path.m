function path = append_path(agent, path, node, n, sij, tr)
    
    if nargin < 6
        tr = 0;
    end
    
    start_node = agent.nodes(1);
    end_node = agent.nodes(2);
    
    nodes = path.node;
    trs = path.tr;
    
    if ~isempty(node)
        nodes = [nodes(1:n) node nodes(n+1:end)];
        trs = [trs(1:n) tr trs(n+1:end)];
    end
    
%     if ~isempty(nodes)
%         add_dist = sij(start_node, nodes(1));
%         dist = dist + add_dist;
%         times(1) = max([trs(1) add_dist]);
%     end
    
    [dists, times] = calc_dist_time([start_node, nodes, end_node], [0, trs, 0], sij);
    times = times(2:end-1);
    
%     for i = 1:length(nodes)-1
%         add_dist = sij(nodes(i), nodes(i+1));
%         dist = dist + add_dist;
%         times(i+1) = max([trs(i+1) times(i) + add_dist]);
%     end
%     
%     if isempty(nodes)
%         add_dist = sij(start_node, end_node);
%         dist = add_dist;
%         time = add_dist;
%     else
%         add_dist = sij(nodes(end), end_node);
%         dist = dist + add_dist;
%         time = times(end) + add_dist;
%     end
    
    path.node = nodes;
    path.time = times;
    path.dist = dists;
    path.tr = trs;
end