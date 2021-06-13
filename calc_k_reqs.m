k_reqs = zeros(num_delivs, num_edges);
k_trel = zeros(num_delivs, num_edges);
% k_dely = +1e10 * ones(num_delivs, num_edges);

for dd = 1:num_delivs
    req_edges = find(k_score(dd, :) > 0);
    if isempty(req_edges)
        continue
    end
    
    start_edges = find(edges(:,1) == deliv(dd).nodes(1));
    end_edges = find(edges(:,2) == deliv(dd).nodes(2));
    
    req_order_asc = [];
    req_order_desc = [];
    req_done = false;
    
    for ii = length(req_edges):-1:1
        ee = req_edges(ii);
        if ismember(ee, start_edges) && ismember(ee, end_edges)
            k_reqs(dd, ee) = 1;
            req_order_asc = ee;
            req_done = true;
            req_edges = [];
            break
        elseif ismember(ee, start_edges)
            req_order_asc = ee;
            req_edges(ii) = [];
            continue
        elseif ismember(ee, end_edges)
            req_order_desc = ee;
            req_edges(ii) = [];
            continue
        end
    end
    
    for ii = length(req_edges):-1:1
        ee = req_edges(ii);
        if ~isempty(req_order_asc) && temps(req_order_asc(end), ee, dd)
                req_order_asc = [req_order_asc ee];
                req_edges(ii) = [];
        elseif ~isempty(req_order_desc) && temps(ee, req_order_desc(1), dd)
            req_order_desc = [ee, req_order_desc];
            req_edges(ii) = [];
        else
            if isempty(req_order_asc)
                ff = start_edges(temps(start_edges, ee, dd)==1);
                req_order_asc = [ff, ee];
            else
                node_i = edges(req_order_asc(end), 2);
                node_j = edges(ee, 1);
                [~, ff] = ismember([node_i, node_j], edges(:,1:2), 'rows');
                req_order_asc = [req_order_asc, ff, ee];
                req_edges(ii) = [];
            end
        end
    end
    
    if isempty(req_order_asc)
        if ismember(start_edges, req_order_desc(1))
            req_order_asc = [req_order_asc, req_order_desc];
            req_done = true;
        else
            ff = start_edges(temps(start_edges, req_order_desc(1), dd)==1);
            req_order_asc = [req_order_asc, ff, req_order_desc];
            req_done = true;
        end
    elseif isempty(req_order_desc)
        if ismember(req_order_asc(end), end_edges)
            req_order_asc = [req_order_asc, req_order_desc];
            req_done = true;
        else
            ff = end_edges(temps(req_order_asc(end), end_edges, dd)==1);
            req_order_asc = [req_order_asc, ff, req_order_desc];
            req_done = true;
        end
    end
    
    if ~req_done
        if temps(req_order_asc(end), req_order_desc(1), dd)
            req_order_asc = [req_order_asc, req_order_desc];
        else
            node_i = edges(req_order_asc(end), 2);
            node_j = edges(req_order_desc(1), 1);
            [~, ff] = ismember([node_i, node_j], edges(:,1:2), 'rows');
            req_order_asc = [req_order_asc, ff, req_order_desc];
        end
    end
    
    for ee = req_order_asc
        k_reqs(dd, ee) = 1;
    end
    
    for ii = 2:length(req_order_asc)
       k_trel(dd, req_order_asc(ii)) = max([k_trel(dd, req_order_asc(ii)) k_time(dd, req_order_asc(ii-1))]); 
    end
    
%     for ee = 1:num_edges %TODO: Balikin ke req_nodes aja
%         for ff = ee+1:num_edges
%             
%             if temps(ee, ff, dd)
%                 k_trel(dd, ff) = max([k_trel(dd, ff) k_time(dd, ee)]);
% %                 fprintf('%d %d %.4f\n', ee, ff, k_time(dd, ee));
%             end
%             if temps(ff, ee, dd)
%                 k_trel(dd, ee) = max([k_trel(dd, ee) k_time(dd, ff)]);
% %                 fprintf('%d %d %.4f\n', ff, ee, k_time(dd, ff));
%             end
%         end
%     end
end

