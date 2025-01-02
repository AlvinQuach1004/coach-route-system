class DocsController < ApplicationController
  def erd
    render file: Rails.root.join('docs/erd.html'), layout: false
  end
end
