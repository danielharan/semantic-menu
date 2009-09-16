require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'action_controller' # grr, action_view now breaks without it
require 'semantic_menu'
require 'mocha'

class SemanticMenuTest < ActiveSupport::TestCase
  def test_menu_to_s
    assert_equal SemanticMenu.new(nil) {}.to_s, '<ul class="menu"></ul>'
  end
  
  def test_menu_item_to_s
    MenuItem.any_instance.stubs(:active?).returns(false)
    assert_equal '<li><a href="link">title</a></li>',
                 MenuItem.new("title", "link", 2).to_s
                 
  end
  
  def test_menu_item_passes_options_to_link
    MenuItem.any_instance.stubs(:active?).returns(false)
    assert_equal '<li><a href="link" class="button">title</a></li>',
                 MenuItem.new("title", "link", 2, :class => 'button').to_s
  end
  
  def test_menu_item_with_one_child
    MenuItem.any_instance.stubs(:active?).returns(false)
    assert_equal '<ul class="mymenu"><li><a href="link">title</a></li></ul>', default_menu.to_s
  end
  
  def test_menu_item_with_two_children
    MenuItem.any_instance.stubs(:active?).returns(false)
    menu = default_menu
    menu.add 'title2', 'link2'
    assert_equal '<ul class="mymenu">' + 
                    '<li><a href="link">title</a></li>' +
                    '<li><a href="link2">title2</a></li></ul>', menu.to_s
  end
  
  def test_menu_item_shows_active_if_on_current_page
    item = MenuItem.new("title", "link", 2)
    item.stubs(:active?).returns(true)
    assert_equal '<li class="active"><a href="link">title</a></li>', item.to_s
  end
  
  def test_nested_menu
    MenuItem.any_instance.stubs(:active?).returns(true)
    menu = SemanticMenu.new(nil) do |root|
      root.add 'top_level', 'some_page_path' do |link1|
        link1.add 'first_child', 'lower_page_path'
      end
    end
    expected = <<NESTED
<ul class="menu">
  <li class="active"><a href="some_page_path">top_level</a>
    <ul class="menu_level_1">
      <li class="active"><a href="lower_page_path">first_child</a></li>
    </ul>
  </li>
</ul>
NESTED
    assert_equal expected.gsub(/\n */, '').gsub(/\n/, ''), menu.to_s
  end
  
  def test_parent_is_active_when_any_child_is
    l1, l1_1, l1_2 = [nil] * 3
    menu = SemanticMenu.new(nil) do |root|
      l1 = root.add 'level1.1', 'link_1.1' do |link1|
        l1_1 = link1.add 'I-1', 'link_I-1'
        l1_2 = link1.add 'I-2', 'link_I-2-active'
      end
    end
    l1_1.stubs(:active?).returns(false)
    l1_2.stubs(:active?).returns(true)
    l1.stubs(:on_current_page?).returns(false)
    assert l1.active?
  end
  
  # def test_example_output_for_developer_laziness
  #  MenuItem.any_instance.stubs(:active?).returns(false)
  #  menu = SemanticMenu.new(nil, :class => 'top_level_nav') do |root|
  #    root.add "overview", "root_path"
  #    root.add "comments", "comments_path", :class => 'button' do |comments|
  #      comments.stubs(:active?).returns(true)
  #      comment_item = comments.add "My Comments", "my_comments_path"
  #      comment_item.stubs(:active?).returns(true)
  #      comments.add "Recent",      "recent_comments_path"
  #    end
  #  end
  #  puts menu
  # end
  
  protected
    def default_menu
      SemanticMenu.new nil, :class => 'mymenu' do |root|
        root.add 'title', 'link'
      end
    end
end
