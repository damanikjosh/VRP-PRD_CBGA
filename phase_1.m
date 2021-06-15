k_bundle = bundle{curr_k};

k_score = score(:,:,curr_k);
k_winner = winner(:,:,curr_k);
k_time = time(:,:,curr_k);

for phase1_iter = 1:20
    calc_k_reqs;
    
    k_max_marg = 0;
    k_max_margw = 0;
    k_max_req = [0 0];
    k_max_bundle = k_bundle;
    for d = 1:num_delivs
        for e = 1:num_edges
            if ismember([d e], k_bundle.bids.req, 'rows')
                continue
            end
            if rewards(d, e, curr_k) == 0
                continue
            end
            
%             k_next_bundle = k_bundle.append([d e], edges(e, 1:2), k_trel(d,e), k_rewards(d, e), sij);
%             if k_trel(d,e) > 0
%                 fprintf('Agent %d: Release time for request (%d,%d) is %.4f\n', curr_k, d, e, k_trel(d,e));
%             end
            k_next_bundle = k_bundle.append([d e], edges(e, 1:2), trel(d,e, curr_k), rewards(d, e, curr_k), sij);
            if isequal(k_bundle, k_next_bundle)
                continue
            end
            
            k_next_marg = k_next_bundle.bids.marg(end);
            k_next_margw = k_next_bundle.bids.margw(end);
            
            k_feas1 = k_next_margw > max(k_score(d,:));
            k_feas2 = k_reqs(d,e) && (k_next_margw > k_score(d,e));
            k_feas = k_feas1 || k_feas2;
            
            if k_reqs(d,e) && k_winner(d,e) == 0
                k_next_marg = k_next_marg * 1.5;
                if length(k_next_bundle.bids.margw) > 1
                    k_next_margw = min([k_next_marg, k_next_bundle.bids.margw(end-1)]);
                else
                    k_next_margw = k_next_marg;
                end
            end
            
            if k_feas && (k_next_marg > k_max_marg)
                k_max_marg = k_next_marg;
                k_max_margw = k_next_margw;
                k_max_req = [d e];
                k_max_bundle = k_next_bundle;
            end
        end
    end
    
    if k_max_marg <= 0
        break
    end
    
    fprintf('Agent %d: Added request (%d,%d) to bundle with margw %.4f\n', curr_k, k_max_req, k_max_margw);
    
    
    k_bundle = k_max_bundle;
    k_score(k_max_req(1), k_max_req(2)) = k_max_margw;
    k_winner(k_max_req(1), k_max_req(2)) = curr_k;
    k_time(k_max_req(1), k_max_req(2)) = k_max_bundle.bids.time(end, 2);
%     calc_k_reqs;
    
    if k_reqs(k_max_req(1), k_max_req(2)) == 0 && k_max_margw > max(k_score(k_max_req(1),:))
        fprintf('Agent %d: Resetting all requests from task %d\n', curr_k, k_max_req(1));
        for f = 1:num_edges
%             if k_reqs(k_max_req(1), f) == 0 && k_score(k_max_req(1), f) > 0
%                 if k_winner(k_max_req(1), f) == curr_k
%                     [k_bundle, k_rel_reqs] = k_bundle.release(k_max_req, sij, true);
%                     for n = 1:size(k_rel_reqs, 1)
%                         k_score(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
%                         k_winner(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
%                         k_time(k_rel_reqs(n,1), k_rel_reqs(n,2)) = 0;
%                     end
%                 end
                k_score(k_max_req(1), f) = 0;
                k_winner(k_max_req(1), f) = 0;
                k_winner(k_max_req(1), f) = 0;
%             end
        end
    end
    
    
    
    
%     [~, k_max_m] = min([k_next_bid.score]);
%     k_max_bid = k_next_bid(k_max_m);
%     
%     if (m == 1) || (k_max_bid.score > 1e9)
%         break
%     end
%     
%     k_max_d = k_max_bid.req(1);
%     k_max_e = k_max_bid.req(2);
%     
%     if (k_reqs(k_max_d, k_max_e) == 0) && ...
%             (isempty(min(k_score(k_max_d,k_score(k_max_d,:)>0))) || ...
%             (k_max_bid.score_w < min(k_score(k_max_d,k_score(k_max_d,:)>0))))
%         for f = 1:num_edges
%             if k_winner(k_max_d,f) > 0
%                 if k_winner(k_max_d,f) == curr_k
%                     k_rel_d = k_max_d;
%                     k_rel_e = f;
%                     release_task;
%                 end
%                 k_score(k_max_d, f) = 0;
%                 k_winner(k_max_d, f) = 0;
%             end
%         end
%     end
%     
%     if isempty(k_bundle)
%         k_bundle = k_max_bid;
%     else
%         k_bundle(end+1) = k_max_bid;
%     end
% %     k_bundle = [k_bundle; k_next_bundle(k_max_m,:)];
%     k_path = k_next_path{k_max_m};
% %     k_timestamp = k_next_time{k_max_m};
%     
%     k_bundle = extract_time(k_bundle, k_path);
%     
%     k_score(k_max_d, k_max_e) = k_bundle(end).score_w;
%     k_winner(k_max_d, k_max_e) = curr_k;
%     k_time(k_max_d, k_max_e) = k_bundle(end).time(2);
%     
%     
%     k_last_dist = k_max_bid.dist;
%     fprintf('Agent %d, Iteration %d: [%d %d] %.4f %.4f Path: \n', ...
%         curr_k, phase1_iter, k_max_d, k_max_e, full(k_max_bid.score_w), ...
%         full(k_max_bid.score));
%     disp(k_path.node);
%     disp('');
end