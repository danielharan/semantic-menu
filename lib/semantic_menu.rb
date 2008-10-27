require 'rubygems'
require 'action_view'
require 'active_support'

class MenuItem
  include ActionView::Helpers::TagHelper,
          ActionView::Helpers::UrlHelper
  
  attr_accessor :children, :link
  
  def initialize(title, link)
    @title, @link, @children = title, link, []
  end
  
  def add(title, link, &block)
    returning(MenuItem.new(title, link)) do |adding|
      @children << adding
      yield adding if block_given?
    end
  end
  
  def to_s
    opts = active? ? {:class => 'active'} : {}
    content_tag :li, link_to(@title, @link) + child_output, opts
  end
  
  def child_output
    children.empty? ? '' : content_tag(:ul, @children.collect(&:to_s).join)
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
   @@controller  = controller
    
    @opts       = {:class => 'menu'}.merge opts
    @opts[:class] = @opts[:class] + ' menu_level_1' unless @opts[:class].split(' ').include?('menu1')
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
