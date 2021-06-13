function reward = calc_reward(reqs, times, rewards)
    reward = 0;
    for n = 1:length(reqs)
        reward = rewards + rewards(reqs(n,1), reqs(n,2)) * 0.99^(times(n));
    end
end