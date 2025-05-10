require "elasticsearch"
namespace :elastic do
  task reindex: [ :environment ] do
    puts Elasticsearch::VERSION
    client = Elasticsearch::Client.new(
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

    # Name of the index you want to drop
    index_name = "recipes_index" # Replace with your index name

    # Check if the index exists before attempting to delete it
    if client.indices.exists(index: index_name)
      puts "Index '#{index_name}' exists. Deleting..."

      client.indices.delete(index: index_name)
    end

    bulk_payload = []

    Recipe.all.each do |recipe|
      bulk_payload << { index: { _index: index_name, _id: recipe.id } }
      bulk_payload << recipe.as_json
    end
    client.bulk({ body: bulk_payload, refresh: true })

    response = client.search(
      index: index_name,
      body: {
        query: {
          match_all: {}
        },
        from: 0,
        size: 999
      }
    )
    puts response

    puts "Found #{response['hits']['total']['value']} documents total."

    # Process and display the documents
    response["hits"]["hits"].each_with_index do |hit, index|
      puts hit["_source"].inspect
    end
  end
end
