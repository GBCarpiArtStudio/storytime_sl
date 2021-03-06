require_dependency "storytime/application_controller"

module Storytime
  class PagesController < ApplicationController
    before_action :load_page

    def show
      if params[:preview].nil? && @page && ((params[:id] != @page.slug) && (request.path != "/"))
        return redirect_to @page, :status => :moved_permanently
      end

      #allow overriding in the host app
      slug = @page.nil? ? ActionController::Base.helpers.sanitize(params[:id]) : @page.slug
      
      expires_in 3.hours, public: true, must_revalidate: true
      
      fresh_when @page

      potential_templates = [
        "storytime/#{@current_storytime_site.custom_view_path}/pages/#{slug}",
        "storytime/#{@current_storytime_site.custom_view_path}/pages/show",
        "storytime/pages/#{slug}",
        "storytime/pages/show",
      ].each do |template|
        if lookup_context.template_exists?(template)
          render template 
          return
        end
      end
    end

    def index
      self.show
    end

  private

    def load_page
      @page = if params[:preview]
        page = Post.find_preview(params[:id])
        page.content = page.autosave.content
        page.preview = true
        page
      elsif Post.friendly.exists? params[:id]
        Post.published.friendly.find(params[:id])
      else
        nil
      end
      redirect_to "/", status: :moved_permanently if @page == current_storytime_site(request).homepage
    end
  end
end
