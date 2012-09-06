require "spec_helper"

describe Mongoid::Validations::UniquenessValidator do

  describe "#valid?" do

    context "when the document is a root document" do

      context "when adding custom persistence options" do

        before do
          Dictionary.validates_uniqueness_of :name
        end

        after do
          Dictionary.reset_callbacks(:validate)
        end

        context "when persisting to another collection" do

          before do
            Dictionary.with(collection: "dicts").create(name: "websters")
          end

          context "when the document is not valid" do

            let(:websters) do
              Dictionary.with(collection: "dicts").new(name: "websters")
            end

            it "performs the validation on the correct collection" do
              websters.should_not be_valid
            end

            it "adds the uniqueness error" do
              websters.valid?
              websters.errors[:name].should_not be_nil
            end

            it "clears the persistence options in the thread local" do
              websters.valid?
              Dictionary.persistence_options.should be_nil
            end
          end

          context "when the document is valid" do

            let(:oxford) do
              Dictionary.with(collection: "dicts").new(name: "oxford")
            end

            it "performs the validation on the correct collection" do
              oxford.should be_valid
            end

            it "does not clear the persistence options in the thread local" do
              oxford.valid?
              Dictionary.persistence_options.should_not be_nil
            end
          end
        end
      end

      context "when the document is paranoid" do

        before do
          ParanoidPost.validates_uniqueness_of :title
        end

        after do
          ParanoidPost.reset_callbacks(:validate)
        end

        let!(:post) do
          ParanoidPost.create(title: "testing")
        end

        context "when the field is unique" do

          let(:new_post) do
            ParanoidPost.new(title: "test")
          end

          it "returns true" do
            new_post.should be_valid
          end
        end

        context "when the field is unique for non soft deleted docs" do

          before do
            post.delete
          end

          let(:new_post) do
            ParanoidPost.new(title: "testing")
          end

          it "returns true" do
            new_post.should be_valid
          end
        end

        context "when the field is not unique" do

          let(:new_post) do
            ParanoidPost.new(title: "testing")
          end

          it "returns false" do
            new_post.should_not be_valid
          end
        end
      end

      context "when the document contains no compound key" do

        context "when validating a relation" do

          before do
            Word.validates_uniqueness_of :dictionary
          end

          after do
            Word.reset_callbacks(:validate)
          end

          context "when the attribute id is unique" do

            let(:dictionary) do
              Dictionary.create
            end

            let(:word) do
              Word.new(dictionary: dictionary)
            end

            it "returns true" do
              word.should be_valid
            end
          end
        end

        context "when the field is localized" do

          before do
            Dictionary.validates_uniqueness_of :description
          end

          after do
            Dictionary.reset_callbacks(:validate)
          end

          context "when the attribute is not unique" do

            context "when the document is not the match" do

              before do
                Dictionary.with(safe: true).create(description: "english")
              end

              let(:dictionary) do
                Dictionary.new(description: "english")
              end

              it "returns false" do
                dictionary.should_not be_valid
              end

              it "adds the uniqueness error" do
                dictionary.valid?
                dictionary.errors[:description].should eq([ "is already taken" ])
              end
            end
          end
        end

        context "when no scope is provided" do

          before do
            Dictionary.validates_uniqueness_of :name
          end

          after do
            Dictionary.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            let!(:oxford) do
              Dictionary.create(name: "Oxford")
            end

            let(:dictionary) do
              Dictionary.new(name: "Webster")
            end

            it "returns true" do
              dictionary.should be_valid
            end

            context "when subsequently cloning the document" do

              let(:clone) do
                oxford.clone
              end

              it "returns false for the clone" do
                clone.should_not be_valid
              end
            end
          end

          context "when the attribute is not unique" do

            context "when the document is not the match" do

              before do
                Dictionary.create(name: "Oxford")
              end

              let!(:dictionary) do
                Dictionary.new(name: "Oxford")
              end

              it "returns false" do
                dictionary.should_not be_valid
              end

              it "adds the uniqueness error" do
                dictionary.valid?
                dictionary.errors[:name].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              context "when the field has changed" do

                let!(:dictionary) do
                  Dictionary.create(name: "Oxford")
                end

                it "returns true" do
                  dictionary.should be_valid
                end
              end

              context "when the field has not changed" do

                before do
                  Dictionary.default_scoping = nil
                end

                let!(:dictionary) do
                  Dictionary.create!(name: "Oxford")
                end

                let!(:from_db) do
                  Dictionary.find(dictionary.id)
                end

                it "returns true" do
                  from_db.should be_valid
                end

                it "does not touch the database" do
                  Dictionary.should_receive(:where).never
                  from_db.valid?
                end
              end
            end
          end
        end

        context "when a default scope is on the model" do

          before do
            Dictionary.validates_uniqueness_of :name
            Dictionary.default_scope(Dictionary.where(year: 1990))
          end

          after do
            Dictionary.send(:strip_default_scope, Dictionary.where(year: 1990))
            Dictionary.reset_callbacks(:validate)
          end

          context "when the document with the unqiue attribute is not in default scope" do

            context "when the attribute is not unique" do

              before do
                Dictionary.with(safe: true).create(name: "Oxford")
              end

              let(:dictionary) do
                Dictionary.new(name: "Oxford")
              end

              it "returns false" do
                dictionary.should_not be_valid
              end
            end
          end
        end

        context "when a single scope is provided" do

          before do
            Dictionary.validates_uniqueness_of :name, scope: :publisher
          end

          after do
            Dictionary.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            before do
              Dictionary.create(name: "Oxford", publisher: "Amazon")
            end

            let(:dictionary) do
              Dictionary.new(name: "Webster")
            end

            it "returns true" do
              dictionary.should be_valid
            end
          end

          context "when the attribute is unique in the scope" do

            before do
              Dictionary.create(name: "Oxford", publisher: "Amazon")
            end

            let(:dictionary) do
              Dictionary.new(name: "Webster", publisher: "Amazon")
            end

            it "returns true" do
              dictionary.should be_valid
            end
          end

          context "when uniqueness is violated due to scope change" do

            let(:personal_folder) do
              Folder.create!(name: "Personal")
            end

            let(:public_folder) do
              Folder.create!(name: "Public")
            end

            before do
              personal_folder.folder_items << FolderItem.new(name: "non-unique")
              public_folder.folder_items << FolderItem.new(name: "non-unique")
            end

            let(:item) do
              public_folder.folder_items.last
            end

            it "should set an error for associated object not being unique" do
              item.update_attributes(folder_id: personal_folder.id)
              item.errors.messages[:name].first.should eq("is already taken")
            end

          end

          context "when the attribute is not unique with no scope" do

            before do
              Dictionary.create(name: "Oxford", publisher: "Amazon")
            end

            let(:dictionary) do
              Dictionary.new(name: "Oxford")
            end

            it "returns true" do
              dictionary.should be_valid
            end
          end

          context "when the attribute is not unique in another scope" do

            before do
              Dictionary.create(name: "Oxford", publisher: "Amazon")
            end

            let(:dictionary) do
              Dictionary.new(name: "Oxford", publisher: "Addison")
            end

            it "returns true" do
              dictionary.should be_valid
            end
          end

          context "when the attribute is not unique in the same scope" do

            context "when the document is not the match" do

              before do
                Dictionary.create(name: "Oxford", publisher: "Amazon")
              end

              let(:dictionary) do
                Dictionary.new(name: "Oxford", publisher: "Amazon")
              end

              it "returns false" do
                dictionary.should_not be_valid
              end

              it "adds the uniqueness errors" do
                dictionary.valid?
                dictionary.errors[:name].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:dictionary) do
                Dictionary.create(name: "Oxford", publisher: "Amazon")
              end

              it "returns true" do
                dictionary.should be_valid
              end
            end

            context "when one of the scopes is a time" do

              before do
                Dictionary.create(
                  name: "Oxford",
                  publisher: "Amazon",
                  published: 10.days.ago.to_time
                )
              end

              let(:dictionary) do
                Dictionary.new(
                  name: "Oxford",
                  publisher: "Amazon",
                  published: 10.days.ago.to_time
                )
              end

              it "returns false" do
                dictionary.should_not be_valid
              end

              it "adds the uniqueness errors" do
                dictionary.valid?
                dictionary.errors[:name].should eq([ "is already taken" ])
              end
            end
          end
        end

        context "when multiple scopes are provided" do

          before do
            Dictionary.validates_uniqueness_of :name, scope: [ :publisher, :year ]
          end

          after do
            Dictionary.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            before do
              Dictionary.create(name: "Oxford", publisher: "Amazon")
            end

            let(:dictionary) do
              Dictionary.new(name: "Webster")
            end

            it "returns true" do
              dictionary.should be_valid
            end
          end

          context "when the attribute is unique in the scope" do

            before do
              Dictionary.create(
                name: "Oxford",
                publisher: "Amazon",
                year: 2011
              )
            end

            let(:dictionary) do
              Dictionary.new(
                name: "Webster",
                publisher: "Amazon",
                year: 2011
              )
            end

            it "returns true" do
              dictionary.should be_valid
            end
          end

          context "when the attribute is not unique with no scope" do

            before do
              Dictionary.create(name: "Oxford", publisher: "Amazon")
            end

            let(:dictionary) do
              Dictionary.new(name: "Oxford")
            end

            it "returns true" do
              dictionary.should be_valid
            end
          end

          context "when the attribute is not unique in another scope" do

            before do
              Dictionary.create(
                name: "Oxford",
                publisher: "Amazon",
                year: 1995
              )
            end

            let(:dictionary) do
              Dictionary.new(
                name: "Oxford",
                publisher: "Addison",
                year: 2011
              )
            end

            it "returns true" do
              dictionary.should be_valid
            end
          end

          context "when the attribute is not unique in the same scope" do

            context "when the document is not the match" do

              before do
                Dictionary.create(
                  name: "Oxford",
                  publisher: "Amazon",
                  year: 1960
                )
              end

              let(:dictionary) do
                Dictionary.new(
                  name: "Oxford",
                  publisher: "Amazon",
                  year: 1960
                )
              end

              it "returns false" do
                dictionary.should_not be_valid
              end

              it "adds the uniqueness errors" do
                dictionary.valid?
                dictionary.errors[:name].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:dictionary) do
                Dictionary.create(
                  name: "Oxford",
                  publisher: "Amazon",
                  year: 1960
                )
              end

              it "returns true" do
                dictionary.should be_valid
              end
            end
          end
        end

        context "when case sensitive is true" do

          before do
            Dictionary.validates_uniqueness_of :name
          end

          after do
            Dictionary.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            before do
              Dictionary.create(name: "Oxford")
            end

            let(:dictionary) do
              Dictionary.new(name: "Webster")
            end

            it "returns true" do
              dictionary.should be_valid
            end
          end

          context "when the attribute is not unique" do

            context "when the document is not the match" do

              before do
                Dictionary.create(name: "Oxford")
              end

              let(:dictionary) do
                Dictionary.new(name: "Oxford")
              end

              it "returns false" do
                dictionary.should_not be_valid
              end

              it "adds the uniqueness error" do
                dictionary.valid?
                dictionary.errors[:name].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:dictionary) do
                Dictionary.create(name: "Oxford")
              end

              it "returns true" do
                dictionary.should be_valid
              end
            end
          end
        end

        context "when case sensitive is false" do

          before do
            Dictionary.validates_uniqueness_of :name, case_sensitive: false
          end

          after do
            Dictionary.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            context "when there are no special characters" do

              before do
                Dictionary.create(name: "Oxford")
              end

              let(:dictionary) do
                Dictionary.new(name: "Webster")
              end

              it "returns true" do
                dictionary.should be_valid
              end
            end

            context "when special characters exist" do

              before do
                Dictionary.create(name: "Oxford")
              end

              let(:dictionary) do
                Dictionary.new(name: "Web@st.er")
              end

              it "returns true" do
                dictionary.should be_valid
              end
            end
          end

          context "when the attribute is not unique" do

            context "when the document is not the match" do

              before do
                Dictionary.create(name: "Oxford")
              end

              let(:dictionary) do
                Dictionary.new(name: "oxford")
              end

              it "returns false" do
                dictionary.should_not be_valid
              end

              it "adds the uniqueness error" do
                dictionary.valid?
                dictionary.errors[:name].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:dictionary) do
                Dictionary.create(name: "Oxford")
              end

              it "returns true" do
                dictionary.should be_valid
              end
            end
          end
        end

        context "when allowing nil" do

          before do
            Dictionary.validates_uniqueness_of :name, allow_nil: true
          end

          after do
            Dictionary.reset_callbacks(:validate)
          end

          context "when the attribute is nil" do

            before do
              Dictionary.create
            end

            let(:dictionary) do
              Dictionary.new
            end

            it "returns true" do
              dictionary.should be_valid
            end
          end
        end

        context "when allowing blank" do

          before do
            Dictionary.validates_uniqueness_of :name, allow_blank: true
          end

          after do
            Dictionary.reset_callbacks(:validate)
          end

          context "when the attribute is blank" do

            before do
              Dictionary.create(name: "")
            end

            let(:dictionary) do
              Dictionary.new(name: "")
            end

            it "returns true" do
              dictionary.should be_valid
            end
          end
        end
      end

      context "when the document contains a compound key" do

        context "when no scope is provided" do

          before do
            Login.validates_uniqueness_of :username
          end

          after do
            Login.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            before do
              Login.create(username: "Oxford")
            end

            let(:login) do
              Login.new(username: "Webster")
            end

            it "returns true" do
              login.should be_valid
            end
          end

          context "when the attribute is not unique" do

            context "when the document is not the match" do

              before do
                Login.create(username: "Oxford")
              end

              let(:login) do
                Login.new(username: "Oxford")
              end

              it "returns false" do
                login.should_not be_valid
              end

              it "adds the uniqueness error" do
                login.valid?
                login.errors[:username].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:login) do
                Login.create(username: "Oxford")
              end

              it "returns true" do
                login.should be_valid
              end
            end
          end
        end

        context "when a single scope is provided" do

          before do
            Login.validates_uniqueness_of :username, scope: :application_id
          end

          after do
            Login.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            before do
              Login.create(username: "Oxford", application_id: 1)
            end

            let(:login) do
              Login.new(username: "Webster")
            end

            it "returns true" do
              login.should be_valid
            end
          end

          context "when the attribute is unique in the scope" do

            before do
              Login.create(username: "Oxford", application_id: 1)
            end

            let(:login) do
              Login.new(username: "Webster", application_id: 1)
            end

            it "returns true" do
              login.should be_valid
            end
          end

          context "when the attribute is not unique with no scope" do

            before do
              Login.create(username: "Oxford", application_id: 1)
            end

            let(:login) do
              Login.new(username: "Oxford")
            end

            it "returns true" do
              login.should be_valid
            end
          end

          context "when the attribute is not unique in another scope" do

            before do
              Login.create(username: "Oxford", application_id: 1)
            end

            let(:login) do
              Login.new(username: "Oxford", application_id: 2)
            end

            it "returns true" do
              login.should be_valid
            end
          end

          context "when the attribute is not unique in the same scope" do

            context "when the document is not the match" do

              before do
                Login.create(username: "Oxford", application_id: 1)
              end

              let(:login) do
                Login.new(username: "Oxford", application_id: 1)
              end

              it "returns false" do
                login.should_not be_valid
              end

              it "adds the uniqueness errors" do
                login.valid?
                login.errors[:username].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:login) do
                Login.create(username: "Oxford", application_id: 1)
              end

              it "returns true" do
                login.should be_valid
              end
            end
          end
        end

        context "when case sensitive is true" do

          before do
            Login.validates_uniqueness_of :username
          end

          after do
            Login.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            before do
              Login.create(username: "Oxford")
            end

            let(:login) do
              Login.new(username: "Webster")
            end

            it "returns true" do
              login.should be_valid
            end
          end

          context "when the attribute is not unique" do

            context "when the document is not the match" do

              before do
                Login.create(username: "Oxford")
              end

              let(:login) do
                Login.new(username: "Oxford")
              end

              it "returns false" do
                login.should_not be_valid
              end

              it "adds the uniqueness error" do
                login.valid?
                login.errors[:username].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:login) do
                Login.create(username: "Oxford")
              end

              it "returns true" do
                login.should be_valid
              end
            end
          end
        end

        context "when case sensitive is false" do

          before do
            Login.validates_uniqueness_of :username, case_sensitive: false
          end

          after do
            Login.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            context "when there are no special characters" do

              before do
                Login.create(username: "Oxford")
              end

              let(:login) do
                Login.new(username: "Webster")
              end

              it "returns true" do
                login.should be_valid
              end
            end

            context "when special characters exist" do

              before do
                Login.create(username: "Oxford")
              end

              let(:login) do
                Login.new(username: "Web@st.er")
              end

              it "returns true" do
                login.should be_valid
              end
            end
          end

          context "when the attribute is not unique" do

            context "when the document is not the match" do

              before do
                Login.create(username: "Oxford")
              end

              let(:login) do
                Login.new(username: "oxford")
              end

              it "returns false" do
                login.should_not be_valid
              end

              it "adds the uniqueness error" do
                login.valid?
                login.errors[:username].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:login) do
                Login.create(username: "Oxford")
              end

              it "returns true" do
                login.should be_valid
              end
            end
          end
        end

        context "when allowing nil" do

          before do
            Login.validates_uniqueness_of :username, allow_nil: true
          end

          after do
            Login.reset_callbacks(:validate)
          end

          context "when the attribute is nil" do

            before do
              Login.create
            end

            let(:login) do
              Login.new
            end

            it "returns true" do
              login.should be_valid
            end
          end
        end

        context "when allowing blank" do

          before do
            Login.validates_uniqueness_of :username, allow_blank: true
          end

          after do
            Login.reset_callbacks(:validate)
          end

          context "when the attribute is blank" do

            before do
              Login.create(username: "")
            end

            let(:login) do
              Login.new(username: "")
            end

            it "returns true" do
              login.should be_valid
            end
          end
        end
      end
    end
  end

  context "when the document is embedded" do

    let(:word) do
      Word.create(name: "Schadenfreude")
    end

    context "when in an embeds_many" do

      context "when the document does not use composite keys" do

        context "when no scope is provided" do

          before do
            Definition.validates_uniqueness_of :description
          end

          after do
            Definition.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            before do
              word.definitions.build(description: "Malicious joy")
            end

            let(:definition) do
              word.definitions.build(description: "Gloating")
            end

            it "returns true" do
              definition.should be_valid
            end
          end

          context "when the attribute is not unique" do

            context "when the document is not the match" do

              before do
                word.definitions.build(description: "Malicious joy")
              end

              let(:definition) do
                word.definitions.build(description: "Malicious joy")
              end

              it "returns false" do
                definition.should_not be_valid
              end

              it "adds the uniqueness error" do
                definition.valid?
                definition.errors[:description].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:definition) do
                word.definitions.build(description: "Malicious joy")
              end

              it "returns true" do
                definition.should be_valid
              end
            end
          end
        end

        context "when a single scope is provided" do

          before do
            Definition.validates_uniqueness_of :description, scope: :part
          end

          after do
            Definition.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            before do
              word.definitions.build(
                description: "Malicious joy", part: "Noun"
              )
            end

            let(:definition) do
              word.definitions.build(description: "Gloating")
            end

            it "returns true" do
              definition.should be_valid
            end
          end

          context "when the attribute is unique in the scope" do

            before do
              word.definitions.build(
                description: "Malicious joy",
                part: "Noun"
              )
            end

            let(:definition) do
              word.definitions.build(
                description: "Gloating",
                part: "Noun"
              )
            end

            it "returns true" do
              definition.should be_valid
            end
          end

          context "when the attribute is not unique with no scope" do

            before do
              word.definitions.build(
                description: "Malicious joy",
                part: "Noun"
              )
            end

            let(:definition) do
              word.definitions.build(description: "Malicious joy")
            end

            it "returns true" do
              definition.should be_valid
            end
          end

          context "when the attribute is not unique in another scope" do

            before do
              word.definitions.build(
                description: "Malicious joy",
                part: "Noun"
              )
            end

            let(:definition) do
              word.definitions.build(
                description: "Malicious joy",
                part: "Adj"
              )
            end

            it "returns true" do
              definition.should be_valid
            end
          end

          context "when the attribute is not unique in the same scope" do

            context "when the document is not the match" do

              before do
                word.definitions.build(
                  description: "Malicious joy",
                  part: "Noun"
                )
              end

              let(:definition) do
                word.definitions.build(
                  description: "Malicious joy",
                  part: "Noun"
                )
              end

              it "returns false" do
                definition.should_not be_valid
              end

              it "adds the uniqueness errors" do
                definition.valid?
                definition.errors[:description].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:definition) do
                word.definitions.build(
                  description: "Malicious joy",
                  part: "Noun"
                )
              end

              it "returns true" do
                definition.should be_valid
              end
            end
          end
        end

        context "when multiple scopes are provided" do

          before do
            Definition.validates_uniqueness_of :description, scope: [ :part, :regular ]
          end

          after do
            Definition.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            before do
              word.definitions.build(
                description: "Malicious joy",
                part: "Noun"
              )
            end

            let(:definition) do
              word.definitions.build(description: "Gloating")
            end

            it "returns true" do
              definition.should be_valid
            end
          end

          context "when the attribute is unique in the scope" do

            before do
              word.definitions.build(
                description: "Malicious joy",
                part: "Noun",
                regular: true
              )
            end

            let(:definition) do
              word.definitions.build(
                description: "Gloating",
                part: "Noun",
                regular: true
              )
            end

            it "returns true" do
              definition.should be_valid
            end
          end

          context "when the attribute is not unique with no scope" do

            before do
              word.definitions.build(
                description: "Malicious joy",
                part: "Noun"
              )
            end

            let(:definition) do
              word.definitions.build(description: "Malicious scope")
            end

            it "returns true" do
              definition.should be_valid
            end
          end

          context "when the attribute is not unique in another scope" do

            before do
              word.definitions.build(
                description: "Malicious joy",
                part: "Noun",
                regular: true
              )
            end

            let(:definition) do
              word.definitions.build(
                description: "Malicious joy",
                part: "Adj",
                regular: true
              )
            end

            it "returns true" do
              definition.should be_valid
            end
          end

          context "when the attribute is not unique in the same scope" do

            context "when the document is not the match" do

              before do
                word.definitions.build(
                  description: "Malicious joy",
                  part: "Noun",
                  regular: true
                )
              end

              let(:definition) do
                word.definitions.build(
                  description: "Malicious joy",
                  part: "Noun",
                  regular: true
                )
              end

              it "returns false" do
                definition.should_not be_valid
              end

              it "adds the uniqueness errors" do
                definition.valid?
                definition.errors[:description].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:definition) do
                word.definitions.build(
                  description: "Malicious joy",
                  part: "Noun",
                  regular: false
                )
              end

              it "returns true" do
                definition.should be_valid
              end
            end
          end
        end

        context "when case sensitive is true" do

          before do
            Definition.validates_uniqueness_of :description
          end

          after do
            Definition.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            before do
              word.definitions.build(description: "Malicious jo")
            end

            let(:definition) do
              word.definitions.build(description: "Gloating")
            end

            it "returns true" do
              definition.should be_valid
            end
          end

          context "when the attribute is not unique" do

            context "when the document is not the match" do

              before do
                word.definitions.build(description: "Malicious joy")
              end

              let(:definition) do
                word.definitions.build(description: "Malicious joy")
              end

              it "returns false" do
                definition.should_not be_valid
              end

              it "adds the uniqueness error" do
                definition.valid?
                definition.errors[:description].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:definition) do
                word.definitions.build(description: "Malicious joy")
              end

              it "returns true" do
                definition.should be_valid
              end
            end
          end
        end

        context "when case sensitive is false" do

          before do
            Definition.validates_uniqueness_of :description, case_sensitive: false
          end

          after do
            Definition.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            context "when there are no special characters" do

              before do
                word.definitions.build(description: "Malicious joy")
              end

              let(:definition) do
                word.definitions.build(description: "Gloating")
              end

              it "returns true" do
                definition.should be_valid
              end
            end

            context "when special characters exist" do

              before do
                word.definitions.build(description: "Malicious joy")
              end

              let(:definition) do
                word.definitions.build(description: "M@licious.joy")
              end

              it "returns true" do
                definition.should be_valid
              end
            end
          end

          context "when the attribute is not unique" do

            context "when the document is not the match" do

              before do
                word.definitions.build(description: "Malicious joy")
              end

              let(:definition) do
                word.definitions.build(description: "Malicious JOY")
              end

              it "returns false" do
                definition.should_not be_valid
              end

              it "adds the uniqueness error" do
                definition.valid?
                definition.errors[:description].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:definition) do
                word.definitions.build(description: "Malicious joy")
              end

              it "returns true" do
                definition.should be_valid
              end
            end
          end
        end

        context "when allowing nil" do

          before do
            Definition.validates_uniqueness_of :description, allow_nil: true
          end

          after do
            Definition.reset_callbacks(:validate)
          end

          context "when the attribute is nil" do

            before do
              word.definitions.build
            end

            let(:definition) do
              word.definitions.build
            end

            it "returns true" do
              definition.should be_valid
            end
          end
        end

        context "when allowing blank" do

          before do
            Definition.validates_uniqueness_of :description, allow_blank: true
          end

          after do
            Definition.reset_callbacks(:validate)
          end

          context "when the attribute is blank" do

            before do
              word.definitions.build(description: "")
            end

            let(:definition) do
              word.definitions.build(description: "")
            end

            it "returns true" do
              definition.should be_valid
            end
          end
        end
      end

      context "when the document uses composite keys" do

        context "when no scope is provided" do

          before do
            WordOrigin.validates_uniqueness_of :origin_id
          end

          after do
            WordOrigin.reset_callbacks(:validate)
          end

          context "when the attribute is unique" do

            before do
              word.word_origins.build(origin_id: 1)
            end

            let(:word_origin) do
              word.word_origins.build(origin_id: 2)
            end

            it "returns true" do
              word_origin.should be_valid
            end
          end

          context "when the attribute is not unique" do

            context "when the document is not the match" do

              before do
                word.word_origins.build(origin_id: 1)
              end

              let(:word_origin) do
                word.word_origins.build(origin_id: 1)
              end

              it "returns false" do
                word_origin.should_not be_valid
              end

              it "adds the uniqueness error" do
                word_origin.valid?
                word_origin.errors[:origin_id].should eq([ "is already taken" ])
              end
            end

            context "when the document is the match in the database" do

              let!(:word_origin) do
                word.word_origins.build(origin_id: 1)
              end

              it "returns true" do
                word_origin.should be_valid
              end
            end
          end
        end

        context "when allowing nil" do

          before do
            WordOrigin.validates_uniqueness_of :origin_id, allow_nil: true
          end

          after do
            WordOrigin.reset_callbacks(:validate)
          end

          context "when the attribute is nil" do

            before do
              word.word_origins.build
            end

            let(:word_origin) do
              word.word_origins.build
            end

            it "returns true" do
              word_origin.should be_valid
            end
          end
        end

        context "when allowing blank" do

          before do
            WordOrigin.validates_uniqueness_of :origin_id, allow_blank: true
          end

          after do
            WordOrigin.reset_callbacks(:validate)
          end

          context "when the attribute is blank" do

            before do
              word.word_origins.build(origin_id: "")
            end

            let(:word_origin) do
              word.word_origins.build(origin_id: "")
            end

            it "returns true" do
              word_origin.should be_valid
            end
          end
        end
      end
    end

    context "when in an embeds_one" do

      before do
        Pronunciation.validates_uniqueness_of :sound
      end

      after do
        Pronunciation.reset_callbacks(:validate)
      end

      let(:pronunciation) do
        word.build_pronunciation(sound: "Schwa")
      end

      it "always returns true" do
        pronunciation.should be_valid
      end
    end
  end
end
