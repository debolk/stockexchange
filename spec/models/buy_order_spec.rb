require 'spec_helper'

describe BuyOrder do
  it 'should not be valid without a price' do
    BuyOrder.new(amount: 10, price: nil).should be_invalid
  end
end
