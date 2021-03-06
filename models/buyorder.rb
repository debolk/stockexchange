class BuyOrder < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :commodity
  has_one :transaction
  
  validates :amount, presence: true, numericality: { :greater_than => 0, :less_than_or_equal_to => 10}
  validates :price, presence: true, numericality: true
  validates :commodity, presence: true
  validates_uniqueness_of :commodity_id, :scope => [:phone, :state, :deleted_at], :unless => Proc.new {|bo| bo.deleted?}, :if => Proc.new {|bo| bo.state == 'open'}

  after_create :remove_lowest_order

  def commodity_name
    commodity.name
  end

  def total_value
    price*amount
  end

  def match!(sell_orders)
    update_attribute :state, :matched
    sell_orders.update_all state: :matched if sell_orders.present?
    Transaction.create do |t|
      t.commodity = commodity
      t.amount = amount
      t.buy_price = 0 # set after payment
      t.sell_price = sell_orders.sum(:price)
      t.save
    end
  end

  def self.open_orders
    order('price DESC').where('state = ?', 'open')
  end

  def notify_matched
    return unless /316\d{8}/ =~ phone
    total_price = (total_value/100.0)
    pretty_total = '%.2f' % total_price
    SMS::notify phone, "Je order staat klaar: #{amount} #{commodity.name} voor #{pretty_total} euro. Haal 'm snel op bij het loket."
  end

  def notify_overbid
    return unless /316\d{8}/ =~ phone
    pretty_min = '%.2f' % (commodity.min_price/100.0)
    pretty_price = '%.2f' % (price/100.0)
    SMS::notify phone, "Je order van: #{amount} #{commodity.name} voor #{pretty_price} euro per stuk is overboden, bied minstens #{pretty_min} euro per stuk."
  end

  def notify_close
    return unless /316\d{8}/ =~ phone
    pretty_price = '%.2f' % (price/100.0)
    SMS::notify phone, "De markt is gesloten, hierom is je order van #{amount} #{commodity.name} voor #{pretty_price} euro per stuk geannuleerd. Beankt voor het handelen."
  end

# Broadcast special states of the market to all clients

  private

  def remove_lowest_order
    Commodity.all.each do |commodity|
      to_be_destroyed = commodity.buy_orders.count - commodity.orderbook_size
      if to_be_destroyed > 0
        lowest = commodity.buy_orders.order('price asc').limit(to_be_destroyed)
        lowest.each do |bid|
          bid.notify_overbid
        end
        lowest.delete_all
      end
    end
  end

end
