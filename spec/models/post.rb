class Tag
  include Mongoid::Document
  field :text
  referenced_in :post
end

class Post
  include Mongoid::Document
  include Mongoid::Versioning
  include Mongoid::Timestamps
  field :title
  field :content
  referenced_in :person
  referenced_in :author, :foreign_key => :author_id, :class_name => "User"
  referenced_in :poster, :foreign_key => :poster_id, :class_name => "Agent"

  references_many :tags, :stored_as => :array

  scope :recent, where(:created_at => { "$lt" => Time.now, "$gt" => 30.days.ago })

  validates_format_of :title, :without => /\$\$\$/

  class << self
    def old
      where(:created_at => { "$lt" => 30.days.ago })
    end
  end
end
