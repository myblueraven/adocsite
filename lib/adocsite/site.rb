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

    def copy_content
      styles_folder = File.join(Adocsite::config[:OUTPUT_FOLDER], Adocsite::config[:STYLES_FOLDER])
      images_folder = File.join(Adocsite::config[:OUTPUT_FOLDER], Adocsite::config[:IMAGES_FOLDER])
      scripts_folder = File.join(Adocsite::config[:OUTPUT_FOLDER], Adocsite::config[:SCRIPTS_FOLDER])
      files_folder = File.join(Adocsite::config[:OUTPUT_FOLDER])

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
