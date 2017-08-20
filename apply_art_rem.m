% clc;
% clear;
% close all;
function apply_art_rem(method, split_len)
%% Apply artefact removal techniques
% method = 6; % 1- ICA; 2 - PCA; 3- QPCA 6 - STAR; 7 - STAR followed by MWF with auto
% 4 - MWF with manual threshold
% threshold
concat_data_path = '/home/abhijith/Documents/MATLAB/Data_addnl';
p = aad_getDefaultParams('Artefact Remove');

    switch method
        case 0
            aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
            p = aad_getDefaultParams('basic_aad_reref_20sSplit');
            p.trialLength = split_len;
            p.rereference = 1;
            p.cluster = 0;
            p.minchexp = 0;
            p.artrem = 0;
            p.artremmethod = 0;
            aad_toplevel(p);
        case 1
            concat_files = dir(fullfile(concat_data_path,'*.mat'));
            concat_files = sort({concat_files(:).name});
            no_of_files = length(concat_files);
            for i = 1:no_of_files
                load(fullfile(concat_data_path,concat_files{i}));
                ica_comp(artefact_ids, :) = [];
                ica_weights(:, artefact_ids) = [];
                eeg = transpose(ica_weights*ica_comp);
                subject = concat_files{i};
                subject = subject(1:end-4);
                path_to_data = fullfile(p.basedirectory,subject);
                strt = 1;
                for j = 1:20
                    trial_num_1 = j;
                    if(j<10)
                        file_name = sprintf('trial 00%d.mat',trial_num_1);
                    else
                        file_name = sprintf('trial 0%d.mat',trial_num_1);
                    end
                    load(fullfile(path_to_data,file_name));
                    len = size(trial.RawData.EegData,1);
                    trial.RawData.EegData = eeg(strt:strt+len-1,:);
                    strt = strt+len;
                    save(fullfile(path_to_data,file_name),'trial');
                end
                fprintf('Trials of subject %s done\n',concat_files{i});
            end

            aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
            p = aad_getDefaultParams('ICA_aad_reref_20sSplit');
            p.trialLength = split_len;
            p.rereference = 1;
            p.cluster = 0;
            p.minchexp = 0;
            p.artrem = 0;
            p.artremmethod = 0;
            aad_toplevel(p);
        case 2
            concat_files = dir(fullfile(concat_data_path,'*.mat'));
            concat_files = sort({concat_files(:).name});
            no_of_files = length(concat_files);
            for i = 1:no_of_files
                load(fullfile(concat_data_path,concat_files{i}));
                eeg = pca_art_comp_rem(concat_eeg, pca_components);
                subject = concat_files{i};
                subject = subject(1:end-4);
                path_to_data = fullfile(p.basedirectory,subject);
                strt = 1;
                for j = 1:20
                    trial_num_1 = j;
                    if(j<10)
                        file_name = sprintf('trial 00%d.mat',trial_num_1);
                    else
                        file_name = sprintf('trial 0%d.mat',trial_num_1);
                    end
                    load(fullfile(path_to_data,file_name));
                    len = size(trial.RawData.EegData,1);
                    trial.RawData.EegData = eeg(strt:strt+len-1,:);
                    strt = strt+len;
                    save(fullfile(path_to_data,file_name),'trial');
                end
                fprintf('Trials of subject %s done\n',concat_files{i});
            end
        case 3
            concat_files = dir(fullfile(concat_data_path,'*.mat'));
            concat_files = sort({concat_files(:).name});
            no_of_files = length(concat_files);
            for i = 1:no_of_files
                load(fullfile(concat_data_path,concat_files{i}));
                qpca_components(:, qpca_artefact_ids) = [];
                tosquares(:, qpca_artefact_ids) = [];
                tosquares = pinv(tosquares);    
    
                eeg = qpca_components * tosquares;
            end
        case 4

            aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
            p = aad_getDefaultParams('MWF_man_thr_aad_reref_20sSplit');
            p.trialLength = split_len;
            p.rereference = 1;
            p.cluster = 0;
            p.minchexp = 0;
            p.artrem = 1;
            p.artremmethod = method;
            aad_toplevel(p);
        case 6

            aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
            p = aad_getDefaultParams('STAR_aad_reref_20sSplit');
            p.trialLength = split_len;
            p.rereference = 1;
            p.cluster = 0;
            p.minchexp = 0;
            p.artrem = 1;
            p.artremmethod = method;
            aad_toplevel(p);
        case 7

            aad_clear_all('powerlaw subbands',aad_getDefaultParams,false);
            p = aad_getDefaultParams('STAR_MWF_man_thr_aad_reref_20sSplit');
            p.trialLength = split_len;
            p.rereference = 1;
            p.cluster = 0;
            p.minchexp = 0;
            p.artrem = 1;
            p.artremmethod = method;
            aad_toplevel(p);
    end
end