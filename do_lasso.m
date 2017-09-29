function [selected_channels, lambda] = do_lasso(params, A, b, sub_name)
        load('nearest_neighbours.mat');
       
        nofchannels = length(params.channels);
        noflags = size(A,2)/length(params.channels);
        lambda = params.lassofactor;
        lamb_gr_2 = 0;
        lamb_ls_2 = 0;


        p11 = size(A,2)/length(params.channels) *ones(length(params.channels),1); %each of the channels represents a group with length equal to number of delays

        rem_chnl_cnt = 1;
        flag = 1;
        selected_channels = [];
        col_sel = ones(1,size(A,2));
        node_ids = ones(1,size(A,2)/noflags);
        node_ids = logical(node_ids);        
        while(length(selected_channels)~=params.lassochnum || flag == 1)
            chnl_lst = chnl_list(node_ids,:);
            fprintf('Lambda = %3.2f of %s\n', lambda, sub_name);
            Abar = A(:,logical(col_sel));
            [output,~] = group_lasso(Abar, b, lambda, p11, 1.0, 1.0); % AMN

            flag = 0;
            decoder.ignoredchannels = find(0==mean(reshape(output,noflags,nofchannels),1)); %which channels were set to zero
            selected_channels = find(0~=mean(reshape(output,noflags,nofchannels),1)); %which channels were set to zero
            fprintf('For lambda =  %3.2f no. of selected channels = %d  \n', lambda, length(selected_channels));

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

            if(length(selected_channels)==params.lassochnum)
                ch_selected = chnl_lst(selected_channels,:)
                [~, uniq_chnls] = unique(ch_selected);
                ch_repeated = ch_selected;
                ch_repeated(uniq_chnls) = [];
                if(length(uniq_chnls)~=(params.lassochnum*2))

                    %% Find in channel list, the repeated electrode's channel to be removed  
                    [r, c] = find(ch_selected == ch_repeated(end));
                    ch_to_be_removed = ch_selected(r(end),:);
                    row_id = find(ismember(chnl_lst,ch_to_be_removed, 'rows'));
                    col_sel((row_id-1)*noflags+1:row_id*noflags) = 0;
                    node_ids(row_id) = false;
                    flag = 1; 
                    %% Find the unique channels' electrodes' other combinations
                    
                    %Find unique channels first
                    inds = [];
                    for i = 1:length(ch_repeated)
                        [r, c] = find(ch_selected == ch_repeated(i))
                        inds = [inds;r]; 
                    end
                    inds = unique(inds);
                    ch_selected(inds,:) = [];
                    % Remove unique electrodes' all channels
                    if(~isempty(ch_selected))
                        for i = 1:numel(ch_selected)
                            [r,c] = find(chnl_lst == ch_selected(i));
                            for k = 1:length(r)
                                col_sel((r(k)-1)*noflags+1:r(k)*noflags) = 0;
                                node_ids(r(k)) = false;
                            end
                        end
                    % Keep unique electrode pairs channels
                        for i = 1:size(ch_selected,1)
                            row_id = find(ismember(chnl_lst,ch_selected(i,:), 'rows'));
                            col_sel((row_id-1)*noflags+1:row_id*noflags) = 1;
                            node_ids(row_id) = true;
                        end
                    end
                    Abar = A(:, logical(col_sel));
                    nofchannels = sum(col_sel == 1)/noflags;
                    p11 = size(Abar,2)/nofchannels *ones(nofchannels,1); %each of the channels represents a group with length equal to number of delays
% % 
                    rem_chnl_cnt = rem_chnl_cnt + 1;
                    lamb_gr_2 = lamb_gr_2 - (0.4*lamb_gr_2);
                    lamb_ls_2 = lamb_ls_2 + (0.4*lamb_ls_2);
                    lambda = params.lassofactor;
%                         end
                else
                    fprintf('LASSO done for %s!', sub_name);
                    save([params.basedirectory filesep 'results/selected_channels' filesep sub_name sprintf('_wide_%d_selected_channels.mat',params.lassochnum)],'ch_selected','lambda');
                end
            end
        end
end