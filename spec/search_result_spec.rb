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
      expect(from.class).to eq(Date)
      to = @committee_result.period[:to]
      expect(to.class).to eq(Date)
      expect(to).to be >= from
    end

  end

  context "filing" do

    it "should make filing accessible" do
      expect(@date_result.filing.class).to eq(Fech::Filing)
      expect(@committee_result.filing.class).to eq(Fech::Filing)
    end

    it "should create filing object for correct filing" do
      filing = @committee_result.filing
      expect(filing.filing_id).to eq(@committee_result.filing_id)
    end

    it "should pass arguments to Fech::Filing#new" do
      filing = @date_result.filing(:download_dir => "/tmp")
      expect(filing.download_dir).to eq("/tmp")
    end

  end


end
