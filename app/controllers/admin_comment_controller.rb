# app/controllers/admin_comment_controller.rb:
# Controller for editing comments from the admin interface.
#
# Copyright (c) 2007 UK Citizens Online Democracy. All rights reserved.
# Email: hello@mysociety.org; WWW: http://www.mysociety.org/

class AdminCommentController < AdminController
  before_action :set_comment, only: [:edit, :update]

  def index
    @title = 'Listing comments'
    @query = params[:query]

    comments = if @query
      Comment.where(["lower(body) LIKE lower('%'||?||'%')", @query]).
        order(created_at: :desc)
    else
      Comment.order(created_at: :desc)
    end

    comments = comments.not_embargoed if cannot? :admin, AlaveteliPro::Embargo

    @comments = comments.paginate page: params[:page], per_page: 100
  end

  def edit
    raise ActiveRecord::RecordNotFound if cannot? :admin, @comment
  end

  def update
    raise ActiveRecord::RecordNotFound if cannot? :admin, @comment

    old_body = @comment.body.dup
    old_visible = @comment.visible
    old_attention = @comment.attention_requested

    if @comment.update(comment_params)
      update_type = if comment_hidden?(old_visible, old_body)
                      'hide_comment'
                    else
                      'edit_comment'
                    end
      @comment.info_request.log_event(
        update_type,
        comment_id: @comment.id,
        editor: admin_current_user,
        old_body: old_body,
        body: @comment.body,
        old_visible: old_visible,
        visible: @comment.visible,
        old_attention_requested: old_attention,
        attention_requested: @comment.attention_requested
      )
      flash[:notice] = 'Comment successfully updated.'
      redirect_to admin_request_url(@comment.info_request)
    else
      render action: 'edit'
    end
  end

  private

  def comment_params
    if params[:comment]
      params.require(:comment).permit(:body, :visible, :attention_requested)
    else
      {}
    end
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_hidden?(old_visibility, old_body)
    !@comment.visible && old_visibility && old_body == @comment.body
  end
end
