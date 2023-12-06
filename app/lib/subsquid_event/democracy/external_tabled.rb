class SubsquidEvent
  module Democracy
    module ExternalTabled
      class << self
        # crab:
        # {
        #   "id": "0000705600-000502-ba74b",
        #   "name": "Democracy.ExternalTabled",
        #   "args": null,
        #   "call": null,
        # }
        def handle(event)
          # find the last DemocracyExternalProposal
          external_proposal =
            DemocracyExternalProposal.where(network: event.network).order(created_block: :desc).limit(1).first
          raise 'DemocracyExternalProposal not found' if external_proposal.nil?

          timeline_step = {
            event_index: event.index,
            timestamp: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index,
            status: 'external_tabled'
          }
          external_proposal.update(
            status: 'external_tabled',
            updated_block: event.block_height,
            timeline: external_proposal.timeline.push(timeline_step)
          )
        end
      end
    end
  end
end
