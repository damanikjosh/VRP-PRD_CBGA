%% Requires m_last_dist
function [m_min_path, m_min_add_nodes, m_min_dist, m_min_time] = ...
    generate_path_greedy(agent, m_last_path, m_nodes, sij)

n = 0;
% m_min_score = 1e10;
m_min_path = [];
m_min_add_nodes = [];
m_min_dist = 1e10;
m_min_time = [];

% [m_last_dist, m_last_time] = calc_dist([agent.nodes(1) m_last_path agent.nodes(2)], sij);

i = find(m_last_path == m_nodes(1), 1 );         % Min
j = find(m_last_path == m_nodes(2), 1, 'last' ); % Max

if isempty(i)
    i = 0;
end
if isempty(j)
    j = 0;
end

if (i > 0) && (j > 0) && i < j
    n_next_path = m_last_path;
    n_next_dist = calc_dist([agent.nodes(1) n_next_path agent.nodes(2)], sij);
    if (n_next_dist <= agent.smax) && (n_next_dist < m_min_dist)
        m_min_path = n_next_path;
        m_min_dist = n_next_dist;
        m_min_add_nodes = [0 0];
    end
elseif (i > 0) || (j > 0)
    if (i > 0)
        for jj = i:length(m_last_path)
            n_next_path = [m_last_path(1:jj) m_nodes(2) m_last_path(jj+1:end)];
            [n_next_dist, n_next_time] = calc_dist([agent.nodes(1) n_next_path agent.nodes(2)], sij);
            if (n_next_dist <= agent.smax) && (n_next_dist < m_min_dist)
                m_min_path = n_next_path;
                m_min_dist = n_next_dist;
                m_min_add_nodes = [0 jj+1];
                m_min_time = n_next_time;
            end
        end
        for jj = 0:i-2
            for ii = 0:jj-1
                n_next_path = [m_last_path(1:ii) m_nodes(1) ...
                               m_last_path(ii+1:jj) m_nodes(2) ...
                               m_last_path(jj+1:end)];
                [n_next_dist, n_next_time] = calc_dist([agent.nodes(1) n_next_path agent.nodes(2)], sij);
                if (n_next_dist <= agent.smax) && (n_next_dist < m_min_dist)
                    m_min_path = n_next_path;
                    m_min_dist = n_next_dist;
                    m_min_add_nodes = [ii+1 jj+2];
                    m_min_time = n_next_time;
                end
            end
        end
    end
    if (j > 0)
        for ii = 0:j-1
            n_next_path = [m_last_path(1:ii) m_nodes(1) m_last_path(ii+1:end)];
            [n_next_dist, n_next_time] = calc_dist([agent.nodes(1) n_next_path agent.nodes(2)], sij);
            if (n_next_dist <= agent.smax) && (n_next_dist < m_min_dist)
                m_min_path = n_next_path;
                m_min_dist = n_next_dist;
                m_min_add_nodes = [ii+1 0];
                m_min_time = n_next_time;
            end
        end
        for ii = j+1:length(m_last_path)
            for jj = ii:length(m_last_path)
                n_next_path = [m_last_path(1:ii) m_nodes(1) ...
                               m_last_path(ii+1:jj) m_nodes(2) ...
                               m_last_path(jj+1:end)];
                [n_next_dist, n_next_time] = calc_dist([agent.nodes(1) n_next_path agent.nodes(2)], sij);
                if (n_next_dist <= agent.smax) && (n_next_dist < m_min_dist)
                    m_min_path = n_next_path;
                    m_min_dist = n_next_dist;
                    m_min_add_nodes = [ii+1 jj+2];
                    m_min_time = n_next_time;
                end
            end
        end
    end
else
    for ii = 0:length(m_last_path)
        for jj = ii:length(m_last_path)
            n_next_path = [m_last_path(1:ii) m_nodes(1) ...
                           m_last_path(ii+1:jj) m_nodes(2) ...
                           m_last_path(jj+1:end)];
            [n_next_dist, n_next_time] = calc_dist([agent.nodes(1) n_next_path agent.nodes(2)], sij);
            if (n_next_dist <= agent.smax) && (n_next_dist < m_min_dist)
                m_min_path = n_next_path;
                m_min_dist = n_next_dist;
                m_min_add_nodes = [ii+1 jj+2];
                m_min_time = n_next_time;
            end
        end
    end
end

end