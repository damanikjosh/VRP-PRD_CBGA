classdef Bundle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        start_node
        end_node
        smax
        bids
        path
        score
    end
    
    properties (Constant)
        LAMBDA = 0.9
    end
    
    methods
        function obj = Bundle(agent, sij)
            obj.start_node = agent.nodes(1);
            obj.end_node = agent.nodes(2);
            obj.smax = agent.smax;
            
            obj.bids.req       = zeros(0,2);
            obj.bids.ij        = zeros(0,2);
            obj.bids.add       = zeros(0,2);
            obj.bids.reward    = zeros(0,1);
            obj.bids.time      = zeros(0,2);
            obj.bids.dist      = zeros(0,1);
            obj.bids.marg      = zeros(0,1);
            obj.bids.margw     = zeros(0,1);
            
            add_dist = full(sij(agent.nodes(1), agent.nodes(2)));
            
            obj.path.node     = agent.nodes;
            obj.path.dist     = [0; add_dist];
            obj.path.time     = [0; add_dist];
            obj.path.trel     = zeros(2,1);
            
            obj.score         = 0;
        end
        
        function obj = append(obj, req, app_nodes, trel, reward, sij)
            assert(isequal(size(trel), [1 1]), 'trel is not integer');
            next_bids.req    = [obj.bids.req; req];
            next_bids.ij     = [obj.bids.ij; 0, 0];
            next_bids.add    = [obj.bids.add; 0, 0];
            next_bids.reward = [obj.bids.reward; reward];
            next_bids.time   = [obj.bids.time; 0 0];
            next_bids.dist   = [obj.bids.dist; 0];
            next_bids.marg   = [obj.bids.marg; 0];
            next_bids.margw  = [obj.bids.margw; 0];
            
            i = [];
            j = [];
%             for ii = find(obj.path.node == app_nodes(1))
%                 if obj.path.time(ii) >= trel %TODO: Check if enough
%                     i = ii;
%                     break
%                 end
%             end
            i = find(obj.path.node == app_nodes(1), 1); % Max
            j = find(obj.path.node == app_nodes(2), 1, 'last'); % Max
            if isempty(i)
                i = 0;
            end
            if isempty(j)
                j = 0;
            end
            
            
            max_marg = 0;
            max_bid = obj.bids;
            max_path = obj.path;
            max_score = obj.score;
            
            if (i > 0) && (j > 0) && i < j
%                 disp('Case 1');
                next_path         = obj.path;
                next_path.trel(i) = max([trel, next_path.trel(i)]);
                next_path         = obj.calc_path(next_path, sij, i);
                
                next_bids.ij(end, :) = [i j];
                next_bids = obj.calc_bids(next_bids, next_path);
                score = sum(next_bids.reward .* (obj.LAMBDA .^ next_bids.time(:,2)));
                next_bids.marg(end) = score - obj.score;
                next_bids.margw(end) = min([next_bids.marg(end); obj.bids.margw]);

                if next_bids.marg(end) > max_marg
                    max_score = score;
                    max_marg  = next_bids.marg(end);
                    max_bid = next_bids;
                    max_path = next_path;
                end
            elseif (i > 0) || (j > 0)
                if (i > 0)
%                     disp('Case 2');
                    for jj = i:length(obj.path.node)-1
                        next_path         = obj.path;
                        next_path.node    = [next_path.node(1:jj); app_nodes(2); next_path.node(jj+1:end)];
                        next_path.trel    = [next_path.trel(1:jj); 0           ; next_path.trel(jj+1:end)];
                        next_path.trel(i) = max([trel, next_path.trel(i)]);
                        next_path         = obj.calc_path(next_path, sij, i);
                        if next_path.dist(end) > obj.smax
                            continue
                        end
                        
                        next_bids.ij(end, :)  = [i jj+1];
                        next_bids.add(end, :) = [0 1];
                        next_bids = obj.calc_bids(next_bids, next_path);
                        score = sum(next_bids.reward .* (obj.LAMBDA .^ next_bids.time(:,2)));
                        next_bids.marg(end) = score - obj.score;
                        next_bids.margw(end) = min([next_bids.marg(end); obj.bids.margw]);

                        if next_bids.marg(end) > max_marg
                            max_score = score;
                            max_marg  = next_bids.marg(end);
                            max_bid = next_bids;
                            max_path = next_path;
                        end
                    end
                end
                if (j > 0)
%                     disp('Case 3');
                    for ii = 1:j-1
                        next_path      = obj.path;
                        next_path.node = [next_path.node(1:ii); app_nodes(1); next_path.node(ii+1:end)];
                        next_path.trel = [next_path.trel(1:ii); trel        ; next_path.trel(ii+1:end)];
                        next_path      = obj.calc_path(next_path, sij, ii+1);
                        if next_path.dist(end) > obj.smax
                            continue
                        end
                        
                        next_bids.ij(end, :)  = [ii+1 j+1];
                        next_bids.add(end, :) = [1    0];
                        next_bids = obj.calc_bids(next_bids, next_path);
                        score = sum(next_bids.reward .* (obj.LAMBDA .^ next_bids.time(:,2)));
                        next_bids.marg(end) = score - obj.score;
                        next_bids.margw(end) = min([next_bids.marg(end); obj.bids.margw]);

                        if next_bids.marg(end) > max_marg
                            max_score = score;
                            max_marg  = next_bids.marg(end);
                            max_bid = next_bids;
                            max_path = next_path;
                        end
                    end
                end
            else
%                 disp('Case 4');
                for ii = 1:length(obj.path.node)-1
                    for jj = ii:length(obj.path.node)-1
                        next_path      = obj.path;
                        next_path.node = [next_path.node(1:ii); app_nodes(1); next_path.node(ii+1:jj); app_nodes(2); next_path.node(jj+1:end)];
                        next_path.trel = [next_path.trel(1:ii); trel        ; next_path.node(ii+1:jj); 0           ; next_path.trel(jj+1:end)];
                        next_path      = obj.calc_path(next_path, sij, ii+1);
                        if next_path.dist(end) > obj.smax
                            continue
                        end
                        
                        next_bids.ij(end, :)  = [ii+1 jj+2];
                        next_bids.add(end, :) = [1    1];
                        next_bids = obj.calc_bids(next_bids, next_path);
                        score = sum(next_bids.reward .* (obj.LAMBDA .^ next_bids.time(:,2)));
                        next_bids.marg(end) = score - obj.score;
                        next_bids.margw(end) = min([next_bids.marg(end); obj.bids.margw]);

                        if next_bids.marg(end) > max_marg
                            max_score = score;
                            max_marg  = next_bids.marg(end);
                            max_bid = next_bids;
                            max_path = next_path;
                        end
                    end
                end
            end
            
            obj.bids  = max_bid;
            obj.path  = max_path;
            obj.score = max_score;
            
            assert(isequal(size(obj.path.node), size(obj.path.trel)), 'size of path node and trel is not equal');
        end
        
        function [obj, rel_reqs] = release(obj, req, sij)
            
            [~, n] = ismember(req, obj.bids.req, 'rows');
            rel_reqs = [];
            if n
                idx = size(obj.bids.req, 1):-1:n;
                rel_reqs = obj.bids.req(idx, :);
                for nn = idx
%                     disp(nn);
                    fprintf('Releasing Task (%d,%d)\n', obj.bids.req(nn,:));
                    
                    i = obj.bids.ij(nn,1);
                    j = obj.bids.ij(nn,2);
                    
                    if obj.bids.add(nn,2)
                        obj.path.node(j) = [];
                        obj.path.time(j) = [];
                        obj.path.dist(j) = [];
                        obj.path.trel(j) = [];
                    end
                    if obj.bids.add(nn,1)
                        obj.path.node(i) = [];
                        obj.path.time(i) = [];
                        obj.path.dist(i) = [];
                        obj.path.trel(i) = [];
                    end
                    
                    obj.bids.req(nn,:)    = [];
                    obj.bids.ij(nn,:)     = [];
                    obj.bids.add(nn,:)    = [];
                    obj.bids.reward(nn,:) = [];
                    obj.bids.time(nn,:)   = [];
                    obj.bids.dist(nn,:)   = [];
                    obj.bids.marg(nn,:)   = [];
                    obj.bids.margw(nn,:)  = [];
                end
                
                obj.path = obj.calc_path(obj.path, sij);
                obj.bids = obj.calc_bids(obj.bids, obj.path);
                obj.score = sum(obj.bids.reward .* (obj.LAMBDA .^ obj.bids.time(:,2)));
            end
        end
    end
    
    methods(Static)
        function path = calc_path(path, sij, i)
            if nargin < 3
                i = 2;
            end

            for ii = i:length(path.node)
                add_dist = full(sij(path.node(ii-1), path.node(ii)));
                path.dist(ii) = path.dist(ii-1) + add_dist;
                path.time(ii) = max([path.time(ii-1) path.trel(ii-1)]) + add_dist;
            end
            assert(isequal(size(path.node), size(path.trel)), 'size of path node and trel is not equal');
        end
        
        function bids = calc_bids(bids, path)
            for n = size(bids.req, 1):-1:1
                i = bids.ij(n,1);
                j = bids.ij(n,2);
                bids.time(n,:) = path.time([i,j])';
                bids.dist(n) = path.dist(j);
                
                if bids.add(n,2)
                    path.time(j) = [];
                    path.dist(j) = [];
                end
                if bids.add(n,1)
                    path.time(i) = [];
                    path.dist(i) = [];
                end
            end
        end
    end
end

