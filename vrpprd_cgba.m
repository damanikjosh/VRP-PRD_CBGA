clear all, clc, close all;

rng_num = 1;
rng(1);

T_SAT_MAX = 5;
S_MAX = 20;
Q_MAX = 20;

generate_graph_random;
generate_edges;

bundle = cell(num_agents, 1);
path = cell(num_agents, 1);
time = cell(num_agents, 1); %TODO timestamp
cost = cell(num_agents, 1);
add_nodes = cell(num_agents, 1);
add_dist = cell(num_agents, 1);

for k = 1:num_agents
    bundle{k} = zeros(0,2);
    path{k} = [];
    cost{k} = [];
    add_nodes{k} = [];
    add_dist{k} = [];
end

score = zeros(num_delivs, num_edges, num_agents);
winner = zeros(num_delivs, num_edges, num_agents);
timestamp = zeros(num_delivs, num_edges, num_agents);

t_start = tic;
t_sat = 0;

for iter = 1:20
    last_score = score;
    for k = 1:num_agents
        curr_k = k;
        
        phase_1;
        bundle{k} = k_bundle;
        path{k} = k_path;
%         time{k} = k_time; %TODO timestamp
        score(:,:,k) = k_score;
        winner(:,:,k) = k_winner;
        cost{k} = k_cost;
        add_nodes{k} = k_add_nodes;
        add_dist{k} = k_add_dist;
        
        phase_2;
        bundle{k} = k_bundle;
        path{k} = k_path;
%         time{k} = k_time; %TODO timestamp
        score(:,:,k) = k_score;
        winner(:,:,k) = k_winner;
        cost{k} = k_cost;
        add_nodes{k} = k_add_nodes;
        add_dist{k} = k_add_dist;
        
        fprintf('Agent %d\n', k);
        disp(k_path);
        disp([k_bundle k_cost']);
    end
    
    if isequal(score, last_score)
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
    highlight(p, [agent(k).nodes(1) path{k} agent(k).nodes(2)], ...
                 'EdgeColor', agent_color(k,:), ...
                 'LineWidth', 2);
end
title(sprintf('Solution (%.2fs)', t_end));

%%
fprintf('=========================================================\n');
fprintf('AGENT PATH\n')
fprintf('=========================================================\n');
for k = 1:num_agents
    fprintf('A%d\t:\t', k);
    for n = 1:length(path{k})
        fprintf('%d > ', path{k}(n));
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
