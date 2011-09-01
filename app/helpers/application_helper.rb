# encoding: utf-8

module ApplicationHelper

  def title
    "#{@github_project} – " unless @github_project.nil?
  end

  def link_or_text(title, link_to)
    link_to_unless_current title, link_to do
      "<span>#{title}</span>".html_safe
    end
  end

end
