function bundle = extract_time(bundle, path)
    for n = length(bundle):-1:1
        bundle(n).time = path.time(bundle(n).ij);
        for idx = 2:-1:1
            if bundle(n).add(idx) == 0
                continue
            end
            path.node(bundle(n).add(idx)) = [];
            path.time(bundle(n).add(idx)) = [];
            path.tr(bundle(n).add(idx)) = [];
        end
    end
end