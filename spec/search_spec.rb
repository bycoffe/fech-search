require 'fech-search'

describe Fech::Search do

  context "creating" do

    it "should raise ArgumentError if no parameters are given" do
      expect { Fech::Search.new }.to raise_error(ArgumentError)
    end

    it "should raise ArgumentError if :committee_id is given with another parameter" do
      expect { Fech::Search.new(:committee_id => "C00431171", :date => Date.new(2013, 5, 16)) }.to raise_error(ArgumentError)
    end

    it "should raise ArgumentError if :form_type is given without another parameter" do
      expect { Fech::Search.new(:form_type => "F3") }.to raise_error(ArgumentError)
    end

    it "should not raise an error if :committee_id is given by itself" do
      expect { Fech::Search.new(:committee_id => "C00431171") }.to_not raise_error(ArgumentError)
    end

    it "should not raise an error if :form_type is given with another parameter" do
      expect { Fech::Search.new(:form_type => "F3", :date => Date.new(2013, 5, 29)) }.to_not raise_error(ArgumentError)
    end

  end

  context "results" do

    it "should return an array of results from committee search" do
      search = Fech::Search.new(:committee_id => "C00431171")
      search.results.class.should == Array
      search.results[0].class.should == Fech::SearchResult
    end

    it "should return an array of results from date search" do
      search = Fech::Search.new(:date => Date.new(2013, 5, 29))
      search.results.class.should == Array
      search.results[0].class.should == Fech::SearchResult
    end

    it "should return an array of results from date and report_type search" do
      search = Fech::Search.new(:date => Date.new(2013, 5, 29), :report_type => "M4")
      search.results.class.should == Array
      search.results[0].class.should == Fech::SearchResult
    end

  end

end
