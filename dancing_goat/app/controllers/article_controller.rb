class ArticleController < ApplicationController
  def show
    codename = params[:id]
    response = @@delivery_client.item(codename).execute
    if response.http_code == 200
      @article = response.item
      render partial: 'show'
    else
      logger.info response.to_s
      render html: 'The article you requested couldn\'t be found'
    end
  end
end
