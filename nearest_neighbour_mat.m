function M = nearest_neighbour_mat(chans, neighs)
    load('elec_cord.mat');
    load('dist_matrix.mat');
    load('locs.mat');
    ok = find(~(cellfun('isempty',{locs.X}) | cellfun('isempty',{locs.Y}) | cellfun('isempty',{locs.Z})));
    [px,py] = cart2sph([locs(ok).Z],[locs(ok).X],[locs(ok).Y]);
    
    % compute neighbor matrix M
    M = zeros(numel(ok));
    
    for i=1:numel(chans)
        % get surface angles/distances to all other channels
        c = chans(i);
        v = [px(c)-px; py(c)-py];
        [ang,dst] = deal((180/pi)*(pi+atan2(v(1,:),v(2,:))), sqrt(v(1,:).^2+v(2,:).^2));
        [dummy, idx] = sort(dst);
        M(c,idx(2:neighs+1)) = 1;
    end
    n_of_pairs = length(find(M==1));
    for i = 1:size(M,1) 
        for j = 1:i
            if M(i,j) == M(j,i)
                M(i,j) = 0;
            end
        end
    end

end