require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket = tickets(:one)
    @comment = comments(:one)
    @viewer = users(:two)

    unless @viewer.apartments.exists?(@ticket.apartment_id)
      @viewer.apartments << @ticket.apartment
    end
  end

  test "owner can update own comment" do
    patch ticket_comment_url(@ticket, @comment), params: { comment: { content: "Comentario atualizado pelo dono" } }

    assert_redirected_to ticket_comment_url(@ticket, @comment)
    assert_equal "Comentario atualizado pelo dono", @comment.reload.content
  end

  test "non owner cannot update another user's comment" do
    sign_in @viewer

    patch ticket_comment_url(@ticket, @comment), params: { comment: { content: "Tentativa de edicao" } }

    assert_redirected_to buildings_url
    assert_equal "MyText", @comment.reload.content
  end
end
