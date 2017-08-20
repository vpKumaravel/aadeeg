function eeg = mwf_man_thr(eeg, fs, threshold)
        mask = zeros(1,size(eeg,2));
        mask(eeg(1,:)>threshold) = 1;
        tr_vec = diff(mask);
        tr_ind = find(tr_vec==-1);
        for i = 1:length(tr_ind)
            strt = tr_ind(i) - 0.2*fs;
            if(strt<=0)
                mask(1,1:tr_ind(i)) = 1;
            else
                mask(1,strt:tr_ind(i)) = 1;
            end
        end
        tr_ind = find(tr_vec==1);
        for i = 1:length(tr_ind)
            stp = tr_ind(i) + 0.2*fs;
            if(stp>=length(mask))
                mask(1,tr_ind(i):end) = 1;
            else
                mask(1,tr_ind(i):stp) = 1;
            end
        end
        user_rank = 4;
        p = filter_params('delay', 1, 'rank', 'user','user_rank',user_rank);

        y           = eeg;
        indx        = find(mask==1);
        if((indx(end)>size(y,2)) || (indx(end)<=0))
            disp('What??');
        end
        y           = y(:,1:indx(end));
        mask(indx(end)+1:end) = [];
        [w]         = filter_compute(y, mask, p);
        [v, d]      = filter_apply(y, w);

        eeg = [v,eeg(:,size(y,2)+1:end)];
        eeg = eeg';
end