fprintf('Agent %d: Building bundle\n', curr_k);
% [~, last_score] = generate_path(hub, deliv, agent(curr_k), bundle{curr_k});
last_score = 0;

while length(bundle{curr_k}) < agent(curr_k).qmax
%     d = setdiff(1:num_deliv, bundle{curr_k});
    legs = setdiff(1:num_deliv, bundle{curr_k});
    if isempty(d)
        break
    end

    next_bundle = [];
    next_path = [];
    next_score = [];
    next_feasible = [];

    for i = 1:length(d)
        next_bundle(i,:) = [bundle{curr_k} d(i)];
        [next_path(i,:), next_score(i,:)] = generate_path(hub, deliv, agent(curr_k), next_bundle(i,:));
            if sum(winner(:,d(i),curr_k)>0, 1) < deliv(d(i)).reqs
                next_feasible(i) = 1;
            elseif next_score(i,:)-last_score > min(winner(winner(:,d(i),curr_k) > 0,d(i),curr_k))
                next_feasible(i) = 1;
            else
                next_feasible(i) = 0;
            end
    end

    [score, max_i] = max(next_score .* next_feasible');
    if (score-last_score) <= 0
        break
    end
    fprintf('Agent %d: Adding task %d to bundle with score %.4f\n', curr_k, d(max_i), score-last_score);
    bundle{curr_k} = next_bundle(max_i, :);
    path{curr_k} = next_path(max_i, :);
    winner(curr_k, d(max_i), curr_k) = score-last_score;
    last_score = score;
end
time(curr_k,curr_k) = t;
fprintf('Agent %d: [ ', curr_k);
fprintf(repmat('%d ', 1, length(bundle{curr_k})), bundle{curr_k});
fprintf(']\n');
disp(winner(:,:,curr_k));