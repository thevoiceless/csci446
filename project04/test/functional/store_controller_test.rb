require 'test_helper'

class StoreControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    # Looks for an element named 'a' contained in an element with an id of
    # 'side' contained within an element with an id of 'columns', verifies
    # that there are a minimum of 4 such elements
    assert_select('#columns #side a', minimum: 4)
    # Verify that all products are displayed
    assert_select('#main .entry', 3)
    assert_select('h3', 'Programming Ruby 1.9')
    assert_select('.price', /\$[,\d]+\.\d\d/)
  end

end
