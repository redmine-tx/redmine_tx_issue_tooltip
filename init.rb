Redmine::Plugin.register :redmine_tx_issue_tooltip do
  name 'Redmine Tx Issue Tooltip plugin'
  author 'KiHyun Kang'
  description '이슈에 마우스 커서 올리면 상세 내역 툴팁으로 보여줌'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end

Rails.application.config.after_initialize do
  require_dependency File.expand_path('../lib/issue_tooltip_hook', __FILE__)
end