clc;
close all;
clear all;
%% 
load('/home/abhijith/Documents/MATLAB/Data/results/AAD_clustering_compare/clus_16_32.mat');
results = [aad_16_clus_local;aad_16_clus_global];
plot_results(results);
title('16 nodes/clusters','FontSize',12)
results = [aad_32_clus_local;aad_32_clus_global];
plot_results(results);
title('32 nodes/clusters','FontSize',12);
load('/home/abhijith/Documents/MATLAB/Data/results/Art_rem_comparison/grand_results.mat');
res_in = [basic_aad;ica_aad;star_aad;qpca_aad;mwf_man_thrs_aad;mwf_auto_thrsh_aad];
plot_results(res_in,'artifact');