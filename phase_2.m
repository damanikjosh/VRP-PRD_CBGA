k_bundle = bundle{curr_k};

k_score = score(:,:,curr_k);
k_winner = winner(:,:,curr_k);
k_time = time(:,:,curr_k);

calc_k_reqs;

for i = 1:num_agents
    if i == curr_k
        continue
    end
    i_score = score(:,:,i);
    i_winner = winner(:,:,i);
    i_time = time(:,:,i);
    
    for d = 1:num_delivs
        for e = 1:num_edges
            if i_score(d,e) == 0 && k_score(d,e) == 0
                continue
            end
            if (i_winner(d,e) > 0 && i_winner(d,e) ~= curr_k)
                if (k_reqs(d, e) == 0) && (i_score(d,e) > max(k_score(d,:)))
                    fprintf('Agent %d: Agent %d has score higher for all requests in task %d\n', curr_k, i, d);
                    for f = 1:num_edges
                        if k_winner(d,f) > 0
                            if k_winner(d,f) == curr_k
                                [k_bundle, k_rel_reqs] = k_bundle.release([d,f], sij);
                                for n = 1:size(k_rel_reqs, 1)
                                    k_score(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
                                    k_winner(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
                                    k_time(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
                                end
                            end
                        end
                    end
                    k_score(d, e) = i_score(d, e);
                    k_winner(d, e) = i_winner(d, e);
                    k_time(d, e) = i_time(d, e);
                    calc_k_reqs;
                elseif k_reqs(d, e) == 1 && i_score(d,e) > k_score(d,e)
                    fprintf('Agent %d: Agent %d has score higher for request (%d,%d)\n', curr_k, i, d, e);
                    if k_winner(d,e) == curr_k
                        [k_bundle, k_rel_reqs] = k_bundle.release([d,e], sij);
                        for n = 1:size(k_rel_reqs, 1)
                            k_score(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
                            k_winner(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
                            k_time(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
                        end
                    end
                    k_score(d, e) = i_score(d, e);
                    k_winner(d, e) = i_winner(d, e);
                    k_time(d, e) = i_time(d, e);
                    calc_k_reqs;
                end
            end
            if (k_winner(d, e) == i)
                k_score(d, e) = i_score(d, e);
                k_winner(d, e) = i_winner(d, e);
                k_time(d, e) = i_time(d, e);
            end
        end
    end
    
    for n = 1:size(k_bundle.bids.req, 1)
        req = k_bundle.bids.req(n,:);
        k_time(req(1), req(2)) = k_bundle.bids.time(n,2);
    end
end