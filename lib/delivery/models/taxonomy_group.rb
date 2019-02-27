module Delivery
  # JSON data of a taxonomy group parsed as OpenStruct objects for dynamic use
  class TaxonomyGroup
    def terms
      @terms unless @terms.nil?
      @terms = JSON.parse(
        JSON.generate(@source['terms']),
        object_class: OpenStruct
      )
    end

    def system
      @system unless @system.nil?
      @system = JSON.parse(
        JSON.generate(@source['system']),
        object_class: OpenStruct
      )
    end

    def initialize(source)
      @source = source
    end
  end
end