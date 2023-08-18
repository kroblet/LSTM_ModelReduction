function inspectPredData(trainData)
    ax2 = subplot(2,1,1);
    ax3 = subplot(2,1,2);
    
    hold(ax2,'on')
    hold(ax3,'on')
    
    ylabel(ax2, 'Output Torque');
    ylabel(ax3, 'Output Velocity');
    
    for ix=1:length(trainData)
        tqout = trainData{ix}(1,:);
        wout = trainData{ix}(2,:);
    
        % plot resampled data
        plot(ax2, tqout)
        plot(ax3, wout)
    
    end
    
    hold(ax2,'off')
    hold(ax3,'off')