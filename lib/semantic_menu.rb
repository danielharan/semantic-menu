require 'rubygems'
require 'action_view'
require 'active_support'

class MenuItem
  include ActionView::Helpers::TagHelper,
          ActionView::Helpers::UrlHelper
  
  attr_accessor :children, :link
  cattr_accessor :controller
  
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
  
  def to_s
    content_tag :li, SemanticMenu::Util.html_safe(link_to(@title, @link, @link_opts) + child_output), ({:class => 'active'} if active?)
  end
  
  def level_class
    "menu_level_#{@level}"
  end
  
  def child_output
    children.empty? ? '' : content_tag(:ul, SemanticMenu::Util.html_safe(@children.collect(&:to_s).join), :class => level_class)
  end
  
  def active?
    children.any?(&:active?) || on_current_page?
  end
  
  def on_current_page?
    @controller = @@controller # set it for current_page? defined in UrlHelper
    current_page?(@link)
  end
end

class SemanticMenu < MenuItem
  # Adapted from Formtastic::Util, which was in turn
  # Adapted from the rails3 compatibility shim in Haml 2.2
  module Util
    extend self
    ## Rails XSS Safety

    # Returns the given text, marked as being HTML-safe.
    # With older versions of the Rails XSS-safety mechanism,
    # this destructively modifies the HTML-safety of `text`.
    #
    # @param text [String]
    # @return [String] `text`, marked as HTML-safe
    def html_safe(text)
      return text if text.nil?
      return text.html_safe if defined?(ActiveSupport::SafeBuffer)
      return text.html_safe!
    end

    def rails_safe_buffer_class
      return ActionView::SafeBuffer if defined?(ActionView::SafeBuffer)
      ActiveSupport::SafeBuffer
    end
  end
  
  def initialize(controller, opts={},&block)
   @@controller = controller
    @opts       = {:class => 'menu'}.merge opts
    @level      = 0
    @children   = []
    
    yield self if block_given?
  end

  def to_s
    content_tag(:ul, SemanticMenu::Util.html_safe(@children.collect(&:to_s).join), @opts)
  end
end
