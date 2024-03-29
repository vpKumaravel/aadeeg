function aad_cnstrct_covar_for_lasso(params)

    if(params.parpro == 1 && params.allsublasso==0)
        poolobj = gcp('nocreate');
        if(isempty(poolobj))
           parpool(2);
        end
    end
    
    k = 1;
    
    if(params.allsublasso == 1)
        allsublasso = 1;
    else
        allsublasso = 0;
    end
    
    for subject = params.subjects
        params_all(k) = {params};
        %% list all preprocessed/split trials for a subject
        trialdir = fullfile(params.basedirectory , subject{1});
        
        trialfile = dir(fullfile(trialdir,['concat_trials' '.mat']));
    
        if(isempty(trialfile))
            warning('Concatenated trials not found for %s', subject{1});
        else
            load(fullfile(trialdir,['concat_trials' '.mat']));
        end
        
        sub_eeg_all(k) = {sub_eeg};
        sub_env_all(k) = {sub_envelope};
        trial_all(k) = {trial};
        sub_names(k) = {subject{1}};
        k = k+1;
    end

    no_of_subs = k-1;
    if(params.parpro == 1 && allsublasso == 0)
        parfor k = 1:no_of_subs
            params = params_all{k};
            trialsub = trial_all{k};
            sub_eeg = sub_eeg_all{k};
            sub_envelope = sub_env_all{k};

            params.channels = 1:length(trialsub.chnl_lst);
%         covar = trial;
%         covar.RawData.EegData = []; covar.Envelope.AudioData = [];
%         covar.params = params;
%         covar.subject = subject{1};
%         covar.condition = trial.condition;

            left = squeeze(sub_envelope(:,1,:))*trialsub.Envelope.subband_weights(:);
            right = squeeze(sub_envelope(:,2,:))*trialsub.Envelope.subband_weights(:);
            if strcmpi(params.experimentName,'abs powerlaw experiment') 
                left = sign(left).*abs(left).^params.power; 
                right = sign(right).*abs(right).^params.power; 
            end
            audio = cat(2,left,right);

            [X, yleft, yright] = create_lagged_data(sub_eeg(:,params.channels),audio,trialsub.FileHeader.SampleRate,params.start,params.end,params.audioshifts,params.singleshift,params.decodershift);

            [y_att, y_unatt] = att_unatt(yleft, yright, trialsub.attended_ear);
            do_lasso(params, X, y_att, sub_names{k});
        end
    else
        for k = 1:no_of_subs
            params = params_all{k};
            trialsub = trial_all{k};
            sub_eeg = sub_eeg_all{k};
            sub_envelope = sub_env_all{k};

            params.channels = 1:length(trialsub.chnl_lst);
    %         covar = trial;
    %         covar.RawData.EegData = []; covar.Envelope.AudioData = [];
    %         covar.params = params;
    %         covar.subject = subject{1};
    %         covar.condition = trial.condition;

            left = squeeze(sub_envelope(:,1,:))*trialsub.Envelope.subband_weights(:);
            right = squeeze(sub_envelope(:,2,:))*trialsub.Envelope.subband_weights(:);
            if strcmpi(params.experimentName,'abs powerlaw experiment') 
                left = sign(left).*abs(left).^params.power; 
                right = sign(right).*abs(right).^params.power; 
            end
            audio = cat(2,left,right);

            [X, yleft, yright] = create_lagged_data(sub_eeg(:,params.channels),audio,trialsub.FileHeader.SampleRate,params.start,params.end,params.audioshifts,params.singleshift,params.decodershift);

            [y_att, y_unatt] = att_unatt(yleft, yright, trialsub.attended_ear);

            if(~allsublasso)
                do_lasso(params, X, y_att, sub_names{k});
            else
                if(k == 1)
                    Rxx = zeros(size(X,2));
                    Rxy = zeros(size(X,2),1);
                end
                Rxx = Rxx + X'*X;
                Rxy = Rxy + X'*y_att;
            end
        end
        if(allsublasso)
            do_lasso(params, Rxx, Rxy, 'all_subs');
        end
    end
%         save([params.covardir filesep 'allsub_covar.mat'],'all_sub_covar');
end



function [X, yleft, yright] = create_lagged_data(x, y, Fs, start, fin, audioshifts, singleshift, decodershift)
    
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
end

function [att, unatt] = att_unatt(left, right, attention)

    if strcmpi(attention,'left')||strcmpi(attention,'L')
        [att,unatt] = deal(left,right);
    elseif strcmpi(attention,'right')||strcmpi(attention,'R')
        [att,unatt] = deal(right,left);
    else
        error('attention is nor left nor right')
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
