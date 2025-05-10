require "elasticsearch"

class ElasticSearchService
  def initialize
    @elastic_client = Elasticsearch::Client.new(
      hosts: [
        {
          host: "localhost",
          port: 9200
        }
      ],
      transport_options: {
        ssl: { verify: false } # Only use in development!
      }
    )
  end

  def fetch_documents_from_index(index, query)
    @elastic_client.search(
      index: index,
      body: {
        query: {
          query_string: {
            query: query,
            default_field: "*"
          }
        }
      }
    )
  end
end
