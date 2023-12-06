require 'graphql/client'
require 'graphql/client/http'

# ['Council.Proposed', ...]
def build_events_query_clause(event_names)
  list_str = event_names.map do |event_name|
    "\"#{event_name}\""
  end.join(', ')
  "[#{list_str}]"
end

module Subsquid
  module Base
    def events(event_names, excluded_from_id = '', limit = 5)
      events_query_clause = build_events_query_clause(event_names)
      query_string = <<~GRAPHQL
        query($excluded_from_id: String, $limit: Int) {
          events(
            where: { id_gt: $excluded_from_id, name_in: #{events_query_clause}},
            limit: $limit,
            orderBy: id_ASC
          ) {
            id
            name
            args
            block {
              height
              timestamp
              block_hash: hash
              spec {
                spec_version: specVersion
              }
              events(where: {name_not_eq: "System.ExtrinsicSuccess"}) {
                id
                name
                args
              }
            }
            call {
              id
              name
              args
              origin
            }
          }
        }
      GRAPHQL

      # puts query_string

      remove_const(:GenericEventsQueryString) if const_defined?(:GenericEventsQueryString)
      const_set(:GenericEventsQueryString, query_string)

      remove_const(:GenericEventsQuery) if const_defined?(:GenericEventsQuery)
      const_set(:GenericEventsQuery, self::Client.parse(self::GenericEventsQueryString))

      result = self::Client.query(
        self::GenericEventsQuery,
        variables: { excluded_from_id:, limit: }
      )
      raise result.errors.messages.to_json if result.errors.messages.any?

      result.data.events.map do |event|
        extrinsic_block = event.call&.id&.split('-')&.[](0).to_i
        extrinsic_index_in_block = event.call&.id&.split('-')&.[](1).to_i
        {
          id: event.id,
          index: "#{event.block.height}-#{event.id.split('-')&.[](1).to_i}",
          name: event.name,
          args: event.args,
          block: {
            height: event.block.height,
            timestamp: event.block.timestamp,
            block_hash: event.block.block_hash,
            spec_version: event.block.spec.spec_version,
            events: event.block.events.map { |e| { name: e.name, args: e.args } }
          },
          call: event.call && {
            id: event.call.id,
            name: event.call.name,
            args: event.call.args,
            origin: event.call.origin,
            extrinsic_index: "#{extrinsic_block}-#{extrinsic_index_in_block}"
          }
        }
      end
    end
  end

  module Darwinia
    URL = 'https://darwinia.explorer.subsquid.io/graphql'
    HTTP = GraphQL::Client::HTTP.new(URL) do
      def headers(_context)
        { "User-Agent": 'G4 Client' }
      end
    end
    Schema = GraphQL::Client.load_schema(HTTP)
    Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

    extend Subsquid::Base
  end

  module Crab
    URL = 'https://crab.explorer.subsquid.io/graphql'
    HTTP = GraphQL::Client::HTTP.new(URL) do
      def headers(_context)
        { "User-Agent": 'G4 Client' }
      end
    end
    Schema = GraphQL::Client.load_schema(HTTP)
    Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

    extend Subsquid::Base
  end

  module Pangolin
    URL = 'https://pangolin.explorer.subsquid.io/graphql'
    HTTP = GraphQL::Client::HTTP.new(URL) do
      def headers(_context)
        { "User-Agent": 'G4 Client for Darwinia Pangolin' }
      end
    end
    Schema = GraphQL::Client.load_schema(HTTP)
    Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

    extend Subsquid::Base
  end
end
