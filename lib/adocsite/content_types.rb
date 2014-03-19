module Adocsite
  class Content
    attr_reader :name, :title
    def initialize(adoc)
      @name = Content::title_to_name(adoc.doctitle)
      @title = adoc.doctitle
      @content = adoc.content
    end

    def self.title_to_name(title)
      title = title.strip
      title = title.gsub(/[^0-9A-Za-z.\-]/, '_')
      title = title.gsub(/[_]+/, '_')
    end

    def stringreturn(title, link_text)
      link_text = link_text.empty? ? title : link_text
      '<a href="'+Content::title_to_name(title)+'.html">'+link_text+'</a>'
    end

    def content()
      @content = @content.gsub(/sitenav:['"](.*)['"](\[(.*)\])?/) {|sitenav| stringreturn("#$1","#$3")}
    end

    private :stringreturn
  end

  class Article < Content
    UNCATEGORIZED_NAME = 'Uncategorized'
    attr_reader :categories, :abstract
    def initialize(adoc)
      super(adoc)
      @abstract = ''
      idx = adoc.blocks.index {|block| block.context==:preamble}
      if idx
        @abstract = adoc.blocks[idx].content
      end
      @categories = Array.new
      if adoc.attributes['categories'] != nil
        @categories = CSV.parse_line(adoc.attributes['categories'].gsub(/,\s+"/,',"'))
      else
        @categories << UNCATEGORIZED_NAME
      end
      @categories.each_index {|cat_idx|
        @categories[cat_idx] = @categories[cat_idx].strip
      }
    end
  end

  class Category
    attr_reader :name, :articles
    def initialize(name, articles)
      @name = name
      @articles = articles
    end
  end

  class Page < Content
  end
end
