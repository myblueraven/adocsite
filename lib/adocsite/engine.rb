module Adocsite
  class Request
    attr_reader :type, :name
    def initialize(type = 'home', name = 'index')
      @type = type
      @name = name
    end
  end

  class RequestProcessing
    attr_accessor :rendered
    attr_reader :request
    def initialize(request)
      @request = request
      rendered = false
    end
  end

  class Engine
    LINK_DOCUMENT_EXTENSION = '.html'
    OUTPUT_DOCUMENT_EXTENSION = '.html'
    LOCATION_PAGE = ''
    LOCATION_ARTICLE = ''
    LOCATION_CATEGORY = ''
    attr_reader :content_loader, :templates, :categories
    def initialize
      # Internal stuff
      @page_context = Array.new
      @request_processing_queue = Hash.new

      # This is hashmap of Category objects.
      @categories = Hash.new

      @content_loader = ContentLoader.new
      @content_loader.load_assets

      @templates = Templates.new
      @templates.load_assets

      build_categories

      @site = Site.new(self)
      @site.prepare_output
      @site.copy_content
    end

    def build_categories
      # figure out categories and build hash of (category, articles)
      @categories = Hash.new
      @content_loader.articles.values.each {|article|
        article_title = article.title

        article.categories.each_index {|idx|
          cat = article.categories[idx]
          if @categories[cat] == nil
            @categories[cat] = Category.new(cat, [article])
          else
          @categories[cat].articles.push(article)
          end
        }
      }
    end

    def request_process_key(request)
      request.type + ':' + request.name
    end

    def add_to_processing_queue(request)
      # Add request into processing queue if it is not already there
      rp_key = request_process_key(request)
      if @request_processing_queue[rp_key] == nil
        @request_processing_queue[rp_key] = RequestProcessing.new(request)
      end
      return rp_key
    end

    def get_next_from_processing_queue
      if @request_processing_queue.empty?
        nil
      else
      # Find first element that is not yet processed
        idx = @request_processing_queue.values.index {|request_processing| !request_processing.rendered}
        if idx
        @request_processing_queue.values[idx]
        else
          nil
        end
      end
    end

    def process_requests(layout)
      # Get request from queue

      # request_processing = get_next_from_processing_queue

      while request_processing = get_next_from_processing_queue
        a_request = request_processing.request
        puts "Processing - '" + a_request.name + "'..."
        # Process request, which means render and save output
        context = Context.new(self, a_request)

        # this converts request into html page
        # all the heavy lifting is hidden behind this call
        output = context.get_layout(layout)
        # save it, nah?
        @site.write(output, a_request.name + OUTPUT_DOCUMENT_EXTENSION)

        # Mark this one as done
        request_processing.rendered = true
      end
    end

    def build(layout = "default")
      home = Request.new
      add_to_processing_queue(home)
      process_requests(layout)
    end

    def sitenav(request)
      # remember to actually generate this document later
      add_to_processing_queue(request)

      # now just create link text and return it to caller
      site_root = Adocsite::config[:SITE_URL]
      if request.type == "home"
        path = '/'
      elsif request.type == "page"
        path = LOCATION_PAGE + request.name + LINK_DOCUMENT_EXTENSION
      elsif request.type == "article"
        path = LOCATION_ARTICLE + request.name + LINK_DOCUMENT_EXTENSION
      elsif request.type == "category"
        path = LOCATION_CATEGORY + request.name + LINK_DOCUMENT_EXTENSION
      else
        path = ''
      end
      if site_root.empty?
      path
      else
        URI::HTTP.build({:host => site_root, :path => path})
      end
    end

    private :build_categories, :request_process_key, :process_requests, :add_to_processing_queue

  end

end
