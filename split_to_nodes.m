clc;
close all;
clear all;
%% 
p = aad_getDefaultParams('Split to Nodes');
clusters = 8;
k = 1;
for subject = p.subjects
    path_to_data = fullfile(p.basedirectory,subject{1});
    for i = 1:20
        trial_num = i;
        if(i<10)
            file_name = sprintf('trial 00%d.mat',trial_num);
        else
            file_name = sprintf('trial 0%d.mat',trial_num);
        end
        load(fullfile(path_to_data,file_name));
        
        eeg_data = trial.RawData.EegDataOrig';
        eegNew = splitnodes(eeg_data, clusters);
        trial.RawData.EegDataCluster8 = eegNew';
        save(fullfile(path_to_data,file_name),'trial');
        fprintf('\nTrial %d of subject %s done!',trial_num,subject{1});
    end
    k = k+1;
end