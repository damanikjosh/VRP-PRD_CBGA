k_path = path{curr_k};
% k_timestamp = timestamp{curr_k};
k_bundle = bundle{curr_k};

k_score = score(:,:,curr_k);
k_winner = winner(:,:,curr_k);
k_time = time(:,:,curr_k);

% [k_last_dist, ~] = calc_dist([agent(curr_k).nodes(1) k_path agent(curr_k).nodes(2)], sij);
[~, k_last_dist, ~] = append_path(agent(curr_k), k_path, [], 0, sij, 0);
% if isempty(k_path)
%     k_last_dist = 0;
% else
%     k_last_dist = k_path.dist(end) + sij(k_path.node(end), agent(curr_k).nodes(2));
% end

for phase1_iter = 1:20
    calc_k_reqs;

    k_next_bid = struct();
    k_next_bid.req      = zeros(2,1);
    k_next_bid.ij       = zeros(2,1);
    k_next_bid.score    = 0;
    k_next_bid.score_w  = 0;
    k_next_bid.add      = zeros(2,1);
    k_next_bid.time     = zeros(2,1);
    k_next_bid.dist     = 0;
    
    k_next_path         = cell(0,1);
    k_next_time         = cell(0,1);

    k_next_add_nodes = zeros(0,2);
    k_next_add_dist = zeros(0,1);
    
    m = 1;
    for d = 1:num_delivs
        for e = 1:num_edges
            if ~isempty(k_bundle) && ismember([d e], [k_bundle.req]', 'rows')
                continue
            end
            
            m_last_dist = k_last_dist;
            m_nodes = edges(e, 1:2);
            
            k_next_bid(m).req = [d e]';
            
%             if k_tr(d,e) > 0
%                 fprintf('Release time of (%d,%d) is %.4f\n', d, e, k_tr(d,e));
%             end
            [m_min_bid, k_next_path{m}] ...
                = generate_path_greedy(agent(curr_k), k_path, m_nodes, sij, k_tr(d, e));
            
            if isempty(k_next_path{m})
                k_next_bid(m) = [];
                continue
            end
            
            k_next_bid(m).dist = m_min_bid.dist;
            k_next_bid(m).ij = m_min_bid.ij;
            k_next_bid(m).add = m_min_bid.add;
            
            sk = k_next_bid(m).dist + 2*RELAY_MULT*sij(m_nodes(1), deliv(d).nodes(1)) ...
                                    + 2*RELAY_MULT*sij(m_nodes(2), deliv(d).nodes(2));
            
            
            min_yfd = min(k_score(d,k_score(d,:)>0));
            cde = sk - k_last_dist;
            if ~isempty(k_bundle)
                cde = max([k_bundle(end).score_w cde]);
            end
            hde = isempty(min_yfd) || (cde < min_yfd) || ...
                    ((k_reqs(d,e) == 1) && ((k_score(d,e) == 0) ...
                     || (cde < k_score(d,e))));
            
            if hde == false
                k_next_bid(m) = [];
                continue
            end
            
            k_next_bid(m).score_w = cde;
            k_next_bid(m).score = (sk - k_last_dist);
            
            m = m + 1;
        end
    end
    
    [~, k_max_m] = min([k_next_bid.score]);
    k_max_bid = k_next_bid(k_max_m);
    
    if (m == 1) || (k_max_bid.score > 1e9)
        break
    end
    
    k_max_d = k_max_bid.req(1);
    k_max_e = k_max_bid.req(2);
    
    if (k_reqs(k_max_d, k_max_e) == 0) && ...
            (isempty(min(k_score(k_max_d,k_score(k_max_d,:)>0))) || ...
            (k_max_bid.score_w < min(k_score(k_max_d,k_score(k_max_d,:)>0))))
        for f = 1:num_edges
            if k_winner(k_max_d,f) > 0
                if k_winner(k_max_d,f) == curr_k
                    k_rel_d = k_max_d;
                    k_rel_e = f;
                    release_task;
                end
                k_score(k_max_d, f) = 0;
                k_winner(k_max_d, f) = 0;
            end
        end
    end
    
    if isempty(k_bundle)
        k_bundle = k_max_bid;
    else
        k_bundle(end+1) = k_max_bid;
    end
%     k_bundle = [k_bundle; k_next_bundle(k_max_m,:)];
    k_path = k_next_path{k_max_m};
%     k_timestamp = k_next_time{k_max_m};
    
    k_bundle = extract_time(k_bundle, k_path);
    
    k_score(k_max_d, k_max_e) = k_bundle(end).score_w;
    k_winner(k_max_d, k_max_e) = curr_k;
    k_time(k_max_d, k_max_e) = k_bundle(end).time(2);
    
    
    k_last_dist = k_max_bid.dist;
    fprintf('Agent %d, Iteration %d: [%d %d] %.4f %.4f Path: \n', ...
        curr_k, phase1_iter, k_max_d, k_max_e, full(k_max_bid.score_w), ...
        full(k_max_bid.score));
    disp(k_path.node);
    disp('');
end