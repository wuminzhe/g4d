module Vote
  def self.decode(value)
    { aye: (value & 0b1000_0000) == 0b1000_0000, conviction: value & 0b0111_1111 }
  end

  def self.decode2(value)
    [0b10000000, 0].each do |vote|
      7.times do |conviction|
        return { aye: vote == 0b10000000, conviction: } if value == conviction | vote
      end
    end
  end
end
