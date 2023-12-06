require_relative './utils'
require 'faraday'

class SubscanApi
  APIS = %w[
    extrinsics extrinsic
    democracy_referendums democracy_referendum democracy_votes democracy_proposals democracy_proposal
    council_proposals council_proposal
    techcomm_proposals techcomm_proposal
    treasury_proposals treasury_proposal
  ].freeze

  def initialize(api_key, network_name)
    @network_name = network_name
    @conn = build_connection(api_key, network_name)
    APIS.each do |api|
      # def democracy_referendums(params = nil, &block)
      #   ...
      # end
      # democracy_referendums({ page: 0, row: 1 })
      # democracy_referendums do |referendums| ... end
      # democracy_referendums({status: 'completed'}) do |referendums| ... end
      # democracy_referendum( referendum_index: 3 )
      self.class.send(:define_method, api, lambda { |params = {}, &block|
        if block
          api_scan_each_page(api, params, &block)
        else
          api_scan(api, params)
        end
      })
    end
    self.class.send(:alias_method, :council_motions, :council_proposals)
    self.class.send(:alias_method, :council_motion, :council_proposal)
  end

  private

  def build_connection(api_key, network_name)
    Faraday.new(
      url: "https://#{network_name}.api.subscan.io",
      params: {},
      headers: {
        'Content-Type' => 'application/json',
        'X-API-Key' => api_key
      }
    )
  end

  # api:
  #  democracy_referendums
  #  extrinsics
  def api_scan(api, params)
    path =
      if api.include?('_')
        category, name = api.split('_')
        "/api/scan/#{category}/#{name}"
      else
        "/api/scan/#{api}"
      end

    response = @conn.post(path) do |req|
      req.body = params.to_json
    end
    result = JSON.parse(response.body)
    raise result['message'] unless result['data']

    result['data']
  end

  # api_scan_each_page('democracy_referendums') do |data_of_one_page, page_index|
  #   ...
  # end
  def api_scan_each_page(api, params = {}, &block)
    data = api_scan(api, params.merge({ page: 0, row: 1 }))
    raise 'not a subscan pageble api' unless data['count']

    each_page(data['count'], 25) do |page_index, page_size|
      page_data = api_scan(api, params.merge({ page: page_index, row: page_size }))
      page_data['list'] = [] if page_data['list'].nil?
      block.call(page_data, page_index)
    end
  end
end

# SUBSCAN_API_KEY = '72254f1ef82c4538a4d9a38c7eb1c3a0'
# NETWORK_NAME = 'darwinia'
# api = SubscanApi.new(SUBSCAN_API_KEY, NETWORK_NAME)
# # puts api.extrinsic(extrinsic_index: '148573-2')
# api.external_proposals
