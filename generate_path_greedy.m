%% Requires m_last_dist
function [max_bid, max_path] = ...
    generate_path_greedy(agent, deliv, bundle, path, app_nodes, sij, tr)

max_path = [];


i = [];
j = [];
for ii = find(path.node == app_nodes(1))
    if path.time(ii) > tr %TODO: Check if enough
        i = ii;
        break
    end
end
j = find(path.node == app_nodes(2), 1, 'last' ); % Max

if isempty(i)
    i = 0;
end
if isempty(j)
    j = 0;
end

app_dist = sij(app_nodes(1), app_nodes(2));
total_dist = sij(deliv.nodes(1), app_nodes(1)) + app_dist + sij(app_nodes(2) + deliv.noes(2));
total_reward = app_dist / total_dist;

max_bid.reward = 0;
max_bid.total_reward = total_reward;

if (i > 0) && (j > 0) && i < j
    next_path = path;
    next_path.tr(i) = max([tr next_path.tr(i)]);
    [next_path, next_dist, ~] = append_path(agent, next_path, [], i, sij);
    next_reward = total_reward * 0.99^(next_path(j).time);
%     next_dist = path(end).dist + full(sij(path(end).node + agent.nodes(2)));
    if (next_reward > max_bid.reward) && (~dist_const || next_dist <= agent.smax)
        max_path = next_path;
        max_bid.add = [0 0];
        max_bid.ij = [i j];
        max_bid.dist = next_dist;
        max_bid.reward = next_reward;
    end
elseif (i > 0) || (j > 0)
    if (i > 0)
        for jj = i:length(path.node)
            next_path = path;
            next_path.tr(i) = max([tr next_path.tr(i)]);
            [next_path, next_dist, ~] = append_path(agent, path, app_nodes(2), jj, sij, 0);
            next_reward = total_reward * 0.99^(next_path(jj+1).time);
%             [next_dist, next_time] = calc_dist([agent.nodes(1) next_path agent.nodes(2)], sij, n_next_tr);
            if (next_reward > max_bid.reward) && (~dist_const || next_dist <= agent.smax)
                max_path = next_path;
                max_bid.dist = next_dist;
                max_bid.add = [0 jj+1];
                max_bid.ij = [i, jj+1];
                max_bid.reward = next_reward;
            end
        end
    end
    if (j > 0)
        for ii = 0:j-1
            [next_path, next_dist, ~] = append_path(agent, path, app_nodes(1), ii, sij, tr);
            next_reward = total_reward * 0.99^(next_path(j+1).time);
%             next_path = [path(1:ii) app_nodes(1) path(ii+1:end)];
%             n_next_tr = zeros(1,length(next_path)+2);
%             n_next_tr(ii+2) = tr;
%             [next_dist, next_time] = calc_dist([agent.nodes(1) next_path agent.nodes(2)], sij, n_next_tr);
            if (next_reward > max_bid.reward) && (~dist_const || next_dist <= agent.smax)
                max_path = next_path;
                max_bid.dist = next_dist;
                max_bid.add = [ii+1 0];
                max_bid.ij = [ii+1, j+1];
                max_bid.reward = next_reward;
            end
        end
    end
else
    for ii = 0:length(path.node)
        for jj = ii:length(path.node)
%             next_path = [path(1:ii) app_nodes(1) ...
%                            path(ii+1:jj) app_nodes(2) ...
%                            path(jj+1:end)];
            [next_path, ~, ~] = append_path(agent, path, app_nodes(2), jj, sij, 0);
            [next_path, next_dist, ~] = append_path(agent, next_path, app_nodes(1), ii, sij, tr);
            next_reward = total_reward * 0.99^(next_path(jj+2).time);
%             n_next_tr = zeros(1,length(next_path)+2);
%             n_next_tr(ii+2) = tr;
%             [next_dist, next_time] = calc_dist([agent.nodes(1) next_path agent.nodes(2)], sij, n_next_tr);
            if (next_reward > max_bid.reward) && (~dist_const || next_dist <= agent.smax)
                max_path = next_path;
                max_bid.dist = next_dist;
                max_bid.add = [ii+1 jj+2];
                max_bid.ij = [ii+1 jj+2];
                max_bid.reward = next_reward;
            end
        end
    end
end

end