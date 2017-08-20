function mn_acc = plot_results(res_in,args,xlabels)
    if nargin<2
        args = 'decacc';
    end
    
    if strcmp(args,'decacc')
        markers = {'o','x','s','+','>','v','p'};
        colors = {'r','g','b','k','y','m'};
%         colors = colormap(parula(16));
        plots_no = numel(res_in);
        dec_per = [];
%         figure,
        for i = 1:plots_no
            color = cell2mat(colors(i));
            marker = markers{i};
            results = res_in(i);
            sub_len = length(results.correctdecodingpct);
            xplaces = 0.5:0.5:0.5*sub_len;
%             plot(xplaces,100*results.correctdecodingpct,marker,'MarkerFaceColor',color,'MarkerSize',(4+2*i));
%             hold on;
            dec_per = [dec_per,(100*results.correctdecodingpct)'];
%             mn_acc(i) = 100*mean(results.correctdecodingpct);
%             mn_pct(i,:) = mn_acc(:,ones(1,length(xplaces)));
        end
%         axis([xplaces(1)-0.5,xplaces(end)+0.5,30,100]);
%         ylabel('Decoding Accuracy(%)');
%         set(gca,'XTick',xplaces);
%         set(gca,'XTickLabel',results.subjects,'FontSize',11);
%         legend('Clusters Local Reference','Clusters Global Reference');
%         legend(str);
        figure,
%         str32gl = sprintf('32 clusters global');
%         str32lo = sprintf('32 clusters local');
%         str16gl = sprintf('16 clusters global');
%         str16lo = sprintf('16 clusters local');
%         str8gl = sprintf('8 clusters global');
%         str8lo = sprintf('8 clusters local');
%         xlabels = {str32gl, str32lo, str16gl, str16lo, str8gl, str8lo};
        boxplot(dec_per,'labels',xlabels);
%         title(sprintf('%d sec splits',split_len));
        ylabel('Corerct Decoding Accuracy(%)','FontSize',11);
    elseif strcmp(args,'artifact')
        methods = {'Baseline','ICA','STAR','MWF manual thr','STAR+MWF','MWF auto thr','QPCA','PCA','MWF auto thr'};
        % Scatter plot first
        plot_no = numel(res_in);
        improvement = [];
        for i = 1:plot_no
            results = res_in(i);
            improvement = [improvement,(100.*results.correctdecodingpct)'];
%             improvement = [improvement, results.grandmeanattendedcorr'];
%             if(i==1)
%                 baseline = results;
%                 continue;
%             end
%             improvement(:,i) = improvement(:,i) - improvement(:,1);
%             x = 100.*baseline.correctdecodingpct';
%             y = 100.*results.correctdecodingpct';
%             x = baseline.grandmeanattendedcorr';
%             y = results.grandmeanattendedcorr';
%             figure(i)
%             plot(x,y,'o','MarkerSize',8);
%             hold on;
%             x_line = (min(x):0.01:max(x));
%             y_line = x_line;
%             plot(x_line,y_line,'b');
%             hold off;
%             axis tight;
%             ylabel(sprintf('%s Correct Decoding Accuracy',methods{i}),'FontSize',12);
%             xlabel('Baseline Correct Decoding Accuracy','FontSize',12)
%             ylabel(sprintf('%s Attended Correlation',methods{i}),'FontSize',12);
%             xlabel('Baseline Attended Correlation','FontSize',12)
        end
        mean_imp = mean(improvement);
        median_imp = median(improvement);
%         pct_sub_improved = 100*(sum(improvement<0)/size(improvement,1));
        mean_imp(1) = 0;
        median_imp(1) = 0;
%         figure,
% %         plot(0:numel(pct_sub_improved)-1,pct_sub_improved,'b--o');
%         plot(0:numel(mean_imp)-1,mean_imp(1:end),'b--o');
%         hold on;
%         plot(0:numel(median_imp)-1,median_imp(1:end),'r--x');
%         hold off;
%         legend('Mean % improvement','Median % improvement');
%         legend('Mean attended correlation improvement','Median attended correlation improvement')
        plotted_methods = {'Baseline','ICA','STAR','MWF manual thr'};
        boxplot(improvement,'labels',plotted_methods);
%         set(gca,'Xtick',0:numel(mean_imp)-1);
%         set(gca,'XtickLabel',methods,'FontSize',12);
        xlabel('Methods');
        ylabel('Correct Decoding Accuracy');
    end
    
end