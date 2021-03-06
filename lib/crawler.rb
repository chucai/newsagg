module NewsAgg
  class Crawler
    attr_accessor :medium

    def initialize(medium)
      @medium = medium
    end

    def process
      feed_items.each do |feed_item|
        item = Item.new(feed_item)

        unless item.exists?
          parser  = NewsAgg::Parser::Html.new(item.url, medium.selector)
          item.content = parser.content
          item.save
        end
      end

      Category.clean_old_items!
    end

    def self.start
      Medium.all.each do |medium|
        crawler = Crawler.new(medium)
        crawler.process
      end

      Clusters.create!
    end

    private
      def feed_items
        parser = NewsAgg::Parser::Rss.new(medium.key, medium.feeds)
        parser.items
      end
  end
end
