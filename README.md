# Fech-Search

Fech-Search is a plugin for [Fech](http://nytimes.github.io/Fech/) that adds an interface for searching for electronic filings submitted to the Federal Election Commission. Where Fech provides a way to download and parse filings, Fech-Search provides users with a way to find the filings they're interested in.

Fech-Search is essentially a Ruby wrapper around the [electronic filing search form on the FEC's website](http://www.fec.gov/finance/disclosure/efile_search.shtml).

## Usage

Because Fech-Search requires Fech, you need only require 'fech-search' to use both:

    require 'fech-search'

Begin searching for filings by creating a Fech::Search object with the desired parameters. For example:

    search = Fech::Search.new(:committee_id => "C00410118")

The following search parameters are available:

- __:committee_id__ (The nine-character committee ID assigned by the FEC)
    - examples: "C00499202", "C00130187"
- __:committee_name__
    - examples: "Restore Our Future", "Obama for America"
- __:state__ (Two-character state abbreviation)
    - examples: "MA", "FL"
- __:party__ (Three-character party abbreviation)
    - examples: "REP", "DEM"
- __:committee_type__ (One-character committee type. [See a list of committee types](http://www.fec.gov/finance/disclosure/metadata/CommitteeTypeCodes.shtml))
    - examples: "H", "P"
- __:report_type__ ([See a list of report types](http://www.fec.gov/finance/disclosure/metadata/ReportTypeCodes.shtml))
    - examples: "M4", "Q1"
- __:date__ (A Ruby Date object)
- __:form_type__ ([See below for a list of form types](#form-types))
    - examples: "F3", "F24"
  
Any number of these parameters may be used. However, the FEC's search functionality has some limitations:

- All other parameters are ignored when :committee_id is used.
- :form_type cannot be used by itself; another parameter must be used with it.

An ArgumentError will be raised if either of these is violated with Fech::Search.new.

Also note that overly broad searches can be slow, so you should make your search as specific as possible.

A list of filings matching the search parameters may then be a accessed with Search#results:

    results = search.results

Each SearchResult object includes basic data about the filing:
  
    >> results[0]
    #<Fech::SearchResult:0x000001028a59f0
    @amended_by=nil,
    @committee_id="C00410118",
    @committee_name="BACHMANN FOR CONGRESS",
    @date_filed=#<Date: 2013-05-29 (4912883/2,0,2299161)>,
    @date_format="%m/%d/%Y",
    @description="YEAR-END",
    @filing_id="872805",
    @form_type="F3A",
    @period=
    {:from=>%<8b0f7347Date: 2012-11-27 (4912517/2,0,2299161)>,
     :to=>#<Date: 2012-12-31 (4912585/2,0,2299161)>}>

To access the Fech::Filing object for a search result, just call SearchResult#filing:

    >> filing = results[0].filing
    #<Fech::Filing:0x00000101777e58
    @csv_parser=Fech::Csv,
    @customized=false,
    @download_dir="/var/folders/Sz/SzmbeiAqFvqD8BYScDKkGE+++TI/-Tmp-",
    @encoding="iso-8859-1:utf-8",
    @filing_id="872805",
    @quote_char="\"",
    @resaved=false,
    @translator=
      #<Fech::Translator:0x00000101777bd8
       @aliases=[],
       @cache={},
       @translations=[]>>

You now have access to the same filing object and methods as if you had created it directly through [Fech](http://nytimes.github.io/Fech/).

To initialize the filing with parameters, pass them as arguments to the SearchResult#filing method:
  
    >> filing = results[0].filing(:csv_parser => Fech::CsvDoctor)

See the [Fech documentation](http://nytimes.github.io/Fech/) for more on initialization options.


#### Form types

- F1: STATEMENT OF ORGANIZATION
- F1M: NOTIFICATION OF MULTICANDIDATE STATUS
- F2: STATEMENT OF CANDIDACY
- F24: 24/48 HOUR NOTICE OF INDEPENDENT EXPENDITURES OR COORDINATED EXPENDITURES
- F3: RPT OF RECEIPTS AND DISBURSEMENTS - AUTHORIZED CMTE
- F3P: RPT OF RECEIPTS AND DISBURSEMENTS - AUTHORIZED CMTE (PRES/VICE PRES)
- F3X: RPT OF RECEIPTS AND DISBURSEMENTS - NON-AUTHORIZED CMTE
- F3L: RPT OF CONTRIBUTIONS BUNDLED BY LOBBYIST/REGISTRANTS AND LOBBYIST/REGISTRANT PACS
- F4: RPT OF RECEIPTS AND DISBURSEMENTS - CONVENTION CMTE
- F5: RPT OF INDEPENDENT EXPENDITURES MADE AND CONTRIBUTIONS RECEIVED
- F6: 48-HOUR NOTICE OF CONTRIBUTIONS/LOANS RECEIVED
- F7: RPT OF COMMUNICATION COSTS - CORPORATIONS AND MEMBERSHIP ORGS
- F8: DEBT SETTLEMENT PLAN
- F9: 24-HOUR NOTICE OF DISBURSEMENT/OBLIGATIONS FOR ELECTIONEERING COMMUNICATIONS
- F10: 24-HOUR NOTICE OF EXPENDITURE FROM CANDIDATE'S PERSONAL FUNDS
- F13: RPT OF DONATIONS ACCEPTED FOR INAUGURAL COMMITTEE
- F99: MISCELLANEOUS SUBMISSION

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

## Copyright

Copyright © 2013 The Huffington Post. See LICENSE for details.
