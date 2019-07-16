module Storytime::ScopedToSite
  extend ActiveSupport::Concern

  included do
    default_scope do 
      if Storytime::Site.current_id.present? 
        where(site_id: Storytime::Site.current_id)
      end
    end
  end
  
end