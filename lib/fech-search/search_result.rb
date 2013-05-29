module Fech

  # Fech:SearchResult is a class representing a search result
  # from Fech::Search.
  class SearchResult
    attr_reader :committee_name, :committee_id, :filing_id, :form_type, :period, :date_filed, :description, :amended_by

    # @param [Hash] attrs The attributes of the search result.
    def initialize(attrs)
      @date_format = '%m/%d/%Y'

      @committee_name = attrs[:committee_name]
      @committee_id   = attrs[:committee_id]
      @filing_id      = attrs[:filing_id]
      @form_type      = attrs[:form_type]
      @period         = parse_period(attrs[:period])
      @date_filed     = Date.strptime(attrs[:date_filed], @date_format)
      @description    = attrs[:description]
      @amended_by     = attrs[:amended_by]
    end

    # Parse the string representing a filing period.
    # @param [String] period a string representing a filing period
    # @return [Hash, nil] a hash representing the start and end
    # of a filing period.
    def parse_period(period)
      return if period.nil?
      from, to = period.split('-')
      from = Date.strptime(from, @date_format)
      to = Date.strptime(to, @date_format)
      {:from => from, :to => to}
    end

    # The Fech filing object for this search result
    # @return [Fech::Filing]
    def filing(opts={})
      @filing ||= Fech::Filing.new(self.filing_id, opts)
    end
  end

end
