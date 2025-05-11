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

  def document_exist?(index, id)
    @elastic_client.exists(
      index: index,
      id: id,
    )
  end

  def save_document(index, id, document)
    @elastic_client.create(
      index: index,
      id: id,
      body: document
    )
  end

  def delete_document(index, id)
    @elastic_client.delete(
      index: index,
      id: id
    )
  end

  def update_document(index, id, document)
    @elastic_client.update(
      index: index,
      id: id,
      body: document
    )
  end
end
