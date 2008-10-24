require 'rubygems'
require 'action_view'
require 'active_support'

class MenuItem
  include ActionView::Helpers::TagHelper,
          ActionView::Helpers::UrlHelper
  
  cattr_accessor :current_page
  
  def initialize(title, link)
    @title, @link = title, link
  end
  
  def to_s
    opts = active? ? {:class => 'active'} : {}
    content_tag :li, link_to(@title, @link), opts
  end
  
  def active?
    on_current_path?
  end
  
  # NB: not the same as current_page? which assumes options (rather than named route / string)
  # also, this takes a path only, not a full url. In a menu, links are expected to be relative.
  def on_current_path?
    @link == CGI.escapeHTML(@@current_page)
  end
end

class SemanticMenu < MenuItem
  
  attr_accessor :children
  def initialize(current_page, opts={},&block)
    @@current_page  = current_page
    
    @opts       = {:class => 'menu'}.merge opts
    @children   = []
    yield self
  end

  def to_s
    content_tag(:ul, @children.collect(&:to_s).join, @opts)
  end
  
  def add(title, link)
    @children << MenuItem.new(title, link)
  end
end