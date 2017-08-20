

%% Run Basic AAD
% aad_clear_all('powerlaw subbands')
% p = aad_getDefaultParams('basic AAD');
% for subject = p.subjects
%     path_to_data= fullfile(p.basedirectory, subject{1});
% for i = 1:20
%     trial_num = i;
%     if(i<10)
%         file_name = sprintf('trial 00%d.mat',trial_num);
%     else
%         file_name = sprintf('trial 0%d.mat',trial_num);
%     end
%     load(fullfile(path_to_data,file_name));
% %    
%     trial.RawData.EegData = trial.RawData.EegDataOrig;
%     save(fullfile(path_to_data,file_name),'trial');
% end
% end
% 
% aad_toplevel(p);

%% Run Basic AAD clustered data
% aad_clear_all('powerlaw subbands')
% p = aad_getDefaultParams('basic AAD 8 nodes');
% for subject = p.subjects
%     path_to_data= fullfile(p.basedirectory, subject{1});
%     for i = 1:20
%         trial_num = i;
%         if(i<10)
%             file_name = sprintf('trial 00%d.mat',trial_num);
%         else
%             file_name = sprintf('trial 0%d.mat',trial_num);
%         end
%         load(fullfile(path_to_data,file_name));
%     %    
%         trial.RawData.EegData = trial.RawData.EegDataCluster8;
%         save(fullfile(path_to_data,file_name),'trial');
%     end
% end
% 
% aad_toplevel(p);
%% Basic AAD with re-referenced data
% aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
p = aad_getDefaultParams('Lasso_AAD');
% aad_clear_all('powerlar subbands',p,0,0,1);
% for subject = p.subjects
%     path_to_data= fullfile(p.basedirectory, subject{1});
%     for i = 1:20
%         trial_num = i;
%         if(i<10)
%             file_name = sprintf('trial 00%d.mat',trial_num);
%         else
%             file_name = sprintf('trial 0%d.mat',trial_num);
%         end
%         load(fullfile(path_to_data,file_name));
%     %    
%         trial.RawData.EegData = trial.RawData.EegDataOrig;
%         save(fullfile(path_to_data,file_name),'trial');
%     end
% end
aad_toplevel(p);
%% 
% aad_clear_all('powerlaw subbands')
% p = aad_getDefaultParams('MWF AAD');
% for subject = p.subjects
%     path_to_data= fullfile(p.basedirectory, subject{1});
%     for i = 1:20
%         trial_num = i;
%         if(i<10)
%             file_name = sprintf('trial 00%d.mat',trial_num);
%         else
%             file_name = sprintf('trial 0%d.mat',trial_num);
%         end
%         load(fullfile(path_to_data,file_name));
% 
%         trial.RawData.EegData = trial.RawData.EegMWF;
%         save(fullfile(path_to_data,file_name),'trial');
%     end
% end

% p = aad_getDefaultParams('Art Removed Auto Thresh AAD');
% aad_toplevel(p);
%% Run AAD on STAR data

% aad_clear_all('powerlaw subbands')
% p = aad_getDefaultParams('STAR applied AAD');
% % 
% for subject = p.subjects
%     path_to_data= fullfile(p.basedirectory, subject{1});
% %     
%     for i = 1:20
%         trial_num = i;
%         if(i<10)
%             file_name = sprintf('trial 00%d.mat',trial_num);
%         else
%             file_name = sprintf('trial 0%d.mat',trial_num);
%         end
%         load(fullfile(path_to_data,file_name));
% 
%         trial.RawData.EegData = trial.RawData.EegStar;
%         save(fullfile(path_to_data,file_name),'trial');
%     end
% end
% % 
% aad_toplevel(p);

%% 
% aad_clear_all('powerlaw subbands')
% p = aad_getDefaultParams('STAR and MWF applied AAD');

% k = 1;
% for subject = p.subjects
%     path_to_data= fullfile(p.basedirectory, subject{1});
%     
%     for i = 1:20
%         trial_num = i;
%         if(i<10)
%             file_name = sprintf('trial 00%d.mat',trial_num);
%         else
%             file_name = sprintf('trial 0%d.mat',trial_num);
%         end
%         load(fullfile(path_to_data,file_name));
%         
%         if(k==1 && i==1)
%             continue;
%         end
%         
%         trial.RawData.EegData = trial.RawData.EegStarMWF';
%         save(fullfile(path_to_data,file_name),'trial');
%     end
%     k = k+1;
% end

% aad_toplevel(p);

%% Run AAD on ICA artefact removed data
% aad_clear_all('powerlaw subbands')
% p = aad_getDefaultParams('ICA applied AAD');
% % 
% for subject = p.subjects
%     path_to_data= fullfile(p.basedirectory, subject{1});
% %     
%     for i = 1:20
%         trial_num = i;
%         if(i<10)
%             file_name = sprintf('trial 00%d.mat',trial_num);
%         else
%             file_name = sprintf('trial 0%d.mat',trial_num);
%         end
%         load(fullfile(path_to_data,file_name));
% 
%         trial.RawData.EegData = trial.RawData.EegDataICA;
%         save(fullfile(path_to_data,file_name),'trial');
%     end
% end
% % 
% aad_toplevel(p);

%% Run AAD on QPCA applied AAD
% aad_clear_all('powerlaw subbands')
	
% 
% for subject = p.subjects
%     path_to_data= fullfile(p.basedirectory, subject{1});
% %     
%     for i = 1:20
%         trial_num = i;
%         if(i<10)
%             file_name = sprintf('trial 00%d.mat',trial_num);
%         else
%             file_name = sprintf('trial 0%d.mat',trial_num);
%         end
%         load(fullfile(path_to_data,file_name));
% 
%         trial.RawData.EegData = trial.RawData.EegDataQPCA;
%         save(fullfile(path_to_data,file_name),'trial');
%     end
% end
% % 
% aad_toplevel(p);


%%  MWF with thresholding
% p = aad_getDefaultParams('MWF with thresholding');
% aad_clear_all('powerlaw subbands')
% for subject = p.subjects
%     path_to_data= fullfile(p.basedirectory, subject{1});
% %     
%     for i = 1:20
%         trial_num = i;
%         if(i<10)
%             file_name = sprintf('trial 00%d.mat',trial_num);
%         else
%             file_name = sprintf('trial 0%d.mat',trial_num);
%         end
%         load(fullfile(path_to_data,file_name));
% 
%         trial.RawData.EegData = trial.RawData.EegDataAutoThrArtRem;
%         save(fullfile(path_to_data,file_name),'trial');
%     end
% end
% % 
% aad_toplevel(p);
%% For hypotheses testing

% signrank(art_res(:),old_res(:))
% 
% ans =
% 
%     0.0156
% 
% mean([art_res(:),old_res(:)])
% 
% ans =
% 
%     0.8796    0.8472