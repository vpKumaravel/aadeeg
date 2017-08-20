clc;
clear all;
close all;
%% 
load('elec_cord.mat');
load('dist_matrix.mat');
load('locs.mat');
%%
% dist_matrix = zeros(64,64);
% 
% for i = 1:size(dist_matrix,1)
%     for j = 1:size(dist_matrix,2)
%         if(j<i)
%             dist_matrix(i,j) = dist_matrix(j,i); 
%         else
%             dist_matrix(i,j) = eucdist(elec_cord(i),elec_cord(j));
%         end
%     end
% end
% 
% save('dist_matrix.mat','dist_matrix');
% for i = 1:size(dist_matrix,1)
%     [val, id] = sort(dist_matrix(i,:));
%     neighb_elecs(i,:) = id(3:7);
% end
ok = find(~(cellfun('isempty',{locs.X}) | cellfun('isempty',{locs.Y}) | cellfun('isempty',{locs.Z})));
[px,py] = cart2sph([locs(ok).Z],[locs(ok).X],[locs(ok).Y]);

% compute neighbor matrix M
M = zeros(length(ok));
neighs = 5;

for c=1:length(ok)
    % get surface angles/distances to all other channels
    v = [px(c)-px; py(c)-py];
    [ang,dst] = deal((180/pi)*(pi+atan2(v(1,:),v(2,:))), sqrt(v(1,:).^2+v(2,:).^2));
    [dummy, idx] = sort(dst);
    M(c,idx(2:6)) = 1;
%     for s = 1:neighs
%         % find all channels within the sector s (excl. c) and store the closest one
%         validchns = find(within(ang, 360*(s-1.5)/neighs, 360*(s-0.5)/neighs) & c~=(1:length(ok)));
%         [dummy,idx] = min(dst(validchns)); % #ok<ASGLU>
%         if ~isempty(idx)
%             M(c,validchns(idx)) = 1; end
%     end
end

for i = 1:size(M,1)
    for j = 1:i
        if M(i,j) == M(j,i)
            M(i,j) = 0;
        end
    end
end

p = sum(M,2);

save('nearest_neighbours.mat','M','p');
