# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'issue_detail/:id', to: 'issue_tooltip#issue_detail', constraints: { id: /\d+/ }
get 'issue_tooltip/attachment_file/:id', to: 'issue_tooltip#attachment_file', constraints: { id: /\d+/ }
