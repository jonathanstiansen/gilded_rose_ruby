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
class Product
  def initialize(item)
    @item = item
  end

  def age
    age_quality
    reduce_age
    quality_after_expiration
  end

  private

  def age_quality
    update_quality
  end

  def update_quality
    @item.quality -= 1
  end

  def quality_after_expiration
    if expired?
      update_quality
    end
  end

  def expired?
    @item.sell_in.negative?
  end
end

class NormalProduct < Product
  def update_quality
    if @item.quality.positive?
      @item.quality -= 1
    end
  end

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
    if normal_item?(item)
      create_normal_item(item)
    else
      LegendaryProduct.new item
    end
  end

  private

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
    if under_max_quality?
      @item.quality += 1
    end
  end
end

class LegendaryProduct < Product
  def update_quality
  end

  def reduce_age
  end
end

class NormalDemand
  def initialize(item)
    @item = item
  end

  def update_quality
    @item.quality += 1
  end
end

class DemandFactory
  def create(item)
    NormalDemand.new(item)
  end
end

class ConcertTickets < NormalProduct
  def update_quality
    if expired?
      @item.quality = 0
    elsif under_max_quality?
      DemandFactory.new.create(@item).update_quality
      if getting_closer?
        @item.quality += 1
      end
      if concert_imminent?
        @item.quality += 1
      end
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