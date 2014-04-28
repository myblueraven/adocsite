module Adocsite
  class Site
    attr_reader :styles, :scripts, :images, :files
    def initialize(engine)
      # Internal
      @engine = engine

      # files to copy
      @styles = Array.new
      @scripts = Array.new
      @images = Array.new
      @files = Array.new
    end

    def prepare_output
      output_folder = File.join(Adocsite::config[:OUTPUT_FOLDER])
      Dir.mkdir(output_folder) unless Dir.exists?(output_folder)
      FileUtils.rm_rf(Dir.glob(File.join(output_folder,'*')))
    end

    def write(content, name)
      f = File.new(File.join(Adocsite::config[:OUTPUT_FOLDER], name), "w")
      f.write(content)
      f.close()
    end

    def copy_content_preserve_path(src, dst)
      src_folder = Pathname.new(src).realpath.dirname
      # quick and ugly
      source_folder = src_folder.to_s.partition("resources").last
      destination_folder = File.join(dst, source_folder)
      FileUtils.mkdir_p(destination_folder)
      FileUtils.cp(src, destination_folder)
    end
    
    def copy_resources(root_output_folder)
      @engine.templates.resources.each {|src| copy_content_preserve_path(src, root_output_folder)}
    end

    def copy_content
      root_output_folder = Adocsite::config[:OUTPUT_FOLDER]
      styles_folder = File.join(root_output_folder, Adocsite::config[:STYLES_FOLDER])
      images_folder = File.join(root_output_folder, Adocsite::config[:IMAGES_FOLDER])
      scripts_folder = File.join(root_output_folder, Adocsite::config[:SCRIPTS_FOLDER])
      files_folder = File.join(root_output_folder)

      # theme resources folder has to be copied verbatim, so we first do that
      copy_resources(root_output_folder)

      Dir.mkdir(files_folder) unless Dir.exists?(files_folder)
      Dir.mkdir(styles_folder) unless Dir.exists?(styles_folder)
      Dir.mkdir(scripts_folder) unless Dir.exists?(scripts_folder)
      Dir.mkdir(images_folder) unless Dir.exists?(images_folder)

      FileUtils.copy(@engine.content_loader.styles, styles_folder)
      FileUtils.copy(@engine.content_loader.scripts, scripts_folder)
      FileUtils.copy(@engine.content_loader.images, images_folder)
      FileUtils.copy(@engine.content_loader.files, files_folder)

      FileUtils.copy(@engine.templates.styles, styles_folder)
      FileUtils.copy(@engine.templates.scripts, scripts_folder)
      FileUtils.copy(@engine.templates.images, images_folder)
      FileUtils.copy(@engine.templates.files, files_folder)
    end
  end
end
