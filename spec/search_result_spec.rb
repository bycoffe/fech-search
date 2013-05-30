require 'fech-search'

describe Fech::SearchResult do

  before do
    @date_search = Fech::Search.new(:date => Date.new(2013, 4, 20))
    @date_results = @date_search.results
    @date_result = @date_results.first
    @committee_search = Fech::Search.new(:committee_id => "C00431171")
    @committee_results = @committee_search.results
    @committee_result = @committee_results.first
  end

  context "creating" do

    it "should have valid dates for period" do
      from = @committee_result.period[:from]
      from.class.should == Date
      to = @committee_result.period[:to]
      to.class.should == Date
      to.should >= from
    end

  end

  context "filing" do

    it "should make filing accessible" do
      @date_result.filing.class.should == Fech::Filing
      @committee_result.filing.class.should == Fech::Filing
    end

    it "should create filing object for correct filing" do
      filing = @committee_result.filing
      filing.filing_id.should == @committee_result.filing_id
    end

    it "should pass arguments to Fech::Filing#new" do
      filing = @date_result.filing(:download_dir => "/tmp")
      filing.download_dir.should == "/tmp"
    end

  end


end
