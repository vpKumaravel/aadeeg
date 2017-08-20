function aad_preprocess_eeg1( trialdir, params )
%AAD_preprocess applies some more custom processing
% This file starts from trials which are outputted by aad_load_bdfs.
% This file should only be performed once (for each envelopemethod)
% and only contains some basic processing that is assumed to never
% change.
% Also adds the right envelope files (resulting from aad_envelopes) to each trial.

% if nargin < 1
%     fprintf('aad_preprocess_eeg: taking default trialdirectory \n')
%     trialdir = 'C:\Users\wbiesman\Data\AAD_recordings\simon\dry';
% end
%
envelopedir = params.envelopedir;

if params.version ==1
    params.epochSelection = 1:100; % a preliminary epoch selection (as not all trials have the same number initially).(see aad_preprocess_eeg). Only applies to version 1.
    params.audioPairing = repmat([repmat([4 2 6],1,2) repmat([1 5 3 ],1,2)],1,2); % which audiofile corresponds to each trial
    params.attention = [repmat({'left'},1,3); repmat({'right'},1,3)]; params.attention = params.attention(:); %start left, then alternate for first 6 trials.
    params.attention = repmat([params.attention ; flipud(params.attention)],2,1); %flip order for trials 7-12, repeat this sequence for trials 13-24.
    params.speakerattended = repmat([1 1 1 2 2 2],1,4);
    expected_no_trials = 24;
    expected_no_envelopes = 6;
elseif params.version == 2
    expected_no_trials = 4+4+12;
    expected_no_envelopes = 16;
end

%% Check if function needs to be run.
temp = dir([trialdir filesep 'preprocessed_trial'  params.envelopemethod params.subbandtag '_0*.mat']);
if length(temp) == expected_no_trials %if preprocessed trials already exist, don't run this file (to save time)
    return; %bypass this by running aad_clear_all
end


%% List all trials
if params.verbose, fprintf('aad_preprocess_eeg: processing trials to preprocessed trials. \n'), end
trialfiles = dir([trialdir filesep 'trial*.mat']);
trialnames = sort({trialfiles(:).name});
nOfTrials = length(trialnames);
if nOfTrials ~= expected_no_trials;
    warning(['nOftrials ~= ' num2str(expected_no_trials) ', but = ' num2str(nOfTrials)])
end


%% Load all envelopes (For version 2 the correct envelopes are only loaded in each iteration of the trial loop - next section)
if params.version ==1
    envelopefiles = dir([envelopedir filesep params.envelopemethod params.subbandtag '*.mat']); %load correct kind
    envelopenames = sort({envelopefiles(:).name});
    nOfEnvelopes = length(envelopenames);
    if nOfEnvelopes ~= expected_no_envelopes;
        warning(['nOfEnvelopes ~= ' num2str(expected_no_envelopes) ', but = ' num2str(nOfEnvelopes)])
    end
    envelopes = cell(1,nOfEnvelopes);
    weights = cell(1,nOfEnvelopes);
    for i = 1:nOfEnvelopes
        load([envelopedir filesep envelopenames{i}]) %loads 'envelope'
        envelopes{i} = envelope;
        % Select the epochs from params.epochSelection, of the envelope
        selection = repmat((params.epochSelection-1)*Fs,Fs,1) + repmat((1:Fs)',1,length(params.epochSelection)); % alternatively reshape, keep certain columns (probably faster)
        envelopes{i} = envelopes{i}(selection(:),:,:);
        weights{i} = subband_weights;
        if Fs ~= params.targetSampleRate
            warning(['Envelope samplerate Fs (' num2str(Fs) 'should be equal to targetsamplerate (' num2str(params.targetSampleRate) 'for the EEG'])
        end
    end
end

%% Load and Preprocess trials (and subsequently update relevant fields).
bpFilter = aad_construct_bpfilter(params);
% Neetha - code to skip just the last repetition - 31/3/2016 - start
if params.skip_last_repetition
    nOfTrials = nOfTrials-4;
end
% Neetha - code to skip just the last repetition - 31/3/2016 - end

% AMN re-referencing Cz
if params.rereference == 1
	params.channels = 1:63;
end

for i = 1: nOfTrials
    % Load trial
    load([trialdir filesep trialnames{i}]) %loads a 'trial' variable into the workspace
    if params.skip_repetition && trial.repetition % Neetha - 02/03/2016 - option to skip repetitions
        continue;
    end
	
       
% AMN re-referencing Cz
    if params.rereference == 1
    	trial.FileHeader.ChannelCount = trial.FileHeader.ChannelCount - 1;
        ref_channel = trial.RawData.EegData(:,48);
        trial.RawData.EegData = trial.RawData.EegData - ref_channel(:,ones(1,64));
        trial.RawData.EegData(:,48) = [];
    end
    
    if params.cluster == 1
        trial.RawData.EegData = transpose(splitnodes(trial.RawData.EegData', 32, 0));
        params.channels = 1:31;
        trial.FileHeader.ChannelCount = 31;% AMN for clustered data
    end

    % Select the epochs to work with (throw away trailing epochs).
    nOfChannels = trial.FileHeader.ChannelCount;
    if params.version ==1
        epochs = reshape(trial.RawData.EegData,params.intermediateSampleRate,[],nOfChannels);
        trial.RawData.EegData = reshape(epochs,[],nOfChannels);
    end
    
    % apply bpfiltering to the EEG signal
    if params.RBP % Neetha - 25/05/2016 - including option to run EEGLab BPF
        eeg_temp = [];
        for ch = 1:size(trial.RawData.EegData,2)
            eeg_temp(:,ch) = Rbp(params.highpass,params.lowpass,trial.FileHeader.SampleRate, double(trial.RawData.EegData(:,ch)));
        end
        trial.RawData.EegData = eeg_temp;
    else
        trial.RawData.EegData = filtfilt(bpFilter.numerator,1,double(trial.RawData.EegData));
    end
    %new
    %     h = bpFilter.numerator;
    %     h2 = conv(h,fliplr(h));
    %     dly = mean(grpdelay(h2,1));
    %     trial.RawData.EegData = fftfilt(h2,[double(trial.RawData.EegData); zeros(dly,size(trial.RawData.EegData,2))]);
    %     trial.RawData.EegData = trial.RawData.EegData(dly+1:end,:);
    
    %     trial.RawData.EegData(abs(trial.RawData.EegData)<=1e-10) = 0; % Neetha  -
    %     06/04/2016 no change in results for abs env method
    
    
    %new end
    trial.RawData.HighPass = params.highpass;
    trial.RawData.LowPass = params.lowpass;
    trial.RawData.bpFilter = bpFilter;
    
    % downsample EEG (using downsample so no filtering appears).
    downsamplefactor = trial.FileHeader.SampleRate/params.targetSampleRate;
    if round(downsamplefactor)~= downsamplefactor, error('Downsamplefactor is not integer'); end
    trial.RawData.EegData = downsample(trial.RawData.EegData,downsamplefactor);
    trial.FileHeader.SampleRate = params.targetSampleRate;
    trial.Epochs.FramesPerEpoch = params.targetSampleRate;
    
    % Add the correct audio envelopes and direction of attention to the trial:
    if params.version ==1
        trial.Envelope.AudioData = envelopes{params.audioPairing(i)};
        trial.Envelope.subband_weights = weights{params.audioPairing(i)};    trial.attended_ear = params.attention{i};
        trial.FileHeader.speakerattended = params.speakerattended(i); % 1/2
    elseif params.version ==2 % pair the trial with the corresponding dry stimuli.
        %(1:end-8) to remove 'hrtf.wav' or '_dry.wav' from the stimulus file name
        if strcmpi(trial.condition,'dry')
            postfix = '_dry.mat';
        else
            postfix = 'dry.mat';
        end
        
        % Neetha - make all envelopes of the same length - 390 seconds -
        % start 9/01/2017
%         if ~trial.repetition 
%          trial.RawData.EegData = trial.RawData.EegData(1:(390*params.targetSampleRate),:);
%         end
        % end 9/01/2017
        
        % Load correct audio, truncate to length of EEG
        load(['Data/stimuli/envelopes' filesep params.envelopemethod params.subbandtag '_' trial.stimuli{1}(1:end-8) postfix ]);
        left = envelope1;
        left = left(1:length(trial.RawData.EegData),:,:);
        load( ['Data/stimuli/envelopes' filesep params.envelopemethod params.subbandtag '_' trial.stimuli{2}(1:end-8) postfix ]);
        right = envelope1;
        right = right(1:length(trial.RawData.EegData),:,:);
        if Fs ~= params.targetSampleRate,warning(['Envelope samplerate Fs (' num2str(Fs) 'should be equal to targetsamplerate (' num2str(params.targetSampleRate) 'for the EEG']),end
        trial.Envelope.AudioData = cat(2,left, right);
        trial.Envelope.subband_weights = subband_weights;
        trial.FileHeader.speakerattended = trial.attended_track; %for backward compatibility: duplicate this info
    end
    trial.trialID = i;
    
    % Match channels of mbraintrain if necessary
    if params.match_mbraintrain_ch
        channels = [1 5 7 13 15 21 23 27 30 31 32 34 37 38 40 42 48 50 52 58 60 64];
        trial.RawData.EegData = trial.RawData.EegData(:,channels);
        trial.FileHeader.ChannelCount = length(channels);
        trial.RawData.Channels = channels;
    end
    
    % Save preprocessed trial
    
    save([trialdir filesep 'preprocessed_trial_'  params.envelopemethod params.subbandtag '_' num2str(i,'%04d') '.mat'],'trial')
    
end
% Possibly average some trials

% store preprocessed trials after averaging (if so).



end

