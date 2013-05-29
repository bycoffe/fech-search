# Fech::Search

Fech-Search is a plugin for [Fech](http://nytimes.github.io/Fech/) that provides an interface for searching for electronic filings submitted to the Federal Election Commission.

Electronic filing searches are normally done through a [form on the FEC's website](http://www.fec.gov/finance/disclosure/efile_search.shtml). Fech-Search is a Ruby wrapper around this form, allowing you to programmatically search for filings.

## Usage

Because the Fech-Search plugin calls the require method for Fech, you need only require 'fech-search' to use both:

    require 'fech-search'

Begin searching for filings by creating a Fech::Search object with the desired parameters. For example:

    >> Fech::Search.new(:committee_id => "C00410118")

The following search parameters are available:

- :committee_id (The nine-character committee ID assigned by the FEC)
- :committee_name
- :state
- :party
- :committee_type ([See a list of types](http://www.fec.gov/finance/disclosure/metadata/CommitteeTypeCodes.shtml))
- :report_type
- :date
- :form_type
  
Any number of these parameters may be used, with one exception: :form_type cannot be used by itself; another parameter must be used with it.

A list of filings matching the search parameters may then be a accessed with Search#results:

    >> search = Fech::Search.new(:committee_id => "C00410118")
    >> results = search.results

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
