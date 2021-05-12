k_reqs = zeros(num_delivs, num_edges);
k_temps = zeros(num_edges, num_edges, num_delivs);
for dd = 1:num_delivs
%     for ee = 1:num_edges
%         if k_score(dd, ee) == 0
%             continue
%         end
%         if deliv(dd).nodes(1) ~= edges(ee, 1)
%             k_reqs(dd, ee) = 1;
%             [~, ff] = ismember([deliv(dd).nodes(1) edges(ee, 1)], edges(:,1:2), 'rows');
%             k_reqs(dd, ff) = 1;
%             k_temps(ff, ee, dd) = -1e10;
%         end
%         if deliv(dd).nodes(2) ~= edges(ee, 2)
%             k_reqs(dd, ee) = 1;
%             [~, ff] = ismember([edges(ee, 2) deliv(dd).nodes(2)], edges(:,1:2), 'rows');
%             k_reqs(dd, ff) = 1;
%             k_temps(ee, ff, dd) = -1e10;
%         end
%     end
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
end