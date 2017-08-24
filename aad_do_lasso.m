function aad_do_lasso(params)

        subjects = params.subjects;
        for subject = subjects
            
            covars = dir([params.covardir filesep subject{1} '*.mat']);
            covars = sort({covars(:).name});
            nOfCovars = length(covars);

            number_of_trials = nOfCovars;

            for i = 1:number_of_trials %nOfCovars

                load([params.covardir filesep covars{i}]) %loads covar variable
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
                
                
                %% construct decoders for LASSO channel selection
                decoder = rmfield(covar,{'Rxx','Rxy_att','Rxy_unatt','Ryy_att','Ryy_unatt'});
                decoder.decoderused = params.decoderused;
                
                decoder.audio = 1; %by default (changes in cca etc...)
                
                lambda = params.lassofactor;
                lamb_gr_2 = 0;
                lamb_ls_2 = 0;
                nofchannels = length(params.channels);
                noflags = length(Rxy)/length(params.channels);
                
                p = length(Rxy)/length(params.channels) *ones(length(params.channels),1); %each of the channels represents a group with length equal to number of delays
                chnl_lst = params.chnl_lst;
                rem_chnl_cnt = 0;
                flag = 1;
                selected_channels = [];
                while(length(selected_channels)~=params.lassochnum || flag == 1)
                    [output,~] = group_lasso(Rxx, Rxy, lambda, p, 1.0, 1.0); % AMN
                    flag = 0;
                    decoder.ignoredchannels = find(0==mean(reshape(output,noflags,nofchannels),1)); %which channels were set to zero
                    selected_channels = find(0~=mean(reshape(output,noflags,nofchannels),1)); %which channels were set to zero
            
        
                    if(length(selected_channels)>params.lassochnum)
                        lamb_gr_2 = lambda;
                        if(~lamb_ls_2)
                            lambda = lambda*2;
                        else
                            lambda = lamb_gr_2 + ((lamb_ls_2 - lamb_gr_2)/2);
                        end
                    else
                        if(lamb_gr_2)
                            lamb_ls_2 = lambda;
                            lambda = lamb_gr_2 + ((lamb_ls_2 - lamb_gr_2)/2);
                        end
                    end
                    
                    [output,~] = group_lasso(Rxx, Rxy, lambda, p, 1.0, 1.0); % AMN
                    selected_channels = find(0~=mean(reshape(output,noflags,nofchannels),1)); %which channels were set to zero
                    fprintf('\nLambda = %3.2f', lambda);
                    
                    if(length(selected_channels)==params.lassochnum)
                        ch_selected = chnl_lst(selected_channels,:);
                        [~, uniq_chnls] = unique(ch_selected);
                        ch_repeated = ch_selected;
                        ch_repeated(uniq_chnls) = [];
                        if(length(uniq_chnls)~=(params.lassochnum*2))
%                             for indx = 1:1
                                [r ,c] = find(ch_selected==ch_repeated(end));
                                if(~isempty(r))
                                    row_ids = find(ismember(chnl_lst, ch_selected(r(1),:), 'rows'));
                                    strt = ((row_ids-1)*noflags)+1;
                                    stp = row_ids*noflags;
                                    Rxx(strt:stp,:) = [];
                                    Rxx(:,strt:stp) = [];
                                    Rxy(strt:stp) = [];
                                    
                                    fprintf('\nRemoved channel = %d. Number of channels removed = %d', selected_channels(selected_channels == row_ids), rem_chnl_cnt);
                                    
                                    selected_channels(selected_channels == row_ids) = [];
                                    chnl_lst(row_ids,:) = [];
                                    nofchannels = size(chnl_lst,1);
                                    p = length(Rxy)/nofchannels *ones(nofchannels,1); %each of the channels represents a group with length equal to number of delays
                                    
                                    rem_chnl_cnt = rem_chnl_cnt + 1;
                                    lamb_gr_2 = 0;
                                    lamb_ls_2 = 0;
                                    lambda = params.lassofactor;
                                end
%                             end
                        end
                    end
                end
                    
  
                decoder.eeg = output;
                
                save([params.resultsdir filesep cell2mat(subject) sprintf('_wide_%d_selected_channels.mat',params.lassochnum)],'selected_channels','lambda');
            end
        end
end