require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  fixtures :products

  def test_list_products
    get :index
    assert_response :success
    assert_select 'tr', 2
  end
end
