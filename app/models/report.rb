class Report

  include Mongoid::Document

  field :analyses, :type => Integer, :default => 0
  field :branch, :type => String
  field :commit, :type => String
  field :last_update, :type => Time
  field :output, :type => Hash
  key :branch

  embedded_in :project

  def age
    (Time.now - last_update).to_i
  end

  def fresh?
    !output.nil? && age < 3600
  end

  def generate
    repo = Metior::Git::Repository.new project.repo_path
    self.output = {}
    output = Metior::Report::Heroku.new(repo, branch).render
    output.each do |name, view_output|
      self.output[name.to_s] = view_output
    end

    self.analyses += 1
    self.last_update = Time.now
  end

end
