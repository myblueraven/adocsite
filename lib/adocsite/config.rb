module Adocsite
  ##################################
  # AdocSite configuration
  #

  def config
    @settings || Adocsite::DefaultSettings
  end

  def config= value
    @settings = self.config.merge(value)
  end

  DefaultSettings = {
    # general stuff
    :SITE_TITLE => "Site Title",
    # if you really want you can put site url here
    # but then you will not be able to browse site by
    # opening index.html file from file explorer
    :SITE_URL => "",

    # input locations
    :INPUT_FOLDERS => ["work", "docs"],
    :TEMPLATES_FOLDER => File.join(File.dirname(__FILE__), "..", "..", "tpl"),

    # output locations
    :OUTPUT_FOLDER => "deploy",
    :STYLES_FOLDER => "css",
    :SCRIPTS_FOLDER => "js",
    :IMAGES_FOLDER => "img",

    # templates
    :THEME => "default",

    # file filters
    :STYLES => ".css",
    :SCRIPTS => ".js",
    # constant (or variable) defined like this can be passed to method that accepts multiple arguments using *
    # i.e. String.ends_with?(*IMAGES)
    :IMAGES => [".jpg", ".jpeg", ".gif", ".png", ".tif", ".bmp", ".svg"],
    :DOCUMENTS => ".adoc",
    :TEMPLATES => ".haml",
  }
  
  ##################################
  # Posting articles to Wordpress
  #

  def wpconfig
    @wpsettings || Adocsite::DefaultWpSettings
  end

  def wpconfig= value
    @wpsettings = self.wpconfig.merge(value)
  end

  DefaultWpSettings = {
      :host => "localhost",
      :path => "/xmlrpc.php",
      :port => 80,
      :username => "editor",
      :password => "editor"
  }

  module_function :config, :config=, :wpconfig, :wpconfig=
end
