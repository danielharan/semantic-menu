require 'rubygems'
require 'action_view'
require 'active_support'

class MenuItem
  include ActionView::Helpers::TagHelper,
          ActionView::Helpers::UrlHelper
  
  attr_accessor :children, :link
  
  def initialize(title, link, level, link_opts={})
    @title, @link, @level, @link_opts = title, link, level, link_opts
    @children = []
  end
  
  def add(title, link, link_opts={}, &block)
    returning(MenuItem.new(title, link, @level +1, link_opts)) do |adding|
      @children << adding
      yield adding if block_given?
    end
  end
  
  def to_s(controller=nil)
    @controller = controller
    content_tag :li, link_to(@title, @link, @link_opts) + child_output, ({:class => 'active'} if active?)
  end
  
  def level_class
    "menu_level_#{@level}"
  end
  
  def child_output
    children.empty? ? '' : content_tag(:ul, @children.collect(&:to_s).join, :class => level_class)
  end
  
  def active?
    children.any?(&:active?) || on_current_page?
  end
  
  def on_current_page?
    @controller && current_page?(@link)
  end
end

class SemanticMenu < MenuItem
  
  def initialize(opts={},&block)
    @opts       = {:class => 'menu'}.merge opts
    @level      = 0
    @children   = []
    
    yield self if block_given?
  end

  def to_s(controller=nil)
    @controller = controller
    content_tag(:ul, @children.collect(&:to_s).join, @opts)
  end
end
