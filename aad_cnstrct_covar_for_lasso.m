function aad_cnstrct_covar_for_lasso(params)
%         all_sub_covar = struct;
%         all_sub_covar.Rxx = [];
%         all_sub_covar.Ryy_att = [];
%         all_sub_covar.Ryy_unatt = [];
%         all_sub_covar.Rxy_att = [];
%         all_sub_covar.Rxy_unatt = [];
%         all_sub_covar.nOfSubs = 0;
    for subject = params.subjects
        %% list all preprocessed/split trials for a subject
        trialdir = fullfile(params.basedirectory , subject{1});
        
        trialfile = dir(fullfile(trialdir,['concat_trials' '.mat']));
    
        if(isempty(trialfile))
            warning('Concatenated trials not found for %s', subject{1});
        else
            load(fullfile(trialdir,['concat_trials' '.mat']));
        end
        
        params.channels = 1:length(trial.chnl_lst);
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
        
        [X, yleft, yright] = create_lagged_data(sub_eeg(:,params.channels),audio,trial.FileHeader.SampleRate,params.start,params.end,params.audioshifts,params.singleshift,params.decodershift);
        
        [y_att, y_unatt] = att_unatt(yleft, yright, trial.attended_ear);
        
        selected_channels = do_lasso(params, X, y_att);
        
        % Calculate 5 covar matrices (with lags).  x refers to eeg, y to audio,
%         [covar.Rxx,Ryy_left,Rxy_left,Ryy_right,Rxy_right] = covar_matrices(sub_eeg(:,params.channels),audio,trial.FileHeader.SampleRate,params.start,params.end,params.audioshifts,params.singleshift,params.decodershift);
%         [covar.Ryy_att,covar.Ryy_unatt] = deal(Ryy_left,Ryy_right);
%         [covar.Rxy_att,covar.Rxy_unatt] = deal(Rxy_left,Rxy_right);
%         
%         save([params.covardir filesep subject{1} '_covar.mat'],'covar');
%         
%         if(all_sub_covar.nOfSubs == 0)
%             all_sub_covar.Rxx = [all_sub_covar.Rxx, covar.Rxx];
%             all_sub_covar.Ryy_att = [all_sub_covar.Ryy_att, covar.Ryy_att];
%             all_sub_covar.Ryy_unatt = [all_sub_covar.Ryy_unatt, covar.Ryy_unatt];
%             all_sub_covar.Rxy_att = [all_sub_covar.Rxy_att, covar.Rxy_att];
%             all_sub_covar.Rxy_unatt = [all_sub_covar.Rxy_unatt, covar.Rxy_unatt];
%             all_sub_covar.nOfSubs = all_sub_covar.nOfSubs + 1;
%         else
%             all_sub_covar.Rxx = (all_sub_covar.Rxx + covar.Rxx)./2;
%             all_sub_covar.Ryy_att = (all_sub_covar.Ryy_att+ covar.Ryy_att)./2;
%             all_sub_covar.Ryy_unatt = (all_sub_covar.Ryy_unatt + covar.Ryy_unatt)./2;
%             all_sub_covar.Rxy_att = (all_sub_covar.Rxy_att + covar.Rxy_att)./2;
%             all_sub_covar.Rxy_unatt = (all_sub_covar.Rxy_unatt + covar.Rxy_unatt)./2;
%             all_sub_covar.nOfSubs = all_sub_covar.nOfSubs + 1;
%         end
% 
% 
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
