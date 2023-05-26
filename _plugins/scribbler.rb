require 'set'
require 'fileutils'

module LiterateProgramming
  class ScribbleTag < Liquid::Tag
    include Jekyll::Filters::URLFilters

    def initialize(tag_name, input, tokens)
      super
      input.strip!
      @scribble_doc = input
      @html_doc = File.basename(input).sub(/\.scrbl$/, '.html')
    end

    def render(context)
      site = context.registers[:site]
      output_dir = @scribble_doc.sub(/\.scrbl$/, '')
      full_output_dir = File.join(site.config['source'], output_dir)
      FileUtils.mkdir_p(full_output_dir) unless File.exist?(full_output_dir)

      redirect_url = "https://docs.racket-lang.org/local-redirect/index.html"
      scribble_command = "raco scribble --html +m --redirect #{redirect_url} --dest #{full_output_dir} #{@scribble_doc}"
      Jekyll.logger.info "Scribbler:", "Scribbling #{@scribble_doc}"
      return unless system(scribble_command)
      Dir.glob(File.join(full_output_dir, '*')) do |file|
        Jekyll.logger.info "Scribbler:", "Registering static file #{File.join(site.config['source'], output_dir, File.basename(file))}"
        site.static_files << Jekyll::StaticFile.new(site, site.config['source'], output_dir, File.basename(file))
      end
      Jekyll::Hooks.register :site, :post_write do |_|
        if File.exist?(full_output_dir)
          Jekyll.logger.info "Scribbler:", "Cleaning up #{full_output_dir}"
          FileUtils.rm_r(full_output_dir, secure: true)
        end
      end

      @context = context # hack for Jekyll::Filters::URLFilters ???
      link = absolute_url(File.join(output_dir, @html_doc))
      %Q{
<a href="#{link}">View full size</a>
<iframe class='scribbled' src="#{link}" title="Scribbled blog post"></iframe>
      }
    end
  end
end

Liquid::Template.register_tag('scribble', LiterateProgramming::ScribbleTag)
