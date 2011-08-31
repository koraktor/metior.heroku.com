class User

  include Mongoid::Document

  field :name, :type => String
  key :name

  has_many :projects

  validates_presence_of   :name
  validates_uniqueness_of :name

end
