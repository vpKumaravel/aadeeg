function aad_cnstrct_covar_for_lasso(params)
    for subject = params.subjects
        %% list all preprocessed/split trials for a subject
        trialdir = fullfile(params.basedirectory , subject{1});
        
        trialfile = dir(fullfile(trialdir,['concat_trials' '.mat']));
    
        if(isempty(trialfile))
            warning('Concatenated trials not found for %s', subject{1});
        else
            load(fullfile(trialdir,['concat_trials' '.mat']));
        end
        
        covar = trial;
        covar.RawData.EegData = []; covar.Envelope.AudioData = [];
        covar.params = params;
        covar.subject = subject{1};
        covar.condition = trial.condition;
        
        left = squeeze(sub_envelope(:,1,:))*trial.Envelope.subband_weights(:);
        right = squeeze(sub_envelope(:,2,:))*trial.Envelope.subband_weights(:);
        if strcmpi(params.experimentName,'abs powerlaw experiment') 
            left = sign(left).*abs(left).^params.power; 
            right = sign(right).*abs(right).^params.power; 
        end
        audio = cat(2,left,right);
        
        % Calculate 5 covar matrices (with lags).  x refers to eeg, y to audio,
        [covar.Rxx,Ryy_left,Rxy_left,Ryy_right,Rxy_right] = covar_matrices(sub_eeg(:,params.channels),audio,trial.FileHeader.SampleRate,params.start,params.end,params.audioshifts,params.singleshift,params.decodershift);
        [covar.Ryy_att,covar.Ryy_unatt] = deal(Ryy_left,Ryy_right);
        [covar.Rxy_att,covar.Rxy_unatt] = deal(Rxy_left,Rxy_right);
        
        save([params.covardir filesep subject{1} '_covar.mat'],'covar');
    end
end


function [Rxx,Ryy_left,Rxy_left,Ryy_right,Rxy_right] = covar_matrices(x,y,Fs,start,fin,audioshifts,singleshift,decodershift)

start = floor(start/1e3*Fs); %convert milliseconds to samples
if singleshift
    fin = decodershift; %added by neetha - need only 1 lag at 100ms 
end
fin = ceil(fin/1e3*Fs); %convert milliseconds to samples
noflags = length(start:fin);
nofsamples = size(x,1);


yleft = aad_LagGenerator(squeeze(y(:,1,:)),audioshifts); %by default there are no audio shifts.
yright = aad_LagGenerator(squeeze(y(:,2,:)),audioshifts);

%UPDATE: normalize frequency-specific envelopes
% yleft = normc(yleft);
% yright = normc(yright);

[start,fin] = deal(-fin,-start);
if singleshift
    X = aad_LagGenerator(x,[start]);%added by Neetha 21/12/2015 - need only 1 lag at 100ms 
else 
    X = aad_LagGenerator(x,start:fin);%adding lags of one sample each
end

Rxx = (X'*X)/nofsamples;

Rxy_left = (X'*yleft)/nofsamples;
Rxy_right = (X'*yright)/nofsamples;

Ryy_left = (yleft'*yleft)/nofsamples;
Ryy_right = (yright'*yright)/nofsamples;


end