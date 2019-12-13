module Kentico
  module Kontent
    module Delivery
      # Holds pagination data from listing responses
      class Pagination
        attr_accessor :skip, :limit, :count, :next_page, :total_count

        # Constructor.
        #
        # * *Args*:
        #   - *json* (+JSON+) The 'pagination' node of a listing reponse's JSON object 
        def initialize(json)
          self.skip = json['skip']
          self.limit = json['limit']
          self.count = json['count']
          self.next_page = json['next_page']
          self.total_count = json['total_count']
        end
      end
    end
  end
end
