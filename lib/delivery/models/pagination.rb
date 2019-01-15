module Delivery
  # Holds pagination data from a DeliveryItemListingResponse
  class Pagination
    attr_accessor :skip, :limit, :count, :next_page

    def initialize(json)
      self.skip = json['skip']
      self.limit = json['limit']
      self.count = json['count']
      self.next_page = json['next_page']
    end
  end
end
