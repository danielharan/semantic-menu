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
  
  def to_s
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
    current_page?(@link)
  end
  
  cattr_accessor :controller
  def controller # make it available to current_page? in UrlHelper
    @@controller
  end
end

class SemanticMenu < MenuItem
  
  def initialize(controller, opts={},&block)
   @@controller = controller
    @opts       = {:class => 'menu'}.merge opts
    @level      = 0
    @children   = []
    
    yield self if block_given?
  end

  def to_s
    content_tag(:ul, @children.collect(&:to_s).join, @opts)
  end
end

# Yep, monkey patch ActionView's UrlHelper
# All that changes here is s/@controller/controller
module ActionView
  module Helpers #:nodoc:
    module UrlHelper
      def current_page?(options)
        url_string = CGI.escapeHTML(url_for(options))
        request = controller.request
        if url_string =~ /^\w+:\/\//
          url_string == "#{request.protocol}#{request.host_with_port}#{request.request_uri}"
        else
          url_string == request.request_uri
        end
      end
    end
  end
end
