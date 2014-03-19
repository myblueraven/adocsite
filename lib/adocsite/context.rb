module Adocsite
  class Context
    attr_reader :type
    def initialize(engine, request)
      @engine = engine
      @request = request
      @type = request.type
      @context_vars = Hash.new

      build_vars
    end

    def build_vars()
      # variables common to all contexts
      @context_vars = {
        :page_title => Adocsite::config[:SITE_TITLE],
      }

      if @type == "home"
        # @context_vars[] = 'nil'
        elsif @type == "page"
          @context_vars[:page] = get_page
        elsif @type == "article"
          @context_vars[:article] = get_article
        elsif @type == "category"
          @context_vars[:category] = get_category
        end
    end

    #--------------------------------------------------
    # these methods load other templates and render them
    # in the same context in which current document is rendered
    def get_partial(partial_name)
      tpl = @engine.templates.get_partial(partial_name)
      tpl.render(self, @context_vars)
    end

    def get_include(include_name)
      tpl = @engine.templates.get_include(include_name)
      tpl.render(self, @context_vars)
    end

    def get_literal(literal_name)
      @engine.templates.get_literal(literal_name)
    end

    def get_layout(layout_name = "default")
      tpl = @engine.templates.get_layout(layout_name)
      tpl.render(self, @context_vars)
    end
    #--------------------------------------------------

    #--------------------------------------------------
    # these methods behave the same in all contexts
    # they are context independet
    def is_context?(context_name)
      @type == context_name
    end

    def get_pages()
      @engine.content_loader.pages.values
    end

    def get_categories()
      @engine.categories.values
    end

    def get_articles(category = nil)
      if category
      @engine.categories[category]
      else
      @engine.content_loader.articles.values
      end
    end

    def sitenav(type, name)
      request = Request.new(type, name)
      @engine.sitenav(request)
    end
    #--------------------------------------------------

    #--------------------------------------------------
    # this is special kind of method that is used in layout template.
    # it gets correct partial for the layout depending on context.
    def get_content_for_layout()
      get_partial(@type)
    # if @type == "home"
    # get_partial('home')
    # elsif @type == "page"
    # get_partial('page')
    # elsif @type == "article"
    # get_partial('article')
    # elsif @type == "category"
    # get_partial('category')
    # end
    end
    #--------------------------------------------------

    #--------------------------------------------------
    # result of calling these depends on context in which
    # they are used, it depends on request that is made
    def get_article()
      @engine.content_loader.articles[@request.name]
    end

    def get_category()
      @engine.categories[@request.name]
    end

    def get_page()
      @engine.content_loader.pages[@request.name]
    end
    #--------------------------------------------------

    private :build_vars

  end
end