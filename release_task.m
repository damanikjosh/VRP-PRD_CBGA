[~, k_bundle_rel] = ismember([k_rel_d k_rel_e],  [k_bundle.req]', 'rows');
    
if k_bundle_rel > 0
    for nn = length(k_bundle):-1:k_bundle_rel
        fprintf('Agent %d: Releasing Task (%d,%d)\n', curr_k, k_bundle(nn).req);

        for idx = 2:-1:1
            if k_bundle(nn).add(idx) == 0
                continue
            end
            k_path.node(k_bundle(nn).add(idx)) = [];
            k_path.time(k_bundle(nn).add(idx)) = [];
            k_path.tr(k_bundle(nn).add(idx)) = [];
%             k_timestamp(k_bundle(nn).add(idx)) = [];
        end
        
        k_score(k_bundle(nn).req(1), k_bundle(nn).req(2)) = 0;
        k_winner(k_bundle(nn).req(1), k_bundle(nn).req(2)) = 0;
        k_time(k_bundle(nn).req(1), k_bundle(nn).req(2)) = 0;
        
        k_bundle(nn) = [];
        if isempty(k_bundle)
            k_last_dist = 0;
        else
            k_last_dist = k_bundle(nn-1).dist;
        end
        
    end
end