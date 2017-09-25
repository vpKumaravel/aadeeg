function [selected_channels, lambda] = do_lasso(params, A, b, sub_name)
        load('nearest_neighbours.mat');
        chnl_lst = chnl_list;
        nofchannels = length(params.channels);
        noflags = size(A,2)/length(params.channels);
        lambda = params.lassofactor;
        lamb_gr_2 = 0;
        lamb_ls_2 = 0;


        p11 = size(A,2)/length(params.channels) *ones(length(params.channels),1); %each of the channels represents a group with length equal to number of delays

        rem_chnl_cnt = 1;
        flag = 1;
        selected_channels = [];
        while(length(selected_channels)~=params.lassochnum || flag == 1)
            fprintf('\nLambda = %3.2f', lambda);
            [output,~] = group_lasso(A, b, lambda, p11, 1.0, 1.0); % AMN

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
            elseif(length(selected_channels)<params.lassochnum)
                if(lamb_gr_2)
                    lamb_ls_2 = lambda;
                    lambda = lamb_gr_2 + ((lamb_ls_2 - lamb_gr_2)/2);
                end
            end

%             [output,~] = group_lasso(A, b, lambda, p11, 1.0, 1.0); % AMN
%             selected_channels = find(0~=mean(reshape(output,noflags,nofchannels),1)); %which channels were set to zero
           

            if(length(selected_channels)==params.lassochnum)
                ch_selected = chnl_lst(selected_channels,:)
                [~, uniq_chnls] = unique(ch_selected);
                ch_repeated = ch_selected;
                ch_repeated(uniq_chnls) = [];
                if(length(uniq_chnls)~=(params.lassochnum*2))
                        [r ,c] = find(ch_selected==ch_repeated(end));
                        if(~isempty(r))
                            row_ids = find(ismember(chnl_lst, ch_selected(r(1),:), 'rows'));
                            strt = ((row_ids-1)*noflags)+1;
                            stp = row_ids*noflags;
%                             A(strt:stp,:) = [];
                            A(:,strt:stp) = [];
%                             b(strt:stp) = [];

                            fprintf('\nRemoved channel = %d. Number of channels removed = %d', selected_channels(selected_channels == row_ids), rem_chnl_cnt);

                            selected_channels(selected_channels == row_ids) = [];
                            chnl_lst(row_ids,:) = [];
                            nofchannels = size(chnl_lst,1);
                            p11 = size(A,2)/nofchannels *ones(nofchannels,1); %each of the channels represents a group with length equal to number of delays

                            rem_chnl_cnt = rem_chnl_cnt + 1;
                            lamb_gr_2 = lamb_gr_2 - (0.2*lamb_gr_2);
                            lamb_ls_2 = lamb_ls_2 + (0.2*lamb_ls_2);
                            lambda = params.lassofactor;
                        end
                else
                    disp('LASSO done!');
                    save([params.resultsdir filesep sub_name sprintf('_wide_%d_selected_channels.mat',params.lassochnum)],'selected_channels','lambda');
                end
            end
        end
end