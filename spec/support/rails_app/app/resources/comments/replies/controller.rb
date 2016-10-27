module Comments
  class RepliesController
    def index
      respond_to do |format|
        format.html
        format.json
      end
    end
  end
end
