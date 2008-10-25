require 'rubygems'
require 'action_view'
require 'active_support'

class MenuItem
  include ActionView::Helpers::TagHelper,
          ActionView::Helpers::UrlHelper
  
  def initialize(title, link)
    @title, @link = title, link
  end
  
  def to_s
    opts = active? ? {:class => 'active'} : {}
    content_tag :li, link_to(@title, @link), opts
  end
  
  def active?
    current_page? @link
  end
  
  cattr_accessor :controller
  def controller # make it available to current_page? in UrlHelper
    @@controller
  end
end

class SemanticMenu < MenuItem
  
  attr_accessor :children
  def initialize(controller, opts={},&block)
   @@controller  = controller
    
    @opts       = {:class => 'menu'}.merge opts
    @children   = []
    yield self if block_given?
  end

  def to_s
    content_tag(:ul, @children.collect(&:to_s).join, @opts)
  end
  
  def add(title, link)
    @children << MenuItem.new(title, link)
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
