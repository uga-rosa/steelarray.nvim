local matrix = {}

function matrix.new(row, col, fill)
  fill = fill or 0
  local res = {}
  for i = 1, row do
    res[i] = {}
    for j = 1, col do
      res[i][j] = fill
    end
  end
  return res
end

return matrix
