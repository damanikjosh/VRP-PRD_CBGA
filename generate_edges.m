%% Digraph
[s, t] = find(adj==1);
w = full(sij(adj==1));

G = digraph(s,t,w);
G_hubs = subgraph(G, 1:num_hubs);
edges = G_hubs.Edges{:,:};
num_edges = size(edges,1);
rewards = zeros(num_delivs, num_edges, num_agents);

for e = 1:num_edges
    for d = 1:num_delivs
        %% Old Scoring Scheme
%         rewards(e,d) = sum(abs(nodes_pos(:,edges(e,1))-hub(deliv(d).nodes(2)).pos)) - sum(abs(nodes_pos(:,edges(e,2))-hub(deliv(d).nodes(2)).pos));
%         rewards(e,d) = rewards(e,d) / sum(abs(hub(deliv(d).nodes(2)).pos - hub(deliv(d).nodes(1)).pos));
%         rewards(e,d) = rewards(e,d) * max_reward;
%         rewards(e,d) = max(0, rewards(e,d));
%         rewards(e,d) = min(max_reward, rewards(e,d));
        %% New Scoring Scheme
        if edges(e,1) ~= deliv(d).nodes(2) && edges(e,2) ~= deliv(d).nodes(1)
            rewards(d,e,1) = sij(deliv(d).nodes(1),deliv(d).nodes(2)) * max_reward * sij(edges(e,1), edges(e,2)) / ...
                               (sij(deliv(d).nodes(1), edges(e,1)) + ...
                                sij(edges(e,1), edges(e,2)) + ...
                                sij(edges(e,2), deliv(d).nodes(2)));
        else
            rewards(d,e,1) = 0;
        end
%         if all(deliv(d).nodes == edges(e,1:2)')
%             rewards(e,d) = max_reward;
%         elseif deliv(d).nodes(1) == edges(e,1)
%             rewards(e,d) = max_reward * edges(e,3) / ...
%                 (edges(e,3) + sij(edges(e,2), deliv(d).nodes(2)));
%         elseif deliv(d).nodes(2) == edges(e,2)
%             rewards(e,d) = max_reward * edges(e,3) / ...
%                 (edges(e,3) + sij(deliv(d).nodes(1), edges(e,1)));
%         end
    end
end

for k = 1:num_agents
    rewards(:,:,k) = rewards(:,:,1);
end

%% Temporal constant
temps = zeros(num_edges, num_edges, num_delivs);
for d = 1:num_delivs
    for e = 1:num_edges
        if edges(e, 2) == deliv(d).nodes(1)
            continue
        end
        for f = 1:num_edges
            if edges(f, 1) == deliv(d).nodes(2)
                continue
            end
            if edges(e, 2) == edges(f, 1)
                temps(e, f, d) = 1;
            end
        end
    end
end

%% Visualization

figure(1);

pd = plot(G_hubs, 'XData', nodes_pos(1,1:num_hubs), ...
                  'YData', nodes_pos(2,1:num_hubs), ...
                  'ArrowSize', 10, ...
                  'EdgeColor', [0.9 0.9 0.9], ...
                  'EdgeLabel', repmat({''}, size(G_hubs.Edges,1), 1));

for d = 1:num_delivs
    highlight(pd, deliv(d).nodes', 'EdgeColor', 0.75*rand(1,3), ...
                                   'LineWidth',2);
    [~, edge_idx] = ismember(deliv(d).nodes',G_hubs.Edges{:,:}(:,1:2),'rows');
    if pd.EdgeLabel{edge_idx} == ""
        pd.EdgeLabel{edge_idx} = sprintf('D%d', d);
    else
        pd.EdgeLabel{edge_idx} = sprintf('%s,%d', pd.EdgeLabel{edge_idx}, d);
    end
    
end
grid on;
axis equal;
axis([-0.5 10.5 -0.5 10.5]);
title('Delivery problems');
saveas(gcf, strcat(int2str(rng_num), 'a.png'));

figure(2);

p = plot(G, 'XData',nodes_pos(1,:), ...
            'YData',nodes_pos(2,:), ...
            'ArrowSize', 10, ...
            'EdgeColor', [0.9 0.9 0.9], ...
            'EdgeLabel', repmat({''}, size(G.Edges,1), 1));

agent_color = 0.75*rand(num_agents, 3);
for k = 1:num_agents
    p.NodeLabel{num_hubs+2*k-1} = sprintf('A%d', k);
    p.NodeLabel{num_hubs+2*k} = '';
    highlight(p, num_hubs+2*k-1, 'NodeColor', agent_color(k, :), ...
                                 'Marker', 's', ...
                                 'MarkerSize', 10);
end

grid on;
axis equal;
axis([-0.5 10.5 -0.5 10.5]);
title('Computing ...');
pause(0.1);

%%
function h = rect2(x,y,r,facecolor, edgecolor)
    d = r*2;
    px = x-r;
    py = y-r;
    rectangle('Position', [px py d d], 'FaceColor', facecolor, ...
                                       'EdgeColor', edgecolor, ...
                                       'LineWidth', 1.5);
    h = plot(NaN, NaN, 's', 'LineWidth', 2, 'Color', edgecolor);
    daspect([1,1,1])
end