function dist = proj_dist(dist, pos_trg)
    proj = (dist'*pos_trg)/(pos_trg'*pos_trg)*pos_trg;
    dist = norm(proj)*sign(proj'*pos_trg);
end