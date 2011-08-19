class Game
  include Mongoid::Document
  field :high_score, :type => Integer, :default => 500
  field :score, :type => Integer, :default => 0
  field :name
  belongs_to :person, :index => true, :validate => true
  has_one :video, :validate => false
  has_many :ratings, :as => :ratable, :dependent => :nullify
  accepts_nested_attributes_for :person
  cache

  validates_format_of :name, :without => /\$\$\$/

  attr_protected :_id

  set_callback(:initialize, :after) do |document|
    write_attribute("name", "Testing") unless name
  end
end
