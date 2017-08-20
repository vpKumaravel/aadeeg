%% Run AAD sequentially with different parameters
% aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
% 
% % % 30s splits used for aad
% split_len = 30;
% p = aad_getDefaultParams('basic_AAD_16_clus_global_30sSplit');
% p.triallength = split_len;
% p.rereference = 1;
% p.cluster = 1;
% p.clusterno = 16;
% p.minchexp = 0;
% % p.decodermethod = 'group lasso';
% aad_toplevel(p);
% 
% aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
split_len = 60;
p = aad_getDefaultParams('LASSO_trial_16_new');
p.triallength = split_len;
p.rereference = 0;
p.cluster = 1;
p.clusterno = 64;
p.minchexp = 1;
p.triallasso = 0;
p.decodermethod = 'osullivan';
p.lassofactor = 1;
p.channels = 1:200;
p.trialchlist = 0;
p.lassochsel = 1;
load('nearest_neighbours.mat','chnl_list');
p.chnl_lst = chnl_list;
p.lassochnum = 16;
aad_toplevel(p);
% aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
% k = 1;
% for lambda = 5e-5:5e-6:2e-4
%     lambda_k(k) = lambda;
%     str = sprintf('LASSO_trial_%d',k);
%     p = aad_getDefaultParams(str);
%     p.rereference = 0;
%     p.cluster = 1;
%     p.minchexp = 1;
%     p.decodermethod = 'group lasso';
%     p.triallasso = 1;
%     p.lassofactor = lambda;
%     p.basedirectory = '/home/abhijith/Documents/MATLAB/Lasso_Data';
%     aad_toplevel(p);
%     k = k+1;
% end