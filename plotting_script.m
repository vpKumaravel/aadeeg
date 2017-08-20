clc;
clear all;
close all;
exp = 3;
%%
switch exp
    case 1
        file_name = '/home/abhijith/Documents/MATLAB/Data/results/clustering_compare/grand_results.mat';
        load(file_name);
        res_in_60s = [aad_32_clus_gl;aad_32_clus_lo;aad_16_clus_gl;aad_16_clus_lo;aad_8_clus_gl;aad_8_clus_lo];
        res_in_30s = [aad_32_clus_30s_gl;aad_32_clus_30s_lo;aad_16_clus_30s_gl;aad_16_clus_30s_lo;aad_8_clus_30s_gl;aad_8_clus_30s_lo];
        res_in_20s = [aad_32_clus_20s_gl;aad_32_clus_20s_lo;aad_16_clus_20s_gl;aad_16_clus_20s_lo;aad_8_clus_20s_gl;aad_8_clus_20s_lo];

        plot_results(res_in_60s,'decacc',60);
        plot_results(res_in_30s,'decacc',30);
        plot_results(res_in_20s,'decacc',20);
    case 2 
        file_name = '/home/abhijith/Documents/MATLAB/Data/results/Art_rem_comparison/grand_results.mat';
        load(file_name);
%         res_in = [basic_aad_reref_30s;ica_aad_reref_30s;star_aad_reref_30s;mwf_man_thrs_aad_reref_30s];
%         res_in = [basic_aad_reref_20s;ica_aad_reref_20s;star_aad_reref_20s;mwf_man_thrs_aad_reref_20s];
        res_in = [basic_aad;ica_aad;star_aad;mwf_man_thrs_aad];
        plot_results(res_in, 'artifact');
    case 3
        load('/home/abhijith/Documents/MATLAB/Lasso_Data/results/LASSO_trial_3/grand results.mat');
        sub_len = length(results.correctdecodingpct);

        boxplot(100*results.correctdecodingpct);
        sub_sel_chn = zeros(sub_len,72);
%         xplaces = 0.5:0.5:0.5*sub_len;
        subnames = {'sub_02','sub_03','sub_04','sub_05','sub_06','sub_07','sub_08','sub_09'};
        for i = 2:sub_len+1
            for j = 1:72
                str = sprintf('0%d_subjectselected_channels_%d.mat',i,j);
                load(fullfile('/home/abhijith/Documents/MATLAB/Data/results/LASSO_trial_2',str));
                sub_sel_chn(i-1,j) = length(selected_channels);
            end
        end
        figure
        boxplot(sub_sel_chn','labels',subnames);
end