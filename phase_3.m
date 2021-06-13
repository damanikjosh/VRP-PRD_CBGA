k_bundle = bundle{curr_k};

k_score = score(:,:,curr_k);
k_winner = winner(:,:,curr_k);
k_time = time(:,:,curr_k);

calc_k_reqs;
% k_bundle = extract_time(k_bundle, k_path);
k_temporal_conflict = false;

for nn = length(k_bundle.bids.req):-1:1
    if size(k_bundle.bids.req, 1) < nn
        continue
    end
    d = k_bundle.bids.req(nn,1);
    e = k_bundle.bids.req(nn,2);
    if k_bundle.bids.time(nn,2) < trel(d, e, curr_k) + sij(edges(e,1), edges(e,2))
        fprintf('Agent %d: Temporal conflict, releasing request (%d,%d)\n', curr_k, d, e);
        k_temporal_conflict = true;
        [k_bundle, k_rel_reqs] = k_bundle.release([d,e], sij);
        for n = 1:size(k_rel_reqs, 1)
            k_score(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
            k_winner(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
            k_time(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
        end
%         k_rewards(d, e) = 0;
%         rewards(d, e, curr_k) = 0;
    end
end