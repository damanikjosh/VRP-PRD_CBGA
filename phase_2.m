k_path = path{curr_k};
k_bundle = bundle{curr_k};
k_cost = cost{curr_k};
k_score = score(:,:,curr_k);
k_winner = winner(:,:,curr_k);
k_add_nodes = add_nodes{curr_k};
k_add_dist = add_dist{curr_k};

calc_k_reqs;

for i = 1:num_agents
    if i == curr_k
        continue
    end
    i_score = score(:,:,i);
    i_winner = winner(:,:,i);
    
    for d = 1:num_delivs
        for e = 1:num_edges
            if i_score(d,e) == 0 && k_score(d,e) == 0
                continue
            end
            if (i_winner(d,e) > 0 && i_winner(d,e) ~= curr_k)
                if (k_reqs(d, e) == 0) && ... #TODO temporal
                      (isempty(min(k_score(d,k_score(d,:) > 0))) || ...
                        (i_score(d,e) < min(k_score(d,k_score(d,:) > 0))) ||...
                        (i_score(d,e) == min(k_score(d,k_score(d,:) > 0)) && i < curr_k) ...
                      )
                    fprintf('Agent %d: Agent %d has score higher for task %d\n', ...
                        curr_k, i, d);
                    for f = 1:num_edges
                        if k_winner(d,f) > 0
                            if k_winner(d,f) == curr_k
                                k_rel_d = d;
                                k_rel_e = f;
                                release_task;
                            end
                            k_score(d, f) = 0;
                            k_winner(d, f) = 0;
                        end
                    end
                    k_score(d, e) = i_score(d, e);
                    k_winner(d, e) = i_winner(d, e);
                    calc_k_reqs;
                elseif (k_reqs(d, e) == 1) && ... #TODO temporal
                       ((k_score(d, e) == 0) || ...
                         (i_score(d, e) < k_score(d, e)) || ...
                         (i_score(d, e) == k_score(d, e) && i < curr_k) ...
                       )
                    fprintf('Agent %d: Agent %d has score higher for arc (%d,%d)\n', ...
                        curr_k, i, d, e);
                    if k_winner(d,e) == curr_k
                        k_rel_d = d;
                        k_rel_e = e;
                        release_task;
                    end
                    k_score(d, e) = i_score(d, e);
                    k_winner(d, e) = i_winner(d, e);
                    calc_k_reqs;
                end
                
            end
        end
    end
end