module Http
  def make_get_api_call(url)
    connection = Faraday.new(
      url: url,
      headers: { "Content-Type" => "application/json", "Authorization" => "Bearer" }
    ) do |faraday|
      faraday.response :raise_error
    end
    begin
      response = connection.get
      response.body
    rescue => e
      raise e
    end
  end
end
