module Comments
  class RepliesController < ApplicationController
    def index
      respond_to do |format|
        format.html
        format.json
      end
    end
  end
end
