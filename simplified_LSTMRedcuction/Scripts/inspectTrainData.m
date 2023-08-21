function inspectTrainData(trainData)
    ax1 = subplot(3,1,1);
    ax2 = subplot(3,1,2);
    ax3 = subplot(3,1,3);
    
    hold(ax1,'on')
    hold(ax2,'on')
    hold(ax3,'on')
    
    ylabel(ax1, 'Reference Torque');
    ylabel(ax2, 'Output Torque');
    ylabel(ax3, 'Output Velocity');
    
    for ix=1:length(trainData)
        tqref = trainData{ix}(1,:);
        tqout = trainData{ix}(2,:);
        wout = trainData{ix}(3,:);
    
        % plot resampled data
        plot(ax1, tqref)
        plot(ax2, tqout)
        plot(ax3, wout)
    
    end
    
    hold(ax1,'off')
    hold(ax2,'off')
    hold(ax3,'off')