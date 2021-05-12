%% Requires m_last_dist
function [m_min_path, ...
          m_min_add_nodes, ...
          m_min_add_dist, ...
          m_min_cost, ...
          m_min_time] = generate_path_greedy(agent, deliv, m_last_dist, ...
                                             m_last_path, m_nodes, sij)

n = 0;
m_next_path = cell(0,1);
m_next_time = cell(0,1);
m_next_dist = zeros(0,1);
m_next_add_nodes = zeros(0,2);

i = find(m_last_path == m_nodes(1), 1 );         % Min
j = find(m_last_path == m_nodes(2), 1, 'last' ); % Max

if isempty(i)
    i = 0;
end
if isempty(j)
    j = 0;
end

if (i > 0) && (j > 0) && i < j
    n = n + 1;
    m_next_path{n} = m_last_path;
	m_next_add_nodes(n,:) = [0 0];
    [m_next_dist(n), path_time] = calc_dist([agent.nodes(1) m_next_path{n} ...
                                agent.nodes(2)], sij);
    m_next_time{n} = path_time(2:end-1);
elseif (i > 0) || (j > 0)
    if (i > 0)
        for jj = i:length(m_last_path)
            n = n + 1;
            m_next_path{n} = [m_last_path(1:jj) m_nodes(2) ...
                              m_last_path(jj+1:end)];
            m_next_add_nodes(n,:) = [0 jj+1];
            [m_next_dist(n), path_time] = calc_dist([agent.nodes(1) m_next_path{n} ...
                                        agent.nodes(2)], sij);
            m_next_time{n} = path_time(2:end-1);
        end
        for jj = 0:i-1
            for ii = 0:jj-1
                n = n + 1;
                m_next_path{n} = [m_last_path(1:ii) m_nodes(1) ...
                                  m_last_path(ii+1:jj) m_nodes(2) ...
                                  m_last_path(jj+1:end)];
                m_next_add_nodes(n,:) = [ii+1 jj+2];
                [m_next_dist(n), path_time] = calc_dist([agent.nodes(1) m_next_path{n}...
                                            agent.nodes(2)], sij);
                m_next_time{n} = path_time(2:end-1);
            end
        end
    end
    if (j > 0)
        for ii = 0:j-1
            n = n + 1;
            m_next_path{n} = [m_last_path(1:ii) m_nodes(1) ...
                              m_last_path(ii+1:end)];
            m_next_add_nodes(n,:) = [ii+1 0];
            [m_next_dist(n), path_time] = calc_dist([agent.nodes(1) m_next_path{n} ...
                                        agent.nodes(2)], sij);
            m_next_time{n} = path_time(2:end-1);
        end
        for ii = j:length(m_last_path)
            for jj = ii:length(m_last_path)
                n = n + 1;
                m_next_path{n} = [m_last_path(1:ii) m_nodes(1) ...
                                  m_last_path(ii+1:jj) m_nodes(2) ...
                                  m_last_path(jj+1:end)];
                m_next_add_nodes(n,:) = [ii+1 jj+2];
                [m_next_dist(n), path_time] = calc_dist([agent.nodes(1) m_next_path{n}...
                                            agent.nodes(2)], sij);
                m_next_time{n} = path_time(2:end-1);
            end
        end
    end
elseif (i == 0) && (j == 0)
    for ii = 0:length(m_last_path)
        for jj = ii:length(m_last_path)
            n = n + 1;
            m_next_path{n} = [m_last_path(1:ii) m_nodes(1) ...
                              m_last_path(ii+1:jj) m_nodes(2) ...
                              m_last_path(jj+1:end)];
            m_next_add_nodes(n,:) = [ii+1 jj+2];
            [m_next_dist(n), path_time] = calc_dist([agent.nodes(1) m_next_path{n} ...
                                        agent.nodes(2)], sij);
            m_next_time{n} = path_time(2:end-1);
        end
    end
end

m_next_cost = m_next_dist + 1*calc_dist([deliv.nodes(1) m_nodes(1) ...
                                         deliv.nodes(1)], sij) ...
                          + 1*calc_dist([m_nodes(2) deliv.nodes(2) ...
                                         m_nodes(2)], sij);
[m_min_cost, m_min_n] = min(m_next_cost);

m_min_path = m_next_path{m_min_n};
m_min_time = m_next_time{m_min_n};
m_min_add_nodes = m_next_add_nodes(m_min_n,:);
m_min_add_dist = m_next_dist(m_min_n) - m_last_dist;

end