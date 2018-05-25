function pos = getFigPosition(ax)
  % creates a matrix of positions for a vector of axes

  pos = zeros(length(ax), 4);

  for ii = 1:length(ax)
    pos(ii,:) = ax(ii).Position;
  end

end
