function scatter_compare(res1, res2, labels)
    decacc1 = 100*(res1.correctdecodingpct);
    decacc2 = 100*(res2.correctdecodingpct);
    ymx_x = min(decacc1-5):100;
    ymx_y = ymx_x;
    figure,
    plot(decacc1, decacc2, 'bo');
    xlabel(labels{1});
    ylabel(labels{2});
    hold on;
    plot(ymx_x, ymx_y);
    axis tight
end