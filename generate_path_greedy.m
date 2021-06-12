%% Requires m_last_dist
function [min_bid, min_path] = ...
    generate_path_greedy(agent, path, app_nodes, sij, tr, dist_const)

if ~exist('dist_const','var')
    dist_const = true;
end

if isempty(path)
    path.node = [];
    path.time = [];
    path.tr = [];
end

min_path          = [];


min_bid.dist = 1e10;

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

% add_path.node = 0;
% add_path.time = 0;
% add_path.tr = 0;

if (i > 0) && (j > 0) && i < j
    next_path = path;
    next_path.tr(i) = max([tr next_path.tr(i)]);
    [next_path, next_dist, ~] = append_path(agent, next_path, [], i, sij);
%     next_dist = path(end).dist + full(sij(path(end).node + agent.nodes(2)));
    if (next_dist < min_bid.dist) && (~dist_const || next_dist <= agent.smax)
        min_path = next_path;
        min_bid.add = [0 0];
        min_bid.ij = [i j];
        min_bid.dist = next_dist;
    end
elseif (i > 0) || (j > 0)
    if (i > 0)
        for jj = i:length(path.node)
            next_path = path;
            next_path.tr(i) = max([tr next_path.tr(i)]);
            [next_path, next_dist, ~] = append_path(agent, path, app_nodes(2), jj, sij, 0);
%             [next_dist, next_time] = calc_dist([agent.nodes(1) next_path agent.nodes(2)], sij, n_next_tr);
            if (next_dist < min_bid.dist) && (~dist_const || next_dist <= agent.smax)
                min_path = next_path;
                min_bid.dist = next_dist;
                min_bid.add = [0 jj+1];
                min_bid.ij = [i, jj+1];
            end
        end
    end
    if (j > 0)
        for ii = 0:j-1
            [next_path, next_dist, ~] = append_path(agent, path, app_nodes(1), ii, sij, tr);
%             next_path = [path(1:ii) app_nodes(1) path(ii+1:end)];
%             n_next_tr = zeros(1,length(next_path)+2);
%             n_next_tr(ii+2) = tr;
%             [next_dist, next_time] = calc_dist([agent.nodes(1) next_path agent.nodes(2)], sij, n_next_tr);
            if (next_dist < min_bid.dist) && (~dist_const || next_dist <= agent.smax)
                min_path = next_path;
                min_bid.dist = next_dist;
                min_bid.add = [ii+1 0];
                min_bid.ij = [ii+1, j+1];
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
%             n_next_tr = zeros(1,length(next_path)+2);
%             n_next_tr(ii+2) = tr;
%             [next_dist, next_time] = calc_dist([agent.nodes(1) next_path agent.nodes(2)], sij, n_next_tr);
            if (next_dist < min_bid.dist) && (~dist_const || next_dist <= agent.smax)
                min_path = next_path;
                min_bid.dist = next_dist;
                min_bid.add = [ii+1 jj+2];
                min_bid.ij = [ii+1 jj+2];
            end
        end
    end
end

end