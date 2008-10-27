require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  def test_create
    Product.create!(:name => 'Ruby', :price => 10)
    assert_not_nil Product.find_by_name('Ruby')
  end

  def test_update
    ruby = Product.create!(:name => 'Ruby', :price => 10)
    ruby.update_attribute :price, 15
    assert_equal 15, Product.find_by_name('Ruby').price
  end

  def test_desc
    ruby = Product.create!(:name => 'Ruby', :price => 10)
    assert_equal 'Ruby: 10', ruby.desc
  end

  def test_destroy
    ruby = Product.create!(:name => 'Ruby', :price => 10)
    ruby.destroy
    assert_nil Product.find_by_name('Ruby')
  end
end
