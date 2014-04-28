module Adocsite
  class Templates
    attr_reader :styles, :scripts, :images, :files, :layouts, :partials, :includes, :literals, :resources
    def initialize
      @options = {:remove_whitespace => true}
      # files to copy
      @styles = Array.new
      @scripts = Array.new
      @images = Array.new
      @files = Array.new
      @resources = Array.new

      # theme template files
      # hashmap keys are template names without .haml extension and values are full paths
      # literal names are full file names (without path portion) and values are full paths
      @layouts = Hash.new
      @partials = Hash.new
      @includes = Hash.new
      @literals = Hash.new

      @theme_location = File.join(Adocsite::config[:TEMPLATES_FOLDER], Adocsite::config[:THEME])
    end

    def find_all_files
      Dir[File.join(@theme_location, "**", "*")].reject {|x| File.directory?(x)}
    end

    def load_assets
      all_files = find_all_files

      templates = all_files.select {|path| path.end_with?(*Adocsite::config[:TEMPLATES])}
      # theme resources have to be copied with folder structure preserved so we treat them separately in Site class
      @resources = Dir[File.join(@theme_location, "resources", "**", "*")].reject {|x| File.directory?(x)}

      @styles = all_files.select {|path| path.end_with?(*Adocsite::config[:STYLES])} - @resources
      @scripts = all_files.select {|path| path.end_with?(*Adocsite::config[:SCRIPTS])} - @resources
      @images = all_files.select {|path| path.end_with?(*Adocsite::config[:IMAGES])} - @resources
      @files = all_files - @images - @scripts - @styles - @resources - templates

      # loads layouts, partials, includes and literals into hashmaps.
      # hashmap keys are template names without .haml extension and values are full paths
      # literal names are full file names (without path portion) and values are full paths
      layouts = templates.select {|path| path.start_with?(File.join(@theme_location, "layouts")) }
      layouts.each {|layout|
        layout_name = File.basename(layout, '.*')
        @layouts[layout_name] = layout
      }
      partials = templates.select {|path| path.start_with?(File.join(@theme_location, "partials")) }
      partials.each {|partial|
        partial_name = File.basename(partial, '.*')
        @partials[partial_name] = partial
      }
      includes = templates.select {|path| path.start_with?(File.join(@theme_location, "includes")) }
      includes.each {|include|
        include_name = File.basename(include, '.*')
        @includes[include_name] = include
      }
      literals = @files.select {|path| path.start_with?(File.join(@theme_location, "literals")) }
      literals.each {|literal|
        literal_name = File.basename(literal)
        @literals[literal_name] = literal
      }
      @files = @files - literals
      all_files
    end

    def get_partial(partial_name)
      partial_tpl = @partials[partial_name]
      tpl = Tilt.new(partial_tpl, @options)
      return tpl
    end

    def get_include(include_name)
      include_tpl = @includes[include_name]
      tpl = Tilt.new(include_tpl, @options)
      return tpl
    end

    def get_literal(literal_name)
      literal_tpl = @literals[literal_name]
      # literals are not processed, they are literals
      tpl = File.read(literal_tpl)
      return tpl
    end

    def get_layout(layout_name = "default")
      layout_tpl = @layouts[layout_name]
      tpl = Tilt.new(layout_tpl, @options)
      return tpl
    end

    private :find_all_files

  end
end
