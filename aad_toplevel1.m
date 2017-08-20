function results = aad_toplevel1(params )
%AAD_TOPLEVEL Summary of this function goes here
%   Detailed explanation goes here

%% TODO: the two outer loops that are present in every subfunction (for subject, for condition)
% should be placed in this file once, instead of in every file.
% Then pass on the trialdir instead of basedir to each subfunction.
% This will greatly simplify the code. Might make aad_preprocess obsolete.

 if nargin == 0 % easy for debugging purposes
    params = aad_getDefaultParams;
end

if params.verbose, fprintf(['aad_toplevel: starting experiment ' params.experimentName '\n']); end

if ~exist(params.resultsdir,'dir')
    mkdir(params.resultsdir);
else
    fprintf('aad_toplevel: Older results from experiment with same name might be overwritten. \n')
    if ~params.bootstrap
    [~,~,~] = rmdir([params.resultsdir filesep '*'],'s') %remove subdirs (also recursively)
    delete(fullfile(params.resultsdir,'*')); %empty the folder.
    end
end
warning('off')   
% mkdir(params.originaldecoderdir);
mkdir(params.covardir);
mkdir(params.avgcovardir);
mkdir(params.decoderdir);
mkdir(params.decodedeegdir);
warning('on')
save([params.resultsdir filesep 'params.mat'],'params')



% clear all previous files if everything is to be recalculated
if params.rerun
    aad_clear_all(params);
end

%preprocess eeg into trials and audio into envelopes. Makes sure both are
%synchronized and links trial to corresponding envelope.

aad_preprocess(params)
if params.rereference == 1
	params.channels = 1:63;
end
if params.cluster == 1
	params.channels = 1:31;
end

% construct decoder should be done in a flexible way...
% We want to be able to do different experiments: construct on all other
% decoders, on all other decoders within the same conditions. On some other
% decoders... etc. Maybe construct different functions for this that like
% michael did with functioncallbacks. also store these with different names
% (including the functioncallback used).
% We also want to construct the decoders using different optimization
% algorithms/ parameters (for example regularization, ...)

% Possibly subsample the channels or apply SNS if dimensionality is too
% big. ATM ~900 parameters,

% compare the correlations with the audio at different timelags (without decodering), and
% also compare these with the correlation

%% algorithm flow:
% load a trial, calculate attended and unattended decoder. Use different
% methods for this. These decoders should be saved in a subfolder of the
% folder of the trials. Other parameters: which channels to use (if not all)
% and which delays. These parameters should be saved with the decoders.
% aad_construct_decoders. FIRST: only Osullivan implemented.

aad_construct_covar(params);
% it is hard to check ATM if this was done correctly. Filter has the right
% dimensions though and backward model was chosen

% Then the decoders have to be combined in some way (e.g. attended decoders)
% to create one decoder per trial. (e.g. for applying to trial x, average
% all decoders but the one created from the trial x.) The trial number and
% the method of combination that was used should be in the decoder's name.

aad_avg_covar(params);



aad_construct_decoders(params);

if params.avg_decoders
    aad_avg_decoders(params);
end

% Apply the decoders to their corresponding trial, save the result.
% This function will also need to take into account the parameters that
% were used to construct the decoders.

aad_apply_decoders(params);


% Compute correlations with both audio envelopes (attended and unattended)
% to perform classification. [R,P]=corrcoef(...) also returns P, a matrix of p-values for testing the hypothesis of no correlation.

aad_evaluate(params);


% Visualize the results... Maybe use R for this? If so, we first have to
% put the results in a .csv file.

% Results aggregated per experiment (over all subjects and conditions)
results = aad_aggregate_results(params); % load all results, then average.


% assess correlations: http://vassarstats.net/rdiff.html

end
% Some visualization of the envelopes:

% load('C:\Users\wbiesman\Data\AAD_recordings\wouter\dry\Preprocessed trial 1.mat')
% trial1 = trial
% load('C:\Users\wbiesman\Data\AAD_recordings\wouter\dry\Preprocessed trial 7.mat')
% trial7 = trial;
% figure,plot(trial1.Envelope.AudioData(1:400,1)), hold on, plot(trial1.Envelope.AudioData(1:400,2),'r')

% correlation checks
% corr(trial1.Envelope.AudioData(:,1),trial1.Envelope.AudioData(:,2))
% corr(trial1.Envelope.AudioData(:,1),trial7.Envelope.AudioData(:,2))
