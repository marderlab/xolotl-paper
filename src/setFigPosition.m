function pos = setFigPosition(ax, pos)
  % sets axis positions to a matrix of positions

  for ii = 1:length(ax)
    ax(ii).Position = pos(ii, :);
  end

end
