% clear, clc, close all;

num_hubs = 4;
num_delivs = 2;
num_agents = 1;

max_reward = 100;

num_nodes = 0;
nodes_pos = [];
nodes_label = {};

%% Hubs
hub(1).pos = [1 5]';
hub(2).pos = [4 5]';
hub(3).pos = [7 5]';
hub(4).pos = [4 1]';
num_hubs = length(hub);
% hub(4).pos = [6 8]';
% hub(5).pos = [4 10]';

for h = 1:num_hubs
    hub(h).nodes = num_nodes + 1;
    num_nodes = num_nodes + 1;
    nodes_pos = [nodes_pos hub(h).pos];
    nodes_label{end+1} = int2str(h);
end

%% Deliveries
deliv(1).nodes = [1 3]';
deliv(2).nodes = [1 4]';
deliv(3).nodes = [3 2]';
num_delivs = length(deliv);
% deliv(4).nodes = [4 3]';

% for d = 1:num_deliv
%     deliv(d).nodes = num_nodes + (1:2)';
%     num_nodes = num_nodes + 2;
%     nodes_pos = [nodes_pos, deliv(d).pos, deliv(d).target];
% end

%% Agents
agent(1).pos = [1 5]';
agent(2).pos = [7 5]';
num_agents = length(agent);
% agent(3).pos = [3 4]';

for k = 1:num_agents
    agent(k).smax = S_MAX;
    agent(k).qmax = Q_MAX;
    
    agent(k).nodes = num_nodes + (1:2)';
    num_nodes = num_nodes + 2;
    nodes_pos = [nodes_pos, agent(k).pos, agent(k).pos];
    nodes_label{end+1} = '';
    nodes_label{end+1} = '';
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



