# Use as so:
# <%= semantic_menu do |root|
#   root.add "overview", root_path
#   root.add "comments", comments_path
# end %>
#
# Assuming you are on /comments, the output would be:
#
# <ul class="menu">
#   <li>
#     <a href="/">overview</a>
#   </li>
#   <li class="active">
#     <a href="/comments">comments</a>
#   </li>
# </ul>
module MenuHelper
  def semantic_menu(opts={}, &block)
    SemanticMenu.new(controller, opts, &block).to_s
  end
end
