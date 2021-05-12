k_reqs = zeros(num_delivs, num_edges);
for dd = 1:num_delivs
    for ee = 1:num_edges
        if k_score(dd, ee) == 0
            continue
        end
        if deliv(dd).nodes(1) ~= edges(ee, 1)
            k_reqs(dd, ee) = 1;
            [~, row] = ismember([deliv(dd).nodes(1) edges(ee, 1)], edges(:,1:2), 'rows');
%                 if sum(k_score(d, :)) == 0
            if k_score(dd, row) == 0
                k_reqs(dd, row) = 1;
            end
        end
        if deliv(dd).nodes(2) ~= edges(ee, 2)
            k_reqs(dd, ee) = 1;
            [~, row] = ismember([edges(ee, 2) deliv(dd).nodes(2)], edges(:,1:2), 'rows');
%                 if sum(k_score(d, :)) == 0
            if k_score(dd, row) == 0
                k_reqs(dd, row) = 1;
            end
        end
    end
end