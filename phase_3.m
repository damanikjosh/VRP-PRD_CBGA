k_path = path{curr_k};
% k_timestamp = timestamp{curr_k};
k_bundle = bundle{curr_k};

k_score = score(:,:,curr_k);
k_winner = winner(:,:,curr_k);
k_time = time(:,:,curr_k);

calc_k_reqs;
k_bundle = extract_time(k_bundle, k_path);

for nn = length(k_bundle):-1:1
    d = k_bundle(nn).req(1);
    e = k_bundle(nn).req(2);
    if k_bundle(nn).time(1) < k_tr(d, e)
        k_rel_d = d;
        k_rel_e = e;
        release_task;
        fprintf('Agent %d: Releasing task %d (temporal conflict)\n', curr_k, d);
    end
end