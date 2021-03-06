# Fech-Search

Fech-Search is a plugin for [Fech](http://nytimes.github.io/Fech/) that adds an interface for searching for electronic filings submitted to the Federal Election Commission. Where Fech provides a way to download and parse filings, Fech-Search provides users with a way to find the filings they're interested in.

Fech-Search is essentially a Ruby wrapper around the [electronic filing search form on the FEC's website](http://www.fec.gov/finance/disclosure/efile_search.shtml).

## Usage

### Example

    require 'fech-search'

Perform a search for form F3P filings (report of receipts and disbursements) submitted by Romney for President:

    search = Fech::Search.new(:committee_name => "Romney for President", :form_type => "F3P")

The search is performed when `Fech::Search.new` is called. You can then access the results of the search with `search.results`, which is simply an array of `Fech::SearchResult` objects:

    results = search.results
    results.size
    => 100

Each `Fech::SearchResult` object has the following attributes:

- amended_by
- committee_id
- committee_name
- date_filed
- date_format
- description
- filing_id
- form_type
- period

You can now work with the results as you would any Ruby array.

Remove any filings that have been amended:

    results.select! { |r| r.amended_by.nil? }
    results.size
    => 41

Limit to filings covering the last six months of 2012:

    results.select! { |r| r.period[:from] >= Date.new(2012, 7, 1) && r.period[:to] <= Date.new(2012, 12, 31) }
    results.size
    => 6

Create a `Fech::Filing` object from one of the results and download the filing data:

    filing = results.first.filing.download

You now have access to the same filing object and methods as if you had created it directly with [Fech](http://nytimes.github.io/Fech/).

To initialize the `Fech::Filing` object with parameters, pass them as arguments to the `SearchResult#filing` method:

    filing = results.first.filing(:csv_parser => Fech::CsvDoctor)

Get information from the filing:

    filing.summary[:col_a_total_receipts]
    => "4747984.49"

    filing.summary[:col_b_total_receipts]
    => "10617838.18"

### Search parameters

The following search parameters are available:

- `:committee_id` (The nine-character committee ID assigned by the FEC)
    - examples: "C00499202", "C00130187"
- `:committee_name`
    - examples: "Restore Our Future", "Obama for America"
- `:state` (Two-character state abbreviation)
    - examples: "MA", "FL"
- `:party` (Three-character party abbreviation)
    - examples: "REP", "DEM"
- `:committee_type` (One-character committee type. [See a list of committee types](http://www.fec.gov/finance/disclosure/metadata/CommitteeTypeCodes.shtml))
    - examples: "H", "P"
- `:report_type` ([See a list of report types](http://www.fec.gov/finance/disclosure/metadata/ReportTypeCodes.shtml))
    - examples: "M4", "Q1"
- `:date` (A Ruby Date object)
- `:form_type` ([See the FEC's electronic filing search for a list of form types](http://www.fec.gov/finance/disclosure/efile_search.shtml))
    - examples: "F3", "F24"
  
Any number of these parameters may be used. However, the FEC's search functionality has some limitations:

- All other parameters are ignored when `:committee_id` is used.
- `:form_type` cannot be used by itself; another parameter must be used with it.

An `ArgumentError` will be raised if either of these is violated with `Fech::Search.new`.

__Note:__ Overly broad searches can be slow, so you should make your search as specific as possible.

## Installation

Add this line to your application's Gemfile:

    gem 'fech-search'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fech-search

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

- Aaron Bycoffe, bycoffe@huffingtonpost.com
- Derek Willis, dwillis@gmail.com

## Copyright

Copyright © 2013 The Huffington Post. See LICENSE for details.
