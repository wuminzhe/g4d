class SubsquidEvent
  module Democracy
    module Voted
      class << self
        def handle(event)
          referendum = DemocracyReferendum.find_by(network: event.network, referendum_index: event.args['refIndex'])
          raise 'DemocracyReferendum not found' if referendum.nil?

          vote = {
            account: event.args['voter'],
            vote: Vote.decode(event.args['vote']['vote']),
            balance: event.args['vote']['balance'].to_i,
            voted_at: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index
          }
          # tokens * conviction_multiplier
          votes_amount = (BigDecimal(vote[:balance]) * (vote[:vote][:conviction].zero? ? 0.1 : vote[:vote][:conviction])).to_i
          if vote[:vote][:aye]
            vote[:aye_votes_amount] = votes_amount
          else
            vote[:nay_votes_amount] = votes_amount
          end

          # TODO: turnout                :string
          referendum.update(
            updated_block: event.block_height,
            aye_amount: referendum.aye_amount.to_i + (vote[:vote][:aye] ? vote[:aye_votes_amount] : 0),
            nay_amount: referendum.nay_amount.to_i + (vote[:vote][:aye] ? 0 : vote[:nay_votes_amount]),
            aye_without_conviction: referendum.aye_without_conviction.to_i + (vote[:vote][:aye] ? vote[:balance] : 0),
            nay_without_conviction: referendum.nay_without_conviction.to_i + (vote[:vote][:aye] ? 0 : vote[:balance]),
            votes: referendum.votes.push(vote)
          )
          #  delay                  :integer
          #  end                    :integer
          #  executed_success       :boolean
          referendum
        end
      end
    end
  end
end
