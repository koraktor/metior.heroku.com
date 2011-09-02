require 'octokit'

class Project

  include Mongoid::Document

  field :analyses, :type => Integer, :default => 0
  field :description, :type => String
  field :name, :type => String
  field :path, :type => String
  key :path

  belongs_to :user
  embeds_many :reports

  def clone
    `git clone --mirror git://github.com/#{path}.git #{repo_path}`
  end

  def cloned?
    File.exist? repo_path
  end

  def default_branch
    return @default_branch unless @default_branch.nil?

    @default_branch = repo.current_branch if File.exist? repo_path
  end

  def generate_report
    return false if repo.commits(default_branch).empty?

    self.analyses += 1

    branch_id = repo.id_for_ref default_branch
    report = reports.find_or_initialize_by :branch => default_branch
    if report.commit == branch_id
      save
      return true
    end
    report.commit = branch_id

    repo.instance_variable_set :@description, description
    repo.instance_variable_set :@name, name

    report.generate

    save
  end

  def pull
    `git --git-dir #{repo_path} remote update`
    logger.warn "#{path} could not be updated." unless $?.success?
  end

  def repo
    @repo ||= Metior::Git::Repository.new repo_path
  end

  def repo_path
    "#{Metior::Application.tmp_path}/repositories/#{path}.git"
  end

end
