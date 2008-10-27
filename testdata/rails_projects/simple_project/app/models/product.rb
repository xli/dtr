class Product < ActiveRecord::Base
  def desc
    "#{name}: #{price}"
  end
end
