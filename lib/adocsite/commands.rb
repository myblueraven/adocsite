module Adocsite
  class Commands
    def Commands.build(args, options)
      Commands.load_config(args, options)

      engine = Adocsite::Engine.new
      engine.build(options.layout)
    end

    def Commands.dump(args, options)
      # default template
      FileUtils.cp_r(Adocsite.config[:TEMPLATES_FOLDER], "adocsite_default_template")

      # default configuration
      conf = <<-EOS
# Default configuration for Adocsite

Adocsite::config = #{Adocsite.config.pretty_inspect}

EOS
      File.open("adocsite_default_config.rb", 'w') {|f| f.write(conf) }
      
      # example of custom configuration file
      sample_custom_config = File.join(File.dirname(__FILE__), "..", "..", "examples", "myconfig.rb")
      FileUtils.cp(sample_custom_config, "adocsite_custom_config_sample.rb")
      
      # example of custom wp configuration file
      sample_custom_config = File.join(File.dirname(__FILE__), "..", "..", "examples", "mywpconfig.rb")
      FileUtils.cp(sample_custom_config, "adocsite_wp_config_sample.rb")
    end

    def Commands.post(args, options)
      Commands.load_config_wp(args, options)

      wp = Adocsite::WpPost.new
      
      if options.list
        alist = wp.list_articles
        atable = []
        alist.each_pair {|key, value|
          atable << [key.to_str, value]
          }
        puts Terminal::Table.new :headings => ['name', 'title'], :rows => atable
      elsif options.title
        wp.process_by_title(options.title)
      else
        article_name = args.shift || abort('Article title is required.')
        wp.process(article_name)
      end

      puts 'Done.'
    end

    def Commands.list(args, options)
      Commands.load_config(args, options)

      alist = Hash.new
      engine = Adocsite::Engine.new
      engine.content_loader.articles.collect{|key, article| alist[key] = article.title}

      atable = []
      alist.each_pair {|key, value|
        atable << [key.to_str, value]
        }
      puts Terminal::Table.new :headings => ['name', 'title'], :rows => atable

      puts 'Done.'
    end
    
    def Commands.load_config(args, options)
      user_config_file_name = options.config || "adocsite_config.rb"
      user_config_file = File.join(Dir.pwd, user_config_file_name)
      if File.exists?(user_config_file)
        require user_config_file
      else
        user_config_file = File.join(Dir.home, ".adocsite")
        if File.exists?(user_config_file)
          require user_config_file
        end
      end
    end
    
    def Commands.load_config_wp(args, options)
      user_config_file_name = options.config || "adocsite_wp_config.rb"
      user_config_file = File.join(Dir.pwd, user_config_file_name)
      if File.exists?(user_config_file)
        require user_config_file
      else
        user_config_file = File.join(Dir.home, ".adocsite_wp")
        if File.exists?(user_config_file)
          require user_config_file
        end
      end
    end
    
    private :Commands.load_config

  end
end
