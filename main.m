function main()
    rng(0);
    startMain = tic;
    assert(~ispc, 'Windows is not supported');
    
    params = artefact.defaultParams();
    params.cacheDir.base = fullfile(omsi.util.dirs('edisk'), 'cache/artefact');
    params.database = @artefact.database;
    
    params.reduceFcn = @omsi.chain.downsample_impl;
    params.artefactFcn = @omsi.chain.artefact_impl;
    params.envelopeFcn = @omsi.chain.calculateEnvelope_impl;
    params.filterFcn = @omsi.chain.filter_impl;
    params.downsampleFcn = @omsi.chain.downsample_impl;
    params.averageFcn = @omsi.chain.average_impl;
    params.verifyFcn = @omsi.chain.verify_impl;
    
    omsi.calculateSilences(params, params.samplerate2);
    
    cleanParams = params;
    cleanParams.cacheDir = fullfile(params.cacheDir.base, 'milan_clean');
    cleanParams.operations = {@(x)omsi.chain.readRaw(x, 'milan'), @omsi.chain.calculateEnvelope, @omsi.chain.reduce, @omsi.chain.artefact,  @omsi.chain.filter, @omsi.chain.downsample, @omsi.chain.eegAverage, @omsi.chain.verify};
    cleanParams.loadCaches = {NaN, 'original', 'envelope', 'reduce', 'artefact', 'filter', 'downsample', 'average'};
    cleanParams.saveCaches = {'original', 'envelope', 'reduce', 'artefact', 'filter', 'downsample', 'average', 'verify'};
    analyse(cleanParams);
    visualise(cleanParams);
    
    durationMain = toc(startMain);
    fprintf('I took %0.2f seconds\n', durationMain);
end

function analyse(params)
    assert(length(params.operations) == length(params.loadCaches));
    assert(length(params.saveCaches) == length(params.loadCaches));
    
    params.currentCache = 1;
    % params.operations{1}(params); % WARNING: put this in comment after running this once
    
    artefactTypes = enumeration('omsi.util.params.artefactParams');
    for artefactIdx = [0:2, 4:6, 8:9];%0:length(artefactTypes) % Iterate over all artefact suppression methods. WARNING: CCA and blanking are not finished
        params.artefact = omsi.util.params.artefactParams(artefactIdx);
        for idx = 2:length(params.operations)
            params.currentCache = idx;
            params.operations{idx}(params);
        end; clear idx;
    end; clear artefactIdx;
end

function visualise(params)
    loadCache = 'verify';
    saveCacheBase = 'graphs/verify';
    params.visualiseFcn = @(d)(visualiseFcn(params, d));
    corrs = nan(10, 0, 7);
    subjects = cell(0, 0);
    
    omsi.util.cacheLoop(params, params.visualiseFcn, params.cacheDir, loadCache, saveCacheBase, {0});
    
    [~, methods] = enumeration('omsi.util.params.artefactParams');
    relCorrs = corrs;
    for artefactIdx = size(relCorrs, 1):-1:1
        relCorrs(artefactIdx, :, :) = (relCorrs(artefactIdx, :, :) - relCorrs(1, :, :));
    end
    
    plotCorrs = corrs;
    plotCorrs = reshape(plotCorrs, 10, []);
    plotCorrs([4 8], :) = []; % CCA and blanking not finished
    
    relCorrs = reshape(relCorrs, 10, []);
    relCorrs([4 8], :) = []; % CCA and blanking not finished
    methods([4 8]) = [];
    corrs([4 8], :, :) = [];
    err = iqr(iqr(corrs, 2), 3);
    
    corrs([3 4 5 6 8],:,:) = [];
    relCorrs([3 4 5 6 8],:) = [];
    methods([3 4 5 6 8],:) = [];
    err = iqr(iqr(corrs, 2), 3);
    methods{1} = 'Baseline'
    
    figIdx = figure(); hold on;
    boxplot(zeros(size(relCorrs))','labels',methods, 'Colors', 'k');
    shadedErrorbar(1:3, median(median(corrs, 2), 3), err); %util
    ylim([0.1 0.225]);
    ylabel('Correlation','FontSize',12,'FontWeight','bold');
    title('Median correlation (black) & IQR correlation (gray)','FontSize',12,'FontWeight','bold');
    saveFig([omsi.util.dirs('edisk') '/cache/artefact/milan_clean/graphs/overall']); %util
    close(figIdx);
    
    figIdx = figure(); hold on;
    boxplot(transpose(relCorrs(2:3,:)),'labels',methods(2:3), 'Colors', 'k');
    ylabel('Correlation difference','FontSize',12,'FontWeight','bold');
    saveFig([omsi.util.dirs('edisk') '/cache/artefact/milan_clean/graphs/improvements']); %util
    close(figIdx);
    
    figIdx = figure(); hold on;
    boxplot(transpose(relCorrs),'labels',methods, 'Colors', 'k');
    shadedErrorbar(1:3, median(median(corrs, 2), 3), err); %util
    ylim([-0.1 0.25]);
    %figIdx.CurrentAxes.XTickLabel = methods;
    %hold on
    %plot(1:7,relCorrs,'.--','MarkerSize',10)
    ylabel('Correlation','FontSize',12,'FontWeight','bold');
    title('Median correlation (black), IQR correlation (gray), pairwise difference (boxplot)','FontSize',12,'FontWeight','bold');
    saveFig([omsi.util.dirs('edisk') '/cache/artefact/milan_clean/graphs/MWF_noICA']); %util
    close(figIdx);
    
    figIdx = figure(); hold on;
    plot(0:0.01:0.35, 0:0.01:0.35,'r','LineWidth',1);
    scatter(vectorize(corrs(1,:,:)), vectorize(corrs(2,:,:)),'k','LineWidth',1.1); %util
    xlim([0 0.35]); xlabel('Baseline correlation','FontSize',12,'FontWeight','bold');
    ylim([0 0.35]); ylabel('Correlation after ICA','FontSize',12,'FontWeight','bold');
    saveFig([omsi.util.dirs('edisk') '/cache/artefact/milan_clean/graphs/scatter_ICA']); %util
    close(figIdx);
    
    figIdx = figure(); hold on;
    plot(0:0.01:0.35, 0:0.01:0.35,'r','LineWidth',1);
    scatter(vectorize(corrs(1,:,:)), vectorize(corrs(7,:,:)),'k','LineWidth',1.1); %util
    xlim([0 0.35]); xlabel('Baseline correlation','FontSize',12,'FontWeight','bold');
    ylim([0 0.35]); ylabel('Correlation after MWF','FontSize',12,'FontWeight','bold');
    saveFig([omsi.util.dirs('edisk') '/cache/artefact/milan_clean/graphs/scatter_MWF']); %util
    close(figIdx);
    
    corrs([3 4 5 6],:,:) = [];
    relCorrs([3 4 5 6],:) = [];
    methods([3 4 5 6],:) = [];
    
    improv_median = median(relCorrs,2);
    improv_mean = mean(relCorrs,2);
    improv_pct = sum(relCorrs > 0, 2) *100 / size(relCorrs,2);
    
    figIdx = figure(); hold on;
    x = 1:3;
    [ax h1 h2] = plotyy([x', x'], [improv_median,improv_mean],x',improv_pct)
    set(ax,'XTickLabel',methods)
    ylabel(ax(1),'Median & Mean improvement [corr]')
    ylabel(ax(2),'Percentage improved [%]')
    set(h1(1),'Marker','o','LineStyle','--')
    set(h1(2),'Marker','s','LineStyle','--')
    set(h2,'Marker','^','LineStyle','--')
    legend('Median improvement','Mean improvement','% of correlations improved','Location','southeast')
    saveFig([omsi.util.dirs('edisk') '/cache/artefact/milan_clean/graphs/improvement']); %util
    close(figIdx);
    
    [bins,count] = hist(relCorrs(4,:),-0.045:0.01:0.105,'k')
    plot(count,bins,'k','LineWidth',2)
    [bins,count] = hist(relCorrs(2,:),-0.045:0.01:0.105,'k')
    hold on
    plot(count,bins,'r','LineWidth',2)
    legend('MWF   ', 'ICA   ')
    xlabel('Correlation improvement','FontSize',12,'FontWeight','bold');
    ylabel('Frequency','FontSize',12,'FontWeight','bold');
    plot([0,0],[0 30],'k:','LineWidth',2)


    %PER SUBJECT
    for h1 = 1:numel(subjects)/2
        subplot(4,2,h1)
        boxplot(transpose(relCorrs(:,h1:16:end)),'labels',methods);
        ylim([-0.15 0.1]);
        title(subjects{h1})
        saveFig([omsi.util.dirs('edisk') '/cache/artefact/milan_clean/graphs/persubject1']); %util
    end
    for h1 = 1:numel(subjects)/2
        subplot(4,2,h1)
        boxplot(transpose(relCorrs(:,(h1+8):16:end)),'labels',methods);
        ylim([-0.15 0.1]);
        title(subjects{h1+8})
        saveFig([omsi.util.dirs('edisk') '/cache/artefact/milan_clean/graphs/persubject2']); %util
    end
    
    for loadCache = 1:numel(subjects)/4
    subplot(4,1,loadCache)
    improv_median = median(relCorrs(:,(loadCache):16:end),2);
    improv_mean = mean(relCorrs(:,(loadCache):16:end),2);
    improv_pct = sum(relCorrs(:,(loadCache):16:end) > 0, 2) *100 / size(relCorrs(:,(loadCache):16:end),2);
    x = 1:8;
    [ax h1 h2] = plotyy([x', x'], [improv_median,improv_mean],x',improv_pct)
    set(ax,'XTickLabel',methods,'XLim',[1 8])
    set(ax(1),'Ylim',[-0.05 0.05])
    %ylabel(ax(1),'Median & Mean improvement [corr]')
    %ylabel(ax(2),'Percentage improved [%]')
    set(h1(1),'Marker','o','LineStyle','--')
    set(h1(2),'Marker','s','LineStyle','--')
    set(h2,'Marker','^','LineStyle','--')
    saveFig([omsi.util.dirs('home') '/cache/artefact/milan_clean/graphs/persubjectimpr1']);

    end
        for loadCache = 1:numel(subjects)/4
    subplot(4,1,loadCache)
    improv_median = median(relCorrs(:,(loadCache+4):16:end),2);
    improv_mean = mean(relCorrs(:,(loadCache+4):16:end),2);
    improv_pct = sum(relCorrs(:,(loadCache+4):16:end) > 0, 2) *100 / size(relCorrs(:,(loadCache+4):16:end),2);
    x = 1:8;
    [ax h1 h2] = plotyy([x', x'], [improv_median,improv_mean],x',improv_pct)
    set(ax,'XTickLabel',methods,'XLim',[1 8])
        set(ax(1),'Ylim',[-0.05 0.05])
    %ylabel(ax(1),'Median & Mean improvement [corr]')
    %ylabel(ax(2),'Percentage improved [%]')
    set(h1(1),'Marker','o','LineStyle','--')
    set(h1(2),'Marker','s','LineStyle','--')
    set(h2,'Marker','^','LineStyle','--')
    saveFig([omsi.util.dirs('edisk') '/cache/artefact/milan_clean/graphs/persubjectimpr2']);

        end
        for loadCache = 1:numel(subjects)/4
    subplot(4,1,loadCache)
    improv_median = median(relCorrs(:,(loadCache+8):16:end),2);
    improv_mean = mean(relCorrs(:,(loadCache+8):16:end),2);
    improv_pct = sum(relCorrs(:,(loadCache+8):16:end) > 0, 2) *100 / size(relCorrs(:,(loadCache+8):16:end),2);
    x = 1:8;
    [ax h1 h2] = plotyy([x', x'], [improv_median,improv_mean],x',improv_pct)
    set(ax,'XTickLabel',methods,'XLim',[1 8])
        set(ax(1),'Ylim',[-0.05 0.05])

    %ylabel(ax(1),'Median & Mean improvement [corr]')
    %ylabel(ax(2),'Percentage improved [%]')
    set(h1(1),'Marker','o','LineStyle','--')
    set(h1(2),'Marker','s','LineStyle','--')
    set(h2,'Marker','^','LineStyle','--')
    saveFig([omsi.util.dirs('edisk') '/cache/artefact/milan_clean/graphs/persubjectimpr3']);

        end
        for loadCache = 1:numel(subjects)/4
    subplot(4,1,loadCache)
    improv_median = median(relCorrs(:,(loadCache+12):16:end),2);
    improv_mean = mean(relCorrs(:,(loadCache+12):16:end),2);
    improv_pct = sum(relCorrs(:,(loadCache+12):16:end) > 0, 2) *100 / size(relCorrs(:,(loadCache+12):16:end),2);
    x = 1:8;
    [ax h1 h2] = plotyy([x', x'], [improv_median,improv_mean],x',improv_pct)
    set(ax,'XTickLabel',methods,'XLim',[1 8])
        set(ax(1),'Ylim',[-0.05 0.05])

    %ylabel(ax(1),'Median & Mean improvement [corr]')
    %ylabel(ax(2),'Percentage improved [%]')
    set(h1(1),'Marker','o','LineStyle','--')
    set(h1(2),'Marker','s','LineStyle','--')
    set(h2,'Marker','^','LineStyle','--')
    saveFig([omsi.util.dirs('edisk') '/cache/artefact/milan_clean/graphs/persubjectimpr4']);
    end
    
     
    function output = visualiseFcn(~, d)
        idx = strcmp(subjects, d.subject.name);
        if omsi.util.any(idx)
            subjectIdx = find(idx, 1);
        else
            subjects{end+1} = d.subject.name;
            subjectIdx = length(subjects);
        end; clear idx;
        
        
        for interval = 1:length(d.corrs{1}{1,1})
            corrs(uint32(d.params.artefact)+1, subjectIdx, interval) = median(d.corrs{1}{1,1}{interval});
        end; clear interval;
        output = false;
    end
end
