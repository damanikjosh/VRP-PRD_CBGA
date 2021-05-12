% clear, clc, close all;

num_hubs = 5;
num_delivs = 5;
num_agents = 3;

max_reward = 100;

num_nodes = 0;
nodes_pos = [];
nodes_label = {};

%% Hubs

for h = 1:num_hubs
    while true
        new_hub_pos = randi(10, 2, 1);
        if h == 1 || ~ismember(new_hub_pos', [hub.pos]', 'rows')
            break
        end
    end
    hub(h).pos = new_hub_pos;
    hub(h).nodes = num_nodes + 1;
    num_nodes = num_nodes + 1;
    nodes_pos = [nodes_pos hub(h).pos];
    nodes_label{end+1} = int2str(h);
end

%% Deliveries

for d = 1:num_delivs
    while true
        new_deliv_nodes = randperm(num_hubs, 2)';
        if d == 1 || ~ismember(new_deliv_nodes', [deliv.nodes]', 'rows')
            break
        end
    end
    deliv(d).nodes = new_deliv_nodes;
end

%% Agents

for k = 1:num_agents
    while true
        new_agent_pos = randi(10, 2, 1);
        if h == 1 || ~ismember(new_agent_pos', [hub.pos]', 'rows')
            break
        end
    end
    agent(k).pos = new_agent_pos;
    agent(k).smax = S_MAX;
    agent(k).qmax = Q_MAX;
    
    agent(k).nodes = num_nodes + (1:2)';
    num_nodes = num_nodes + 2;
    nodes_pos = [nodes_pos, agent(k).pos, agent(k).pos];
    nodes_label{end+1} = sprintf('A%d+', k);
    nodes_label{end+1} = sprintf('A%d-', k);
end


%% Adjacency matrix definition

adj = sparse(num_nodes, num_nodes);

for i = 1:num_hubs
    for j = 1:num_hubs
        if i == j
            continue
        end
        adj(i, j) = 1;
    end
end

for k = 1:num_agents
    adj(agent(k).nodes(1), 1:num_hubs) = 1;
    adj(1:num_hubs, agent(k).nodes(2)) = 1;
    adj(agent(k).nodes(1), agent(k).nodes(2)) = 1;
end

sij = sparse(num_nodes, num_nodes);
rewards = zeros(num_nodes, num_nodes, num_delivs);
for i = 1:num_nodes
    for j = 1:num_nodes
        if ~adj(i,j)
            continue
        end
        sij(i,j) = norm(nodes_pos(:,i)-nodes_pos(:,j));
    end
end



