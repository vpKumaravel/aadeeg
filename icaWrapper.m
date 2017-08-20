function [components, mm, artefactIdx] = icaWrapper(eeg,fs)
    eeg = transpose(eeg);
    [components, mm, ~] = fastica(eeg, 'maxNumIterations', 250);    
    artefactIdx = visualiseComponents(components, fs);
end

function artefactIdx = visualiseComponents(eeg, fs, ispca)
    if(nargin<3)
        ispca = 0;
    end
    if(ispca)
        eegplot(eeg, 'srate', fs, 'winlength', 1, 'dispchans', 32);
    else
        eegplot(eeg, 'srate', fs, 'winlength', 20, 'dispchans', 32);
    end
    fprintf('\n Components plotted');
    artefactIdx = input('\n Artefact components: ');
    close(gcf);
end