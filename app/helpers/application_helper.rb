# encoding: utf-8

module ApplicationHelper

  def title
    "#{@title} – " unless @title.nil?
  end

end
