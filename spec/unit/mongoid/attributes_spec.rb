require File.expand_path(File.join(File.dirname(__FILE__), "/../../spec_helper.rb"))

describe Mongoid::Attributes do

  describe "#process" do

    context "when supplied hash has values" do

      before do
        @attributes = {
          :_id => "1",
          :title => "value",
          :age => "30",
          :terms => "true",
          :name => {
            :_id => "2", :first_name => "Test", :last_name => "User"
          },
          :addresses => [
            { :_id => "3", :street => "First Street" },
            { :_id => "4", :street => "Second Street" }
          ]
        }
      end

      it "returns a properly cast the attributes" do
        attrs = Person.new(@attributes).attributes
        attrs[:age].should == 30
        attrs[:terms].should == true
        attrs[:_id].should == "1"
      end

    end

    context "when associations provided in the attributes" do

      context "when association is a has_one" do

        before do
          @name = Name.new(:first_name => "Testy")
          @attributes = {
            :name => @name
          }
          @person = Person.new(@attributes)
        end

        it "sets the associations" do
          @person.name.should == @name
        end

      end

      context "when association is a belongs_to" do

        before do
          @person = Person.new
          @name = Name.new(:first_name => "Tyler", :person => @person)
        end

        it "sets the association" do
          @name.person.should == @person
        end

      end

    end

  end

end
