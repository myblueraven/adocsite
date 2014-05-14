# adocsite

[![Gem Version](https://badge.fury.io/rb/adocsite.svg)](http://badge.fury.io/rb/adocsite)

## ADocSite in a few words

The idea behind this gem is this:

* You have a bunch of text files where you keep your howto's, todo's, brilliant ideas, code snippets, etc. etc.
* There's just so many of them already, and you are loosing track of what is where
* You wish you can have a sort of index of them all where you can easily find them and navigate between them.

ADocSite takes:

* All those text files which are kept somewhere around in bunch of folders with funny names.
* All the images and other files that you keep with those text documents.

and generates one simple static web site out of it.

Now you can go, open index.html and browse through all those documents of yours and view them as web pages.

## Some more details 

ADocSite is implemented in [Ruby](https://www.ruby-lang.org/en/). It expects that all files with content are 
written as [asciidoc](http://www.methods.co.nz/asciidoc/) text files. These files are converted into HTML using [asciidoctor](http://asciidoctor.org/).

All documents are considered to be **articles** unless they are explicitly marked to be **pages**.
Articles can be grouped into **categories**, pages are entities for them selves. That's the only difference
between the two.

Usually, asciidoctor generates one complete HTML page from one text file, head, body and all. ADocSite uses
asciidoctor to render text file content as a HTML section, without html, head and body tags. This _partial_ HTML
text is then inserted into final HTML page at it's predeterminad place.

You can already tell: how final HTML pages look is determined by **templates**. ADocSite uses [HAML](http://haml.info/)
templates so its final output can take any shape and form you wish it to take.

So, there you have it:

ADocSite generates static web site.

All content consists of **asciidoc formatted text files**.

There are **articles**, organized into **categories**, and **pages**.

Final shape of everything is controlled by haml **templates**.

ADocSite **is** very simple to use and to play with. Don't let the _"asciidoc formatted text file"_ thing
scare you. You only need to know three things as a necessarry minimum to write asciidoc files:

* how to write a document title
* how to write a list of categories that the article belongs to
* how to type on a keyboard

That's it.

Really.

[Here, let me show you...](http://myblueraven.com/adocsite).


## Installation

Add this line to your application's Gemfile:

    gem 'adocsite'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install adocsite

## Usage

OK! So, you can do these things with adocsite:

    $ adocsite
    $ adocsite build
    $ adocsite dump

First two are identical: calling adocsite without parameters is same as asking it to do build.

### adocsite dump

If you run this command you will get adocsite to dump it's templates and configurations into current folder. So, after running:

    $ adocsite dump

you will end up with:

* folder **adocsite__default__templates** which will contain all HAML adocsite templates
* file **adocsite__default__config.rb** which contains adocsite default configuration
* file **adocsite__custom__config__sample.rb** with example of custom configuration for site builder
* file **adocsite__wp__config__sample.rb** with example of custom configuration for wordpress article poster (heavy beta phase, avoid it for now :o)

These can be your starting point for customizing/configuring adocsite output to your liking.

### adocsite build

Create folder to work in (let's say it's called "Documents")

    $ mkdir Documents
    $ cd Documents

Create folders in there to hold your stuff:

    $ mkdir work
    $ mkdir docs

Collect all your adoc documents into **work** and/or **docs** folder(s) you created in previous step.

Run adocsite:

    $ adocsite

After build is finished there will be new folder in **Documents** called **deploy**. There you can find output of adocsite's hard work. Open deploy/index.html in your browser and check out the results.

#### customize the build

If you would like to change what can be changed in adocsite, then first run

    $ adocsite dump

to get templates and default configs from adocsite.

Then you can make your own config file with custom settings (i.e. different names for folder(s) where you keep your documents, instead of default **work** and **docs**) or you can tweak existing or create new templates.

With config files you can do two things:

1. save them in the folder you use to run adocsite in (i.e. **Documents** from above example)
2. save them in your $HOME folder with names **.adocsite** and **.adocsite_wp** (notice the dot at the start)

If you choose 1. then you need to tell adocsite to use that config file by running it like this

    $ adocsite build --config my_custom_config.rb

or

    $ adocsite --config my_custom_config.rb

If you choose 2. then your custom configuration files will be used **always** when you run adocsite like usual:

    $ adocsite

or

    $ adocsite build

#### custom templates

If you choose to edit/create new HAML templates for adocsite, first dump the ones adocsite uses and start there. Templates folder contains subfolders whose names are used as names of layouts. Default layout will be taken from subfolder named, yes, **default**. If you want to choose different layout run adocsite like this:

    $ adocsite --layout adoc

This way adocsite will use templates from subfolder named **adoc** for building output.

If you make your own changes then

1. create templates folder (or rename one dumped by adocsite) 

## Contributing

1. Fork it ( http://github.com/<my-github-username>/adocsite/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
