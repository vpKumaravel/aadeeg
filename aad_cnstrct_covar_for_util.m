    function aad_cnstrct_covar_for_util(params)
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
        
        str = sprintf('%s_wide_%d_selected_channels.mat', subject{1}, params.lassochnum);
        load(fullfile('/home/abhijith/Documents/MATLAB/Lasso_Data/results/selected_channels',str));
        load('nearest_neighbours.mat','chnl_list');
        ch_selected = chnl_list(selected_channels,:);
        add_sens_num = 4;
        Mnew = zeros(64,64);
        Mnew_new = zeros(64,64);
        
        Mat = covar.chnl_lst;
        
        refs = unique(Mat(:,1));
        for rr = 1:length(refs)
            channel_details{rr,1} = refs(rr);
            r = find(Mat(:,1) == refs(rr));
            channel_details{rr,2} = Mat(r,2);
            channel_details{rr,3} = r;
        end
        add_sensor = 1;
        while(add_sensor<=add_sens_num)
            params.channels = [];
            if(add_sensor <= 4)
                for cc = 1:size(ch_selected,1)
                    c_id = find([channel_details{:,1}] == ch_selected(cc,1));
                    elec_nums = channel_details{c_id,2};
                    ch_nums = channel_details{c_id,3};
                    c_id = find(elec_nums == ch_selected(cc,2));
                    params.channels = [params.channels; ch_nums(c_id)];
                end
            end
            ch_ids = [];
            if(add_sensor == 1 || add_sensor == 3)
                for cc = 1:size(channel_details,1)
                    ch_ids = [ch_ids; channel_details{cc,3}];
                end
            elseif(add_sensor == 2)
                for cc = 1:size(channel_details,1)
                    [c_id, p_id] = find(ch_selected == channel_details{cc,1});
                    if(~isempty(c_id))
                        if(numel(c_id)<2)
                            if(p_id==1)
                                [cc_id,pp_id] = find(ch_selected == ch_selected(c_id,2));
                            else
                                [cc_id,pp_id] = find(ch_selected == ch_selected(c_id,1));
                            end
                            if(numel(cc_id)<2)
                                ch_ids = [ch_ids; channel_details{cc,3}];
                            end
                        end
                    end
                end
            else
                [c_count, edges] = histcounts(ch_selected, 1:64);
                ids = find(c_count == 2);
                c_id = find([channel_details{:,1}] == ids(1));
                ch_ids = [ch_ids; channel_details{c_id,3}];
            end
            
            Util = get_util(sub_eeg, covar, audio, ch_ids, params, trial);
            [val, ids] = sort(Util, 'descend');
            ch_selected = [covar.chnl_lst(ids(1),:); ch_selected];
            add_sensor = add_sensor + 1;
            if(add_sensor == 3)
                [N, edges] = histcounts(ch_selected, 1:64);
                ids = find(N == 2);
                for ii = 1:2
                    [r1, c1] = find(ch_selected == ids(ii));
                    [r11, c11] = find(c1 == 2);
                    if(~isempty(r11))
                        ch_selected(r1(r11),:) = circshift(ch_selected(r1(r11),:),1,2);    
                    end
                    c_id = find([channel_details{:,1}] == ids(ii));
                    channel_details_new{ii,1} = channel_details{c_id,1};
                    channel_details_new{ii,2} = channel_details{c_id,2};
                    channel_details_new{ii,3} = channel_details{c_id,3};
                end
                channel_details = channel_details_new;
            end
        end

        indx = sub2ind(size(Mnew), ch_selected(:,1), ch_selected(:,2));
        Mnew(indx) = 1;
        Mnew_new = Mnew;
        save(fullfile('/home/abhijith/Documents/MATLAB/Lasso_Data/results/selected_channels',str),'ch_selected','Mnew_new','-append');
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

function Util = get_util(sub_eeg, covar, audio, ch_ids, params, trial)
        
       for k =  1:length(ch_ids) 
            
            if(isempty(find(params.channels == ch_ids(k))))
                temp_channels = [ch_ids(k); params.channels];
            else
                continue;
            end
%           % Calculate 5 covar matrices (with lags).  x refers to eeg, y to audio,
            [covar.Rxx,Ryy_left,Rxy_left,Ryy_right,Rxy_right] = covar_matrices(sub_eeg(:,temp_channels),audio,trial.FileHeader.SampleRate,params.start,params.end,params.audioshifts,params.singleshift,params.decodershift);
            [covar.Ryy_att,covar.Ryy_unatt] = deal(Ryy_left,Ryy_right);
            [covar.Rxy_att,covar.Rxy_unatt] = deal(Rxy_left,Rxy_right);

%             save([params.covardir filesep subject{1} '_covar.mat'],'covar');

            %% attended or unattended decoder
            Rxx = covar.Rxx;
            if strcmpi(params.decoderused,'attended')
                [Rxy,Ryy] = deal(covar.Rxy_att,covar.Ryy_att);
            elseif strcmpi(params.decoderused,'unattended')
                [Rxy,Ryy] = deal(covar.Rxy_unatt,covar.Ryy_unatt);
            end

            %% regularization
            if strcmpi(params.regularizationmethod, 'smoothness')
                Mx = smoothregmatrix(size(Rxx));
                My = smoothregmatrix(size(Ryy));
            elseif strcmpi(params.regularizationmethod, 'min norm')
                Mx = eye(size(Rxx));
                My = eye(size(Ryy));
            else
                error('unknown params.regularizationmethod')
            end
            Rxx = Rxx + params.lambdax * mean(diag(Rxx))*Mx;
            Ryy = Ryy + params.lambday * mean(diag(Ryy))*My;
            
            noflags = length(Rxx)/length(temp_channels);
            Util(ch_ids(k)) = comp_util(Rxx, Rxy, noflags);
      end
end