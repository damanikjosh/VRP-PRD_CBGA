function [cycle, new_cycle] = search_forward(path, length, arcs)
    cycle = {};
    if isempty(path)
        new_cycle = [];
    else
        new_cycle = [path; path(end,2) path(1,1)];
    end
    if size(path, 1) < length-1
        if isempty(path)
            arcs_p = arcs;
        else
            arcs_p = arcs(arcs(:,1)==path(end,2),:);
        end
%         disp(arcs_p);
        
        for i = 1:size(arcs_p, 1)
            if ~ismember(arcs_p(i, 2), path)
                [cycle, new_cycle] = search_forward([path; arcs_p(i, 1:2)], length, arcs);
            else
                cycle{end+1} = new_cycle;
                new_cycle = [];
            end
        end
    end
end