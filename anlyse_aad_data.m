clc;
clear all;
close all;
%% 
path_to_data = '../Data/02_subject';
file_name = 'trial 001.mat';
load(fullfile(path_to_data,file_name));
eeg_data = trial.RawData.EegData';
Fs = trial.FileHeader.SampleRate;
eegplot(eeg_data, 'srate', Fs,'command','get_mask_eeglab','butlabel','SAVE MARKS');


for i = 1:20
    trial_num = i;
    file_name = sprtintf('trial 00%d.mat',trial_num);
    load(fullfile(path_to_data,file_name));
    trial.RawData.EegDataOrig = trial.RawData.EegData;
    eeg_data = trial.RawData.EegData';
    Fs = trial.FileHeader.SampleRate;
    save('../matlab_workspace/EEG_data_readout/trial.mat','eeg_data','Fs');
end