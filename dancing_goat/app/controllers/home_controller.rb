class HomeController < ApplicationController
  def index; end
  def article_list
    @response = @@delivery_client.items(
      'system.type'.eq 'article'
    )
    .order_by('elements.post_date', '[desc]')
    .execute
    if @response.http_code == 200
      render partial: 'article_tile', collection: @response.items, as: :article
    else
      logger.info @response.to_s
      render html: 'Sorry, articles are not available at this time'
    end
  end
end
