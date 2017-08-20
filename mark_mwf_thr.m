function threshold = mark_mwf_thr(eeg , fs)

%     eegplot(eeg, 'srate', fs, 'winlength', 20);
%     region = input('\n Artifact region to plot: ');
    region = [1,60];
    figure
    plot(eeg(1,(fs*region(1):fs*region(2))));
    threshold = input('\n Threshold for channel 1: ');
    close all;
    
end