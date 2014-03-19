module Adocsite
  class WpPost
    attr_reader :categories, :content, :title, :excerpt, :name, :img_srcs, :post_media

    def initialize
      @engine = Adocsite::Engine::new

      @wp = Rubypress::Client.new(Adocsite.wpconfig)
    end
    
    def process_by_title(article_title)
      article_name = Adocsite::Content::title_to_name(article_title)
      process(article_name)
    end
    
    def process(article_name)
      @name = article_name
      context = Adocsite::Context::new(@engine, Adocsite::Request.new('article', @name))
      article = context.get_article
      if article.nil?
        abort "Can't find article."
      end

      @categories = article.categories
      @content = article.content
      @title = article.title
      @excerpt = article.abstract

      collect_images
      create_post
      upload_post_media
      replace_images(@post_media)
      update_post
    end
    
    def create_post
      # get all WP categories
      wp_categories = @wp.getTerms(:taxonomy => 'category')
      all_categories = Hash.new
      wp_categories.each {|term|
        all_categories[term['name']] = term['term_id']
      }
      
      # are there any new we need to create?
      new_categories_names = @categories - all_categories.keys
      
      # pp new_categories_names
      
      # create new categories, collect term_ids
      new_categories = Hash.new
      unless new_categories_names.empty?
        new_categories_names.each {|name|
          term_id = @wp.newTerm(:content => {:taxonomy => 'category', :name => name})
          new_categories[name] = term_id
        }
      end
      
      # create list of all article categories with their term_ids
      article_categories = Hash.new
      @categories.each {|name|
        if all_categories.include?(name)
          article_categories[name] = all_categories[name]
        end
        if new_categories.include?(name)
          article_categories[name] = new_categories[name]
        end
        }
      
      # now create new post from article
      @post_id = @wp.newPost(:content => {
            #  :post_type => 'post', # by default post_type is 'post'
            :post_status => 'draft', # post will be draft if post_status is omitted
            :post_title => @title,
            #  :post_author => 'admin', # by default post_author is same as user you use for calling wp.newPost method
            :post_excerpt => @excerpt,
            :post_content => "", # empty content for now
            :terms =>
            {
              :category => article_categories.values # these are term_ids for categories, if omitted default is 'Uncategorized'
            }
      })
      # pp post_id
      @post_id
    end
    
    def find_full_image_path(image_name, image_list)
      ret_arr = image_list.collect {|element|
        if element.end_with? image_name
          element
        else
          nil
        end
        }
      ret_arr.compact[0]
    end
    
    def upload_post_media
      site_images = @engine.content_loader.images
      @post_media = Hash.new
      @img_srcs.each {|image_name|
        file_path = find_full_image_path(image_name, site_images)
        # file_name = File.join("", file_path)
        file_name = file_path

        image_contents = XMLRPC::Base64.new(IO.read(file_name))
        image_type = MIME::Types.type_for(image_name).first.to_s

        media_upload = @wp.uploadFile(:data => {
            :name => image_name,
            :type => image_type,
            # :filename => file_name,
            :bits => image_contents,
            :overwrite => false,
            :post_id => @post_id
        })
        # media_upload[:url] is NOT going to work here
        @post_media[image_name] = media_upload["url"]
        # pp media_upload
      }
      
    end
    
    def update_post
      #Update/Edit post
      @post_id = @wp.editPost(:post_id => @post_id, 
        :content => {
            :post_status => 'publish', # it was created as draft, now publish it
            :post_content => @content
      })
      # pp post_id
      @post_id
    end

    def stringreturn(img_name)
      @img_hash[img_name]
    end
    
    def collect_images
      doc = Nokogiri::HTML(@content)
      img_srcs = doc.css('img').map{ |i| i['src'] } # Array of strings
      
      # pp article_content
      
      # pp img_srcs
      
      img_srcs = img_srcs.collect {|img_src|
        md = /^img\/(.*)/.match(img_src)
        md.captures[0] unless md == nil
      }
      
      @img_srcs = img_srcs.compact
      
      # pp img_srcs
    end

    def replace_images(new_images)
      @img_hash = Hash.new
      @img_srcs.each {|img_nm|
        # @img_hash[img_nm] = "\"myimages/#{img_nm}\""
        @img_hash[img_nm] = new_images[img_nm]
      }
      
      # pp article_content
      @content = @content.gsub(/"img\/(.*?)"/) {|img_tag| stringreturn("#$1")}
      # pp article_content
    end
    
    private :create_post, :find_full_image_path, :upload_post_media, :update_post, :stringreturn, :collect_images, :replace_images
  end
end
