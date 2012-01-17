require "spec_helper"

describe Mongoid::MultiParameterAttributes do

  describe "#process" do

    context "creating a post" do

      let(:post) do
        Post.new({
          "created_at(1i)" => "2010",
          "created_at(2i)" => "8",
          "created_at(3i)" => "12",
          "created_at(4i)" => "15",
          "created_at(5i)" => "45"
        })
      end

      it "should set a multi-parameter Time attribute correctly" do
        post.created_at.should == Time.local(2010, 8, 12, 15, 45)
      end

      it "should not leave ugly attributes on the model" do
        post.attributes.should_not have_key("created_at(1i)")
      end
    end

    context "creating a person" do

      context "with a valid DOB" do

        let(:person) do
          Person.new({
            "dob(1i)" => "1980",
            "dob(2i)" => "7",
            "dob(3i)" => "27"
          })
        end

        it "should set a multi-parameter Date attribute correctly" do
          person.dob.should == Date.civil(1980, 7, 27)
        end
      end

      context "with an invalid DOB" do

        it "should raise an exception" do
          lambda {
            Person.new({
              "dob(1i)" => "1980",
              "dob(2i)" => "2",
              "dob(3i)" => "31"
            })
          }.should raise_exception(
            Mongoid::MultiParameterAttributes::Errors::MultiparameterAssignmentErrors,
            "1 error(s) on assignment of multiparameter attributes"
          )
        end
      end
    end

    context "with a blank DOB" do

      let(:person) do
        Person.new({
          "dob(1i)" => "",
          "dob(2i)" => "",
          "dob(3i)" => ""
        })
      end

      it "should generate a nil date" do
        person.dob.should be_nil
      end
    end

    context "with a partially blank DOB" do

      let(:person) do
        Person.new({
          "dob(1i)" => "1980",
          "dob(2i)" => "",
          "dob(3i)" => ""
        })
      end

      it "should set empty date's year" do
        person.dob.year.should == 1980
      end

      it "should set empty date's month" do
        person.dob.month.should == 1
      end

      it "should set empty date's day" do
        person.dob.day.should == 1
      end
    end
  end
end