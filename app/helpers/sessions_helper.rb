module SessionsHelper
  def proceed_to_url
    # "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
    "#{request.protocol}#{request.host_with_port}/login"
  end
end
