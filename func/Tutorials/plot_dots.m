
figure; scatter(ProtoTable.ActualDots_xy(:,1), ProtoTable.ActualDots_xy(:,2), 'k');axis equal;
ax=gca;
hold on; plot([mean(ax.XLim) mean(ax.XLim)], [ax.YLim(1) ax.YLim(2)], 'k');
hold on; plot([ax.XLim(1) ax.XLim(2)], [mean(ax.YLim) mean(ax.YLim)], 'k');
hold on; scatter(ProtoTable.prototypeXY(:,1), ProtoTable.prototypeXY(:,2), 'g');

hold on; scatter(ProtoTable.ResponseDots_xy(idx,1), ProtoTable.ResponseDots_xy(idx,2), 'r');


hold on; scatter(cur_mx, cur_my, 'b');