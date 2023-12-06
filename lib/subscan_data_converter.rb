def call_params(params)
  params = params.nil? || params.strip == '' ? '[]' : params
  JSON.parse(params)
end

def preimage(_network, raw_preimage)
  Preimage.find_by(preimage_hash: raw_preimage['hash'])
  # Preimage.create_from_subscan_data!(network, raw_preimage)
end

def democracy_public_proposal(network, raw, block_timestamp: nil)
  raw['network'] = network
  raw['proposal_index'] = raw.delete('proposal_id')
  raw['preimage_hash'] = raw.delete('proposal_hash')
  raw['block_timestamp'] = block_timestamp if block_timestamp
  # call params & preimage
  # call_module, call_name, call_params are not needed in public proposal
  raw.delete('call_module')
  raw.delete('call_name')
  raw.delete('params')
  raw['preimage'] = preimage(network, raw['pre_image']) if raw['pre_image']
  raw.delete('pre_image')

  raw
end

# motion_hash → Democracy.external_propose_majority(preimage_hash)
def council_motion(network, raw)
  raw['network'] = network
  raw['motion_index'] = raw.delete('proposal_id')
  raw['motion_hash'] =  raw.delete('proposal_hash')
  # call params & preimage
  raw['call_params'] = call_params(raw.delete('params'))
  raw.delete('pre_image') # TODO: subscan has no value in this field

  raw
end

# proposal_hash → democracy.fastTrack(preimage_hash)
def techcomm_proposal(network, raw)
  raw['network'] = network
  raw['proposal_index'] = raw.delete('proposal_id')
  # call params & preimage
  raw['call_params'] = call_params(raw.delete('params'))
  if raw['pre_image']
    raw['preimage'] = preimage(network, raw['pre_image'])
    raw['preimage_hash'] = raw['pre_image']['hash']
    raw.delete('pre_image')
  end

  raw
end

def democracy_referendum(network, raw)
  raw['network'] = network
  if raw['pre_image']
    raw['preimage'] = preimage(network, raw['pre_image'])
    raw['preimage_hash'] = raw['pre_image']['hash']
    raw.delete('pre_image')
  end

  raw
end
