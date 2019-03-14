class ApplicationController < ActionController::Base
  PROJECT_ID = '<your-project-id>'.freeze
  item_resolver = KenticoCloud::Delivery::Resolvers::InlineContentItemResolver.new(lambda do |item|
    if (item.system.type.eql? 'hosted_video') && (item.elements.video_host.value[0].codename.eql? 'youtube')
      return "<iframe class='hosted-video__wrapper'
                    width='560'
                    height='315'
                    src='https://www.youtube.com/embed/#{item.elements.video_id.value}'
                    frameborder='0'
                    allowfullscreen
                    >
            </iframe>"
    end
  end)
  link_resolver = KenticoCloud::Delivery::Resolvers::ContentLinkResolver.new(lambda do |link|
    return "/coffees/#{link.url_slug}" if link.type.eql? 'coffee'
    return "/article/#{link.code_name}" if link.type.eql? 'article'
  end)
  @@delivery_client = KenticoCloud::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                   inline_content_item_resolver: item_resolver,
                                                   content_link_url_resolver: link_resolver
end
