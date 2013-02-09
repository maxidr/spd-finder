module ViewHelper
  def url(for_path)
    req.path + for_path[/\A\/?(.*)/, 1] # Extract / from the begining of for_path
  end
end
