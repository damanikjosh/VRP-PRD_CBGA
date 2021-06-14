k_reqs = zeros(num_delivs, num_edges);

% k_dely = +1e10 * ones(num_delivs, num_edges);

for dd = 1:num_delivs
    req_edges = find(k_score(dd, :) > 0);
    if isempty(req_edges)
        continue
    end
    
    start_edges = find(edges(:,1) == deliv(dd).nodes(1));
    end_edges = find(edges(:,2) == deliv(dd).nodes(2));
    
    if ismember(req_edges(1), start_edges) && ismember(req_edges(1), end_edges)
        req_order_asc = req_edges(1);
    elseif ismember(req_edges(1), start_edges)
        ff = end_edges(temps(req_edges(1), end_edges, dd)==1);
        req_order_asc = [req_edges(1), ff];
    elseif ismember(req_edges(1), end_edges)
        ff = start_edges(temps(start_edges, req_edges(1), dd)==1);
        req_order_asc = [ff, req_edges(1)];
    end
    
    for ee = req_order_asc
        k_reqs(dd, ee) = 1;
    end
    
    for ii = 2:length(req_order_asc)
       trel(dd, req_order_asc(ii), curr_k) = max([trel(dd, req_order_asc(ii), curr_k) k_time(dd, req_order_asc(ii-1))]);
    end
    
end

