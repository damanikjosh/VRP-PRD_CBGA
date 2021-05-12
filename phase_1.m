k_path = path{curr_k};
k_time = time{curr_k}; %TODO timestamp
k_bundle = bundle{curr_k};
k_cost = cost{curr_k};
k_score = score(:,:,curr_k);
k_winner = winner(:,:,curr_k);
k_add_nodes = add_nodes{curr_k};
k_add_dist = add_dist{curr_k};

k_last_dist = 0;

for phase1_iter = 1:20
    calc_k_reqs;
    
    k_next_bundle = zeros(0,2);
    k_next_path = cell(0,1);
    k_next_time = cell(0,1); %TODO timestamp
    k_next_score = zeros(0,1);
    k_next_score_bar = zeros(0,1);
    k_next_add_nodes = zeros(0,2);
    k_next_add_dist = zeros(0,1);
    
    m = 0;
    for d = 1:num_delivs
        for e = 1:num_edges
            if ismember([d e], k_bundle, 'rows')
                continue
            end
            
            m_last_dist = k_last_dist;
            
            [m_min_path, m_min_add_nodes, m_min_add_dist, m_min_cost, m_min_time] ...
                = generate_path_greedy(agent(curr_k), deliv(d), ...
                                       k_last_dist, k_path, ...
                                       edges(e, 1:2), sij);
            if m_last_dist + m_min_add_dist > agent(k).smax
                continue
            end
            
            m = m + 1;
            
            k_next_bundle(m,:) = [d e];
            k_next_path{m} = m_min_path;
%             k_next_time{m} = m_min_time; #TODO timestamp
            
            k_next_add_nodes(m,:) = m_min_add_nodes;
            k_next_add_dist(m) = m_min_add_dist;
            
            min_yfd = min(k_score(d,k_score(d,:)>0));
            
            cde = max([k_cost (m_min_cost - k_last_dist)]);
            hde = false;
            
            if isempty(min_yfd) || (cde < min_yfd) || ...
                    ((k_reqs(d,e) == 1) && ((k_score(d,e) == 0) ... #TODO temporal
                     || (cde < k_score(d,e))))
                hde = true;
            end
            
            k_next_score_bar(m) = cde;
            k_next_score(m) = (m_min_cost - k_last_dist);
            if hde == 0
                k_next_score_bar(m) = 1e10;
                k_next_score(m) = 1e10;
            end
        end
    end
    
    [k_max_score, k_max_m] = min(k_next_score);
    k_max_score_warped = k_next_score_bar(k_max_m);
    if (m == 0) || (k_next_score(k_max_m) > 1e9)
        break
    end
    
    k_max_d = k_next_bundle(k_max_m,1);
    k_max_e = k_next_bundle(k_max_m,2);
    
    if (k_reqs(k_max_d, k_max_e) == 0) && ... #TODO temporal
            (isempty(min(k_score(k_max_d,k_score(k_max_d,:)>0))) || ...
            (k_max_score_warped < min(k_score(k_max_d,k_score(k_max_d,:)>0))))
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
    
    % Combining tasks
%     for f = 1:num_edges
%         if (k_max_e == f) || (k_reqs(k_max_d,k_max_e) == 0) || ... #TODO temporal
%                 (k_reqs(k_max_d,f) == 0) || (k_winner(k_max_d,f) ~= curr_k)
%             continue
%         end
%         fprintf('Combining %d and %d\n', k_max_e, f);
%         nodes_e = edges(k_max_e,1:2);
%         nodes_f = edges(f,1:2);
% 
%         inter = ismember(nodes_f, nodes_e);
%         if inter(1)
%             combd = [nodes_e(1) nodes_f(2)];
%         else
%             combd = [nodes_f(1) nodes_e(2)];
%         end
%         
%         k_rel_d = k_max_d;
%         k_rel_e = f;
%         release_task;
% 
%         [~, k_max_e] = ismember(combd, edges(:,1:2), 'rows');
%         [m_min_path, m_min_add_nodes, m_min_add_dist, m_min_cost]...
%             = generate_path_greedy(agent(curr_k), deliv(k_max_d), ...
%                                    k_last_dist, k_path, combd, sij);
%         
%         k_next_bundle(k_max_m,:) = [k_max_d, k_max_e];
%         k_next_path{k_max_m} = m_min_path;
%         k_next_add_nodes(k_max_m, :) = m_min_add_nodes;
%         k_next_add_dist(k_max_m) = m_min_add_dist;
%         k_max_score = max([k_cost (m_min_cost - k_last_dist)]);
%     end
    
    k_bundle = [k_bundle; k_next_bundle(k_max_m,:)];
    k_path = k_next_path{k_max_m};
%     k_time = k_next_time{k_max_m}; #TODO timestamp
    k_add_nodes = [k_add_nodes; k_next_add_nodes(k_max_m, :)];
    k_add_dist = [k_add_dist k_next_add_dist(k_max_m)];
    k_cost = [k_cost k_max_score_warped];
    
    
    k_score(k_max_d, k_max_e) = k_max_score_warped;
    k_winner(k_max_d, k_max_e) = curr_k;
    
    k_last_dist = k_last_dist + k_next_add_dist(k_max_m);
    fprintf('Agent %d, Iteration %d: [%d %d] %.4f %.4f\n', ...
        curr_k, phase1_iter, k_max_d, k_max_e, k_max_score_warped, ...
        k_next_score(k_max_m));
%     disp([agent(curr_k).nodes(1) k_path agent(curr_k).nodes(2)]);
    disp('');
end