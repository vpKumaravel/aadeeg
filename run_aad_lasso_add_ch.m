%% Adding channels to sensor nodes
% aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
% split_len = 60;
% p = aad_getDefaultParams('WESN_add_4_channels');
% p.trialLength = split_len;
% p.rereference = 0;
% p.cluster = 1;
% p.clusterno = 64;
% p.minchexp = 1;
% p.triallasso = 0;
% p.decodermethod = 'osullivan';
% p.lassofactor = 1;
% p.channels = 1:200;
% p.trialchlist = 0;
% p.utilitycalc = 1;
% p.lassochsel = 0;
% load('nearest_neighbours.mat','chnl_list');
% p.chnl_lst = chnl_list;
% p.lassochnum = 2;
% p.utilitytrial = 0;
% aad_toplevel(p);
%% Running AAD with selected channels
% aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
% split_len = 60;
% p = aad_getDefaultParams('WESN_add_2_channel_60s');
% p.trialLength = split_len;
% p.rereference = 0;
% p.cluster = 1;
% p.clusterno = 64;
% p.minchexp = 1;
% p.triallasso = 0;
% p.decodermethod = 'osullivan';
% p.lassofactor = 1;
% p.channels = 1:200;
% p.trialchlist = 1;
% p.utilitycalc = 0;
% p.lassochsel = 0;
% load('nearest_neighbours.mat','chnl_list');
% p.chnl_lst = chnl_list;
% p.lassochnum = 2;
% p.utilitytrial = 1;
% aad_toplevel(p);
% 
% %
% %
% %
% 
% aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
% split_len = 30;
% p = aad_getDefaultParams('WESN_add_2_channel_30s');
% p.trialLength = split_len;
% p.rereference = 0;
% p.cluster = 1;
% p.clusterno = 64;
% p.minchexp = 1;
% p.triallasso = 0;
% p.decodermethod = 'osullivan';
% p.lassofactor = 1;
% p.channels = 1:200;
% p.trialchlist = 1;
% p.utilitycalc = 0;
% p.lassochsel = 0;
% load('nearest_neighbours.mat','chnl_list');
% p.chnl_lst = chnl_list;
% p.lassochnum = 2;
% p.utilitytrial = 1;
% aad_toplevel(p);
% % 
% aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
% split_len = 20;
% p = aad_getDefaultParams('WESN_add_2_channel_20s');
% p.trialLength = split_len;
% p.rereference = 0;
% p.cluster = 1;
% p.clusterno = 64;
% p.minchexp = 1;
% p.triallasso = 0;
% p.decodermethod = 'osullivan';
% p.lassofactor = 1;
% p.channels = 1:200;
% p.trialchlist = 1;
% p.utilitycalc = 0;
% p.lassochsel = 0;
% load('nearest_neighbours.mat','chnl_list');
% p.chnl_lst = chnl_list;
% p.lassochnum = 2;
% p.utilitytrial = 1;
% aad_toplevel(p);
%% Subjects-wide channel/node selection
% aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
split_len = 60;
p = aad_getDefaultParams('WESN_subjects_wide_select_nodes');
p.rereference = 0;
p.cluster = 1;
p.clusterno = 64;
p.minchexp = 1;
p.triallasso = 0;
p.decodermethod = 'osullivan';
p.lassofactor = 1;
p.channels = 1:200;
p.lassochnum = 2;
p.lassochsel = 1;
p.allsublasso = 1;
aad_toplevel(p);