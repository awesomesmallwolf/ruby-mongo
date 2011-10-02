class Quiz
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  field :name, :type => String
  field :topic, :type => String
  embeds_many :pages

  attr_accessible :topic, :as => [ :default, :admin ]
  attr_accessible :name, :as => :default
end
