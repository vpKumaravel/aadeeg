function eegNew = splitnodes(eeg, clusters, reref)
% Functions divides the eeg data into clusters number of nodes.
% Each node has number of channels referenced to one of the sensor in the
% node. The reference node is pre-defined based on an assumed sensor
% configuration
%
% Inputs:
% eeg - N*T eeg data. N - number of channels and T is time samples.
% clusters - Number of nodes to be divided into. (default 32) (possible
% values currently: 4, 8, 16, 32.
if(nargin==1 || (clusters~=4 && clusters ~=8 && clusters ~=16))
    clusters = 32;
end
   
switch clusters
    case 32
        node_order = [1,33; 2,7; 3,6; 4,5; 8,9; 10,13; 14,15; 16,17;...
                      18,21; 19,32; 31,20; 22,25; 23,24; 26,27; 28,29;...
                      11,47; 37,38; 34,36; 35,42; 41,40; 43,44; 45,50;...
                      12,48; 49,56; 39,46,;55,57; 53,54; 58,59; 61,60;...
                      62,64; 30,63; 51,52;
                      ];
        iter = 1;
        eegNew = zeros(32,size(eeg,2));
        while(iter <= size(node_order,1))
            if(reref)
                eegNew(iter,:) = eeg_sub_chnl(eeg,node_order(iter,1:end-1),node_order(iter,end));
            else
                eegNew(iter,:) = eeg(node_order(iter,1),:);
            end
            iter = iter+1;
        end
    case 16
        node_order = [33,4,39,37; 1,2,5,3; 6,7,10,9; 8,13,14,15;...
                      16,18,19,17; 22,24,25,23; 20,21,27,26; 28,29,31,30;...
                      34,35,40,36; 41,42,45,44; 43,50,51,52; 53,55,56,54;...
                      59,61,60,62; 57,56,64,63; 12,32,49,48; 11,38,46,47];
        eegNew = zeros(48,size(eeg,2));
        iter = 1;
        strt = 1;
        while(iter <= size(node_order,1))
            if(reref)
                eegNew(strt:strt+2,:) = eeg_sub_chnl(eeg,node_order(iter,1:end-1),node_order(iter,end));
            else
                eegNew(strt:strt+2,:) = eeg(node_order(iter,1:end-1),:);
            end
            strt = strt+3; 
            iter = iter+1;
        end
    case 8
        node_order = [1,2,3,5,7,8,9,6; 10,12,14,15,17,18,19,13; ...
                      16,21,22,24,25,26,27,23; 34,35,36,40,42,43,44,41;...
                      45,49,51,52,54,55,56,50; 35,58,60,61,62,63,64,59;...
                      4,11,32,37,39,46,47,38; 20,28,29,30,32,57,31,48];
        eegNew = zeros(56,size(eeg,2));
        iter = 1;
        strt = 1;
        
        while(iter <= size(node_order,1))
            if(reref)
                eegNew(strt:strt+6,:) = eeg_sub_chnl(eeg,node_order(iter,1:end-1),node_order(iter,end));
            else
                eegNew(strt:strt+6,:) = eeg(node_order(iter,1:end-1),:);
            end
            strt = strt+7; 
            iter = iter+1;
        end
end

end

function y = eeg_sub_chnl(eeg,ch_vec,j)
    ref_ch = eeg(j,:);
    y = eeg(ch_vec,:) - ref_ch(ones(length(ch_vec),1),:);
end
