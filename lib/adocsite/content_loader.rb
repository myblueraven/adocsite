module Adocsite
  class ContentLoader
    attr_reader :styles, :scripts, :images, :files, :pages, :articles
    def initialize
      @adoc_options = {:attributes => {
        "imagesdir" => Adocsite::config[:IMAGES_FOLDER],
        "stylesdir" => Adocsite::config[:STYLES_FOLDER],
        "iconsdir" => Adocsite::config[:IMAGES_FOLDER] + "/icons"
        }}

      # files to copy
      @styles = Array.new
      @scripts = Array.new
      @images = Array.new
      @files = Array.new

      #content
      @pages = Hash.new
      @articles = Hash.new
    end

    def find_all_files
      file_list = []
      Adocsite::config[:INPUT_FOLDERS].each {|input_folder|
        file_list.concat(Dir[File.join(input_folder, "**","*")].reject {|x| File.directory?(x)})
      }
      return file_list
    end

    def load_assets
      all_files = find_all_files

      @content = all_files.select {|path| path.end_with?(*Adocsite::config[:DOCUMENTS])}

      @styles = all_files.select {|path| path.end_with?(*Adocsite::config[:STYLES])}
      @scripts = all_files.select {|path| path.end_with?(*Adocsite::config[:SCRIPTS])}
      @images = all_files.select {|path| path.end_with?(*Adocsite::config[:IMAGES])}
      @files = all_files - @images - @scripts - @styles - @content

      build_pages_and_articles
    end

    def build_pages_and_articles
      @content.each {|path|
        adoc = Asciidoctor::load_file(path, @adoc_options)
        if adoc.attributes["page"].nil?
          article = Article.new(adoc)
        @articles[article.name] = article
        else
          page = Page.new(adoc)
        @pages[page.name] = page
        end
      }

    end

    private :build_pages_and_articles, :find_all_files
  end
end
