[~, k_bundle_rel] = ismember([k_rel_d k_rel_e], k_bundle, 'rows');
    
if k_bundle_rel > 0
    for nn = size(k_bundle, 1):-1:k_bundle_rel
        fprintf('Agent %d: Releasing Task (%d,%d)\n', curr_k, k_bundle(nn,1), k_bundle(nn,2));

        for idx = 2:-1:1
            if k_add_nodes(nn,idx) == 0
                continue
            end
            k_path(k_add_nodes(nn,idx)) = [];
%             k_time(k_add_nodes(nn,idx)) = []; #TODO timestamp
        end
        k_score(k_bundle(nn,1), k_bundle(nn,2)) = 0;
        k_winner(k_bundle(nn,1), k_bundle(nn,2)) = 0;
        k_last_dist = k_last_dist - k_add_dist(nn);
        k_bundle(nn, :) = [];
        k_add_nodes(nn, :) = [];
        k_add_dist(nn) = [];
        k_cost(nn) = [];
    end
end