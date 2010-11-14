require "spec_helper"

describe Mongoid::Relations::Referenced::ManyToMany do

  before do
    [ Person, Preference, UserAccount ].map(&:delete_all)
  end

  [ :<<, :push, :concat ].each do |method|

    describe "##{method}" do

      context "when the relations are not polymorphic" do

        context "when the parent is a new record" do

          let(:person) do
            Person.new
          end

          let(:preference) do
            Preference.new
          end

          before do
            person.preferences.send(method, preference)
          end

          it "adds the documents to the relation" do
            person.preferences.should == [ preference ]
          end

          it "sets the foreign key on the relation" do
            person.preference_ids.should == [ preference.id ]
          end

          it "sets the foreign key on the inverse relation" do
            preference.person_ids.should == [ person.id ]
          end

          it "sets the base on the inverse relation" do
            preference.people.should == [ person ]
          end

          it "sets the same instance on the inverse relation" do
            preference.people.first.should eql(person)
          end

          it "does not save the target" do
            preference.should be_new
          end

          it "adds the correct number of documents" do
            person.preferences.size.should == 1
          end
        end

        context "when the parent is not a new record" do

          let(:person) do
            Person.create(:ssn => "554-44-3887")
          end

          let(:preference) do
            Preference.new
          end

          before do
            person.preferences.send(method, preference)
          end

          it "adds the documents to the relation" do
            person.preferences.should == [ preference ]
          end

          it "sets the foreign key on the relation" do
            person.preference_ids.should == [ preference.id ]
          end

          it "sets the foreign key on the inverse relation" do
            preference.person_ids.should == [ person.id ]
          end

          it "sets the base on the inverse relation" do
            preference.people.should == [ person ]
          end

          it "sets the same instance on the inverse relation" do
            preference.people.first.should eql(person)
          end

          it "saves the target" do
            preference.should_not be_new
          end

          it "adds the document to the target" do
            person.preferences.count.should == 1
          end
        end
      end

      context "when the relations are polymorphic" do

        context "when the parent is a new record" do

          let(:person) do
            Person.new
          end

          let(:user_account) do
            UserAccount.new
          end

          before do
            person.accountables.send(method, user_account)
          end

          it "adds the document to the relation" do
            person.accountables.should == [ user_account ]
          end

          it "sets the foreign key on the relation" do
            person.accountables_ids.should == [ user_account.id ]
          end

          it "sets the foreign key on the inverse relation" do
            user_account.people_ids.should == [ person.id ]
          end

          it "sets the base on the inverse relation" do
            user_account.people.should == [ person ]
          end

          it "does not save the target" do
            user_account.should be_new
          end

          it "adds the document to the target" do
            person.accountables.size.should == 1
          end
        end

        context "when the parent is not a new record" do

          let(:person) do
            Person.create(:ssn => "423-43-5928")
          end

          let(:user_account) do
            UserAccount.new
          end

          before do
            person.accountables.send(method, user_account)
          end

          it "adds the document to the relation" do
            person.accountables.should == [ user_account ]
          end

          it "sets the foreign key on the relation" do
            person.accountables_ids.should == [ user_account.id ]
          end

          it "sets the foreign key on the inverse relation" do
            user_account.people_ids.should == [ person.id ]
          end

          it "sets the base on the inverse relation" do
            user_account.people.should == [ person ]
          end

          it "saves the target" do
            user_account.should be_persisted
          end

          it "adds the document to the target" do
            person.accountables.size.should == 1
          end
        end
      end
    end
  end

  describe "#=" do

    context "when the relation is not polymorphic" do

      context "when the parent is a new record" do

        let(:person) do
          Person.new
        end

        let(:preference) do
          Preference.new
        end

        before do
          person.preferences = [ preference ]
        end

        it "sets the relation" do
          person.preferences.should == [ preference ]
        end

        it "sets the foreign key on the relation" do
          person.preference_ids.should == [ preference.id ]
        end

        it "sets the foreign key on the inverse relation" do
          preference.person_ids.should == [ person.id ]
        end

        it "sets the base on the inverse relation" do
          preference.people.first.should == person
        end

        it "does not save the target" do
          preference.should be_new
        end
      end

      context "when the parent is not a new record" do

        let(:person) do
          Person.create(:ssn => "437-11-1112")
        end

        let(:preference) do
          Preference.new
        end

        before do
          person.preferences = [ preference ]
        end

        it "sets the relation" do
          person.preferences.should == [ preference ]
        end

        it "sets the foreign key on the relation" do
          person.preference_ids.should == [ preference.id ]
        end

        it "sets the foreign key on the inverse relation" do
          preference.person_ids.should == [ person.id ]
        end

        it "sets the base on the inverse relation" do
          preference.people.first.should == person
        end

        it "saves the target" do
          preference.should be_persisted
        end
      end
    end

    context "when the relation is polymorphic" do

      context "when the parent is a new record" do

        let(:person) do
          Person.new
        end

        let(:user_account) do
          UserAccount.new
        end

        before do
          person.accountables = [ user_account ]
        end

        it "sets the relation" do
          person.accountables.should == [ user_account ]
        end

        it "sets the foreign key on the relation" do
          person.accountables_ids.should == [ user_account.id ]
        end

        it "sets the foreign key on the inverse relation" do
          user_account.people_ids.should == [ person.id ]
        end

        it "sets the base on the inverse relation" do
          user_account.people.should == [ person ]
        end

        it "sets the same instance on the inverse relation" do
          user_account.people.first.should eql(person)
        end

        it "does not save the target" do
          user_account.should be_new
        end
      end

      context "when the parent is not a new record" do

        let(:person) do
          Person.create(:ssn => "918-72-6354")
        end

        let(:user_account) do
          UserAccount.new
        end

        before do
          person.accountables = [ user_account ]
        end

        it "sets the relation" do
          person.accountables.should == [ user_account ]
        end

        it "sets the foreign key on the relation" do
          person.accountables_ids.should == [ user_account.id ]
        end

        it "sets the foreign key on the inverse relation" do
          user_account.people_ids.should == [ person.id ]
        end

        it "sets the base on the inverse relation" do
          user_account.people.should == [ person ]
        end

        it "sets the same instance on the inverse relation" do
          user_account.people.first.should eql(person)
        end

        it "saves the target" do
          user_account.should be_persisted
        end
      end
    end
  end

  describe "#= nil" do

    context "when the relation is not polymorphic" do

      context "when the parent is a new record" do

        let(:person) do
          Person.new
        end

        let(:preference) do
          Preference.new
        end

        before do
          person.preferences = [ preference ]
          person.preferences = nil
        end

        it "sets the relation to an empty array" do
          person.preferences.should be_empty
        end

        it "removed the inverse relation" do
          preference.people.should be_empty
        end

        it "removes the foreign key values" do
          person.preference_ids.should be_empty
        end

        it "removes the inverse foreign key values" do
          preference.person_ids.should be_empty
        end
      end

      context "when the parent is not a new record" do

        let(:person) do
          Person.create(:ssn => "437-11-1112")
        end

        let(:preference) do
          Preference.new
        end

        before do
          person.preferences = [ preference ]
          person.preferences = nil
        end

        it "sets the relation to an empty array" do
          person.preferences.should be_empty
        end

        it "removed the inverse relation" do
          preference.people.should be_empty
        end

        it "removes the foreign key values" do
          person.preference_ids.should be_empty
        end

        it "removes the inverse foreign key values" do
          preference.person_ids.should be_empty
        end

        it "deletes the target from the database" do
          preference.should be_destroyed
        end
      end
    end

    context "when the relation is polymorphic" do

      context "when the parent is a new record" do

        let(:person) do
          Person.new
        end

        let(:user_account) do
          UserAccount.new
        end

        before do
          person.accountables = [ user_account ]
          person.accountables = nil
        end

        it "sets the relation to an empty array" do
          person.accountables.should be_empty
        end

        it "removed the inverse relation" do
          user_account.people.should be_empty
        end

        it "removes the foreign key values" do
          person.accountables_ids.should be_empty
        end

        it "removes the inverse foreign key values" do
          user_account.people_ids.should be_empty
        end
      end

      context "when the parent is not a new record" do

        let(:person) do
          Person.create(:ssn => "433-10-0000")
        end

        let(:user_account) do
          UserAccount.new
        end

        before do
          person.accountables = [ user_account ]
          person.accountables = nil
        end

        it "sets the relation to an empty array" do
          person.accountables.should be_empty
        end

        it "removed the inverse relation" do
          user_account.people.should be_empty
        end

        it "removes the foreign key values" do
          person.accountables_ids.should be_empty
        end

        it "removes the inverse foreign key values" do
          user_account.people_ids.should be_empty
        end

        it "deletes the documents from the database" do
          user_account.should be_destroyed
        end
      end
    end
  end

  describe "#build" do

    context "when the relation is not polymorphic" do

      context "when the parent is a new record" do

        let(:person) do
          Person.new
        end

        let!(:preference) do
          person.preferences.build(:name => "settings")
        end

        it "adds the document to the relation" do
          person.preferences.should == [ preference ]
        end

        it "sets the foreign key on the relation" do
          person.preference_ids.should == [ preference.id ]
        end

        it "sets the inverse foreign key on the relation" do
          preference.person_ids.should == [ person.id ]
        end

        it "sets the base on the inverse relation" do
          preference.people.should == [ person ]
        end

        it "sets the attributes" do
          preference.name.should == "settings"
        end

        it "does not save the target" do
          preference.should be_new
        end

        it "adds the correct number of documents" do
          person.preferences.size.should == 1
        end
      end

      context "when the parent is not a new record" do

        let(:person) do
          Person.create(:ssn => "554-44-3891")
        end

        let!(:preference) do
          person.preferences.build(:name => "settings")
        end

        it "adds the document to the relation" do
          person.preferences.should == [ preference ]
        end

        it "sets the foreign key on the relation" do
          person.preference_ids.should == [ preference.id ]
        end

        it "sets the inverse foreign key on the relation" do
          preference.person_ids.should == [ person.id ]
        end

        it "sets the base on the inverse relation" do
          preference.people.should == [ person ]
        end

        it "sets the attributes" do
          preference.name.should == "settings"
        end

        it "does not save the target" do
          preference.should be_new
        end

        it "adds the correct number of documents" do
          person.preferences.size.should == 1
        end
      end
    end

    context "when the relation is polymorphic" do

      context "when the parent is a new record" do

        let(:person) do
          Person.new
        end

        let!(:user_account) do
          person.accountables.build({ :username => "durran" }, UserAccount)
        end

        it "adds the document to the relation" do
          person.accountables.should == [ user_account ]
        end

        it "sets the foreign key on the relation" do
          person.accountables_ids.should == [ user_account.id ]
        end

        it "sets the inverse foreign key on the relation" do
          user_account.people_ids.should == [ person.id ]
        end

        it "sets the base on the inverse relation" do
          user_account.people.should == [ person ]
        end

        it "sets the attributes" do
          user_account.username.should == "durran"
        end

        it "does not save the target" do
          user_account.should be_new
        end

        it "adds the correct number of documents" do
          person.accountables.size.should == 1
        end
      end

      context "when the parent is not a new record" do

        let(:person) do
          Person.create(:ssn => "777-77-8811")
        end

        let!(:user_account) do
          person.accountables.build({ :username => "durran" }, UserAccount)
        end

        it "adds the document to the relation" do
          person.accountables.should == [ user_account ]
        end

        it "sets the foreign key on the relation" do
          person.accountables_ids.should == [ user_account.id ]
        end

        it "sets the inverse foreign key on the relation" do
          user_account.people_ids.should == [ person.id ]
        end

        it "sets the base on the inverse relation" do
          user_account.people.should == [ person ]
        end

        it "sets the attributes" do
          user_account.username.should == "durran"
        end

        it "does not save the target" do
          user_account.should be_new
        end

        it "adds the correct number of documents" do
          person.accountables.size.should == 1
        end
      end
    end
  end

  describe "#clear" do

    context "when the relation is not polymorphic" do

      context "when the parent has been persisted" do

        let!(:person) do
          Person.create(:ssn => "123-45-9988")
        end

        context "when the children are persisted" do

          let!(:preference) do
            person.preferences.create(:name => "settings")
          end

          let!(:relation) do
            person.preferences.clear
          end

          it "clears out the relation" do
            person.preferences.should be_empty
          end

          it "removes the parent from the inverse relation" do
            preference.people.should_not include(person)
          end

          it "removes the foreign keys" do
            person.preference_ids.should be_empty
          end

          it "removes the parent key from the inverse" do
            preference.person_ids.should_not include(person.id)
          end

          it "marks the documents as deleted" do
            preference.should be_destroyed
          end

          it "deletes the documents from the db" do
            person.reload.preferences.should be_empty
          end

          it "returns the relation" do
            relation.should == []
          end
        end

        context "when the children are not persisted" do

          let!(:post) do
            person.preferences.build(:name => "setting")
          end

          let!(:relation) do
            person.preferences.clear
          end

          it "clears out the relation" do
            person.preferences.should be_empty
          end
        end
      end

      context "when the parent is not persisted" do

        let(:person) do
          Person.new
        end

        let!(:preference) do
          person.preferences.build(:name => "setting")
        end

        let!(:relation) do
          person.preferences.clear
        end

        it "clears out the relation" do
          person.preferences.should be_empty
        end
      end
    end

    context "when the relation is polymorphic" do

      context "when the parent has been persisted" do

        let!(:person) do
          Person.create(:ssn => "123-45-9188")
        end

        context "when the children are persisted" do

          let!(:accountable) do
            person.accountables.create({ :username => "durran" }, UserAccount)
          end

          let!(:relation) do
            person.accountables.clear
          end

          it "clears out the relation" do
            person.accountables.should be_empty
          end

          it "removes the parent from the inverse relation" do
            accountable.people.should_not include(person)
          end

          it "removes the foreign keys" do
            person.accountables_ids.should be_empty
          end

          it "removes the parent key from the inverse" do
            accountable.people_ids.should_not include(person.id)
          end

          it "marks the documents as deleted" do
            accountable.should be_destroyed
          end

          it "deletes the documents from the db" do
            person.reload.accountables.should be_empty
          end

          it "returns the relation" do
            relation.should == []
          end
        end

        context "when the children are not persisted" do

          let!(:post) do
            person.accountables.build({ :username => "durran" }, UserAccount)
          end

          let!(:relation) do
            person.accountables.clear
          end

          it "clears out the relation" do
            person.accountables.should be_empty
          end
        end
      end

      context "when the parent is not persisted" do

        let(:person) do
          Person.new
        end

        let!(:accountable) do
          person.accountables.build({ :username => "durran" }, UserAccount)
        end

        let!(:relation) do
          person.accountables.clear
        end

        it "clears out the relation" do
          person.accountables.should be_empty
        end
      end
    end
  end

  # describe "#count" do

    # let(:movie) do
      # Movie.create
    # end

    # context "when documents have been persisted" do

      # let!(:rating) do
        # movie.ratings.create(:value => 1)
      # end

      # it "returns the number of persisted documents" do
        # movie.ratings.count.should == 1
      # end
    # end

    # context "when documents have not been persisted" do

      # let!(:rating) do
        # movie.ratings.build(:value => 1)
      # end

      # it "returns 0" do
        # movie.ratings.count.should == 0
      # end
    # end
  # end

  # describe "#create" do

    # context "when the relation is not polymorphic" do

      # context "when the parent is a new record" do

        # let(:person) do
          # Person.new
        # end

        # let!(:post) do
          # person.posts.create(:text => "Testing")
        # end

        # it "sets the foreign key on the relation" do
          # post.person_id.should == person.id
        # end

        # it "sets the base on the inverse relation" do
          # post.person.should == person
        # end

        # it "sets the attributes" do
          # post.text.should == "Testing"
        # end

        # it "does not save the target" do
          # post.should be_a_new_record
        # end

        # it "adds the document to the target" do
          # person.posts.size.should == 1
        # end
      # end

      # context "when the parent is not a new record" do

        # let(:person) do
          # Person.create(:ssn => "554-44-3891")
        # end

        # let!(:post) do
          # person.posts.create(:text => "Testing")
        # end

        # it "sets the foreign key on the relation" do
          # post.person_id.should == person.id
        # end

        # it "sets the base on the inverse relation" do
          # post.person.should == person
        # end

        # it "sets the attributes" do
          # post.text.should == "Testing"
        # end

        # it "saves the target" do
          # post.should_not be_a_new_record
        # end

        # it "adds the document to the target" do
          # person.posts.count.should == 1
        # end
      # end
    # end

    # context "when the relation is polymorphic" do

      # context "when the parent is a new record" do

        # let(:movie) do
          # Movie.new
        # end

        # let!(:rating) do
          # movie.ratings.create(:value => 1)
        # end

        # it "sets the foreign key on the relation" do
          # rating.ratable_id.should == movie.id
        # end

        # it "sets the base on the inverse relation" do
          # rating.ratable.should == movie
        # end

        # it "sets the attributes" do
          # rating.value.should == 1
        # end

        # it "does not save the target" do
          # rating.should be_new
        # end

        # it "adds the document to the target" do
          # movie.ratings.size.should == 1
        # end
      # end

      # context "when the parent is not a new record" do

        # let(:movie) do
          # Movie.create
        # end

        # let!(:rating) do
          # movie.ratings.create(:value => 3)
        # end

        # it "sets the foreign key on the relation" do
          # rating.ratable_id.should == movie.id
        # end

        # it "sets the base on the inverse relation" do
          # rating.ratable.should == movie
        # end

        # it "sets the attributes" do
          # rating.value.should == 3
        # end

        # it "saves the target" do
          # rating.should_not be_new
        # end

        # it "adds the document to the target" do
          # movie.ratings.count.should == 1
        # end
      # end
    # end
  # end

  # describe "#create!" do

    # context "when the relation is not polymorphic" do

      # context "when the parent is a new record" do

        # let(:person) do
          # Person.new
        # end

        # let!(:post) do
          # person.posts.create!(:title => "Testing")
        # end

        # it "sets the foreign key on the relation" do
          # post.person_id.should == person.id
        # end

        # it "sets the base on the inverse relation" do
          # post.person.should == person
        # end

        # it "sets the attributes" do
          # post.title.should == "Testing"
        # end

        # it "does not save the target" do
          # post.should be_a_new_record
        # end

        # it "adds the document to the target" do
          # person.posts.size.should == 1
        # end
      # end

      # context "when the parent is not a new record" do

        # let(:person) do
          # Person.create(:ssn => "554-44-3891")
        # end

        # let!(:post) do
          # person.posts.create!(:title => "Testing")
        # end

        # it "sets the foreign key on the relation" do
          # post.person_id.should == person.id
        # end

        # it "sets the base on the inverse relation" do
          # post.person.should == person
        # end

        # it "sets the attributes" do
          # post.title.should == "Testing"
        # end

        # it "saves the target" do
          # post.should_not be_a_new_record
        # end

        # it "adds the document to the target" do
          # person.posts.count.should == 1
        # end

        # context "when validation fails" do

          # it "raises an error" do
            # expect {
              # person.posts.create!(:title => "$$$")
            # }.to raise_error(Mongoid::Errors::Validations)
          # end
        # end
      # end
    # end

    # context "when the relation is polymorphic" do

      # context "when the parent is a new record" do

        # let(:movie) do
          # Movie.new
        # end

        # let!(:rating) do
          # movie.ratings.create!(:value => 1)
        # end

        # it "sets the foreign key on the relation" do
          # rating.ratable_id.should == movie.id
        # end

        # it "sets the base on the inverse relation" do
          # rating.ratable.should == movie
        # end

        # it "sets the attributes" do
          # rating.value.should == 1
        # end

        # it "does not save the target" do
          # rating.should be_new
        # end

        # it "adds the document to the target" do
          # movie.ratings.size.should == 1
        # end
      # end

      # context "when the parent is not a new record" do

        # let(:movie) do
          # Movie.create
        # end

        # let!(:rating) do
          # movie.ratings.create!(:value => 4)
        # end

        # it "sets the foreign key on the relation" do
          # rating.ratable_id.should == movie.id
        # end

        # it "sets the base on the inverse relation" do
          # rating.ratable.should == movie
        # end

        # it "sets the attributes" do
          # rating.value.should == 4
        # end

        # it "saves the target" do
          # rating.should_not be_new
        # end

        # it "adds the document to the target" do
          # movie.ratings.count.should == 1
        # end

        # context "when validation fails" do

          # it "raises an error" do
            # expect {
              # movie.ratings.create!(:value => 1000)
            # }.to raise_error(Mongoid::Errors::Validations)
          # end
        # end
      # end
    # end
  # end

  # [ :delete_all, :destroy_all ].each do |method|

    # describe "##{method}" do

      # context "when the relation is not polymorphic" do

        # context "when conditions are provided" do

          # let(:person) do
            # Person.create(:ssn => "123-32-2321")
          # end

          # before do
            # person.posts.create(:title => "Testing")
            # person.posts.create(:title => "Test")
          # end

          # it "removes the correct posts" do
            # person.posts.send(method, :conditions => { :title => "Testing" })
            # person.posts.count.should == 1
          # end

          # it "deletes the documents from the database" do
            # person.posts.send(method, :conditions => {:title => "Testing" })
            # Post.where(:title => "Testing").count.should == 0
          # end

          # it "returns the number of documents deleted" do
            # person.posts.send(method, :conditions => { :title => "Testing" }).should == 1
          # end
        # end

        # context "when conditions are not provided" do

          # let(:person) do
            # Person.create(:ssn => "123-32-2321")
          # end

          # before do
            # person.posts.create(:title => "Testing")
            # person.posts.create(:title => "Test")
          # end

          # it "removes the correct posts" do
            # person.posts.send(method)
            # person.posts.count.should == 0
          # end

          # it "deletes the documents from the database" do
            # person.posts.send(method)
            # Post.where(:title => "Testing").count.should == 0
          # end

          # it "returns the number of documents deleted" do
            # person.posts.send(method).should == 2
          # end
        # end
      # end

      # context "when the relation is polymorphic" do

        # context "when conditions are provided" do

          # let(:movie) do
            # Movie.create(:title => "Bladerunner")
          # end

          # before do
            # movie.ratings.create(:value => 1)
            # movie.ratings.create(:value => 2)
          # end

          # it "removes the correct ratings" do
            # movie.ratings.send(method, :conditions => { :value => 1 })
            # movie.ratings.count.should == 1
          # end

          # it "deletes the documents from the database" do
            # movie.ratings.send(method, :conditions => { :value => 1 })
            # Rating.where(:value => 1).count.should == 0
          # end

          # it "returns the number of documents deleted" do
            # movie.ratings.send(method, :conditions => { :value => 1 }).should == 1
          # end
        # end

        # context "when conditions are not provided" do

          # let(:movie) do
            # Movie.create(:title => "Bladerunner")
          # end

          # before do
            # movie.ratings.create(:value => 1)
            # movie.ratings.create(:value => 2)
          # end

          # it "removes the correct ratings" do
            # movie.ratings.send(method)
            # movie.ratings.count.should == 0
          # end

          # it "deletes the documents from the database" do
            # movie.ratings.send(method)
            # Rating.where(:value => 1).count.should == 0
          # end

          # it "returns the number of documents deleted" do
            # movie.ratings.send(method).should == 2
          # end
        # end
      # end
    # end
  # end

  # describe "#exists?" do

    # let!(:person) do
      # Person.create(:ssn => "292-19-4232")
    # end

    # context "when documents exist in the database" do

      # before do
        # person.posts.create
      # end

      # it "returns true" do
        # person.posts.exists?.should == true
      # end
    # end

    # context "when no documents exist in the database" do

      # before do
        # person.posts.build
      # end

      # it "returns false" do
        # person.posts.exists?.should == false
      # end
    # end
  # end

  # describe "#find" do

    # context "when the relation is not polymorphic" do

      # let(:person) do
        # Person.create
      # end

      # let!(:post_one) do
        # person.posts.create(:title => "Test")
      # end

      # let!(:post_two) do
        # person.posts.create(:title => "OMG I has relations")
      # end

      # context "when providing an id" do

        # context "when the id matches" do

          # let(:post) do
            # person.posts.find(post_one.id)
          # end

          # it "returns the matching document" do
            # post.should == post_one
          # end
        # end

        # context "when the id does not match" do

          # context "when config set to raise error" do

            # before do
              # Mongoid.raise_not_found_error = true
            # end

            # after do
              # Mongoid.raise_not_found_error = false
            # end

            # it "raises an error" do
              # expect {
                # person.posts.find(BSON::ObjectId.new)
              # }.to raise_error(Mongoid::Errors::DocumentNotFound)
            # end
          # end

          # context "when config set not to raise error" do

            # let(:post) do
              # person.posts.find(BSON::ObjectId.new)
            # end

            # before do
              # Mongoid.raise_not_found_error = false
            # end

            # it "returns nil" do
              # post.should be_nil
            # end
          # end
        # end
      # end

      # context "when providing an array of ids" do

        # context "when the ids match" do

          # let(:posts) do
            # person.posts.find([ post_one.id, post_two.id ])
          # end

          # it "returns the matching documents" do
            # posts.should == [ post_one, post_two ]
          # end
        # end

        # context "when the ids do not match" do

          # context "when config set to raise error" do

            # before do
              # Mongoid.raise_not_found_error = true
            # end

            # after do
              # Mongoid.raise_not_found_error = false
            # end

            # it "raises an error" do
              # expect {
                # person.posts.find([ BSON::ObjectId.new ])
              # }.to raise_error(Mongoid::Errors::DocumentNotFound)
            # end
          # end

          # context "when config set not to raise error" do

            # let(:posts) do
              # person.posts.find([ BSON::ObjectId.new ])
            # end

            # before do
              # Mongoid.raise_not_found_error = false
            # end

            # it "returns an empty array" do
              # posts.should be_empty
            # end
          # end
        # end
      # end

      # context "when finding first" do

        # context "when there is a match" do

          # let(:post) do
            # person.posts.find(:first, :conditions => { :title => "Test" })
          # end

          # it "returns the first matching document" do
            # post.should == post_one
          # end
        # end

        # context "when there is no match" do

          # let(:post) do
            # person.posts.find(:first, :conditions => { :title => "Testing" })
          # end

          # it "returns nil" do
            # post.should be_nil
          # end
        # end
      # end

      # context "when finding last" do

        # context "when there is a match" do

          # let(:post) do
            # person.posts.find(:last, :conditions => { :title => "OMG I has relations" })
          # end

          # it "returns the last matching document" do
            # post.should == post_two
          # end
        # end

        # context "when there is no match" do

          # let(:post) do
            # person.posts.find(:last, :conditions => { :title => "Testing" })
          # end

          # it "returns nil" do
            # post.should be_nil
          # end
        # end
      # end

      # context "when finding all" do

        # context "when there is a match" do

          # let(:posts) do
            # person.posts.find(:all, :conditions => { :title => { "$exists" => true } })
          # end

          # it "returns the matching documents" do
            # posts.should == [ post_one, post_two ]
          # end
        # end

        # context "when there is no match" do

          # let(:posts) do
            # person.posts.find(:all, :conditions => { :title => "Other" })
          # end

          # it "returns an empty array" do
            # posts.should be_empty
          # end
        # end
      # end
    # end

    # context "when the relation is polymorphic" do

      # let(:movie) do
        # Movie.create
      # end

      # let!(:rating_one) do
        # movie.ratings.create(:value => 1)
      # end

      # let!(:rating_two) do
        # movie.ratings.create(:value => 5)
      # end

      # context "when providing an id" do

        # context "when the id matches" do

          # let(:rating) do
            # movie.ratings.find(rating_one.id)
          # end

          # it "returns the matching document" do
            # rating.should == rating_one
          # end
        # end

        # context "when the id does not match" do

          # context "when config set to raise error" do

            # before do
              # Mongoid.raise_not_found_error = true
            # end

            # after do
              # Mongoid.raise_not_found_error = false
            # end

            # it "raises an error" do
              # expect {
                # movie.ratings.find(BSON::ObjectId.new)
              # }.to raise_error(Mongoid::Errors::DocumentNotFound)
            # end
          # end

          # context "when config set not to raise error" do

            # let(:rating) do
              # movie.ratings.find(BSON::ObjectId.new)
            # end

            # before do
              # Mongoid.raise_not_found_error = false
            # end

            # it "returns nil" do
              # rating.should be_nil
            # end
          # end
        # end
      # end

      # context "when providing an array of ids" do

        # context "when the ids match" do

          # let(:ratings) do
            # movie.ratings.find([ rating_one.id, rating_two.id ])
          # end

          # it "returns the matching documents" do
            # ratings.should == [ rating_one, rating_two ]
          # end
        # end

        # context "when the ids do not match" do

          # context "when config set to raise error" do

            # before do
              # Mongoid.raise_not_found_error = true
            # end

            # after do
              # Mongoid.raise_not_found_error = false
            # end

            # it "raises an error" do
              # expect {
                # movie.ratings.find([ BSON::ObjectId.new ])
              # }.to raise_error(Mongoid::Errors::DocumentNotFound)
            # end
          # end

          # context "when config set not to raise error" do

            # let(:ratings) do
              # movie.ratings.find([ BSON::ObjectId.new ])
            # end

            # before do
              # Mongoid.raise_not_found_error = false
            # end

            # it "returns an empty array" do
              # ratings.should be_empty
            # end
          # end
        # end
      # end

      # context "when finding first" do

        # context "when there is a match" do

          # let(:rating) do
            # movie.ratings.find(:first, :conditions => { :value => 1 })
          # end

          # it "returns the first matching document" do
            # rating.should == rating_one
          # end
        # end

        # context "when there is no match" do

          # let(:rating) do
            # movie.ratings.find(:first, :conditions => { :value => 11 })
          # end

          # it "returns nil" do
            # rating.should be_nil
          # end
        # end
      # end

      # context "when finding last" do

        # context "when there is a match" do

          # let(:rating) do
            # movie.ratings.find(:last, :conditions => { :value => 5 })
          # end

          # it "returns the last matching document" do
            # rating.should == rating_two
          # end
        # end

        # context "when there is no match" do

          # let(:rating) do
            # movie.ratings.find(:last, :conditions => { :value => 3 })
          # end

          # it "returns nil" do
            # rating.should be_nil
          # end
        # end
      # end

      # context "when finding all" do

        # context "when there is a match" do

          # let(:ratings) do
            # movie.ratings.find(:all, :conditions => { :value => { "$exists" => true } })
          # end

          # it "returns the matching documents" do
            # ratings.should == [ rating_one, rating_two ]
          # end
        # end

        # context "when there is no match" do

          # let(:ratings) do
            # movie.ratings.find(:all, :conditions => { :value => 7 })
          # end

          # it "returns an empty array" do
            # ratings.should be_empty
          # end
        # end
      # end
    # end
  # end

  # describe "#find_or_create_by" do

    # context "when the relation is not polymorphic" do

      # let(:person) do
        # Person.create
      # end

      # let!(:post) do
        # person.posts.create(:title => "Testing")
      # end

      # context "when the document exists" do

        # let(:found) do
          # person.posts.find_or_create_by(:title => "Testing")
        # end

        # it "returns the document" do
          # found.should == post
        # end
      # end

      # context "when the document does not exist" do

        # let(:found) do
          # person.posts.find_or_create_by(:title => "Test")
        # end

        # it "sets the new document attributes" do
          # found.title.should == "Test"
        # end

        # it "returns a newly persisted document" do
          # found.should be_persisted
        # end
      # end
    # end

    # context "when the relation is polymorphic" do

      # let(:movie) do
        # Movie.create
      # end

      # let!(:rating) do
        # movie.ratings.create(:value => 1)
      # end

      # context "when the document exists" do

        # let(:found) do
          # movie.ratings.find_or_create_by(:value => 1)
        # end

        # it "returns the document" do
          # found.should == rating
        # end
      # end

      # context "when the document does not exist" do

        # let(:found) do
          # movie.ratings.find_or_create_by(:value => 3)
        # end

        # it "sets the new document attributes" do
          # found.value.should == 3
        # end

        # it "returns a newly persisted document" do
          # found.should be_persisted
        # end
      # end
    # end
  # end

  # describe "#find_or_initialize_by" do

    # context "when the relation is not polymorphic" do

      # let(:person) do
        # Person.create
      # end

      # let!(:post) do
        # person.posts.create(:title => "Testing")
      # end

      # context "when the document exists" do

        # let(:found) do
          # person.posts.find_or_initialize_by(:title => "Testing")
        # end

        # it "returns the document" do
          # found.should == post
        # end
      # end

      # context "when the document does not exist" do

        # let(:found) do
          # person.posts.find_or_initialize_by(:title => "Test")
        # end

        # it "sets the new document attributes" do
          # found.title.should == "Test"
        # end

        # it "returns a non persisted document" do
          # found.should_not be_persisted
        # end
      # end
    # end

    # context "when the relation is polymorphic" do

      # let(:movie) do
        # Movie.create
      # end

      # let!(:rating) do
        # movie.ratings.create(:value => 1)
      # end

      # context "when the document exists" do

        # let(:found) do
          # movie.ratings.find_or_initialize_by(:value => 1)
        # end

        # it "returns the document" do
          # found.should == rating
        # end
      # end

      # context "when the document does not exist" do

        # let(:found) do
          # movie.ratings.find_or_initialize_by(:value => 3)
        # end

        # it "sets the new document attributes" do
          # found.value.should == 3
        # end

        # it "returns a non persisted document" do
          # found.should_not be_persisted
        # end
      # end
    # end
  # end

  # [ :size, :length ].each do |method|

    # describe "##{method}" do

      # let(:movie) do
        # Movie.create
      # end

      # context "when documents have been persisted" do

        # let!(:rating) do
          # movie.ratings.create(:value => 1)
        # end

        # it "returns 0" do
          # movie.ratings.send(method).should == 1
        # end
      # end

      # context "when documents have not been persisted" do

        # before do
          # movie.ratings.build(:value => 1)
          # movie.ratings.create(:value => 2)
        # end

        # it "returns the total number of documents" do
          # movie.ratings.send(method).should == 2
        # end
      # end
    # end
  # end
end
