require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'action_controller' # grr, action_view now breaks without it
require 'semantic_menu'

class SemanticMenuTest < ActiveSupport::TestCase
  def test_menu_to_s
    assert_equal SemanticMenu.new(nil) {}.to_s, '<ul class="menu"></ul>'
  end
  
  def test_menu_item_to_s
    assert_equal MenuItem.new('title', 'link').to_s, '<li><a href="link">title</a></li>'
  end
  
  def test_menu_item_with_one_child
    assert_equal '<ul class="mymenu"><li><a href="link">title</a></li></ul>', default_menu.to_s
  end
  
  def test_menu_item_with_two_children
    menu = default_menu
    menu.add 'title2', 'link2'
    assert_equal '<ul class="mymenu"><li><a href="link">title</a></li>' +
                                    '<li><a href="link2">title2</a></li></ul>', menu.to_s
  end
  
  def test_menu_item_shows_active_if_on_current_page
    item = MenuItem.new("title", "link")
    item.stubs(:active?).returns(true)
    assert_equal '<li class="active"><a href="link">title</a></li>', item.to_s
  end
  
  protected
    def default_menu
      SemanticMenu.new nil, :class => 'mymenu' do |root|
        root.add 'title', 'link'
      end
    end
end
