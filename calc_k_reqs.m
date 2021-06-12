k_reqs = zeros(num_delivs, num_edges);
k_tr = zeros(num_delivs, num_edges);
k_dely = +1e10 * ones(num_delivs, num_edges);

for dd = 1:num_delivs
    req_edges = find(k_score(dd, :) > 0);
    if isempty(req_edges)
        continue
    end
    req_nodes = edges(req_edges, 1:2);
    
    ii = 1;
    while ii < size(req_nodes,1)
        jj = ii + 1;
        while jj <= size(req_nodes,1)
            if req_nodes(ii,2) == req_nodes(jj,1)
                req_nodes(ii,2) = req_nodes(jj,2);
                req_nodes(jj,:) = [];
                ii = 0;
                break;
            end
            if req_nodes(ii,1) == req_nodes(jj,2)
                req_nodes(ii,1) = req_nodes(jj,1);
                req_nodes(jj,:) = [];
                ii = 0;
                break
            end
            jj = jj + 1;
        end
        ii = ii + 1;
    end
    
    assert(size(req_nodes,1) == 1, 'Size of req_nodes is not 1');
    
    for ee = req_edges
        k_reqs(dd, ee) = 1;
    end
    
    if req_nodes(1) ~= deliv(dd).nodes(1)
        [~, ff] = ismember([deliv(dd).nodes(1) req_nodes(1)], edges(:,1:2), 'rows');
        k_reqs(dd, ff) = 1;
    end
    
    if req_nodes(2) ~= deliv(dd).nodes(2)
        [~, ff] = ismember([req_nodes(2) deliv(dd).nodes(2)], edges(:,1:2), 'rows');
        k_reqs(dd, ff) = 1;
    end
    
    for ee = 1:num_edges %TODO: Balikin ke req_nodes aja
        for ff = ee+1:num_edges
            
            if temps(ee, ff, dd)
                k_tr(dd, ff) = max([k_tr(dd, ff) k_time(dd, ee)]);
%                 fprintf('%d %d %.4f\n', ee, ff, k_time(dd, ee));
            end
            if temps(ff, ee, dd)
                k_tr(dd, ee) = max([k_tr(dd, ee) k_time(dd, ff)]);
%                 fprintf('%d %d %.4f\n', ff, ee, k_time(dd, ff));
            end
        end
    end
end

