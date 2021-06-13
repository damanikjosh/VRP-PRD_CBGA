clear all, clc, close all;

rng_num = 1;
rng(rng_num);

T_SAT_MAX = 1;
S_MAX = 200;
Q_MAX = 20;
RELAY_MULT = 1;

generate_graph_random;
generate_edges;

bundle = cell(num_agents, 1);

for k = 1:num_agents
    bundle{k} = Bundle(agent(k), sij);
end

score = zeros(num_delivs, num_edges, num_agents);
winner = zeros(num_delivs, num_edges, num_agents);
time = zeros(num_delivs, num_edges, num_agents);

t_start = tic;
t_sat = 0;



for iter = 1:20
    last_score = score;
    last_time = time;
    
    for k = 1:num_agents
        curr_k = k;
        
        k_rewards = rewards(:,:,k);
        while true
            phase_1;
            bundle{k} = k_bundle;
            score(:,:,k) = k_score;
            winner(:,:,k) = k_winner;
            time(:,:,k) = k_time;

            phase_3;
            bundle{k} = k_bundle;
            score(:,:,k) = k_score;
            winner(:,:,k) = k_winner;
            time(:,:,k) = k_time;
            
            
            if ~k_temporal_conflict
                break
            end
        end
        
        phase_2;
        bundle{k} = k_bundle;
        score(:,:,k) = k_score;
        winner(:,:,k) = k_winner;
        time(:,:,k) = k_time;
        
%         phase_3;
%         bundle{k} = k_bundle;
%         score(:,:,k) = k_score;
%         winner(:,:,k) = k_winner;
%         time(:,:,k) = k_time;
%         
        
%         bundle{k} = k_bundle;
%         path{k} = k_path;
% %         timestamp{k} = k_timestamp;
%         score(:,:,k) = k_score;
%         winner(:,:,k) = k_winner;
%         time(:,:,k) = k_time;
        fprintf('Agent %d\nBundle:\n', k);
        disp(array2table([k_bundle.bids.req'; k_bundle.bids.marg'; k_bundle.bids.margw'; k_bundle.bids.time(:,1)'; k_bundle.bids.time(:,2)'], 'RowName', {'d', 'e', 'marg', 'margw', 'time1', 'time2'}));
        fprintf('Path:\n');
        disp(array2table([k_bundle.path.node'; k_bundle.path.time'; k_bundle.path.trel'], 'RowName', {'Nodes', 'Time', 'Trel'}));
        fprintf('=========================================================\n');
    end
    
    if isequal(score, last_score) && isequal(time, last_time)
        t_sat = t_sat + 1;
    else
        t_sat = 0;
    end
    
    if t_sat >= T_SAT_MAX
        break
    end
end
t_end = toc(t_start);

%%
figure(2);
for k = 1:num_agents
    highlight(p, bundle{k}.path.node, ...
                 'EdgeColor', agent_color(k,:), ...
                 'LineWidth', 2);
end
title(sprintf('Solution (%.2fs)', t_end));
saveas(gcf, strcat(int2str(rng_num), 'b.png'));

% close all;

%%
fprintf('=========================================================\n');
fprintf('AGENT PATH\n')
fprintf('=========================================================\n');
for k = 1:num_agents
    fprintf('A%d\t:\t', k);
    for n = 1:length(bundle{k}.path.node)
        fprintf('%d > ', bundle{k}.path.node(n));
    end
    fprintf('END\n');
end

fprintf('=========================================================\n');
fprintf('DELIVERY PATH\n')
fprintf('=========================================================\n');
for d = 1:num_delivs
    edge_idxs = find(winner(d,:,1) > 0);
    node_lists = edges(edge_idxs, 1:2);
    
    last_node_idx = find(node_lists(:,1) == deliv(d).nodes(1),1);
    last_node = node_lists(last_node_idx, 2);
    fprintf('D%d\t:\t%d\t', d, deliv(d).nodes(1));
    while true
        if isempty(last_node)
            fprintf('NOT COMPLETE\n');
            break
        end
        
        if last_node == deliv(d).nodes(2)
            fprintf('-A%d->\t%d\n', winner(d,edge_idxs(last_node_idx),1), deliv(d).nodes(2));
            break
        else
            fprintf('-A%d->\t%d\t', winner(d,edge_idxs(last_node_idx),1), last_node);
        end
        last_node_idx = find(node_lists(:,1) == last_node,1);
        last_node = node_lists(last_node_idx, 2);
        
    end
    
end
