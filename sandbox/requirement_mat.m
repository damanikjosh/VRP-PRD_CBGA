clear, clc, close all;


clear all, clc, close all;

rng_num = 1;
rng(rng_num);

generate_graph;
generate_edges;

bundle = cell(num_agent, 1);
path = cell(num_agent, 1);

winner = zeros(num_agent, num_deliv, num_agent);
time = zeros(num_agent, num_agent);

tic
for t = 1:1
    for k = 1:1
        curr_k = k;
%         generate_path;
    end
end

edges = [1 4;
         1 2;
         2 3;
         3 4;
         1 3;
         2 4];
path = {[1];
        [2];
        [2 3];
        [2 3 4];
        [5];
        [2 6]};

mat1 = zeros(num_agent, 6);
mat2 = zeros(num_agent, 6, num_deliv);

for k = 1:num_agent
    k_node = agent(k).nodes(1);
    
    for i = 1:6
        score = sij(k_node, 1);
        for n = 1:length(path{i})
            edge = path{i}(n);
            score = score + sij(edges(edge,1), edges(edge, 2));
        end
        mat1(k,i) = score;
        for d = 1:num_deliv
            mat2(k,i,d) = spij(edges(i,1), edges(i,2), d);
        end
    end
end


toc
%     for k = 1:num_agent
% 
%     %     t = t + 1;
%         % Generate Bundle
%         curr_k = k;
%         generate_bundle;
% 
%         for i = 1:num_agent
%             if k == i
%                 continue
%             end
%     %         t = t + 1;
% 
%             for j = 1:num_deliv
% 
%                 for m = find(winner(:,j,i) > 0)'
%                     if (k == m) && (time(k,m) > time(i,m))
%                         winner(k,j,i) = winner(k,j,k);
%                     end
%                 end
% 
%                 for m = find(winner(:,j,k) > 0)'
%                     if (m ~= i) && ((time(k,m) > time(i,m)) || (m==k))
%                         next_winner = winner(:,j,i);
%                         next_winner(m) = winner(m,j,k);
% 
%                         if sum(next_winner>0, 1) <= deliv(j).reqs
%                             winner(m,j,i) = winner(m,j,k);
%                         else
%                             min_x = min(next_winner(next_winner > 0));
%                             n = find(next_winner == min_x);
% 
%                             if winner(m,j,k) > min_x
%                                 fprintf('Agent %d: Resetting value of agent %d and updating value of agent %d for task %d\n', i, n, m, j);
%                                 winner(n,j,i) = 0;
%                                 winner(m,j,i) = winner(m,j,k);
%                                 if (n == i)
%                                     cbga_release;
%                                 end
%                             end
% 
%                         end
%                     end
%                 end
%             end
%             time(i,k) = t;
% %             fprintf('Agent %d: Finished consensus with agent %d\n', k, i);
% %             disp(winner(:,:,i));
%         end
%     %     disp(winner);
%     end
% end
% toc;

% visualization;
