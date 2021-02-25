# frozen_string_literal: true

def update_quality(items)
  items.each do |item|
    ProductFactory.new.create(item).age
  end
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]
class NormalQuality
  def initialize(item)
    @item = item
  end

  def age
    if @item.quality.positive?
      @item.quality -= 1
    end
  end
end

class QualityFactory
  def initialize(item)
    @item = item
  end

  def create
    NormalQuality.new(@item)
  end
end

class Product
  def initialize(item)
    @item = item
  end

  def age
    update_quality
    reduce_age
    quality_after_expiration
  end

  private

  def update_quality
    QualityFactory.new(@item).create.age
  end

  def quality_after_expiration
    update_quality if expired?
  end

  def expired?
    @item.sell_in.negative?
  end
end

class NormalProduct < Product

  def reduce_age
    @item.sell_in -= 1
  end

  private

  def under_max_quality?
    @item.quality < 50
  end
end

class ProductFactory
  def create(item)
    if !normal_item?(item)
      LegendaryProduct.new item
    else
      create_normal_item(item)
    end
  end

  private

  def conjured_item?(item)
    item.name == 'Conjured Mana Cake'
  end

  def create_normal_item(item)
    case item.name
    when 'Aged Brie'
      Brie.new item
    when 'Backstage passes to a TAFKAL80ETC concert'
      ConcertTickets.new item
    else
      NormalProduct.new item
    end
  end

  def normal_item?(item)
    item.name != 'Sulfuras, Hand of Ragnaros'
  end
end

class Brie < NormalProduct
  def update_quality
    @item.quality += 1 if under_max_quality?
  end
end

class LegendaryProduct < Product
  def update_quality; end

  def reduce_age; end
end

class NormalDemand
  def initialize(item)
    @item = item
  end

  def update_quality
    @item.quality += 1
  end
end

class RisingDemand < NormalDemand
  def update_quality
    @item.quality += 2
  end
end

class ImminentDemand < NormalDemand
  def update_quality
    @item.quality += 3
  end
end

class DemandFactory
  def initialize(item)
    @item = item
  end

  def create
    if concert_imminent?
      ImminentDemand.new(@item)
    elsif getting_closer?
      RisingDemand.new(@item)
    else
      NormalDemand.new(@item)
    end
  end

  private

  def getting_closer?
    @item.sell_in < 11
  end

  def concert_imminent?
    @item.sell_in < 6
  end
end

class ConcertTickets < NormalProduct
  def update_quality
    if expired?
      @item.quality = 0
    elsif under_max_quality?
      DemandFactory.new(@item).create.update_quality
    end
  end

  private

  def getting_closer?
    @item.sell_in < 11
  end

  def concert_imminent?
    @item.sell_in < 6
  end
end
