# encoding: utf-8

module ApplicationHelper

  def title
    "#{@github_project} – " unless @github_project.nil?
  end

end
