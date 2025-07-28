class IssueTooltipHook < Redmine::Hook::ViewListener
    def view_layouts_base_html_head( context = {} )
        return context[:controller].render_to_string(:partial => 'tx_issue_tooltip' )
    end
end