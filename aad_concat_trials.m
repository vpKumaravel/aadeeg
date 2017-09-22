function aad_concat_trials(trialdir, params)

%         temp = dir([trialdir filesep 'concat_trials' '.mat']);
%         if length(temp) == 1 %if preprocessed trials already exist, don't run this file (to save time)
%             return; %bypass this by running aad_clear_all
%         end
%         %% List all the preprocessed trials (same as in avg covar matrices)
        trialfiles = dir(fullfile(trialdir, ['preprocessed trial '  params.envelopemethod params.subbandtag ' 0*.mat']));
        trialnames = sort({trialfiles(:).name});
        nOfTrials = length(trialnames);

        sub_eeg = [];
        sub_envelope = [];
        for i= 1:length(trialnames)
            load([trialdir filesep trialnames{i}]) % loads a trial.
            sub_eeg = [sub_eeg; trial.RawData.EegData];
            audio_data = trial.Envelope.AudioData;
            if strcmpi(trial.attended_ear,'R')
                tmp = audio_data(:,1,:);
                audio_data(:,1,:) = audio_data(:,2,:);
                audio_data(:,2,:) = tmp;
            end
            sub_envelope = [sub_envelope; audio_data];
        end
        
        save([trialdir filesep 'concat_trials' '.mat'],'trial','sub_eeg','sub_envelope');
end