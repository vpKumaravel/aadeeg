clc;
clear all;
close all;
%% Modify trial variables to original
p = aad_getDefaultParams('Mod Data');
new_path = '/home/abhijith/Documents/MATLAB/Data';
k = 1;

for subject = p.subjects
    if(k==2)
        break;
    end
    path_to_data = fullfile(p.basedirectory,subject{1});
    for i = 1:20
        trial_num = i;
        if(i<10)
            file_name = sprintf('trial 00%d.mat',trial_num);
        else
            file_name = sprintf('trial 0%d.mat',trial_num);
        end
        load(fullfile(path_to_data,file_name));
        
        if(isfield(trial.RawData,'EegDataArtRem'))
            trial.RawData = rmfield(trial.RawData,'EegDataArtRem');
        end
        str = 'EegDataArtRemOneW';
        if(isfield(trial.RawData,str))
            trial.RawData = rmfield(trial.RawData,str);
        end
        str = 'EegDataAutoThrArtRem';
        if(isfield(trial.RawData,str))
            trial.RawData = rmfield(trial.RawData,str);
        end
        str = 'EegStarMWF';
        if(isfield(trial.RawData,str))
            trial.RawData = rmfield(trial.RawData,str);
        end
        str = 'EegDataQPCA';
        if(isfield(trial.RawData,str))
            trial.RawData = rmfield(trial.RawData,str);
        end
        if(isfield(trial.RawData,'EegDataICA'))
            trial.RawData = rmfield(trial.RawData,'EegDataICA');
        end
        if(isfield(trial.RawData,'EegStar'))
            trial.RawData = rmfield(trial.RawData,'EegStar');
        end
        if(isfield(trial.RawData,'EegDataAutoThrArtRem'))
            trial.RawData = rmfield(trial.RawData,'EegDataAutoThrArtRem');
        end
        if(isfield(trial.RawData,'EegDataCluster32'))
            trial.RawData = rmfield(trial.RawData,'EegDataCluster32');
        end
        if(isfield(trial.RawData,'EegDataCluster16'))
            trial.RawData = rmfield(trial.RawData,'EegDataCluster16');
        end
        if(isfield(trial.RawData,'EegDataCluster8'))
            trial.RawData = rmfield(trial.RawData,'EegDataCluster8');
        end
        
%         if(isfield(trial.RawData,'EegDataOrig'))
%             trial.RawData.EegData = trial.RawData.EegDataOrig;
%             trial.RawData = rmfield(trial.RawData,'EegDataOrig');
%         end
        save(fullfile(new_path,subject{1},file_name),'trial');
        fprintf('\nTrial %d of subject - %s done!',trial_num,subject{1});
    end
    k = k+1;
end