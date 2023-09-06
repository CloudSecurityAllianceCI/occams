# frozen_string_literal: true

# Nav Tag for unordered list of links to the children of the current page
#   {{ cms:children }}
#   {{ cms:children style: "font-weight: bold", exclude: "404-page, search-page" }}
# To customize your children style, add a 'children' id to your CSS, e.g
# #children {
#   color: #006633;
#   font-size: 90%;
#   margin-bottom: 4px;
#   font-style: italic;
# }
# and/or pass in style overrides with the 'style' parameter, as above
#
# To exclude children, list their slugs with the 'exclude' parameter
# as comma-delimited string, e.g. as above - exclude: "404-page, search-page"

class Occams::Content::Tag::Children < Occams::Content::Tag
  attr_reader :list, :style, :locals

  def initialize(context:, params: [], source: nil)
    super
    @locals = params.extract_options!
    @style  = ''
    @style  = "<style>#children {#{@locals['style']}}</style>" if @locals['style']
    @exclude = []
    @exclude = @locals['exclude'].split(',') if @locals['exclude']
    @list = ''
    # ActiveRecord_Associations_CollectionProxy
    page_children = context.children.order(:position).to_ary
    page_children.delete_if { |child| @exclude.include? child.slug }
    return unless page_children.any?

    @list = '<ul id="children">'
    page_children.each do |c|
      next if Rails.env == 'production' && !c.is_published

      @list += "<li><a href=#{c.url(relative: true)}>#{c.label}</a></li>"
    end
    @list += '</ul>'
  end

  def content
    format("#{@style}#{@list}")
  end
end

Occams::Content::Renderer.register_tag(
  :children, Occams::Content::Tag::Children
)