def normal_item?(item)
  item.name != 'Sulfuras, Hand of Ragnaros'
end

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

  def age_quality
    @item.quality -= 1
  end

  def age
    if @item.name != 'Aged Brie' && @item.name != 'Backstage passes to a TAFKAL80ETC concert'
      age_quality
    else
      if @item.quality < 50
        @item.quality += 1
        if @item.name == 'Backstage passes to a TAFKAL80ETC concert'
          if @item.sell_in < 11
            if @item.quality < 50
              @item.quality += 1
            end
          end
          if @item.sell_in < 6
            if @item.quality < 50
              @item.quality += 1
            end
          end
        end
      end
    end

    reduce_age
    quality_after_expiration
  end

  private

  def quality_after_expiration
    if @item.sell_in.negative?
      if @item.name != "Aged Brie"
        if @item.name != 'Backstage passes to a TAFKAL80ETC concert'
          age_quality
        else
          @item.quality = 0
        end
      else
        if @item.quality < 50
          @item.quality += 1
        end
      end
    end
  end
end

class NormalProduct < Product
  def age_quality
    if @item.quality.positive?
      @item.quality -= 1
    end
  end

  def reduce_age
    @item.sell_in -= 1
  end
end

class ProductFactory
  def create(item)
    if normal_item?(item)
      NormalProduct.new item
    else
      LegendaryProduct.new item
    end
  end

  private

  def normal_item?(item)
    item.name != 'Sulfuras, Hand of Ragnaros'
  end
end

class LegendaryProduct < Product
  def age_quality
  end

  def reduce_age
  end
end