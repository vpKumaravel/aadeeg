clc;
clear all;
close all;
%% Find channels of local re-reference
load('nearest_neighbours.mat');
ids = find(M==1);
chnl_list = zeros(numel(ids),2);
chn = 1;
for k = 1:size(M,1)
    ids = find(M(k,:) == 1);
    chnl_list(chn:chn+length(ids)-1,1) = k;
    chnl_list(chn:chn+length(ids)-1,2) = ids;
    chn = chn+length(ids);
end