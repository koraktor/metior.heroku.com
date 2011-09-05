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

  def available?
    !output.nil?
  end

  def last_error
    failures = Resque::Failure.all 0, Resque::Failure.count
    return if failures.empty?

    failures = [failures] unless failures.is_a? Array
    index = failures.index do |failure|
      failure['payload']['args'] == [project.path, branch]
    end
    return if index.nil?

    Resque::Failure.remove index unless index.nil?
    failures[index]['error']
  end

  def fresh?
    available? && age < 3600
  end

  def generate
    if project.repo.commits(branch).empty?
      $stderr.puts "---   No commits in #{branch}."
      raise "#{project.path} has no commits in the \"#{branch}\" branch."
    end

    project.analyses += 1
    self.analyses +=1
    self.last_update = Time.now

    branch_id = project.repo.id_for_ref branch
    if self.commit == branch_id
      project.save
      $stdout.puts '---   Up-to-date. No need to regenerate report.'
      return true
    end
    self.commit = branch_id

    project.repo.instance_variable_set :@description, project.description
    project.repo.instance_variable_set :@name, project.name

    self.output = {}
    output = Metior::Report::Heroku.new(project.repo, branch).render
    output.each do |name, view_output|
      self.output[name.to_s] = view_output
    end

    $stdout.puts "---   Report generated."

    project.save
    true
  end

  def queue!
    Resque.enqueue ReportJob, project.path, branch
  end

  def queued?
    jobs = Resque.peek :report, 0, Resque.size(:report)
    jobs = [jobs] unless jobs.is_a? Array
    jobs.any? { |job| job['args'] == [project.path, branch] }
  end

end
