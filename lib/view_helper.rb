module ViewHelper
  def url(for_path)
    #req.path + for_path[/\A\/?(.*)/, 1] # Extract / from the begining of for_path
    if req.path.end_with?("/")
      req.path + for_path[/\A\/?(.*)/, 1] # Extract / from the begining of for_path
    else
      req.path + ( for_path.start_with?("/") ? for_path : "/" + for_path
    end
  end
end
